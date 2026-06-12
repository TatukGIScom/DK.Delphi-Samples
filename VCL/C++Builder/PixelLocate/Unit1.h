//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * PixelLocate sample — demonstrates pixel-level feature location and attribute
 * retrieval from raster (DEM/grid) layers.
 *
 * What the sample shows:
 *   - Loading a DEM (Digital Elevation Model) raster grid into the viewer
 *   - Implementing pixel-level location queries via mouse clicks
 *   - Using TGIS_LayerPixel.Locate to find raw elevation values at coordinates
 *   - Converting screen pixels to map coordinates (ScreenToMap)
 *   - Displaying elevation/attribute values in a status bar or info panel
 *   - Handling both elevation and multi-band raster data
 *   - Zoom and pan navigation with terrain visualization
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd          - main visual map control
 *   TGIS_LayerPixel         - raster/grid layer (DEM, imagery, etc.)
 *   TGIS_LayerPixel.Locate  - query pixel value at geographic coordinate
 *   ScreenToMap             - convert screen pixel coordinates to map coordinates
 *   TGIS_Point              - geographic location for queries
 *   OnMouseDown event       - user interaction handling
 */
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerJPG.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"
#include "GisLayerADF.hpp"

//---------------------------------------------------------------------------
/* PixelLocate sample — demonstrates pixel-level raster data access and analysis.
   Loads a raster image (TIFF, etc.) and allows users to click on pixels to retrieve their RGB channel values.
   Displays raw pixel color information and supports brightness adjustment. Useful for examining
   individual pixel attributes in satellite imagery or scanned maps. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TGIS_ViewerWnd *GIS;
  TImageList *ImageList1;
  TPanel *paTop;
  TGroupBox *gbOriginal;
  TGroupBox *gbChannels;
  TLabel *lbRGBValueC;
  TPanel *paColorC;
  TGroupBox *gbBrightness;
  TTrackBar *tbBrightness;
  TMemo *Memo1;
	TButton *btnImage;
	TButton *btnGrid;
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall tbBrightnessChange(TObject *Sender);
	void __fastcall btnImageClick(TObject *Sender);
	void __fastcall btnGridClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
