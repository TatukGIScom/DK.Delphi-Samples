//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Relate Sample — Demonstrates computing spatial relations between two shapes using
  TGIS_Shape.Relate and DE-9IM (Dimensionally Extended 9-Intersection Model) predicates.

  Key concepts illustrated:
    - Loading a shapefile with sample polygon geometries
    - Shape selection via mouse click with visual feedback (blue=Shape A, red=Shape B)
    - Computing 14 different spatial relationships (equality, disjoint, intersect, touch, etc.)
    - Understanding DE-9IM matrix relationships for topology analysis
    - Using the RELATE_* constants to check geometric relationships
    - Displaying all matching relationships for a pair of shapes

  Data: Samples\Topology\topology2.shp (two overlapping polygons)

  User workflow:
    1. Left-click a polygon to select Shape A (shown in blue)
    2. Right-click another polygon to select Shape B (shown in red)
    3. Click "Check Relations" to compute and display all spatial relationships
}
unit UMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.Classes,
  System.Types,
  System.SysUtils,
  System.Variants,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ToolWin,
  Vcl.ImgList,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Buttons,
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
    Panel1: TPanel;
    GIS: TGIS_ViewerWnd;                  // Main map viewer control
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    btnCheck: TSpeedButton;               // Computes and displays spatial relations
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ShapeA: TLabel;                       // Shows "Selected" or "UnSelected" for Shape A
    ShapeB: TLabel;                       // Shows "Selected" or "UnSelected" for Shape B
    Relations: TMemo;                     // Displays all matching DE-9IM predicates
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCheckClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    shpA : TGIS_Shape ;                   // Reference to Shape A (left-click selection)
    shpB : TGIS_Shape ;                   // Reference to Shape B (right-click selection)
    currshape : TGIS_Shape ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the map viewer and loads the topology sample shapefile containing
  two overlapping polygons. Sets visual parameters for shape selection feedback.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  { Load the topology2 shapefile which contains two overlapping polygon geometries
    for demonstrating spatial relationships. }
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology2.shp');

  { Configure visual parameters for the loaded layer }
  with TGIS_LayerVector( GIS.Items[0] ) do
  begin
    { Add the parameter style list to support visual state changes }
    ParamsList.Add ;
    { Use the 'selected' style which provides visual feedback when shapes are selected }
    Params.Style := 'selected' ;
    { Set outline width to 1 pixel for clear shape boundaries }
    Params.Area.OutlineWidth := 1 ;
  end ;
end;

{
  GISMouseDown
  Handles mouse clicks on the map to select shapes for spatial relationship analysis.

  Behavior:
    - Left-click: Selects Shape A (rendered in blue)
    - Right-click: Selects Shape B (rendered in red)

  Each selection:
    1. Deselects any previously selected shape
    2. Makes the clicked shape editable for geometry access
    3. Highlights it with color and label
    4. Updates the UI status labels
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  { Guard against empty viewer or painting operations }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Convert screen pixel coordinates (X,Y) to map geographic coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Locate the topmost shape at the map coordinate with 5-pixel screen tolerance.
    This tolerance makes small shapes easier to select on screen. }
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ;

  { Exit if no shape was found at the clicked location }
  if not Assigned( shp ) then exit;

  { Create an editable copy of the shape so we can access and modify its geometry
    without affecting the underlying file-backed layer }
  shp := shp.MakeEditable ;

  { Handle left-click: select Shape A (shown in blue) }
  if Button=mbLeft then
  begin
    { Deselect any previously selected Shape A by resetting its color to gray
      and clearing its label }
    if Assigned( shpA ) then
    begin
      shpA.Params.Area.color := TGIS_Color.Gray;
      shpA.Params.Labels.Value:='';
      shpA.Invalidate ;
      ShapeA.Caption := 'UnSelected';
    end ;

    { Set the newly clicked shape as Shape A and highlight it }
    shpA :=shp;
    shpA.Params.Area.color := TGIS_Color.Blue;         // Blue indicates Shape A
    shpA.Params.Labels.Value:='Shape A';
    shpA.Params.Labels.Position := [TGIS_LabelPosition.UpLeft] ;
    shpA.Invalidate ;                                   // Trigger redraw
    ShapeA.Caption := 'Selected';
  end ;

  { Handle right-click: select Shape B (shown in red) }
  if (Button=mbRight)then
  begin
    { Deselect any previously selected Shape B }
    if Assigned( shpB ) then
    begin
      shpB.Params.Area.color := TGIS_Color.Gray;
      shpB.Params.Labels.Value:='';
      shpB.Invalidate ;
      ShapeB.Caption := 'UnSelected';
    end ;

    { Set the newly clicked shape as Shape B and highlight it }
    shpB :=shp;
    shpB.Params.Area.color := TGIS_Color.Red;          // Red indicates Shape B
    shpB.Params.Labels.Value:='Shape B';
    shpB.Params.Labels.Position := [TGIS_LabelPosition.UpLeft] ;
    shpB.Invalidate ;                                   // Trigger redraw
    ShapeB.Caption := 'Selected';
  end
