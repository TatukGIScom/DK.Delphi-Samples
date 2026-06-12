//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  Relate sample — demonstrates spatial relationships between geometries using
//  DE-9IM topology predicates (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading vector layer(s) into viewer
//    - Selecting a reference shape via mouse click
//    - Querying spatial relationships between reference shape and all other shapes
//    - Testing topological relationships:
//      * Equals: same geometry
//      * Disjoint: no overlap or touching
//      * Touches: boundaries touch but no overlap
//      * Contains: reference contains target shape
//      * Within: reference shape is within target
//      * Overlaps: partial geometric overlap
//      * Crosses: geometries cross each other
//      * Intersects: any type of spatial overlap
//    - Displaying related shapes with highlighting in different color
//    - Showing relationship results in text format (DE-9IM matrix)
//    - Testing multiple relationships simultaneously
//    - Counting matches per relationship type
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - vector layer with features to test
//    TGIS_Shape                  - reference shape for relationship testing
//    TGIS_Topology.Relate()      - compute DE-9IM relationship matrix
//    Spatial predicates          - Equals, Disjoint, Touches, Contains, Within, Overlaps, Crosses, Intersects
//    DE-9IM (Dimensionally Extended 9-Intersection Model) - topology relationship standard
//    FindFirst / FindNext        - feature enumeration for relationship testing
//    Relationship filtering      - finding shapes matching specific relationships
//    Color highlighting          - visualizing result geometries
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
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TStatusBar *StatusBar1;
  TPanel *paLeft;
  TGroupBox *gbShapes;
  TGroupBox *GroupBox1;
  TMemo *Relations;
  TLabel *Label1;
  TLabel *ShapeA;
  TLabel *Label3;
  TLabel *ShapeB;
  TButton *btnCheck;
  TGIS_ViewerWnd *GIS;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall btnCheckClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  TGIS_Shape *shpA;
  TGIS_Shape *shpB;
  TGIS_Shape *currshape;

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
