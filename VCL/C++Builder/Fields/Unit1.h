//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to add layer to the map.
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GISRegistredLayers.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisDataSet.hpp"
#include "GisUtils.hpp"
#include <DBGrids.hpp>
#include <Grids.hpp>
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TDBGrid *DBGrid1;
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GIS_ControlLegend;
	TGIS_DataSet *GIS_DataSet1;
	TStatusBar *StatusBar1;
	TToolBar *ToolBar1;
	TButton *CreateLayerButton;
	TToolButton *ToolButton1;
	TCheckBox *chkUseSymbols;
	TDataSource *DataSource1;
	void __fastcall CreateLayerButtonClick(TObject *Sender);
	void __fastcall GIS_DataSet1AfterPost(TDataSet *DataSet);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
