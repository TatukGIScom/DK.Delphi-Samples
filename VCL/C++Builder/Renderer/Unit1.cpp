//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Renderer sample (C++Builder VCL edition) — form implementation.
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
// The actual rendering definitions (symbol styles, colors, scale-dependent
// rules, etc.) live inside the renderer.ttkproject file.  This form simply
// loads that project and wires up the toolbar buttons so the user can
// navigate the map.
//
// Check project\options\directories in case of any problems during compilation.
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"  // Uncomment to embed a run-time license key
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

/// FormCreate — called when the form is first created.
/// Opens the renderer project file from the shared sample data directory so
/// the map is ready when the form appears.
///
/// GisSamplesDataDirDownload() (from GisUtils) returns the path to the
/// downloaded TatukGIS sample data set.  The second parameter (true) requests
/// that the viewer automatically zooms to full extent after opening.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
    // Load the pre-configured renderer project; all layer styles are embedded
    // in the .ttkproject file — no additional setup is required here.
    GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\renderer.ttkproject" , true );
}
//---------------------------------------------------------------------------

/// btnFullExtentClick — zooms the map out to show all loaded layers.
/// TGIS_ViewerWnd::FullExtent recomputes the bounding rectangle covering
/// every visible layer and adjusts the view accordingly.
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
    GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/// btnZoomClick — switches the viewer to Zoom interaction mode.
/// In Zoom mode the user can draw a rubber-band rectangle or use the scroll
/// wheel to zoom into a specific area.
/// TGIS_ViewerMode::Zoom is defined in GisTypesUI.hpp.
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

/// btnDragClick — switches the viewer to Drag (pan) interaction mode.
/// In Drag mode the user can click and drag the map to pan across the dataset.
/// TGIS_ViewerMode::Drag is defined in GisTypesUI.hpp.
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------
