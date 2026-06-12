//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// SelectByShape sample — demonstrates how to select vector features by drawing
// an arbitrary shape (circle or rectangle) interactively on the map.
//
// Key concepts shown:
//   - Interactive rubber-band drawing of a selection shape on the GIS viewer
//     using mouse events and the PaintExtraEvent hook.
//   - Converting screen pixel coordinates to geographic map coordinates via
//     ScreenToMap so the drawn shape is in the layer's coordinate system.
//   - Building a circular selection area using TGIS_Topology::MakeBuffer, which
//     approximates a circle as a polygon around a point shape using a given
//     radius in map units.
//   - Building a rectangular selection polygon by manually adding four corner
//     points to a new polygon shape.
//   - Spatial query via TGIS_LayerVector::FindFirst / FindNext using the
//     RELATE_INTERSECT predicate (a DE-9IM relationship test) to find all
//     features that share at least one point with the selection shape.
//   - Visually highlighting matched features with IsSelected and listing their
//     "name" attribute in a memo control.
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include <math.h>
#include <cmath>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

// FormCreate
// Initialises the map with the base Counties layer and two empty in-memory
// layers that will hold visual indicators added during selection:
//   "Points"  - invisible marker shapes placed at click/drag positions
//               (size = 0 so they are not rendered, used only as geometry
//                containers for the buffer calculation)
//   "Buffers" - the actual selection shape (circle polygon or rectangle)
//               rendered semi-transparently over the map
// The viewer is locked during setup so that only one repaint fires on Unlock.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector *ll ;

  GIS->Lock() ;
  // Open the base shapefile; Counties.shp supplies the features to select from
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp", true );

  // "Points" layer — invisible markers that act as geometry placeholders
  // (Marker->Size = 0 hides them from the renderer)
  ll = new TGIS_LayerVector;
  ll->Params->Area->Color = TGIS_Color::Blue;
  ll->Transparency = 50;
  ll->Name = "Points";
  // Inherit the coordinate system from the viewer so all geometry is in the
  // same spatial reference and ScreenToMap conversions are correct
  ll->CS = GIS->CS ;
  GIS->Add( ll );

  // "Buffers" layer — holds the selection shape drawn by the user
  ll = new TGIS_LayerVector;
  ll->Params->Area->Color = TGIS_Color::Blue;
  ll->Params->Area->OutlineColor = TGIS_Color::Blue;
  ll->Transparency = 60;    // Semi-transparent so the map beneath shows through
  ll->Name = "Buffers";
  ll->CS = GIS->CS ;
  GIS->Add( ll );
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

// GISMouseDown
// Records the starting screen position when the user begins a drag operation.
// Right-click switches back to the built-in Zoom mode so the user can pan/zoom
// without permanently leaving the custom Select mode.
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;

  if (Button == mbRight) {
    // Right-click: hand control back to the viewer's built-in zoom/pan behaviour
    GIS->Mode = TGIS_ViewerMode::Zoom;
    return;
  }
  // Initialise both anchor and drag-end to the same pixel so the shape starts
  // with zero size (guard against a stale oldPos2 from a previous selection)
  oldPos1 = Point( X, Y ) ;
  oldPos2 = Point( X, Y ) ;
  oldRadius = 0 ;
}
//---------------------------------------------------------------------------

// GISMouseMove
// Updates the rubber-band dimensions while the left mouse button is held down.
// For rectangle mode the second corner follows the cursor; for circle mode the
// radius is the Euclidean pixel distance from the anchor to the cursor.
// GIS->Invalidate() triggers a repaint, which calls GISPaintExtraEvent so the
// rubber-band is drawn on every frame.
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  if ( GIS->Mode != TGIS_ViewerMode::Select ) return;
  // Only update the rubber-band while the left button is pressed (dragging)
  if (!(Shift.Contains(ssLeft))) return ;

  if ( btnRect->Down){
    // Track the second corner of the bounding rectangle
    oldPos2 = Point( X, Y );
  }
  if ( btnCircle->Down ) {
    // Pythagorean distance from the anchor to the current cursor position
    oldRadius = RoundS( (Sqrt( pow( double( oldPos1.X - X), 2 )  + pow( double( oldPos1.Y - Y), 2 ) ) ) );
  }
  // Trigger a repaint so PaintExtraEvent draws the updated rubber-band shape
  GIS->Invalidate();
}
//---------------------------------------------------------------------------

