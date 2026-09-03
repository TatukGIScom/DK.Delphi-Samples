//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  WindAnimation — demonstrates animated wind particle rendering on a geographic map (Delphi/VCL).

  What the sample shows:
    - Custom GIS layer implementation for rendering complex animated data
    - Loading meteorological wind data from JSON format (U/V wind components)
    - Particle system simulation with wind-driven movement (4000+ particles)
    - Bilinear interpolation of grid data for smooth particle motion
    - Real-time coordinate transformation between geographic (WGS84) and screen pixels
    - Opacity/fading effects for visual trail smoothing
    - Dynamic buffer management for high-performance rendering
    - Speed-based color gradients (Windy-style wind visualization)
    - Particle respawning at map edges and age limits
    - Integration with TatukGIS viewer viewport offsets and zoom levels

  Key TatukGIS API concepts shown here:
    TGIS_Layer                  - base class for custom layer implementations
    TGIS_LayerWind              - custom wind particle layer
    TGIS_Bitmap                 - double-buffering for smooth animation
    TGIS_RendererAbstract       - abstract renderer for layer drawing
    TGIS_RendererContext        - rendering context setup
    DrawEx                      - custom layer rendering override
    TGIS_Extent / TGIS_Point    - geographic coordinate system
    TWindEngine                 - particle system and wind interpolation
}
unit GisLayerWind ;

interface

uses
  Types,
  SysUtils,
  Classes,
  GisLayer,
  GisTypes,
  GisTypesUI,
  WindEngineUnit ;

type
  /// <summary>
  ///   A custom GIS layer responsible for managing and drawing animated wind maps.
  /// </summary>
  TGIS_LayerWind = class(TGIS_Layer)
  private
    FEngine  : TWindEngine ;
    FBuffer  : TGIS_Bitmap ;
  protected
    /// <summary>
    ///   Initializes the layer, sets up the coordinate system, creates the wind engine,
    ///   and allocates the rendering buffer.
    /// </summary>
    procedure setUp ; override ;

    /// <summary>
    ///   Frees allocated resources including the wind engine and the bitmap buffer.
    /// </summary>
    procedure doDestroy ; override ;
  public
    /// <summary>
    ///   Creates a new instance of the wind GIS layer.
    /// </summary>
    constructor Create ; override ;

    /// <summary>
    ///   Draws the layer content (wind particles) within the specified geographic extent.
    /// </summary>
    /// <param name="_extent">The geographic extent to draw.</param>
    /// <returns>True if the drawing was successful, False otherwise.</returns>
    function DrawEx(const _extent : TGIS_Extent) : Boolean ; override ;
  end ;

implementation

uses
  Math,
  IOUtils,
  GisInternals,
  GisFunctions,
  GisRendererAbstract,
  GisParams ;

const
  NUMBER_OF_PARTICLES = 4000 ;
  FADING_EFFECT = 80 ;
  SPEED_FACTOR = 1.33 ;
  ANIMATION_SPEED = 1.5 ;

{ TGIS_LayerWind }

{ Constructor
  Initializes the wind layer with pixel-based rendering parameters.
  Sets layer as persistent and prepares for wind engine data. }
constructor TGIS_LayerWind.Create ;
begin
  inherited ;

  ParamsList.SetUp(TGIS_ParamsSectionPixel.Create) ;
  FSubType := FSubType + [TGIS_LayerSubType.Persistent] ;
  Path := '' ;
  Name := '' ;
  FIsModified := False ;
end ;

{ doDestroy (override)
  Releases the wind engine and rendering buffer when the layer is destroyed. }
procedure TGIS_LayerWind.doDestroy ;
begin
  FEngine.Free ;
  FBuffer.Free ;

  inherited ;
end ;

{ setUp (override)
  Initializes the wind layer: sets WGS84 coordinate system, creates rendering
  buffer and wind engine, loads meteorological JSON data from Path property,
  and initializes particles.

  Algorithm:
    1. Set coordinate system to WGS84 (EPSG:4326) for global wind data.
    2. Allocate rendering buffer (double-buffer) sized to viewer canvas.
    3. Create wind engine with 4000 particles and multi-color mode.
    4. Load wind data from JSON file if Path points to valid file.
    5. Initialize particles scattered across viewer window. }
procedure TGIS_LayerWind.setUp ;
var
  w, h : Integer ;
