/// <summary>
///   Provides a custom GIS layer that renders animated wind particles
///   using the TWindEngine.
/// </summary>
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

constructor TGIS_LayerWind.Create ;
begin
  inherited ;

  // Initialize parameters and set the layer subtype as persistent
  ParamsList.SetUp(TGIS_ParamsSectionPixel.Create) ;
  FSubType := FSubType + [TGIS_LayerSubType.Persistent] ;
  Path := '' ;
  Name := '' ;
  FIsModified := False ;
end ;

procedure TGIS_LayerWind.doDestroy ;
begin
  // Free the internal wind engine and bitmap buffer to prevent memory leaks
  FEngine.Free ;
  FBuffer.Free ;

  inherited ;
end ;

procedure TGIS_LayerWind.setUp ;
var
  w, h : Integer ;
begin
  inherited ;

  // Set the coordinate system to WGS84 (EPSG : 4326) and initialize the valid extent
  SetCSByEPSG(4326) ;
  FExtent := CS.ValidityExtent ;

  // Retrieve the current viewer canvas dimensions
  w := Viewer.Ref.ViewerParent.ControlCanvasWidth ;
  h := Viewer.Ref.ViewerParent.ControlCanvasHeight ;

  // Create and initialize the bitmap buffer used for smooth particle trail rendering
  FBuffer := TGIS_Bitmap.Create(w, h) ;
  FBuffer.Clear( TGIS_Color.FromARGB(255, 255, 255, 255) ) ;
  FBuffer.MakeTransparent ;

  // Initialize the wind engine with 4000 active particles
  FEngine := TWindEngine.Create( NUMBER_OF_PARTICLES ) ;
  // use gradient color ramp
  FEngine.OneColor := False ;

  // Load meteorological JSON data if the specified file path exists
  if SafeFileExists(Path) then
    FEngine.LoadDataFromJSON( TFile.ReadAllText(Path) ) ;

  // Initialize particle positions within the viewer's screen dimensions
  FEngine.InitializeParticles(w, h) ;
end ;

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
  // Verify if the layer is visible in the current extent
  Result := IsVisible(_extent) ;
  if not Result then Exit ;

  rdr := TGIS_RendererAbstract(Renderer) ;
  w := Viewer.Ref.ViewerParent.ControlCanvasWidth ;
  h := Viewer.Ref.ViewerParent.ControlCanvasHeight ;

  // Reallocate the rendering buffer dynamically if the viewer dimensions have changed
  if (w <> FBuffer.Width) or (h <> FBuffer.Height) then
  begin
    FBuffer.Free ;
    FBuffer := TGIS_Bitmap.Create(w, h) ;
    FBuffer.MakeTransparent ;
  end ;

  // Calculate the screen rectangle corresponding to the current map extent
  rct := Viewer.Ref.MapToScreenRect(_extent) ;

  // Update particle positions based on the wind grid data and the current view offset
  FEngine.UpdateWGSWithOffset(
    w, h,            // Full dimensions of the viewer window
    rct.Width,       // Map width in pixels
    rct.Height,      // Map height in pixels
    rct.Left,        // Left margin of the map in the window
    rct.Top,         // Top margin of the map in the window
    ANIMATION_SPEED, // SpeedScale (animation speed)
    _extent.XMin, _extent.XMax, _extent.YMin, _extent.YMax
  ) ;

  // Calculate fading/opacity effect dynamically based on the average wind speed
  avgSpeed := FEngine.GetAverageSpeed ;
  calcAlpha := FADING_EFFECT + (avgSpeed * SPEED_FACTOR) ;
  calcAlpha := EnsureRange(Round(calcAlpha), 8, 100) ;

  // Apply the calculated opacity to create a smooth, fading trail effect for particles
  FBuffer.ApplyOpacity(Round(calcAlpha)) ;

  ctx := TGIS_RendererContext.Create ;
  try
    // Create a local renderer instance to draw the updated particles onto the buffer
    rnd := rdr.CreateInstance ;
    try
      ctx.AssignBaseMap(FBuffer, False) ;
      rnd.CreateContext(Viewer.Ref.ViewerParent, Viewer.Ref, ctx, Point(0, 0), w, h, Viewer.Ref.PPI, 100) ;
      rnd.PrepareDraw ;

      // Draw the wind particles onto the temporary rendering context
      FEngine.DrawParticles(rnd) ;
    finally
      rnd.AfterDraw ;
      rnd.ReleaseContext ;
      rnd.Free ;
    end ;
  finally
    ctx.Free ;
  end ;

  // Render the final composition buffer directly onto the main GIS canvas
  rdr.CanvasDrawBitmap( FBuffer, Rect(0, 0, w, h) ) ;

  Result := True ;
end ;

end.
