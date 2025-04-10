//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//  How to display map hints.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "frmHint.h"
#include "Unit1.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmHints *frmHints;
//---------------------------------------------------------------------------
__fastcall TfrmHints::TfrmHints(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmHints::FormShow(TObject *Sender)
{
  int i;
  TGIS_Layer *ll;
  TGIS_LayerVector   *lv;

  chkShow->Checked = Form1->hintDisplay;
  paColor->Color   = Form1->hintColor;

  cbLayers->Items->Clear();

  // get layers fom map
  for ( i=0 ; i <= Form1->GIS->Items->Count-1; i++) {
    ll = (TGIS_Layer *)( (Form1->GIS->Items)->Items[i] ) ;
    if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
      cbLayers->Items->Add( ll->Name ) ;
  }
  if (cbLayers->Items->Count <= 0) return;
  cbLayers->ItemIndex = 0;
  cbLayersChange(0);
}
//---------------------------------------------------------------------------
void __fastcall TfrmHints::paColorClick(TObject *Sender)
{
  if (!dlgColor->Execute()) return;

  paColor->Color = dlgColor->Color;
}
//---------------------------------------------------------------------------
void __fastcall TfrmHints::cbLayersChange(TObject *Sender)
{
  int i;
  TGIS_LayerAbstract *ll;
  TGIS_LayerVector   *lv;

  lbFields->Items->Clear();

  //get fields for selected layer
  lv = (TGIS_LayerVector *)( (Form1->GIS->Items)->Items[cbLayers->ItemIndex] );
  for ( i=0 ; i <= lv->Fields->Count - 1; i++) {
    if (lv->FieldInfo(i)->Deleted) continue;
    lbFields->Items->Add( lv->FieldInfo(i)->NewName );
  }

  for ( i=0 ; i <= lbFields->Items->Count - 1 ; i++)
    if ( AnsiCompareText( lbFields->Items->Strings[i], Form1->hintField) == 0 )
      lbFields->ItemIndex = i;

  if ( lbFields->ItemIndex < 0 ) lbFields->ItemIndex = 0;

}
//---------------------------------------------------------------------------
