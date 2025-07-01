//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide editing functionality.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "InfoForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmInfo *frmInfo;
//---------------------------------------------------------------------------
__fastcall TfrmInfo::TfrmInfo(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void TfrmInfo::ShowInfo( TGIS_Shape * const _shp )
{
  GISAttributes->ShowShape( _shp ) ;
}
//---------------------------------------------------------------------------




