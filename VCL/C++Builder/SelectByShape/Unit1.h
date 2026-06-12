//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// SelectByShape sample — demonstrates how to select vector features by drawing
// an arbitrary shape (circle or rectangle) interactively on the map.
//
// Key concepts shown:
//   - Interactive rubber-band drawing of a selection shape on the GIS viewer
//     using mouse events and the PaintExtraEvent hook.
//   - Converting screen pixel coordinates to geographic map coordinates via
//     ScreenToMap so the drawn shape is in the layer's coordinate system.
//   - Building a circular selection area using TGIS_Topology::MakeBuffer, which
//     approximates a circle as a polygon around a point shape using a given
//     radius in map units.
//   - Building a rectangular selection polygon by manually adding four corner
//     points to a new polygon shape.
//   - Spatial query via TGIS_LayerVector::FindFirst / FindNext using the
//     RELATE_INTERSECT predicate (a DE-9IM relationship test) to find all
//     features that share at least one point with the selection shape.
//   - Visually highlighting matched features with IsSelected and listing their
//     "name" attribute in a memo control.
//
//  Check project\options\directories in case of any problems during compilation
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include <Vcl.Buttons.hpp>

//---------------------------------------------------------------------------
/* Main application form for the SelectByShape sample.
   Hosts the TatukGIS viewer control, two mode-toggle buttons (circle /
   rectangle), and a read-only text box that lists the names of the features
   found to intersect the drawn selection shape. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1;          // Status bar at the bottom of the form
        TMemo *Memo1;                    // Displays names of selected features
        TGIS_ViewerWnd *GIS;            // Main map viewer control
        TToolBar *ToolBar1;             // Toolbar hosting the mode buttons
        TSpeedButton *btnRect;          // Toggle: select by rectangle
        TSpeedButton *btnCircle;        // Toggle: select by circle
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
                TShiftState Shift, int X, int Y);
        void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
                int Y);
        void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button,
                TShiftState Shift, int X, int Y);
        void __fastcall GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
                  TGIS_DrawMode _mode);
private:	// User declarations
        // Anchor point where the user first pressed the mouse button (screen pixels)
        TPoint            oldPos1;
        // Current drag position used as the second corner of the rectangle (screen pixels)
        TPoint            oldPos2;
        Integer           oldColor;
        // Current radius of the rubber-band circle in screen pixels
        Integer           oldRadius ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
