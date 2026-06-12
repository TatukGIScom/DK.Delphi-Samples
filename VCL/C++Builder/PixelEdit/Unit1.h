//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// PixelEdit sample — demonstrates editing raster data at the pixel level (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a raster image or DEM (Digital Elevation Model) layer
//   - Locking the raster for efficient pixel-level access (TGIS_LayerPixel.Lock)
//   - Iterating through pixels using Loop / LoopNextPixel
//   - Reading individual pixel values and band data
//   - Modifying pixel values programmatically
//   - Applying bulk transformations to all pixels (e.g., scaling, offsetting)
//   - Handling multi-band raster data (R, G, B, alpha channels)
//   - Creating custom raster processing algorithms
//   - Optimizing performance via direct pixel buffer access
//   - Unlocking the raster to finalize changes
//   - Saving modified raster to disk (GeoTIFF, JPEG, PNG, etc.)
//   - Creating new in-memory raster layers from scratch
//   - Displaying edited raster with updated color mapping
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerPixel             - raster/image layer with pixel access
//   Lock / Unlock               - pixel buffer locking for performance
//   Loop / LoopNextPixel        - pixel iteration methods
//   Pixel value reading         - GetPixel or direct buffer access
//   Pixel value writing         - SetPixel or direct buffer modification
//   Band data                   - R, G, B, A channel access
//   Raster statistics           - min, max, mean values
//   Color mapping               - palette or gradient visualization
//   Georeferencing              - spatial reference for raster
//   Resampling                  - interpolation for pixel operations
//
//  Use TGIS_LayerPixel.Lock & Loop to edit pixel content.
//
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <Math.hpp>

#include "GisAllLayers.hpp"
#include "GisUtils.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "GisCsFactory.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisLayerJpg.hpp"
#include "GisLayerGrd.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp" ;

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS ;
	TToolBar *ToolBar1 ;
	TMemo *Memo1 ;
	TButton *btnProfile ;
	TButton *btnMinMax ;
	TButton *btnAvargeColor ;
	TButton *btnCreateBitmap ;
	TButton *btnCreateGrid ;
	TGIS_ControlLegend *GIS_Legend ;
	void __fastcall btnAvargeColorClick(TObject *Sender);
	void __fastcall btnCreateBitmapClick(TObject *Sender);
	void __fastcall btnCreateGridClick(TObject *Sender);
	void __fastcall btnMinMaxClick(TObject *Sender);
	void __fastcall btnProfileClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	double __fastcall trunc(double d) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
