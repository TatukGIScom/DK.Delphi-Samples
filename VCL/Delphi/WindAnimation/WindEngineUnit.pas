//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  WindEngineUnit — wind particle system engine for animated meteorological visualization (Delphi/VCL).

  What the unit provides:
    - TWindParticle record for individual animated wind particles
    - TWindEngine class managing 4000+ wind particles with physics simulation
    - Meteorological grid data loading (U/V wind components from JSON)
    - Particle initialization in WGS84 geographic coordinates
    - Real-time particle position updates via bilinear wind grid interpolation
    - Particle respawning at map edges and age limits
    - Speed-based color mapping (gradient and monochrome color schemes)
    - Trail effect opacity/fading calculations
    - Rendering to both VCL Canvas and abstract GIS renderers

  Key components:
    TWindParticle               - single particle (position, speed, color, age)
    TWindEngine                 - particle system simulator and renderer
    LatLonToScreen (local)       - geographic to screen coordinate transformation
    UpdateWGSWithOffset()       - main physics and animation update loop
    LoadDataFromJSON()          - parse meteorological wind data
    DrawParticles()             - render particles to output (overloaded)

  Data format: Wind data loaded from JSON containing nx, ny (grid dimensions),
  and flat arrays of U, V components representing wind velocity at each grid point.
}
unit WindEngineUnit ;

interface

uses
  Winapi.Windows, System.SysUtils, System.Types, System.Classes, System.JSON,
  System.Math, Vcl.Graphics,
  GisRendererAbstract ;

type
  /// <summary>
  ///   Represents a single wind particle used in the animation.
  /// </summary>
  TWindParticle = record
    /// <summary>Position in geographic coordinates (WGS84).</summary>
    Lat, Lon : Single ;
    /// <summary>Previous screen position in pixels.</summary>
    OldX, OldY : Single ;
    /// <summary>Current screen position in pixels.</summary>
    X, Y : Single ;
    /// <summary>Current speed of the particle.</summary>
    Speed : Single ;
    /// <summary>Current rendering color.</summary>
    Color : TColor ;
    /// <summary>Current age and maximum lifespan in frames.</summary>
    Age, MaxAge : Integer ;
  end ;

  /// <summary>
  ///   Engine responsible for generating, updating, and drawing wind particles
  ///   based on loaded meteorological data grids.
  /// </summary>
  TWindEngine = class
  private
    FParticles : array of TWindParticle ;
    /// <summary>Grid width (According to the file : nx = 360).</summary>
    FGridW : Integer ;
    /// <summary>Grid height (According to the file : ny = 181).</summary>
    FGridH : Integer ;
    /// <summary>2D dynamic arrays for decoded meteorological data (U and V vectors).</summary>
    FGridU : array of array of Single ;
    FGridV : array of array of Single ;

    FOneColor : Boolean ;
  private
    /// <summary>
    ///   Interpolates between two colors based on a factor [0..1].
    /// </summary>
    function MixColors(const Color1, Color2 : TColor ; const Factor : Single) : TColor ;
    /// <summary>
    ///   Converts wind speed to a multicolor gradient (Windy-like).
    /// </summary>
    function SpeedToColor(const Speed : Single) : TColor ;
    /// <summary>
    ///   Converts wind speed to a monochrome scale color.
    /// </summary>
    function SpeedToColorOne(const Speed : Single) : TColor ;
  public
    /// <summary>
    ///   Creates a new instance of the wind engine.
    /// </summary>
    /// <param name="ParticleCount">The number of particles to simulate.</param>
    constructor Create(const ParticleCount : Integer) ;
    destructor Destroy ; override ;

    /// <summary>
    ///   Loads meteorological wind data (U and V components) from a JSON string.
    /// </summary>
    /// <param name="JsonString">The JSON data string.</param>
    /// <returns>True if parsing was successful and grid dimensions are established.</returns>
    function LoadDataFromJSON(const JsonString : string) : Boolean ;

    /// <summary>Draws particles on a standard VCL Canvas.</summary>
    procedure DrawParticles(const Canvas : TCanvas) ; overload ;

    /// <summary>Draws particles using the abstract GIS renderer.</summary>
    procedure DrawParticles(const Canvas : TGIS_RendererAbstract) ; overload ;

    /// <summary>
    ///   Initializes particles using screen coordinates.
    /// </summary>
    procedure InitializeParticles(const ScreenWidth, ScreenHeight : Integer) ;

    /// <summary>
    ///   Calculates the average speed of all active particles.
    /// </summary>
    function GetAverageSpeed : Single ;

    /// <summary>
    ///   Initializes particles using WGS84 geographic coordinates.
    /// </summary>
    procedure InitializeParticlesWGS ;

    /// <summary>
    ///   Updates particle positions based on wind data and screen offset.
    /// </summary>
    /// <param name="FormWidth">Total width of the form.</param>
    /// <param name="FormHeight">Total height of the form.</param>
    /// <param name="MapWidth">Physical width of the map area.</param>
    /// <param name="MapHeight">Physical height of the map area.</param>
    /// <param name="MapLeft">Left margin (offset) of the map.</param>
    /// <param name="MapTop">Top margin (offset) of the map.</param>
    /// <param name="SpeedScale">Scale multiplier for particle speed.</param>
    /// <param name="ExtentMinLon">Current map extent minimum longitude.</param>
    /// <param name="ExtentMaxLon">Current map extent maximum longitude.</param>
    /// <param name="ExtentMinLat">Current map extent minimum latitude.</param>
    /// <param name="ExtentMaxLat">Current map extent maximum latitude.</param>
    procedure UpdateWGSWithOffset(
      const FormWidth, FormHeight : Integer ;
      const MapWidth, MapHeight : Integer ;
      const MapLeft, MapTop : Integer ;
      const SpeedScale : Single ;
      const ExtentMinLon, ExtentMaxLon, ExtentMinLat, ExtentMaxLat : Double
    ) ;
  public
    /// <summary>Determines if a single monochrome scale is used for particle colors.</summary>
    property OneColor : Boolean read FOneColor write FOneColor ;
  end ;

