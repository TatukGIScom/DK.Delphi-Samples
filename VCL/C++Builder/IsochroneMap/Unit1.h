//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
  Isochrone Map sample.

  Demonstrates how to compute travel-time (isochrone) zones from a chosen
  origin point on a road network using TGIS_IsochroneMap and TGIS_ShortestPath.

  Workflow:
    1. Load a road-network SHP layer (US TIGER edges for San Bernardino, CA).
    2. Style the layer to distinguish highways from local roads.
    3. Create an output TGIS_LayerVector for the isochrone polygons and a
       separate TGIS_LayerVector for the origin marker.
    4. Wire up three network-cost callbacks:
         - doLinkCostEvent    : sets the base traversal cost to arc length.
         - doLinkType         : classifies arcs as highway (type 0) or local (type 1).
         - doLinkDynamic      : optionally blocks highway links at run time.
    5. On each mouse click (in Select mode) the user picks an origin.
    6. generateIsochrone calls TGIS_IsochroneMap.Generate once per zone,
       dividing the maximum cost so each successive call covers a wider area.
    7. The resulting polygons are smoothed and displayed as colour-coded zones.

  Check project\options\directories in case of any problems during compilation.
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisControlScale.hpp"
#include <Vcl.ExtCtrls.hpp>
#include "GisShortestPath.hpp"
#include "GisIsochroneMap.hpp"

//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TGIS_ControlScale *GIS_ControlScale1;
	TImageList *il1;
	TPanel *Panel2;
	TGIS_ControlLegend *GIS_ControlLegend1;
	TGroupBox *GroupBox1;
	TEdit *edtDistance;
	TEdit *edtZones;
	TLabel *lbl1;
	TLabel *lblAddrFrom;
	TLabel *lblAddrTo;
	TLabel *lblHighways;
	TLabel *lblSmallRoads;
	TTrackBar *trkHighways;
	TTrackBar *trkSmallRoads;
	TToolBar * tlb1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomInClick(TObject *Sender);
	void __fastcall btnZoomOutClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
private:	// User declarations
	TGIS_LayerVector *layerSrc ;
	TGIS_LayerVector *layerRoute ;
	TGIS_LayerVector *layerMarker ;
	TGIS_IsochroneMap *rtrObj ;
	TGIS_ShortestPath *srtpObj ;
	Double costFactor ;
	Integer numZones ;
	TGIS_Shape *markerShp ;
	void __fastcall doLinkCostEvent( TObject *_sender,
									 TGIS_ShapeArc *_shape,
									 Double &_cost,
									 Double &_revcost
								   ) ;
	void __fastcall doLinkType     ( TObject *_sender,
									 TGIS_ShapeArc *_shape,
									 Integer &_type
								   ) ;
	void __fastcall doLinkDynamic  ( TObject *_sender,
									 Integer _uid,
									 Double &_cost,
									 Double &_revcost
							       ) ;
	void __fastcall generateIsochrone() ;
public:		// User declarations
        __fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
