//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  DragLabel sample — demonstrates interactive draggable feature labels on maps.

  What the sample shows:
    - Two parallel in-memory vector layers: realpoints (actual features) and sidekicks (labels)
    - Realpoints layer contains CGM marker symbols that never move via user interaction
    - Sidekicks layer contains invisible ghost points that carry label text
    - Spatial offset between sidekick and realpoint positions for clean label display
    - User dragging sidekick shapes freely across the map
    - PaintShapeLabelEvent callback firing during normal paint cycle
    - Looking up corresponding realpoint by matching shape UIDs
    - Drawing connecting leader line from realpoint to label position
    - Copying name attribute from real shape for label text
    - Manual editor control for drag-to-reposition interaction
    - Programmatic movement loop demonstrating simultaneous realpoint/sidekick translation

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd                      - main visual map control
    TGIS_LayerVector                    - in-memory vector layer for features
    TGIS_Shape                          - individual geographic feature
    PaintShapeLabelEvent (callback)     - per-shape label rendering hook
    TGIS_RendererAbstract               - platform-agnostic drawing interface
    GIS.MapToScreen()                   - convert geographic coords to screen pixels
    GIS.Editor.MouseBegin()             - start manual shape editing/dragging
    TGIS_Shape.SetPosition()            - reposition shape in geographic space
    DrawLabel()                         - render text label at shape position
    Shape UID matching                  - relate realpoint to sidekick pair
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
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisInterfaces,
  GisLayer,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;  // toolbar housing the Animate button
    GIS: TGIS_ViewerWnd; // main TatukGIS map viewer control
    Button1: TButton;    // "Animate" button - triggers programmatic movement

    // Mouse event handlers for drag interaction
    procedure Button1Click(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

    // The sidekick shape currently being dragged; nil when no drag is active.
    currShape : TGIS_Shape ;

    // Custom label-paint callback registered on the "sidekicks" layer via
    // PaintShapeLabelEvent.  Draws the leader line and the label text each
    // time the viewer repaints the shape.
    procedure doLabelPaint( _sender : TObject            ;
                            _shape  : TGIS_Shape
                          )  ;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  // Prefix used when building the "name" attribute stored on each real point.
  LABEL_TEXT = 'Ship ' ;

implementation

uses
  GisRendererAbstract ;

{$R *.DFM}

{ TForm1.Button1Click
  Animates one realpoint and its sidekick for 90 steps of (2, 1) map-unit
  displacement per step, sleeping 100 ms between steps so the movement is
  visible.  ProcessMessages keeps the UI responsive during the loop.
}
procedure TForm1.Button1Click(Sender: TObject);
var
  i   : Integer    ;
  shp : TGIS_Shape ;

  { synchroMove
    Moves both the real point (_shp) and the matching sidekick by (_x, _y)
    map units in a single step.

    The "sidekick" layer stores shadow shapes whose UIDs match the real-point
    UIDs, which is how we look up the corresponding ghost shape.

    The ex extent is computed here but intentionally left unused (the viewer's
    built-in change-detection handles invalidation); it exists as a scaffold
    for callers that might want to call InvalidateExtent explicitly.
  }
  procedure synchroMove( _shp : TGIS_Shape ; _x,_y : Integer ) ;
  var
    ll  : TGIS_LayerVector ;
    shp : TGIS_Shape ;
    ptgA : TGIS_Point ;
    ptgB : TGIS_Point ;
    ex  : TGIS_Extent ;
  begin
    // Retrieve the current geographic position of the real point, shift it,
    // and commit with SetPosition (which also fires the viewer repaint).
    ptgA := _shp.GetPoint( 0, 0 ) ;
    ptgA.x := ptgA.X + _x ;
    ptgA.Y := ptgA.Y + _y ;
    _shp.SetPosition( ptgA , nil, 0 ) ;

    // Locate the matching sidekick by UID and apply the same displacement so
    // the leader line length is preserved across animation frames.
    ll := TGIS_LayerVector( GIS.Get( 'sidekicks' ) ) ;
    shp := ll.GetShape( _shp.Uid ) ;
    ptgB := shp.GetPoint( 0, 0 ) ;
    ptgB.x := ptgB.X + _x ;
    ptgB.Y := ptgB.Y + _y ;
    shp.SetPosition( ptgB , nil, 0 ) ;

    // Build the bounding extent covering both points.  Required when
    // calling InvalidateExtent to limit the repaint region (not called
    // here but left for reference).
    ex.XMin := Min( ptgA.X, ptgB.X ) ;
    ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
    ex.XMax := Max( ptgA.X, ptgB.X ) ;
    ex.YMax := Max( ptgA.Y, ptgB.Y ) ;
  end ;

begin
  // Animate shape with UID=5 from the realpoints layer
  shp := TGIS_LayerVector( GIS.Get( 'realpoints' ) ).GetShape( 5 ) ;
  for i:=0 to 90 do begin
    synchroMove( shp, 2, 1 ) ;
    Sleep( 100 ) ;
    Application.ProcessMessages ;
  end ;
end;

{ TForm1.doLabelPaint
  PaintShapeLabelEvent callback - fired by the "sidekicks" layer for every
  sidekick shape during a repaint pass.

  _shape is the sidekick shape being painted.  Its Uid matches the
  corresponding realpoint, enabling the lookup.

  Steps:
    1. Find the realpoint at the same UID.
    2. Convert both geographic points to screen pixels via MapToScreen.
       MapToScreen takes a TGIS_Point (geographic/projected coordinates) and
       returns a TPoint in screen pixels relative to the viewer's top-left.
    3. Set pen properties on the abstract renderer and draw a leader line
       connecting the real location to the floating label position.
    4. Copy the "name" field value from the real feature into the sidekick's
       label parameter, then call DrawLabel to have TatukGIS render the text
       using the layer's label style.
}
procedure TForm1.doLabelPaint(
  _sender : TObject ;
  _shape  : TGIS_Shape
) ;
var
  ptA, ptB : TPoint ;          // screen-pixel positions
  ll : TGIS_LayerVector ;
  shp : TGIS_Shape ;           // corresponding real point shape
  rdr : TGIS_RendererAbstract ;
begin
  // Retrieve the real-point layer and the matching shape by UID
  ll := TGIS_LayerVector( GIS.Get('realpoints') ) ;
  shp := ll.GetShape( _shape.Uid ) ;

  // Convert geographic coordinates to screen pixels.
  // Viewer.Ref gives access to the coordinate transformation utilities of
  // the viewer that is currently rendering this shape.
  ptA := _shape.Viewer.Ref.MapToScreen( shp.GetPoint( 0, 0 ) ) ;    // real point
  ptB := _shape.Viewer.Ref.MapToScreen( _shape.GetPoint( 0, 0 ) ) ;  // sidekick (label anchor)

  // Draw the blue leader line on the abstract renderer canvas.
  // TGIS_RendererAbstract provides a unified drawing API that works
  // regardless of the underlying graphics engine (GDI+, Direct2D, Skia, …).
  rdr := GIS.Renderer as TGIS_RendererAbstract ;
  with rdr do
  begin
   CanvasPen.Color := TGIS_Color.Blue ;
   CanvasPen.Style := TGIS_PenStyle.Solid ;
   CanvasPen.Width := 1 ;
   CanvasDrawLine( ptA.x, ptA.y, ptB.x, ptB.y ) ;
  end ;

  // Populate the sidekick's label value from the real feature's "name" field,
  // then let TatukGIS render the label text at the sidekick's position
  // using whatever label style is configured on the "sidekicks" layer.
  _shape.Params.Labels.Value := shp.GetField('name') ;
  _shape.DrawLabel ;
end ;

{ TForm1.GISMouseDown
  Begins a label drag when the user clicks on or near a sidekick shape.

  GIS.IsEmpty / GIS.InPaint guards prevent starting an edit while a repaint
  is in progress, which would corrupt the renderer state.

  ll.Locate finds the nearest sidekick within a tolerance radius expressed
  in map units (100 / GIS.Zoom converts 100 screen pixels to map units,
  giving a constant pick radius regardless of zoom level).

  We call GIS.Editor.MouseBegin manually rather than switching GIS.Mode to
  Edit, so that the viewer's default panning/zoom behaviour is bypassed and
  we retain full control over what gets moved.
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ll  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // Search for a sidekick shape at the clicked screen position.
  // ScreenToMap converts pixel coordinates to geographic/projected coordinates.
  ll := TGIS_LayerVector( GIS.Get('sidekicks') ) ;
  shp := ll.Locate( GIS.ScreenToMap( Point(x,y) ), 100/GIS.Zoom ) ;
  currShape := shp ;

  if currShape = nil then exit ;

  // Initiate the editor's drag tracking without switching the viewer mode
  // to Edit globally - we handle all subsequent mouse events ourselves.
  GIS.Editor.MouseBegin( Point(x,y), True ) ;
end;

{ TForm1.GISMouseUp
  Ends the current drag by clearing the tracked shape reference.
  The viewer will repaint in its normal state on the next cycle.
}
procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;
  currShape := nil ;
end;

{ TForm1.GISMouseMove
  Moves the tracked sidekick shape to follow the mouse cursor.

  The bounding extent (ex) capturing both the old and new positions of the
  sidekick and its real counterpart is computed before and after the move.
  This extent could be passed to GIS.InvalidateExtent to repaint only the
  affected region; at the moment the full-map invalidation done by
  SetPosition is relied upon instead.

  ScreenToMap converts the current mouse pixel position to geographic map
  coordinates.  GisIsPointInsideExtent ensures the label cannot be dragged
  outside the map's visible extent, preventing the shape from escaping to
  coordinates that are off the valid geographic range.
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ll  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
  ptgA : TGIS_Point ;
  ptgB : TGIS_Point ;
    ex  : TGIS_Extent ;
begin
  if GIS.IsEmpty then exit ;
  if currShape = nil then exit ;

  // Capture pre-move extent to allow selective map invalidation
  ptgA := currShape.GetPoint( 0, 0 ) ;
  ll  := TGIS_LayerVector( GIS.Get( 'realpoints' ) ) ;
  shp := ll.GetShape( currShape.Uid ) ;
  ptgB := shp.GetPoint( 0, 0 ) ;
  ex.XMin := Min( ptgA.X, ptgB.X ) ;
  ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax := Max( ptgA.X, ptgB.X ) ;
  ex.YMax := Max( ptgA.Y, ptgB.Y ) ;

  // Convert screen pixel position to geographic map coordinates and
  // reposition the sidekick there, provided the point is within the
  // viewer's current map extent.
  ptgA := GIS.ScreenToMap( Point(x,y) ) ;
  if TGIS_Utils.GisIsPointInsideExtent( ptgA, GIS.Extent ) then
    currShape.SetPosition( ptgA, nil, 0 );

  // Capture post-move extent for any future selective invalidation
  ptgA := currShape.GetPoint( 0, 0 ) ;
  ll  := TGIS_LayerVector( GIS.Get( 'realpoints' ) );
  shp := ll.GetShape( currShape.Uid ) ;
  ptgB := shp.GetPoint( 0, 0 ) ;
  ex.XMin := Min( ptgA.X, ptgB.X ) ;
  ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax := Max( ptgA.X, ptgB.X ) ;
  ex.YMax := Max( ptgA.Y, ptgB.Y ) ;
end;

{ TForm1.FormCreate
  Builds the two-layer data model and populates it with 21 random ship points.

  Layer setup:
    "realpoints" - CachedPaint=False so that the viewer always redraws this
                   layer fresh (required because shape positions change at
                   runtime).  A CGM symbol file is attached as the marker.
                   A "name" string field stores the label text.

    "sidekicks"  - Invisible markers (Size=0), label position centred.
                   PaintShapeLabelEvent wired to doLabelPaint so we can
                   draw the leader line and label ourselves.
                   Allocator=False disables the auto label-placement
                   algorithm; the sidekick's own position is the label anchor.

  For each point:
    - A realpoint is added at a random world coordinate.
    - A sidekick is added at the same coordinate offset by 15 map units /
      GIS.Zoom so the label starts slightly displaced from the symbol.
    - The UID of both shapes is the same (CreateShape returns shapes
      with sequential UIDs from the same counter when added to separate
      layers in creation order), enabling the UID-based lookup in
      doLabelPaint.
}
procedure TForm1.FormCreate(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  i   : Integer    ;
  shp : TGIS_Shape ;
  ptg : TGIS_Point ;
begin
  // --- "realpoints" layer ---
  ll := TGIS_LayerVector.Create ;
  // Load the ship CGM symbol; SymbolList.Prepare caches and compiles the
  // symbol for later rendering with TGIS_Params.Marker.Symbol.
  ll.Params.Marker.Symbol := SymbolList.Prepare(
    TGIS_Utils.GisSamplesDataDirDownload +
    '\Symbols\2267.cgm'
  ) ;
  ll.Name:='realpoints' ;
  // Disable paint cache so the viewer always redraws moving shapes from
  // scratch rather than blitting a stale cached bitmap tile.
  ll.CachedPaint := False ;

  GIS.Add( ll ) ;
  ll.AddField( 'name', TGIS_FieldType.String, 100, 0 );
  // Set a world-spanning extent so all random points fall within the layer.
  ll.Extent := TGIS_Utils.GisExtent( -180, -180, 180, 180 ) ;

  // --- "sidekicks" layer (the draggable label anchors) ---
  ll := TGIS_LayerVector.Create ;
  ll.Name:='sidekicks' ;
  ll.Params.Marker.Size := 0 ;                                  // invisible marker
  ll.Params.Labels.Position := [TGIS_LabelPosition.MiddleCenter] ;
  ll.CachedPaint := False ;

  GIS.Add( ll ) ;
  // Register the custom label painter so we can draw leader lines and
  // control exactly when/how the label text appears.
  ll.PaintShapeLabelEvent := doLabelPaint ;
  // Disable auto-allocator so labels are always placed at the exact
  // sidekick position, not repositioned by TatukGIS's overlap-avoidance.
  ll.Params.Labels.Allocator := False ;

  // --- Populate both layers with random ship points ---
  for i:=0 to 20 do begin
    ptg := TGIS_Utils.GisPoint( Random( 360 ) - 180 , Random( 180 ) - 90 ) ;

    // Create the real (visible) point and configure its marker appearance.
    shp := TGIS_LayerVector( GIS.Get('realpoints') ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent ) ;   // prevent automatic extent expansion during edit
    shp.AddPart ;
    shp.AddPoint( ptg );
    // Rotate each symbol by its UID so ships face different directions.
    shp.Params.Marker.SymbolRotate := (shp.Uid);
    shp.Params.Marker.Size :=250;
    shp.Params.Marker.Color := TGIS_Color.FromRGB( Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;

    shp.SetField( 'name', Format( LABEL_TEXT + ': %d', [shp.Uid] ) );
    shp.Unlock ;

    // Create the matching sidekick at the same UID offset by a small screen
    // distance so the label does not initially overlap the symbol.
    shp := TGIS_LayerVector( GIS.Get('sidekicks') ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;

    // Offset by 15 pixels worth of map units (15 / Zoom converts screen
    // pixels to the current map-unit scale)
    ptg.x := ptg.x + 15/GIS.Zoom ;
    ptg.y := ptg.y + 15/GIS.Zoom ;
    shp.AddPoint( ptg );
    shp.Unlock ;
  end ;

  GIS.FullExtent ;
end;

end.
