//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  PaintLabel sample — demonstrates customizing label rendering and appearance (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading a shapefile layer (countries/cities) with predefined labels
//    - Implementing custom label painting via OnPaintShapeLabel event handler
//    - Modifying label text dynamically based on feature attributes
//    - Customizing label font, size, color, and style per feature
//    - Adding custom icons or symbols alongside labels
//    - Controlling label positioning and offset from feature geometry
//    - Filtering labels based on zoom level or feature attributes
//    - Adding borders, outlines, or shadows to label text
//    - Handling label collision detection and placement
//    - Rotating labels to match feature orientation (e.g., road labels)
//    - Using TGIS_PaintShapeLabelEventArgs to access rendering context
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - vector layer with label data
//    OnPaintShapeLabel           - event triggered during label rendering
//    TGIS_PaintShapeLabelEventArgs - rendering context for custom drawing
//    TGIS_Params.Labels          - label configuration and appearance
//    Label text                  - feature attribute used for label content
//    Label position              - offset and alignment from geometry
//    Font and color              - label typography customization
//    Label rotation              - orientation based on feature direction
//    Collision detection         - overlap prevention for label placement
//
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
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TImageList *ImageList1 ;
        TStatusBar *StatusBar1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall PaintLabel( TObject * _sender, TGIS_Shape * _shape ) ;
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomInClick(TObject *Sender);
        void __fastcall btnZoomOutClick(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
