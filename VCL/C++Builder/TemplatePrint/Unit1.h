// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// =============================================================================

//
// How to provide template based printing
//
// Check project\options\directories in a case of any problems during compilation
// ---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
// ---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisControlPrintPreview.hpp"
#include "VCL.GisControlScale.hpp"
#include "VCL.GisControlNorthArrow.hpp"
#include "GisControlPrintPreviewSimple.hpp"
#include "GisTypesUI.hpp"

// ---------------------------------------------------------------------------
class TForm1 : public TForm {
__published: // IDE-managed Components
	TGIS_ControlLegend *GIS_ControlLegend1;
	TGIS_ControlScale *GIS_ControlScale1;
	TGIS_ControlPrintPreviewSimple *GIS_ControlPrintPreviewSimple1;
	TStatusBar *StatusBar1;
	TSplitter *Splitter1;
	TToolBar *ToolBar1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TImageList *ImageList1;
	TGIS_ViewerWnd *GIS;
	TButton *Button1;
	TGIS_ControlScale *GIS_ControlScale2;
	TGIS_ControlNorthArrow *GIS_ControlNorthArrow1;

	void __fastcall FormCreate(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall GISAfterPaint(TObject *_sender, TObject *_canvas);
	void __fastcall Button1Click(TObject *Sender);

private: // User declarations
public: // User declarations
	__fastcall TForm1(TComponent* Owner);
};

// ---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
// ---------------------------------------------------------------------------
#endif
