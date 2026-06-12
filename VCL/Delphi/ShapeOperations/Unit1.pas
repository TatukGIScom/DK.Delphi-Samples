//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  ShapeOperations sample - Interactive geometry transformation of vector shapes.

  This sample demonstrates how to interactively apply affine geometric
  transformations to individual vector shapes using the TatukGIS DK API:

    - Rotate: spins the shape around its own centroid proportional to
              horizontal mouse movement (angle in radians derived from pixels).
    - Scale:  grows or shrinks the shape relative to its centroid based on
              the ratio of the current mouse position to the previous one.
    - Move (Translate): slides the shape in map coordinates matching the
              delta between consecutive mouse positions.

  The workflow uses a two-layer pattern:
    1. The original layer holds the real shapefile data.
    2. A transient in-memory TGIS_LayerVector (edtLayer) renders a live
       preview of the shape being edited without touching the original data.
  On commit (second mouse-up) the modified geometry is written back to the
  source shape via CopyGeometry, and the preview layer is reverted.

  Data: Samples\3D\buildings.shp
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  //GisLicense,
  GisTypes,        // TGIS_Point, TGIS_Shape and other core types
  GisLayerSHP,     // SHP file layer support
  GisLayerVector,  // In-memory vector layer used as edit/preview layer
  GisViewer,       // TGIS_ViewerMode enumeration
  GisTypesUI,      // TGIS_Color, TGIS_BrushStyle
  GisUtils,        // TGIS_Utils helpers (data directory, point constructors)
  Vcl.GisViewerWnd, Vcl.ExtCtrls;

