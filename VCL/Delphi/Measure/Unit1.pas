//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Measure sample — demonstrates interactive distance and area measurement on a map.

  What the sample shows:
    - Creating an in-memory TGIS_LayerVector to hold temporary measurement shapes
    - Using TGIS_ViewerWnd.Editor to create and track polyline and polygon shapes
    - Responding to EditorChangeEvent for live measurement updates
    - Using TGIS_CSUnits.AsLinear and AsAreal for human-readable output formatting
    - Polyline distance measurement with geodetic accuracy
    - Polygon area measurement with coordinate system awareness
    - Toggling between Line (distance) and Polygon (area) measurement modes
    - Real-time display of measurements as user places vertices
    - Clear button to reset and start new measurement
    - Viewer mode transitions: Select (awaiting) -> Edit (drawing) -> Drag (idle)

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_ViewerWnd.Editor       - in-place shape creation and editing
    TGIS_LayerVector            - in-memory measurement shape layer
    TGIS_Shape                  - polyline/polygon measurement geometry
    TGIS_CSUnits                - unit formatting and conversion
    EditorChangeEvent           - live measurement update trigger
    TGIS_ViewerMode             - interaction mode (Select, Edit, Drag)
    EPSG 904201                 - metric unit set for geodetic calculations
    EPSG 4326                   - WGS-84 geographic coordinate system
    LengthCS / AreaCS           - geodetically correct calculations
}

unit Unit1;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.Buttons,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisClasses,
  GisCSBase,

  Vcl.GisViewerWnd, Vcl.ExtCtrls;

