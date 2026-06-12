//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  PixelFilters - demonstrates how to apply image-processing filters to raster
  (pixel) layers using TatukGIS.

  The sample loads a DEM (Digital Elevation Model) in ESRI ADF format and lets
  the user pick a filter from a list box, configure its parameters, and execute
  it against the layer.  The result is displayed in the viewer.

  Supported filter categories:
    - Intensity / threshold  : Threshold, Salt-and-Pepper Noise, Gaussian Noise
    - Convolution kernels    : Low-Pass, High-Pass, Gaussian, Laplacian, Gradient
                               direction, Point Detector, Line Detectors
    - Rank / statistical     : Sobel Magnitude, Range, Midpoint, Minimum, Maximum,
                               Arithmetic Mean, Alpha-Trimmed Mean,
                               Contra-Harmonic Mean, Geometric Mean, Harmonic Mean,
                               Weighted Mean, Yp Mean, Majority, Minority, Median,
                               Weighted Median, Sum, Standard Deviation, Unique Count
    - Morphological          : Erosion, Dilation, Opening, Closing, Top-Hat, Bottom-Hat

  Key TatukGIS API concepts shown here:
    - TGIS_LayerPixel             : base class for raster layers; the input source
    - TGIS_PixelFilterAbstract    : abstract base class for all pixel filters;
                                    wire up SourceLayer, DestinationLayer, Band,
                                    ColorSpace, BusyEvent, then call Execute()
    - TGIS_PixelFilterConvolution : applies a predefined or custom kernel matrix;
                                    the kernel type is set via MaskType
    - TGIS_PixelFilterMaskType    : enumeration of built-in convolution kernels
    - TGIS_PixelFilterStructuringElementType : shape of the neighbourhood for
                                    morphological operations (Square, Diamond, Disk,
                                    line variants)
    - TGIS_PixelFilterColorSpace  : colour space in which the filter operates;
                                    HSL is used here so the filter acts on luminance
    - TGIS_LayerPixel.Build()     : creates an in-memory output raster layer that
                                    matches the input layer's CRS and dimensions
    - TGIS_LayerPixel.BitWidth/BitHeight : pixel dimensions of the raster
    - TGIS_LayerPixel.MinHeight/MaxHeight : data range used to set filter thresholds
    - filter.BusyEvent            : callback invoked during Execute() to report
                                    progress; pos=0 initialises, pos=-1 signals end
    - GIS.Delete(name) / GIS.Add(): replaces the input layer with the output layer
                                    after the first successful filter run (bFirst flag)
    - TGIS_Utils.GisCreateLayer() : factory method that infers the layer type from
                                    the file extension and returns a TGIS_Layer
}
unit Unit1;

interface

uses

  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisUtils,
  GisTypesUI,
  GisPixelFilter,    // TGIS_PixelFilter* classes - convolution, morphology, statistics
  GisViewer,
  GisLayerPixel,     // TGIS_LayerPixel base class
  GisLayerADF,       // ESRI ADF raster layer support
  GisLayer,

  Vcl.GisViewerWnd, VCL.GisControlLegend;

type
  TForm1 = class(TForm)
    cbStructure: TComboBox;         // Structuring element shape for morphological filters
    Label1: TLabel;
    lblStructuring: TLabel;         // Label for cbStructure
    btnExecute: TButton;            // Applies the selected filter to the raster layer
    GIS: TGIS_ViewerWnd;            // TatukGIS map viewer control
    cbMask: TComboBox;              // Convolution kernel type selector (for Convolution filter)
    sbMaskSize: TScrollBar;         // Block/kernel size slider (for block-based filters)
    lblMaskSizeValue: TLabel;       // Displays the current block size as "NxN"
    lblMaskSize: TLabel;            // Label for sbMaskSize
    lblMask: TLabel;                // Label for cbMask
    GIS_Legend: TGIS_ControlLegend; // Layer legend panel showing loaded layers
    pbProgress: TProgressBar;       // Progress bar updated by the filter's BusyEvent
    lbFilter: TListBox;             // List of available filter types
    btnReset: TButton;              // Reloads the original raster and resets bFirst
    procedure open ;
    procedure sbMaskSizeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure onFilterChange(Sender: TObject);
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
    procedure btnResetClick(Sender: TObject);
  private
    { bFirst: True on the first Execute call.  On the first run the filter writes
      into a fresh output layer and then that output replaces the input in the viewer.
      On subsequent runs the output IS the input (in-place filtering). }
    bFirst : Boolean ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  GisRegistredLayers ;

