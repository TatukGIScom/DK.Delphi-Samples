//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/* Buffers1 sample — demonstrates spatial buffer operations for proximity analysis (C++Builder/VCL).

   What the sample shows:
     - Loading vector shapefiles into the GIS viewer
     - Creating in-memory vector layer to hold buffer results
     - Letting user click on shapes to select them as buffer source
     - Using TGIS_Topology::MakeBuffer to compute buffer polygons around shapes
     - Interactive buffer distance control via trackbar (range -50 to +50 km)
     - Negative buffer values produce inward/erosion buffers instead of expansion
     - Adding result shapes to buffer layer with automatic view refresh
     - Hit-testing with GIS->Locate to find clicked shapes
     - Converting pixel coordinates to map coordinates with ScreenToMap
     - Clearing previous buffer results with RevertShapes before adding new ones

   Key TatukGIS API concepts shown here:
     TGIS_ViewerWnd          - main visual map control
     TGIS_LayerVector        - in-memory or file-backed vector layer
     TGIS_Topology           - spatial operations (MakeBuffer, Intersection, Union, etc.)
     TGIS_Shape              - individual geographic feature (point, line, polygon)
     TGIS_Topology::MakeBuffer() - compute proximity buffer around shape
     GIS->Locate()           - hit-test at point to find topmost shape
     GIS->ScreenToMap()      - convert screen pixels to geographic coordinates
     TGIS_LayerVector::RevertShapes() - clear all shapes from layer
     TGIS_LayerVector::Add() - add result shape to layer
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* Main form for the Buffers1 sample.
   Loads a topology shapefile, lets the user click a shape to select it,
   then draws a buffer polygon around it whose distance is set by a slider. */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
        TGIS_ViewerWnd *GIS;         // Main map viewer control
        TToolBar       *ToolBar1;
        TStatusBar     *StatusBar1;
        TTrackBar      *TrackBar1;   // Buffer distance slider (-50..+50 km)
        TToolButton    *btnPlus;     // Increments slider by 1
        TToolButton    *btnMinus;    // Decrements slider by 1
        TImageList     *ImageList1;
        void __fastcall btnMinusClick(TObject *Sender);
        void __fastcall btnPlusClick(TObject *Sender);
        void __fastcall TrackBar1Change(TObject *Sender);
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
                  int X, int Y);
private:    // User declarations
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
        // shp_id stores the Uid of the shape currently chosen as the buffer
        // source.  Updated in GISMouseDown; read in TrackBar1Change.
        int shp_id;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
