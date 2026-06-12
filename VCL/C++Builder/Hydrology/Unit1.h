//=============================================================================
// Hydrology sample — TatukGIS DK C++Builder
//
// Demonstrates the complete DEM-based hydrological analysis pipeline provided
// by the TGIS_Hydrology toolset, executed step by step via UI buttons.
//
// Workflow (10 steps):
//   1. Sink              — detect depressions/flat areas in the raw DEM
//   2. Fill              — condition the DEM by raising sinks
//   3. FlowDirection     — D8 flow-direction codes (power-of-two, 1–128)
//   4. FlowAccumulation  — upstream-cell count per cell
//   5. AddOutlets        — place two hardcoded pour points on high-acc cells
//   6. Watershed         — label cells by the outlet they drain toward
//   7. Basin             — partition DEM into auto-detected drainage basins
//   8. StreamOrder       — Strahler hierarchical ordering of stream cells
//   9. Vectorize         — GridToPolygon (basins) + StreamToPolyline (streams)
//  10. 3D               — drape stream layer on conditioned DEM in 3D viewer
//
// Data: World/Countries/Poland/DEM/Bytowski_County.tif
//
// Check project/options/directories in case of any compilation problems.
//=============================================================================

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
	TGIS_LayerPixel  *dem;              // original DEM layer (Bytowski County)
	TGIS_Extent       ext;              // DEM extent used as analysis region
	TGIS_Hydrology   *hydrologyToolset; // shared hydrology toolset instance

	/* Progress callback: _pos==0 initialises bar; _pos<0 resets; _pos>0 updates. */
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);

public:		// User declarations
	__fastcall TForm1(TComponent* Owner);

	/* Creates an in-memory grid layer matching the DEM extent, CS, and cell size. */
	TGIS_LayerPixel* __fastcall CreateLayerPix( TGIS_LayerPixel* _dem, System::UnicodeString _name );

	/* Creates an empty in-memory vector layer with the given name, CS, and shape type. */
	TGIS_LayerVector* __fastcall CreateLayerVec( System::UnicodeString _name,
	                                              TGIS_CSCoordinateSystem* _cs,
	                                              TGIS_ShapeType _type );

	/* Retrieves a TGIS_LayerPixel by name from the GIS viewer. */
	TGIS_LayerPixel*  __fastcall GetLayerPix( System::UnicodeString _name );
	/* Retrieves a TGIS_LayerVector by name from the GIS viewer. */
	TGIS_LayerVector* __fastcall GetLayerVec( System::UnicodeString _name );

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

