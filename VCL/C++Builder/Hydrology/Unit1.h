//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to use hydrology toolset.
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
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisViewer.hpp"
#include "GisHydrology.hpp"
#include "GisUtils.hpp"
#include "GisFunctions.hpp"
#include "GisClassification.hpp"
#include "GisVectorization.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
#include "VCL.GisControlLegend.hpp"

#define round(a) int((a)+0.5)

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblInfo;
	TGIS_ViewerWnd *GIS;
	TPanel *pnlButtons;
	TButton *btnStreamOrderStrahler;
	TButton *btnSink;
	TButton *btnFillSinks;
	TButton *btnFlowDirection;
	TButton *btnVectorize;
	TButton *btnFlowAccumulation;
	TButton *btnWatershed;
	TButton *btnBasin;
	TButton *btnAddOutlets;
	TButton *btn3D;
	TGIS_ControlLegend *GIS_Legend;
	TProgressBar *pbBusy;
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall btnSinkClick(TObject *Sender);
	void __fastcall btnFillSinksClick(TObject *Sender);
	void __fastcall btnFlowDirectionClick(TObject *Sender);
	void __fastcall btnFlowAccumulationClick(TObject *Sender);
	void __fastcall btnAddOutletsClick(TObject *Sender);
	void __fastcall btnWatershedClick(TObject *Sender);
	void __fastcall btnBasinClick(TObject *Sender);
	void __fastcall btnStreamOrderStrahlerClick(TObject *Sender);
	void __fastcall btnVectorizeClick(TObject *Sender);
	void __fastcall btn3DClick(TObject *Sender);

private:	// User declarations
	TGIS_LayerPixel *dem ;
	TGIS_Extent ext  ;
	TGIS_Hydrology *hydrologyToolset  ;

	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);


public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
	TGIS_LayerPixel* __fastcall CreateLayerPix( TGIS_LayerPixel* _dem, System::UnicodeString _name )  ;

	TGIS_LayerVector* __fastcall CreateLayerVec( System::UnicodeString _name,
							 TGIS_CSCoordinateSystem* _cs,
							 TGIS_ShapeType _type
						   ) ;

	TGIS_LayerPixel* __fastcall GetLayerPix( System::UnicodeString _name  )  ;
	TGIS_LayerVector* __fastcall GetLayerVec( System::UnicodeString _name  )  ;

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------

#define  HYDRO_LAYER_SINK          "Sinks and flats"
#define  HYDRO_LAYER_DEM           "Hydrologically conditioned DEM"
#define  HYDRO_LAYER_DIRECTION     "Flow direction"
#define  HYDRO_LAYER_ACCUMULATION  "Flow accumulation"
#define  HYDRO_LAYER_STREAM_ORDER  "Stream order (Strahler)"
#define  HYDRO_LAYER_OUTLETS       "Outlets (pour points)"
#define  HYDRO_LAYER_WATERSHED     "Watersheds"
#define  HYDRO_LAYER_BASIN         "Basins"
#define  HYDRO_LAYER_STREAM_VEC    "Streams (vectorized)"
#define  HYDRO_LAYER_BASIN_VEC     "Basins (vectorized)"
#define  HYDRO_FIELD_ORDER         "ORDER"
#define  HYDRO_FIELD_BASIN         "BASIN_ID"

#endif

