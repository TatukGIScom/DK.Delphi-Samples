/*
 * GridToVector sample — demonstrates raster-to-vector conversion using
 * TGIS_GridToPolygon (raster to polygon) and TGIS_GridToPoint (raster to point).
 *
 * Two source datasets are available:
 *   Land Cover TIFF (Corine CLC2018, Luxembourg) and a DEM grid (elevation.grd).
 * Common parameters (tolerance) control the vectorisation quality.
 * Clicking a generated shape shows its attributes in the attribute control.
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "GisLayerVector.hpp"
#include "GisAllLayers.hpp"
#include "GisVectorization.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ExtCtrls.hpp>
#include "VCL.GisControlAttributes.hpp"
#include <Vcl.ComCtrls.hpp>
//---------------------------------------------------------------------------
class TForm10 : public TForm
{
__published:	// IDE-managed Components
	TPanel *pnl;
	TGroupBox *grpData;
	TButton *btnDem;
	TButton *btnLandCover;
	TGroupBox *grpGridToPolygon;
	TLabel *lblTolerance;
	TEdit *edtTolerance;
	TCheckBox *chkSplit;
	TButton *btnGenerate;
	TGroupBox *grpSelected;
	TGIS_ControlAttributes *GIS_ControlAttributes;
	TPanel *pnl1;
	TGIS_ViewerWnd *GIS;
	TProgressBar *pbprogress;
	void __fastcall FormShow(TObject *Sender);          /* Load Land Cover on startup; select mode */
	void __fastcall btnLandCoverClick(TObject *Sender); /* Load Corine Land Cover TIFF */
	void __fastcall btnDemClick(TObject *Sender);       /* Load DEM grid with colour ramp */
	void __fastcall btnGenerateClick(TObject *Sender);  /* Convert raster to polygon vector layer */
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort); /* Progress bar */
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);                                /* Select shape and show attributes on click */
	void __fastcall GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);                               /* Zoom out on mouse-wheel-down */
	void __fastcall GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);                               /* Zoom in on mouse-wheel-up */

public:		// User declarations
	__fastcall TForm10(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm10 *Form10;
//---------------------------------------------------------------------------
#endif
