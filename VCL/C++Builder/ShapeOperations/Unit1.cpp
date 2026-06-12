//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// ShapeOperations sample - Interactive affine transformation of vector shapes.
// C++Builder / VCL edition.
//
// This sample demonstrates how to interactively apply affine geometric
// transformations to individual vector shapes using the TatukGIS DK API:
//
//   Rotate:    Spins the selected shape around its centroid.
//              Page 0 of the tab control activates this mode.
//              Rotation angle = DegToRad( (X - prevX) * (Y - prevY) ).
//   Scale:     Grows or shrinks the shape by comparing current to previous
//              screen coordinates per axis.  Page 1 activates this mode.
//   Move:      Translates the shape by the map-coordinate delta between
//              consecutive mouse-move events.  Page 2 activates this mode.
//
// Two-layer workflow:
//   1. The original shapefile layer holds the real data.
//   2. edtLayer (TGIS_LayerVector, CachedPaint=false) renders a live preview;
//      CachedPaint=false makes it a "tracking" layer so InvalidateTopmost
//      redraws it immediately on every incremental transform.
// On commit (second mouse-up), CopyGeometry writes the final geometry back
// to the source shape, and RevertAll clears the preview layer.
//
// Data: Samples\3D\buildings.shp
//
// Check project\options\directories in case of any problems during compilation.
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

/*
 * TransformSelectedShape
 * ----------------------
 * Applies a 3x3 affine transformation matrix to every vertex of shape,
 * pivoting around the shape's geometric centroid so that rotate/scale
 * operations feel natural (the shape stays in place rather than flying off
 * to the origin).
 *
 * The matrix convention used by TGIS_Shape::Transform is:
 *
 *     | xx  yx  0 |       x' = x*xx + y*xy + dx
 *     | xy  yy  0 |  =>   y' = x*yx + y*yy + dy
 *     |  0   0  1 |       z' = z   (z component is preserved)
 *
 * The pivot point (centroid, passed as TGIS_Point3D) tells the API to
 * translate the shape to the origin, apply the matrix, then translate back.
 * Passing (0,0) for dx/dy when rotating or scaling keeps the shape centred.
 *
 * After updating the geometry, InvalidateTopmost redraws only the topmost
 * layer (the preview layer), which is much faster than a full map repaint.
 */
void __fastcall TForm1::TransformSelectedShape(
                TGIS_Shape *shape,
                double xx,
                double yx,
                double xy,
                double yy,
                double dx,
                double dy )
{
  TGIS_Point centroid ;

  if( shape == NULL ) return ;

  // Compute the centroid so the transform pivots around the shape's centre
  centroid = shape->Centroid();

  // Apply the affine matrix:
  // x' = x*xx + y*xy + dx
  // y' = x*yx + y*yy + dy
  // z' = z
  shape->Transform( GisPoint3DFrom2D( centroid ),  // pivot point (centroid)
                   xx, yx, 0,                       // first row of matrix
                   xy, yy, 0,                       // second row
                    0,  0, 1,                       // third row (z pass-through)
                   dx, dy, 0,                       // translation vector
                   False                            // do not recalc extent yet
                  );

  // Refresh only the top preview layer; avoid repainting the whole map
  GIS->InvalidateTopmost();
}

/*
 * RotateSelectedShape
 * -------------------
 * Builds a 2-D rotation matrix for the given angle (in radians) and
 * delegates to TransformSelectedShape.  Standard rotation matrix:
 *
 *     | cos(a)  sin(a) |
 *     |-sin(a)  cos(a) |
 *
 * A positive angle rotates counter-clockwise in standard map orientation.
 */
void __fastcall TForm1::RotateSelectedShape(TGIS_Shape *shape, double angle)
{
  TransformSelectedShape(
    shape,
     Cos(angle), Sin(angle),    // row 0: x stays on x-axis rotated
    -Sin(angle), Cos(angle),    // row 1: y stays on y-axis rotated
             0 ,        0       // no additional translation
  );
}

/*
 * ScaleSelectedShape
 * ------------------
 * Builds a non-uniform scale matrix.  x_value and y_value are the scale
 * factors for each axis (e.g. 1.1 = 10% larger).  Values < 1 shrink the
 * shape; values > 1 grow it.  The centroid pivot keeps the shape centred.
 */
