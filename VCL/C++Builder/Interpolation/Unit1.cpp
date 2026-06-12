//---------------------------------------------------------------------------
// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// =============================================================================
//
// Interpolation Sample (C++Builder / VCL edition)
//
// Generates a raster grid from vector point data using various spatial
// interpolation methods.  See Unit1.h for the full feature description.
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include <GisUtils.hpp>
#include <GisCsFactory.hpp>
#include <GisLayerVector.hpp>
#include <GisLayerPixel.hpp>
#include <GisInterpolation.hpp>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
    : TForm(Owner)
{
}

//---------------------------------------------------------------------------
// doBusyEvent
// Progress callback invoked by the interpolation engine at regular intervals.
//
// TatukGIS busy event convention:
//   _pos == 0   => initialise (set up progress bar range)
//   _pos == -1  => finished (show maximum)
//   _pos  > 0   => update (throttled every 1000 steps to limit overhead)
// Setting _abort = true inside this handler cancels the ongoing operation.
//---------------------------------------------------------------------------
void __fastcall TfrmMain::doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
  if (_pos < 0)
  {
    // Finished: show full progress bar
    pbProgress->Position = pbProgress->Max ;
  }
  else
  if (_pos == 0)
  {
    // Initialise: configure the range for this interpolation run
    pbProgress->Min = 0 ;
    pbProgress->Max = _end ;
    pbProgress->Position = 0 ;
  }
  else
  {
    // Throttle: update every 1000 steps to avoid sluggish redraws
    if (_pos % 1000 == 0)
      pbProgress->Position = _pos ;
  }
}

//---------------------------------------------------------------------------
// doRbtnAnyClick
// Shared OnClick handler for all five method radio buttons.
// Shows the Semivariance combo box only when Kriging is selected because
// no other method uses a semivariogram model.
//---------------------------------------------------------------------------
void __fastcall TfrmMain::doRbtnAnyClick(TObject *Sender)
{
  if (rbtnKriging->Checked)
  {
    // Kriging requires a semivariogram model - reveal the selector
    lblSemivariance->Visible = True ;
    cmbSemivariance->Visible = True ;
  }
  else
  {
    // All other methods work without a semivariogram - hide the selector
    lblSemivariance->Visible = False ;
    cmbSemivariance->Visible = False ;
  }
}

//---------------------------------------------------------------------------
// FormCreate
// Loads the bundled project file which supplies:
//   "temperatures": point layer with TEMP field values to interpolate
//   "country":      polygon layer that defines the output extent and clip mask
// Sets EPSG:3395 (World Mercator) so distance calculations use metres.
// Wires the shared doRbtnAnyClick handler to each radio button.
//---------------------------------------------------------------------------
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  // Open the bundled project; layers are created from paths stored inside
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "Samples\\Interpolation\\Interpolation.ttkproject" ) ;
  // Override the viewer CRS to World Mercator for accurate distance-based interpolation
  GIS->CS = TGIS_CSFactory::ByEPSG( 3395 ) ;
  GIS->FullExtent() ;

  // Wire all radio buttons to the shared handler so Kriging-specific UI
  // appears and disappears as the user switches between methods
  rbtnIDW->OnClick = doRbtnAnyClick;
  rbtnKriging->OnClick = doRbtnAnyClick;
  rbtnSplines->OnClick = doRbtnAnyClick;
  rbtnHeatMap->OnClick = doRbtnAnyClick;
  rbtnConcentrationMap->OnClick = doRbtnAnyClick;
}

