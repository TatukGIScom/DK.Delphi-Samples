//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  SplitbyArc Sample — Demonstrates splitting polygon geometries using an
  interactively drawn line (arc) via TGIS_Topology.SplitByArc.

  Key concepts illustrated:
    - Interactive line drawing: clicking points to create a line geometry
    - Polygon topology: splitting a polygon using a line that intersects it
    - TGIS_Topology.SplitByArc: splits a polygon into multiple fragments
    - Result visualization: assigning random colors to split fragments
    - Intersection detection: enabling split operation only when line intersects polygon
    - Layer management: organizing original, splitting line, and result polygons

  User workflow:
    1. Click "New Line" to start drawing a line
    2. Click on the map to add vertices to the line
    3. Line appears in red as you draw
    4. When line intersects the polygon, "Split" button becomes enabled
    5. Click "Split" to divide the polygon into fragments
    6. Each fragment is displayed in a random color
    7. Count of resulting fragments shown in result label

  Data: Samples\Topology\topology3.shp (polygon for splitting)

  Three layers in the viewer:
    - Original polygon (from topology3.shp)
    - Splitting line (in-memory, red color, user-drawn)
    - Result fragments (in-memory, random colors, generated after split)
}

unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    paLeft: TPanel;
    GIS: TGIS_ViewerWnd;
    btnLine: TButton;
    btnSplit: TButton;
    gboxResult: TGroupBox;
    lbInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnSplitClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    layerObj      : TGIS_LayerVector ;    //layer for new shapes
    shpPolygon    : TGIS_ShapePolygon;    //shape for split
    shpArc        : TGIS_ShapeArc;        //shape for line
    layerPolygon  : TGIS_LayerVector ;
    layerArc      : TGIS_LayerVector ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the SplitbyArc sample:
    1. Loads the topology sample shapefile containing a polygon
    2. Creates three layers: original polygon, splitting line, results
    3. Configures line appearance (red, thick) for visibility
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock;

  { Load the topology sample shapefile (polygon for splitting) }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology3.shp' );

  { Get the first polygon from the loaded shapefile }
  layerPolygon := TGIS_LayerVector( GIS.Items[0] );
  { Make the polygon editable so we can access its geometry for splitting }
  shpPolygon := TGIS_ShapePolygon( layerPolygon.GetShape( 1 ).MakeEditable ) ;
  if not Assigned( shpPolygon ) then exit ;

  { Create an in-memory vector layer to hold the user-drawn splitting line }
  layerArc := TGIS_LayerVector.Create ;
  { Configure line appearance: red color, 25 pixel width for visibility }
  layerArc.Params.Line.Color := TGIS_Color.Red;
  layerArc.Params.Line.Width := 25;
  if not Assigned( layerArc ) then exit ;
  { Add the line layer to the viewer }
  GIS.Add( layerArc );

  { Create an arc (line) shape in the layer that the user will draw by clicking }
  shpArc := TGIS_ShapeArc(TGIS_LayerVector( GIS.Items[1] ).CreateShape( TGIS_ShapeType.Arc ));
  if not Assigned( shpArc ) then exit ;
  { Initialize the arc for adding points }
  shpArc.AddPart ;

  { Create an in-memory vector layer to hold the split result polygons }
  layerObj := TGis_LayerVector.Create;
  layerObj.Name := 'Splits' ;
  { Add the results layer to the viewer }
  GIS.Add( layerObj );
  GIS.Unlock;

  { Fit the viewport to show all layers and set restricted extent }
  GIS.FullExtent ;
  GIS.RestrictedExtent := GIS.Extent;
end;

{
  btnLineClick
  Resets the splitting line and result fragments for a new split operation.
  Called when user clicks "New Line" button.
}
procedure TForm1.btnLineClick(Sender: TObject);
begin
  { Clear any previous split result polygons from the results layer }
  layerObj.RevertShapes ;

  { Clear the splitting line and prepare for new points }
  shpArc.Reset;
  { Initialize the arc for adding new vertex points }
  shpArc.AddPart ;

  { Reset the result label to indicate waiting for input }
  lbInfo.Caption := '...';

  { Redraw the map without the previous results }
  GIS.InvalidateWholeMap;

  { Disable the Split button until a new valid line is drawn }
  btnSplit.Enabled := false;
