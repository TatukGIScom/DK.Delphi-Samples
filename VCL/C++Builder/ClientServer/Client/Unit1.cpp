//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide basic Client-Server solution(Client side)
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

void __fastcall TForm1::UpdateStatus(){
  try{
    if( IdTCPClient->Connected() )
    {
      btnConnect->Enabled    = false ;
      btnDisconnect->Enabled = true  ;
    }
    else
    {
      btnConnect->Enabled   = true  ;
      btnDisconnect->Enabled = false ;
    }
  }
  catch( Exception& e ){
    btnConnect->Enabled    = true  ;
    btnDisconnect->Enabled = false ;
  }
}

void __fastcall TForm1::LockControls(bool ALock){
  int i;

  for( i = 0; i<=ComponentCount-1; i++ ){
	if( (( TControl *)(Components[i]))->Tag == 99 ){
	   (( TControl *)(Components[i]))->Enabled = ALock;
	}
  }
}

void __fastcall TForm1::btnDisconnectClick(TObject *Sender)
{
  if( IdTCPClient->Connected() ){

    try{
      IdTCPClient->Disconnect(); // we can disconnect from either the server or the client side
    }catch(Exception& e){
      ShowMessage(e.Message);
    }
  }
  UpdateStatus() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnConnectClick(TObject *Sender)
{
  memMessages->Lines->Clear();

    IdTCPClient->Host = edtHost->Text;
    IdTCPClient->Port = StrToInt(edtPort->Text);
    try{
      IdTCPClient->Connect();
    }catch(Exception& e){
        LockControls(true);
        ShowMessage(e.Message);
    }
  UpdateStatus() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnSendCommandClick(TObject *Sender)
{
  String LCommand;
  TMemoryStream *strm ;
  int cnt ;
  TBitmap *bmp ;

  LCommand = cboCommands->Text;

  strm = new TMemoryStream;
  try{
    try{
      IdTCPClient->IOHandler->WriteLn(LCommand);
      cnt = IdTCPClient->IOHandler->ReadLongInt() ;
      IdTCPClient->IOHandler->ReadStream( strm, cnt );
      strm->Position = 0 ;

      bmp = new TBitmap() ;
      bmp->LoadFromStream( strm ) ;
      Image1->Width  = bmp->Width  ;
      Image1->Height = bmp->Height ;
      Image1->Canvas->FillRect( Image1->Canvas->ClipRect );
      Image1->Canvas->Draw( 0, 0, bmp );
    }
    catch(Exception& e)
    {
      LockControls(true);
      ShowMessage(e.Message);
    }
  }

  __finally{
    delete strm ;
  }

  UpdateStatus() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::IdTCPClientDisconnected(TObject *Sender)
{
  memMessages->Lines->Add("Disconnected from remote server");
  LockControls(false);
  UpdateStatus() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::IdTCPClientConnected(TObject *Sender)
{
  String str;

  str = IdTCPClient->IOHandler->ReadLn();
  memMessages->Lines->Add("Connected to remote server");
  memMessages->Lines->Add("Server said -> " + str);
  LockControls(true);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  if( cboCommands->Items->Count > 0 ){
    cboCommands->ItemIndex = 0;
    cboCommands->Text = cboCommands->Items->Strings[cboCommands->ItemIndex];
  }
}
//---------------------------------------------------------------------------

