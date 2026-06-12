//---------------------------------------------------------------------------
// HelloDK - TatukGIS Developer Kernel introductory sample (C++Builder / VCL).
//
// Demonstrates the core DK workflow:
//   1. Opening a vector Shapefile into the map viewer.
//   2. Switching the viewer interaction mode: Zoom / Drag / Select.
//   3. Creating an in-memory editable vector layer with a transparent polygon style.
//   4. Building a polygon shape programmatically by adding explicit vertices.
//   5. Click-to-select a feature using screen-to-map coordinate conversion
//      and spatial proximity search (GIS->Locate).
//   6. Spatial containment query using the DE-9IM matrix string "T*****FF*"
//      combined with a SQL WHERE filter to find world features whose label
//      starts with 's' and that are geometrically contained within the
//      user-created polygon.
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"

// Helper macro: rounds a floating-point value to the nearest integer
#define round(a) int((a)+0.5)
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlAttributes"
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisControlNorthArrow"
#pragma link "VCL.GisControlScale"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------

// "Open project" button click event.
// Opens the WorldDCW world Shapefile and loads it into the viewer.
// The viewer auto-zooms to the full extent of the loaded data.
void __fastcall TForm1::btnOpenClick(TObject *Sender)
{
  GIS->Open( "..\\data\\world.shp");
}
//---------------------------------------------------------------------------

// "Zooming" button click event.
// Switches the viewer to Zoom mode. In this mode the left mouse button
// draws a rubber-band rectangle to zoom into a region; the right button
// zooms out.
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;
}
//---------------------------------------------------------------------------

// "Dragging" button click event.
// Switches the viewer to Drag mode, allowing the user to pan the map
// by clicking and dragging with the mouse.
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------

// "Selecting" button click event.
// Switches the viewer to Select mode. In this mode, mouse clicks on the map
// are handled by GISTapSimpleEvent to toggle shape selection.
void __fastcall TForm1::btnSelectClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------