end;

{
  btnSplitClick
  Performs the polygon split operation using TGIS_Topology.SplitByArc.
  Splits the polygon with the user-drawn line and displays all fragments.

  Algorithm:
    1. Create a TGIS_Topology engine
    2. Call SplitByArc(polygon, line, onlyCompleteSplit)
    3. Get back a list of resulting polygon fragments
    4. Assign random colors to each fragment for visualization
    5. Add all fragments to the results layer
    6. Update the result count label
}
procedure TForm1.btnSplitClick(Sender: TObject);
var
  n : Integer;
  shape_list: TGIS_ObjectList;
  topology_obj : TGIS_Topology ;
begin
  { Clear any previous split results from the results layer }
  layerObj.RevertShapes ;

  { Create the topology processing engine }
  topology_obj := TGIS_Topology.Create ;
  try
    { Execute the split operation: use the drawn line to split the polygon.
      SplitByArc returns a collection of resulting polygon fragments.
      The True parameter means only complete split (line crosses polygon completely). }
    shape_list := topology_obj.SplitByArc(shpPolygon, shpArc, True);

    { If the split succeeded (line intersected polygon), process the results }
    if Assigned( shape_list ) then
    begin
      { Display the number of resulting fragments in the result label }
      lbInfo.Caption := IntToStr( shape_list.Count ) ;

      { Assign random colors to each fragment for visual distinction }
      Randomize ;
      for n := 0 to shape_list.Count - 1 do
      begin
        { Generate a random RGB color for this fragment }
        TGIS_Shape( shape_list.Items[ n ] ).Params.Area.Color := TGIS_Color.FromRGB(Random( 255 ) * 256 * 256 + Random( 255 ) * 256 + Random( 256 )) ;
        { Add the colored fragment to the results layer for display }
        layerObj.AddShape( TGIS_Shape(shape_list.Items[ n ]) ) ;
      end;
      { Free the list of fragments (the shapes themselves are now in the layer) }
      shape_list.Free;
    end;
  finally
    topology_obj.Free ;
  end ;

  { Redraw the map to display all split fragments }
  GIS.InvalidateWholeMap ;
end;

{
  GISMouseDown
  Adds a vertex to the splitting line when user clicks on the map.
  Checks if the line intersects the polygon to enable the Split button.
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg   : TGIS_Point ;
begin
  { Guard: skip if no layers loaded }
  if GIS.IsEmpty then exit ;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Add the clicked point as a new vertex to the splitting line (arc) }
  shpArc.Lock( TGIS_Lock.Extent ) ;
  shpArc.AddPoint( ptg );
  shpArc.Unlock ;

  { Redraw the map to show the updated line }
  GIS.InvalidateWholeMap ;

  { Check if the line now intersects the polygon.
    Enable the Split button only if there's a valid intersection. }
  if shpArc.Intersect( shpPolygon ) then
    btnSplit.Enabled := true;
end;

{
  GISMouseUp
  Also adds vertices to the splitting line (handles both mouse up and down events).
  This provides responsive feedback as the user draws the line.
}
procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg   : TGIS_Point ;
begin
  { Guard: skip if no layers loaded }
  if GIS.IsEmpty then exit ;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Add the point as a new vertex to the splitting line }
  shpArc.Lock( TGIS_Lock.Extent ) ;
  shpArc.AddPoint( ptg );
  shpArc.Unlock ;

  { Redraw the map to show the line being drawn }
  GIS.InvalidateWholeMap;

  { Check if the line intersects the polygon and enable Split if valid }
  if shpArc.Intersect( shpPolygon ) then
    btnSplit.Enabled := true;
end;

end.
