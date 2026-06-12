//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  Pipeline sample — demonstrates scripted GIS operations using TGIS_Pipeline.
//  A .ttkpipeline file is loaded and parsed; the user can edit and execute pipeline
//  commands (ETL operations like opening layers, filtering, contouring) via the
//  code editor or by double-clicking commands in the list to open parameter dialogs.
//  Progress bars show operation execution status in real-time.
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
/* Main form for the Pipeline sample.
   Demonstrates scripted GIS operations via TGIS_Pipeline. */
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
	void __fastcall FormCreate(TObject *Sender);  /* Load pipeline file; set up pipeline */
	void __fastcall FormDestroy(TObject *Sender);  /* Cleanup */
	void __fastcall lstbxCommandsDblClick(TObject *Sender);  /* Open editor for command */
	void __fastcall mmoCodeDblClick(TObject *Sender);  /* Open editor for code line */
	void __fastcall btnExitClick(TObject *Sender);  /* Exit application */
	void __fastcall btnExecuteClick(TObject *Sender);  /* Execute pipeline script */
	void __fastcall mmoCodeClick(TObject *Sender);  /* Update current line */
	void __fastcall btnHelpClick(TObject *Sender);  /* Open help docs */
	void __fastcall btnOpenClick(TObject *Sender);  /* Open pipeline file */
	void __fastcall btnSaveClick(TObject *Sender);  /* Save pipeline file */

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

