//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to support different projections
//
//  Check project\options\directories in a case of any problems during compilation
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
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------



void __fastcall TfrmMain::FormCreate(TObject *Sender)
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
            if ( (*CSProjList())[i]->IsStandard ) 
            { 
            lst->Add( (*CSProjList())[i]->WKT ) ;
        }
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

  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\world.ttkproject" ) ;
}
//---------------------------------------------------------------------------


void __fastcall TfrmMain::cbxSrcProjectionChange(TObject *Sender)
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
        // we are aware of problems upon switching
        // between two incompatible systems
    }
  }
  __finally
  {
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------

