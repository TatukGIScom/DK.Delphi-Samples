//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide WMTS Layer support.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "formWMTS.h"
#include "formMain.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmWMTS *frmWMTS;
//---------------------------------------------------------------------------
__fastcall TfrmWMTS::TfrmWMTS(TComponent* Owner)
    : TForm(Owner)
{
}

void __fastcall TfrmWMTS::btnConnectClick(TObject *Sender)
{
  TGIS_LayerWMTS *wmts ;
  TGIS_LayerInfoList *lst ;
  TGIS_LayerInfo *li ;

  wmts = new TGIS_LayerWMTS ;
  try{
    wmts->Path = cbServers->Text ;
    try{
      lst = wmts->GetAvailableLayers() ;
      cbLayers->Items->Clear() ;
      for (int i = 0; i<lst->Count; i++) {
          li = lst->Items[i] ;
          cbLayers->Items->Add(li->Name);
      }
      if( cbLayers->Items->Count > 0 ){
        cbLayers->ItemIndex = 0 ;
      }
    }__finally{
      FreeObjectNotNil(lst) ;
    }
  }
  __finally{
    delete wmts ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWMTS::btnAddClick(TObject *Sender)
{
  TGIS_LayerWMTS *wmts ;
  TGIS_Strings *layer ;
  String str ;
  String tmp ;

  wmts = new TGIS_LayerWMTS() ;
  tkn  = new TGIS_Tokenizer() ;
  try{
    str = cbLayers->Text ;
    tkn->ExecuteEx( str, ';' ) ;
    layer = tkn->Result ;
    wmts->Path = tmp.sprintf( L"[TatukGIS Layer]\n"
                              L"Storage=WMTS\n"
                              L"%s\n"
                              L"Url=%s \n"
                              L"TileMatrixSet=%s \n"
                              L"ImageFormat=%s \n"
                              L"InvertAxis=%s \n",
                              layer->Strings[0].c_str(), 
                              cbServers->Text.c_str(), 
                              layer->Strings[2].c_str(), 
                              layer->Strings[1].c_str(),
                              BoolToStr(cbInvertAxis->Checked, true).c_str() 
                            ) ;

    frmMain->GIS->Add( wmts ) ;
    if( frmMain->GIS->Items->Count == 1 ){
      frmMain->GIS->FullExtent();
    }
    else{
      frmMain->GIS->InvalidateWholeMap() ;
    }
  }catch( Exception &e){
    delete wmts;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWMTS::FormDestroy(TObject *Sender)
{
  delete tkn ;
}
//---------------------------------------------------------------------------