void __fastcall TForm1::ScaleSelectedShape(TGIS_Shape *shape, double x_value, double y_value)
{
  TransformSelectedShape(
    shape,
     x_value ,        0  ,   // scale X axis
           0 ,   y_value ,   // scale Y axis
           0 ,        0      // no translation
  );
}

/*
 * TranslateSelectedShape
 * ----------------------
 * Slides the shape by (x_value, y_value) in map coordinates.
 * The identity submatrix leaves coordinates unchanged; only dx/dy translate.
 */
void __fastcall TForm1::TranslateSelectedShape( TGIS_Shape *shape, double x_value, double y_value)
{
  TransformSelectedShape(
    shape,
         1 ,         0 ,   // identity: x unchanged
         0 ,         1 ,   // identity: y unchanged
    x_value,   y_value     // pure translation
  );
}

/*
 * FormCreate
 * ----------
 * Initialises the sample when the form is first created:
 *   - Opens the 3-D buildings shapefile from the standard samples location.
 *   - Creates an in-memory vector layer (edtLayer) that acts as an edit
 *     overlay.  CachedPaint = false makes it a "tracking" layer so every
 *     call to InvalidateTopmost triggers an immediate repaint without the
 *     normal tile-caching pass.
 *   - Sets the layer style to a transparent fill with a red outline so
 *     users can clearly see the shape being manipulated.
 *   - Sets the page control to page 2 (Move) as the initial mode.
 *   - Zooms in 4x so the buildings are visible at a comfortable scale.
 */
void __fastcall TForm1::FormCreate( TObject *Sender)
{
  curShape = NULL ;
  edtShape = NULL ;
  handleMouseMove = false ;
  pgc1->ActivePageIndex = 2 ;           // Start in Move mode
  lblSelected->Caption = "Select shape on the map to start transform" ;

  GIS->Lock() ;  // Suspend repaints while loading/configuring layers

  // GisSamplesDataDirDownload resolves the path to the shared sample data
  GIS->Open( GisSamplesDataDirDownload() + "Samples\\3D\\buildings.shp");

  // Create the in-memory edit/preview overlay layer
  edtLayer = new TGIS_LayerVector() ;
  edtLayer->CS = GIS->CS ;              // Match coordinate system of the viewer
  edtLayer->CachedPaint = false ;       // Tracking layer: bypass tile cache
  edtLayer->Params->Area->Pattern = TGIS_BrushStyle::Clear ;    // Transparent fill
  edtLayer->Params->Area->OutlineColor = TGIS_Color::Red ;      // Red outline
  GIS->Add( edtLayer );

  GIS->Unlock() ;
  GIS->Zoom = GIS->Zoom * 4 ;          // Zoom in for a better starting view
}

/*
 * GISMouseMove
 * ------------
 * Called every time the mouse moves over the viewer while a shape is selected
 * (handleMouseMove = true).  Dispatches to the correct transform depending on
 * the active page index.
 *
 * Page 0 (Rotate):    angle = DegToRad( deltaX * deltaY ) — both axes contribute.
 * Page 1 (Scale):     ratio = current / previous pixel position per axis.
 * Page 2 (Translate): delta = difference in map coordinates between events.
 *
 * prevX/prevY and prevPtg are updated at the end of each event so the next
 * call works with an incremental delta rather than an absolute offset.
 */
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg ;

  if ( edtShape == NULL ) return ;  // Nothing selected yet; ignore

  if ( handleMouseMove ) {

    // Convert screen pixel to map coordinate for translation delta
    ptg = GIS->ScreenToMap( Point( X, Y ) ) ;

    if ( pgc1->ActivePageIndex == 0 )
      // Rotate: combined horizontal and vertical pixel delta drives angle
      RotateSelectedShape(edtShape, DegToRad(1.0*((X - prevX)*(Y - prevY)))) ;
    else if ( pgc1->ActivePageIndex == 1 )
    {
      // Guard against division-by-zero on the very first move event
      if ((prevX != 0) && (prevY != 0))
         // Scale factor = current position / previous position (per axis)
         ScaleSelectedShape(edtShape, X / ( prevX * 1.0)  , Y / ( prevY *1.0 )) ;
    }
    else
      // Translate by the map-coordinate delta since last event
      TranslateSelectedShape( edtShape, (ptg.X - prevPtg.X), (ptg.Y - prevPtg.Y) );

    // Store current state as "previous" for the next incremental update
    prevPtg.X = ptg.X ;
    prevPtg.Y = ptg.Y ;
    prevX     = X ;
    prevY     = Y ;
  }
}

