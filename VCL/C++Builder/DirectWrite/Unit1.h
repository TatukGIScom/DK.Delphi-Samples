//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to direct write file.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisTypesUI.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerVector.hpp"
#include "GisGeometryFactory.hpp"
#include "GisRtl.hpp"
#include "GisTopology.hpp"


//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TToolBar *Toolbar1;
	TButton *btnImportLayer ;
	TButton *btnMergeLayer;
	TButton *btnDirectMerge;
	TButton *btnBuild;
	TButton *btnDirectWrite ;
	void __fastcall btnBuildClick(TObject *Sender);
	void __fastcall btnImportLayerClick(TObject *Sender);
	void __fastcall btnMergeLayerClick(TObject *Sender);
	void __fastcall btnDirectWriteClick(TObject *Sender);
	void __fastcall btnDirectMergeClick(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
  int number ;
  bool exist ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
