//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/* AddLayer sample — demonstrates dynamic layer addition and visual parameter configuration (C++Builder/VCL).

   What the sample shows:
     - Programmatically creating a TGIS_LayerSHP instance for vector data
     - Adding layers to the viewer via GIS->Add() method
     - Using GisCreateLayer factory to auto-detect layer type from file extension
     - Setting visual rendering parameters: fill colour, line width, outline, line colour
     - Disabling automatic .ttkgp config-file loading with UseConfig property
     - Applying customised parameters so layers display as explicitly configured
     - Fitting viewport to all loaded layers with GIS->FullExtent()
     - Switching viewer interaction modes: Drag (pan) vs. Select (click features)
     - Zooming programmatically by scaling current Zoom value up/down

   Key TatukGIS API concepts shown here:
     TGIS_ViewerWnd          - main visual map control
     TGIS_LayerSHP           - vector layer for ESRI Shapefiles
     GisCreateLayer()        - factory function for automatic layer type detection
     TGIS_Params             - layer styling and rendering parameters
     TGIS_Params->Params     - nested property tree for symbol/fill/line customisation
     GIS->Add()              - adds a layer to the viewer
     GIS->FullExtent()       - zoom to combined extent of all loaded layers
     TGIS_ViewerMode         - interaction modes (Drag, Select, Zoom)
*/
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
#include <DB.hpp>
#include "GisViewer.hpp"         // Base viewer infrastructure
#include "VCL.GisViewerWnd.hpp"  // VCL-hosted map viewer control (TGIS_ViewerWnd)
#include "GisLayerSHP.hpp"       // ESRI Shapefile layer (TGIS_LayerSHP)
#include "GisTypesUI.hpp"        // UI types including TGIS_ViewerMode

//---------------------------------------------------------------------------
/* AddLayer sample — demonstrates how to programmatically add vector layers to a GIS viewer.
   Creates shapefile layers (TGIS_LayerSHP) for country polygons and rivers polylines, sets visual
   styling parameters (fill color, line width, line color), and adds them to the viewer using GIS->Add().
   Provides zoom navigation and interaction mode switching (pan/select). */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    /// The main TatukGIS map viewer control.  All layers are added here;
    /// it handles rendering, hit-testing, and user interaction.
    TGIS_ViewerWnd *GIS;
    TStatusBar     *StatusBar1;
    TToolBar       *Toolbar1;
    TToolButton    *btnFullExtent;   // Resets viewport to show all layers
    TToolButton    *btnZoomIn;       // Doubles the zoom level
    TToolButton    *btnZoomOut;      // Halves the zoom level
    TToolButton    *ToolButton4;     // Separator
    /// Checkbox that toggles between Drag (pan) and Select interaction modes.
    TCheckBox      *chkDrag;
    TImageList     *ImageList1;

    void __fastcall FormCreate(TObject *Sender);
    void __fastcall chkDragClick(TObject *Sender);
    void __fastcall btnFullExtentClick(TObject *Sender);
    void __fastcall btnZoomInClick(TObject *Sender);
    void __fastcall btnZoomOutClick(TObject *Sender);

private:    // User declarations
public:     // User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
