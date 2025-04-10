//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to manipulate grid layer presentation
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
#include "GisLayerPixel.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
		TGIS_ViewerWnd *GIS;
		TStatusBar *StatusBar1;
		TSplitter *Splitter1;
		TToolBar *ToolBar1;
		TToolButton *btnFullExtent;
		TToolButton *btnZoom;
		TToolButton *btnDrag;
		TButton *btnClear;
		TButton *btnShadow;
		TButton *btnUserDefined;
		TButton *btnUserIni;
		TButton *btnReloadIni;
		TGIS_ControlLegend *GIS_ControlLegend1;
		TImageList *ImageList1;
		void __fastcall btnFullExtentClick(TObject *Sender);
		void __fastcall btnZoomClick(TObject *Sender);
		void __fastcall btnDragClick(TObject *Sender);
		void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift,
				int X, int Y);
		void __fastcall FormCreate(TObject *Sender);
		void __fastcall btnClearClick(TObject *Sender);
		void __fastcall btnShadowClick(TObject *Sender);
		void __fastcall btnUserDefinedClick(TObject *Sender);
		void __fastcall btnUserIniClick(TObject *Sender);
		void __fastcall btnReloadIniClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
