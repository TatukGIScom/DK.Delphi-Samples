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

#include "formMain.h"
#include "formWMTS.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::AppendCoverage( const String _path ){
  TGIS_Layer *ll ;

  try{
    // create a new layer
    ll = GisCreateLayer( ExtractFileName(_path),_path );
    // and add it to the viewer
    if (ll != NULL){
      ll->ReadConfig();
      try{
        GIS->Add(ll);
      }catch( Exception& e ) {
        delete ll ;
      }
    }

    GIS_ControlLegend1->GIS_Layer = ll ;

    if( GIS->Items->Count == 1 ){
      GIS->FullExtent();
    }
    else{
      GIS->InvalidateWholeMap() ;
    }
  } catch( Exception& e ){
      ShowMessage( "File can't be open\n" + e.Message ) ;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::btnOpenClick(TObject *Sender)
{
  frmWMTS->Show() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnCloseClick(TObject *Sender)
{
    GIS->Close();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnFullExtentClick(TObject *Sender)
{
    GIS->FullExtent();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnZoomClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnDragClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

