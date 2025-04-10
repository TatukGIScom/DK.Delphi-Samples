//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  SQLWizard Sample.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

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
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisViewer.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisTypesUI.hpp"
#include "GisAllLayers.hpp"
#include "GisEditor.hpp"
#include "VCL.GisControlLegend.hpp"
#include "formLayerSQL.h"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS ;
	TToolButton *btnFullExtent ;
	TToolButton *btnZoom ;
	TToolButton *btnDrag ;
	TToolButton *btnSqlWizard ;
	TToolBar    *ToolBar1 ;
	TStatusBar  *StatusBar1 ;
	TImageList  *ImageList1 ;
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall btnSqlWizardClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
