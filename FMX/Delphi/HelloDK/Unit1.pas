// HelloDK - TatukGIS Developer Kernel (DK11) introductory sample (FireMonkey / FMX).
//
// Demonstrates the core DK workflow on the cross-platform FMX framework:
//   1. Opening a vector Shapefile into the map viewer (platform-conditional paths).
//   2. Switching the viewer interaction mode: Zoom / Drag / Select.
//   3. Creating an in-memory editable vector layer with a transparent polygon style.
//   4. Building a polygon shape programmatically by adding explicit vertices.
//   5. Click-to-select a feature using screen-to-map coordinate conversion
//      and spatial proximity search (GIS.Locate).
//   6. Spatial containment query using the DE-9IM matrix string "T*****FF*"
//      combined with a SQL WHERE filter to find world features whose label
//      starts with 's' and that are geometrically contained within the
//      user-created polygon.
//
// Unlike the VCL version, mouse coordinates in FMX are Single (floating-point)
// rather than Integer, and data paths differ per target platform.

unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.GisViewerWnd,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Controls.Presentation,

  //GisLicense,
  GisUtils,
  GisTypes,
  GisTypesUI,
  GisViewer,
  GisLayerVector;

type
  TForm3 = class(TForm)
    ToolBar1: TToolBar;
    // "Open project" button - loads the sample world shapefile
    btnOpen: TSpeedButton;
    // "Zooming" button - enables rubber-band zoom interaction
    btnZoom: TSpeedButton;
    // "Dragging" button - enables pan/drag interaction
    btnDrag: TSpeedButton;
    // "Selecting" button - enables click-to-select interaction
    btnSelect: TSpeedButton;
    // "Create Shape" button - adds an editable layer with a sample polygon
    btnCreate: TSpeedButton;
    // "Find Shape" button - runs DE-9IM spatial containment query
    btnFind: TSpeedButton;
    // The central GIS map viewer control (FMX variant)
    GIS: TGIS_ViewerWnd;
    procedure btnOpenClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    // TapSimple event - FMX uses Single (float) for X/Y instead of Integer
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}

// "Open project" button click event.
// Opens the WorldDCW world Shapefile. The data path is conditional on the
// target platform: Windows uses the DK sample data directory helper,
// macOS uses a relative bundle path, iOS and Android use the device's
// Documents folder or the DK download helper.
procedure TForm3.btnOpenClick(Sender: TObject);
var
  path: String;
begin
{$IF Defined(WIN32) or Defined(WIN64)}
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\world.shp');
{$ELSEIF Defined(MACOS) and not Defined(IOS) }
  str := TDirectory.GetParent(TDirectory.GetParent(ParamStr(0)));
  GIS.Open(str + '/Data/world.shp');
{$ELSEIF Defined(MACOS) and Defined(IOS)}
  // On iOS the app bundle is sandboxed; data must be placed in Documents
  GIS.Open(System.IOUtils.TPath.GetDocumentsPath + PathDelim + 'world.shp');
{$ELSE ANDROID}
  path := tgis_uTILS.GisSamplesDataDirDownload;
  GIS.Open(path + '/World/WorldDCW/world.shp');
{$ENDIF}
end;

// "Selecting" button click event.
// Switches the viewer to Select mode. In this mode, mouse clicks on the map
// are handled by GISTapSimpleEvent to toggle shape selection.
procedure TForm3.btnSelectClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select;
end;

// "Zooming" button click event.
// Switches the viewer to Zoom mode. In this mode the left mouse button
// draws a rubber-band rectangle to zoom into a region; the right button
// zooms out.
procedure TForm3.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;

// "Dragging" button click event.
// Switches the viewer to Drag mode, allowing the user to pan the map
// by clicking and dragging with the mouse.
procedure TForm3.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

// "Create Shape" button click event.
// Creates a new in-memory TGIS_LayerVector named 'edit layer', gives it a
// transparent fill with a blue outline, then adds a single quadrilateral
// polygon to it. This layer is not backed by a file.
procedure TForm3.btnCreateClick(Sender: TObject);
var
  ll: TGIS_LayerVector;
  shp: TGIS_Shape;
begin
  // Guard: if the edit layer already exists, do nothing (idempotent)
  ll := TGIS_LayerVector(GIS.Get('edit layer'));
  if ll <> nil then
    exit;

  // Create a new in-memory vector layer and register it with the viewer
  ll := TGIS_LayerVector.Create;
  ll.Name := 'edit layer';
  // Inherit the viewer's coordinate system so coordinates are interpreted correctly
  ll.CS := GIS.CS;

  // Style: transparent fill (Clear pattern) with a solid blue outline,
  // so the underlying world layer remains visible through the polygon
  ll.Params.Area.OutlineColor := TGIS_Color.Blue;
  ll.Params.Area.Pattern := TGIS_BrushStyle.Clear;

  // Register the layer with the viewer; it will appear on top of existing layers
  GIS.Add(ll);

  // Create a new Polygon shape inside the layer
  shp := ll.CreateShape(TGIS_ShapeType.Polygon);

  // Lock(Extent) batches vertex additions so the bounding box is recalculated
  // only once when Unlock is called, improving performance for bulk edits
  shp.Lock(TGIS_Lock.Extent);

  // AddPart starts the first ring of the polygon; a shape can have multiple
  // parts (e.g., islands or holes in a multi-polygon)
  shp.AddPart; // shape can have multiple parts like islands, holes

  // Add the four corner vertices of the polygon (coordinates in the map's CS)
  shp.AddPoint(TGIS_Utils.GisPoint(10, 10));
  shp.AddPoint(TGIS_Utils.GisPoint(10, 80));
  shp.AddPoint(TGIS_Utils.GisPoint(80, 90));
  shp.AddPoint(TGIS_Utils.GisPoint(90, 10));

  // Unlock finalises the shape geometry: recalculates extents and closes
  // the polygon ring automatically if the first and last points differ
  shp.Unlock; // unlock operation, close shape if necessary

  // Redraw the entire map canvas to show the newly added polygon
  GIS.InvalidateWholeMap;
