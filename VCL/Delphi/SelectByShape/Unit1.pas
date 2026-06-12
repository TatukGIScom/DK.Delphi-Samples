//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  SelectByShape sample - demonstrates how to select vector features by drawing
  an arbitrary shape (circle or rectangle) interactively on the map.

  Key concepts shown:
  - Interactive rubber-band drawing of a selection shape on the GIS viewer
    using mouse events and the PaintExtraEvent hook.
  - Converting screen pixel coordinates to geographic map coordinates via
    ScreenToMap, so the drawn shape is in the layer's coordinate system.
  - Building a circular selection area using TGIS_Topology.MakeBuffer, which
    expands a point geometry outward by a given radius in map units.
  - Building a rectangular selection polygon by manually adding four corner
    points to a new polygon shape.
  - Spatial query via TGIS_LayerVector.FindFirst / FindNext using the
    RELATE_INTERSECT predicate (a DE-9IM relationship test) to find all
    features that share at least one point with the selection shape.
  - Visually highlighting matched features with IsSelected and listing their
    "name" attribute in a memo control.
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
  GisRendererAbstract,
  GISTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main application form for the SelectByShape sample.
    Hosts the TatukGIS viewer control, two mode-toggle buttons (circle /
    rectangle), and a read-only text box that lists the names of the features
    found to intersect the drawn selection shape. }
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;          // Main map viewer control
    StatusBar1: TStatusBar;        // Status bar at the bottom of the form
    Memo1: TMemo;                  // Displays names of selected features
    ToolBar1: TToolBar;            // Toolbar hosting the mode buttons
    btnRect: TSpeedButton;         // Toggle: select by rectangle
    btnCircle: TSpeedButton;       // Toggle: select by circle
    procedure FormCreate(Sender: TObject);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
  private
    { Private declarations }

    // Anchor point where the user first pressed the mouse button (screen pixels)
    oldPos1   : TPoint      ;
    // Current drag position used as the second corner of the rectangle (screen pixels)
    oldPos2   : TPoint      ;
    // Current radius of the rubber-band circle in screen pixels
    oldRadius : Integer     ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisAllLayers ;

{$R *.DFM}


{ TForm1.FormCreate
  Initialises the map with the base Counties layer and two empty in-memory
  layers that will hold the visual indicators added during selection:
    "Points"  - invisible marker shapes placed at the click/drag positions
                (size = 0 so they are not rendered, used only as geometry
                 containers for the buffer calculation)
    "Buffers" - the actual selection shape (circle polygon or rectangle)
                rendered semi-transparently over the map
  The viewer is locked during setup so that only one repaint is triggered
  when Unlock is called. }
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  GIS.Lock;
  // Open the base shapefile; Counties.shp supplies the features to select from
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload+'\World\Countries\USA\States\California\Counties.shp' );

  // "Points" layer - invisible markers that act as geometry placeholders
  // (Marker.Size = 0 hides them from the renderer)
  ll := TGIS_layerVector.Create;
  ll.Params.Area.color := TGIS_Color.Blue;
  ll.Transparency := 50;
  ll.Name := 'Points';
  // Inherit the coordinate system from the viewer so all geometry is in the
  // same spatial reference and ScreenToMap conversions are correct
  ll.CS := GIS.CS ;
  GIS.Add( ll );

  // "Buffers" layer - holds the selection shape drawn by the user
  ll := TGis_layerVector.Create;
  ll.Params.Area.color := TGIS_Color.Blue;
  ll.Params.Area.OutlineColor := TGIS_Color.Blue;
  ll.Transparency := 60;    // Semi-transparent so the map beneath shows through
  ll.Name := 'Buffers';
  ll.CS := GIS.CS ;
  GIS.Add( ll );
  GIS.Unlock;

  // Default to rectangle mode on startup
  btnRect.Down := true;
end;

{ TForm1.GISMouseDown
  Records the starting screen position when the user begins a drag operation.
  Right-click switches back to the built-in Zoom mode so the user can pan/zoom
  without leaving the custom Select mode permanently. }
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  if Button = mbRight then
  begin
    // Right-click: hand control back to the viewer's built-in zoom/pan behaviour
    GIS.Mode := TGIS_ViewerMode.Zoom;
    exit;
  end;

  // Initialise both anchor and drag-end to the same pixel so the shape starts
  // with zero size (guard against a stale oldPos2 from a previous selection)
  oldPos1   := Point( X, Y )  ;
  oldPos2   := Point( X, Y )  ;
  oldRadius := 0              ;
end;

