//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Search window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "SearchForm.h"
#include "MainForm.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmSearch *frmSearch;
//---------------------------------------------------------------------------
__fastcall TfrmSearch::TfrmSearch(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmSearch::FormShow(TObject *Sender)
{
   TGIS_Layer       *ll;
   TGIS_LayerVector *lv;

   if ( frmMain->GIS->IsEmpty ) return;

   cbLayer->Items->Clear();
   cbField->Items->Clear();
   btnSearch->Enabled = false;

   // find all layers and make a list
    for ( int i = 0 ; i <= frmMain->GIS->Items->Count-1 ; i++ ) {
        ll = (TGIS_Layer *)(frmMain->GIS->Items->Items[i]) ;
        if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
          cbLayer->Items->Add( ll->Name );
    }

    if ( cbLayer->Items->Count > 0 ) {
      cbLayer->ItemIndex = 0;

      //for first layer get fields names
      lv = (TGIS_LayerVector *)( frmMain->GIS->Items->Items[cbLayer->ItemIndex] );
      for ( int j = 0 ; j <= lv->Fields->Count - 1 ; j++ ) {
        if ( lv->FieldInfo(j)->Deleted ) continue;
        cbField->Items->Add( lv->FieldInfo(j)->NewName );
      }
      cbField->ItemIndex = 0;
      btnSearch->Enabled = true;
    }
    stsBar->Panels->Items[1]->Text = cbLayer->Items->Strings[cbLayer->ItemIndex];
}
//---------------------------------------------------------------------------
void __fastcall TfrmSearch::btnSearchClick(TObject *Sender)
{
  TGIS_Shape         *shp;
  TGIS_LayerVector   *ll;
  TGIS_Extent         ex;
  String             sql;

   // get selected layer
   ll = (TGIS_LayerVector *)( frmMain->GIS->Items->Items[cbLayer->ItemIndex] );

   // check if assigned, has proper type and searching value is not empty
   if ( ( ll == NULL ) ||
        ( ll->InheritsFrom( __classid(TGIS_LayerPixel) ) ) ||
        ( eValue->Text == "")) return;

   // check the extent
   if ( rgExtent->ItemIndex == 0 ) ex = frmMain->GIS->VisibleExtent;
   else ex = GisWholeWorld();

   // calculate the condition similar to SQL where clause
   sql = String().sprintf( L"%s%s%s",
						   cbField->Items->Strings[cbField->ItemIndex].c_str(),
						   cbOperation->Items->Strings[cbOperation->ItemIndex].c_str(),
						   QuotedStr( eValue->Text ).c_str()
                         );

   // let's find any shapes meeting the criteria and flash them
   shp = ll->FindFirst( ex, sql, NULL, "", false);
   if ( shp == NULL ) return;
   do { 
       shp->Flash(4, 100);
       Application->ProcessMessages();
       shp = ll->FindNext() ;
   } while( shp != NULL);

   frmMain->GIS->Update();
}
//---------------------------------------------------------------------------
void __fastcall TfrmSearch::FormHide(TObject *Sender)
{
  frmMain->GIS->RevertAll();
  frmMain->GIS->FullExtent();
}
//---------------------------------------------------------------------------
void __fastcall TfrmSearch::cbLayerChange(TObject *Sender)
{
  TGIS_LayerVector   *ll;
  // if layer changed, reload fields names
  cbField->Items->Clear();
  ll = (TGIS_LayerVector *)(frmMain->GIS->Get(cbLayer->Items->Strings[cbLayer->ItemIndex]));
  for ( int j = 0 ; j<= ll->Fields->Count-1 ; j++ ) {
      if (ll->FieldInfo(j)->Deleted) continue ;
      cbField->Items->Add( ll->FieldInfo(j)->NewName );
  }

  if ( cbField->Items->Count > 0 ) cbField->ItemIndex = 0;
  stsBar->Panels->Items[1]->Text = cbLayer->Items->Strings[cbLayer->ItemIndex];
}
//---------------------------------------------------------------------------
void __fastcall TfrmSearch::eValueKeyPress(TObject *Sender, char &Key)
{
  if ( Key == VK_RETURN ) btnSearchClick( 0 );

}
//---------------------------------------------------------------------------
