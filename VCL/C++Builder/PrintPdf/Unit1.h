//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// PrintPdf sample — demonstrates printing maps and exporting to PDF (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a map dataset into TGIS_ViewerWnd
//   - Configuring print layout and page setup parameters
//   - Selecting paper size, orientation (portrait/landscape)
//   - Adding map frame with specific dimensions to print page
//   - Including scale bar, north arrow, legend, and title elements
//   - Setting print resolution (DPI) for output quality
//   - Previewing layout before printing/exporting
//   - Exporting map to PDF file via TGIS_ExportPDF
//   - Printing directly to physical printer
//   - Supporting multiple page sizes (Letter, A4, A3, etc.)
//   - Managing margins and safe areas on print page
//   - Preserving map symbology and layer visibility in output
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_PrintManager           - print job management
//   TGIS_Printer                - printer output interface
//   TGIS_ExportPDF              - PDF export engine
//   TGIS_ControlLegend          - legend for print output
//   TGIS_ControlScale           - scale bar element
//   Page setup                  - orientation, size, margins
//   Print templates             - layout definitions
//   Export resolution           - DPI settings
//   Georeferenced output        - coordinate grid overlay
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
