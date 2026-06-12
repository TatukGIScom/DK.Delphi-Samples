//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Isochrone Map sample.

  Demonstrates how to compute travel-time (isochrone) zones from a chosen
  origin point on a road network using TGIS_IsochroneMap and TGIS_ShortestPath.

  Workflow:
    1. Load a road-network SHP layer (US TIGER edges for San Bernardino, CA).
    2. Style the layer to distinguish highways from local roads.
    3. Create an output TGIS_LayerVector for the isochrone polygons and a
       separate TGIS_LayerVector for the origin marker.
    4. Wire up three network-cost callbacks:
         - LinkCostEvent    : sets the base traversal cost to arc length.
         - LinkTypeEvent    : classifies arcs as highway (type 0) or local (type 1).
         - LinkDynamicEvent : optionally blocks highway links at run time.
    5. On each mouse click (in Select mode) the user picks an origin.
    6. generateIsochrone calls TGIS_IsochroneMap.Generate once per zone,
       dividing the maximum cost so each successive call covers a wider area.
    7. The resulting polygons are smoothed and displayed as colour-coded zones.
}

unit MainForm;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.ToolWin,

  //GisLicense,
  GisTypes,
  GisCsBase,
  GisIsochroneMap,
  GisLayerVector,
  GisLayerSHP,
  GisParams,
  GisShortestPath,
  GisTypesUI,
  GisUtils,

  Vcl.GisControlScale,
  Vcl.GisViewerWnd,
  VCL.GisControlLegend ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_ControlScale1: TGIS_ControlScale;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    trkSmallRoads: TTrackBar;
    trkHighways: TTrackBar;
    lblSmallRoads: TLabel;
    lblHighways: TLabel;
    edtDistance: TEdit;
    edtZones: TEdit;
    lblAddrFrom: TLabel;
    lblAddrTo: TLabel;
    GIS_ControlLegend1: TGIS_ControlLegend;
    tlb1: TToolBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    il1: TImageList;
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
  private
    { Private declarations }
    layerSrc   : TGIS_LayerVector ;
    layerRoute : TGIS_LayerVector ;
    layerMarker: TGIS_LayerVector ;
    rtrObj     : TGIS_IsochroneMap ;
    srtpObj    : TGIS_ShortestPath ;
    costFactor : Double ;
    numZones   : Integer ;
    markerShp  : TGIS_Shape ;

    procedure doLinkCostEvent(      _sender  : TObject ;
                                    _shape   : TGIS_ShapeArc ;
                                var _cost    : Double ;
                                var _revcost : Double
                             ) ;
    procedure doLinkType     (      _sender  : TObject ;
                                    _shape   : TGIS_ShapeArc ;
                                var _type    : Integer
                             ) ;
    procedure doLinkDynamic  (      _sender  : TObject ;
                                    _uid     : Integer ;
                                var _cost    : Double ;
                                var _revcost : Double
                             ) ;
    procedure generateIsochrone ;

    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisCsSystems ;

{$R *.DFM}

{
  Assigns a network link type based on the MTFCC road-class attribute.
  Links with MTFCC >= 'S1400' are classified as local roads (type 1);
  all others (primary/secondary highways) are classified as type 0.
  The type index is used to look up the corresponding CostModifier.
}
// simple LinkTypeEvent handler which uses a shape attribute to set link type
// used during network creation process
procedure TForm1.doLinkType(
     _sender   : TObject ;
     _shape    : TGIS_ShapeArc ;
 var _type     : Integer
) ;
begin
  if _shape.GetField( 'MTFCC' ) >= 'S1400' then
    // local roads
    _type := 1
  else
    _type := 0 ;
end ;

{
  Computes the base traversal cost for a road arc.
  Uses LengthCS (real-world metres) when a coordinate system is known,
  or raw geometry Length when the layer has no CS.
  Both forward and reverse costs are set identically (undirected network).
}
// simple LinkCostEvent handler which uses a shape length as the network cost
// used during network creation process
procedure TForm1.doLinkCostEvent(
      _sender   : TObject ;
      _shape    : TGIS_ShapeArc ;
  var _cost     : Double ;
  var _revcost  : Double
) ;
begin
  if _shape.Layer.CS is TGIS_CSUnknownCoordinateSystem then
    _cost := _shape.Length
  else
    _cost := _shape.LengthCS ;

  _revcost := _cost ;
end ;

{
  Dynamically blocks highway arcs at traversal time when the Highways
  track-bar is set to its minimum value (position = 1).
  Setting cost and revcost to -1 marks the link as impassable, effectively
  restricting the isochrone to local roads only.
}
// simple LinkDynamicEvent handler which uses Highways preference to block links
// used during isochrone map creation upon traveling network
procedure TForm1.doLinkDynamic(
      _sender  : TObject ;
      _uid     : Integer ;
  var _cost    : Double ;
  var _revcost : Double
) ;
var
  shp : TGIS_Shape ;
begin
  if trkHighways.Position = 1 then begin
    // block all highways
    shp := layerSrc.GetShape( _uid ) ;
    if shp.GetField( 'MTFCC' ) < 'S1400' then begin
      _cost    := -1 ;
      _revcost := -1 ;
    end ;
  end ;
end ;

