//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------


#include <vcl.h>
#pragma hdrstop

#include "InfoForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TFormInfo *FormInfo;
//---------------------------------------------------------------------------
__fastcall TFormInfo::TFormInfo(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TFormInfo::FormClose(TObject *Sender, TCloseAction &Action)
{
  Form1->sgrdMemo->Hint = "Double click for info";
}
//---------------------------------------------------------------------------

void __fastcall TFormInfo::FormShow(TObject *Sender)
{
  Form1->sgrdMemo->Hint = "";
}
//---------------------------------------------------------------------------

