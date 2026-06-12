//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  SplitbyArc sample — demonstrates polygon splitting using line/arc geometry (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading a polygon feature (county boundary) as source geometry
//    - Interactively drawing an arc/line to define split boundary
//    - Using TGIS_Topology.SplitByArc to divide polygon by line
//    - Handling polygon-line intersection detection
//    - Extracting resulting polygons from split operation
//    - Displaying original and split geometries in different colours
//    - Storing result geometries in in-memory layer
//    - Handling edge cases (non-intersecting line, complex polygons)
//    - Supporting both straight lines and curves as splitting tools
//    - Iterating through split result geometries
//    - Updating display and UI with operation results
//    - Assigning random colors to split fragments
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - in-memory layer for result geometries
//    TGIS_Shape / TGIS_ShapePolygon - polygon feature being split
//    TGIS_ShapeArc               - line/arc used as split boundary
//    TGIS_Topology.SplitByArc()  - polygon division operation
//    Polygon intersection        - detecting line-polygon overlap
//    Result geometry handling    - processing split output shapes
//    Multi-part geometry         - handling complex split results
//    Spatial operations          - polygon topology
//    User interaction            - drawing line for split operation
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include "GisTypes.hpp"
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
#include "System.Classes.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TPanel *paLeft;
  TGIS_ViewerWnd *GIS;
  TStatusBar *StatusBar1;
  TButton *btnLine;
  TButton *btnSplit;
  TGroupBox *gbAfterSplit;
  TLabel *lbInfo;
  void __fastcall btnLineClick(TObject *Sender);
  void __fastcall btnSplitClick(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
  void __fastcall GISMouseUp(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
  void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
    TGIS_LayerVector  *layerObj;        //layer for new shapes
    TGIS_ShapePolygon *shpPolygon;      //shape for split
    TGIS_ShapeArc     *shpArc;          //shape for line
    TGIS_LayerVector  *layerPolygon;
    TGIS_LayerVector  *layerArc;

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
