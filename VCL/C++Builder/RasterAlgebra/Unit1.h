/*
 * RasterAlgebra sample - demonstrates how to apply mathematical expressions
 * to raster layers using TGIS_RasterAlgebra to produce derived pixel or grid
 * outputs.
 *
 * The sample loads a pixel image, a grid (DEM), or a vector layer into the
 * viewer, then evaluates a user-supplied formula cell-by-cell to build a new
 * result layer.  Supported formula examples:
 *   Pixel inversion : RGB(255 - pixel.R, 255 - pixel.G, 255 - pixel.B)
 *   Grid thresholding: IF(grid < AVG(grid), MIN(grid), MAX(grid))
 *   Vector rasterize : IF(NODATA(vector.GIS_UID), RGB(0,255,0), RGB(255,0,0))
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.hpp>
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisLayerPixel.hpp"
//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblFormula;
	TEdit *edtFormula;
	TLabel *lblResultType;
	TLabel *lblSource;
	TButton *btnExecute;
	TProgressBar *pbrProgress;
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GIS_Legend;
	TButton *btnOpenGrid;
	TButton *btnOpenPixel;
	TButton *btnOpenVector;
	TRadioButton *rbtnResultPixel;
	TRadioButton *rbtnResultGrid;
	void __fastcall btnOpenPixelClick(TObject *Sender);
	void __fastcall btnOpenGridClick(TObject *Sender);
	void __fastcall btnOpenVectorClick(TObject *Sender);
	void __fastcall btnExecuteClick(TObject *Sender);
private:	// User declarations
	/* Reports raster algebra execution progress on the progress bar.
	   _pos = 0 initializes the bar; _pos = -1 resets it after completion. */
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
	/* Applies a blue-lime-red colour ramp to grid layer _l, mapping its full
	   value range to the ramp and disabling the default grid shadow. */
	void __fastcall applyRamp(TGIS_LayerPixel *_l);
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