{ TForm1.GISMouseMove
  Updates the rubber-band dimensions while the left mouse button is held down.
  For rectangle mode the second corner follows the cursor; for circle mode the
  radius is the Euclidean pixel distance from the anchor to the cursor.
  GIS.Invalidate triggers a repaint, which calls GISPaintExtraEvent so the
  rubber-band is drawn on every frame. }
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if GIS.IsEmpty then exit ;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit ;
  // Only update the rubber-band while the left button is pressed (dragging)
  if not ( ssLeft in Shift ) then exit ;

  if btnRect.Down then
     // Track the second corner of the bounding rectangle
     oldPos2 := Point( X, Y ) ;

  if btnCircle.Down then begin
    // Pythagorean distance from the anchor to the current cursor position
    oldRadius := Round(Sqrt( Sqr( oldPos1.X - X ) + Sqr( oldPos1.Y - Y ) ) );
  end;

  // Request a repaint so PaintExtraEvent draws the updated rubber-band shape
  GIS.Invalidate
end;

{ TForm1.GISMouseUp
  The main event handler: finalises the selection shape and performs the
  spatial query.

  Steps:
  1. Guard: ignore if the viewer is empty or the drag was too small.
  2. Record invisible point markers in the "Points" layer to preserve the
     geometry for the MakeBuffer call (circle) or corner calculation (rectangle).
  3. Clear the "Buffers" layer and add the new selection polygon.
     - Circle: TGIS_Topology.MakeBuffer approximates a circle as a 32-sided
       polygon around the centre point, using the pixel-to-map distance as
       the radius in map units.
     - Rectangle: four corner points are assembled in map coordinates.
  4. Call FindFirst / FindNext on layer 0 (Counties) using RELATE_INTERSECT
     to iterate over every shape that spatially intersects the selection polygon.
     RELATE_INTERSECT is a DE-9IM predicate: it returns true when the two
     geometries share at least one point (boundary or interior).
  5. Mark each hit as selected (IsSelected) and append its name to Memo1.

  Right-click releases: restores Select mode (reverses the right-click zoom
  toggle set in MouseDown). }
procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ll        : TGis_LayerVector;
  tmp       : TGis_Shape;       // Working shape variable for iteration
  buf       : TGis_Shape;       // The selection shape (circle or rectangle)
  ptg       : TGis_Point;       // Centre point (circle) or first corner (rectangle) in map coords
  ptg1      : TGis_Point;       // Edge point used to compute the circle radius in map units
  ptg2      : TGis_Point;       // Opposite corner for rectangle in map coords
  distance  : double;           // Circle radius in map units (geographic or projected)
  tpl       : TGIS_Topology;
