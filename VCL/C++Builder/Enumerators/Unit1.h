/*
 * Enumerators sample — demonstrates using TGIS_LayerVector::Loop() enumerators to compute
 * the neighbor count for every shape in a polygon layer.
 *
 * What the sample shows:
 *   - Loading a polygon shapefile (California Counties) into the GIS viewer
 *   - Using nested Loop() enumerators to iterate through all shapes and find neighbors
 *   - The outer Loop() enumerates each county polygon
 *   - The inner Loop(extent, "", shape, "****T", true) counts topologically adjacent neighbors
 *     using the DE-9IM spatial relationship filter "****T" (touching boundary)
 *   - Creating a new COUNT field via AddField and populating it with neighbor counts via MakeEditable
 *   - Rendering the layer as a 5-zone white-to-red color ramp keyed on the COUNT field
 *   - Displaying the COUNT value as labels on each county
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd              - main visual map control
 *   TGIS_LayerVector            - vector layer with spatial indexing and enumeration
 *   TGIS_LayerVector::Loop()    - returns enumerator for spatial iteration
 *   TGIS_LayerVectorEnumerator  - iterator supporting MoveNext, Current
 *   TGIS_Shape                  - geographic feature (county polygon)
 *   TGIS_Shape::ProjectedExtent - bounding box for spatial queries
 *   AddField / MakeEditable     - schema manipulation and feature editing
 *   Params.Render.Expression    - value expression for color ramp rendering
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
#include "GisLayerSHP.hpp"
#include "GISRegistredLayers.hpp"
#include "GisTypesUI.hpp"


//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TGIS_ViewerWnd *GIS;
    TStatusBar *StatusBar1;
    TToolBar *Toolbar1;
    TToolButton *btnFullExtent;
    TToolButton *btnZoomIn;
    TToolButton *btnZoomOut;
    TToolButton *ToolButton4;
    TCheckBox *chkDrag;
	TImageList *ImageList2;
	TToolButton *ToolButton1;
	TToolButton *btnEnumerate;
        void __fastcall FormCreate(TObject *Sender);        /* Load California Counties shapefile */
        void __fastcall chkDragClick(TObject *Sender);      /* Toggle Drag / Select viewer mode */
        void __fastcall btnFullExtentClick(TObject *Sender); /* Reset to full map extent */
        void __fastcall btnZoomInClick(TObject *Sender);     /* Double the zoom level */
        void __fastcall btnZoomOutClick(TObject *Sender);    /* Halve the zoom level */
	void __fastcall btnEnumerateClick(TObject *Sender);  /* Count neighbors; render white-to-red ramp */

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
