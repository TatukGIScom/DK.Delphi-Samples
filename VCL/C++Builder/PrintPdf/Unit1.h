//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <System.ImageList.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include <Vcl.ExtCtrls.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisControlScale.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.Dialogs.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TStatusBar *StatusBar1;
	TPanel *Panel1;
	TRadioGroup *RadioGroup1;
	TButton *Button1;
	TGIS_ControlLegend *GISLegend;
	TSplitter *Splitter1;
	TGIS_ViewerWnd *GIS;
	TGIS_ControlScale *GISScale;
	TSaveDialog *dlgSave;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall Button1Click(TObject *Sender);
	int  __fastcall inch(TGIS_Printer *_printer, double _value);
	void __fastcall PrintPage(TObject *_sender,
	   TGIS_PrintManager *_printmanager, bool &_lastpage);
	void __fastcall BeforePrintPage(TObject *_sender,
	   TGIS_PrintManager *_printmanager, bool &_lastpage);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
