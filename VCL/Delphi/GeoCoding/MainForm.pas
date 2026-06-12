//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  GeoCoding Sample - Delphi VCL
  ==============================
  Demonstrates address geocoding and shortest-path routing using TatukGIS DK11.

  Geocoding translates a human-readable address string (e.g. "Chrysler 1345")
  into geographic coordinates by matching it against street-range fields stored
  in a vector layer.  The TGIS_Geocoding class performs this matching entirely
  on the client side using a loaded shapefile — no external service is required
  unless OSM online routing is enabled.

  Routing then finds the shortest path between two geocoded points using
  TGIS_ShortestPath, which builds an in-memory graph from the road network and
  applies Dijkstra's algorithm.  The resulting path segments are visualised by
  adding them to a separate in-memory "RouteDisplay" layer rendered in red.

  Key concepts shown:
    - Loading a TatukGIS project file (.ttkproject) containing a roads layer
    - Constructing TGIS_Geocoding with address-range field mappings
      (FULLNAME, LFROMADD/LTOADD for left side, RFROMADD/RTOADD for right side)
    - Using TGIS_Geocoding.Parse to resolve a typed address to coordinates
    - Building a TGIS_ShortestPath graph with per-link-type cost modifiers
    - Handling the LinkTypeEvent callback to classify road segments
    - Drawing route results into an in-memory TGIS_LayerVector
    - Optionally switching to OSM online geocoding/routing via chkbxOnline

  Data used:
    California.ttkproject — a TatukGIS project referencing US Census TIGER/Line
    street data for California.  Field layout:
      FULLNAME   — full street name
      LFROMADD   — address range start, left side of street
      LTOADD     — address range end, left side of street
      RFROMADD   — address range start, right side of street
      RTOADD     — address range end, right side of street
      MTFCC      — MAF/TIGER Feature Class Code; "S1400" = local/residential road
}

unit MainForm;

interface

uses
  System.Classes,
  System.SysUtils,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,

  //GisLicense,       // Uncomment and configure if using a licensed build
  GisTypes,           // Core TatukGIS types (TGIS_Point, extents, shape types, …)
  GisCsBase,          // Coordinate-system base classes
  GisEditor,          // Layer editing support
  GisGeocoding,       // TGIS_Geocoding — address-to-coordinate resolution
  GisLayerVector,     // TGIS_LayerVector — in-memory and file-backed vector layers
  GisLayerSHP,        // Shapefile driver (registers .shp support)
  GisLayerADF,        // ArcInfo Binary Grid driver (used by some project files)
  GisParams,          // Rendering parameter classes (colour, width, markers, …)
  GisShortestPath,    // TGIS_ShortestPath — Dijkstra graph-based routing engine
  GisTopology,        // Topology utilities used internally by the routing engine
  GisTypesUI,         // TGIS_ViewerMode, TGIS_Color, and other UI-facing types
  GisUtils,           // GisSamplesDataDirDownload, CSUnitsList, and helpers
  GisViewer,          // Base viewer class

  Vcl.GisControlScale, // Scale-bar overlay control
  Vcl.GisViewerWnd ;   // VCL windowed map viewer component