type
  { Main form for the ShapeOperations sample.
    Demonstrates interactive rotate, scale, and translate operations on
    individual vector shapes using TGIS_Shape.Transform with an affine matrix. }
  TForm1 = class(TForm)
    Panel1: TPanel;
    GIS: TGIS_ViewerWnd;           // Main map viewer control
    lblSelected: TLabel;           // Status/hint label shown above the map
    rbRotate: TRadioButton;        // Select Rotate mode
    rbScale: TRadioButton;         // Select Scale mode
    rbMove: TRadioButton;          // Select Move (translate) mode
    procedure FormCreate(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure pgc1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure rbRotateClick(Sender: TObject);
    procedure rbScaleClick(Sender: TObject);
    procedure rbMoveClick(Sender: TObject);
  private
    { Private declarations }

    // Flag that enables transform dragging; toggled by first mouse-up (select)
    // and cleared by second mouse-up (commit).
    handleMouseMove : boolean;

    // Map-coordinate position of the previous mouse event, used to compute
    // the delta for translation mode.
    prevPtg  : TGIS_Point;

    // Screen-pixel coordinates of the previous mouse event, used to derive
    // rotation angle and scale ratios.
    prevX    : Integer;
    prevY    : Integer;

    // The in-memory overlay layer that shows the shape being dragged without
    // modifying the underlying shapefile until the user commits.
    edtLayer : TGIS_LayerVector;

    // The original shape in the source layer, placed in editable state via
    // MakeEditable so that CopyGeometry can write back later.
    curShape : TGIS_Shape;

    // The working copy of curShape that lives in edtLayer and receives all
    // intermediate transform calls during the drag session.
    edtShape : TGIS_Shape;

    { Core affine transform helper and the three convenience wrappers. }
    procedure TransformSelectedShape(shape : TGIS_Shape; xx, yx, xy, yy, dx, dy : Double);
    procedure RotateSelectedShape   (shape : TGIS_Shape; angle : Double);
    procedure ScaleSelectedShape    (shape : TGIS_Shape; x_value, y_value : Double);
    procedure TranslateSelectedShape(shape : TGIS_Shape; x_value, y_value : Double);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,   // Cos, Sin, DegToRad

  GisFunctions,  // GisPoint3DFrom2D helper
  GisRtl;        // RTL support utilities

{
  TransformSelectedShape
  ----------------------
  Applies a 3x3 affine transformation matrix to every vertex of <shape>,
  pivoting around the shape's geometric centroid so that rotate/scale
  operations feel natural (the shape stays in place rather than flying off
  to the origin).

  The matrix convention used by TGIS_Shape.Transform is:

      | xx  yx  0 |       x' = x*xx + y*xy + dx
      | xy  yy  0 |  =>   y' = x*yx + y*yy + dy
      |  0   0  1 |       z' = z   (z component is preserved)

  The pivot point (centroid, passed as TGIS_Point3D) tells the API to
  translate the shape to the origin, apply the matrix, then translate back,
  so the caller passes (0,0) for dx/dy when rotating or scaling.

  After updating the geometry, InvalidateTopmost redraws only the topmost
  layer (the preview layer), which is much faster than a full map repaint.
}
procedure TForm1.TransformSelectedShape(shape : TGIS_Shape; xx, yx, xy, yy, dx, dy : Double);
var
  centroid : TGIS_Point;
begin
  if shape = nil then exit;

  // Compute the centroid so the transform pivots around the shape's centre
  centroid := shape.Centroid;

  // x' = x*xx + y*xy + dx
  // y' = x*yx + y*yy + dy
  // z' = z
  shape.Transform( GisPoint3DFrom2D( centroid ),  // pivot point (centroid)
                   xx, yx, 0,                      // first row of matrix
                   xy, yy, 0,                      // second row
                    0,  0, 1,                      // third row (z pass-through)
                   dx, dy, 0,                      // translation vector
                   False                           // False = do not recalc extent yet
                 );

  // Refresh only the top preview layer; avoid repainting the whole map
  GIS.InvalidateTopmost;
end;

{
  RotateSelectedShape
  -------------------
  Builds a 2-D rotation matrix for the given angle (in radians) and
  delegates to TransformSelectedShape.  The standard rotation matrix is:

      | cos(a)  sin(a) |
      |-sin(a)  cos(a) |

  A positive angle rotates counter-clockwise in standard map orientation.
  The dx/dy translation components are zero because the pivot is handled
  by passing the centroid to TGIS_Shape.Transform.
}
procedure TForm1.RotateSelectedShape(shape : TGIS_Shape; angle : Double);
begin
  TransformSelectedShape(
    shape,
     Cos(angle), Sin(angle),   // row 1: x stays on x-axis rotated
    -Sin(angle), Cos(angle),   // row 2: y stays on y-axis rotated
             0 ,        0      // no additional translation
  );
end;

{
  ScaleSelectedShape
  ------------------
  Builds a non-uniform scale matrix.  x_value and y_value are the scale
  factors for each axis (e.g. 1.1 = 10% larger).  Values < 1 shrink the
  shape; values > 1 grow it.  The pivot centroid keeps the shape centred.
}
procedure TForm1.ScaleSelectedShape(shape : TGIS_Shape; x_value, y_value : Double);
begin
  TransformSelectedShape(
    shape,
     x_value ,        0  ,   // scale X axis
           0 ,   y_value ,   // scale Y axis
           0 ,        0      // no translation
  );
end;

{
  TranslateSelectedShape
  ----------------------
  Slides the shape by (x_value, y_value) in map coordinates.
  The identity submatrix leaves coordinates unchanged; only the dx/dy
  translation vector is non-zero.
}
procedure TForm1.TranslateSelectedShape(shape : TGIS_Shape; x_value, y_value : Double);
begin
  TransformSelectedShape(
    shape,
         1 ,         0 ,   // identity: x unchanged
         0 ,         1 ,   // identity: y unchanged
    x_value,   y_value    // pure translation
  );
end;

{
  FormCreate
  ----------
  Initialises the sample when the form is first shown:
    - Opens the 3-D buildings shapefile from the standard samples location.
    - Creates an in-memory vector layer (edtLayer) that acts as an edit
      overlay.  CachedPaint = False makes it a "tracking" layer so every
      call to InvalidateTopmost triggers an immediate repaint without the
      normal tile-caching pass.
    - Sets the layer style to a transparent fill with a red outline so
      users can clearly see the shape being manipulated.
    - Zooms in 4x so the buildings are visible at a comfortable scale.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  curShape := nil;
  edtShape := nil;
  handleMouseMove := False;
  lblSelected.Caption := 'Select shape on the map to start transform';

  GIS.Lock;  // Suspend repaints while loading/configuring layers

  // Load the sample buildings shapefile; GisSamplesDataDirDownload resolves
  // the path to the shared TatukGIS sample data directory.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\3D\buildings.shp');

  // Create the in-memory edit/preview overlay layer
  edtLayer := TGIS_LayerVector.Create;
  edtLayer.CS := GIS.CS;               // Match coordinate system of the viewer
  edtLayer.CachedPaint := False;        // Tracking layer: bypass tile cache so
                                        // InvalidateTopmost redraws immediately
  edtLayer.Params.Area.Pattern := TGIS_BrushStyle.Clear;    // Transparent fill
  edtLayer.Params.Area.OutlineColor := TGIS_Color.Red;      // Bright red outline
  GIS.Add( edtLayer );                  // Add above the shapefile layer

  GIS.Unlock;                           // Resume painting
  GIS.Zoom := GIS.Zoom * 4;            // Zoom in for a better starting view
end;

{
  GISMouseMove
  ------------
  Called every time the mouse moves over the viewer while a shape is selected
  (handleMouseMove = True).  Dispatches to the correct transform depending on
  the active radio button.

  Rotate:    angle = horizontal pixel delta converted to radians.
  Scale:     ratio = current / previous screen pixel position (per axis).
  Translate: delta = difference in map coordinates between consecutive events.

  prevX/prevY and prevPtg are updated at the end of each event so the next
  call works with an incremental delta rather than an absolute offset.
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point;
begin
  if edtShape = nil then exit;  // Nothing selected yet; ignore

  if handleMouseMove then begin

    // Convert screen pixel to map coordinate for translation delta
    ptg := GIS.ScreenToMap( Point( X, Y ) );

    if rbRotate.Checked = true then
      // Horizontal mouse movement drives the rotation angle (1 pixel = 1 degree)
      RotateSelectedShape(edtShape, DegToRad(X - prevX))

    else if rbScale.Checked = true then begin
      // Guard against division-by-zero on the very first move event
      if (prevX <> 0) and (prevY <> 0) then
        // Scale factor = current position / previous position (per axis)
        ScaleSelectedShape(edtShape, X / prevX, Y / prevY)
    end

    else if rbMove.Checked = true then
      // Translate by the map-coordinate delta since last event
      TranslateSelectedShape(edtShape, (ptg.X - prevPtg.X), (ptg.Y - prevPtg.Y));

    // Store current state as "previous" for the next incremental update
    prevPtg.X := ptg.X;
    prevPtg.Y := ptg.Y;
    prevX     := X;
    prevY     := Y;
  end;
end;

{
  GISMouseUp
  ----------
  Handles both the select click (first up) and the commit click (second up).

  First click (curShape is nil):
    - Converts screen point to map coordinates.
    - Calls GIS.Locate to find a shape within a 5-pixel tolerance.
    - Calls MakeEditable on the found shape to obtain a writable proxy.
    - Creates a copy of the shape in the preview layer (edtLayer) so edits
      are visible without affecting the original.
    - Toggles handleMouseMove to start receiving transform events.

  Second click (curShape is assigned):
    - Writes the final edited geometry back to the original shape via
      CopyGeometry, making the change permanent in the layer.
    - Reverts all shapes in the preview layer (RevertAll) and clears
      references, ending the edit session.
    - Triggers a full map repaint to show the committed result.
}
procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp : TGIS_Shape;
  ptg : TGIS_Point;
begin
  // Do not process events while the map is being painted
  if GIS.InPaint then exit;

  lblSelected.Caption := 'No selected shape. Select shape';

  // --- COMMIT path: a shape was already selected and being edited ---
  if Assigned(curShape) then
  begin
    // Copy the transformed preview geometry back into the original layer shape
    curShape.CopyGeometry( edtShape );

    // Clear the preview layer; RevertAll discards all shapes added during editing
    edtLayer.RevertAll;

    curShape := nil;
    edtShape := nil;

    // Full repaint so the committed shape is rendered in the original layer style
    GIS.InvalidateWholeMap;
    handleMouseMove := false;
    exit;
  end;

  // --- SELECT path: pick a shape from the map ---

  // Only proceed if the viewer has data and is in Select interaction mode
  if GIS.IsEmpty then exit;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit;

  // Convert screen point to map coordinate for spatial lookup
  ptg := GIS.ScreenToMap( Point( X, Y ) );

  // Locate the topmost shape within 5 screen pixels of the click point.
  // The tolerance (5 / Zoom) converts screen pixels to map units.
  shp := TGIS_Shape( GIS.Locate( ptg, 5 / GIS.Zoom ) );
  if not Assigned( shp ) then exit;

  // MakeEditable returns a transient proxy that allows geometry changes on the
  // source layer's shape; these are not flushed to disk until explicitly saved.
  curShape := shp.MakeEditable;

  // AddShape copies curShape into the preview layer so we can manipulate it
  // visually during the drag without disturbing the source layer.
  edtShape := edtLayer.AddShape( curShape.CreateCopy );

  lblSelected.Caption := Format( 'Selected shape : %d. Click to commit changes.',
                                 [curShape.Uid] );

  // Initialise previous-position state for incremental delta calculation
  prevPtg.X := ptg.X;
  prevPtg.Y := ptg.Y;
  prevX     := X;
  prevY     := Y;

  // Toggle the flag to start processing mouse-move events as transforms
  handleMouseMove := not handleMouseMove;
end;

{
  GISMouseWheelDown / GISMouseWheelUp
  ------------------------------------
  Implement zoom-around-cursor using ZoomBy.  The ratio 9/8 (zoom in) and
  8/9 (zoom out) gives a ~12% step per wheel notch.  The current mouse
  position is converted to client coordinates so the map zooms centred on
  the pointer rather than the centre of the window.
}
procedure TForm1.GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  if GIS.IsEmpty then exit;

  pt := GIS.ScreenToClient( MousePos );
  GIS.ZoomBy( 9/8, pt.X, pt.Y );  // Zoom in ~12%

  Handled := True;
end;

procedure TForm1.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint;
begin
  if GIS.IsEmpty then exit;

  pt := GIS.ScreenToClient( MousePos );
  GIS.ZoomBy( 8/9, pt.X, pt.Y );  // Zoom out ~12%

  Handled := True;
end;

{
  pgc1Changing
  ------------
  When the user switches the mode tab, any in-progress drag must be cancelled
  so the state machine does not get stuck.
}
procedure TForm1.pgc1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  handleMouseMove := False;
end;

{ Radio button click handlers - switch the active transform mode.
  If a shape is currently selected, deselect it (cancel the edit session)
  so the user starts fresh in the new mode. }

procedure TForm1.rbMoveClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start moving';

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost;
    curShape := nil;
    handleMouseMove := false;
    exit;
  end;
end;

procedure TForm1.rbRotateClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start rotating';

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost;
    curShape := nil;
    handleMouseMove := false;
    exit;
  end;
end;

procedure TForm1.rbScaleClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start scaling';

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost;
    curShape := nil;
    handleMouseMove := false;
    exit;
  end;
end;

end.
