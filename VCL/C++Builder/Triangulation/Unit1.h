//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Triangulation Sample – Demonstrates Delaunay triangulation and Voronoi diagrams.
//
// This header declares TForm1, which hosts a TatukGIS map viewer, a toolbar for
// map navigation, and controls for generating one of two geometric structures
// derived from a Polish city point dataset:
//
//   Delaunay Triangulation
//     Connects input points into triangles such that no point lies inside the
//     circumscribed circle of any triangle.  Produces a TIN (Triangulated
//     Irregular Network) suitable for surface modelling and proximity analysis.
//
//   Voronoi Diagram
//     Partitions the plane into one region per input point, where each region
//     contains all locations closer to that point than to any other input point.
//     The Voronoi diagram is the geometric dual of the Delaunay triangulation.
//
// Key TatukGIS classes used:
//   TGIS_LayerDelaunay       – generates and stores a Delaunay triangulation
//   TGIS_LayerVoronoi        – generates and stores a Voronoi diagram
//   TGIS_LayerVector         – base class; ImportLayer() copies source point data
//   TGIS_ControlAttributes   – side panel that shows shape attribute data on click
//   TGIS_ControlLegend       – layer legend / style control panel
//   TGIS_ViewerWnd           – VCL map viewer control
//
// Check project\options\directories in case of any problems during compilation.
//=============================================================================

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
#include "VCL.GisControlAttributes.hpp"  // TGIS_ControlAttributes
#include "VCL.GisControlLegend.hpp"       // TGIS_ControlLegend
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTriangulation.hpp"           // TGIS_LayerDelaunay, TGIS_LayerVoronoi
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/**
 * TForm1
 * Main form for the Triangulation sample.
 *
 * Hosts the map viewer, navigation toolbar, attribute side panel, legend panel,
 * mode selection radio buttons, layer name editor, and Generate button.
 */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
        TGIS_ViewerWnd *GIS;              // Map viewer – renders all loaded layers
        TImageList *ImageList1;           // Toolbar button image strip
        TPanel *Panel1;                   // Panel hosting the toolbar strip
        TGIS_ControlAttributes *GIS_Attributes; // Side panel for shape attribute display
        TGroupBox *grpbxResult;           // Groups the mode/name controls
        TLabel *lblName;                  // "Layer name:" label
        TRadioButton *rdbtnVoronoi;       // Select Voronoi diagram mode
        TRadioButton *rdbtnDelaunay;      // Select Delaunay triangulation mode
        TEdit *edtName;                   // Editable output layer name
        TButton *btnGenerate;             // Trigger triangulation / diagram computation
        TGIS_ControlLegend *GIS_ControlLegend1; // Layer legend panel
        TStatusBar *StatusBar1;           // Status bar at the bottom
        TToolBar *ToolBar1;               // Navigation toolbar container
        TToolButton *btnFullExtent;       // Zoom to fit all layers
        TToolButton *btnZoomIn;           // Double the zoom factor
        TToolButton *btnZoomOut;          // Halve the zoom factor
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall btnZoomInClick(TObject *Sender);
        void __fastcall btnZoomOutClick(TObject *Sender);
        void __fastcall btnGenerateClick(TObject *Sender);
        void __fastcall rdbtnVoronoiClick(TObject *Sender);
        void __fastcall rdbtnDelaunayClick(TObject *Sender);
private:    // User declarations
public:     // User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
