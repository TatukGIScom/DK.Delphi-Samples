//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//  How to use TGIS_DataSet
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

void __fastcall TForm1::GIS_DataSet1AfterScroll(TDataSet *DataSet)
{
  TGIS_Shape *shp ;

  if ( GIS_DataSet1->ActiveShape ) {
    GIS->Lock() ;
      GIS->VisibleExtent = GIS_DataSet1->ActiveShape->Extent ;
      GIS->Zoom = GIS->Zoom * 0.8 ;
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp", TRUE ) ;
  GIS_DataSet1->Open( (TGIS_LayerVector *)( GIS->Items->Items[0] ), GIS->Extent ) ;
}
//---------------------------------------------------------------------------
