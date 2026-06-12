//---------------------------------------------------------------------------
// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// =============================================================================
//
// Interpolation Sample (C++Builder / VCL edition)
//
// Demonstrates generating a raster grid from vector point data using various
// spatial interpolation methods.
//
// This sample shows:
//   - Opening a TatukGIS project (.ttkproject) with "temperatures" (points)
//     and "country" (polygon) layers.
//   - Setting EPSG:3395 (World Mercator) for metre-based distance calculations.
//   - Creating an in-memory TGIS_LayerPixel as the interpolation output.
//   - Running five interpolation methods: IDW, Kriging, Splines, Heat Map,
//     and Concentration Map.
//   - Applying a colour ramp and clipping to the country polygon.
//   - Reporting progress via a BusyEvent callback.
//
// Key TatukGIS API classes used:
//   TGIS_ViewerWnd              - VCL map viewer control
//   TGIS_LayerVector            - source point / polygon layer
//   TGIS_LayerPixel             - destination raster grid layer
//   TGIS_InterpolationIDW       - IDW interpolation engine
//   TGIS_InterpolationKriging   - Kriging interpolation engine
//   TGIS_InterpolationSplines   - Completely Regularized Splines engine
//   TGIS_GaussianHeatmap        - Gaussian heat/concentration map engine
//   TGIS_CSFactory              - coordinate system factory (EPSG lookup)
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
//---------------------------------------------------------------------------

// Name of the attribute field in the "temperatures" layer to interpolate
const String FIELD_VALUE = "TEMP";

// Output raster width in pixels; height is computed from the extent aspect ratio
// so that output pixels are approximately square in the projected CRS
const int GRID_RESOLUTION = 400;

//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:    // IDE-managed Components
    TLabel *lblMethod;              // "Method" group label
    TRadioButton *rbtnIDW;          // Select IDW interpolation
    TRadioButton *rbtnKriging;      // Select Kriging interpolation
    TRadioButton *rbtnSplines;      // Select Completely Regularized Splines
    TRadioButton *rbtnHeatMap;      // Select Gaussian Heat Map
    TRadioButton *rbtnConcentrationMap;  // Select Concentration Map (density only)
    TLabel *lblSemivariance;        // "Semivariance" label (Kriging only)
    TComboBox *cmbSemivariance;     // Kriging semivariance model selector
    TButton *btnGenerateGrid;       // Trigger the interpolation and add the grid
    TGIS_ViewerWnd *GIS;            // Main map viewer control
    TProgressBar *pbProgress;       // Shows interpolation progress
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall doRbtnAnyClick(TObject *Sender);
    void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
    void __fastcall btnGenerateGridClick(TObject *Sender);
private:    // User declarations
public:     // User declarations
    __fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