/*
 * GISMouseUp
 * ----------
 * Handles both the select click (first up) and the commit click (second up).
 *
 * First click (curShape is NULL):
 *   - Calls GIS->Locate to find a shape within a 5-pixel tolerance.
 *   - Calls MakeEditable on the found shape to obtain a writable proxy.
 *   - Creates a copy of the shape in the preview layer (edtLayer) so edits
 *     are visible without affecting the original.
 *   - Toggles handleMouseMove to start receiving transform events.
 *
 * Second click (curShape is assigned):
 *   - Writes the final edited geometry back to the original shape via
 *     CopyGeometry, making the change permanent in the layer.
 *   - Reverts all shapes in the preview layer (RevertAll) and clears
 *     references, ending the edit session.
 *   - Triggers a full map repaint to show the committed result.
 */
void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Shape *shp  ;
  TGIS_Point ptg  ;
  AnsiString str ;

  lblSelected->Caption = "No selected shape";

  // Only proceed if the viewer has data and is in Select interaction mode
  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;

  if ( GIS->Mode != TGIS_ViewerMode::Select ) return ;

  // --- COMMIT path: a shape was already selected and being edited ---
  if ( curShape != NULL ){
    // Copy the transformed preview geometry back into the original layer shape
    curShape->CopyGeometry( edtShape );

    // Clear the preview layer; RevertAll discards all shapes added during editing
    edtLayer->RevertAll() ;

    curShape = NULL ;
    edtShape = NULL;

    // Full repaint so the committed shape is rendered in the original layer style
    GIS->InvalidateWholeMap() ;

    handleMouseMove = false;

    // Restore the appropriate mode hint
    if ( pgc1->ActivePageIndex == 2 )
      lblSelected->Caption = "Select shape to start moving." ;
    else if ( pgc1->ActivePageIndex == 1 )
      lblSelected->Caption = "Select shape to start scaling." ;
    else
      lblSelected->Caption = "Select shape to start rotating." ;

    return;
  }

  // --- SELECT path: pick a shape from the map ---

  // Convert screen point to map coordinate for spatial lookup
  ptg = GIS->ScreenToMap( Point( X, Y ) )  ;

  // Locate the topmost shape within 5 screen pixels of the click point.
  // The tolerance (5.0/Zoom) converts screen pixels to map units.
  shp = ( TGIS_Shape *)( GIS->Locate( ptg, (5.0/GIS->Zoom ) ) ) ;
  if ( shp == NULL )
    return ;

  // MakeEditable returns a transient proxy allowing geometry changes on the
  // source layer's shape without flushing to disk until explicitly saved.
  curShape = shp->MakeEditable() ;

  // AddShape copies curShape into the preview layer so we can manipulate it
  // visually during the drag without disturbing the source layer.
  edtShape = edtLayer->AddShape( curShape->CreateCopy() ) ;

  lblSelected->Caption = str.sprintf( "Selected shape : %d. Click to commit changes.",
                                 curShape->Uid
                                ) ;

  // Initialise previous-position state for incremental delta calculation
  prevPtg.X = ptg.X;
  prevPtg.Y = ptg.Y;
  prevX     = X ;
  prevY     = Y ;

  // Toggle the flag to start processing mouse-move events as transforms
  handleMouseMove = !handleMouseMove;
}

/*
 * GISMouseWheelDown / GISMouseWheelUp
 * ------------------------------------
 * Implement zoom-around-cursor using ZoomBy.  The ratio 9/8 (zoom in) and
 * 8/9 (zoom out) gives a ~12% step per wheel notch.  The current mouse
 * position is converted to client coordinates so the map zooms centred on
 * the pointer rather than the centre of the window.
 */
void __fastcall TForm1::GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  TPoint pt;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 9./8., pt.X, pt.Y );  // Zoom in ~12%

  Handled = true ;
}

void __fastcall TForm1::GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  TPoint pt ;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 8./9., pt.X, pt.Y );  // Zoom out ~12%

  Handled = true ;
}

/*
 * pgc1Changing
 * ------------
 * When the user switches the mode tab, any in-progress drag must be cancelled
 * so the state machine does not get stuck with handleMouseMove = true.
 */
void __fastcall TForm1::pgc1Changing(TObject *Sender, bool &AllowChange)
{
  handleMouseMove = False;
}
//---------------------------------------------------------------------------