// "Create Shape" button click event.
// Creates a new in-memory TGIS_LayerVector named "edit layer", gives it a
// transparent fill with a blue outline, then adds a single quadrilateral
// polygon to it. This layer is not backed by a file.
void __fastcall TForm1::btnCreateShapeClick(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVector *lv ;

  // Guard: if the edit layer already exists, do nothing (idempotent)
  ll = ( TGIS_LayerVector *)( GIS->Get( "edit layer" ) );
  if( ll != NULL ){
	return;
  }

  // Create a new in-memory vector layer and register it with the viewer
  ll = new TGIS_LayerVector();
  ll->Name = "edit layer" ;
  // Inherit the viewer's coordinate system so coordinates are interpreted correctly
  ll->CS = GIS->CS ;

  // Style: transparent fill (Clear pattern) with a solid blue outline,
  // so the underlying world layer remains visible through the polygon
  ll->Params->Area->OutlineColor = TGIS_Color::Blue ;
  ll->Params->Area->Pattern = TGIS_BrushStyle::Clear ;

  // Register the layer with the viewer; it will appear on top of existing layers
  GIS->Add( ll );

  // Create a new Polygon shape inside the layer
  shp = ll->CreateShape( TGIS_ShapeType::Polygon ) ;

  // Lock(Extent) batches vertex additions so the bounding box is recalculated
  // only once when Unlock is called, improving performance for bulk edits
  shp->Lock( TGIS_Lock::Extent ) ;

  // AddPart starts the first ring of the polygon; a shape can have multiple
  // parts (e.g., islands or holes in a multi-polygon)
  shp->AddPart() ;

  // Add the four corner vertices of the polygon (coordinates in the map's CS)
  shp->AddPoint( TGIS_Utils::GisPoint( 10, 10 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 10, 80 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 80, 90 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 90, 10 ) );

  // Unlock finalises the shape geometry: recalculates extents and closes
  // the polygon ring automatically if the first and last points differ
  shp->Unlock() ;

  // Redraw the entire map canvas to show the newly added polygon
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

// "Find Shape" (Relation) button click event.
// Uses DE-9IM (Dimensionally Extended 9-Intersection Model) spatial
// relationship to find all world features that are fully contained inside
// the polygon created by btnCreateShapeClick.
//
// The DE-9IM matrix "T*****FF*" encodes the "contains" relationship:
//   - 'T' at position [0]: interiors must intersect (non-empty)
//   - "FF" at positions [6,7]: the query shape's boundary and exterior
//     must NOT intersect the target shape's interior - i.e. the target
//     lies entirely within the query polygon.
//
// An additional SQL LIKE filter restricts results to features whose
// 'label' field starts with the letter 's'.
//
// Note: C++ requires an explicit TGIS_LayerVectorEnumerator loop pattern
// instead of a range-for, because the DK enumerator type is not a
// standard C++ iterator.
void __fastcall TForm1::btnRelationClick(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_Shape *selshp ;
  TGIS_LayerVector *lv ;
  TGIS_Shape *tmpshp ;
  TGIS_LayerVectorEnumerator *loop1 ;

  // The edit layer must exist (created by btnCreateShapeClick) to provide
  // the selection polygon; exit early if it has not been created yet
  ll = ( TGIS_LayerVector *)( GIS->Get( "edit layer") );
  if( ll == NULL ){
	return ;
  }

  // Retrieve the first (and only) shape from the edit layer to use as
  // the spatial query boundary
  selshp = ll->GetShape(1); // just a first shape from the layer

  // MakeEditable pins the shape into memory so it survives the subsequent
  // iteration; file-backed shapes are otherwise evicted from cache
  selshp = selshp->MakeEditable() ;

  // Retrieve the world layer - its name is derived from the filename ('world')
  lv = ( TGIS_LayerVector *)( GIS->Get( "world" ) );

  // Clear any previous selection on the world layer before applying the new one
  lv->DeselectAll();

  // Lock the viewer to batch all selection redraws into a single repaint
  GIS->Lock();

  // Loop over all shapes in the world layer whose bounding box overlaps
  // selshp->Extent, whose 'label' field matches the SQL pattern 's%', AND
  // whose DE-9IM relationship with selshp satisfies "T*****FF*" (Contains).
  // C++Builder requires the explicit GetEnumerator / MoveNext / Current pattern.
  loop1 = lv->Loop( selshp->Extent, "label LIKE 's%'", selshp, "T*****FF*" )->GetEnumerator();
  while (loop1->MoveNext()) {
	tmpshp = loop1->Current ;
	tmpshp->IsSelected = True ;
  }

  // Unlock releases the batched repaint and triggers a single screen refresh
  GIS->Unlock();

  // Force a full map redraw to show the newly selected shapes highlighted
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

// TapSimple event handler - fired on every single mouse click on the viewer.
// When the viewer is in Select mode, this converts the click position from
// screen pixels to map coordinates, finds the nearest shape within a
// tolerance of 5 pixels, and toggles its selection state.
//
// Parameters:
//   X, Y  - screen pixel coordinates of the mouse click (top-left origin)
void __fastcall TForm1::GISTapSimpleEvent(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Shape *shp ;
  TGIS_Point ptg ;
  Double precision ;
  TGIS_LayerVector *lv ;

  // Ignore taps when the viewer is not in Select mode
  if ( GIS->Mode != TGIS_ViewerMode::Select ){
	return;
  }

  // Get the world layer to manage its selection state
  lv = ( TGIS_LayerVector *)( GIS->Get("world") );
  if (lv == NULL) {
	return;
  }

  // Clear any previously selected shapes before applying the new selection
  lv->DeselectAll();

  // Convert screen pixel coordinates to geographic map coordinates.
  // ScreenToMap accounts for the current zoom level and pan offset.
  ptg = GIS->ScreenToMap( Point( round(X), round(Y) ) );

  // Compute the hit-test tolerance: 5 screen pixels expressed in map units.
  // Dividing by Zoom converts pixels to the map's coordinate unit.
  precision = 5 / GIS->Zoom ;

  // Search all layers for the topmost shape within 'precision' of the click point
  shp = ( TGIS_Shape *)( GIS->Locate( ptg, precision ) );

  // If no shape was found near the click point, do nothing
  if( shp == NULL ){
   return ;
  }

  // Toggle selection: clicking a selected shape deselects it, and vice versa
  shp->IsSelected = !(shp->IsSelected) ;

  // Repaint the map to reflect the updated selection highlight
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
