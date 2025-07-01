//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Print window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef PrintFormH
#define PrintFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <VCL.GisPrinters.hpp>
#include "VCL.GisControlPrintPreview.hpp"
#include "GisControlPrintPreviewSimple.hpp"
//---------------------------------------------------------------------------
class TfrmPrint : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TButton *btnPreview;
  TButton *btnRefresh;
  TGIS_ControlPrintPreview *GIS_ControlPrintPreview1;
  TGIS_ControlPrintPreviewSimple *GIS_ControlPrintPreviewSimple1;
  void __fastcall btnRefreshClick(TObject *Sender);
  void __fastcall btnPreviewClick(TObject *Sender);
  void __fastcall GISPrintPage(TObject * _sender,
		   TGIS_Printer * _printer, bool &_lastpage);
  void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmPrint(TComponent* Owner);
  int __fastcall inch(double _value);  
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmPrint *frmPrint;
//---------------------------------------------------------------------------
#endif
