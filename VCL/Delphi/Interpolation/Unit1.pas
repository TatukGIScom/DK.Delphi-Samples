//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Interpolation Sample - How to generate a raster grid from vector point data
  using various spatial interpolation methods.

  This sample demonstrates:
    - Opening a TatukGIS project file (.ttkproject) that contains two layers:
        "temperatures" - a vector point layer with a numeric "TEMP" field
        "country"      - a polygon layer used to define and clip the output extent
    - Creating an in-memory TGIS_LayerPixel (raster grid) as the interpolation
      output, sized to match the geographic extent of the polygon layer.
    - Running five different vector-to-grid conversion methods:
        IDW (Inverse Distance Weighting)    - weights by 1/distance^exponent
        Kriging                             - geostatistical method using a
                                              semivariogram model to weight samples
        Completely Regularized Splines      - smooth surface interpolation using
                                              radial basis functions
        Gaussian Heat Map                   - kernel density surface; each point
                                              spreads its value across a Gaussian bell
        Concentration Map                   - like Heat Map but only counts point
                                              density (ignores the TEMP field value)
    - Applying a colour ramp (Blue -> Lime -> Red) to the generated grid to
      make high/low values visually distinct.
    - Clipping the result to the country polygon so only pixels inside the
      region of interest are rendered (CuttingPolygon).
    - Displaying a progress bar during the long-running interpolation via a
      BusyEvent callback.

  Key TatukGIS API classes used:
    TGIS_ViewerWnd              - map viewer control
    TGIS_LayerVector            - source point / polygon layer
    TGIS_LayerPixel             - destination raster grid layer
    TGIS_InterpolationIDW       - IDW interpolation engine
    TGIS_InterpolationKriging   - Kriging interpolation engine
    TGIS_InterpolationSplines   - Completely Regularized Splines engine
    TGIS_GaussianHeatmap        - Gaussian heat/concentration map engine
    TGIS_SemivariancePowerLaw / Exponential / Gaussian / Spherical /
      Circular / Linear         - semivariance models for Kriging
    TGIS_CSFactory              - coordinate system factory (EPSG lookup)
}
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls,

  GisTypesUI,
  VCL.GisControlLegend,
  VCL.GisViewerWnd ;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;                    // Main map viewer control
    lblMethod: TLabel;                      // "Method" group label
    rbtnIDW: TRadioButton;                  // Select IDW interpolation
    rbtnKriging: TRadioButton;              // Select Kriging interpolation
    rbtnSplines: TRadioButton;              // Select Completely Regularized Splines
    rbtnHeatMap: TRadioButton;              // Select Gaussian Heat Map
    btnGenerateGrid: TButton;               // Trigger interpolation and add grid
    pbProgress: TProgressBar;              // Shows interpolation progress (0-100%)
    rbtnConcentrationMap: TRadioButton;     // Select Concentration Map (density only)
    lblSemivariance: TLabel;               // "Semivariance" label (Kriging only)
    cmbSemivariance: TComboBox;            // Kriging semivariance model selector
    procedure btnGenerateGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Callback fired periodically by the interpolation engine to report progress.
      _pos = 0 means initialise; _pos = -1 means finished; otherwise _pos is
      the current step count and _end is the total step count. }
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
    { Shared handler for all radio buttons; shows/hides the Semivariance
      selector depending on whether Kriging is chosen. }
    procedure doRbtnAnyClick(
          _sender : TObject
    ) ;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  GisRtl,
  GisTypes,
  GisFunctions,
  GisUtils,
  GisRegistredLayers,
  GisLayer,
  GisLayerVector,
  GisLayerPixel,
  GisCsFactory,
  GisInterpolation;

{$R *.dfm}

{ The name of the numeric attribute field in the "temperatures" vector layer
  that holds the value to be interpolated.  Must match the field name exactly. }