// GISMouseUp
// The main event handler: finalises the selection shape and performs the
// spatial query.
//
// Steps:
//   1. Guard: ignore if the viewer is empty or the drag was too small.
//   2. Record invisible point markers in the "Points" layer to preserve the
//      geometry for the MakeBuffer call (circle) or corner calculation (rectangle).
//   3. Clear the "Buffers" layer and add the new selection polygon.
//      - Circle: TGIS_Topology::MakeBuffer approximates a circle as a 32-sided
//        polygon around the centre point, using the pixel-to-map distance as
//        the radius in map units.  distance/2 converts screen diameter to radius.
//      - Rectangle: four corner points are assembled in map coordinates.
//   4. Call FindFirst / FindNext on layer 0 (Counties) using RELATE_INTERSECT
//      to iterate over every shape that spatially intersects the selection polygon.
//      RELATE_INTERSECT is a DE-9IM predicate: it returns true when the two
//      geometries share at least one point (boundary or interior).
//   5. Mark each hit as selected (IsSelected) and append its name to Memo1.
//
//   Right-click releases: restores Select mode (reverses the right-click zoom
//   toggle set in GISMouseDown).
void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Topology     *tpl;
  TGIS_LayerVector  *ll;
  TGIS_Shape        *tmp;
  TGIS_Shape        *buf;
  TGIS_Point        ptg;   // Centre (circle) or first corner (rectangle) in map coords
  TGIS_Point        ptg1;  // Edge point used to compute the circle radius in map units
  TGIS_Point        ptg2;  // Opposite corner for rectangle in map coords
  double            distance;

  if ( GIS->IsEmpty ) return;

  if (Button == mbRight) {
    // Right-click: restore Select mode (reversed the right-click zoom set in MouseDown)
    GIS->Mode = TGIS_ViewerMode::Select;
    return;
  }
  if (GIS->Mode != TGIS_ViewerMode::Select) return;

  // Guard: if the drag produced no movement, ignore (avoids zero-size shapes)
  if ( btnRect->Down ) {
    if ( (oldPos2.X == oldPos1.X) && (oldPos2.Y == oldPos1.Y)) return;
  }
  if ( ( btnCircle->Down ) && ( oldRadius ==0 ) ) {
    return ;
  }

  // --- Add invisible marker(s) to the "Points" layer ---
  // Marker->Size = 0 hides them from the renderer; they exist only to
  // supply geometry for MakeBuffer (circle) or as placeholders (rectangle).
  ll = (TGIS_LayerVector *)( GIS->Get("Points") );
  ll->Lock();
  tmp = ll->CreateShape( TGIS_ShapeType::Point );
  tmp->Params->Marker->Size = 0;
  // Lock with Extent so the layer's extent is automatically updated
  tmp->Lock( TGIS_Lock::Extent );
  tmp->AddPart();

  if ( btnCircle->Down ) {
    // Convert the anchor screen pixel to a map coordinate (centre of circle)
    ptg = GIS->ScreenToMap(oldPos1);
    tmp = ll->CreateShape( TGIS_ShapeType::Point );
    tmp->Params->Marker->Size = 0;
    tmp->Lock( TGIS_Lock::Extent );
    tmp->AddPart();
    tmp->AddPoint( ptg );
    tmp->Unlock();
    ll->Unlock();
    // Convert a point that is exactly oldRadius pixels to the right of centre;
    // the map-unit X difference between ptg1 and ptg is the circle radius
    ptg1 = GIS->ScreenToMap( Point( oldPos1.X + oldRadius, Y ) );
  }

  if ( btnRect->Down ) {
    // Record the first corner as an invisible marker
    ptg = GIS->ScreenToMap(oldPos1);
    tmp->AddPoint( ptg );
    tmp->Unlock();
    // Record the second corner (drag endpoint) as a second invisible marker
    ll->CreateShape( TGIS_ShapeType::Point );
    tmp->Params->Marker->Size = 0;
    tmp->Lock( TGIS_Lock::Extent );
    tmp->AddPart();
    ptg = GIS->ScreenToMap(oldPos2);
    tmp->AddPoint( ptg );
    tmp->Unlock();
    ll->Unlock();
    // Re-convert the first corner for use during rectangle construction below
    ptg1 = GIS->ScreenToMap( oldPos1 );
  }

  // --- Rebuild the "Buffers" layer with the new selection shape ---
  ll = (TGIS_LayerVector *)(GIS->Get("Buffers") );
  // RevertShapes clears all shapes added since the last commit, effectively
  // resetting the layer to empty so previous selections are discarded
  ll->RevertShapes();

  if ( btnCircle->Down ) {
    // The map-unit diameter spans ptg1.X - ptg.X (right edge minus centre).
    // Dividing by 2 converts diameter to radius as expected by MakeBuffer.
    distance = ptg1.X - ptg.X ;
    tpl = new TGIS_Topology ;
    try {
      // MakeBuffer approximates a circle as a 32-vertex polygon around tmp.
      // The last parameter (True) closes the ring automatically.
      buf = tpl->MakeBuffer( tmp, distance/2, 32, True );
      // AddShape transfers ownership of the geometry to the Buffers layer
      buf = ll->AddShape( buf ) ;
    } __finally {
      delete tpl ;
    }
  }
  if ( btnRect->Down ) {
    // Build a closed rectangle polygon from the two diagonally opposite corners
    ptg2 = GIS->ScreenToMap( oldPos2 );
    buf = ll->CreateShape( TGIS_ShapeType::Polygon ) ;
    buf->AddPart() ;
    // Wind the four corners in order (top-left, top-right, bottom-right, bottom-left)
    buf->AddPoint( ptg1 ) ;
    buf->AddPoint( GisPoint( ptg1.X, ptg2.Y ) );
    buf->AddPoint( ptg2 );
    buf->AddPoint( GisPoint( ptg2.X, ptg1.Y ) );
  }

  // --- Perform the spatial query on the base Counties layer (Items->Items[0]) ---
  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;

  if (ll == NULL) {
    GIS->InvalidateWholeMap();
    return;
  }

  // Clear any previously selected features before the new selection pass
  ll->DeselectAll();

  GIS->InvalidateWholeMap() ;
  Memo1->Clear() ;
  Memo1->Lines->BeginUpdate() ;
  GIS->Lock() ;

  // FindFirst / FindNext iterate over shapes whose bounding box overlaps buf->Extent,
  // then applies RELATE_INTERSECT (a DE-9IM test) to confirm the geometries
  // actually share at least one point — not just overlapping bounding boxes.
  // check all shapes
  tmp = ll->FindFirst( buf->Extent, "", buf, RELATE_INTERSECT ) ;

  if (tmp == NULL) return;
  do {
    // This feature intersects the selection polygon: highlight it and record its name
    Memo1->Lines->Add( tmp->GetField( "name" ) ) ;
    tmp->IsSelected = true ;
    tmp = ll->FindNext();
  } while( tmp != NULL);
  GIS->Unlock();
  Memo1->Lines->EndUpdate();
}
//---------------------------------------------------------------------------

