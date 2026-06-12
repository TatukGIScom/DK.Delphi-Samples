//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  Statistic sample — demonstrates statistical analysis of layer features (C++Builder/VCL).
//
//  What the sample shows:
//    - Loading a vector layer (countries/cities) with numeric attributes
//    - Computing various statistics on layer attributes:
//      * Count: total number of features
//      * Sum: total of all values in selected field
//      * Average: mean value across all features
//      * Min/Max: lowest and highest values
//      * Standard deviation: measure of value spread
//    - Selecting which attribute field to analyze via dropdown
//    - Displaying results in summary text/grid
//    - Filtering features before computing statistics
//    - Updating statistics dynamically when layer changes
//    - Using TGIS_Shape.GetField to access attribute values
//    - Iterating through all features with FindFirst/FindNext
//    - Choropleth visualization with data-driven polygon coloring
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control
//    TGIS_LayerVector            - vector layer with attribute data
//    TGIS_Shape.GetField()       - read numeric attribute value
//    FindFirst / FindNext        - feature iteration
//    Attribute fields            - numeric data source for statistics
//    Statistical calculations    - sum, average, min, max, std dev
//    Field selection             - choosing which attribute to analyze
//    Data aggregation            - processing entire dataset
//    Filter criteria              - selecting subset of features
//    Results display             - summary grid or text output
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
        TStatusBar *StatusBar1 ;
        TComboBox *ComboLabels ;
        TComboBox *ComboStatistic ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TImageList *ImageList1 ;
        TToolButton *ToolButton1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall PaintShape( TObject * _sender, TGIS_Shape * _shape  ) ;
        void __fastcall ComboChange(TObject *Sender);
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