{ TForm1.btnExecuteClick
  Reads the currently selected filter from lbFilter, constructs the appropriate
  TGIS_PixelFilter* object with its parameters, wires it to the source and
  destination layers, then calls Execute().

  On the first run (bFirst=True):
    - A new in-memory TGIS_LayerPixel is created (Build) with the same CRS and
      pixel dimensions as the input layer.
    - After Execute(), the input layer is removed from the viewer and the output
      is added in its place.
  On subsequent runs (bFirst=False):
    - The output IS the same object as the input (in-place filtering).

  BlockSize is derived from the sbMaskSize scroll-bar position using the formula:
    block = position * 2 + 1
  This always yields an odd number (3, 5, 7, ...) as required by symmetric kernels.

  The filter is run in Band=1 and ColorSpace=HSL so that it operates on the
  luminance channel of the raster rather than on RGB directly.

  The BusyEvent callback (doBusyEvent) drives the pbProgress bar during the
  potentially long-running Execute() call. }
procedure TForm1.btnExecuteClick(Sender: TObject);
var
  fltr  : TGIS_PixelFilterAbstract               ;
  input : TGIS_LayerPixel                        ;
  output: TGIS_LayerPixel                        ;
  mask  : TGIS_PixelFilterMaskType               ;
  struct: TGIS_PixelFilterStructuringElementType ;
  block : Integer                                ;