end;

{
  btnCheckClick
  Computes all spatial relationships between Shape A and Shape B using the
  RELATE_* DE-9IM predicates and displays the results.

  The following 14 relationships are tested:
    EQUALITY        - Shapes have identical boundaries and interiors
    DISJOINT        - Shapes don't share any space
    INTERSECT       - Shapes share some space (any overlap)
    INTERSECT1/2/3  - Various specific intersection configurations
    WITHIN          - Shape A is completely contained inside Shape B
    CROSS           - Shapes cross each other
    CROSS_LINE      - Polyline crosses another geometry
    TOUCH           - Shapes share a boundary point but no interior space
    TOUCH_INTERIOR  - Boundary of one touches interior of other
    CONTAINS        - Shape A completely contains Shape B
    OVERLAP         - Shapes overlap (both contain parts of each other)
    OVERLAP_LINE    - Polylines overlap
}
procedure TForm1.btnCheckClick(Sender: TObject);
begin
  { Clear previous results }
  Relations.Lines.Clear;

  { Guard: cannot compute relationships without both shapes selected }
  if (not Assigned (shpA)) or (not Assigned(shpB)) then exit;

  { Test all DE-9IM spatial relationships and display those that are true.
    TGIS_Shape.Relate compares two geometries using the DE-9IM matrix model. }

  { Test equality: shapes have identical geometry }
  if shpA.Relate(shpB,RELATE_EQUALITY)       then Relations.Lines.Add('EQUALITY');

  { Test disjoint: shapes do not share any space }
  if shpA.Relate(shpB,RELATE_DISJOINT)       then Relations.Lines.Add('DISJOINT');

  { Test intersection: shapes share any space at all }
  if shpA.Relate(shpB,RELATE_INTERSECT)      then Relations.Lines.Add('INTERSECT');

  { Test specific intersection patterns }
  if shpA.Relate(shpB,RELATE_INTERSECT1)     then Relations.Lines.Add('INTERSECT1');
  if shpA.Relate(shpB,RELATE_INTERSECT2)     then Relations.Lines.Add('INTERSECT2');
  if shpA.Relate(shpB,RELATE_INTERSECT3)     then Relations.Lines.Add('INTERSECT3');

  { Test containment: Shape A is completely within Shape B }
  if shpA.Relate(shpB,RELATE_WITHIN)         then Relations.Lines.Add('WITHIN');

  { Test crossing: geometries cross each other }
  if shpA.Relate(shpB,RELATE_CROSS)          then Relations.Lines.Add('CROSS');
  if shpA.Relate(shpB,RELATE_CROSS_LINE)     then Relations.Lines.Add('CROSS_LINE');

  { Test touching: geometries share a boundary but no interior space }
  if shpA.Relate(shpB,RELATE_TOUCH)          then Relations.Lines.Add('TOUCH');
  if shpA.Relate(shpB,RELATE_TOUCH_INTERIOR) then Relations.Lines.Add('TOUCH_INTERIOR');

  { Test containment: Shape A completely contains Shape B }
  if shpA.Relate(shpB,RELATE_CONTAINS)       then Relations.Lines.Add('CONTAINS');

  { Test overlapping: both shapes contain parts of each other }
  if shpA.Relate(shpB,RELATE_OVERLAP)        then Relations.Lines.Add('OVERLAP');
  if shpA.Relate(shpB,RELATE_OVERLAP_LINE)   then Relations.Lines.Add('OVERLAP_LINE');
end;

end.