implementation

uses
  System.Generics.Collections,
  GisTypesUI ;

{ Constructor
  Initializes the wind engine with specified particle count.
  Sets up empty particle array and zero grid dimensions. }
constructor TWindEngine.Create(
  const ParticleCount : Integer
) ;
begin
  inherited Create ;
  SetLength(FParticles, ParticleCount) ;
  FGridW := 0 ;
  FGridH := 0 ;
  FOneColor := False ;
end ;

{ Destructor
  Frees all dynamically allocated wind grid data and particle arrays. }
destructor TWindEngine.Destroy ;
begin
  SetLength(FGridU, 0, 0) ;
  SetLength(FGridV, 0, 0) ;
  SetLength(FParticles, 0) ;
  inherited ;
end ;

{ InitializeParticlesWGS
  Randomly distributes particles across the world at WGS84 coordinates.
  Assigns random lifespans to create staggered respawning and smooth animation.

  Algorithm:
    1. Distribute particles longitude: -180 to +180 degrees.
    2. Distribute particles latitude: -85 to +85 degrees (Mercator limits).
    3. Assign random MaxAge (20-50 frames) and random current Age to stagger death. }
procedure TWindEngine.InitializeParticlesWGS ;
var
  i : Integer ;
begin
  for i := 0 to High(FParticles) do
  begin
    // Randomly distribute longitude and latitude across world bounds
    FParticles[i].Lon := -180.0 + Random(3600) / 10.0 ;
    FParticles[i].Lat := -85.0 + Random(1700) / 10.0 ;

    // Stagger lifespan so particles don't all respawn at the same time
    FParticles[i].MaxAge := 20 + Random(30) ;
    FParticles[i].Age := Random(FParticles[i].MaxAge) ;
  end ;
end ;

{ LatLonToScreen (local helper)
  Converts geographic WGS84 coordinates to screen pixels, accounting for the
  current map extent and viewport offset. Returns True if point is within visible map area.

  Algorithm:
    1. Linear map of longitude to X pixel coordinate (normalized to map width).
    2. Linear map of latitude to Y pixel coordinate (inverted for screen coords).
    3. Apply viewport offset (MapLeft, MapTop) to position in window.
    4. Return visibility test: True if pixel is within map bounds. }
function LatLonToScreen(
  const Lat, Lon : Double ;
  const MinWidthLon, MaxWidthLon, MinHeightLat, MaxHeightLat : Double ;
  const MapWidth, MapHeight : Integer ;
  const MapLeft, MapTop : Integer ;
  out x, y : Single
) : Boolean ;
begin
  // Map longitude to X pixel within map rectangle
  x := ((Lon - MinWidthLon) / (MaxWidthLon - MinWidthLon)) * MapWidth ;

  // Map latitude to Y pixel (inverted: MaxLat=0, MinLat=MapHeight)
  y := ((MaxHeightLat - Lat) / (MaxHeightLat - MinHeightLat)) * MapHeight ;

  // Apply viewport offset to convert from local map coords to screen coords
  x := x + MapLeft ;
  y := y + MapTop ;

  // Test if pixel is within map rectangle (with 10-pixel margin for smooth transitions)
  Result := (x >= MapLeft) and (x <= MapLeft + MapWidth) and (y >= MapTop) and (y <= MapTop + MapHeight) ;
