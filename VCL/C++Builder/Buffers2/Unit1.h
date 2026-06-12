//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
  Buffers2 - Advanced buffer operation with spatial intersection query.

  This sample extends the Buffers1 concept by demonstrating how to combine
  TGIS_Topology.MakeBuffer with a spatial search to find all features that
  intersect the resulting buffer polygon.

  What the sample shows:
    - Loading a real-world county shapefile (California counties) into the viewer
    - Creating a separate in-memory overlay layer (TGIS_LayerVector) to hold
      the buffer polygon, styled with a semi-transparent yellow fill
    - Using TGIS_LayerVector.FindFirst with an attribute filter (NAME='Merced')
      to locate a specific county as the buffer source shape
    - Computing a planar buffer around that county with TGIS_Topology.MakeBuffer
    - Using TGIS_LayerVector.FindFirst / FindNext with the buffer's extent
      as a spatial pre-filter, then refining with TGIS_Shape.IsCommonPoint
    - Visually marking intersecting counties blue and listing their names in
      a Memo control
    - Using a TTimer to debounce rapid track-bar changes

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd      - the main visual map control
    TGIS_LayerVector    - a file-backed or in-memory vector layer
    TGIS_Topology       - utility class for spatial operations (MakeBuffer, etc.)
    TGIS_Shape          - a single geographic feature (point, line, or polygon)
    FindFirst / FindNext - iterator pair for querying shapes within a layer
    IsCommonPoint       - precise overlap test for determining shape intersection
*/
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <Buttons.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:    // IDE-managed Components
        TGIS_ViewerWnd *GIS;         // Main map viewer control
        TTimer         *Timer1;      // Debounce timer (250 ms interval)
        TStatusBar     *StatusBar1;  // Shows buffer distance during drag
        TTrackBar      *TrackBar1;   // Buffer distance slider (0..200)
        TMemo          *Memo1;       // Lists intersecting county names
        TToolBar       *ToolBar1;
        TToolButton    *btnMinus;    // Decrements slider by 5
        TToolButton    *btnPlus;     // Increments slider by 5
        TImageList     *ImageList1;
        void __fastcall btnMinusClick(TObject *Sender);
        void __fastcall btnPlusClick(TObject *Sender);
        void __fastcall TrackBar1Change(TObject *Sender);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall FormCreate(TObject *Sender);
private:    // User declarations
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
