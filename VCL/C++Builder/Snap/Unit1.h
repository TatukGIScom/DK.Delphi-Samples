//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  Snap sample — demonstrates snapping functionality during shape editing (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading map layer with road network (street features)
//    - Creating animated tracking of a moving point (vehicle marker / police car)
//    - Two tracking modes:
//      * Free movement: point moves without constraint
//      * Snapped movement: point automatically snaps to nearest road feature
//    - Using TGIS_Shape.SetPosition() with optional target layer parameter
//    - Snap tolerance distance configuration
//    - Real-time snapping during animation
//    - Comparing free vs. snapped trajectory visually
//    - Animating point along predefined path
//    - Handling snap failures (no valid snap target)
//    - Using timer for smooth animation updates
//    - Displaying movement statistics and position tracking
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - source layer with features for snapping
//    TGIS_Shape.SetPosition()    - update shape location (with or without snap)
//    Snap target layer           - features to snap to
//    Snap tolerance              - search radius for snap candidates
//    Coordinate snapping         - automatic point projection onto target geometry
//    Animation timer             - periodic position updates
//    Trajectory visualization    - comparing movement paths
//    Free vs. snapped movement   - demonstrating snap effect
//    Snap-to-feature             - alignment with road network or boundaries
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
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TButton *btnWithoutSnapping;
  TButton *btnWithSnapping;
  TGIS_ViewerWnd *GIS;
  TTimer *tmrWithoutSnapping;
  TTimer *tmrWithSnapping;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall FormDestroy(TObject *Sender);
  void __fastcall tmrWithoutSnappingTimer(TObject *Sender);
  void __fastcall btnWithSnappingClick(TObject *Sender);
  void __fastcall tmrWithSnappingTimer(TObject *Sender);
  void __fastcall btnWithoutSnappingClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
    TPicture    *pctPolice; // police car bitmap
    TGIS_Shape  *shpPolice; // police shape
    int         cntPoint;  // number of evaluated points
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
