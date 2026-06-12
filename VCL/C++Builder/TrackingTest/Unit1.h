//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  TrackingTest sample — demonstrates animated tracking of GPS-like movement (C++Builder/VCL).
//
//  What the sample shows:
//    - Creating an in-memory vector layer to hold a tracked object (vehicle marker)
//    - Programmatically animating a point shape moving along a predefined path
//    - Using a timer to update shape position at regular intervals
//    - Rotating the symbol to face the direction of movement (heading)
//    - Calculating movement vector and bearing from current and previous positions
//    - Optionally locking the viewer extent to follow the tracked object
//    - Implementing BusyEvent callback to update animation progress
//    - Displaying tracking status in viewer (current position, heading, speed)
//    - Using TGIS_Params to control symbol appearance and colour
//    - Toggling lock mode (Projection vs Extent) for tracking behavior
//    - Creating smooth animated movement across the map view
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - in-memory layer for tracked object
//    TGIS_Shape                  - the tracked point shape
//    TGIS_Shape.SetXY()          - update shape position
//    TGIS_Params.Marker          - point symbol properties (rotation, size, color)
//    Timer                       - animation update interval
//    OnExtentChanged             - event for viewer extent synchronization
//    VisibleExtent / SetExtent   - programmatically control viewer pan/zoom
//    TGIS_Lock                   - projection vs. extent locking for tracking
//    BusyEvent                   - progress notification during animation
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
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TCheckBox *chkUseLock;
  TButton *btnAnimate;
  TGIS_ViewerWnd *GIS;
  TToolButton *ToolButton1;
  TToolButton *ToolButton2;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall btnAnimateClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
