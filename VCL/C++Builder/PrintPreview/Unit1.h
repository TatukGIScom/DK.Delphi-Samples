//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  PrintPreview sample — demonstrates print preview and printing maps with layout controls (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading a map dataset (countries shapefile) into the main viewer
//    - Creating a print layout using TGIS_ControlPrintPreview control
//    - Adding map frame to layout with specific dimensions and position
//    - Setting print title and subtitle text on the layout
//    - Adding north arrow / orientation indicator to the print page
//    - Adding scale bar with automatic scale calculation
//    - Adding legend showing layer symbology and colors
//    - Configuring page orientation (portrait/landscape) and paper size
//    - Setting print margins and safe area constraints
//    - Previewing the print layout before sending to printer
//    - Printing the layout to physical printer
//    - Exporting layout to file (PDF, PostScript, etc.)
//    - Controlling map projection and extent on the print page
//    - Using TGIS_PrintManager to manage print jobs
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main interactive map viewer
//    TGIS_ControlPrintPreview    - print layout and preview control
//    TGIS_PrintManager           - print job management system
//    TGIS_ControlLegend          - legend rendering for print output
//    Map frame                   - positioned map area on print page
//    Scale bar                   - automatic scale indicator for print
//    North arrow                 - map orientation indicator
//    Title / subtitle            - print page annotations
//    Page setup                  - paper size, orientation, margins
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
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <Dialogs.hpp>
#include <DB.hpp>
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisPrintManager.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlPrintPreview.hpp"
#include "GisControlPrintPreviewSimple.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TGIS_ControlLegend *GIS_ControlLegend1;
  TGIS_ViewerWnd *GIS;
  TButton *Button1;
  TButton *Button2;
  TGIS_ControlPrintPreviewSimple *GIS_ControlPrintPreviewSimple1;
  TGIS_ControlPrintPreview *GIS_ControlPrintPreview1;
  TCheckBox *chkStandardPrint;
  TButton *btnTitleFont;
  TButton *btnSubTitleFont;
  TEdit *edPrintTitle;
  TEdit *edPrintSubTitle;
  TLabel *lbPrintTitle;
  TLabel *lbPrintSubTitle;
  TFontDialog *dlgFontT;
  TFontDialog *dlgFontST;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall Button1Click(TObject *Sender);
  void __fastcall Button2Click(TObject *Sender);
  void __fastcall btnTitleFontClick(TObject *Sender);
  void __fastcall btnSubTitleFontClick(TObject *Sender);
  void __fastcall dlgFontTApply(TObject *Sender, HWND Wnd);
  void __fastcall dlgFontSTApply(TObject *Sender, HWND Wnd);
  void __fastcall edPrintTitleChange(TObject *Sender);
  void __fastcall edPrintSubTitleChange(TObject *Sender);
  void __fastcall GISPrintPage(TObject *_sender,
		   TGIS_PrintManager *_printmanager, bool &_lastpage);
  void __fastcall chkStandardPrintClick(TObject *Sender);
private:	// User declarations
  TGIS_PrintManager *printManager;
  TFontStyles __fastcall to_native_fontstyle(TGIS_FontStyles _st );
  TGIS_FontStyles __fastcall to_gis_fontstyle(TFontStyles _st );
  TColor __fastcall to_native_color(TGIS_Color _cl);
  TGIS_Color __fastcall to_gis_color(TColor _cl);
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  int __fastcall inch(TGIS_Printer *_printer, double _value);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
