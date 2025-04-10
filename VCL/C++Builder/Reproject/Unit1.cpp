//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to reproject the file.
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

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  Integer      i   ;
  TStringList *lst ;

  lst = new TStringList() ;
  lst->Sorted = True ;
  __try
  {
    lst->Clear() ;
    for ( i = 0; i < CSProjList()->Count(); i++ )
    {
      // UTM is a bit to restrictive to show whole country
      lst->Add( (*CSProjList())[i]->WKT ) ;
    }
    for (i = 0; i < lst->Count; i++ )
    {
      cbxSrcProjection->Items->AddObject( lst->Strings[i], lst->Objects[i] ) ;
    }
    cbxSrcProjection->ItemIndex = 0 ;
  }
  __finally
  {
    delete lst ;
  }

  cbxSrcProjectionChange( this ) ;

  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\Country.shp" ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  TGIS_LayerVector *lv ;
  TGIS_LayerVector *lo ;

  if ( GIS->IsEmpty ) return ;

  if ( !dlgSave->Execute() ) return ;

  lv = ( TGIS_LayerVector *)( GIS->Items->Items[0] );

  lo = new TGIS_LayerSHP ;
  lo->Path = dlgSave->FileName;
  lo->CS = GIS->CS ;
  try
  {
    lo->ImportLayer( lv,  GisWholeWorld(),
                     TGIS_ShapeType::Unknown, "", False
                   ) ;
  }
  __finally
  {
    delete lo ;
  } ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbxSrcProjectionChange(TObject *Sender)
{
  String                             sproj ;
  TGIS_CSCoordinateSystem           *ocs   ;
  TGIS_CSGeographicCoordinateSystem *ogcs  ;
  TGIS_CSUnits                      *ounit ;
  TGIS_CSProjAbstract               *oproj ;

  sproj = cbxSrcProjection->Items->Strings[cbxSrcProjection->ItemIndex] ;

  ogcs  = CSGeographicCoordinateSystemList()->ByEPSG( 4030 ) ;
  ounit = CSUnitsList()->ByWKT( "METER" ) ;
  oproj = CSProjList()->ByWKT( sproj ) ;


  ocs = new TGIS_CSProjectedCoordinateSystem(
           -1, "Test",
           ogcs->EPSG, ounit->EPSG, oproj->EPSG,
           CSProjectedCoordinateSystemList()->DefaultParams( oproj->EPSG )
         );

  GIS->Lock() ;
  try
  {
    try
    {
      GIS->CS = ocs ;
      GIS->FullExtent() ;
    }
    catch(Exception &exception)
    {
      GIS->CS = NULL ;
    }
  }
  __finally
  {
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------