// GISPaintExtraEvent
// Called by the viewer during each repaint pass after all layers have been
// drawn.  Renders the rubber-band selection shape using the renderer's canvas
// primitives directly in screen space.
//
// Using PaintExtraEvent (rather than a Windows GDI overlay) ensures the
// feedback is composited correctly on top of the map without flickering and
// works regardless of whether hardware acceleration is active.
//
// The pen colour is randomised on each call to create an animated "marching
// ants" visual effect on the outline.
void __fastcall TForm1::GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode)
{
  TGIS_RendererAbstract  *rdr ;

  rdr = _renderer ;
  rdr->CanvasPen->Width   = 1 ;
  // Random colour creates the animated "marching ants" outline effect
  rdr->CanvasPen->Color   = TGIS_Color::FromBGR( Random( 0xFFFFFFFF ) ) ;
  rdr->CanvasPen->Style = TGIS_PenStyle::Solid ;
  // Clear brush so only the outline is drawn (no fill obscuring the map)
  rdr->CanvasBrush->Style = TGIS_BrushStyle::Clear ;

  if ( btnRect->Down ) {
    // Do not draw until the user has actually moved the cursor (zero-size guard)
    if ( (oldPos1.X == oldPos2.X) && (oldPos1.Y == oldPos2.Y) ) return;
    rdr->CanvasDrawRectangle( Rect( oldPos1.X, oldPos1.Y, oldPos2.X, oldPos2.Y) );
  }
  if ( btnCircle->Down ) {
    // CanvasDrawEllipse takes top-left corner X/Y, width, height in screen pixels.
    // Top-left is the centre offset by the radius on both axes.
    // RoundS(oldRadius/2) converts the pixel-space radius to the top-left offset.
    rdr->CanvasDrawEllipse( oldPos1.X - RoundS( oldRadius/2 ), oldPos1.Y - RoundS( oldRadius/2 ),
                            oldRadius, oldRadius);
  }
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
