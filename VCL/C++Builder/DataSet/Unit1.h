/*
 * DataSet sample — demonstrates TGIS_DataSet as a live bridge between a GIS vector layer
 * and a data-aware grid (TDBGrid).
 *
 * What the sample shows:
 *   - Loading a vector shapefile (California Counties) into the GIS viewer
 *   - Creating a TGIS_DataSet bound to the layer's attribute table
 *   - Connecting the DataSet to a TDBGrid via TDataSource
 *   - Bidirectional synchronization: grid rows ↔ map selection
 *   - Scrolling the grid auto-pans and zooms the viewer to the selected county
 *   - Grid displays all shape attributes in editable columns
 *   - Splitter control allows resizing viewer and grid panes
 *   - Real-time map-to-grid and grid-to-map interaction
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd              - main visual map control
 *   TGIS_LayerVector            - vector layer backing the data
 *   TGIS_DataSet                - attribute table bridge (implements TDataSet)
 *   TDataSource                 - VCL data binding connector
 *   TDBGrid                     - standard VCL data-aware grid control
 *   GIS_DataSet1AfterScroll     - selection change event
 *   TGIS_Extent                 - geographic bounding box for zoom-to
 *   Shape attributes            - grid columns bound to feature fields
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Grids.hpp>
#include <DB.hpp>
#include <DBGrids.hpp>
#include "GisDataSet.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
#include "GisDataSet.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS;
        TGIS_DataSet *GIS_DataSet1;
        TDataSource *DataSource1;
        TSplitter *Splitter1;
        TDBGrid *DBGrid1;
        void __fastcall GIS_DataSet1AfterScroll(TDataSet *DataSet); /* Pan/zoom to the selected county */
        void __fastcall FormCreate(TObject *Sender);                /* Load shapefile and bind dataset to grid */
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
