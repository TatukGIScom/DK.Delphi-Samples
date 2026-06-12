//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * JoinAndChart sample - demonstrates joining external database tables to
 * vector layers and rendering thematic charts (pie/bar) on map features.
 *
 * What the sample shows:
 *   - Loading a world country shapefile and connecting to an external ADO database
 *     containing economic data (values, sizes, chart types) indexed by country code
 *   - Creating a join between layer features and database records via a common key field
 *   - Rendering vector shapes as charts: the chart type and values vary per feature
 *   - Switching chart types via UI dropdown (area, population, custom metrics)
 *   - Adjusting chart size scaling dynamically
 *   - Performing spatial queries on the layer to select features by location
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd    - main visual map control
 *   TGIS_LayerSHP     - vector layer with database join capability
 *   TGIS_LayerVector  - base class for vector operations
 *   Database joins    - connecting external data via ODBC/ADO connections
 *   TGIS_Params       - layer rendering parameters including chart display
 *   ADO connections   - ADODB for database access and SQL queries
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <utilcls.h>
#include <ADODB.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* JoinAndChart sample — demonstrates joining layer attributes with external data sources and visualizing
   relationships through proportional symbol charting. Joins a map layer with an OleDb database table, then
   renders pie, bar, or column charts at each feature location with size and value fields controlling the
   chart appearance. Users can switch between different chart types and data fields via dropdown selectors. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TToolBar *ToolBar1;
    TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TComboBox *cmbValues;
	TComboBox *cmbSize;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	TToolButton *btnZoomOut;
	TToolButton *ToolButton1;
	TToolButton *ToolButton2;
	TToolButton *ToolButton3;
	TComboBox *cmbStyle;
	TADOConnection *ADOConnection;
	TADOQuery *ADOQuery;
		void __fastcall FormDestroy(TObject *Sender);
		void __fastcall btnFullExtentClick(TObject *Sender);
		void __fastcall btnZoomInClick(TObject *Sender);
		void __fastcall btnZoomOutClick(TObject *Sender);
		void __fastcall cmbChange(TObject *Sender);
		void __fastcall FormCreate(TObject *Sender);
public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