type
  /// <summary>
  ///   Main application form for the GeoCoding sample.
  ///   Hosts a TGIS_ViewerWnd showing California street data and provides
  ///   address resolution (geocoding) and route finding (shortest path).
  /// </summary>
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;                 // Map viewer — renders street data and the route
    GIS_ControlScale1: TGIS_ControlScale; // Scale-bar overlay linked to the viewer
    Panel2: TPanel;                       // Right-hand panel hosting the controls
    memRoute: TMemo;                      // Read-only text area showing turn-by-turn directions
    GroupBox1: TGroupBox;                 // Groups the routing parameter controls
    trkSmallRoads: TTrackBar;            // Cost modifier slider: preference for local roads (1–10)
    trkHighways: TTrackBar;              // Cost modifier slider: preference for highways (1–10)
    lblSmallRoads: TLabel;               // Label for trkSmallRoads
    lblHighways: TLabel;                 // Label for trkHighways
    edtAddrFrom: TEdit;                  // Start address text box (e.g. "Chrys 1345")
    btnResolve: TButton;                 // Resolve and highlight the start address on the map
    edtAddrTo: TEdit;                    // End address text box (e.g. "wash")
    btnRoute: TButton;                   // Geocode both addresses and find the shortest route
    lblAddrFrom: TLabel;                 // Label for edtAddrFrom
    lblAddrTo: TLabel;                   // Label for edtAddrTo
    chkbxOnline: TCheckBox;             // Toggle between local-data and OSM online geocoding/routing

    procedure FormCreate(Sender: TObject);
    procedure btnResolveClick(Sender: TObject);
    procedure btnRouteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkbxOnlineClick(Sender: TObject);
  private
    layerSrc   : TGIS_LayerVector ;  // Source streets layer loaded from the project file
    layerRoute : TGIS_LayerVector ;  // In-memory layer used to display the computed route
    rtrObj     : TGIS_ShortestPath ; // Routing engine; builds graph from layerSrc
    geoObj     : TGIS_Geocoding ;    // Geocoding engine; resolves address text to coordinates
    costFactor : Double ;            // Reserved cost scaling factor (currently fixed at 1)

    /// <summary>
    ///   Callback invoked by TGIS_ShortestPath for each road segment to classify
    ///   its link type.  Link type 0 = highway; link type 1 = local road.
    ///   The router uses these types together with CostModifiers to weigh edges.
    /// </summary>
    /// <param name="_shape">
    ///   The arc shape (road segment) being classified.
    /// </param>
    /// <param name="_type">
    ///   Out parameter: set to 1 for local roads (MTFCC >= "S1400"), 0 for
    ///   highways and major roads.
    /// </param>
    procedure doLinkType(     _sender   : TObject ;
                              _shape    : TGIS_ShapeArc ;
                          var _type     : Integer
                        ) ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


/// <summary>
///   Classifies a road segment as highway (0) or local road (1).
///
///   The US Census MTFCC code "S1400" and higher identify local residential
///   streets, service roads, and alleys.  Codes below "S1400" are major roads
///   (interstates, US routes, state routes, etc.).
///
///   The cost modifiers applied via CostModifiers[0] and CostModifiers[1]
///   scale the traversal cost for each link type.  A lower cost makes the
///   router prefer that type; sliders let the user tune this at runtime.
/// </summary>
procedure TForm1.doLinkType(    _sender   : TObject ;
                                 _shape    : TGIS_ShapeArc ;
                             var _type     : Integer
                           ) ;
begin
  if _shape.GetField( 'MTFCC' ) >= 'S1400' then
    // MTFCC >= S1400 → local/residential road (link type 1)
    _type := 1
  else
    // MTFCC < S1400 → highway or major road (link type 0)
    _type := 0 ;
end ;