const
  FIELD_VALUE : String = 'TEMP' ;
  { Output grid resolution in pixels along the wider axis.  The perpendicular
    axis is computed from the extent's aspect ratio so pixels remain square. }
  GRID_RESOLUTION : Integer = 400 ;

{ TfrmMain.doBusyEvent
  Progress callback invoked by the interpolation engine at regular intervals.
  Convention:
    _pos = 0   => initialise the progress bar (set Min/Max/Position)
    _pos = -1  => interpolation finished (reset to 0)
    _pos > 0   => update the bar to the current step
  Setting _abort := True would cancel the ongoing operation. }
procedure TfrmMain.doBusyEvent(
      _sender : TObject ;
      _pos    : Integer ;
      _end    : Integer ;
  var _abort  : Boolean
) ;
begin
  case _pos of
    // Initialize: set up progress bar range and reset position
    0  : begin
      pbProgress.Min := 0 ;
      pbProgress.Max := 100 ;
      pbProgress.Position := 0 ;
    end ;
    // Completion sentinel: reset bar so it doesn't remain full after finishing
    -1 : pbProgress.Position := 0 ;
  else
    // Normal update: _pos is the current progress percentage (0-100)
    pbProgress.Position := _pos ;
  end ;
end ;

{ TfrmMain.doRbtnAnyClick
  Shared OnClick handler for all five method radio buttons.
  Shows the Semivariance combo box only when Kriging is selected, because
  the other methods do not use a semivariogram model. }
procedure TfrmMain.doRbtnAnyClick(
  _sender : TObject
) ;
begin
  if rbtnKriging.Checked then begin
    // Kriging requires a semivariance model; reveal the selector
    lblSemivariance.Visible := True ;
    cmbSemivariance.Visible := True ;
  end
  else begin
    // Other methods do not use semivariance; hide the selector
    lblSemivariance.Visible := False ;
    cmbSemivariance.Visible := False ;
  end ;
end ;

{ TfrmMain.FormCreate
  Loads the bundled project file which supplies:
    - "temperatures": point layer with TEMP field values to interpolate
    - "country":      polygon layer that defines the output extent and clip mask
  The project coordinate system is overridden to EPSG:3395 (World Mercator)
  so that all layers use a consistent projected CRS, which is required for
  distance-based interpolation to produce meaningful results.
  Radio button OnClick handlers are wired here rather than in the DFM so that
  the initial selection does not trigger the handler before setup is complete. }
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Open the bundled TatukGIS project; layers are loaded from their paths inside
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\Interpolation\Interpolation.ttkproject' ) ;
  // Override the viewer's coordinate system to World Mercator (metres)
  // This ensures distance calculations in the interpolation are accurate
  GIS.CS := TGIS_CSFactory.ByEPSG( 3395 ) ;
  GIS.FullExtent ;

  // Wire radio buttons to the shared click handler so Kriging-specific UI
  // appears/disappears as the user switches between methods
  rbtnIDW.OnClick := doRbtnAnyClick ;
  rbtnKriging.OnClick := doRbtnAnyClick ;
  rbtnSplines.OnClick := doRbtnAnyClick ;
  rbtnHeatMap.OnClick := doRbtnAnyClick ;
  rbtnConcentrationMap.OnClick := doRbtnAnyClick ;
end;

{ TfrmMain.btnGenerateGridClick
  Main interpolation orchestration procedure.  Performs these steps:
    1. Retrieve the source (point) layer and the country polygon layer.
    2. Delete any previously generated "grid" layer to avoid duplicates.
    3. Compute the geographic extent and aspect ratio from the polygon layer.
    4. Create and initialise a blank TGIS_LayerPixel (the output raster).
    5. Dispatch to the appropriate interpolation helper based on the selected
       radio button.
    6. Apply a Blue->Lime->Red colour ramp using GenerateRamp.
    7. Clip the output grid to the country polygon with CuttingPolygon.
    8. Add the grid to the viewer and zoom to full extent. }
procedure TfrmMain.btnGenerateGridClick(Sender: TObject);
var
  src : TGIS_LayerVector ;  // Source point layer ("temperatures")
  dst : TGIS_LayerPixel  ;  // Destination raster grid layer ("grid")
  plg : TGIS_LayerVector ;  // Polygon layer defining the output extent ("country")
  ext : TGIS_Extent      ;  // Geographic bounding box of the polygon layer
  rat : Double           ;  // Height/width aspect ratio of the extent
  clr : TGIS_Color       ;  // Start colour of the colour ramp

  { doIDW
    Runs Inverse Distance Weighting (IDW) interpolation.
    IDW estimates unknown values as a weighted average of known sample points,
    where the weight of each point decreases with the inverse of its distance
    raised to the Exponent.  Exponent=3.0 gives sharper local detail than the
    default 2.0.
    The global (non-windowed) variant uses ALL source points for every output
    cell; enable Windowed=True and set Radius to restrict the search area and
    speed up very large datasets. }
  procedure doIDW ;
  var
    vtg : TGIS_InterpolationIDW ;
  begin
    vtg := TGIS_InterpolationIDW.Create ;
    try
      // For windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.:
      //   vtg.Windowed := True ;
      //   vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // Attach the progress event to keep the UI responsive during computation
      vtg.BusyEvent := doBusyEvent ;
      // Exponent controls the rate of distance decay in the IDW formula.
      // Default is 2.0 (Inverse Distance Squared); 3.0 produces a more
      // localised surface with sharper peaks around sample points.
      vtg.Exponent := 3.0 ;
      // Generate the grid: read from src layer, write to dst layer.
      // Both extents are passed so the engine knows the sampling region and
      // output domain (they can differ for partial updates).
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  { doKriging
    Runs Ordinary Kriging interpolation.
    Kriging is a geostatistical method that models spatial autocorrelation
    through a semivariogram (how variance grows with distance).  The choice of
    semivariogram model (Power Law, Exponential, Gaussian, etc.) affects how
    smoothly the surface varies and should be chosen to fit the data's known
    spatial structure. }
  procedure doKriging ;
  var
    vtg : TGIS_InterpolationKriging ;
  begin
    vtg := TGIS_InterpolationKriging.Create ;
    try
      // For windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.:
      //   vtg.Windowed := True ;
      //   vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // Attach the progress event callback
      vtg.BusyEvent := doBusyEvent ;
      // The semivariogram model governs spatial dependence structure.
      // Power Law is the default; other models may better represent the data.
      case cmbSemivariance.ItemIndex of
        0 : vtg.Semivariance := TGIS_SemivariancePowerLaw.Create ;     // scale-free power relationship
        1 : vtg.Semivariance := TGIS_SemivarianceExponential.Create ;  // exponential decay of correlation
        2 : vtg.Semivariance := TGIS_SemivarianceGaussian.Create ;     // smooth Gaussian bell-curve decay
        3 : vtg.Semivariance := TGIS_SemivarianceSpherical.Create ;    // linear then flat (common in geology)
        4 : vtg.Semivariance := TGIS_SemivarianceCircular.Create ;     // circular model
        5 : vtg.Semivariance := TGIS_SemivarianceLinear.Create ;       // simple linear model
      end ;
      // Generate the Kriging interpolation grid
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  { doSplines
    Runs Completely Regularized Splines (CRS) interpolation.
    CRS fits a smooth surface through the sample points using radial basis
    functions.  The Tension parameter controls how tightly the surface adheres
    to the sample values versus how smooth it is; a very small value (1e-9)
    produces a near-minimum-curvature surface.  Larger tension values cause
    the surface to relax away from sample points. }
  procedure doSplines ;
  var
    vtg : TGIS_InterpolationSplines ;
  begin
    vtg := TGIS_InterpolationSplines.Create ;
    try
      // For windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.:
      //   vtg.Windowed := True ;
      //   vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // Attach the progress event callback
      vtg.BusyEvent := doBusyEvent ;
      // Tension governs stiffness of the spline surface.
      // 1e-9 gives a minimum-curvature (very smooth) result; increase if
      // the surface shows unwanted oscillations near sparse data areas.
      vtg.Tension := 1e-9 ;
      // Generate the Completely Regularized Splines interpolation grid
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  { doHeatmap
    Runs Gaussian Heat Map or Concentration Map generation.
    Both share the TGIS_GaussianHeatmap engine; the difference is in the
    field used:
      Heat Map          (_concentration=False): spreads the FIELD_VALUE of
                        each point using a Gaussian kernel.  High-value points
                        produce brighter hotspots.
      Concentration Map (_concentration=True):  ignores field values and only
                        counts point density (each point contributes equally).
    EstimateRadius computes the 3-sigma bandwidth automatically from the data
    distribution; halving it (Radius / 2) gives a finer, more peaked result.
    For Heat/Concentration maps the start colour is set to transparent blue
    (alpha=0) so the basemap shows through where density is zero. }
  procedure doHeatmap( const _concentration : Boolean ) ;
  var
    vtg : TGIS_GaussianHeatmap ;
    fld : String ;
  begin
    vtg := TGIS_GaussianHeatmap.Create ;
    try
      // Coordinate.None means point centroids are used as-is without offset
      vtg.Coordinate := TGIS_VectorToGridCoordinate.None ;
      // For Concentration Map supply an empty field name so only point
      // locations (not values) contribute to the output
      if _concentration then
        fld := ''
      else
        fld := FIELD_VALUE ;

      // Attach the progress event callback
      vtg.BusyEvent := doBusyEvent ;
      // Automatically estimate the optimal Gaussian kernel radius from the data.
      // The 3-sigma bandwidth is calculated from the average nearest-neighbour
      // distance; halving it narrows the influence of each point.
      vtg.EstimateRadius( src, src.Extent, dst ) ;
      vtg.Radius := vtg.Radius/2.0 ;
      // Generate the Heat/Concentration Map grid
      vtg.Generate( src, src.Extent, fld, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

begin
  // Disable the button to prevent concurrent runs while interpolation is active
  btnGenerateGrid.Enabled := False ;

  // Retrieve named layers from the loaded project
  src := TGIS_LayerVector( GIS.Get( 'temperatures' ) ) ;  // point data source
  plg := TGIS_LayerVector( GIS.Get( 'country' ) ) ;       // polygon for extent/clip

  // Remove any previously generated interpolation result so we start fresh
  if Assigned( GIS.Get( 'grid' ) ) then
    GIS.Delete( 'grid' ) ;

  // Use the polygon's full extent as the output domain so the grid covers
  // the entire country boundary (which is larger than the scattered points)
  ext := plg.Extent ;

  // Compute the height-to-width ratio so the grid cells remain roughly square
  // when projected (avoids distorted cells on wide or tall extents)
  rat := ( ext.YMax - ext.YMin )/( ext.XMax - ext.XMin ) ;

  // Create the destination raster layer in memory (not backed by a file)
  dst := TGIS_LayerPixel.Create ;
  dst.Name := 'grid' ;
  // Build allocates the pixel buffer.  True = in-memory, src.CS = coordinate
  // system of the source layer, GRID_RESOLUTION pixels wide, aspect-ratio
  // corrected height ensures square pixels.
  dst.Build( True, src.CS, ext, GRID_RESOLUTION, RoundS( rat*GRID_RESOLUTION ) ) ;
  // Disable hill-shading on the interpolated grid (no elevation data to shade)
  dst.Params.Pixel.GridShadow := False ;

  // Default start colour for the colour ramp (overridden for heat/concentration maps)
  clr := TGIS_Color.Blue ;

  // Dispatch to the selected interpolation method
  if rbtnIDW.Checked then begin
    doIDW ;
  end
  else
  if rbtnKriging.Checked then begin
    doKriging ;
  end
  else
  if rbtnSplines.Checked then begin
    doSplines ;
  end
  else
  if rbtnHeatMap.Checked then begin
    doHeatmap( False ) ;
    // Use transparent blue as the ramp start so the basemap shows through
    // where the heat value is zero (alpha=0 means fully transparent)
    clr := TGIS_Color.FromARGB( 0, 0, 0, 255 ) ;
  end
  else
  if rbtnConcentrationMap.Checked then begin
    doHeatmap( True ) ;
    clr := TGIS_Color.FromARGB( 0, 0, 0, 255 ) ;
  end ;

  // Apply a three-stop colour ramp across the full value range of the grid.
  // Arguments: startColour, midColour, endColour, minVal, midVal, maxVal,
  //            useLog, minStep, maxStep, existingZones, clearZones
  // This creates AltitudeMapZones entries that map data values to colours.
  dst.GenerateRamp(
    clr, TGIS_Color.Lime, TGIS_Color.Red,
    dst.MinHeight, ( dst.MaxHeight - dst.MinHeight )/2, dst.MaxHeight, False,
    ( dst.MaxHeight - dst.MinHeight )/100,
    ( dst.MaxHeight - dst.MinHeight )/10,
    nil, False
  ) ;

  // Clip the grid to the country polygon so only cells inside the boundary
  // are rendered.  GetShape(6) retrieves the 7th shape (0-based) from the
  // polygon layer; CreateCopy is needed because CuttingPolygon takes ownership.
  dst.CuttingPolygon := TGIS_ShapePolygon( plg.GetShape( 6 ).CreateCopy ) ;

  // Add the generated grid layer to the viewer's layer list
  GIS.Add( dst ) ;
  // Zoom to show the new result
  GIS.FullExtent ;

  // Reset the progress bar now that the operation is complete
  pbProgress.Position := 0 ;

  btnGenerateGrid.Enabled := True ;
end;

end.