begin
  if GIS.IsEmpty then exit ;

  buf := nil ;

  if Button = mbRight then
  begin
    // Right-click: restore Select mode (the user had switched to Zoom on MouseDown)
    GIS.mode := TGIS_ViewerMode.Select;
    exit;
  end;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit ;

  // Guard: if the drag produced no movement, ignore (avoids zero-size shapes)
  if btnRect.Down then
    if ( oldPos2.X = oldPos1.X ) and ( oldPos2.Y = oldPos1.Y ) then exit  ;
  if btnCircle.Down then
    if oldRadius  = 0 then exit;

  // --- Add invisible marker(s) to the "Points" layer ---
  // These are not rendered (Marker.Size = 0) but are needed as geometry
  // containers so MakeBuffer has a point shape to work with for circle mode,
  // and to keep geometry symmetry in rectangle mode.
  ll := TGIS_LayerVector( GIS.Get( 'Points' ) ) ;
  ll.Lock;
  tmp := ll.CreateShape(TGIS_ShapeType.Point);
  tmp.Params.Marker.Size := 0;
  // Lock with Extent so the layer's extent is automatically updated
  tmp.Lock(TGIS_Lock.Extent);
  tmp.AddPart;

  if btnCircle.Down then begin
    // Convert the anchor screen pixel to a map coordinate (centre of circle)
    ptg := Gis.ScreenToMap(oldPos1);
    ll := TGIS_LayerVector( GIS.Get( 'Points' ) ) ;
    ll.Lock;
    tmp := ll.CreateShape(TGIS_ShapeType.Point);
    tmp.Params.Marker.Size := 0;
    tmp.Lock(TGIS_Lock.Extent);
    tmp.AddPart;
    tmp.AddPoint( ptg );
    tmp.Unlock;
    ll.Unlock;
    // Convert a second screen point that is exactly oldRadius pixels to the right
    // of the centre; the difference in X map coordinates gives the radius in map units
    ptg1 := GIS.ScreenToMap( Point( oldPos1.X + oldRadius, Y ) ) ;
  end;

  if btnRect.Down then begin
    // Record the first corner of the rectangle as an invisible marker
    ptg := Gis.ScreenToMap(oldPos1);
    tmp.AddPoint( ptg );
    tmp.Unlock;
    // Record the second corner as a second invisible marker
    tmp := ll.CreateShape(TGIS_ShapeType.Point);
    tmp.Params.Marker.Size := 0;
    tmp.Lock(TGIS_Lock.Extent);
    tmp.AddPart;
    ptg := Gis.ScreenToMap(oldPos2);
    tmp.AddPoint( ptg );
    tmp.Unlock;
    ll.Unlock;
    // Re-convert the first corner to use as ptg1 for rectangle construction below
    ptg1 := Gis.ScreenToMap(oldPos1);
  end;

  // --- Rebuild the "Buffers" layer with the new selection shape ---
  ll := TGIS_LayerVector( GIS.Get('Buffers') ) ;
  // RevertShapes clears all shapes added since the last save, effectively
  // resetting the layer to empty so previous selections are discarded
  ll.RevertShapes;

  if btnCircle.Down then begin
    // The map-unit radius is the horizontal difference between the edge and centre
    distance := ptg1.X - ptg.X ;

    tpl := TGIS_Topology.Create ;
    try
      // MakeBuffer approximates a circle as a 32-vertex polygon around tmp.
      // The last parameter (True) closes the ring automatically.
      buf := tpl.MakeBuffer( tmp, distance, 32, True ) ;
      // AddShape transfers ownership of the geometry to the Buffers layer
      buf := ll.AddShape( buf ) ;
    finally
      tpl.Free ;
    end ;
  end;

  if btnRect.Down then begin
    // Build a closed rectangle polygon from the two diagonally opposite corners
    ptg2 := Gis.ScreenToMap(oldPos2);
    buf := ll.CreateShape( TGIS_ShapeType.Polygon ) ;
    buf.AddPart ;
    // Wind the four corners in order (top-left, top-right, bottom-right, bottom-left)
    buf.AddPoint( ptg1 ) ;
    buf.AddPoint( TGIS_Utils.GisPoint( ptg1.X, ptg2.Y ) ) ;
    buf.AddPoint( ptg2 ) ;
    buf.AddPoint( TGIS_Utils.GisPoint( ptg2.X, ptg1.Y ) ) ;
  end;

  // --- Perform the spatial query on the base Counties layer (Items[0]) ---
  ll := TGIS_LayerVector( GIS.Items[0] ) ;
  if not Assigned( ll ) then begin
    Gis.InvalidateWholeMap;
    exit ;
  end;

  // Clear any previously selected features before starting the new selection
  ll.DeselectAll ;

  Gis.InvalidateWholeMap ;

  Memo1.Clear ;
  Memo1.Lines.BeginUpdate ;
  GIS.Lock ;
  // check all shapes

  if not (btnRect.Down or btnCircle.Down) then begin
    MessageBox(Handle, 'Please select mode first', 'Select mode', MB_OK);
    exit;
  end;

  // FindFirst / FindNext iterate over shapes whose bounding box overlaps buf.Extent,
  // then applies the RELATE_INTERSECT DE-9IM predicate to filter out shapes that
  // only touch the extent but do not actually intersect the selection geometry.
  tmp := ll.FindFirst( buf.Extent, '', buf, RELATE_INTERSECT );
  while Assigned( tmp ) do
  begin
    // This shape intersects the selection polygon: highlight it and list its name
    Memo1.Lines.Add( tmp.GetField( 'name' ) ) ;
    tmp.IsSelected := True ;
    tmp := ll.FindNext ;
  end ;
  GIS.UnLock ;
  Memo1.Lines.EndUpdate ;
end;

{ TForm1.GISPaintExtraEvent
  Called by the viewer during each repaint pass after all layers have been
  drawn. This is where the rubber-band selection shape is rendered using the
  renderer's canvas primitives directly in screen space.

  Using PaintExtraEvent (rather than a Windows GDI overlay) ensures the
  feedback is composited correctly on top of the map without flickering and
  works regardless of whether hardware acceleration is active.

  The pen colour is randomised on each call intentionally to create an
  animated "marching ants" visual effect on the outline. }
procedure TForm1.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
var
  rdr : TGIS_RendererAbstract ;
begin
  rdr := _renderer ;
  rdr.CanvasPen.Width   := 1 ;
  // Random colour creates a flickering "marching ants" outline effect
  rdr.CanvasPen.Color   := TGIS_Color.FromBGR( Cardinal(Random( $FFFFFF )) ) ;
  rdr.CanvasPen.Style := TGIS_PenStyle.Solid ;
  // Clear brush so only the outline is drawn (no fill obscuring the map)
  rdr.CanvasBrush.Style := TGIS_BrushStyle.Clear ;

  if btnRect.Down then begin
    // Do not draw until the user has actually moved the cursor (zero-size guard)
    if (oldPos1.X = oldPos2.X) and (oldPos1.Y = oldPos2.Y) then exit ;
    rdr.CanvasDrawRectangle( Rect( oldPos1.X, oldPos1.Y, oldPos2.X, oldPos2.Y ) ) ;
  end;

  if btnCircle.Down then begin
    // CanvasDrawEllipse takes top-left corner, width, and height in screen pixels.
    // The top-left is the centre minus the radius on both axes.
    rdr.CanvasDrawEllipse(oldPos1.X - Round(oldRadius), oldPos1.Y - Round(oldRadius),
                          oldRadius * 2, oldRadius * 2);
  end;
end;

end.
