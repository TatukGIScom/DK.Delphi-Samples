//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// DK11.24.0.17147-Unstable4daily30
// (c)2000-2018 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to add layer to the map.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include <System.Generics.Collections.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisAllLayers.hpp"
#include "GisUtils.hpp"
#include "GisTypesUI.hpp"
#include <Vcl.Dialogs.hpp>
#include <System.Classes.hpp>
#include "GisPipeline.hpp"
#include "GisAllPipelineOperations.hpp"
#include "VCL.GisPipelineParamsEditor.hpp"
#include <System.Classes.hpp>
#include "VCL.GisControlLegend.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblCommands;
	TLabel *lblCode;
	TGIS_ViewerWnd *GIS;
	TMemo *mmoCode;
	TButton *btnExecute;
	TButton *btnExit;
	TButton *btnHelp;
	TListBox *lstbxCommands;
	TButton *btnOpen;
	TButton *btnSave;
	TOpenDialog *dlgOpen;
	TSaveDialog *dlgSave;
	TGIS_ControlLegend *GIS_ControlLegend1;
	TLabel *lbl1;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall lstbxCommandsDblClick(TObject *Sender);
	void __fastcall mmoCodeDblClick(TObject *Sender);
	void __fastcall btnExitClick(TObject *Sender);
	void __fastcall btnExecuteClick(TObject *Sender);
	void __fastcall mmoCodeClick(TObject *Sender);
	void __fastcall btnHelpClick(TObject *Sender);
	void __fastcall btnOpenClick(TObject *Sender);
	void __fastcall btnSaveClick(TObject *Sender);

private:	// User declarations
	TGIS_Pipeline *oPipeline ;
	System::Classes::TStringList *oPipelineCommands ;
	Integer oPipelineLine ;

	__fastcall void prepareCommands() ;

	__fastcall void doPipelineMessage(
	  const System::UnicodeString _message
	) ;
	__fastcall void doPipelineForm(
	  TGIS_PipelineOperationAbstract *_operation
	) ;
	__fastcall void doPipelineHelp(
	  TObject *_sender,
	  String _name
	) ;

public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

