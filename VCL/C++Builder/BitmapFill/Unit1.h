/*
 * BitmapFill sample — demonstrates per-shape bitmap fill using a custom PaintShapeEvent callback.
 *
 * What the sample shows:
 *   - Loading a vector shapefile (California Counties) into the GIS viewer
 *   - Implementing custom shape rendering via PaintShapeEvent callback
 *   - Assigning per-shape bitmap textures based on attribute values
 *   - Using combo boxes to switch between different rendering criteria
 *     (population density vs. raw population)
 *   - Toggling feature labels (none, FIPS code, name) dynamically
 *   - Five different texture bitmaps demonstrating visual variety
 *   - Integration of bitmap resources with shape rendering pipeline
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd              - main visual map control
 *   TGIS_LayerVector            - vector layer with custom paint callbacks
 *   TGIS_LayerSHP               - ESRI Shapefile layer (California Counties)
 *   PaintShapeEvent callback    - custom per-shape rendering hook
 *   TGIS_Shape                  - individual geographic feature
 *   TGIS_Params->Marker         - shape visualization parameters
 *   Bitmap resources            - texture fill patterns
 *   Shape attributes            - field-based rendering criteria
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
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* Main form for the BitmapFill sample.
   Demonstrates filling vector polygon areas with bitmap/image textures instead of solid colors. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TStatusBar *StatusBar1 ;
        TComboBox *ComboLabels ;
        TComboBox *ComboStatistic ;
        TPanel *Panel3 ;
        TImage *Image1 ;
        TImage *Image2 ;
        TImage *Image3 ;
        TImage *Image4 ;
        TImage *Image5 ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TToolButton *ToolButton5 ;
        TImageList *ImageList1 ;
        void __fastcall FormCreate(TObject *Sender);           /* Load counties layer and wire paint callback */
        void __fastcall PaintShape( TObject * _sender, TGIS_Shape * _shape  ) ; /* Assign bitmap by density/population */
        void __fastcall ComboChange(TObject *Sender);          /* Update labels field from combo selection */
        void __fastcall btnFullExtentClick(TObject *Sender);   /* Reset view to full extent */
        void __fastcall btnZoomInClick(TObject *Sender);       /* Double zoom level */
		void __fastcall btnZoomOutClick(TObject *Sender);       /* Halve zoom level */

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
