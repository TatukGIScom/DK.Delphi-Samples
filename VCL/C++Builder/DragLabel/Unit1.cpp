//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  DragLabel sample - demonstrates how to construct interactively draggable
//  feature labels on a GIS map.
//
//  Design pattern:
//    "realpoints" layer - visible CGM-symbol markers that represent the actual
//                         geographic positions of ships.  These do not move by
//                         user interaction (only by the Animate button).
//    "sidekicks" layer  - invisible ghost point shapes whose UIDs correspond
//                         one-to-one with realpoints.  The user drags these
//                         freely; they carry the floating label text.
//
//  PaintShapeLabelEvent (doLabelPaint) is fired by the viewer for each
//  sidekick during a repaint.  It converts both geographic positions to screen
//  pixels with MapToScreen, draws a blue leader line on the renderer canvas,
//  then calls DrawLabel to render the label text at the sidekick's location.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
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

// synchroMove
// Moves both the given real-point shape (_shp) and its matching sidekick by
// (_x, _y) map units in a single step.  Used by Button1Click to animate a
// shape across the map and could equally be called from a timer.
//
// The sidekick is located by matching its UID to _shp->Uid - the two layers
// maintain parallel arrays of shapes with identical UIDs.
//
// ex is populated with the bounding extent of both shapes to allow selective
// map invalidation if needed; currently the viewer's built-in change
// detection handles invalidation.
void TForm1::synchroMove( TGIS_Shape *_shp, int _x, int _y )
{
  TGIS_LayerVector *ll ;
  TGIS_Shape  *shp  ;
  TGIS_Point   ptgA ;
  TGIS_Point   ptgB ;
  TGIS_Extent  ex   ;

  // Shift the real point
  ptgA = _shp->GetPoint( 0, 0 ) ;
  ptgA.X = ptgA.X + _x ;
  ptgA.Y = ptgA.Y + _y ;
  _shp->SetPosition( ptgA , NULL, 0 ) ;

  // Locate and shift the matching sidekick by the same displacement
  // so the leader line length is preserved during animation.
  ll = (TGIS_LayerVector *)( GIS->Get("sidekicks") ) ;
  shp = ll->GetShape( _shp->Uid ) ;
  ptgB = shp->GetPoint( 0, 0 ) ;
  ptgB.X = ptgB.X + _x ;
  ptgB.Y = ptgB.Y + _y ;
  shp->SetPosition( ptgB , NULL, 0 ) ;

  // Build bounding extent for optional selective invalidation
  ex.XMin = Min( ptgA.X, ptgB.X ) ;
  ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax = Max( ptgA.X, ptgB.X ) ;
  ex.YMax = Max( ptgA.Y, ptgB.Y ) ;
}

// Button1Click - "Animate" button handler
// Runs a 90-step animation loop moving shape UID=5 and its sidekick by
// (2, 1) map units per step with a 100 ms delay between steps.
// ProcessMessages keeps the UI responsive during the loop.
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp  ;

  shp = ((TGIS_LayerVector *)( GIS->Get("realpoints") ))->GetShape( 5 ) ;
  for (i=0; i<=90; i++) {
    synchroMove( shp, 2, 1 ) ;
    Sleep( 100 ) ;
    Application->ProcessMessages() ;
  } ;
}

