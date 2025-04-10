//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Info window.
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
void __fastcall TfrmInfo::ShowInfo( TGIS_Shape *_shp )
{
  AnsiString str;

  if ( _shp == NULL ) {
    shpObj = NULL ;
    Caption = "Shape: NULL" ;
  }
  else {
    Caption = str.sprintf( "Shape: %d", _shp->Uid )  ;
    // display all attributes for selected shape
    GIS_ControlAttributes->ShowShape( _shp );
    Show() ;
  }
}
