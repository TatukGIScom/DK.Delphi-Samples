//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * JoinAndRender sample - demonstrates joining external database tables to
 * vector layers and rendering features using dynamic styling based on joined data.
 *
 * What the sample shows:
 *   - Loading a world country shapefile and connecting to an external ADO database
 *     containing attribute data (population, economic indicators) indexed by country
 *   - Creating a database join between layer features and external data via common key
 *   - Rendering vector shapes with dynamic colors/patterns based on joined field values
 *   - Using custom rendering expressions (FIELD:<name>) for field-driven styling
 *   - Switching between different database columns for rendering via UI combo box
 *   - Performing zoom and pan operations on the styled map
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd    - main visual map control
 *   TGIS_LayerSHP     - vector shapefile layer with external data join
 *   TGIS_LayerVector  - base class supporting rendering expressions
 *   Database joins    - ODBC/ADO connections for external attribute access
 *   TGIS_Params       - layer styling (area color, transparency, etc.)
 *   FIELD expressions - dynamic rendering based on feature attributes
 */
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.Win.ComObj.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisViewer.hpp"
#include "GisUtils.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerSHP.hpp"
#include "GisTopology.hpp"
#include "GisParams.hpp"
#include "GisEditor.hpp"
#include "GisTypesUI.hpp"
#include "GisTypes.hpp"
#include "Vcl.GisControlLegend.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include <Data.DB.hpp>
#include <Data.Win.ADODB.hpp>
//---------------------------------------------------------------------------
/* JoinAndRender sample — demonstrates joining layer attributes with external databases and applying
   data-driven styling to map features. Joins a vector layer with an OleDb table, then applies colors,
   line styles, and outline properties based on joined attribute values. Users can select different
   data fields to control feature appearance in real-time. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TComboBox *cmbSize;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	TToolButton *btnZoomOut;
	TToolButton *ToolButton1;
	TGIS_ControlLegend *GIS_Legend;
	TToolButton *ToolButton2;
	TToolButton *ToolButton3;
	TTrackBar *scrTransparency;
	TColorDialog *dlgColor;
	TPanel *panColorStart;
	TPanel *panColorEnd ;
	TADOQuery *ADOQuery;
	TADOConnection *ADOConnection;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomInClick(TObject *Sender);
	void __fastcall btnZoomOutClick(TObject *Sender);
	void __fastcall cmbSizeChange(TObject *Sender);
	void __fastcall scrTransparencyChange(TObject *Sender);
	void __fastcall panColorStartClick(TObject *Sender);
	void __fastcall panColorEndClick(TObject *Sender);
private:	// User declarations
	Variant sqlDC ;
	Variant sqlRS ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
