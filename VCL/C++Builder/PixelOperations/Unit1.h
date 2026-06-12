//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  PixelOperations sample — demonstrates basic raster pixel manipulation and analysis (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading a DEM (Digital Elevation Model) raster layer (ArcInfo ADF format) into the viewer
//    - Creating a hillshade visualization from elevation data via TGIS_LayerPixel.Hillshade
//    - Generating contour lines (isolines) from raster elevation data via TGIS_Topology.ContourLines
//    - Creating a slope map showing steepness analysis from DEM
//    - Creating an aspect map showing downhill direction (N, NE, E, etc.) from DEM
//    - Querying individual pixel values at clicked locations
//    - Applying colour ramps to raster layers for visual analysis
//    - Displaying layer metadata and pixel statistics
//    - Using a legend control to show the rendered layer and styling
//    - Handling raster layer rendering via TGIS_LayerPixel
//    - Opening custom raster files via file dialog
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerPixel             - raster/pixel layer for DEM data
//    TGIS_LayerADF               - ArcInfo Grid format loader
//    TGIS_LayerPixel.Hillshade   - shaded relief rendering from elevation
//    TGIS_Topology.ContourLines  - extract isolines from raster elevation
//    TGIS_LayerPixel.Slope       - compute slope steepness from DEM
//    TGIS_LayerPixel.Aspect      - compute flow direction aspect from DEM
//    TGIS_Params                 - rendering parameters and colour ramps
//    TGIS_ControlLegend          - legend panel for layer display
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.Math.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
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
#include "GisRegistredLayers.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "Vcl.GisControlLegend.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar;
	TToolButton *btnFullExtent;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TToolButton *ToolButton4;
	TImageList *ImageList1;
	TGIS_ControlLegend *GIS_Legend;
	TToolButton *ToolButton1;
	TToolButton *ToolButton2;
	TOpenDialog *dlgFileOpen;
	TToolButton *btn2;
	TCheckBox *cbCheckPixels;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall cbCheckPixelsClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall ToolButton1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	double __fastcall trunc(double d) ;
	bool __fastcall changePixels(
								 TObject* _layer,
								 const TGIS_Extent &_extent,
								 const TGIS_Pixels _source,
								 TGIS_Pixels &_output,
								 const int _width,
								 const int _height
								 );
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
