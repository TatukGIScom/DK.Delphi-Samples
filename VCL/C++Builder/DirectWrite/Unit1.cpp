//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * DirectWrite sample - demonstrates five sequential low-level write techniques on TGIS_LayerSHP:
 * Build (AddShape loop + SaveData), ImportLayerEx (spatial CONTAINS filter), MergeLayerEx
 * (DISJOINT filter), TGIS_LayerVectorDirectWriteHelper (sequential high-performance write), and
 * TGIS_LayerVectorMergeHelper (batch-commit write).  Buttons unlock in sequence; output files go
 * into a numbered Shapes{n} directory.
 */
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
/* Creates a new SHP layer via Build(), opens the cities source, copies structure and coordinate
   system, loops all shapes with AddShape, then saves data. */
void __fastcall TForm1::btnBuildClick(TObject *Sender)
{
  TGIS_LayerSHP *lv ;
  TGIS_LayerSHP *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVectorEnumerator *loop1 ;

  /* Close any previously opened layers. */
  GIS->Close();

  /* Technique 1: Build + AddShape loop. Create a new shapefile layer. */
  lv = new TGIS_LayerSHP ;

  try{
      /* Build creates a new empty shapefile with:
         - file path for output
         - initial extent (can be updated as shapes are added)
         - shape type (Point, Polyline, Polygon, etc.)
         - dimension type (XY, XYZ, XYM, XYZM) */
      lv->Build( ( "Shapes" + IntToStr( number ) + "\\build.shp" ),
                   GisExtent( -180, -90, 180, 90 ),
                   TGIS_ShapeType::Point,
                   TGIS_DimensionType::XY
               );
      lv->Open() ;

      /* Open the source cities layer to copy from. */
      ll = new TGIS_LayerSHP ;
      try {
        ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
        ll->Open() ;
        int cnt = ll->Items->Count ;
        /* Copy the field structure (name, type, width) from source to destination. */
        lv->ImportStructure( ll ) ;
        /* Copy the coordinate system from source so geometry is compatible. */
        lv->CS = ll->CS ;
        /* Iterate all shapes from the source layer and add them to the new layer. */
        loop1 = ll->Loop()->GetEnumerator();
        while (loop1->MoveNext()) {
          lv->AddShape( loop1->Current, True);
        };
      }
      __finally {
        delete loop1 ;
        delete ll ;
      }
      /* Flush all pending writes to disk and finalize the shapefile. */
      lv->SaveData() ;
  } catch(...) {

  }

  /* Display the newly created layer in the viewer. */
  GIS->Add( lv ) ;
  GIS->FullExtent() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

/* Imports a spatially filtered subset of cities using ImportLayerEx with a CONTAINS WKT polygon
   (European bounding box); the imported layer is displayed in green. */
void __fastcall TForm1::btnImportLayerClick(TObject *Sender)
{
  TGIS_LayerSHP *ll ;
  TGIS_LayerSHP *lv ;
  TGIS_Shape *shp ;

  GIS->Close();

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
  GIS->Add( ll );

  shp = TGIS_GeometryFactory::GisCreateShapeFromWKT(
        "POLYGON(( 7.86 56.39, 31.37 56.39, 31.37 39.48, 7.86 39.48, 7.868 56.39 ))"
  ) ;

  lv = new TGIS_LayerSHP ;
  lv->Path = "Shapes" + IntToStr( number ) + "\\imported.shp" ;
  lv->CS = ll->CS ;
  lv->ImportLayerEx( ll, ll->Extent, TGIS_ShapeType::Unknown, "",
                     shp, TGIS_Utils::GIS_RELATE_CONTAINS(), False );

  delete shp ;
  GIS->Add( lv );
  lv->Params->Marker->Color = TGIS_Color::Green;
  GIS->FullExtent() ;
  GIS->VisibleExtent = lv->Extent ;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/* Merges cities outside the European polygon using MergeLayerEx with a DISJOINT relation;
   the merged layer is displayed in green. */
void __fastcall TForm1::btnMergeLayerClick(TObject *Sender)
{
  TGIS_LayerSHP *ll ;
  TGIS_LayerSHP *lv ;
  TGIS_Shape *shp ;

  GIS->Close();

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
  GIS->Add( ll );

  shp = TGIS_GeometryFactory::GisCreateShapeFromWKT(
        "POLYGON(( 7.86 56.39, 31.37 56.39, 31.37 39.48, 7.86 39.48, 7.868 56.39 ))"
  ) ;

  lv = new TGIS_LayerSHP ;
  lv->Path = "Shapes" + IntToStr( number ) + "\\imported.shp" ;
  lv->CS = ll->CS ;
  lv->MergeLayerEx( ll, ll->Extent, TGIS_ShapeType::Unknown, "",
                     shp, TGIS_Utils::GIS_RELATE_DISJOINT(), False, False );

  delete shp ;
  GIS->Add( lv );
  lv->Params->Marker->Color = TGIS_Color::Green;
  GIS->FullExtent() ;

  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/* Writes all cities to a new SHP using TGIS_LayerVectorDirectWriteHelper
   (Build -> AddShape loop -> Close) for high-performance sequential writing. */
void __fastcall TForm1::btnDirectWriteClick(TObject *Sender)
{
  TGIS_LayerSHP *lv ;
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVectorDirectWriteHelper *drh;
  TGIS_LayerVectorEnumerator *en;

  GIS->Close();

  ll = new TGIS_LayerSHP ;

  try {
    ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
    ll->Open() ;

    lv = new TGIS_LayerSHP ;
    try{
      lv->ImportStructure( ll ) ;
      lv->CS = ll->CS ;

      drh = new TGIS_LayerVectorDirectWriteHelper( lv ) ;
      try{
        drh->Build("Shapes"+ IntToStr( number ) + "\\direct_write.shp", ll->Extent,
                   TGIS_ShapeType::Point, TGIS_DimensionType::XY );
        en = ll->Loop()->GetEnumerator() ;
        try{
          while (en->MoveNext()){
            shp = en->GetCurrent() ;
            drh->AddShape( shp ) ;
          }
        }
        __finally{
          delete en ;
        }
        drh->Close();
      }
      __finally {
        delete drh ;
      }
    }
    __finally{
      GIS->Add( lv ) ;
      GIS->FullExtent();
    }
  }
  __finally{
    delete ll  ;
  }
}
//---------------------------------------------------------------------------

/* Writes all cities to a new SHP using TGIS_LayerVectorMergeHelper with Commit() per shape for
   batch-commit writing; resets all buttons on completion. */
void __fastcall TForm1::btnDirectMergeClick(TObject *Sender)
{
  TGIS_LayerSHP *lv ;
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVectorMergeHelper *drm;
  TGIS_LayerVectorEnumerator *en;

  GIS->Close();

  ll = new TGIS_LayerSHP ;
  try{
      ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
      ll->Open() ;

      lv = new TGIS_LayerSHP ;
      try {
         lv->ImportStructure( ll );
         lv->CS = ll->CS ;
         try{
           lv->Build( "Shapes" + IntToStr( number ) + "\\merge_helper.shp", ll->Extent,
                      TGIS_ShapeType::Point, TGIS_DimensionType::XY
                    );
         } catch(...) {
         }

         drm = new TGIS_LayerVectorMergeHelper( lv, 500 ) ;

         try{
           en = ll->Loop()->GetEnumerator() ;
           try {
             while(en->MoveNext()) {
               shp = en->GetCurrent() ;
               drm->AddShape( shp ) ;
               drm->Commit();
             }
           }
           __finally {
             delete en ;
           }
         }
         __finally{
           delete drm ;
         }
      }
      __finally {
        GIS->Add( lv ) ;
        GIS->FullExtent() ;
      }
    }
    __finally{
      delete ll ;
    }
}

//---------------------------------------------------------------------------

/* Finds the next unused Shapes{n} directory number and creates it as the output destination. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  number = 0 ;
  exist = true ;
  while (exist){
    if ( DirectoryExists( "Shapes" + IntToStr( number ) ) ){
      number = number + 1 ;
    }
    else{
      exist = false ;
    }
  }

  CreateDir( "Shapes" + IntToStr( number ) );
}
//---------------------------------------------------------------------------

