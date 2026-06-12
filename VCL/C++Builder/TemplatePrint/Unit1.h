// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// =============================================================================

//
// TemplatePrint sample — demonstrates printing maps using pre-designed print templates (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a TatukGIS project with predefined print templates
//   - Selecting different print template layouts (portrait, landscape, multi-map)
//   - Configuring print parameters (scale, title, subtitle, date)
//   - Adding map frame with specific position and size on template
//   - Incorporating legend, scale bar, and north arrow in template
//   - Setting margins and safe area constraints for printing
//   - Previewing template layout before printing
//   - Printing template to physical printer or PDF export
//   - Handling multi-page templates for large map areas
//   - Managing template-to-map extent mapping and scaling
//   - Supporting custom template editing and creation
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main interactive map viewer
//   TGIS_ControlScale           - scale bar display on print
//   TGIS_ControlLegend          - legend inclusion in print template
//   TGIS_ControlNorthArrow      - orientation indicator on print
//   Print template              - predefined layout with frames and placeholders
//   Map frame                   - positioned area for map display
//   Template parameters         - scale, orientation, margins
//   Scale calculation           - automatic scale bar generation
//   Multi-page printing         - large area coverage across pages
//   Print preview               - layout validation before printing
//   PDF export                  - non-paper output option
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
