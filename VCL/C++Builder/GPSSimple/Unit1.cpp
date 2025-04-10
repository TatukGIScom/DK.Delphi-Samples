//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to GPS NMEA Unit.
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

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  cbxCom->ItemIndex = GPS->Com - 1 ;

  for ( int i = 0; cbxBaud->Items->Count - 1 ; i++ ) {
    if ( StrToInt(cbxBaud->Items->Strings[ i ]) == GPS->BaudRate) {
       cbxBaud->ItemIndex = i ;
       break ;
    }
  }
  GPS->Active = True ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GPSPosition(TObject *Sender)
{
  AnsiString str;
  str.sprintf("%s %s %s",
              TimeToStr(Now()).c_str(),
              FloatToStr(RadToDeg( GPS->Longitude )).c_str(),
              FloatToStr(RadToDeg( GPS->Latitude  )).c_str());

  Memo1->Lines->Add( str ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cbxComChange(TObject *Sender)
{
  GPS->Com = cbxCom->ItemIndex + 1 ;
  GPS->Active = true ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cbxBaudChange(TObject *Sender)
{
  GPS->BaudRate = StrToInt( cbxBaud->Items->Strings[ cbxBaud->ItemIndex ] ) ;
  GPS->Active = true ;
}
//---------------------------------------------------------------------------
