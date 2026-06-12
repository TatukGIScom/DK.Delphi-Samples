//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
  Zooming Sample — Interactive viewer navigation with multiple zoom control methods.

  Key concepts illustrated:
    - Full extent navigation: fit all features to viewport
    - Zoom mode: rectangular selection for custom zoom areas
    - Drag mode: pan/translate the visible map area
    - Mouse wheel zoom: in/out with cursor-anchored scaling
    - Zoom anchoring: cursor position remains fixed during zoom
    - ZoomBy method: multiply zoom by factor (5/4 = 25% in, 4/5 = 20% out)
    - Viewer mode switching: TGIS_ViewerMode enum
    - Mouse event interception: wheel up/down handlers

  Zoom control methods:
    1. Toolbar buttons: switch between Full Extent, Zoom, Drag modes
    2. Mouse wheel: zoom in/out with scroll wheel (any time)
    3. Rectangular selection: in Zoom mode, draw box to zoom to area
    4. Pan: in Drag mode, hold and drag to move viewport

  Mouse wheel behavior (cursor-anchored):
    - Wheel up (scroll up): zoom in by 5/4 (25% closer)
    - Wheel down (scroll down): zoom out by 4/5 (20% farther)
    - Anchor point: current mouse cursor position
    - During zoom: cursor stays at same screen location while map scales
    - Result: intuitive zoom centered at pointer location
*/

//  How to provide zoom on mouse drag
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
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

/*
  FormCreate
  Initializes the sample by loading a project file (Poland map).

  Steps:
    1. Build full path to sample project file
    2. Open project into the GIS viewer
    3. Viewer automatically renders all layers from the project
*/
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // Load Poland project (borders, administrative regions)
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
}
//---------------------------------------------------------------------------

/*
  btnFullExtentClick
  Fits the entire map to the viewport (zooms to show all features).

  Action: Calls FullExtent() which calculates extent of all layers
          and adjusts viewport to show everything
*/
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  // Zoom to fit all features in the viewport
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/*
  btnZoomClick
  Switches viewer to Zoom mode: user can draw a rectangle to zoom into an area.

  Action: Sets Mode to TGIS_ViewerMode::Zoom
          User then draws rectangle on map to zoom to that area
*/
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  // Set viewer to zoom mode (rectangle selection)
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

/*
  btnDragClick
  Switches viewer to Drag mode: user can pan/move the map view.

  Action: Sets Mode to TGIS_ViewerMode::Drag
          User can hold and drag mouse to pan the visible area
*/
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  // Set viewer to drag mode (panning)
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

/*
  GISMouseWheelDown
  Handles mouse wheel scroll down: zooms out by 20% with cursor-anchored zoom.

  Algorithm:
    1. Guard: skip if viewer is empty
    2. Convert screen coordinates to client coordinates (relative to viewer)
    3. Call ZoomBy with factor 4/5 (0.8 = 20% zoom out)
    4. Anchor point: current mouse cursor position (pt.x, pt.y)
    5. Mark event as handled to prevent other handlers

  Zoom factor: 4/5 means multiply current zoom by 0.8 (20% reduction)
  Cursor anchoring: position stays at same screen location during zoom
*/
void __fastcall TForm1::GISMouseWheelDown(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  TPoint  pt;

  // Guard: skip if no layers loaded
  if ( GIS->IsEmpty ) return ;

  // Convert screen coordinates to viewer client area coordinates
  pt = GIS->ScreenToClient( MousePos ) ;

  // Zoom out by 20% (factor 4/5 = 0.8) with cursor anchor point
  GIS->ZoomBy( 4./5., pt.x, pt.y );
  // Mark event as handled (don't propagate to other handlers)
  Handled = true ;
}
//---------------------------------------------------------------------------

/*
  GISMouseWheelUp
  Handles mouse wheel scroll up: zooms in by 25% with cursor-anchored zoom.

  Algorithm:
    1. Guard: skip if viewer is empty
    2. Convert screen coordinates to client coordinates
    3. Call ZoomBy with factor 5/4 (1.25 = 25% zoom in)
    4. Anchor point: current mouse cursor position (pt.x, pt.y)
    5. Mark event as handled

  Zoom factor: 5/4 means multiply current zoom by 1.25 (25% increase)
  Cursor anchoring: position stays at same screen location during zoom
*/
void __fastcall TForm1::GISMouseWheelUp(TObject *Sender, TShiftState Shift,
      TPoint &MousePos, bool &Handled)
{
  TPoint  pt;

  // Guard: skip if no layers loaded
  if ( GIS->IsEmpty ) return ;

  // Convert screen coordinates to viewer client area coordinates
  pt = GIS->ScreenToClient( MousePos ) ;

  // Zoom in by 25% (factor 5/4 = 1.25) with cursor anchor point
  GIS->ZoomBy( 5./4., pt.x, pt.y );
  // Mark event as handled
  Handled = true ;
}
//---------------------------------------------------------------------------

