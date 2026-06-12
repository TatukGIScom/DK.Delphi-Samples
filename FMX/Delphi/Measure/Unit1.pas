//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Measure Sample - TatukGIS DK FMX/Delphi

  Demonstrates how to interactively measure distance (line length) and area
  (polygon area) on a map using the built-in shape editor on the
  FireMonkey cross-platform framework (Windows, macOS, iOS, Android).

  Key concepts shown:
  - Creating an in-memory TGIS_LayerVector to hold the temporary measurement
    shape rendered on top of the background map.
  - Using TGIS_ViewerWnd.Editor to create and track Arc (polyline) and Polygon
    shapes in real time.
  - Responding to GISTapSimpleEvent (the FMX touch/click event) instead of
    MouseDown to support both desktop and mobile input.
  - Responding to EditorChangeEvent to recompute measurements after every
    vertex the user places.
  - Using TGIS_CSUnits.AsLinear / AsAreal to format raw metre / square-metre
    values into human-readable strings with units (e.g. "12.3 km", "4.5 km²").
  - EPSG 904201 = TatukGIS metric unit set; EPSG 904202 = imperial unit set.
    Switching between them is as simple as changing the TGIS_CSUnits instance
    and refreshing the display.
  - Platform-specific data paths are handled at startup with conditional defines
    (WIN32/WIN64, MACOS, IOS, ANDROID).
  - GIS.Mode transitions: Select (awaiting first tap) -> Edit (shape being
    drawn vertex by vertex) -> Drag (idle / panning).
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,

  //GisLicense,
  GisTypes,
  GisTypesUI,
  GisAllLayers,
  GisCSBase,
  GisLayer,
  GisLayerVector,
  GisUtils,

  FMX.GisViewerWnd ;

type
  TForm1 = class(TForm)
    GIS             : TGIS_ViewerWnd  ; // The main map viewer control
    edtArea         : TEdit           ; // Read-only display of the measured area
    edtLength       : TEdit           ; // Read-only display of the measured length / perimeter
    ToolBar1        : TToolBar        ; // Toolbar hosting the mode buttons
    btnMeasureLine  : TSpeedButton    ; // Activates polyline distance measurement mode
    btnMeasurePol   : TSpeedButton    ; // Activates polygon area measurement mode
    Panel1          : TPanel          ; // Panel housing the result display fields
    lblLength       : TLabel          ; // "Length:" label
    lblArea         : TLabel          ; // "Area:" label
    btnClear        : TSpeedButton    ; // Clears the current measurement shape
    btnMetrical     : TButton         ; // Switches output to metric units (km, km²)
    btnImperial     : TButton         ; // Switches output to imperial units (mi, mi²)
    procedure FormCreate(Sender: TObject);
    procedure btnMeasureLineClick(Sender: TObject);
    procedure btnMeasurePolClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure GISEditorChangeEvent(Sender: TObject);
    procedure btnMetricalClick(Sender: TObject);
    procedure btnImperialClick(Sender: TObject);
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    layer     : TGIS_LayerVector ; // In-memory vector layer holding the measurement shape
    isLine    : Boolean ;          // True when measuring distance along a polyline
    isPolygon : Boolean ;          // True when measuring area of a polygon
    unitMsr   : TGIS_CSUnits ;    // Current unit formatter (metric or imperial)
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses System.IOUtils  ;

{ Clears the active measurement shape and returns the viewer to drag/pan mode. }
procedure TForm1.btnClearClick(Sender: TObject);
begin
  // Remove the shape currently being edited without committing it.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  // Return to normal pan/drag interaction mode.
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{ Prepares the viewer for polyline distance measurement.
  Switches mode to Select so the next tap starts a new Arc (polyline) shape. }
procedure TForm1.btnMeasureLineClick(Sender: TObject);
begin
  // Discard any existing measurement before starting a new one.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  // Only the perimeter/distance field will be updated; area stays empty.
  isPolygon := False ;
  isLine := True ;
  // Select mode waits for the first tap that anchors the initial vertex.
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

{ Prepares the viewer for polygon area measurement.
  Switches mode to Select so the next tap starts a new Polygon shape. }
procedure TForm1.btnMeasurePolClick(Sender: TObject);
begin
  // Discard any existing measurement before starting a new one.
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  // Both perimeter length and enclosed area will be displayed.
  isPolygon := True ;
  isLine := False ;
  // Select mode waits for the first tap that anchors the initial vertex.
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

{ Switches the unit formatter to metric (km, km²) and immediately refreshes
  the displayed measurement.  EPSG 904201 is TatukGIS's metric unit set. }
procedure TForm1.btnMetricalClick(Sender: TObject);
begin
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904201 );
  // Reuse the editor-change handler to reformat the existing measurement
  // with the newly selected units without requiring new user input.
  GISEditorChangeEvent(Self);
end;