begin
  inherited ;

  // Set coordinate system to WGS84 (world extent)
  SetCSByEPSG(4326) ;
  FExtent := CS.ValidityExtent ;

  // Determine viewer canvas dimensions for buffer allocation
  w := Viewer.Ref.ViewerParent.ControlCanvasWidth ;
  h := Viewer.Ref.ViewerParent.ControlCanvasHeight ;

  // Allocate double-buffer for particle trail rendering
  FBuffer := TGIS_Bitmap.Create(w, h) ;
  FBuffer.Clear( TGIS_Color.FromARGB(255, 255, 255, 255) ) ;
  FBuffer.MakeTransparent ;

  // Initialize wind engine and load meteorological data
  FEngine := TWindEngine.Create( NUMBER_OF_PARTICLES ) ;
  FEngine.OneColor := False ;

  if SafeFileExists(Path) then
    FEngine.LoadDataFromJSON( TFile.ReadAllText(Path) ) ;

  // Scatter particles across current viewport
  FEngine.InitializeParticles(w, h) ;
end ;

{ DrawEx (override)
  Renders animated wind particles for the current map extent.
  Updates particle positions, applies fading trail effects, and composites final frame.

  Algorithm:
    1. Exit if layer not visible in current extent.
    2. Get viewer canvas dimensions; reallocate buffer if size changed (e.g., window resize).
    3. Convert map extent to screen rectangle accounting for viewport offset.
    4. Update all particles: interpolate wind vectors, move particles, handle respawning.
    5. Apply opacity/fading effect based on average wind speed (visual trail effect).
    6. Render particles onto double-buffer using abstract renderer.
    7. Composite final buffer image onto main GIS canvas. }
function TGIS_LayerWind.DrawEx(
  const _extent : TGIS_Extent
) : Boolean ;
var
  avgSpeed : Single ;
  calcAlpha : Single ;
  w, h : Integer ;
  rdr, rnd : TGIS_RendererAbstract ;
  ctx : TGIS_RendererContext ;
  rct : TRect ;
begin
  Result := IsVisible(_extent) ;
  if not Result then Exit ;

  rdr := TGIS_RendererAbstract(Renderer) ;
  w := Viewer.Ref.ViewerParent.ControlCanvasWidth ;
  h := Viewer.Ref.ViewerParent.ControlCanvasHeight ;

  // Reallocate buffer if viewer window size changed
  if (w <> FBuffer.Width) or (h <> FBuffer.Height) then
  begin
    FBuffer.Free ;
    FBuffer := TGIS_Bitmap.Create(w, h) ;
    FBuffer.MakeTransparent ;
  end ;

  // Convert map extent to screen rectangle (accounts for window offset)
  rct := Viewer.Ref.MapToScreenRect(_extent) ;

  // Update particle simulation for current extent and viewport
  FEngine.UpdateWGSWithOffset(
    w, h,
    rct.Width,       // Map drawing area width
    rct.Height,      // Map drawing area height
    rct.Left,        // Left offset (pan/zoom dependent)
    rct.Top,         // Top offset (pan/zoom dependent)
    ANIMATION_SPEED,
    _extent.XMin, _extent.XMax, _extent.YMin, _extent.YMax
  ) ;

  // Dynamic fading effect: faster wind = more opaque trails
  avgSpeed := FEngine.GetAverageSpeed ;
  calcAlpha := FADING_EFFECT + (avgSpeed * SPEED_FACTOR) ;
  calcAlpha := EnsureRange(Round(calcAlpha), 8, 100) ;

  FBuffer.ApplyOpacity(Round(calcAlpha)) ;

  // Render particles onto double-buffer
  ctx := TGIS_RendererContext.Create ;
  try
    rnd := rdr.CreateInstance ;
    try
      ctx.AssignBaseMap(FBuffer, False) ;
      rnd.CreateContext(Viewer.Ref.ViewerParent, Viewer.Ref, ctx, Point(0, 0), w, h, Viewer.Ref.PPI, 100) ;
      rnd.PrepareDraw ;

      FEngine.DrawParticles(rnd) ;
    finally
      rnd.AfterDraw ;
      rnd.ReleaseContext ;
      rnd.Free ;
    end ;
  finally
    ctx.Free ;
  end ;

  // Composite final buffer to GIS canvas
  rdr.CanvasDrawBitmap( FBuffer, Rect(0, 0, w, h) ) ;

  Result := True ;
end ;

end.
