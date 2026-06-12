//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/* Legend sample — demonstrates interactive layer list and legend management (C++Builder/VCL).

   What the sample shows:
     - Placing TGIS_ControlLegend next to TGIS_ViewerWnd with legend-to-viewer linking
     - Interactive layer visibility toggling via legend checkboxes
     - Reordering layers via drag-and-drop in legend panel
     - Expanding/collapsing layer symbology details
     - Opening layer property dialogs for advanced configuration
     - Switching between two display modes at runtime (Layers vs. Groups)
     - Loading .ttkproject files with multiple pre-configured layers
     - Persisting layer-style changes back to project file via SaveAll
     - Real-time status bar updates showing current map scale

   Key TatukGIS API concepts shown here:
     TGIS_ViewerWnd              - main visual map control
     TGIS_ControlLegend          - interactive legend/layer list panel
     TGIS_ControlLegendMode      - display modes (Layers, Groups, etc.)
     GIS->Items                  - layer collection (get count, access by index)
     TGIS_Params                 - layer styling and rendering parameters
     GIS->VisibleExtent          - geographic extent of loaded layers
     GIS->Scale                  - map scale for display in status bar
*/

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
#include "VCL.GisControlLegend.hpp"  // TGIS_ControlLegend VCL control
#include "GisViewer.hpp"             // Base viewer class
#include "VCL.GisViewerWnd.hpp"      // TGIS_ViewerWnd VCL control (interactive map canvas)
#include "GisTypesUI.hpp"            // UI-specific types (TGIS_ViewerMode, etc.)

//---------------------------------------------------------------------------
/* Main application form for the Legend sample.
   Hosts a TGIS_ViewerWnd (map canvas) and a TGIS_ControlLegend panel
   side-by-side, separated by a resizable splitter. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TToolBar *ToolBar1 ;
    TGIS_ViewerWnd *GIS ;             // The main interactive map canvas
    TStatusBar *StatusBar1 ;          // Displays current map scale after each paint
	TImageList *ImageList1 ;          // Toolbar button icons
	TToolButton *btnFullExtent ;      // Zooms to the full extent of all loaded layers
	TToolButton *ToolButton2 ;        // Separator
	TToolButton *btnZoom ;            // Switches viewer to Zoom interaction mode
	TToolButton *btnDrag ;            // Switches viewer to Drag/Pan interaction mode
	TGIS_ControlLegend *GIS_ControlLegend1 ; // Interactive legend panel linked to GIS viewer
	TToolButton *ToolButton1 ;        // Separator
	TTabControl *TabControl1;         // Tabs to switch legend display mode (Layers / Groups)
	TSplitter *Splitter1;             // Resizable divider between legend panel and map
    TSpeedButton *SpeedButton1;       // Save configuration button
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