end;

// "Find Shape" button click event.
// Uses DE-9IM (Dimensionally Extended 9-Intersection Model) spatial
// relationship to find all world features that are fully contained inside
// the polygon created by btnCreateClick.
//
// The DE-9IM matrix "T*****FF*" encodes the "contains" relationship:
//   - 'T' at position [0]: interiors must intersect (non-empty)
//   - "FF" at positions [6,7]: the query shape's boundary and exterior
//     must NOT intersect the target shape's interior - i.e. the target
//     lies entirely within the query polygon.
//
// An additional SQL LIKE filter restricts results to features whose
// 'label' field starts with the letter 's'.
procedure TForm3.btnFindClick(Sender: TObject);
var
  ll: TGIS_LayerVector;
  selshp: TGIS_Shape;
  lv: TGIS_LayerVector;
  tmpshp: TGIS_Shape;
begin
  // The edit layer must exist (created by btnCreateClick) to provide
  // the selection polygon; exit early if it has not been created yet
  ll := TGIS_LayerVector(GIS.Get('edit layer'));
  if ll = nil then
    exit;

  // Retrieve the world layer - its name is derived from the filename ('world')
  lv := TGIS_LayerVector(GIS.Get('world'));

  // Clear any previous selection on the world layer before applying the new one
  lv.DeselectAll;

  // Retrieve the first (and only) shape from the edit layer to use as
  // the spatial query boundary
  selshp := ll.GetShape(1); // just a first shape form the layer

  // MakeEditable pins the shape into memory so it survives the subsequent
  // iteration; file-backed shapes are otherwise evicted from cache
  selshp := selshp.MakeEditable;

  // Lock the viewer to batch all selection redraws into a single repaint
  GIS.Lock;

  // Loop over all shapes in the world layer whose bounding box overlaps
  // selshp.Extent, whose 'label' field matches the SQL pattern 's%', AND
  // whose DE-9IM relationship with selshp satisfies "T*****FF*" (Contains)
  for tmpshp in lv.Loop(selshp.Extent, 'label LIKE ''s%''', selshp,
    'T*****FF*') do
  begin
    tmpshp.IsSelected := True;
  end;

  // Unlock releases the batched repaint and triggers a single screen refresh
  GIS.Unlock;

  // Force a full map redraw to show the newly selected shapes highlighted
  GIS.InvalidateWholeMap;
end;

// TapSimple event handler - fired on every single mouse click on the viewer.
// When the viewer is in Select mode, this converts the click position from
// screen pixels to map coordinates, finds the nearest shape within a
// tolerance of 5 pixels, and toggles its selection state.
//
// Note: FMX passes X/Y as Single (float), unlike the VCL version which uses Integer.
//
// Parameters:
//   X, Y  - screen pixel coordinates of the mouse click (floating-point in FMX)
procedure TForm3.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  shp: TGIS_Shape;
  ptg: TGIS_Point;
  precision: Double;
  lv: TGIS_LayerVector;
begin
  // Ignore taps when the viewer is not in Select mode
  if GIS.Mode <> TGIS_ViewerMode.Select then
    exit;

  // Get the world layer to manage its selection state
  lv := TGIS_LayerVector(GIS.Get('world'));

  // Clear any previously selected shapes before applying the new selection
  lv.DeselectAll;

  // Convert screen pixel coordinates to geographic map coordinates.
  // Round converts Single to Integer for the TPoint constructor.
  // ScreenToMap accounts for the current zoom level and pan offset.
  ptg := GIS.ScreenToMap(Point(Round(X), Round(Y)));

  // Compute the hit-test tolerance: 5 screen pixels expressed in map units.
  // Dividing by Zoom converts pixels to the map's coordinate unit.
  precision := 5 / GIS.Zoom;

  // Search all layers for the topmost shape within 'precision' of the click point
  shp := TGIS_Shape(GIS.Locate(ptg, precision));

  // If no shape was found near the click point, do nothing
  if shp = nil then
    exit;

  // Toggle selection: clicking a selected shape deselects it, and vice versa
  shp.IsSelected := not shp.IsSelected;

  // Repaint the map to reflect the updated selection highlight
  GIS.InvalidateWholeMap;
end;

end.
