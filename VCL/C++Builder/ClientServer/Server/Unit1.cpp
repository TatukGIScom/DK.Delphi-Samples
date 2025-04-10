//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide basic Client-Server solution(Server side)
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
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete oGis ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  oGis = new TGIS_ViewerBmp() ;
  oGis->Open( TGIS_Utils::GisSamplesDataDirDownload() +"\\World\Countries\Poland\DCW\poland.ttkproject" ) ;
  oGis->RestrictedDrag = false ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::IdTCPServerConnect(TIdContext *AContext){
  memMessages->Lines->Add( "Client connected" ) ;
  AContext->Connection->IOHandler->WriteLn("Welcome to TatukGIS ClientServer demo");
}

//---------------------------------------------------------------------------
void __fastcall TForm1::IdTCPServerExecute(TIdContext *AContext){
  String cmd  ;
  TMemoryStream *strm ;

  strm = new TMemoryStream;
  try{
    cmd = AContext->Connection->IOHandler->ReadLn();
    cmd = UpperCase(cmd);
    if( cmd == "ZOOMIN" ){
      oGis->ZoomIn() ;
      oGis->Draw() ;
      (( TBitmap *)(oGis->Bitmap))->SaveToStream( strm );
      AContext->Connection->IOHandler->Write( int(strm->Size) ) ;
      AContext->Connection->IOHandler->Write( strm ) ;
      memMessages->Lines->Add( "ZOOMIN" ) ;
    }
    else if( cmd == "ZOOMOUT" ){
      oGis->ZoomOut() ;
      oGis->Draw() ;
      ((TBitmap *)(oGis->Bitmap))->SaveToStream( strm );
      AContext->Connection->IOHandler->Write( int(strm->Size) ) ;
      AContext->Connection->IOHandler->Write( strm ) ;
      memMessages->Lines->Add( "ZOOMOUT" ) ;
    }
    else if( cmd == "QUIT" ){
      AContext->Connection->Disconnect();
      memMessages->Lines->Add( "QUIT" ) ;
    }
    else{ // just draw
      oGis->Draw() ;
      ( ( TBitmap *)(oGis->Bitmap))->SaveToStream( strm );
      AContext->Connection->IOHandler->Write( int(strm->Size) ) ;
      AContext->Connection->IOHandler->Write( strm ) ;
      memMessages->Lines->Add( "DRAW" ) ;
    }
  }__finally{
    delete strm ;
  }
}