end ;

{ UpdateWGSWithOffset
  Animates all wind particles for one frame. Interpolates wind vectors from grid
  data, moves particles according to wind direction/speed, handles respawning at
  map edges and age limits, and updates particle colors based on wind speed.

  Called each render frame to advance the animation. Requires meteorological grid
  data to be loaded via LoadDataFromJSON first.

  Algorithm:
    1. Exit if wind grid data not loaded.
    2. For each particle: age it, compute screen position from current geographic coords.
    3. Check death conditions (max age or out-of-bounds); respawn if needed.
    4. Interpolate wind U,V components from grid via bilinear interpolation.
    5. Compute wind speed and apply color gradient based on speed magnitude.
    6. Move particle in geographic space according to interpolated wind velocity. }
procedure TWindEngine.UpdateWGSWithOffset(
  const FormWidth, FormHeight : Integer ;
  const MapWidth, MapHeight : Integer ;
  const MapLeft, MapTop : Integer ;
  const SpeedScale : Single ;
  const ExtentMinLon, ExtentMaxLon, ExtentMinLat, ExtentMaxLat : Double
) ;
var
  i, x0, y0, x1, y1 : Integer ;
  xf, yf, u, v : Single ;
  normLon, normLat : Single ;
  deltaLon, deltaLat : Double ;
begin
  if (FGridW = 0) or (FGridH = 0) then
    Exit ;

  // Calculate current map extent size in degrees (used for zoom-aware scaling)
  deltaLon := ExtentMaxLon - ExtentMinLon ;
  deltaLat := ExtentMaxLat - ExtentMinLat ;

  // === PHASE 2: Process all particles ===
  for i := 0 to High(FParticles) do
  begin
    Inc(FParticles[i].Age) ;

    // === STEP 2.1: Project geographic position to screen pixels ===
    LatLonToScreen(
      FParticles[i].Lat, FParticles[i].Lon, ExtentMinLon,
      ExtentMaxLon, ExtentMinLat, ExtentMaxLat,
      MapWidth, MapHeight, MapLeft, MapTop,
      FParticles[i].X, FParticles[i].Y
    ) ;

    // === STEP 2.2: Save previous position for trail rendering ===
    FParticles[i].OldX := FParticles[i].X ;
    FParticles[i].OldY := FParticles[i].Y ;

    // === STEP 2.3: Check death conditions and respawn if needed ===
    // Particles die at max age or exit map bounds (with 10-pixel margin for smooth transitions)
    if (FParticles[i].Age > FParticles[i].MaxAge) or
       (FParticles[i].X < MapLeft - 10) or
       (FParticles[i].X > MapLeft + MapWidth + 10) or
       (FParticles[i].Y < MapTop - 10) or
       (FParticles[i].Y > MapTop + MapHeight + 10) then
    begin
      // Respawn the particle at a random point within the CURRENT geographic EXTENT
      FParticles[i].Lon := ExtentMinLon + (Random(1000) / 1000.0) * deltaLon ;
      FParticles[i].Lat := ExtentMinLat + (Random(1000) / 1000.0) * deltaLat ;
      FParticles[i].Age := 0 ;
      FParticles[i].MaxAge := 20 + Random(30) ;

      // Immediate position synchronization after respawn
      LatLonToScreen(
        FParticles[i].Lat, FParticles[i].Lon,
        ExtentMinLon, ExtentMaxLon, ExtentMinLat, ExtentMaxLat,
        MapWidth, MapHeight, MapLeft, MapTop,
        FParticles[i].X, FParticles[i].Y
      ) ;

      FParticles[i].OldX := FParticles[i].X ;
      FParticles[i].OldY := FParticles[i].Y ;
      Continue ;
    end ;

    // === STEP 2.4: Interpolate wind vectors from meteorological grid ===
    // Maps particle position to grid coordinates and performs bilinear interpolation.
    normLon := FParticles[i].Lon ;

    // === STEP 2.4a: Normalize longitude to 0..360 range ===
    while normLon < 0 do
      normLon := normLon + 360.0 ;
    while normLon >= 360.0 do
      normLon := normLon - 360.0 ;

    // Convert Lat coordinate to grid row index (from North Pole 90� downwards)
    normLat := 90.0 - FParticles[i].Lat ;

    // Calculate grid indices and interpolation factors
    x0 := Floor(normLon) ;
    y0 := Floor(normLat) ;
    x0 := EnsureRange(x0, 0, FGridW - 2) ;
    y0 := EnsureRange(y0, 0, FGridH - 2) ;
    x1 := x0 + 1 ;
    y1 := y0 + 1 ;
    xf := normLon - x0 ;
    yf := normLat - y0 ;

    // Retrieve interpolated wind velocity vectors U and V (Bilinear Interpolation)
    u := (1 - xf) * (1 - yf) * FGridU[x0, y0] +
         xf * (1 - yf) * FGridU[x1, y0] +
         (1 - xf) * yf * FGridU[x0, y1] +
         xf * yf * FGridU[x1, y1] ;

    v := (1 - xf) * (1 - yf) * FGridV[x0, y0] +
         xf * (1 - yf) * FGridV[x1, y0] +
         (1 - xf) * yf * FGridV[x0, y1] +
         xf * yf * FGridV[x1, y1] ;

    // Compute magnitude (speed) of the wind
    FParticles[i].Speed := Sqrt(u * u + v * v) ;

    // Update color based on speed
    if FOneColor then
      FParticles[i].Color := SpeedToColorOne(FParticles[i].Speed)
    else
      FParticles[i].Color := SpeedToColor(FParticles[i].Speed) ;

    // STEP 4 : Move particle in the geographic coordinate system
    // The multiplier (* deltaLon / deltaLat) scales the wind step to visually fit the current zoom level
    FParticles[i].Lon := FParticles[i].Lon + (u * SpeedScale * 0.0005) * deltaLon ;
    FParticles[i].Lat := FParticles[i].Lat + (v * SpeedScale * 0.0005) * deltaLat ;

    // STEP 5 : Calculate the new screen position after movement
    LatLonToScreen(
      FParticles[i].Lat, FParticles[i].Lon,
      ExtentMinLon, ExtentMaxLon, ExtentMinLat, ExtentMaxLat,
      MapWidth, MapHeight, MapLeft, MapTop,
      FParticles[i].X, FParticles[i].Y
    ) ;
  end ;
