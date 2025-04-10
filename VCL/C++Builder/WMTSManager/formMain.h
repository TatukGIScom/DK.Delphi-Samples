//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide WMTS Layer support.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef formMainH
#define formMainH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisRegistredLayers.hpp"
//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TGIS_ControlLegend *GIS_ControlLegend1;
	TGIS_ViewerWnd *GIS;
	TToolBar *tlb1;
	TStatusBar *stat1;
	TImageList *il1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TToolButton *btnClose;
	TToolButton *btnOpen;
	TToolButton *btn1;
	void __fastcall btnOpenClick(TObject *Sender);
	void __fastcall btnCloseClick(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
	void __fastcall AppendCoverage( const String _path ) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
