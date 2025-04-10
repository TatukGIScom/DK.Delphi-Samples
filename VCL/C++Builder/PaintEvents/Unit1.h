//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to override OnPaintShapeLabel.
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
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include <Vcl.Dialogs.hpp>
#include "VCL.GisRendererDirect2D.hpp"
#include "VCL.GisRendererGdi32.hpp"
#include "VCL.GisRendererGdiPlus.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TToolButton *ToolButton4 ;
        TImageList *ImageList1 ;
        TStatusBar *StatusBar1 ;
        TCheckBox *chkDrag ;
        TPanel *Panel1 ;
        TCheckBox *chkBeforePaintRendererEvent;
        TCheckBox *chkBeforePaintEvent;
        TCheckBox *chkPaintExtraEvent;
        TCheckBox *chkAfterPaintEvent;
        TCheckBox *chkAfterPaintRendererEvent;
        TButton *btnTestPrintBmp;
        TCheckBox *chkPrintBmpWithEvents;
        TRadioGroup *grbRenderers;
        TRadioButton *rbDirect2D;
        TRadioButton *rbGdiPlus;
        TRadioButton *rbGdi32;
        TSaveDialog *SaveDialog1;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomInClick(TObject *Sender);
        void __fastcall btnZoomOutClick(TObject *Sender);
        void __fastcall chkDragClick(TObject *Sender);
	void __fastcall GISBeforePaintRendererEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode);
	void __fastcall GISBeforePaintEvent(TObject *_sender, TObject *_canvas);
	void __fastcall GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode);
	void __fastcall GISAfterPaintEvent(TObject *_sender, TObject *_canvas);
	void __fastcall GISAfterPaintRendererEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode);
	void __fastcall chkBeforePaintRendererEventClick(TObject *Sender);
	void __fastcall chkBeforePaintEventClick(TObject *Sender);
	void __fastcall chkPaintExtraEventClick(TObject *Sender);
	void __fastcall chkAfterPaintEventClick(TObject *Sender);
	void __fastcall chkAfterPaintRendererEventClick(TObject *Sender);
	void __fastcall btnTestPrintBmpClick(TObject *Sender);
	void __fastcall rbDirect2DClick(TObject *Sender);
	void __fastcall rbGdiPlusClick(TObject *Sender);
	void __fastcall rbGdi32Click(TObject *Sender);

private:	// User declarations
        TGIS_Point center_ptg ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