type
  { Main application form for the Measure sample.
    Hosts the TatukGIS viewer and provides controls to measure line lengths
    and polygon areas directly on the map. }
  TForm1 = class(TForm)
    GIS         : TGIS_ViewerWnd  ; // The main map viewer control
    StatusBar1  : TStatusBar      ; // Bottom status bar with usage hint
    ToolBar1    : TToolBar        ; // Toolbar hosting the action buttons
    btnClear    : TButton         ; // Clears the current measurement shape
    btnPolygon  : TButton         ; // Activates polygon-area measurement mode
    btnLine     : TButton         ; // Activates polyline-distance measurement mode
    Panel1      : TPanel          ; // Panel housing the result display fields
    lblLength   : TLabel          ; // "Length:" label
    lblArea     : TLabel          ; // "Area:" label
    edtLength   : TEdit           ; // Read-only display of the measured length
    edtArea     : TEdit           ; // Read-only display of the measured area

    procedure FormCreate(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnPolygonClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure GISEditorChangeEvent(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    ll        : TGIS_LayerVector  ; // In-memory vector layer that holds the temporary measurement shape
    isLine    : Boolean           ; // True when measuring distance along a polyline
    isPolygon : Boolean           ; // True when measuring the perimeter and area of a polygon
    units     : TGIS_CSUnits      ; // Unit formatter for metric output (EPSG 904201)
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisAllLayers ;

{$R *.DFM}


{ Clears the active measurement shape and returns the viewer to drag/pan mode. }
procedure TForm1.btnClearClick(Sender: TObject);
begin
  // Remove the shape currently being edited from the editor without committing it.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  // Clear the displayed measurement values.
  edtArea.Text := '';
  edtLength.Text := '';

  // Return to normal pan/drag interaction mode.
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

{ Prepares the viewer for polyline distance measurement.
  Switches mode to Select so the next mouse click starts a new Arc shape. }
procedure TForm1.btnLineClick(Sender: TObject);
begin
  // Discard any existing measurement shape before starting a new one.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  edtArea.Text := '';
  edtLength.Text := '';

  // Set flags: only distance (perimeter) will be shown; area field stays empty.
  isPolygon := False;
  isLine := True;

  // Select mode waits for the initial mouse click that will anchor the first vertex.
  GIS.Mode := TGIS_ViewerMode.Select;
end;

{ Prepares the viewer for polygon area measurement.
  Switches mode to Select so the next mouse click starts a new Polygon shape. }
procedure TForm1.btnPolygonClick(Sender: TObject);
begin
  // Discard any existing measurement shape before starting a new one.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  edtArea.Text := '';
  edtLength.Text := '';

  // Set flags: both perimeter length and enclosed area will be displayed.
  isPolygon := True;
  isLine := False;

  // Select mode waits for the initial mouse click that will anchor the first vertex.
  GIS.Mode := TGIS_ViewerMode.Select;
end;

{ Initialises the viewer, loads the background world map, and creates the
  transparent in-memory layer that will receive the measurement shape. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Lock suspends rendering while we make multiple changes to avoid flicker.
  GIS.Lock();

  // Open a world outline shapefile as the basemap.
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\WorldDCW\world.shp');

  // Create an in-memory vector layer to hold the user-drawn measurement shape.
  // This layer has no backing file; shapes exist only at runtime.
  ll := TGIS_LayerVector.create;
  ll.Params.Line.Color := TGIS_Color.Red;  // Bright red so the measurement stands out
  ll.Params.Line.Width := 25;              // Thick line for easy visibility

  // Assign WGS-84 geographic coordinate system (EPSG 4326).
  // This is critical: LengthCS and AreaCS compute geodetic distances when the
  // layer's CS is geographic, giving true earth-surface measurements in metres.
  ll.SetCSByEPSG( 4326 );

  GIS.Add(ll);

  // Lock the pan/zoom extent to the initial full-world view so the user
  // cannot scroll outside the basemap.
  GIS.RestrictedExtent := GIS.Extent;

  GIS.Unlock();

  // EPSG 904201 is TatukGIS's internal code for the standard metric unit set
  // (metres for linear, square metres for areal), used to format output strings.
  units := TGIS_Utils.CSUnitsList.ByEPSG( 904201 );

  isLine := False;
  isPolygon := False;

  // Make the editor's rubber-band preview line thicker so it is clearly visible.
  GIS.Editor.EditingLinesStyle.PenWidth := 10;

  // AfterActivePoint mode draws a preview segment from the last committed vertex
  // to the current mouse cursor position, giving live length feedback.
  GIS.Editor.Mode := TGIS_EditorMode.AfterActivePoint;
end;


{ Called by the editor every time a vertex is added or the mouse moves while
  editing.  Recomputes and displays the current length (and area for polygons)
  using coordinate-system-aware methods that account for map projection. }
procedure TForm1.GISEditorChangeEvent(Sender: TObject);
begin
  if Assigned(GIS.Editor.CurrentShape) then
  begin
    if isLine then
    begin
      // LengthCS returns the geodetic length in metres (or projected units)
      // as a Double.  AsLinear converts it to a human-readable string with
      // the appropriate unit suffix chosen by the TGIS_CSUnits instance.
      edtLength.Text := units.AsLinear(TGIS_Shape(GIS.Editor.CurrentShape).LengthCS, True)
    end
    else if isPolygon then
    begin
      // For a polygon, LengthCS is the perimeter of the current shape.
      edtLength.Text := units.AsLinear(TGIS_Shape(GIS.Editor.CurrentShape).LengthCS, True) ;
      // AreaCS returns the geodetic area in square metres.  AsAreal formats it
      // with a superscript-2 suffix (%s² expands to the unit abbreviation + ²).
      edtArea.Text := units.AsAreal( TGIS_Shape( GIS.Editor.CurrentShape ).AreaCS, True, '%s²' ) ;
    end;
  end;

end;

{ Handles the first mouse click that begins a new measurement shape.
  Subsequent vertices are added automatically by the editor in Edit mode;
  this handler only runs once per measurement to create the initial shape. }
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
begin
  // Once the editor is active (Edit mode) all further vertices are handled
  // internally by the viewer; this event should not restart a new shape.
  if GIS.Mode = TGIS_ViewerMode.Edit then
    exit ;

  // Convert the screen pixel coordinate to geographic map coordinates.
  ptg := GIS.ScreenToMap( Point( x, y ) ) ;

  if isLine then
  begin
    // TGIS_ShapeType.Arc creates a polyline shape whose LengthCS measures
    // the sum of all segment lengths along the earth's surface.
    GIS.Editor.CreateShape( ll, ptg, TGIS_ShapeType.Arc ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;  // Hand control to the editor for subsequent vertices
  end
  else if isPolygon then
  begin
    // TGIS_ShapeType.Polygon creates a closed polygon whose AreaCS and
    // LengthCS (perimeter) are computed geodetically.
    GIS.Editor.CreateShape( ll, ptg, TGIS_ShapeType.Polygon ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;  // Hand control to the editor for subsequent vertices
  end ;
end;

end.
