//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * DemOperations sample - demonstrates terrain analysis derived from a DEM raster.
 *
 * The sample opens an ADF elevation grid and lets the user choose from the
 * following TGIS_DemGenerator operations:
 *   Hillshade, Slope, Slope Hydro, Aspect, TRI, TPI, Roughness,
 *   Total Curvature, Matrix Gain, Flow Dir.
 *
 * A custom hillshade implementation (changeDEM) demonstrates the
 * TGIS_LayerPixel GridOperationEvent callback mechanism.
 *
 * Check project\options\directories in case of any problems during compilation.
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>

#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisTypes.hpp"
#include "GisEditor.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisLayerADF.hpp"
#include "GisDem.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisRegistredLayers.hpp"
#include <cmath>

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar           *ToolBar1;
	TGIS_ViewerWnd     *GIS ;
	TStatusBar         *StatusBar ;
	TToolButton        *btnFullExtent ;
	TToolButton        *btnZoom ;
	TToolButton        *btnDrag ;
	TToolButton        *ToolButton4;
	TImageList         *ImageList1 ;
	TPanel             *paTop ;
	TGroupBox          *GroupBox1;
	TTrackBar          *tbShadowAngle ;
	TButton            *btnGenerate ;
	TComboBox          *cbDemOperation ;
	TLabel             *Label19;
	TLabel             *Label20;
	TLabel             *Label21;
	TCheckBox          *cbCombined ;
	TEdit              *eZFactor ;
	TEdit              *eAzimuth;
	TEdit              *eAltitude;
	TLabel             *Label18;
	TLabel             *Label17;
	TComboBox          *cbSlopeMode;
	TEdit              *eScale ;
	TGIS_ControlLegend *GIS_Legend;
	TLabel             *Label1 ;
	TProgressBar       *pboperation ;
	TCheckBox          *cbCustomOperation ;
	TGroupBox          *gbMain ;
	TToolButton        *ToolButton1 ;
	TToolButton        *ToolButton2;
	TOpenDialog        *dlgFileOpen ;
	TCheckBox          *chkAngleAzimuth ;
	TGroupBox          *gbHillShadeParams ;
	TGroupBox          *gbSlopeParams ;
	TComboBox          *cbCurvatureMode ;
	TLabel             *Label2 ;
	TGroupBox          *gbCurvature ;
	TToolButton        *btn1;
	TToolButton        *btn2 ;
	void __fastcall btnFullExtentClick(TObject *Sender);    /* Reset map to full extent */
	void __fastcall btnZoomClick(TObject *Sender);          /* Switch viewer to zoom mode */
	void __fastcall cbCustomOperationClick(TObject *Sender);/* Attach/detach custom GridOperationEvent callback */
	void __fastcall btnGenerateClick(TObject *Sender);      /* Run the selected DEM operation */
	void __fastcall cbDemOperationChange(TObject *Sender);  /* Show/hide operation-specific parameter panels */
	void __fastcall btn1Click(TObject *Sender);             /* Open file dialog and load raster */
	void __fastcall btnDragClick(TObject *Sender);          /* Switch viewer to pan/drag mode */
	void __fastcall FormCreate(TObject *Sender);            /* Load default sample DEM on startup */
	void __fastcall GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort); /* Progress bar update */
	double __fastcall trunc( double d );                    /* Helper: truncate double to integer value */
	void __fastcall tbShadowAngleChange(TObject *Sender);   /* Update grid shadow angle from track bar */
	void __fastcall ToolButton1Click(TObject *Sender);      /* Toggle 3D perspective view */


private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	/* Custom GridOperationEvent callback that computes a hillshade value for
	   every cell using a 3x3 neighbourhood (Horn's algorithm).  Reads the
	   nine-cell window from _source, calculates the cosine of the sun
	   incidence angle, and writes the shaded value (1..255) to _output.
	   Cells containing NoData are passed through unchanged.
	   Returns true to indicate the output grid is valid. */
	bool __fastcall changeDEM( TObject* _layer,
							   const TGIS_Extent &_extent,
							   const TGIS_GridArray _source,
							   TGIS_GridArray &_output,
							   const int _width,
							   const int _height,
							   float &_minz,
							   float &_maxz
							);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