{
  Initialises the map viewer, loads the road network, configures rendering
  parameters, creates the isochrone result layer and the origin marker layer,
  and wires up the TGIS_ShortestPath cost callbacks.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock ;
  try
    GIS.Open(
      TGIS_Utils.GisSamplesDataDirDownload +
      'World\Countries\USA\States\California\San Bernardino\TIGER\tl_2008_06071_edges_trunc.SHP'
    ) ;
    layerSrc := TGIS_LayerVector( GIS.Get( 'tl_2008_06071_edges_trunc' ) ) ;

    if not Assigned( layerSrc ) then exit ;
    if not ( layerSrc is TGIS_LayerVector ) then exit ;

    // update the layer parameters to show roads types
    layerSrc.ParamsList.Add ;
    layerSrc.Params.Line.Width := -2 ;
    layerSrc.Params.Query := 'MTFCC<''S1400''' ;
    layerSrc.ParamsList.Add ;
    layerSrc.Params.Line.Width := 1 ;
    layerSrc.Params.Line.Style := TGIS_PenStyle.Dash ;
    layerSrc.Params.Query := 'MTFCC=''S1400''' ;

    GIS.VisibleExtent := layerSrc.Extent ;
    GIS_ControlScale1.Units := CSUnitsList.ByEPSG( 9035 ) ; // mile

    // initial traversing cost
    costFactor := 5000.0 ;
    numZones   := 5 ;

    // create route layer for result isochrone map
    layerRoute := TGIS_LayerVector.Create ;
    layerRoute.UseConfig := False ;
    layerRoute.Name := 'Isochrone map for route' ;
    layerRoute.CS := GIS.CS ;
    layerRoute.Params.Render.Expression := 'GIS_COST' ;
    layerRoute.Params.Render.MinVal     := 0 ;
    layerRoute.Params.Render.MaxVal     := costFactor ;
    layerRoute.Params.Render.Zones      := numZones ;
    layerRoute.Params.Area.Color        := TGIS_Color.RenderColor ;
    layerRoute.Params.Area.ShowLegend   := True ;
    layerRoute.Transparency := 50 ;
    GIS.Add( layerRoute ) ;

    // create marker layer to show position
    layerMarker := TGIS_LayerVector.Create ;
    layerMarker.UseConfig := False ;
    layerMarker.Name := 'Current Position' ;
    layerMarker.CS := GIS.CS ;
    layerMarker.Params.Marker.Color := TGIS_Color.Red ;
    GIS.Add( layerMarker ) ;

    markerShp := nil ;

    // initialize isochrone map generator
    rtrObj := TGIS_IsochroneMap.Create( GIS ) ;

    // initialize shortest path and attach events
    srtpObj := TGIS_ShortestPath.Create( GIS ) ;
    srtpObj.LinkCostEvent    := doLinkCostEvent ;
    srtpObj.LinkTypeEvent    := doLinkType ;
    srtpObj.LinkDynamicEvent := doLinkDynamic ;
  finally
    GIS.Unlock ;
  end;
end;

{ Resets the visible extent to show all loaded layers. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ Doubles the current zoom level. }
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ Halves the current zoom level. }
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

{ Frees the routing and shortest-path objects on form destruction. }
procedure TForm1.FormDestroy(Sender: TObject);
begin
  srtpObj.Free;
  rtrObj.Free;
end;

{
  Handles a mouse-down event on the map.
  Converts the screen coordinates to map coordinates, places or moves the
  origin marker at the clicked location, then triggers isochrone generation.
  Exits immediately when the viewer is empty or not in Select mode.
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
begin
   // if there is no layer or we are not in select mode, exit
  if GIS.IsEmpty then exit;
  if (GIS.Mode <> TGIS_ViewerMode.Select) then exit ;

  ptg := GIS.ScreenToMap( Point(X, Y) ) ;

  // recreate a marker shape indicating start position
  if not assigned( markerShp ) then begin
    markerShp := layerMarker.CreateShape( TGIS_ShapeType.Point ) ;
    markerShp.Lock( TGIS_Lock.Extent );
    markerShp.AddPart ;
    markerShp.AddPoint( ptg ) ;
    markerShp.Unlock ;
    markerShp.Invalidate ;
  end
  else
    markerShp.SetPosition( ptg, nil, 0 ) ;

  generateIsochrone ;
end;

{
  Generates the isochrone map from the current origin marker.
  Reads the maximum cost and zone count from the UI controls, updates the
  render range on the result layer, applies road-class cost modifiers from
  the track-bars, and calls TGIS_IsochroneMap.Generate once for each zone,
  stepping from the largest cost down to costFactor/numZones.
  After generation each polygon is smoothed for a cleaner visual result.
}
procedure TForm1.generateIsochrone ;
var
  i   : Integer ;
  shp : TGIS_Shape ;
begin
  if not assigned( markerShp ) then begin
    ShowMessage( 'Please select a start point on the map' ) ;
    exit ;
  end ;

  layerRoute.RevertShapes ;

  // maximum traversing cost for the isochrone map
  numZones   := StrToInt( edtZones.Text ) ;
  costFactor := StrToInt( edtDistance.Text ) ;

  // update the renderer range
  layerRoute.Params.Render.MaxVal     := costFactor ;
  layerRoute.Params.Render.Zones      := numZones ;

  // calculate wages
  srtpObj.CostModifiers[0] := 1 - 1/11 * trkHighways.Position ;
  srtpObj.CostModifiers[1] := 1 - 1/11 * trkSmallRoads.Position ;

  // generate the isochrone maps
  for i := 1 to numZones do
    rtrObj.Generate( layerSrc, srtpObj, layerRoute, TGIS_ShapeType.Polygon,
                     markerShp.Centroid, costFactor/i, 0
                    ) ;

  // smooth the result polygons shapes
  for shp in layerRoute.Loop do
    shp.Smooth( 10, False ) ;

  layerRoute.RecalcExtent ;
  GIS.Lock ;
  GIS.VisibleExtent := layerRoute.ProjectedExtent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;
end;

end.