end ;

function TWindEngine.LoadDataFromJSON(
  const JsonString : string
) : Boolean ;
var
  jsonArray : TJSONArray ;
  jsonObj : TJSONObject ;
  headerObj : TJSONObject ;
  dataArray : TJSONArray ;
  i, x, y, flatIndex : Integer ;
  paramName : string ;
begin
  Result := False ;
  try
    jsonArray := TJSONObject.ParseJSONValue(JsonString) as TJSONArray ;
    if not Assigned(jsonArray) then
      Exit ;

    try
      // Loop through the two main objects in the array (one for U, one for V components)
      for i := 0 to jsonArray.Count - 1 do
      begin
        jsonObj := jsonArray.Items[i] as TJSONObject ;
        headerObj := jsonObj.GetValue('header') as TJSONObject ;
        dataArray := jsonObj.GetValue('data') as TJSONArray ;

        // E.g., 'U-component_of_wind' or 'V-component_of_wind'
        paramName := headerObj.GetValue('parameterNumberName').Value ;

        // Get grid dimensions on the first pass
        if FGridW = 0 then
        begin
          FGridW := StrToInt(headerObj.GetValue('nx').Value) ; // e.g., 360
          FGridH := StrToInt(headerObj.GetValue('ny').Value) ; // e.g., 181
          SetLength(FGridU, FGridW, FGridH) ;
          SetLength(FGridV, FGridW, FGridH) ;
        end ;

        // Map the flattened 1D array from JSON to our 2D structure (X, Y)
        for y := 0 to FGridH - 1 do
        begin
          for x := 0 to FGridW - 1 do
          begin
            flatIndex := (y * FGridW) + x ;
            if flatIndex < dataArray.Count then
            begin
              if paramName = 'U-component_of_wind' then
                FGridU[x, y] := (dataArray.Items[flatIndex]).GetValue<Double>
              else if paramName = 'V-component_of_wind' then
                FGridV[x, y] := (dataArray.Items[flatIndex]).GetValue<Double> ;
            end ;
          end ;
        end ;
      end ;
      Result := (FGridW > 0) and (FGridH > 0) ;
    finally
      jsonArray.Free ;
    end ;
  except
    Result := False ;
  end ;
end ;

procedure TWindEngine.InitializeParticles(
  const ScreenWidth, ScreenHeight : Integer
) ;
var
  i : Integer ;
