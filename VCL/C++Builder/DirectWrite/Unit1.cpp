//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to direct write file.
//
//  Check project\options\directories in a case of any problems during compilation
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
void __fastcall TForm1::btnBuildClick(TObject *Sender)
{
  TGIS_LayerSHP *lv ;
  TGIS_LayerSHP *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVectorEnumerator *loop1 ;

  GIS->Close();

  lv = new TGIS_LayerSHP ;

  try{
      lv->Build( ( "Shapes" + IntToStr( number ) + "\\build.shp" ),
                   GisExtent( -180, -90, 180, 90 ),
                   TGIS_ShapeType::Point,
                   TGIS_DimensionType::XY
               );
      lv->Open() ;

      ll = new TGIS_LayerSHP ;
      try {
        ll->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\cities.shp" ;
        ll->Open() ;
        int cnt = ll->Items->Count ;
        lv->ImportStructure( ll ) ;
        lv->CS = ll->CS ;
        loop1 = ll->Loop()->GetEnumerator(); // (GIS->VisibleExtent, "", 0, "", True)->GetEnumerator();
        while (loop1->MoveNext()) {
          lv->AddShape( loop1->Current, True);
        };
      }
      __finally {
        delete loop1 ;
        delete ll ;
      }
      lv->SaveData() ;
  } catch(...) {

  }

  GIS->Add( lv ) ;
  GIS->FullExtent() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

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

