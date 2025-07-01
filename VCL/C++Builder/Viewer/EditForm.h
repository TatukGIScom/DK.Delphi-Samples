//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Edit window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef EditFormH
#define EditFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
//---------------------------------------------------------------------------
class TfrmEdit : public TForm
{
__published:	// IDE-managed Components
  TImageList *ImageList1;
  TToolBar *ToolBar1;
  TToolButton *btnSave;
  TMemo *Editor;
  TStatusBar *StatusBar1;
  void __fastcall EditorChange(TObject *Sender);
  void __fastcall btnSaveClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmEdit(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmEdit *frmEdit;
//---------------------------------------------------------------------------
#endif
