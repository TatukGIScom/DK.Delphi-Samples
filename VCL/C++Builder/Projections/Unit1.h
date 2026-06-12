//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Projections sample — demonstrates on-the-fly coordinate system reprojection of map layers (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a world map (vector layer) into the GIS viewer
//   - Accessing the projection catalogue via TGIS_Utils::CSProjList
//   - Creating/building custom coordinate systems via TGIS_CSBuilder
//   - Switching the viewer's coordinate system via GIS->CS property
//   - On-the-fly reprojection: all layers instantly reproject in memory
//   - No data reload required — reprojection is automatic and seamless
//   - Switching between different projection types (Mercator, UTM, etc.)
//   - Combo box selector for choosing projection from the full catalogue
//   - Real-time map updates reflecting the new projection
//   - Automatic bounds recalculation after reprojection
//
// Key TatukGIS API concepts shown here:
//   - TGIS_ViewerWnd: main visual map control
//   - TGIS_ViewerWnd::CS: viewer's current coordinate system property
//   - TGIS_ViewerWnd::FullExtent(): zoom to all layers in current CS
//   - TGIS_LayerVector: vector layer (auto-reproject with viewer CS)
//   - TGIS_CSCoordinateSystem: coordinate system definition (WKT)
//   - TGIS_Utils::CSProjList: projection catalogue and WKT lookup
//   - TGIS_Utils::CSBuilder: builds coordinate systems by code/parameters
//   - TGIS_CSProjectedCoordinateSystem: user-defined CRS (EPSG -1 for temporary)
//   - TGIS_CSGeographicCoordinateSystem: WGS 84 unscaled base datum
//   - On-the-fly reprojection: transparent coordinate transformation
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"    // Vector layer support
#include "GisViewer.hpp"         // Base viewer types and TGIS_CSCoordinateSystem
#include "VCL.GisViewerWnd.hpp"  // TGIS_ViewerWnd: the visual map viewer control
#include "GisCsProjections.hpp"  // Projection catalogue and CS builder types
#include "GisTypesUI.hpp"        // UI-related GIS type definitions
//---------------------------------------------------------------------------
/* Main application form for the Projections sample.
   Shows a world map that is immediately reprojected whenever the user
   picks a different projection method from the combo box. */
class TfrmMain : public TForm
{
__published:    // IDE-managed Components
        /// Toolbar container for the projection combo box.
        TToolBar  *ToolBar1 ;
        /// Drop-down list of available projection names (WKT strings).
        TComboBox *cbxSrcProjection ;
        /// TatukGIS map viewer control that renders and reprojects layers.
        TGIS_ViewerWnd *GIS ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall cbxSrcProjectionChange(TObject *Sender);
private:        // User declarations
public:         // User declarations
        __fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
