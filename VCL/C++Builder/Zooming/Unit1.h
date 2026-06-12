//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to provide zoom on mouse drag
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/*
  Zooming Sample — Demonstrates comprehensive viewer navigation and zoom control techniques.

  Key concepts illustrated:
    - Full extent zoom: fit entire map to viewport
    - Zoom mode: rectangular selection to define zoom area
    - Drag mode: pan/move the map
    - Mouse wheel zoom: in/out with cursor anchor point
    - Zoom anchoring: keeping cursor position fixed during zoom operations
    - Zoom factor: viewport scaling via GIS.Zoom property
    - Viewer mode switching: TGIS_ViewerMode::Zoom vs. Drag vs. Select
    - Mouse event handling: wheel up/down with position tracking

  User workflow:
    1. Load a shapefile (California counties)
    2. Click "Full Extent" to fit map to viewport
    3. Click "Zoom" button, then draw rectangle to zoom into area
    4. Click "Drag" button to pan/move the map
    5. Use mouse wheel up/down to zoom in/out (cursor position is anchor point)
    6. Status bar shows cursor coordinates in map units

  Navigation modes:
    - Full Extent: TGIS_ViewerWnd::FullExtent() fits all features
    - Zoom Mode: draw rectangle, viewport zooms to that area
    - Drag Mode: hold and move mouse to pan the view
    - Wheel Zoom: scroll wheel in/out with cursor-anchored zoom center

  Key API:
    - TGIS_ViewerWnd::Mode: switch between navigation modes
    - TGIS_ViewerWnd::Zoom: get/set current zoom factor
    - TGIS_ViewerWnd::FullExtent(): fit viewport to all features
    - TGIS_ViewerMode: enum for mode selection (Zoom, Drag, Select)
    - GISMouseWheelUp/Down: handle mouse wheel events with position
    - ScreenToMap: convert pixel coordinates to map coordinates

  Mouse wheel behavior:
    - Wheel up: zoom in (Zoom *= 1.5 or similar)
    - Wheel down: zoom out (Zoom /= 1.5 or similar)
    - Anchor point: current cursor position stays in same screen location
    - Smooth navigation: cursor-relative zoom calculation
*/
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TStatusBar *StatusBar1 ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoom ;
        TToolButton *btnDrag ;
        TImageList *ImageList1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomClick(TObject *Sender);
        void __fastcall btnDragClick(TObject *Sender);
        void __fastcall GISMouseWheelDown(TObject *Sender,
          TShiftState Shift, TPoint &MousePos, bool &Handled);
        void __fastcall GISMouseWheelUp(TObject *Sender, TShiftState Shift,
          TPoint &MousePos, bool &Handled);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
