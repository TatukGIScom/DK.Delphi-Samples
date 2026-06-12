//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * Locate sample — demonstrates feature identification and location by finding
 * shapes at the cursor position using spatial queries and coordinate conversion.
 *
 * What the sample shows:
 *   - Loading a polygon shapefile (California Counties) into the GIS viewer
 *   - Feature location: finding which shape is at a given position
 *   - Screen-to-map coordinate conversion: ScreenToMap transforms pixel coordinates
 *   - Spatial tolerance: 5-pixel screen tolerance for easier feature selection
 *   - GIS.Locate: queries features at a geographic position
 *   - Shape attributes: retrieving field values from selected features
 *   - Shape flashing: visual feedback highlighting the selected shape
 *   - Dynamic status bar: real-time display of feature attributes
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd.ScreenToMap - convert screen pixel to geographic coordinate
 *   TGIS_ViewerWnd.Locate      - find topmost shape at location with tolerance
 *   TGIS_Shape                 - geographic feature with field access
 *   TGIS_Shape.Flash()         - briefly highlight shape for visual feedback
 *   OnMouseMove / OnMouseDown  - user interaction event handling
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
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* Locate sample — demonstrates how to locate shapes under the cursor using TGIS_Viewer.Locate.
   Loads a world map with USA state counties. When the user moves the mouse, Locate identifies
   the shape at that cursor position and displays the county name in the status bar. Clicking
   any shape causes it to flash. This technique is useful for interactive feature selection and
   information display in GIS applications. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TStatusBar *StatusBar ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TImageList *ImageList1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomInClick(TObject *Sender);
        void __fastcall btnZoomOutClick(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
