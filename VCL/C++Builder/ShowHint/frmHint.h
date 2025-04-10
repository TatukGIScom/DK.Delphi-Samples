//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to display map hints.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef frmHintH
#define frmHintH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TfrmHints : public TForm
{
__published:	// IDE-managed Components
  TGroupBox *gbHintsData;
  TCheckBox *chkShow;
  TButton *btnCancel;
  TButton *btnOk;
  TComboBox *cbLayers;
  TListBox *lbFields;
  TPanel *paColor;
  TLabel *lbColor;
  TColorDialog *dlgColor;
  void __fastcall FormShow(TObject *Sender);
  void __fastcall paColorClick(TObject *Sender);
  void __fastcall cbLayersChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmHints(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmHints *frmHints;
//---------------------------------------------------------------------------
#endif
