/*
 * DataSet sample — demonstrates TGIS_DataSet as a live bridge between a GIS vector layer
 * and a data-aware grid (TDBGrid).
 *
 * Loads the California Counties shapefile, opens a TGIS_DataSet on the layer, and binds it
 * via TDataSource to a TDBGrid.  Scrolling the grid fires GIS_DataSet1AfterScroll which pans
 * and zooms the viewer to the selected county's extent.
 */
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

/* Pans and zooms the viewer to the county that was just scrolled to in the dataset. */
void __fastcall TForm1::GIS_DataSet1AfterScroll(TDataSet *DataSet)
{
  TGIS_Shape *shp ;

  /* Check if a valid shape is selected in the dataset. */
  if ( GIS_DataSet1->ActiveShape ) {
    /* Lock the viewer to prevent rendering updates during viewport changes. */
    GIS->Lock() ;
      /* Set the visible extent to the current shape's bounds (pan to the county). */
      GIS->VisibleExtent = GIS_DataSet1->ActiveShape->Extent ;
      /* Zoom out slightly (0.8x) to show some context around the selected county. */
      GIS->Zoom = GIS->Zoom * 0.8 ;
    /* Unlock the viewer to allow rendering with the new viewport. */
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------

/* Loads the California Counties shapefile, opens the DataSet on the layer, and binds it to the grid. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  /* Load the California counties shapefile into the viewer. */
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp", TRUE ) ;
  /* Create a DataSet bridge between the loaded layer and the data-aware grid (TDBGrid).
     DataSet provides two-way synchronization:
     - Grid scrolling updates GIS viewport via AfterScroll event
     - GIS feature selection can update grid selection
     The extent parameter defines the initial visible area for the dataset. */
  GIS_DataSet1->Open( (TGIS_LayerVector *)( GIS->Items->Items[0] ), GIS->Extent ) ;
}
//---------------------------------------------------------------------------