/// <summary>
///   Called when the form is created.
///   Opens the California street project, builds the geocoding and routing
///   objects, and sets up the route-display layer.
/// </summary>
/// <remarks>
///   The viewer is locked during setup to suppress intermediate redraws.
///   GIS.Lock / GIS.Unlock are the standard DK pattern for batch updates.
/// </remarks>
procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock ;

  // Open the TatukGIS project file which references the California street data.
  // The project loads the "streets" layer automatically.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\Projects\California.ttkproject' ) ;

  // Retrieve the streets layer by name so we can pass it to the geocoding
  // and routing engines.  Cast is safe because the project was built with
  // a vector layer at that name.
  layerSrc := TGIS_LayerVector( GIS.Get( 'streets' ) ) ;

  if not Assigned( layerSrc ) then exit ;
  if not ( layerSrc is TGIS_LayerVector ) then exit ;

  // Zoom to the full extent of the street network on startup.
  GIS.VisibleExtent := layerSrc.ProjectedExtent ;

  // ------------------------------------------------------------------
  // Create an in-memory vector layer to display the computed route.
  // UseConfig = False prevents the DK from writing a style config file.
  // The line is rendered in red with a 2-pixel width.
  // Markers (for start/end points) will use a 1-pixel outline.
  // ------------------------------------------------------------------
  layerRoute := TGIS_LayerVector.Create ;
  layerRoute.UseConfig := False ;
  layerRoute.Params.Line.Color := TGIS_Color.Red ;
  layerRoute.Params.Line.Width := -2 ;             // Negative = device pixels (DPI-independent)
  layerRoute.Params.Marker.OutlineWidth := 1 ;
  layerRoute.Name := 'RouteDisplay' ;
  layerRoute.CS := GIS.CS ;                        // Must share the viewer's coordinate system
  GIS.Add( layerRoute ) ;

  // ------------------------------------------------------------------
  // Configure the geocoding engine.
  //   Offset    — how far along the road segment to place the geocoded
  //               point (in layer units), avoiding placing it on the
  //               exact road node.
  //   RoadName  — attribute field containing the full street name.
  //   LFrom/LTo — address number range for the left side of the street.
  //   RFrom/RTo — address number range for the right side of the street.
  //               US Census TIGER/Line uses these four fields to
  //               interpolate the house position along the segment.
  // ------------------------------------------------------------------
  geoObj := TGIS_Geocoding.Create( layerSrc ) ;
  geoObj.offset    := 0.0001 ;
  geoObj.RoadName  := 'FULLNAME' ;
  geoObj.LFrom     := 'LFROMADD' ;
  geoObj.LTo       := 'LTOADD' ;
  geoObj.RFrom     := 'RFROMADD' ;
  geoObj.RTo       := 'RTOADD' ;

  costFactor := 1 ;   // Placeholder for future cost scaling

  // ------------------------------------------------------------------
  // Configure the routing engine.
  //   LoadTheData builds the in-memory graph from all arc shapes in
  //   layerSrc.  LinkTypeEvent is called for each segment to assign a
  //   link type, enabling per-type cost modifiers.
  //   RoadName is used to label each route step in the directions panel.
  // ------------------------------------------------------------------
  rtrObj := TGIS_ShortestPath.Create( GIS ) ;
  rtrObj.LinkTypeEvent := doLinkType ;
  rtrObj.LoadTheData( layerSrc ) ;
  rtrObj.RoadName := 'FULLNAME' ;

  GIS.Unlock ;

  // Display the scale bar in miles (EPSG 9035).
  GIS_ControlScale1.Units := CSUnitsList.ByEPSG( 9035 ) ;
end ;

/// <summary>
///   Resolves the address typed in edtAddrFrom against the streets layer
///   and highlights all matching segments on the map.
///
///   If one or more matches are found, the matching street shapes are copied
///   to layerRoute (shown in red) and a green marker is placed at the exact
///   geocoded point for each result.  The view zooms to the result set.
///
///   If no matches are found, " ???" is appended to the text box to indicate
///   the address could not be resolved.
/// </summary>
procedure TForm1.btnResolveClick(Sender: TObject);
var
  i   : Integer ;
  r   : Integer ;
  shp : TGIS_Shape ;
