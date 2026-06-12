//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Topology Sample – Demonstrates polygon set-algebra operations using TGIS_Topology.
//
// This header declares TForm1, which hosts a TatukGIS map viewer and five
// toolbar buttons for the following boolean polygon operations:
//
//   A + B   : Union            – area covered by either A or B (or both)
//   A * B   : Intersection     – area covered by both A and B
//   A - B   : Difference       – area in A but not in B
//   B - A   : Difference       – area in B but not in A
//   A xor B : SymDifference    – area in A or B but not in both (exclusive OR)
//
// Key TatukGIS classes used:
//   TGIS_Topology            – engine that performs polygon boolean operations
//   TGIS_TopologyCombineType – scoped enum of the five combine modes
//   TGIS_LayerVector         – in-memory vector layer for result display
//   TGIS_ShapePolygon        – strongly-typed polygon shape handle
//   TGIS_ViewerWnd           – VCL map viewer control
//=============================================================================

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
#include "GisTopology.hpp"      // TGIS_Topology, TGIS_TopologyCombineType
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
/* Main form for the Topology sample application.
   Demonstrates the five polygon boolean (set-algebra) operations supported
   by TGIS_Topology: Union, Intersection, Difference (A-B),
   Difference (B-A), and Symmetrical Difference (XOR). */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TGIS_ViewerWnd *GIS;        // Map viewer – renders all loaded layers
    TToolBar *ToolBar1;
    TStatusBar *StatusBar1;
    TButton *btnAplusB;         // Union:               A + B
    TButton *btnAmultB;         // Intersection:        A * B
    TButton *btnAminusB;        // Difference:          A - B
    TButton *btnBminusA;        // Reverse difference:  B - A
    TButton *btnAxorB;          // Symmetrical diff:    A xor B
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnAplusBClick(TObject *Sender);
        void __fastcall btnAmultBClick(TObject *Sender);
        void __fastcall btnAminusBClick(TObject *Sender);
        void __fastcall btnBminusAClick(TObject *Sender);
        void __fastcall btnAxorBClick(TObject *Sender);
private:    // User declarations
    // The topology engine used to compute polygon boolean operations
    TGIS_Topology  *topologyObj ;
    // In-memory output layer; receives the result shape after each operation
    TGIS_LayerVector  *layerObj ;
    // Two source polygons loaded from the shapefile (shape indices 1 and 2)
    TGIS_ShapePolygon  *shpA ;
    TGIS_ShapePolygon  *shpB ;
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

