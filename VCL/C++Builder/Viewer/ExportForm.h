//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Export window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef ExportFormH
#define ExportFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TfrmExportLayer : public TForm
{
__published:	// IDE-managed Components
  TLabel *Label1;
  TLabel *Label2;
  TLabel *Label3;
  TRadioGroup *grpSelectExtent;
  TComboBox *cmbLayersList;
  TComboBox *cmbShapeType;
  TButton *btnCancel;
  TButton *btnOK;
  TEdit *edtQuery;
  void __fastcall FormShow(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmExportLayer(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmExportLayer *frmExportLayer;
//---------------------------------------------------------------------------
#endif
