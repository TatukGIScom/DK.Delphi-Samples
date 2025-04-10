//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Export window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "ExportForm.h"
#include "MainForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmExportLayer *frmExportLayer;
//---------------------------------------------------------------------------
__fastcall TfrmExportLayer::TfrmExportLayer(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmExportLayer::FormShow(TObject *Sender)
{
  TGIS_Layer *ll;

  cmbLayersList->Items->Clear() ;
  // add all layers of TGIS_LayerVector type to the list
  for ( int i = frmMain->GIS->Items->Count - 1 ; i == 0 ; i--) {
    ll = ( TGIS_Layer *)(frmMain->GIS->Items->Items[i]) ;
    // only vectors
    if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
      cmbLayersList->Items->Add( ll->Name ) ;
  }
  cmbLayersList->ItemIndex   = 0 ;
  cmbShapeType->ItemIndex    = 0 ;
  grpSelectExtent->ItemIndex = 0 ;
}
//---------------------------------------------------------------------------
