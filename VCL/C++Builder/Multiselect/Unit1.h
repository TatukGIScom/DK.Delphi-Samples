//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Multiselect sample — demonstrates selecting and manipulating multiple features (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a polygon or polyline layer into the GIS viewer
//   - Using the Select interaction mode to pick individual shapes on the map
//   - Selecting multiple shapes with Ctrl+click or Shift+click combinations
//   - Highlighting selected shapes with a distinct color overlay
//   - Displaying selected feature attributes in a grid control (TGIS_ControlAttributes)
//   - Querying the number of selected features
//   - Iterating through selected shapes to perform bulk operations
//   - Clearing the selection to start fresh
//   - Modifying attributes of all selected features simultaneously
//   - Deleting multiple selected shapes in one operation
//   - Using selection for spatial analysis queries
//   - Exporting selected features to a new layer or file
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control with selection support
//   TGIS_LayerVector            - vector layer for multiselection
//   TGIS_Shape                  - individual shape / feature object
//   IsSelected property          - shape selection state flag
//   SelectionColor              - highlight color for selected shapes
//   TGIS_ControlAttributes      - grid showing selected feature attributes
//   TGIS_ControlLegend          - legend for visual feedback
//   TGIS_ViewerMode.Select      - interaction mode for shape picking
//   Shift/Ctrl click            - multiple selection modifiers
//   Shape iteration             - looping through selected features
//   Bulk operations             - modifying/deleting multiple shapes
//
//  How to select several shapes
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
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "VCL.GisControlAttributes.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
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
  TPanel *panelRight;
  TListBox *lbSelected;
  TGIS_ControlAttributes *GIS_Attributes;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
		void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
		  TShiftState Shift, int X, int Y);
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
 
