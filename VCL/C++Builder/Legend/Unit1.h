//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide Legend control
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TToolBar *ToolBar1 ;
    TGIS_ViewerWnd *GIS ;
    TStatusBar *StatusBar1 ;
	TImageList *ImageList1 ;
	TToolButton *btnFullExtent ;
	TToolButton *ToolButton2 ;
	TToolButton *btnZoom ;
	TToolButton *btnDrag ;
	TGIS_ControlLegend *GIS_ControlLegend1 ;
	TToolButton *ToolButton1 ;
	TTabControl *TabControl1;
	TSplitter *Splitter1;
    TSpeedButton *SpeedButton1;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomClick(TObject *Sender);
        void __fastcall btnDragClick(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall GISAfterPaint(TObject *_sender, TObject *_canvas);
	void __fastcall TabControl1Change(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
