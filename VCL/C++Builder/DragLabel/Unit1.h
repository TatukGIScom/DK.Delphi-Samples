//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * DragLabel sample - demonstrates how to construct interactively draggable
 * feature labels on a GIS map.
 *
 * What the sample shows:
 *   - Two parallel in-memory vector layers pattern:
 *     * "realpoints" - actual geographic point features rendered as CGM symbols (static)
 *     * "sidekicks" - invisible ghost points that carry draggable label text
 *   - PaintShapeLabelEvent callback (doLabelPaint) fires during paint cycle
 *   - Drawing leader lines connecting real points to floating labels
 *   - Manual drag implementation via editor control: MouseDown/Begin, MouseMove,
 *     MouseUp with SetPosition screen-to-map coordinate conversion
 *   - "Animate" button demonstrates programmatic 90-step movement synching
 *     realpoint and sidekick positions simultaneously
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd              - main visual map control
 *   TGIS_LayerVector            - in-memory vector layers
 *   TGIS_Shape                  - geographic feature with position control
 *   PaintShapeLabelEvent        - callback for custom label rendering
 *   TGIS_Editor                 - shape editing via mouse interaction
 *   ScreenToMap / MapToScreen   - coordinate system conversion
 *   DrawLabel                   - render label text at specific location
 */
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
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1 ;   // status bar at the bottom of the form
        TToolBar   *ToolBar1 ;     // toolbar housing the Animate button
        TGIS_ViewerWnd *GIS ;      // main TatukGIS map viewer control
        TButton    *Button1 ;      // "Animate" button

        // Event handlers wired from the form designer
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
        void __fastcall FormCreate(TObject *Sender);

private:	// User declarations
        // The sidekick shape currently being dragged; NULL when idle.
        TGIS_Shape *currShape ;

        // Moves both the real point and its matching sidekick by (_x, _y)
        // map units.  Used by the Animate button loop and indirectly by
        // mouse move handling.
        void synchroMove( TGIS_Shape *_shp, int _x, int _y ) ;

        // PaintShapeLabelEvent callback: draws the leader line and label
        // for each sidekick shape during the viewer's paint cycle.
        void __fastcall doLabelPaint( TObject * _sender, TGIS_Shape * _shape ) ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
