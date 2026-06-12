//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  Legend Sample - C++Builder VCL
//
//  Demonstrates how to use the TGIS_ControlLegend panel alongside a map viewer.
//  The legend control provides an interactive, dockable layer list that lets the
//  user toggle layer visibility, reorder layers, expand/collapse layer symbology,
//  and open layer property dialogs - all without writing any extra code.
//
//  Key concepts shown:
//    - Placing TGIS_ControlLegend next to TGIS_ViewerWnd and linking them via
//      the GIS_Viewer property so the legend reflects the loaded map automatically.
//    - Switching between two display modes at runtime:
//        * TGIS_ControlLegendMode::Layers  - flat list of every individual layer
//        * TGIS_ControlLegendMode::Groups  - tree grouped by layer group membership
//    - Opening a .ttkproject file that bundles multiple SHP layers together.
//    - Controlling the viewer interaction mode (Zoom / Drag).
//    - Persisting any layer-style changes back to the project file with SaveAll.
//    - Reflecting the current map scale in the status bar after each repaint.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"   // Uncomment when deploying with a commercial license key
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------

// TForm1 constructor - form components are initialised by the VCL framework
// using the DFM resource; no manual wiring is needed here.
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

// TForm1::FormCreate
// Called once when the form is first created.
// Opens the sample Poland multi-layer project so the map and legend are
// populated immediately without requiring user interaction.
// TGIS_ViewerWnd::Open() accepts a .ttkproject path; it loads all embedded
// layer references and refreshes the legend control automatically because
// GIS_ControlLegend1->GIS_Viewer is already pointed at GIS (set in the DFM).
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // Load the bundled Poland DCW project; GIS_ControlLegend1 will populate
  // its layer list automatically because it is linked to this viewer.
  GIS->Open( GisSamplesDataDirDownload() +  "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", true ) ;
}
//---------------------------------------------------------------------------

// TForm1::btnFullExtentClick
// Resets the map viewport to show all loaded layers at their combined extent.
// Useful after zooming into a specific area and wanting to return to the overview.
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  // Zoom out to fit the complete bounding box of all visible layers
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

// TForm1::btnZoomClick
// Switches the viewer to Zoom mode.
// In Zoom mode, a left-click-drag draws a rubber-band rectangle that the
// viewer zooms into; a right-click zooms back out by a fixed factor.
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  // TGIS_ViewerMode::Zoom: left-drag to zoom in, right-click to zoom out
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

// TForm1::btnDragClick
// Switches the viewer to Drag (pan) mode.
// In Drag mode the user pans the map by click-dragging, which is the most
// natural way to explore a map after zooming in.
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  // TGIS_ViewerMode::Drag: click-drag to pan the visible map extent
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

// TForm1::Button1Click
// Saves all layer configuration changes (symbology, visibility, order) back to
// the originating project or layer files.
// Guards against calling SaveAll on an empty viewer to avoid an error.
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  if ( GIS->IsEmpty ) return ;  // Nothing loaded - nothing to save

  // Persist any legend changes (visibility flags, symbology edits, layer order)
  // back to the .ttkproject file and its referenced layer files.
  GIS->SaveAll() ;
}
//---------------------------------------------------------------------------

// TForm1::GISAfterPaint
// Fired by TGIS_ViewerWnd after every completed map repaint.
// Updates the status bar with the human-readable map scale string
// (e.g. "1 : 250 000") so the user always knows the current zoom level.
void __fastcall TForm1::GISAfterPaint(TObject *_sender, TObject *_canvas)
{
  // ScaleAsText returns a formatted "1 : N" string for the current viewport
  StatusBar1->SimpleText = GIS->ScaleAsText ;
}
//---------------------------------------------------------------------------

// TForm1::TabControl1Change
// Switches the legend control between its two display modes when the user
// selects a different tab:
//   Tab 0 (Layers) - shows a flat, ordered list of every individual layer.
//                    Useful when the user wants to manage individual layers.
//   Tab 1 (Groups) - shows layers organised into their logical group hierarchy.
//                    Useful when the project uses group layers to structure data.
// Both modes support the same interactive features (visibility toggle,
// drag-to-reorder, expand to see symbology classes, double-click for properties).
void __fastcall TForm1::TabControl1Change(TObject *Sender)
{
  if ( TabControl1->TabIndex == 0 )
    // Flat mode: each layer appears as a separate top-level item
    GIS_ControlLegend1->Mode = TGIS_ControlLegendMode::Layers ;
  else
    // Grouped mode: layers are nested inside their parent group nodes
    GIS_ControlLegend1->Mode = TGIS_ControlLegendMode::Groups ;
}
//---------------------------------------------------------------------------
