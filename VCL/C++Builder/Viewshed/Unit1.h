/*
 * Viewshed sample — demonstrates line-of-sight terrain analysis using TGIS_Viewshed.
 *
 * Loads a DEM (Digital Elevation Model) for San Bernardino, CA. The user clicks on the map
 * to place observer points; TGIS_Viewshed.Generate computes visibility rasters from those points.
 *
 * Two output rasters are generated:
 *   - Viewshed: Binary (visible/not-visible) or frequency (count of visible observers per cell)
 *   - AGL (Above-Ground-Level): Minimum height needed for non-visible cells to become visible
 *
 * Key concepts illustrated:
 *   - TGIS_Viewshed: Line-of-sight terrain analysis engine
 *   - ObserverElevation: Can be read from DEM or provided as an offset
 *   - CurvedEarth: Account for Earth's curvature and atmospheric refraction
 *   - GenerateRamp: Color-map raster values for visualization
 *   - Multi-observer viewshed: Compute visibility from multiple observer locations
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisSymbol.hpp"
#include <Vcl.ComCtrls.hpp>
//---------------------------------------------------------------------------
/* Main form for the Viewshed sample.
   Demonstrates line-of-sight terrain analysis via TGIS_Viewshed. */
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblHint;
	TGIS_ViewerWnd *GIS;
	TButton *btnFullExtent;
	TButton *btnReset;
	TGroupBox *gbMapMode;
	TRadioButton *rbtnZoom;
	TRadioButton *rbtnAddObserver;
	TGroupBox *gbVisibleLayer;
	TRadioButton *rbtnViewshedBinary;
	TRadioButton *rbtnViewshedFreq;
	TRadioButton *rbtnAGL;
	TLabel *lblObserverElevation;
	TEdit *edtObserverElevation;
    TStatusBar *StatusBar1;
	void __fastcall FormCreate(TObject *Sender);  /* Load DEM; create Observers layer with tower symbol */
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);  /* Add observer; generate viewshed and AGL rasters */
	void __fastcall btnFullExtentClick(TObject *Sender);  /* Zoom to full extent */
	void __fastcall btnResetClick(TObject *Sender);  /* Remove viewshed/AGL layers; revert observers */
	void __fastcall rbtnZoomClick(TObject *Sender);  /* Switch to Zoom mode */
	void __fastcall rbtnAddObserverClick(TObject *Sender);  /* Switch to UserDefined mode for adding observers */
	void __fastcall rbtnViewshedBinaryClick(TObject *Sender);  /* Refresh layer for binary viewshed */
	void __fastcall rbtnAGLClick(TObject *Sender);  /* Refresh layer for AGL display */
	void __fastcall rbtnViewshedFreqClick(TObject *Sender);  /* Refresh layer for frequency viewshed */
	void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);  /* Show raster values at cursor */

private:	// User declarations
	TGIS_LayerPixel  *lTerrain;
	TGIS_LayerVector *lObservers;
	TGIS_LayerPixel  *lViewshed;
	TGIS_LayerPixel  *lAGL;
	void __fastcall setLayerActive();
	void __fastcall makeViewshedRamp();
    void __fastcall showComment();
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