begin
  if not Assigned( geoObj ) then exit ;

  // Clear any previously displayed route or address result.
  layerRoute.RevertShapes ;

  // Parse the address string.  Returns the number of matching candidates.
  // Subtracting 1 gives the last valid index for the result arrays.
  r := geoObj.Parse( edtAddrFrom.Text ) - 1 ;
  if r <= 0 then edtAddrFrom.Text := edtAddrFrom.Text + ' ???' ;

  for i := 0 to r do
  begin
    // Show the canonical name of each matching street in the text box.
    edtAddrFrom.Text := geoObj.Query[i] ;
    Application.ProcessMessages ; // Allow the UI to refresh between results

    // Add the primary matching street segment to the route display layer.
    // GetShape retrieves the shape by its unique ID from the source layer.
    shp := layerSrc.GetShape( geoObj.Uid[i] ) ;
    layerRoute.AddShape( shp ) ;

    // Initialise the display extent from the first matched segment.
    if i = 0 then layerRoute.Extent := shp.ProjectedExtent ;

    // Add the secondary (adjacent) segment if available.
    // UidEx returns the ID of the complementary segment for the same address
    // range (e.g. the opposite side of the street).
    shp := layerSrc.GetShape( geoObj.UidEx[i] ) ;
    if Assigned( shp ) then
      layerRoute.AddShape( shp ) ;

    // Place a green point marker at the exact geocoded coordinate.
    // Lock/Unlock brackets shape modification to keep internal extent correct.
    shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;
    // FromCS converts the point from the source layer's CS to the route layer's CS.
    shp.AddPoint( layerRoute.CS.FromCS( layerSrc.CS, geoObj.Point[i] ) ) ;
    shp.Params.Marker.Color := TGIS_Color.Green ;
    shp.Unlock ;
  end ;

  // Zoom to the matched result with a slight zoom-out factor (0.7×) so the
  // surrounding context is also visible.
  GIS.Lock ;
  GIS.VisibleExtent := layerRoute.ProjectedExtent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;
end ;

/// <summary>
///   Geocodes both the From and To addresses, then computes and displays the
///   shortest route between them.
///
///   The turn-by-turn directions are written to memRoute as compass direction
///   abbreviations (FWD, LEFT, RIGHT, BACK) followed by the street name.
///   Route segments are added to layerRoute (red lines) and the start and
///   end points are marked with green and red markers respectively.
/// </summary>
/// <remarks>
///   Cost modifiers are re-applied before each routing call so the user can
///   adjust the highway/local-road preference without reloading data.
///
///   The Compass property of each route item encodes the turn direction as an
///   integer: 0 = straight, 1..3 = right turns (45°, 90°, 135°),
///   4 = U-turn, -1..-3 = left turns, -4 = left U-turn.
/// </remarks>
procedure TForm1.btnRouteClick(Sender: TObject);
var
  i      : Integer ;
  shp    : TGIS_Shape ;
  res    : Integer ;
  pt_a   : TGIS_Point ;
  pt_b   : TGIS_Point ;
  ang    : String ;
  oldnam : String ;
