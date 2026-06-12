//=============================================================================
// CustomPaint sample — demonstrates custom drawing overlays using paint-hook mechanisms (C++Builder/VCL).
//
// What the sample shows:
//   - Per-shape paint-hook via PaintShapeEvent for custom shape rendering
//   - Replacing default shape rendering with custom graphics primitives
//   - Converting shape geographic position to screen pixels with MapToScreen
//   - Drawing rectangles, ellipses, text, and bitmaps with TGIS_RendererAbstract
//   - Viewer-level paint-hook via PaintExtraEvent for map-wide overlays
//   - Rendering overlays on top of entire map (HUD text, watermarks, etc.)
//   - Accessing native renderer canvas handles (GDI+, GDI32, Direct2D, Skia)
//   - Calling platform-specific graphics APIs directly for advanced effects
//   - Switching between multiple renderer backends at runtime
//   - In-memory vector layer with invisible markers as custom drawing anchors
//   - Drawing different primitives based on shape attribute values
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerVector            - vector layer for custom shape storage
//   TGIS_Shape                  - individual geographic feature
//   PaintShapeEvent             - per-shape custom rendering callback
//   PaintExtraEvent             - viewer-level post-render overlay callback
//   TGIS_RendererAbstract       - platform-agnostic drawing interface
//   GIS->MapToScreen()          - convert geographic coords to screen pixels
//   RendererManager()           - access available rendering backends
//   TGIS_Bitmap                 - image for custom drawing from file
//   TGIS_Pixels                 - raw ARGB pixel array for direct drawing
//=============================================================================

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
#include <Direct2D.hpp>
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisRendererGdi32.hpp"
#include "VCL.GisRendererGdiPlus.hpp"
#include "VCL.GisRendererDirect2D.hpp"

// Delphi DX12 (RAD RX12)
#ifdef VER360
  #define LEVEL_RX12_VCL
#endif

#ifdef LEVEL_RX12_VCL
  #define SKIA
#endif

#ifdef SKIA
  #include "VCL.GisRendererSkia.hpp"
  #include <System.Skia.hpp>
#endif

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TGIS_ViewerWnd *GIS;     // main TatukGIS map viewer control
    TComboBox *cbRenderer;   // drop-down to switch the active rendering backend

    // Event handlers wired from the form designer
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall FormDestroy(TObject *Sender);
    void __fastcall cbRendererChange(TObject *Sender);
    // PaintExtraEvent: fires once per frame after all layers have rendered
    void __fastcall GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode);

private:	// User declarations

public:		// User declarations
    __fastcall TForm1(TComponent* Owner);

    // Fills the px pixel buffer with the 5x5 ARGB test image data
    void __fastcall initialize_pixels() ;

    // PaintShapeEvent callback: draws a custom primitive for each shape based
    // on the shape's "type" attribute field value.
    void __fastcall GISPaintShapeEvent(TObject *_sender, TGIS_Shape *_shape);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
