//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================


#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisGeometryFactory.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
//---------------------------------------------------------------------------
/*
  WKT Sample — Demonstrates WKT (Well-Known Text) geometry parsing and real-time visualization.

  Key concepts illustrated:
    - ISO SQL/MM WKT standard (Well-Known Text) geometry representation
    - Dynamic shape creation from text input (TGIS_Utils::GisCreateShapeFromWKT)
    - Real-time geometry validation and error handling (visual feedback)
    - Geometry types: Point, MultiPoint, LineString, MultiLineString, Polygon with holes
    - Vector layer manipulation (AddShape, RevertShapes, RecalcExtent)
    - Interactive geometry exploration with dropdown presets
    - Visual feedback for parsing errors (color-coded text)

  User workflow:
    1. Select geometry type from dropdown (Point, MultiPoint, LineString, MultiLineString, Polygon)
    2. View WKT text representation in memo
    3. Edit WKT text or change dropdown to update geometry
    4. Map updates in real-time with valid geometries
    5. Invalid WKT shows red text and empty map
    6. Zoom to fit geometry automatically

  WKT format examples:
    - POINT (30 30)
    - MULTIPOINT (4 4, 5 5, 6 6, 7 7)
    - LINESTRING (3 3, 10 10)
    - MULTILINESTRING ((1 1 3 3 4 4), (5 5 7 7))
    - POLYGON ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))

  Error handling:
    - Invalid WKT: text color changes to red
    - Parsing failure: shape not added to layer
    - Valid geometries: text black, shape rendered on map
    - Automatic zoom adjustment for new geometries

  Key API:
    - TGIS_Utils::GisCreateShapeFromWKT: parse WKT string to shape object
    - TGIS_LayerVector::AddShape: add parsed shape to layer
    - TGIS_LayerVector::RevertShapes: clear all shapes before re-adding
    - TGIS_LayerVector::RecalcExtent: update layer bounds
    - TGIS_ViewerWnd::FullExtent: zoom to fit all shapes
*/
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TMemo *Memo1;
        TGIS_ViewerWnd *GIS;
        TStatusBar *StatusBar1;
        TToolBar *ToolBar1;
        TComboBox *cbType;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall Memo1Change(TObject *Sender);
        void __fastcall cbTypeChange(TObject *Sender);
private:	// User declarations
  TGIS_LayerVector *layerObj ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