{ Switches the unit formatter to imperial (miles, square miles) and immediately
  refreshes the displayed measurement.  EPSG 904202 is TatukGIS's imperial set. }
procedure TForm1.btnImperialClick(Sender: TObject);
begin
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904202 );
  GISEditorChangeEvent(Self);
end;

{ Initialises the viewer, loads the background world map, and creates the
  in-memory layer that will receive the measurement shape.
  Handles platform-specific data paths for desktop and mobile targets. }
procedure TForm1.FormCreate(Sender: TObject);
var
  str : String ;
begin
  str := '' ;
  // Open the world outline shapefile.  The path resolution differs per platform:
  // Windows uses the shared samples data directory; macOS/iOS/Android use
  // platform-appropriate document paths.
  {$IF Defined(WIN32) or Defined(WIN64)}
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\world.shp' );
  {$ELSEIF Defined(MACOS) and not Defined(IOS) }
    str := TDirectory.GetParent( TDirectory.GetParent( ParamStr(0) ) ) ;
    GIS.Open( str + '/Data/world.shp' );
  {$ELSEIF Defined(MACOS) and Defined(IOS)}
    GIS.Open( TPath.GetDocumentsPath + PathDelim + 'world.shp' ) ;
  {$ELSE ANDROID}
    GIS.Open( TPath.GetDocumentsPath + PathDelim + 'world.shp' ) ;
  {$ENDIF}

  GIS.Mode := TGIS_ViewerMode.Drag;

  // Create an in-memory vector layer to hold the measurement shape.
  // No file is written; shapes exist only in memory for the duration of the session.
  layer := TGIS_LayerVector.Create ;
  layer.Params.Line.Color := TGIS_Color.Red ;  // Red for high visibility on the basemap
  layer.Params.Line.Width := 25 ;              // Thick line so the measurement is easy to see

  // Assign WGS-84 geographic CS (EPSG 4326) to the layer.
  // When the layer has a geographic CS, LengthCS and AreaCS perform geodetic
  // calculations that account for the curvature of the Earth.
  layer.SetCSByEPSG( 4326 ) ;

  if not Assigned( layer ) then
    exit ;

  GIS.Add( layer ) ;
  // Restrict scrolling to the initial full-world extent so the user cannot
  // pan into empty space outside the basemap.
  GIS.RestrictedExtent := GIS.Extent ;

  isLine := False ;
  isPolygon := False ;

  // EPSG 904201 selects the TatukGIS metric unit formatter as the default.
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904201 ) ;

  // Widen the editor's rubber-band preview line so it is visible on small screens.
  GIS.Editor.EditingLinesStyle.PenWidth := 10 ;
end;


{ Called by the editor every time a vertex is added or the cursor moves during
  shape editing.  Recomputes and displays length (and optionally area) using
  coordinate-system-aware methods that account for map projection. }
procedure TForm1.GISEditorChangeEvent(Sender: TObject);
begin
  if Assigned( GIS.Editor.CurrentShape ) then
    if isLine then
      // LengthCS returns the geodetic length in the layer's base units (metres
      // for EPSG 4326).  AsLinear formats it to a string with the unit label.
      edtLength.Text := unitMsr.asLinear( TGIS_Shape( GIS.Editor.CurrentShape ).LengthCS, True )
    else if isPolygon then
    begin
      // For a polygon, LengthCS is the perimeter.
      edtLength.Text := unitMsr.asLinear( TGIS_Shape( GIS.Editor.CurrentShape ).LengthCS, True ) ;
      // AreaCS returns the geodetic enclosed area in square metres.
      // "%s²" inserts the unit abbreviation followed by the superscript-2 character.
      edtArea.Text := unitMsr.AsAreal( TGIS_Shape( GIS.Editor.CurrentShape ).AreaCS, True, '%s²' ) ;
    end
end;

{ Handles a tap (or mouse click on desktop) on the map.
  This event uses FMX's TapSimple convention where coordinates are Single
  (floating-point screen pixels) to support high-DPI and touch screens.
  The first tap creates the shape; subsequent vertex placement is handled
  automatically by the editor in Edit mode. }
procedure TForm1.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  ptg : TGIS_Point;
begin
  // Once the editor is active (Edit mode) additional vertices are placed
  // internally; this handler must not create a second shape.
  if GIS.Mode = TGIS_ViewerMode.Edit then
    exit ;

  // Round the floating-point FMX coordinates to integers before converting
  // from screen pixels to geographic map coordinates.
  ptg := GIS.ScreenToMap( Point( Round(x), Round(y) ) ) ;

  if isLine then
  begin
    // Arc = polyline shape; LengthCS will sum all segment lengths geodetically.
    GIS.Editor.CreateShape( layer, ptg, TGIS_ShapeType.Arc ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;  // Transfer vertex control to the editor
  end
  else if isPolygon then
  begin
    // Polygon shape; both AreaCS and LengthCS (perimeter) are available.
    GIS.Editor.CreateShape( layer, ptg, TGIS_ShapeType.Polygon ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;  // Transfer vertex control to the editor
  end ;
end;

end.
