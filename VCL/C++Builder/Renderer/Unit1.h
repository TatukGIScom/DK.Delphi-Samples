//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Renderer sample (C++Builder VCL edition) — form header.
//
// Demonstrates how to load and display a TatukGIS project file that contains
// pre-configured custom rendering rules.
//
// Key concepts shown:
//   - Opening a .ttkproject file with TGIS_ViewerWnd->Open
//   - Switching the viewer interaction mode between Zoom and Drag via
//     TGIS_ViewerMode::Zoom / TGIS_ViewerMode::Drag
//   - Restoring the full map extent with TGIS_ViewerWnd->FullExtent
//
// Check project\options\directories in case of any problems during compilation.
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
#include "GisViewer.hpp"          // Base viewer classes
#include "VCL.GisViewerWnd.hpp"   // VCL TGIS_ViewerWnd control
#include "GisTypesUI.hpp"         // TGIS_ViewerMode enumeration

//---------------------------------------------------------------------------
/// TForm1 — main application form for the Renderer sample.
/// Hosts the TGIS_ViewerWnd map control together with a toolbar that
/// provides Full-Extent, Zoom, and Drag navigation buttons.
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TToolBar        *ToolBar1;      // Navigation toolbar
    TGIS_ViewerWnd  *GIS;           // TatukGIS VCL map viewer control
    TStatusBar      *StatusBar1;    // Status bar (coordinates, messages)
    TToolButton     *btnFullExtent; // Button: zoom to full map extent
    TToolButton     *btnZoom;       // Button: switch to Zoom interaction mode
    TToolButton     *btnDrag;       // Button: switch to Drag/pan interaction mode
    TToolButton     *ToolButton4;   // Toolbar separator
    TImageList      *ImageList1;    // Icons for toolbar buttons

    /// Called when the form is created; opens the renderer project file.
    void __fastcall FormCreate(TObject *Sender);
    /// Zooms the map to fit all loaded layers in the viewer.
    void __fastcall btnFullExtentClick(TObject *Sender);
    /// Switches the viewer to Zoom interaction mode.
    void __fastcall btnZoomClick(TObject *Sender);
    /// Switches the viewer to Drag/pan interaction mode.
    void __fastcall btnDragClick(TObject *Sender);

private:    // User declarations
public:     // User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
