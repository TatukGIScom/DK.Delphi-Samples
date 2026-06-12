//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * InMemory sample implementation — demonstrates creating and populating vector layers at runtime.
 *
 * Creates in-memory TGIS_LayerVector instances without reading from files, then dynamically adds
 * point, polyline, and polygon shapes with custom styling. Demonstrates symbol loading, rotation,
 * random colors, and shape animation.
 */
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "math.h"
#include "assert.h"
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

/* Button1Click
   Creates an in-memory vector layer with custom symbol styling.

   Steps:
   1. Create a new TGIS_LayerVector (no file backing; data exists only in memory).
   2. Load a custom symbol from CGM file for marker display.
   3. Set marker rotation (M_PI/2 = 90 degrees).
   4. Set negative marker size (-20) for size in screen pixels (scaled to zoom).
   5. Load a custom line symbol for polyline styling.
   6. Add the layer to the viewer and set a world extent.
   7. Fit the viewport to show the layer's extent. */
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  TGIS_LayerVector *ll ;

  /* Create a new in-memory layer with no file backing. */
  ll = new TGIS_LayerVector ;
  /* Load a custom marker symbol from a CGM graphics file (vector-based symbol). */
  ll->Params->Marker->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
  /* Rotate the marker symbol 90 degrees (M_PI/2 radians = 90 degrees). */
  ll->Params->Marker->SymbolRotate = M_PI/2 ;
  /* Set marker size to 20 screen pixels (negative values = screen pixels; positive = map units). */
  ll->Params->Marker->Size = -20 ;
  /* Load a custom symbol for polyline rendering. */
  ll->Params->Line->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\1301.cgm" ) ;
  /* Set line width to 5 screen pixels (negative values = screen pixels). */
  ll->Params->Line->Width = -5 ;
  /* Add the configured layer to the viewer so it becomes visible. */
  GIS->Add( ll ) ;
  /* Set the layer's geographic extent (world bounds: -180 to +180 lon, -90 to +90 lat). */
  ll->Extent = GisExtent( -180, -90, 180, 90 ) ;
  /* Fit the viewport to show the entire layer extent. */
  GIS->FullExtent() ;
  /* Disable the button after layer creation (it's only needed once). */
  Button1->Enabled = FALSE ;
  /* Show status message. */
  StatusBar1->SimpleText = " Layer created.";
}
//---------------------------------------------------------------------------

/* Button2Click
   Adds 101 random point shapes to the layer, each with random position, rotation, and color.

   Algorithm:
   1. Guard against adding points to an empty viewer.
   2. Loop 101 times to create individual point shapes.
   3. For each point:
      - Create a new TGIS_ShapeType::Point shape in the layer.
      - Assign a random rotation (0-360 degrees converted to radians).
      - Assign a random RGB color.
      - Lock shape extent (prevent extent recalc per point for performance).
      - Add a part (point shapes have one part with one point vertex).
      - Add a vertex at a random lat/lon coordinate (world bounds).
      - Unlock the shape.
   4. Redraw the map to display all new points. */
void __fastcall TForm1::Button2Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  /* Guard against clicking before creating a layer. */
  if ( GIS->IsEmpty ) {
    ShowMessage( "Create a layer first" ) ;
    return ;
  }

  /* Generate 101 random point shapes. */
  for (i=0; i<=100; i++) {
    /* Create a new point shape in the layer. */
    shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Point ) ;
    /* Assign a random rotation angle (0-360 degrees, converted to radians). */
    shp->Params->Marker->SymbolRotate = DegToRad( 1.0*random( 360 ) ) ;
    /* Create a random RGB colour (red << 16 | green << 8 | blue). */
    shp->Params->Marker->Color = TGIS_Color::FromRGB((random(256) << 16) + (random( 256 ) <<  8) + random ( 256 ) );
    /* Set outline colour to match the fill colour. */
    shp->Params->Marker->OutlineColor = shp->Params->Marker->Color ;
    /* Lock shape extent to prevent recalculating bounds after each vertex (improves performance). */
    shp->Lock( TGIS_Lock::Extent );
    /* Add a part to the shape (point shapes have one part). */
    shp->AddPart() ;
    /* Add a vertex at random lat/lon (global extent: -180 to +180 lon, -90 to +90 lat). */
    shp->AddPoint( GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) );
    /* Unlock shape and recalculate extent based on the added vertex. */
    shp->Unlock();
  }
  /* Repaint the map to display all newly added points. */
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