// doLabelPaint - PaintShapeLabelEvent callback
// Fired by the "sidekicks" layer for each sidekick shape during a repaint.
//
// _shape is the sidekick being painted.  Its Uid matches the corresponding
// realpoint in the "realpoints" layer, enabling the UID-based lookup.
//
// Steps:
//   1. Look up the matching realpoint shape by UID.
//   2. Call MapToScreen on both geographic positions to get screen pixel
//      coordinates.  ptA is the real location; ptB is the label anchor.
//   3. Configure the abstract renderer pen and draw the blue leader line.
//   4. Copy the "name" attribute to the sidekick's label value and call
//      DrawLabel so TatukGIS renders the text using the layer's label style.
void __fastcall  TForm1::doLabelPaint( TObject * _sender, TGIS_Shape * _shape )
{
  TPoint ptA, ptB ;              // screen-pixel coordinates
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;              // matching realpoint shape
  TGIS_RendererAbstract *rdr ;

  // Find the real-point layer and retrieve the shape with the same UID
  ll = (TGIS_LayerVector *)( GIS->Get("realpoints") );
  shp = ll->GetShape( _shape->Uid ) ;

  // MapToScreen converts geographic (projected) coordinates to screen pixels
  // relative to the viewer's top-left corner.
  ptA = _shape->Viewer->Ref->MapToScreen( shp->GetPoint( 0, 0 ) ) ;    // real point
  ptB = _shape->Viewer->Ref->MapToScreen( _shape->GetPoint( 0, 0 ) ) ; // label anchor

  // Draw the connecting leader line using the abstract renderer.
  // TGIS_RendererAbstract provides a hardware-agnostic drawing API.
  rdr = GIS->Renderer ;
  rdr->CanvasPen->Color = TGIS_Color::Blue ;
  rdr->CanvasPen->Style = TGIS_PenStyle::Solid;
  rdr->CanvasPen->Width = 1 ;
  rdr->CanvasDrawLine( ptA.x, ptA.y, ptB.x, ptB.y );

  // Set the label text from the real feature's "name" field and render it.
  _shape->Params->Labels->Value = shp->GetField("name") ;
  _shape->DrawLabel() ;
}

//---------------------------------------------------------------------------

// GISMouseDown - begins a label drag operation
// Looks for a sidekick near the clicked position and, if found, initialises
// the editor's tracking state.  We use MouseBegin manually instead of
// switching GIS->Mode to Edit so that normal pan/zoom is not disturbed.
//
// The Locate tolerance (100 / GIS->Zoom) converts 100 screen pixels to map
// units, giving a constant pick radius at any zoom level.
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_LayerVector  *ll  ;
  TGIS_Shape        *shp ;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint)  return ;

  // Search for a sidekick at the clicked position
  ll = (TGIS_LayerVector *)( GIS->Get("sidekicks") );
  if (!GIS->InPaint)
    shp = ll->Locate( GIS->ScreenToMap( Point(X,Y) ), 100/GIS->Zoom, TRUE ) ;
  else
    return;
  currShape = shp ;

  if ( currShape == NULL ) return ;

  // Initiate editor drag tracking (without switching viewer mode globally)
  GIS->Editor->MouseBegin( Point(X,Y), True );

}
//---------------------------------------------------------------------------

// GISMouseUp - ends the current drag
// Clearing currShape stops GISMouseMove from repositioning any shape.
void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  currShape = NULL ;
}
//---------------------------------------------------------------------------

// GISMouseMove - repositions the tracked sidekick shape under the cursor
//
// Two bounding extents (pre- and post-move) are computed around the sidekick
// and its matching realpoint.  These can be passed to GIS->InvalidateExtent
// to repaint only the dirty region; currently the SetPosition call itself
// triggers the viewer repaint.
//
// ScreenToMap converts the mouse pixel position to geographic map coordinates.
// GisIsPointInsideExtent prevents the label from being dragged outside the
// map's valid extent.
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_LayerVector  *ll  ;
  TGIS_Shape        *shp ;
  TGIS_Point  ptgA ;
  TGIS_Point  ptgB ;
  TGIS_Extent ex   ;

  if ( GIS->IsEmpty ) return;
  if ( currShape == NULL ) return;

  // Pre-move extent for the sidekick + real point pair
  ptgA = currShape->GetPoint( 0, 0 ) ;
  ll  = (TGIS_LayerVector *)( GIS->Get("realpoints") );
  shp = ll->GetShape( currShape->Uid ) ;
  ptgB = shp->GetPoint( 0, 0 ) ;
  ex.XMin = Min( ptgA.X, ptgB.X ) ;
  ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax = Max( ptgA.X, ptgB.X ) ;
  ex.YMax = Max( ptgA.Y, ptgB.Y ) ;

  // Convert mouse pixel position to map coordinates and move the sidekick
  ptgA = GIS->ScreenToMap( Point(X,Y) ) ;
  if ( GisIsPointInsideExtent( ptgA, GIS->Extent ) )
    currShape->SetPosition( ptgA, NULL, 0 );

  // Post-move extent for optional selective repaint
  ptgA = currShape->GetPoint( 0, 0 ) ;
  ll  = (TGIS_LayerVector *)( GIS->Get("realpoints") );
  shp = ll->GetShape( currShape->Uid ) ;
  ptgB = shp->GetPoint( 0, 0 ) ;
  ex.XMin = Min( ptgA.X, ptgB.X ) ;
  ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax = Max( ptgA.X, ptgB.X ) ;
  ex.YMax = Max( ptgA.Y, ptgB.Y ) ;
}
//---------------------------------------------------------------------------

