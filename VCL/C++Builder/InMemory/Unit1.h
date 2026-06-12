//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * InMemory sample — demonstrates creating and populating vector layers
 * programmatically at runtime without reading from files.
 *
 * What the sample shows:
 *   - Creating an in-memory TGIS_LayerVector with custom symbol styling
 *   - Dynamically adding point, polyline, and polygon shapes with random
 *     coordinates, colors, and rotations
 *   - All data is generated and stored in memory without file I/O
 *   - Useful for real-time data visualization and dynamic feature creation
 *   - Setting layer-wide rendering parameters (transparency, line width, etc.)
 *   - Programmatic shape creation using TGIS_Shape vertices and properties
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_LayerVector        - in-memory vector layer with dynamic features
 *   TGIS_Shape              - geographic feature (point, line, or polygon)
 *   TGIS_ShapeType          - enumeration for shape geometry types
 *   AddField / TGIS_Lock    - schema management and shape editing
 *   TGIS_ViewerWnd          - main visual map control
 *   Params                  - layer rendering parameters and styling
 *   GIS.FullExtent()        - zoom to fit all layer geometry
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
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
/* InMemory sample — demonstrates creating and populating vector layers programmatically at runtime.
   Creates an in-memory TGIS_LayerVector with custom symbol styling, then dynamically adds point, polyline,
   and polygon shapes with random coordinates, colors, and rotations. All data is generated and stored
   in memory without reading from files; useful for real-time data visualization and dynamic feature creation. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1 ;
        TToolBar *ToolBar1 ;
        TButton *Button1 ;
        TButton *Button2 ;
        TButton *Button3 ;
        TGIS_ViewerWnd *GIS ;
        TButton *Button4 ;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall Button2Click(TObject *Sender);
        void __fastcall Button3Click(TObject *Sender);
        void __fastcall Button4Click(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
