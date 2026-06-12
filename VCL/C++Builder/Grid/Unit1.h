//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Grid Sample (C++Builder / VCL edition)
//
// Demonstrates how to manipulate a raster grid (DEM) layer presentation.
//
// This sample shows:
//   - Loading a DEM (NED - National Elevation Dataset) in ArcInfo Binary Grid
//     (.adf) format via TGIS_ViewerWnd::Open.
//   - Clearing and redefining altitude colour zones (AltitudeMapZones) that
//     map elevation ranges to named colours, creating a hypsometric tint.
//   - Loading display parameters from an external INI configuration file via
//     ConfigName / RereadConfig.
//   - Toggling hill-shading (GridShadow) to give the terrain a 3-D look.
//   - Reading the raw elevation value at the mouse position using
//     TGIS_LayerPixel::Locate and displaying it in the status bar.
//
// Key TatukGIS API classes used:
//   TGIS_ViewerWnd   - VCL map viewer control
//   TGIS_LayerPixel  - raster/grid layer (DEM, imagery, etc.)
//   TGIS_ControlLegend - layer list / legend panel
//   GisSamplesDataDirDownload() - utility to locate sample data
//
// Check project->Options->Directories if you encounter linker problems.
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
/* Main form for the Grid sample application.
   Loads a DEM raster layer and allows the user to experiment with
   altitude colour zones, hill-shading, and INI-based configuration. */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
        TGIS_ViewerWnd *GIS;            // Main map viewer control
        TStatusBar *StatusBar1;         // Shows current cursor elevation in panel[1]
        TSplitter *Splitter1;
        TToolBar *ToolBar1;
        TToolButton *btnFullExtent;     // Zoom to full map extent
        TToolButton *btnZoom;           // Activate rubber-band zoom mode
        TToolButton *btnDrag;           // Activate pan/drag mode
        TButton *btnClear;              // Remove all custom altitude zones
        TButton *btnShadow;             // Toggle hill-shading (GridShadow) on/off
        TButton *btnUserDefined;        // Apply a hard-coded altitude colour scheme
        TButton *btnUserIni;            // Load the bundled sample INI colour config
        TButton *btnReloadIni;          // Reload config from the layer's own INI file
        TGIS_ControlLegend *GIS_ControlLegend1;  // Layer list / legend panel
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
private:    // User declarations
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