/* Button3Click
   Creates a single polyline (arc) shape with 21 random vertices.

   Algorithm:
   1. Guard against an empty viewer.
   2. Create a new TGIS_ShapeType::Arc (polyline) shape.
   3. Lock the shape's extent to prevent mid-construction updates.
   4. Add a part (polylines have one or more parts; each part is a connected sequence of vertices).
   5. Loop 21 times, adding random vertices.
   6. Unlock the shape.
   7. Redraw the map. */
void __fastcall TForm1::Button3Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  /* Guard against clicking before creating a layer. */
  if ( GIS->IsEmpty ) {
    ShowMessage( "First create Layer" ) ;
    return ;
  } ;

  /* Verify the layer exists. */
  assert( GIS->Items->Count > 0 ) ;
  /* Create a new polyline (Arc = arcline / polyline geometry type) shape. */
  shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Arc );
  /* Lock extent to defer recalculation until all vertices are added. */
  shp->Lock( TGIS_Lock::Extent ) ;
  /* Add a part to the shape (polylines have one or more disconnected parts). */
  shp->AddPart() ;
  /* Add 21 random vertices to form the polyline path. */
  for (i=0; i<=20; i++) {
    /* Add a vertex at random lat/lon coordinates. */
    shp->AddPoint( GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) );
  }
  /* Unlock shape and recalculate its extent based on all vertices. */
  shp->Unlock() ;
  /* Repaint the map to display the new polyline. */
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/* Button4Click
   Creates a blue point at the origin (0,0) and animates it by moving it in a northeast direction.

   Algorithm:
   1. Guard against an empty viewer.
   2. Create a new point shape at (0,0).
   3. Style it blue with a 20-pixel size.
   4. Loop 91 times, moving the point 2 degrees east and 1 degree north per step.
   5. Sleep 10 milliseconds between moves and process pending UI events to keep the UI responsive.
   6. This demonstrates shape repositioning without recreating the geometry. */
void __fastcall TForm1::Button4Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  /* Guard against clicking before creating a layer. */
  if ( GIS->IsEmpty ) {
    ShowMessage( "First create Layer" ) ;
    return ;
  } ;

  /* Verify the layer exists. */
  assert( GIS->Items->Count > 0 ) ;
  /* Create a new point shape. */
  shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Point ) ;
  /* Lock extent to defer recalculation until all operations complete. */
  shp->Lock( TGIS_Lock::Extent ) ;
  /* Add a part (point shapes have one part). */
  shp->AddPart() ;
  /* Add a vertex at the world origin. */
  shp->AddPoint( GisPoint( 0 , 0 ) );

  /* Style the point blue. */
  shp->Params->Marker->Color = TGIS_Color::Blue ;
  shp->Params->Marker->OutlineColor = TGIS_Color::Blue ;
  /* Set marker size to 20 screen pixels. */
  shp->Params->Marker->Size = -20 ;

  /* Unlock and repaint to display the initial point. */
  shp->Unlock() ;
  shp->Invalidate();

  /* Animate the point by moving it northeast in 91 steps.
     Each step moves the point 2 degrees east (i * 2 longitude) and 1 degree north (i latitude). */
  for (i=0; i<=90; i++) {
    /* Reposition the shape without recreating its geometry. The third parameter (0) means the first part. */
    shp->SetPosition( GisPoint( i * 2, i ), NULL, 0 ) ;
    /* Sleep 10 ms to control animation speed. */
    Sleep( 10 ) ;
    /* Process pending UI events (redraws, mouse clicks, etc.) to keep the interface responsive. */
    Application->ProcessMessages() ;
  }
}
//---------------------------------------------------------------------------

