//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  WKT Sample — Demonstrates parsing and visualization of Well-Known Text (WKT)
  geometry representations using TGIS_Utils.GisCreateShapeFromWKT.

  Key concepts illustrated:
    - Well-Known Text (WKT): ISO SQL/MM standard text format for geometry
    - Geometry types supported:
      * Point: single location (x, y)
      * MultiPoint: set of points
      * LineString: sequence of connected points forming a line
      * MultiLineString: collection of linestrings
      * Polygon: closed ring(s) with optional holes (interior rings)
      * GeometryCollection: mixed geometry types
      * 3D variants (PointZ, LineStringZ, etc.) with z-coordinate elevation
    - Real-time WKT parsing with live visualization
    - Visual feedback for valid/invalid WKT (black/red text)
    - Interactive geometry type selector

  User workflow:
    1. Select geometry type from dropdown (10 types including 2D and 3D variants)
    2. Edit WKT in the text memo
    3. Geometry displays in real-time as you type
    4. Red text indicates parsing error
    5. Black text confirms valid WKT

  Sample WKT examples:
    - POINT (30 30)
    - POLYGON ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))
      (outer ring with hole/interior ring)
    - POINTZ (30 30 100) - 3D point with elevation
    - GEOMETRYCOLLECTION (POINT (30 30), LINESTRING (3 3, 10 10))
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,

  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisTopology,
  GisTypesUI,
  GisUtils,
  GisViewer,
  Vcl.GisViewerWnd ;

type
  { Main form for the WKT sample application.
    Demonstrates parsing and visualizing Well-Known Text geometry representations.
    Features live WKT parsing with visual feedback and geometry type selection. }
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;                      { Map viewer displaying parsed WKT geometries }
    StatusBar1: TStatusBar;                   { Status bar for messages }
    Memo1: TMemo;                             { Text area for editing WKT strings }
    ToolBar1: TToolBar;                       { Toolbar area }
    cbType: TComboBox;                        { Dropdown to select geometry type (10 options) }
    procedure FormCreate(Sender: TObject);
    procedure btnParseClick(Sender: TObject); { Parse button: manually parse WKT }
    procedure Memo1Change(Sender: TObject);   { Real-time parsing as WKT is edited }
    procedure cbTypeChange(Sender: TObject);  { Load sample WKT for selected geometry type }
  private
    { Private declarations }
    layerObj : TGIS_LayerVector ;             { In-memory layer holding parsed geometries }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the WKT sample: creates an in-memory vector layer for displaying
  parsed geometries, loads a sample polygon WKT, and triggers parsing.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  { Create an in-memory vector layer that will hold all parsed geometries }
  layerObj := TGIS_LayerVector.Create ;
  layerObj.Name := 'output' ;
  { Set fill color to red for all parsed geometries }
  layerObj.Params.Area.Color := TGIS_Color.Red ;

  { Add the layer to the viewer so geometries are displayed }
  GIS.Add( layerObj ) ;
  GIS.FullExtent ;

  { Load a sample polygon WKT string in the memo for the user to examine.
    This polygon has an exterior ring and one hole (interior ring). }
  Memo1.Text :='POLYGON( ( 5 5, 25 5, 25 25, 5 25, 5 5 ), ( 10 10, 10 20, 20 20, 20 10, 10 10 ) )' ;

  { Select the polygon type in the dropdown (index 4) }
  cbType.ItemIndex := 4 ;

  { Parse and display the WKT }
  btnParseClick(Self) ;
end;


{
  btnParseClick
  Manually parses the WKT string in the memo and displays the resulting geometry.
  Called when user clicks the Parse button or changes geometry type.
}
procedure TForm1.btnParseClick(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  try
    { Clear any previously parsed geometry from the layer }
    layerObj.RevertShapes ;

    { Parse the WKT text into a TGIS_Shape object.
      GisCreateShapeFromWKT is the main WKT parsing function.
      It supports all ISO SQL/MM geometry types including 3D variants. }
    shp := TGIS_Utils.GisCreateShapeFromWKT( Memo1.Text ) ;

    { Add the parsed shape to the layer for visualization }
    layerObj.AddShape( shp ) ;
    shp.Free ;
  except
    { If WKT parsing fails, show an error message }
    ShowMessage( 'Bad format' ) ;
  end ;

  { Recalculate the layer and viewer extents to fit the new geometry }
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{
  Memo1Change
  Called on every keystroke as the user edits the WKT text.
  Provides real-time parsing and visual feedback (black=valid, red=invalid).
}
procedure TForm1.Memo1Change(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  try
    { Clear previous geometry }
    layerObj.RevertShapes ;

    { Attempt to parse the current WKT text }
    shp := TGIS_Utils.GisCreateShapeFromWKT( Memo1.Text ) ;

    { If parsing succeeded, add the shape to the layer }
    if Assigned( shp ) then
    begin
      layerObj.AddShape( shp ) ;
      shp.Free ;
    end
    else
      Abort ;

    { Set text color to black to indicate valid WKT }
    Memo1.Font.Color := clBlack ;
  except
    { If parsing failed, set text color to red as visual feedback }
    Memo1.Font.Color := clRed ;
  end ;

  { Update viewport to show the parsed geometry }
  layerObj.RecalcExtent ;
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{
  cbTypeChange
  Called when the user selects a different geometry type from the dropdown.
  Loads a sample WKT string for the selected type and parses it.

  10 geometry types are available:
    0-4: 2D geometries (Point, MultiPoint, LineString, MultiLineString, Polygon)
    5-9: 3D geometries (PointZ, MultiPointZ, LineStringZ, MultiLineStringZ, PolygonZ)
    10: Geometry Collection (mixed types)
}
procedure TForm1.cbTypeChange(Sender: TObject);
begin
  { Load sample WKT based on selected geometry type }
  case cbType.ItemIndex of
     0 : Memo1.Text :='POINT (30 30)';
         { Single point at (30, 30) }

     1 : Memo1.Text :='MULTIPOINT (4 4, 5 5, 6 6 ,7 7)';
         { Multiple separate points }

     2 : Memo1.Text :='LINESTRING (3 3, 10 10)';
         { Line connecting two points }

     3 : Memo1.Text :='MULTILINESTRING ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))';
         { Multiple separate line segments }

     4 : Memo1.Text :='POLYGON ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))';
         { Closed polygon with exterior ring and one hole (interior ring) }

     5 : Memo1.Text :='POINTZ (30 30 100)';
         { 3D point with elevation (z-coordinate = 100) }

     6 : Memo1.Text :='MULTIPOINTZ (4 4 100, 5 5 100, 6 6 100, 7 7 100)';
         { Multiple 3D points at same elevation }

     7 : Memo1.Text :='LINESTRINGZ (3 3 100, 10 10 100)';
         { 3D line segment }

     8 : Memo1.Text :='MULTILINESTRINGZ ((5 5 100, 25 5 100, 25 25 100, 5 25 100, 5 5 100), (10 10 100, 10 20 100, 20 20 100, 20 10 100, 10 10 100))';
         { Multiple 3D line segments }

     9 : Memo1.Text :='POLYGONZ ((5 5 100, 25 5 100, 25 25 100, 5 25 100, 5 5 100), (10 10 100, 10 20 100, 20 20 100, 20 10 100, 10 10 100))';
         { 3D polygon with hole }

     10 : Memo1.Text :='GEOMETRYCOLLECTION (POINT (30 30), LINESTRING (3 3, 10 10) )';
          { Mixed geometry types: point and linestring in one collection }
  end;

  { Parse and display the loaded WKT sample }
  btnParseClick(Self)
end;

end.
