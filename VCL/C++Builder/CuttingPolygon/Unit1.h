//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
 * CuttingPolygon sample — demonstrates how to clip a raster (pixel) layer's rendering to
 * within an arbitrary polygon boundary using TGIS_LayerPixel::CuttingPolygon.
 *
 * What the sample shows:
 *   - Loading a raster image (world map) into the GIS viewer
 *   - Creating an in-memory vector layer with a custom polygon
 *   - Implementing raster clipping/masking via CuttingPolygon property
 *   - Assigning a triangular polygon as the cutting mask
 *   - Toggling clipping on/off via button click (Do Cutting)
 *   - Raster rendering constrained to polygon boundary
 *   - Remaining regions outside polygon are not rendered
 *   - Interactive zoom and pan with clipped raster display
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd              - main visual map control
 *   TGIS_LayerPixel             - raster/image layer
 *   TGIS_LayerVector            - in-memory vector layer
 *   TGIS_LayerPixel::CuttingPolygon - masking/clipping property
 *   TGIS_Shape                  - polygon geometry for clipping
 *   TGIS_ControlLegend          - layer list/legend panel
 *   OnFormCreate event          - initialization workflow
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisLayerPixel.hpp"
//---------------------------------------------------------------------------
/* Main form for the CuttingPolygon sample.
   Demonstrates raster-to-polygon clipping via TGIS_LayerPixel.CuttingPolygon,
   rendering raster data within an arbitrary polygon boundary. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TButton *btnCutting;
	TButton *btnZoom;
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GIS_ControlLegend1;
	void __fastcall btnCuttingClick(TObject *Sender); /* Assign polygon as CuttingPolygon; hide vector layer */
	void __fastcall btnZoomClick(TObject *Sender);    /* Switch to Zoom mode */
	void __fastcall FormCreate(TObject *Sender);      /* Load raster image; create triangular clip polygon */
private:	// User declarations
	TGIS_LayerVector *ll ;
	TGIS_LayerPixel  *lp ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