begin
  // Apply slider-derived cost modifiers.
  // CostModifiers[0] scales highway cost; CostModifiers[1] scales local-road cost.
  // Formula maps slider value 1..10 to modifier 1.0..~0.09 (lower = cheaper = preferred).
  rtrObj.CostModifiers[0] := 1 - 1/11 * trkHighways.Position ;
  rtrObj.CostModifiers[1] := 1 - 1/11 * trkSmallRoads.Position ;

  // Geocode the start address.  Parse returns the number of candidates found.
  // If any candidates are found (res > 0), refine the text box to the best match.
  res := geoObj.Parse( edtAddrFrom.Text ) ;
  if res > 0 then edtAddrFrom.Text := geoObj.Query[0]
             else edtAddrFrom.Text := edtAddrFrom.Text + ' ???' ;

  // Abort if the start address could not be resolved.
  if res <= 0 then exit ;
  pt_a := geoObj.Point[0] ;  // Geocoded start coordinate

  // Geocode the end address using the same approach.
  res := geoObj.Parse( edtAddrTo.Text ) ;
  if res > 0 then edtAddrTo.Text := geoObj.Query[0]
             else edtAddrTo.Text := edtAddrTo.Text + ' ???' ;

  // Abort if the end address could not be resolved.
  if res <= 0 then exit ;
  pt_b := geoObj.Point[0] ;  // Geocoded end coordinate

  // UpdateTheData refreshes the routing graph (e.g. after the layer was edited).
  // Find computes the shortest path between the two projected points.
  // Unproject converts from the viewer's display CS back to layer coordinates.
  rtrObj.UpdateTheData ;
  rtrObj.Find( layerRoute.Unproject( pt_a ),
               layerRoute.Unproject( pt_b ) ) ;

  // Build the turn-by-turn directions text.
  // BeginUpdate/EndUpdate prevents excessive redraws while populating the memo.
  memRoute.Lines.BeginUpdate ;
  memRoute.Clear ;
  oldnam := '#$@3eqewe' ;  // Sentinel to detect the first segment

  for i := 0 to rtrObj.ItemsCount - 1 do
  begin
    // Map the numeric Compass value to a human-readable direction string.
    case rtrObj.Items[i].Compass of
      0  : ang := 'FWD  ' ;
      1  : ang := 'RIGHT' ;  // Slight right
      2  : ang := 'RIGHT' ;  // Right
      3  : ang := 'RIGHT' ;  // Sharp right
      4  : ang := 'BACK ' ;  // U-turn
      -1 : ang := 'LEFT ' ;  // Slight left
      -2 : ang := 'LEFT ' ;  // Left
      -3 : ang := 'LEFT ' ;  // Sharp left
      -4 : ang := 'BACK ' ;  // Left U-turn
    end ;

    // Suppress consecutive items on the same named street to avoid clutter.
    if oldnam = rtrObj.Items[i].Name then continue ;
    oldnam := rtrObj.Items[i].Name ;

    memRoute.Lines.Add( Format( '%s %s', [ ang, rtrObj.Items[i].Name ] ) ) ;
  end ;
  memRoute.Lines.EndUpdate ;

  // Clear the route display layer and repopulate with the new path segments.
  layerRoute.RevertShapes ;

  // Copy each route segment shape from the source layer into the display layer.
  for i := 0 to rtrObj.ItemsCount - 1 do
  begin
    shp := rtrObj.Items[i].Layer.GetShape( rtrObj.Items[i].Uid ) ;
    if not Assigned( shp ) then continue ;
    layerRoute.AddShape( shp ) ;
    if i = 0 then
      layerRoute.Extent := shp.Extent ;  // Seed the bounding extent from the first shape
  end ;

  // Place a green point marker at the start (pt_a).
  shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( pt_a ) ;
  shp.Params.Marker.Color := TGIS_Color.Green ;
  shp.Unlock ;

  // Place a red (default) point marker at the end (pt_b).
  shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( pt_b ) ;
  shp.Unlock ;

  // Zoom to the route bounding box, pulling back slightly for context.
  GIS.Lock ;
  GIS.VisibleExtent := layerRoute.Extent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;
end ;

/// <summary>
///   Toggles between local-data geocoding/routing and OSM online services.
///
///   When OSMGeocoding is true, TGIS_Geocoding queries the OpenStreetMap
///   Nominatim service instead of the local layer data.  When OSMRouting is
///   true, TGIS_ShortestPath uses the OSRM routing service.
///   Both services require an internet connection.
/// </summary>
procedure TForm1.chkbxOnlineClick(Sender: TObject);
begin
  if chkbxOnline.Checked then begin
    geoObj.OSMGeocoding := True ;
    rtrObj.OSMRouting   := True ;
  end
  else begin
    geoObj.OSMGeocoding := False ;
    rtrObj.OSMRouting   := False ;
  end ;
end ;

/// <summary>
///   Frees the geocoding and routing objects when the form is destroyed.
///   layerRoute is owned by the viewer and is freed automatically.
/// </summary>
procedure TForm1.FormDestroy(Sender: TObject);
begin
  geoObj.Free ;
  rtrObj.Free ;
end ;

end.
