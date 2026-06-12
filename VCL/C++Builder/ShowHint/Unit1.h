//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to display map hints.
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
#include <ToolWin.hpp>
#include <ImgList.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"

/*
  ShowHint Sample — Demonstrates dynamic tooltips showing feature attributes at cursor position.

  Key concepts illustrated:
    - Real-time feature detection under cursor (GIS.Locate)
    - Dynamic hint display with attribute field values
    - Hint timing and appearance customization (Application.HintHidePause, HintColor)
    - Screen coordinate to map coordinate conversion (ScreenToMap)
    - Feature flashing/highlighting on hover
    - Multiple hint layers support
    - Cursor position tracking (GISMouseMove)
    - Field name selection via configuration (hintField, hintLayer)

  User workflow:
    1. Move mouse over map
    2. When cursor over feature: hint shows selected attribute value
    3. Click "Hints" button to toggle hints on/off
    4. Tooltip disappears after mouse pause or on mouse leave
    5. Different colors for hints vs. standard VCL tooltips

  Hint display:
    - Shows attribute from configurable field (e.g., NAME, POPULATION)
    - Follows cursor closely
    - Automatically hides when cursor moves away from feature
    - Customizable color and timing
    - Layer-specific hints (hintLayer) for multi-layer maps

  Key API:
    - GIS.Locate: find shape at cursor position with tolerance
    - Shape.GetField: retrieve attribute value by field name
    - Application.HintHidePause: control hint duration
    - Screen coordinate to map: ScreenToMap method
    - Shape.Flash: visual highlight when hint appears

  Configuration:
    - hintField: attribute field name to display (e.g., "NAME")
    - hintLayer: which layer to show hints for
    - hintDisplay: toggle hints on/off
    - hintColor: custom hint background color
*/

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TStatusBar *StatusBar1;
  TGIS_ViewerWnd *GIS;
  TImageList *ImageList1;
  TToolButton *btnFullExtent;
  TToolButton *btnZoomIn;
  TToolButton *btnZoomOut;
  TToolButton *ToolButton4;
  TToolButton *btnHint;
  void __fastcall btnFullExtentClick(TObject *Sender);
  void __fastcall btnZoomInClick(TObject *Sender);
  void __fastcall btnZoomOutClick(TObject *Sender);
  void __fastcall btnHintClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall ToolBar1MouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
private:	// User declarations
public:		// User declarations
	String      hintField;          // Field name to display in hint (e.g., "NAME")
	String      hintLayer;          // Which layer to show hints for

    Boolean     hintDisplay;        // True = hints enabled, False = hints disabled
    TColor      hintColor;          // Custom hint background color
    TColor      hintColorStd;       // Standard VCL hint color (for fallback)

  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
