//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Edit window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "EditForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmEdit *frmEdit;
//---------------------------------------------------------------------------
__fastcall TfrmEdit::TfrmEdit(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmEdit::EditorChange(TObject *Sender)
{
  btnSave->Enabled = Editor->Modified;
}
//---------------------------------------------------------------------------
void __fastcall TfrmEdit::btnSaveClick(TObject *Sender)
{
  if ( StatusBar1->Panels->Items[1]->Text != "") {
      Editor->Lines->SaveToFile( StatusBar1->Panels->Items[1]->Text );
      btnSave->Enabled = false;
  }
}
//---------------------------------------------------------------------------