//---------------------------------------------------------------------------
// btnGenerateGridClick
// Main interpolation orchestration handler.  Performs these steps:
//   1. Retrieve source (point) and country polygon layers by name.
//   2. Delete any previous "grid" layer to avoid duplicates.
//   3. Compute the geographic extent and aspect ratio from the polygon layer.
//   4. Create a blank in-memory TGIS_LayerPixel with square pixels.
//   5. Dispatch to the appropriate interpolation code block.
//   6. Apply a Blue->Lime->Red colour ramp via GenerateRamp.
//   7. Clip the output to the country polygon via CuttingPolygon.
//   8. Add the grid to the viewer and zoom to full extent.
//---------------------------------------------------------------------------
void __fastcall TfrmMain::btnGenerateGridClick(TObject *Sender)
{
  btnGenerateGrid->Enabled = False ;

  // Retrieve named layers from the loaded project
  TGIS_LayerVector *src = (TGIS_LayerVector *)GIS->Get("temperatures");  // point data source
  TGIS_LayerVector *plg = (TGIS_LayerVector *)GIS->Get("country");       // polygon for extent/clip

  // Remove any previous interpolation result so we start fresh
  if (GIS->Get("grid"))
    GIS->Delete("grid");

  // Use the polygon's full extent as the output domain
  TGIS_Extent ext = plg->Extent;

  // Compute aspect ratio so output pixels remain square when projected
  double rat = (ext.YMax - ext.YMin)/(ext.XMax - ext.XMin);

  // Create and initialise the in-memory raster output layer
  TGIS_LayerPixel *dst = new TGIS_LayerPixel();
  dst->Name = "grid";
  // Build allocates the pixel buffer: true=in-memory, src->CS=CRS,
  // GRID_RESOLUTION=width, RoundS(rat*...) height maintains square pixels
  dst->Build(true, src->CS, ext, GRID_RESOLUTION, RoundS(rat * GRID_RESOLUTION));
  // Disable hill-shading - the interpolated values are not elevation data
  dst->Params->Pixel->GridShadow = false;

  // Default ramp start colour (overridden to transparent blue for heat maps)
  TGIS_Color clr = TGIS_Color::Blue;

  // -------------------------------------------------------------------------
  // IDW (Inverse Distance Weighting)
  // Estimates each output cell as a weighted average of all sample points,
  // where weight = 1/distance^Exponent.  Exponent=3.0 gives sharper local
  // peaks than the default 2.0.
  // -------------------------------------------------------------------------
  if (rbtnIDW->Checked)
  {
    TGIS_InterpolationIDW *vtg = new TGIS_InterpolationIDW();

    // For windowed version set Windowed=true and Radius, e.g.:
    //   vtg->Windowed = true;
    //   vtg->Radius = (ext.XMax - ext.XMin)/5.0;

    // Attach the progress callback
    vtg->BusyEvent = doBusyEvent;
    // Exponent 3.0: sharper localised surface than default 2.0
    vtg->Exponent = 3.0;
    // Generate the IDW grid
    vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

    vtg->Free();
  }
  else
  // -------------------------------------------------------------------------
  // Kriging
  // Geostatistical method that models spatial autocorrelation via a
  // semivariogram, producing a statistically optimal (BLUE) surface.
  // The semivariogram model governs spatial dependence structure.
  // -------------------------------------------------------------------------
  if (rbtnKriging->Checked)
  {
    TGIS_InterpolationKriging *vtg = new TGIS_InterpolationKriging();

    // For windowed version set Windowed=true and Radius, e.g.:
    //   vtg->Windowed = true;
    //   vtg->Radius = (ext.XMax - ext.XMin)/5.0;

    // Attach the progress callback
    vtg->BusyEvent = doBusyEvent;
    // Select the semivariogram model based on the combo box choice
    switch (cmbSemivariance->ItemIndex)
    {
      case 0: vtg->Semivariance = new TGIS_SemivariancePowerLaw(); break;     // scale-free power relationship
      case 1: vtg->Semivariance = new TGIS_SemivarianceExponential(); break;  // exponential decay
      case 2: vtg->Semivariance = new TGIS_SemivarianceGaussian(); break;     // smooth Gaussian decay
      case 3: vtg->Semivariance = new TGIS_SemivarianceSpherical(); break;    // linear then flat (geology)
      case 4: vtg->Semivariance = new TGIS_SemivarianceCircular(); break;     // circular model
      case 5: vtg->Semivariance = new TGIS_SemivarianceLinear(); break;       // simple linear model
    }
    // Generate the Kriging interpolation grid
    vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

    vtg->Free();
  }
  else
  // -------------------------------------------------------------------------
  // Completely Regularized Splines
  // Fits a smooth surface using radial basis functions.  Tension=1e-9 gives
  // a minimum-curvature result; increase it for oscillation-prone datasets.
  // -------------------------------------------------------------------------
  if (rbtnSplines->Checked)
  {
    TGIS_InterpolationSplines *vtg = new TGIS_InterpolationSplines();

    // For windowed version set Windowed=true and Radius, e.g.:
    //   vtg->Windowed = true;
    //   vtg->Radius = (ext.XMax - ext.XMin)/5.0;

    // Attach the progress callback
    vtg->BusyEvent = doBusyEvent ;
    // Tension=1e-9: near-minimum-curvature, very smooth surface
    vtg->Tension = 1e-9 ;
    // Generate the Completely Regularized Splines grid
    vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

    vtg->Free();
  }
  else
  // -------------------------------------------------------------------------
  // Gaussian Heat Map
  // Each point spreads its FIELD_VALUE through a Gaussian kernel.
  // EstimateRadius computes the 3-sigma bandwidth from the data;
  // halving it narrows the kernel for more peaked hotspots.
  // -------------------------------------------------------------------------
  if (rbtnHeatMap->Checked)
  {
    TGIS_GaussianHeatmap *vtg = new TGIS_GaussianHeatmap() ;

    // Attach the progress callback
    vtg->BusyEvent = doBusyEvent ;
    // Estimate 3-sigma Gaussian kernel radius from the data distribution
    vtg->EstimateRadius(src, src->Extent, dst);
    // Halve the estimated radius for a more localised, peaked result
    vtg->Radius = vtg->Radius/2.0 ;
    // Generate the Heat Map grid (uses FIELD_VALUE weighting)
    vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

    vtg->Free();

    // Use transparent blue ramp start so basemap shows through zero-density areas
    clr = TGIS_Color::FromARGB(0, 0, 0, 255);
  }
  else
  // -------------------------------------------------------------------------
  // Concentration Map
  // Counts point density only (ignores field values); every point contributes
  // equally.  Coordinate::None means centroids are used as-is.
  // -------------------------------------------------------------------------
  if (rbtnConcentrationMap->Checked)
  {
    TGIS_GaussianHeatmap *vtg = new TGIS_GaussianHeatmap() ;

    // Coordinate::None: use point centroids directly without any offset
    vtg->Coordinate = TGIS_VectorToGridCoordinate::None ;

    // Attach the progress callback
    vtg->BusyEvent = doBusyEvent ;
    // Estimate 3-sigma Gaussian kernel radius from the data distribution
    vtg->EstimateRadius(src, src->Extent, dst);
    // Halve the estimated radius for a more localised, peaked result
    vtg->Radius = vtg->Radius/2.0 ;
    // Generate the Concentration Map grid (empty field = density only)
    vtg->Generate(src, src->Extent, "", dst, dst->Extent);

    vtg->Free();

    // Use transparent blue ramp start so basemap shows through zero-density areas
    clr = TGIS_Color::FromARGB(0, 0, 0, 255);
  }

  // Apply a three-stop colour ramp across the full value range.
  // Blue (low) -> Lime (mid) -> Red (high), divided into fine steps.
  dst->GenerateRamp(
    clr, TGIS_Color::Lime, TGIS_Color::Red,
    dst->MinHeight,
    (dst->MaxHeight - dst->MinHeight)/2.0,
    dst->MaxHeight, False,
    (dst->MaxHeight - dst->MinHeight)/100.0,
    (dst->MaxHeight - dst->MinHeight)/10.0,
    NULL, False
  );

  // Clip the grid to the country boundary.  GetShape(6) retrieves the 7th shape
  // (0-based index) from the polygon layer; CreateCopy is required because
  // CuttingPolygon takes ownership of the shape object.
  dst->CuttingPolygon = (TGIS_ShapePolygon *)plg->GetShape(6)->CreateCopy();

  // Add the generated grid to the viewer layer list
  GIS->Add(dst);
  // Zoom to display the full interpolated result
  GIS->FullExtent();

  // Reset the progress bar
  pbProgress->Position = 0;

  btnGenerateGrid->Enabled = true;
}
//---------------------------------------------------------------------------