begin
  // The first layer in the viewer is always the raster being filtered
  input := GIS.Items[0] as TGIS_LayerPixel ;

  if bFirst then begin
    // First run: create an empty output layer matching the input's geometry
    output := TGIS_LayerPixel.Create ;
    output.Name := 'Result' ;
    // Build(inMemory, CS, Extent, pixelWidth, pixelHeight) - True = in-memory layer
    output.Build( True, input.CS, input.Extent, input.BitWidth, input.BitHeight );
    output.Open ;
  end
  else
    output := input ;  // Subsequent runs: filter the layer in place

  // Derive an odd block/kernel size from the scroll-bar position
  block := sbMaskSize.Position * 2 + 1 ;

  try
    case lbFilter.ItemIndex of
      // --- Threshold ---
      // Binarises the raster: pixels above the threshold are set to max, others to 0.
      // Threshold is set to 30% of the data range as a reasonable default.
      0  :  begin
              fltr := TGIS_PixelFilterThreshold.Create ;
              TGIS_PixelFilterThreshold( fltr ).Threshold := ( input.MinHeight + input.MaxHeight ) * 0.3 ;
            end ;

      // --- Salt-and-Pepper Noise ---
      // Adds random white/black pixels to the raster (impulse noise simulation).
      // Amount controls the percentage of pixels that are replaced.
      1  :  begin
              fltr := TGIS_PixelFilterNoiseSaltPepper.Create ;
              TGIS_PixelFilterNoiseSaltPepper( fltr ).Amount := 10 ;
            end;

      // --- Gaussian Noise ---
      // Adds normally distributed random noise; Amount is the standard deviation.
      2  :  begin
              fltr := TGIS_PixelFilterNoiseGaussian.Create ;
              TGIS_PixelFilterNoiseGaussian( fltr ).Amount := 10 ;
            end;

      // --- Convolution ---
      // Applies a predefined kernel matrix (selected via cbMask) to each pixel
      // neighbourhood.  Kernels range from simple smoothing (Low-Pass) to edge
      // detection (Laplacian, Gradient) and feature detection (Line/Point Detectors).
      3  :  begin
              fltr := TGIS_PixelFilterConvolution.Create ;
              case cbMask.ItemIndex of
                0  : mask := TGIS_PixelFilterMaskType.LowPass3x3 ;         // Smoothing 3x3
                1  : mask := TGIS_PixelFilterMaskType.LowPass5x5 ;         // Smoothing 5x5
                2  : mask := TGIS_PixelFilterMaskType.LowPass7x7 ;         // Smoothing 7x7
                3  : mask := TGIS_PixelFilterMaskType.HighPass3x3 ;        // Sharpening 3x3
                4  : mask := TGIS_PixelFilterMaskType.HighPass5x5 ;        // Sharpening 5x5
                5  : mask := TGIS_PixelFilterMaskType.HighPass7x7 ;        // Sharpening 7x7
                6  : mask := TGIS_PixelFilterMaskType.Gaussian3x3 ;        // Gaussian blur 3x3
                7  : mask := TGIS_PixelFilterMaskType.Gaussian5x5 ;        // Gaussian blur 5x5
                8  : mask := TGIS_PixelFilterMaskType.Gaussian7x7 ;        // Gaussian blur 7x7
                9  : mask := TGIS_PixelFilterMaskType.Laplacian3x3 ;       // Laplacian edge detect 3x3
                10 : mask := TGIS_PixelFilterMaskType.Laplacian5x5 ;       // Laplacian edge detect 5x5
                11 : mask := TGIS_PixelFilterMaskType.GradientNorth ;      // Directional gradient N
                12 : mask := TGIS_PixelFilterMaskType.GradientEast ;       // Directional gradient E
                13 : mask := TGIS_PixelFilterMaskType.GradientSouth ;      // Directional gradient S
                14 : mask := TGIS_PixelFilterMaskType.GradientWest ;       // Directional gradient W
                15 : mask := TGIS_PixelFilterMaskType.GradientNorthwest ;  // Diagonal gradient NW
                16 : mask := TGIS_PixelFilterMaskType.GradientNortheast ;  // Diagonal gradient NE
                17 : mask := TGIS_PixelFilterMaskType.GradientSouthwest ;  // Diagonal gradient SW
                18 : mask := TGIS_PixelFilterMaskType.GradientSoutheast ;  // Diagonal gradient SE
                19 : mask := TGIS_PixelFilterMaskType.PointDetector ;            // Isolated point detector
                20 : mask := TGIS_PixelFilterMaskType.LineDetectorHorizontal ;   // Horizontal line detector
                21 : mask := TGIS_PixelFilterMaskType.LineDetectorVertical ;     // Vertical line detector
                22 : mask := TGIS_PixelFilterMaskType.LineDetectorLeftDiagonal ; // Left-diagonal line detector
                23 : mask := TGIS_PixelFilterMaskType.LineDetectorHorizontal ;   // (duplicate entry)
              end;
              TGIS_PixelFilterConvolution( fltr ).MaskType := mask ;
            end;

      // --- Sobel Magnitude ---
      // Computes the gradient magnitude using Sobel operators in X and Y directions.
      // The result highlights edges; BlockSize controls the neighbourhood window.
      4  :  begin
              fltr := TGIS_PixelFilterSobelMagnitude.Create ;
              TGIS_PixelFilterSobelMagnitude( fltr ).BlockSize := block ;
            end;

      // --- Range ---
      // Replaces each pixel with the local value range (max - min) in the block.
      // High values indicate areas of high local variability (edges, textures).
      5  :  begin
              fltr := TGIS_PixelFilterRange.Create ;
              TGIS_PixelFilterRange( fltr ).BlockSize := block ;
            end;

      // --- Midpoint ---
      // Replaces each pixel with the midpoint (average of local min and max).
      // Useful for removing impulse noise while preserving broad structure.
      6  :  begin
              fltr := TGIS_PixelFilterMidpoint.Create ;
              TGIS_PixelFilterMidpoint( fltr ).BlockSize := block ;
            end;

      // --- Minimum (Erosion-like) ---
      // Replaces each pixel with the minimum value in the block window.
      7  :  begin
              fltr := TGIS_PixelFilterMinimum.Create ;
              TGIS_PixelFilterMinimum( fltr ).BlockSize := block ;
            end;

      // --- Maximum (Dilation-like) ---
      // Replaces each pixel with the maximum value in the block window.
      8  :  begin
              fltr := TGIS_PixelFilterMaximum.Create ;
              TGIS_PixelFilterMaximum( fltr ).BlockSize := block ;
            end;

      // --- Arithmetic Mean ---
      // Replaces each pixel with the mean of the block neighbourhood.
      // Smooths the raster; equivalent to a box/averaging filter.
      9  :  begin
              fltr := TGIS_PixelFilterArithmeticMean.Create ;
              TGIS_PixelFilterArithmeticMean( fltr ).BlockSize := block ;
            end;

      // --- Alpha-Trimmed Mean ---
      // Mean after discarding a fraction of the extreme values.
      // Robust to outliers (e.g. salt-and-pepper noise).
      10 :  begin
              fltr := TGIS_PixelFilterAlphaTrimmedMean.Create ;
              TGIS_PixelFilterAlphaTrimmedMean( fltr ).BlockSize := block ;
            end;

      // --- Contra-Harmonic Mean ---
      // Weighted mean; effective against different types of noise depending on
      // the order parameter Q (positive Q removes pepper noise, negative removes salt).
      11 :  begin
              fltr := TGIS_PixelFilterContraHarmonicMean.Create ;
              TGIS_PixelFilterContraHarmonicMean( fltr ).BlockSize := block ;
            end;

      // --- Geometric Mean ---
      // Nth root of the product of N block values.
      // Less noise amplification than arithmetic mean; preserves fine detail.
      12 :  begin
              fltr := TGIS_PixelFilterGeometricMean.Create ;
              TGIS_PixelFilterGeometricMean( fltr ).BlockSize := block ;
            end;

      // --- Harmonic Mean ---
      // Reciprocal of the arithmetic mean of reciprocals.
      // Good for removing salt noise; poor for pepper noise.
      13 :  begin
              fltr := TGIS_PixelFilterHarmonicMean.Create ;
              TGIS_PixelFilterHarmonicMean( fltr ).BlockSize := block ;
            end;

      // --- Weighted Mean ---
      // Mean weighted by distance from the centre of the block.
      // Closer neighbours contribute more than distant ones.
      14 :  begin
              fltr := TGIS_PixelFilterWeightedMean.Create ;
              TGIS_PixelFilterWeightedMean( fltr ).BlockSize := block ;
            end;

      // --- Yp Mean ---
      // Generalised power-mean filter; useful for specialised noise models.
      15 :  begin
              fltr := TGIS_PixelFilterYpMean.Create ;
              TGIS_PixelFilterYpMean( fltr ).BlockSize := block ;
            end;

      // --- Majority ---
      // Replaces each pixel with the most frequently occurring value in the block.
      // Useful for smoothing categorical/classified rasters.
      16 :  begin
              fltr := TGIS_PixelFilterMajority.Create ;
              TGIS_PixelFilterMajority( fltr ).BlockSize := block ;
            end;

      // --- Minority ---
      // Replaces each pixel with the least frequently occurring value in the block.
      17 :  begin
              fltr := TGIS_PixelFilterMinority.Create ;
              TGIS_PixelFilterMinority( fltr ).BlockSize := block ;
            end;

      // --- Median ---
      // Replaces each pixel with the median value in the block.
      // Very effective at removing salt-and-pepper noise without blurring edges.
      18 :  begin
              fltr := TGIS_PixelFilterMedian.Create ;
              TGIS_PixelFilterMedian( fltr ).BlockSize := block ;
            end;

      // --- Weighted Median ---
      // Median with distance-based weights; preserves edges better than plain median.
      19 :  begin
              fltr := TGIS_PixelFilterWeightedMedian.Create ;
              TGIS_PixelFilterWeightedMedian( fltr ).BlockSize := block ;
            end;

      // --- Sum ---
      // Replaces each pixel with the sum of all values in the block.
      20 :  begin
              fltr := TGIS_PixelFilterSum.Create ;
              TGIS_PixelFilterSum( fltr ).BlockSize := block ;
            end;

      // --- Standard Deviation ---
      // Replaces each pixel with the local standard deviation, highlighting
      // areas of high variability (texture, edges).
      21 :  begin
              fltr := TGIS_PixelFilterStandardDeviation.Create ;
              TGIS_PixelFilterStandardDeviation( fltr ).BlockSize := block ;
            end;

      // --- Unique Count ---
      // Replaces each pixel with the count of distinct values in the block.
      // Useful for diversity analysis on classified rasters.
      22 :  begin
              fltr := TGIS_PixelFilterUniqueCount.Create ;
              TGIS_PixelFilterUniqueCount( fltr ).BlockSize := block ;
            end;

      // --- Morphological filters (23-28) ---
      // These operate on the shape of features in the raster using a structuring
      // element (SE).  The SE shape is selected via cbStructure.
      //
      // Erosion  : shrinks bright regions (removes small protrusions)
      // Dilation : expands bright regions (fills small gaps)
      // Opening  : Erosion followed by Dilation; removes small bright objects
      // Closing  : Dilation followed by Erosion; fills small dark holes
      // Top-Hat  : original minus Opening; highlights bright features smaller than the SE
      // Bottom-Hat: Closing minus original; highlights dark features smaller than the SE

      23 :  begin
              fltr := TGIS_PixelFilterErosion.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterErosion( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterErosion( fltr ).BlockSize := block ;
            end;
      24 :  begin
              fltr := TGIS_PixelFilterDilation.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterDilation( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterDilation( fltr ).BlockSize := block ;
            end;
      25 :  begin
              fltr := TGIS_PixelFilterOpening.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterOpening( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterOpening( fltr ).BlockSize := block ;
            end;
      26 :  begin
              fltr := TGIS_PixelFilterClosing.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterClosing( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterClosing( fltr ).BlockSize := block ;
            end;
      27 :  begin
              fltr := TGIS_PixelFilterTopHat.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterTopHat( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterTopHat( fltr ).BlockSize := block ;
            end;
      28 :  begin
              fltr := TGIS_PixelFilterBottomHat.Create ;
              case cbStructure.ItemIndex of
                0 : struct := TGIS_PixelFilterStructuringElementType.Square            ;
                1 : struct := TGIS_PixelFilterStructuringElementType.Diamond           ;
                2 : struct := TGIS_PixelFilterStructuringElementType.Disk              ;
                3 : struct := TGIS_PixelFilterStructuringElementType.LineHorizontal    ;
                4 : struct := TGIS_PixelFilterStructuringElementType.LineVertical      ;
                5 : struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal  ;
                6 : struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal ;
              end;
              TGIS_PixelFilterBottomHat( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterBottomHat( fltr ).BlockSize := block ;
            end;
    end;

    // Wire up the common filter properties shared by all filter types
    fltr.SourceLayer      := input ;         // Layer to read pixel values from
    fltr.DestinationLayer := output ;        // Layer to write filtered values into
    fltr.Band             := 1 ;             // Process band 1 (only band for a DEM)
    fltr.ColorSpace       := TGIS_PixelFilterColorSpace.HSL ; // Operate on luminance channel
    fltr.BusyEvent        := doBusyEvent;    // Hook up the progress callback
    fltr.Execute ;                           // Run the filter (may be slow for large rasters)
  finally
    fltr.Free ;
  end;

  // Apply anti-alias rendering to the result and disable the altitude shadow
  output.Params.Pixel.GridShadow := False ;
  output.ApplyAntialiasSettings( True ) ;

  if bFirst then begin
    // First run only: swap the input layer out and add the result layer
    GIS.Delete( input.Name );
    GIS.Add( output ) ;
    bFirst := False ;
  end ;
  GIS.InvalidateWholeMap ;  // Force a repaint to show the filtered result
end;

{ TForm1.btnResetClick
  Reloads the original raster, clearing any previously applied filters. }
procedure TForm1.btnResetClick(Sender: TObject);
begin
  open ;
end;

{ TForm1.doBusyEvent
  Progress callback invoked by the filter's Execute() method.
  _pos=0  : initialise the progress bar
  _pos=-1 : filter finished; reset the progress bar
  otherwise: update the bar position to reflect current progress }
procedure TForm1.doBusyEvent(_sender: TObject; _pos: Integer; _end: Integer; var _abort: Boolean);
begin
  case _pos of
    // Initialize the progress bar at the start of Execute()
    0  : begin
      pbProgress.Min := 0 ;
      pbProgress.Max := 100 ;
      pbProgress.Position := 0 ;
    end ;
    // Filter has finished; reset the progress bar to 0
    -1 : pbProgress.Position := 0 ;
  else
    // Normal progress update
    pbProgress.Position := _pos ;
  end ;
end ;

{ TForm1.onFilterChange
  Adjusts the visibility of the Mask, Mask Size, and Structuring Element controls
  to show only the parameters relevant to the currently selected filter type.

  Filters 0-2 (Threshold, Salt-Pepper, Gaussian Noise) take no user parameters
  beyond what is hard-coded, so all parameter controls are hidden.

  Filter 3 (Convolution) shows only the Mask combo box (kernel type selection).

  Filters 4-22 (rank/statistical) show only the block-size slider.

  Filters 23-28 (morphological) show both the block-size slider and the
  structuring element combo box. }
procedure TForm1.onFilterChange(Sender: TObject);
begin
  if ( lbFilter.ItemIndex = 0 ) or
     ( lbFilter.ItemIndex = 1 ) or
     ( lbFilter.ItemIndex = 2 ) then begin
     // No configurable parameters for noise/threshold filters
     cbStructure.Visible      := False ;
     lblStructuring.Visible   := False ;
     lblMask.Visible          := False ;
     cbMask.Visible           := False ;
     lblMaskSize.Visible      := False ;
     lblMaskSizeValue.Visible := False ;
     sbMaskSize.Visible       := False ;
  end
  else
  begin
    if ( lbFilter.ItemIndex = 23 ) or
     ( lbFilter.ItemIndex = 24 ) or
     ( lbFilter.ItemIndex = 25 ) or
     ( lbFilter.ItemIndex = 26 ) or
     ( lbFilter.ItemIndex = 27 ) or
     ( lbFilter.ItemIndex = 28 ) then
    begin
       // Morphological filters need both block size and structuring element
       cbStructure.Visible      := True  ;
       lblStructuring.Visible   := True  ;
       lblMask.Visible          := True  ;
       cbMask.Visible           := True  ;
       lblMaskSize.Visible      := True  ;
       lblMaskSizeValue.Visible := True  ;
       sbMaskSize.Visible       := True  ;
    end
    else
    begin
       // Rank/statistical filters: only block size is needed
       cbStructure.Visible      := False ;
       lblStructuring.Visible   := False ;
       lblMask.Visible          := False ;
       cbMask.Visible           := False ;
       lblMaskSize.Visible      := False ;
       lblMaskSizeValue.Visible := False ;
       sbMaskSize.Visible       := False ;
    end ;

    if lbFilter.ItemIndex = 3 then begin
       // Convolution filter: show only the kernel (Mask) selector
       cbMask.Visible           := True  ;
       lblMask.Visible          := True  ;
       lblMaskSize.Visible      := False ;
       lblMaskSizeValue.Visible := False ;
       sbMaskSize.Visible       := False ;
    end
    else
    begin
       // All other parameterised filters: show only the block-size slider
       cbMask.Visible           := False ;
       lblMask.Visible          := False ;
       lblMaskSize.Visible      := True  ;
       lblMaskSizeValue.Visible := True  ;
       sbMaskSize.Visible       := True  ;
    end ;
  end ;
end;

{ TForm1.open
  Loads (or reloads) the sample DEM raster layer into the viewer.
  The ADF file is an ESRI ARC/INFO Grid format DEM covering a portion of
  San Bernardino County, California (National Elevation Dataset).
  AltitudeMapZones are cleared and GridShadow is disabled so the layer renders
  as a plain grey-scale elevation image rather than a colourised hillshade.
  bFirst is set to True so the next Execute() creates a fresh output layer. }
procedure TForm1.open;
var
  ll : TGIS_LayerPixel ;
begin
  GIS.Close ;
  // GisCreateLayer() infers the layer type from the file extension/format
  ll := TGIS_LayerPixel(
    TGIS_Utils.GisCreateLayer( '', TGIS_Utils.GisSamplesDataDirDownload +
      'World\Countries\USA\States\California\San Bernardino\NED\w001001.adf' )
  ) ;
  ll.Open ;
  ll.Params.Pixel.AltitudeMapZones.Clear ;  // Remove colour zones so DEM renders as grey
  ll.Params.Pixel.GridShadow := False ;     // Disable hillshade shadow for a plain view

  GIS.Add( ll );
  GIS.FullExtent ;

  bFirst := True ;  // Signal that the next Execute() must create a fresh output layer
end;

{ TForm1.FormCreate
  Initialises default selections and loads the raster layer on startup. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  lbFilter.ItemIndex := 0 ;      // Default to Threshold filter
  cbStructure.ItemIndex := 0 ;   // Default structuring element: Square
  cbMask.ItemIndex := 0 ;        // Default convolution kernel: Low-Pass 3x3

  open ;
end;

{ TForm1.sbMaskSizeChange
  Updates the lblMaskSizeValue label whenever the mask-size scroll bar moves.
  The block size is always odd: 2*position + 1 (e.g. position=1 -> 3x3). }
procedure TForm1.sbMaskSizeChange(Sender: TObject);
var
  i : Integer ;
begin
  i := 2 * sbMaskSize.Position + 1 ;
  lblMaskSizeValue.Caption := IntToStr( i ) + 'x' + IntToStr( i ) ;
end;

end.
