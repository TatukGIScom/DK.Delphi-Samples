//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Search window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef SearchFormH
#define SearchFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Buttons.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TfrmSearch : public TForm
{
__published:	// IDE-managed Components
  TLabel *Label1;
  TLabel *Label2;
  TSpeedButton *btnSearch;
  TLabel *Label3;
  TLabel *Label4;
  TComboBox *cbLayer;
  TComboBox *cbField;
  TEdit *eValue;
  TComboBox *cbOperation;
  TRadioGroup *rgExtent;
  TStatusBar *stsBar;
  void __fastcall FormShow(TObject *Sender);
  void __fastcall btnSearchClick(TObject *Sender);
  void __fastcall FormHide(TObject *Sender);
  void __fastcall cbLayerChange(TObject *Sender);
  void __fastcall eValueKeyPress(TObject *Sender, char &Key);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmSearch(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmSearch *frmSearch;
//---------------------------------------------------------------------------
#endif
