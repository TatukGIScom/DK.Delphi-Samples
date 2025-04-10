//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to perform Isochrone Map.
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

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  srtpObj.Free;
  rtrObj.Free;
end;

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