// FormCreate - builds the two-layer data model and populates 21 random ships.
//
// "realpoints": CachedPaint=False so the viewer redraws moving shapes each
//   frame.  A CGM symbol is loaded and a "name" string field is added.
//
// "sidekicks": Invisible markers (Size=0), centred label position.
//   PaintShapeLabelEvent is wired to doLabelPaint.
//   Allocator=False disables the auto label-placement algorithm so labels
//   stay exactly at the sidekick's position.
//
// For each of the 21 points:
//   - A realpoint is created at a random world coordinate.
//   - A sidekick is created at the same position plus a 15-pixel offset in
//     map units (15 / Zoom) so it starts displaced from the symbol.
//   - Both shapes are created in the same UID-counter sequence so their UIDs
//     match, enabling the lookup in doLabelPaint.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll  ;
  int                i   ;
  TGIS_Shape        *shp ;
  TGIS_Point         ptg ;

  // --- "realpoints" layer ---
  ll = new TGIS_LayerVector ;
  // SymbolList().Prepare caches the CGM symbol for fast repeated rendering.
  ll->Params->Marker->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
  ll->Name = "realpoints" ;
  ll->CachedPaint = False ; // disable tile cache so moving shapes are always redrawn

  GIS->Add( ll ) ;
  ll->AddField( "name", TGIS_FieldType::String, 100, 0 );
  ll->Extent = GisExtent( -180, -180, 180, 180 ) ; // world-spanning extent

  // --- "sidekicks" layer ---
  ll = new TGIS_LayerVector ;
  ll->Name = "sidekicks" ;
  ll->Params->Marker->Size = 0 ;              // invisible - no marker drawn
  ll->Params->Labels->Position <<  TGIS_LabelPosition::MiddleCenter ;
  ll->CachedPaint = False ;

  GIS->Add( ll ) ;
  // Wire the custom label painter for leader lines + label rendering
  ll->PaintShapeLabelEvent = doLabelPaint ;
  // Keep labels at the exact sidekick position (no overlap avoidance)
  ll->Params->Labels->Allocator = False ;

  GIS->FullExtent() ;

  // --- Populate both layers with random ship positions ---
  for (i=0; i<=20; i++) {
    ptg = GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) ;

    // Real (visible) point
    shp = ((TGIS_LayerVector *)( GIS->Get("realpoints") ) )->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Extent ) ; // freeze extent during shape construction
    shp->AddPart() ;
    shp->AddPoint( ptg );
    shp->Params->Marker->SymbolRotate = shp->Uid ; // unique rotation per ship
    shp->Params->Marker->Size = 250 ;
    shp->Params->Marker->Color = TGIS_Color::FromRGB((random(256) << 16) + (random( 256 ) <<  8) + random ( 256 ) );

    shp->SetField( "name", Format( "Ship: %d", OPENARRAY(TVarRec, ( shp->Uid) ) ) );
    shp->Unlock() ;

    // Matching sidekick - positioned 15 screen-pixels (in map units) away
    shp = ((TGIS_LayerVector *)( GIS->Get("sidekicks") ) )->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Extent ) ;
    shp->AddPart() ;

    // 15 / Zoom converts 15 pixels to the equivalent map-unit distance
    ptg.X = ptg.X + 15/GIS->Zoom ;
    ptg.Y = ptg.Y + 15/GIS->Zoom ;
    shp->AddPoint( ptg );
    shp->Unlock() ;
  }

  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------


