//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// SQLWizard sample — demonstrates SQL layer creation via an interactive wizard (C++Builder/VCL).
//
// What the sample shows:
//   - Launching an interactive SQL layer wizard dialog
//   - Specifying database connection parameters and type
//   - Selecting spatial tables from the database
//   - Choosing geometry and attribute columns
//   - Configuring spatial reference systems
//   - Setting up layer filtering and field mapping
//   - Creating new SQL layer (.ttkls) definitions interactively
//   - Testing database connections before saving
//   - Applying the newly created layer to the viewer
//   - Managing multiple SQL layers in the project
//   - Saving layer definitions for future reuse
//   - Browsing available databases and tables
//   - Handling various SQL database backends
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerSqlAdo            - ADO-based SQL layer creation
//   TGIS_LayerSqlSqlite         - SQLite layer creation
//   TGIS_LayerSqlPostGis        - PostGIS layer creation
//   SQL Wizard dialog           - step-by-step layer configuration UI
//   Database connection         - server, port, user, password parameters
//   Table selection             - choosing source spatial table
//   Geometry column selection   - identifying the shape column
//   Spatial reference system    - setting EPSG code or well-known text
//   Layer configuration         - .ttkls file format creation
//   Database schema browsing    - discovery of available tables
//   TGIS_Utils.GisCreateLayer   - factory method for layer instantiation
//
//  SQLWizard Sample.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisViewer.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisTypesUI.hpp"
#include "GisAllLayers.hpp"
#include "GisEditor.hpp"
#include "VCL.GisControlLegend.hpp"
#include "formLayerSQL.h"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS ;
	TToolButton *btnFullExtent ;
	TToolButton *btnZoom ;
	TToolButton *btnDrag ;
	TToolButton *btnSqlWizard ;
	TToolBar    *ToolBar1 ;
	TStatusBar  *StatusBar1 ;
	TImageList  *ImageList1 ;
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall btnSqlWizardClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
