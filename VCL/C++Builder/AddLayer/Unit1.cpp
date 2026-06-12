//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// AddLayer Sample - Demonstrates how to programmatically add vector layers
// to a TatukGIS map viewer in a C++Builder VCL application.
//
// Key concepts illustrated:
//   - Creating TGIS_LayerSHP instances directly and adding them to the viewer
//     via GIS->Add().
//   - Setting visual rendering parameters (line colour, line width, line
//     outline width) through the Params property tree on each layer.
//   - Suppressing automatic .ttkgp config-file loading with UseConfig = False
//     so that the layer always starts with the explicitly assigned params.
//   - Fitting the viewport to all loaded layers with GIS->FullExtent().
//   - Switching the viewer interaction mode between Drag (pan) and Select.
//   - Zooming programmatically by multiplying or dividing GIS->Zoom.
//
//  Check project\options\directories in case of any problems during compilation.
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"  // Uncomment when deploying with a runtime licence unit
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

/**
 * FormCreate
 *
 * Called once by the VCL framework immediately after the form and all its
 * designer-managed controls have been constructed.  This is the right place
 * to load map layers so that the viewer is populated before the user sees
 * the window.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  // --- Layer 1: Country outline (polygon / area layer) ---
  // Construct the layer directly.  TGIS_LayerSHP wraps an ESRI Shapefile;
  // the geometry type (polygon here) is determined automatically from the
  // .shp file header when the layer is first accessed by the viewer.
  ll = new TGIS_LayerSHP;

  // GisSamplesDataDirDownload() returns the root path where TatukGIS sample
  // datasets were installed or downloaded (configured by the DK installer).
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\country.shp" ;

  // A human-readable label used in legends and layer lists.
  ll->Name = "country";

  // GIS->Add appends the layer to the internal stack.  Layers added earlier
  // are rendered first (drawn at the bottom of the visual stack).
  // Note: no explicit area colour is set here; the layer will use its
  // default style (or a saved .ttkgp config if one exists).
  GIS->Add(ll) ;

  // --- Layer 2: Rivers (polyline layer) ---
  // A second TGIS_LayerSHP instance is constructed for the rivers Shapefile.
  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\lwaters.shp" ;

  // UseConfig = False prevents the DK from loading a previously saved .ttkgp
  // configuration file for this layer, ensuring the rendering parameters we
  // set below take effect rather than any cached values from a prior session.
  ll->UseConfig = False ;

  // Params->Line controls the stroke appearance of polyline geometries.
  // OutlineWidth = 0 removes the contrasting halo normally drawn around lines,
  // yielding a clean single-colour stroke.
  ll->Params->Line->OutlineWidth = 0;

  // Width is in screen pixels at the reference zoom level.
  ll->Params->Line->Width = 3;

  ll->Params->Line->Color = TGIS_Color::Blue;

  GIS->Add(ll) ;

  // Zoom the viewport to the combined bounding box of all layers so the full
  // map is visible immediately after the form opens.
  GIS->FullExtent() ;

}
//---------------------------------------------------------------------------

/**
 * chkDragClick
 *
 * Toggles the viewer's active interaction mode when the checkbox state changes.
 *
 * TGIS_ViewerMode::Drag   – left-click and drag pans the map canvas.
 * TGIS_ViewerMode::Select – left-click picks the topmost feature under the cursor.
 */
void __fastcall TForm1::chkDragClick(TObject *Sender)
{
  if ( chkDrag->Checked ) {
     // Enable pan-drag mode so the user can scroll the map by dragging.
     GIS->Mode = TGIS_ViewerMode::Drag ;
  }
  else {
     // Revert to feature-selection mode.
     GIS->Mode = TGIS_ViewerMode::Select ;
  } ;
}
//---------------------------------------------------------------------------

/**
 * btnFullExtentClick
 *
 * Resets the viewport so that all loaded layers fit inside the viewer window.
 * Useful after the user has zoomed in and wants to return to the overview.
 */
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/**
 * btnZoomInClick
 *
 * Doubles the current zoom level.  The Zoom property is a linear scale factor
 * relative to the FullExtent view; doubling it halves the visible area.
 */
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   // Multiply the current zoom by 2 to zoom in by one step.
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

/**
 * btnZoomOutClick
 *
 * Halves the current zoom level, widening the visible area by a factor of two.
 */
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   // Divide the current zoom by 2 to zoom out by one step.
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------