begin
  for i := 0 to High(FParticles) do
  begin
    FParticles[i].X := Random(ScreenWidth) ;
    FParticles[i].Y := Random(ScreenHeight) ;
    FParticles[i].OldX := FParticles[i].X ;
    FParticles[i].OldY := FParticles[i].Y ;
    FParticles[i].MaxAge := 20 + Random(30) ;
    FParticles[i].Age := Random(FParticles[i].MaxAge) ;
    FParticles[i].Speed := 0 ;
    FParticles[i].Color := clWhite ;
  end ;
end ;

function TWindEngine.MixColors(
  const Color1, Color2 : TColor ;
  const Factor : Single
) : TColor ;
var
  r1, g1, b1, r2, g2, b2 : Byte ;
begin
  // Extract RGB components
  r1 := GetRValue(Color1) ;
  g1 := GetGValue(Color1) ;
  b1 := GetBValue(Color1) ;
  r2 := GetRValue(Color2) ;
  g2 := GetGValue(Color2) ;
  b2 := GetBValue(Color2) ;

  // Interpolate and return the mixed color
  Result := RGB(
    Round(r1 + (r2 - r1) * Factor),
    Round(g1 + (g2 - g1) * Factor),
    Round(b1 + (b2 - b1) * Factor)
  ) ;
end ;

function TWindEngine.SpeedToColor(
  const Speed : Single
) : TColor ;
begin
  // Smooth Windy-like palette (Gradient) based on m/s
  // Speed scale ranges from 0 m/s up to 15+ m/s

  if Speed <= 2.0 then
    // Dark Blue -> Light Blue
    Result := MixColors(RGB(30, 50, 90), RGB(30, 144, 255), Speed / 2.0)
  else if Speed <= 5.0 then
    // Light Blue -> Green
    Result := MixColors(RGB(30, 144, 255), RGB(0, 250, 154), (Speed - 2.0) / 3.0)
  else if Speed <= 8.0 then
    // Green -> Yellow
    Result := MixColors(RGB(0, 250, 154), RGB(255, 255, 0), (Speed - 5.0) / 3.0)
  else if Speed <= 12.0 then
    // Yellow -> Orange
    Result := MixColors(RGB(255, 255, 0), RGB(255, 140, 0), (Speed - 8.0) / 4.0)
  else
    // Orange -> Red (Caps factor at 1.0)
    Result := MixColors(RGB(255, 140, 0), RGB(220, 20, 60), Min((Speed - 12.0) / 5.0, 1.0)) ;
end ;

function TWindEngine.SpeedToColorOne(
  const Speed : Single
) : TColor ;
var
  factor : Single ;
  baseColor, maxColor : TColor ;
begin
  // Cap the speed calculation factor to 1.0 at 15 m/s
  factor := Min(Speed / 15.0, 1.0) ;
  baseColor := RGB(40, 45, 55) ;   // Dark Gray
  maxColor := RGB(255, 255, 255) ; // Pure White
  Result := MixColors(baseColor, maxColor, factor) ;
end ;

procedure TWindEngine.DrawParticles(
  const Canvas : TCanvas
) ;
var
  i : Integer ;
begin
  for i := 0 to High(FParticles) do
  begin
    Canvas.Pen.Color := FParticles[i].Color ;
    Canvas.Pen.Width := 1 ;
    // Draw a trail from the old position to the new one
    Canvas.MoveTo( Round(FParticles[i].OldX), Round(FParticles[i].OldY) ) ;
    Canvas.LineTo( Round(FParticles[i].X), Round(FParticles[i].Y) ) ;
  end ;
end ;

procedure TWindEngine.DrawParticles(
  const Canvas : TGIS_RendererAbstract
) ;
var
  i : Integer ;
  cl : TGIS_Color ;
begin
  for i := 0 to High(FParticles) do
  begin
    cl := TGIS_Color.FromBGR(Cardinal(FParticles[i].Color)) ;
    Canvas.CanvasPen.Color := TGIS_Color.FromARGB(255, cl.R, cl.G, cl.B) ;
    Canvas.CanvasPen.Width := 1 ;
    // Draw a trail via the GIS specific rendering canvas
    Canvas.CanvasDrawLine( Round(FParticles[i].OldX), Round(FParticles[i].OldY),
                           Round(FParticles[i].X), Round(FParticles[i].Y)
                         ) ;
  end ;
end ;

function TWindEngine.GetAverageSpeed : Single ;
var
  i : Integer ;
  totalSpeed : Single ;
begin
  if Length(FParticles) = 0 then
    Exit(0) ;

  totalSpeed := 0 ;
  for i := 0 to High(FParticles) do
    totalSpeed := totalSpeed + FParticles[i].Speed ;

  Result := totalSpeed / Length(FParticles) ;
end ;

end.
