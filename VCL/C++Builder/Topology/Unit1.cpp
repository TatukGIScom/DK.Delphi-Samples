//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Topology Sample – Demonstrates polygon set-algebra operations using TGIS_Topology.
//
// This sample loads two overlapping polygon shapes (A and B) from a shapefile
// and allows the user to compute the following topological combinations:
//
//   A + B   : Union            – area covered by either A or B (or both)
//   A * B   : Intersection     – area covered by both A and B
//   A - B   : Difference       – area in A but not in B
//   B - A   : Difference       – area in B but not in A
//   A xor B : SymDifference    – area in A or B but not in both (exclusive OR)
//
// Results are displayed in a separate in-memory TGIS_LayerVector rendered
// in red with 50% transparency so the original shapes remain visible.
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

/**
 * FormCreate
 * Initialises the map viewer, loads the topology sample shapefile,
 * extracts polygons A and B as editable copies, and creates a transparent
 * output layer for displaying topology results.
 *
 * Lock/Unlock brackets suspend viewer repaints during batch setup to avoid
 * flickering and to ensure consistent state before the first paint.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll ;

  // Create the topology engine (stateless; can be reused for multiple calls)
  topologyObj = new TGIS_Topology ;

  GIS->Lock();  // Suspend repaints while setting up layers

  // Open the bundled topology sample shapefile (contains two overlapping polygons)
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology.shp", true ) ;

  // Retrieve the first (and only) vector layer just loaded
  ll = (TGIS_LayerVector *)(GIS->Items->Items[0]) ;
  if ( ll == NULL ) return ;

  // MakeEditable returns a detached, editable copy of each shape.
  // This is required so the topology engine can safely read the geometry
  // without modifying the underlying file-backed layer.
  shpA = (TGIS_ShapePolygon *)( ll->GetShape( 1 )->MakeEditable() );
  if ( shpA == NULL ) return ;

  shpB = (TGIS_ShapePolygon *)( ll->GetShape( 2 )->MakeEditable() );
  if ( shpB == NULL ) return ;

  // Create a blank in-memory layer to hold the topology result.
  // The layer sits on top of the source layer in the viewer stack.
  layerObj = new TGIS_LayerVector ;
  layerObj->Name = "output" ;
  layerObj->Transparency = 50 ;               // 50% transparent so source shows through
  layerObj->Params->Area->Color  = TGIS_Color::Red ;  // Result polygon fill colour

  GIS->Add( layerObj ) ;
  GIS->Unlock();       // Resume painting
  GIS->FullExtent() ;  // Zoom to fit all layers
}
//---------------------------------------------------------------------------

/**
 * btnAplusBClick – Union (A + B)
 * The resulting shape covers all area contained in either polygon A or B,
 * merging any overlapping regions into a single contiguous polygon.
 */
void __fastcall TForm1::btnAplusBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  // Remove the previous result before computing a new one
  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Union, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;  // Transfer result into the output layer
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;  // Trigger a full repaint
}
//---------------------------------------------------------------------------

/**
 * btnAmultBClick – Intersection (A * B)
 * The resulting shape covers only the area simultaneously inside both
 * polygon A and polygon B.
 */
void __fastcall TForm1::btnAmultBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Intersection, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

/**
 * btnAminusBClick – Difference A minus B (A - B)
 * The result is the area of polygon A with the overlap of B removed.
 * The first Combine() argument is the "base" shape; the second is subtracted.
 */
void __fastcall TForm1::btnAminusBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Difference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

/**
 * btnBminusAClick – Reverse Difference B minus A (B - A)
 * Identical logic to A-B but with operands swapped so that the area of A
 * is subtracted from the area of B.
 */
void __fastcall TForm1::btnBminusAClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  // Note: shpB is the first (base) argument; shpA is what gets subtracted
  tmp = topologyObj->Combine( shpB, shpA, TGIS_TopologyCombineType::Difference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/**
 * btnAxorBClick – Symmetrical Difference (A xor B)
 * The result covers area belonging to exactly one of the two polygons –
 * equivalent to Union minus Intersection, or a logical XOR of the two areas.
 */
void __fastcall TForm1::btnAxorBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::SymmetricalDifference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
