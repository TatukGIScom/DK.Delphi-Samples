//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Fields sample — demonstrates attribute field creation and data-driven rendering (C++Builder/VCL).
//
// What the sample shows:
//   - Defining custom attribute fields on in-memory vector layer via AddField
//   - Field properties: name, type (TGIS_FieldType), width, decimal precision
//   - Writing field values to individual shapes via TGIS_Shape::SetField
//   - Data-driven rendering using "FIELD:<name>" expression syntax
//   - Per-attribute colour assignment via field values
//   - Per-attribute size control via field values
//   - Per-attribute rotation via field values
//   - Label text from field values
//   - Label positioning from field values
//   - Exposing layer attribute table via TGIS_DataSet
//   - Displaying attributes in TDBGrid (database-bound grid control)
//   - Interactive grid editing with automatic map refresh
//   - Lock types: Projection (layer CS) vs Extent (world coordinates)
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerVector            - vector layer with attribute schema
//   TGIS_LayerVector::AddField() - define custom attribute field
//   TGIS_FieldType              - data type enumeration (String, Integer, Date, etc.)
//   TGIS_Shape::SetField()      - update feature attribute value
//   TGIS_DataSet                - attribute table accessor
//   "FIELD:<name>" expression   - dynamic rendering based on field value
//   TGIS_Params->Marker         - point symbol parameters (colour, size, rotation)
//   TGIS_Params->Line           - line rendering parameters
//   TGIS_Params->Area           - polygon fill parameters
//   TGIS_Params->Labels         - label text and positioning
//   TGIS_Lock                   - coordinate system locking (Projection vs Extent)
//
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"   // TGIS_ViewerWnd: the main map viewer control
#include "GisLayerSHP.hpp"
#include "GISRegistredLayers.hpp"
#include "VCL.GisControlLegend.hpp" // TGIS_ControlLegend: legend / layer-tree panel
#include "GisDataSet.hpp"           // TGIS_DataSet: exposes a layer as a VCL TDataSet
#include "GisUtils.hpp"             // GisPoint(), GisSamplesDataDirDownload(), SymbolList(), etc.
#include <DBGrids.hpp>              // TDBGrid: shows attribute rows via DataSource/TGIS_DataSet
#include <Grids.hpp>
#include "GisTypesUI.hpp"           // TGIS_LabelPosition, ConstructParamPosition

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TDBGrid              *DBGrid1;            // Database-bound grid showing the layer's attribute table
    TGIS_ViewerWnd       *GIS;               // Main interactive map viewer control
    TGIS_ControlLegend   *GIS_ControlLegend; // Legend panel bound to the created layer
    TGIS_DataSet         *GIS_DataSet1;      // Bridges the vector layer to DBGrid1 via DataSource1
    TStatusBar           *StatusBar1;        // Bottom status bar
    TToolBar             *ToolBar1;
    TButton              *CreateLayerButton; // Triggers CreateLayerButtonClick
    TToolButton          *ToolButton1;
    TCheckBox            *chkUseSymbols;     // When checked, CGM symbol files are used
    TDataSource          *DataSource1;       // VCL data source linking TGIS_DataSet to DBGrid1

    // CreateLayerButtonClick: main demo logic - creates fields, shapes, rendering params
    void __fastcall CreateLayerButtonClick(TObject *Sender);

    // GIS_DataSet1AfterPost: called when a DBGrid row edit is committed;
    // invalidates the map so changes are immediately visible in the viewer
    void __fastcall GIS_DataSet1AfterPost(TDataSet *DataSet);

private:    // User declarations
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
