//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * CuttingPolygon sample — demonstrates how to clip a raster (pixel) layer's rendering to within
 * an arbitrary polygon boundary using TGIS_LayerPixel.CuttingPolygon.  On form create, a world
 * raster image and an in-memory vector layer with a triangular polygon are added to the viewer.
 * Clicking "Do cutting" assigns that polygon as the raster layer's CuttingPolygon so only the
 * region inside the polygon is rendered.
 */
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
/* Assigns the "shape" layer's first polygon as the raster layer's CuttingPolygon (converting to
   the raster's coordinate system), then hides the vector layer. */
void __fastcall TForm1::btnCuttingClick(TObject *Sender)
{
  /* Get the raster layer (the first/only pixel layer in the map). */
  lp = (TGIS_LayerPixel *)( (GIS->Items)->Items[0] );;
  /* Fetch the polygon from the vector layer and convert it to the raster's coordinate system.
     CreateCopyCS creates a copy of the shape geometry transformed to the target CS
     (CuttingPolygon must be in the same coordinate system as the raster layer). */
  lp->CuttingPolygon = ( TGIS_ShapePolygon *)( ll->GetShape( 1 )->CreateCopyCS( lp->CS ) ) ;
  /* Hide the clipping polygon layer so only the raster with the clipping effect is visible. */
  ll->Active = False ;
  /* Repaint the map to apply the clipping effect. */
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/* Switches the viewer to Zoom mode. */
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;
}
//---------------------------------------------------------------------------

/* Opens the world raster image, creates an in-memory vector layer named "shape", and adds a
   triangular polygon shape to it. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_Shape *shp ;

  /* Load the base world raster image (satellite imagery). */
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\VisibleEarth\\world_8km.jpg");
  /* Create an in-memory vector layer to hold the clipping polygon. */
  ll = new TGIS_LayerVector ;
  ll->Name = "shape" ;
  GIS->Add( ll );

  /* Create a new polygon shape in the vector layer. */
  shp = ll->CreateShape( TGIS_ShapeType::Polygon);
  /* Lock the shape so the spatial extent updates as we add points. */
  shp->Lock( TGIS_Lock::Extent ) ;
  /* Start a new polygon part (polygon can have multiple parts for complex shapes). */
  shp->AddPart() ;
  /* Add three vertices to form a triangle (in geographic coordinates). */
  shp->AddPoint( GisPoint( -5, 8 ) );
  shp->AddPoint( GisPoint( 40,2 ) );
  shp->AddPoint( GisPoint( 20, -20 ) ) ;
  /* Unlock the shape to finalize it. */
  shp->Unlock();
}
//---------------------------------------------------------------------------

