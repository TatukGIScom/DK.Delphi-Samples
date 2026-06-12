//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Hydrology sample.

  A step-by-step tutorial that performs common hydrological analyses on a
  DEM (Digital Elevation Model) raster grid using TGIS_Hydrology.
  Each button in the UI unlocks the next step in the pipeline:

    1. Identify DEM problems (Sink)     — detects sinks (pits) and flat areas.
    2. Fill sinks                       — raises depressions to produce a
                                          hydrologically conditioned DEM.
    3. Flow Direction                   — encodes the steepest-descent direction
                                          for each cell (D8 method, 1..128).
    4. Flow Accumulation                — counts upstream cells draining into
                                          each cell; reveals the stream network.
    5. Add outlets (pour points)        — places two sample outlet points on
                                          high-accumulation cells.
    6. Watershed                        — delineates the drainage area upstream
                                          of each outlet.
    7. Basin                            — partitions the DEM into independent
                                          drainage basins.
    8. Stream Order (Strahler)          — assigns a Strahler order to each
                                          stream segment.
    9. Convert to vector                — converts the raster basin and stream
                                          grids to polygon/polyline layers.
   10. View in 3D                       — drapes the stream network over the
                                          conditioned DEM in 3-D.

  Data: Bytowski County DEM, Poland (GeoTIFF).
}
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  VCL.GisControlLegend, Vcl.StdCtrls, VCL.GisViewerWnd,
  GisClassification,
  GisCsSystems,
  GisHydrology,
  GisLayerPixel,
  GisLayerVector,
  GisTypes,
  GisFunctions,
  GisClasses,
  GisTypesUI,
  GisUtils,
  GisVectorization;

type
  TfrmHydrology = class(TForm)
    GIS: TGIS_ViewerWnd;
    pnlButtons: TPanel;
    btnStreamOrderStrahler: TButton;
    btnSink: TButton;
    btnFillSinks: TButton;
    btnFlowDirection: TButton;
    btnVectorize: TButton;
    btnFlowAccumulation: TButton;
    btnWatershed: TButton;
    btnBasin: TButton;
    GIS_Legend: TGIS_ControlLegend;
    prgBusy: TProgressBar;
    btnAddOutlets: TButton;
    lblInfo: TLabel;
    btn3D: TButton;
    procedure btnSinkClick(Sender: TObject);
    procedure btnFlowDirectionClick(Sender: TObject);
    procedure btnFlowAccumulationClick(Sender: TObject);
    procedure btnStreamOrderStrahlerClick(Sender: TObject);
    procedure btnWatershedClick(Sender: TObject);
    procedure btnBasinClick(Sender: TObject);
    procedure btnVectorizeClick(Sender: TObject);
    procedure btnFillSinksClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure btnAddOutletsClick(Sender: TObject);
    procedure btn3DClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    dem              : TGIS_LayerPixel ;
    ext              : TGIS_Extent ;
    hydrologyToolset : TGIS_Hydrology ;

    procedure doBusyEvent(     _sender : TObject ;
                               _pos    : Integer ;
                               _end    : Integer ;
                           var _abort  : Boolean
                         ) ;
  public
    { Public declarations }
    function CreateLayerPix( const _dem  : TGIS_LayerPixel ;
                             const _name : String
                           ) : TGIS_LayerPixel ;

    function CreateLayerVec( const _name : String ;
                             const _cs   : TGIS_CSCoordinateSystem ;
                             const _type : TGIS_ShapeType
                           ) : TGIS_LayerVector ;

    function GetLayerGrd   ( const _name : String ) : TGIS_LayerPixel ;
    function GetLayerVec   ( const _name : String ) : TGIS_LayerVector ;
  end;

var
  frmHydrology: TfrmHydrology;

implementation

{$R *.dfm}

const
  HYDRO_LAYER_SINK         = 'Sinks and flats' ;
  HYDRO_LAYER_DEM          = 'Hydrologically conditioned DEM' ;
  HYDRO_LAYER_DIRECTION    = 'Flow direction' ;
  HYDRO_LAYER_ACCUMULATION = 'Flow accumulation' ;
  HYDRO_LAYER_STREAM_ORDER = 'Stream order (Strahler)' ;
  HYDRO_LAYER_OUTLETS      = 'Outlets (pour points)' ;
  HYDRO_LAYER_WATERSHED    = 'Watersheds' ;
  HYDRO_LAYER_BASIN        = 'Basins' ;
  HYDRO_LAYER_STREAM_VEC   = 'Streams (vectorized)' ;
  HYDRO_LAYER_BASIN_VEC    = 'Basins (vectorized)' ;
  HYDRO_FIELD_ORDER        = 'ORDER' ;
  HYDRO_FIELD_BASIN        = 'BASIN_ID' ;

  {
    Progress callback for TGIS_Hydrology and TGIS_GridToPolygon operations.
    _pos = 0   : initialises the progress bar range (0..100).
    _pos = -1  : resets the bar to 0 after the operation completes.
    _pos > 0   : advances the bar to the current percentage value.
    Calls Application.ProcessMessages so the UI remains responsive.
  }
  procedure TfrmHydrology.doBusyEvent(
        _sender : TObject ;
        _pos    : Integer ;
        _end    : Integer ;
  var   _abort  : Boolean
) ;
begin
  case _pos of
    // initialize progress bar
    0  : begin
      prgBusy.Min := 0 ;
      prgBusy.Max := 100 ;
      prgBusy.Position := 0 ;
    end ;
    // end of prgBusy - reset prgBusy bar
    -1 : prgBusy.Position := 0 ;
  else
    prgBusy.Position := _pos ;
  end ;

  Application.ProcessMessages ;
end;

{
  Creates an in-memory TGIS_LayerPixel grid whose extent, coordinate system,
  and cell dimensions match those of the reference DEM layer.
  Anti-aliasing and hillshading are disabled so the raw cell values remain visible.
  Returns the new, unnamed (until the caller sets .Name) layer.
}
// Creates a new grid layer with the same parameters as input DEM and a given name
function TfrmHydrology.CreateLayerPix(
  const _dem  : TGIS_LayerPixel ;
  const _name : String
) : TGIS_LayerPixel ;
begin
  Result := TGIS_LayerPixel.Create ;
  Result.Build( True, _dem.CS, _dem.Extent, _dem.BitWidth, _dem.BitHeight ) ;
  Result.Name := _name;
  Result.Params.Pixel.Antialias := False ;
  Result.Params.Pixel.GridShadow := False ;
end;

{
  Creates an empty in-memory TGIS_LayerVector with the given name, coordinate
  system, and default shape type.  Opens the layer so shapes can be added immediately.
}
// Creates a new vector layer wita a given name, cs and type
function TfrmHydrology.CreateLayerVec(
  const _name : String ;
  const _cs   : TGIS_CSCoordinateSystem ;
  const _type : TGIS_ShapeType
) : TGIS_LayerVector ;
begin
  Result := TGIS_LayerVector.Create ;
  Result.Name := _name;
  Result.Open ;
  Result.CS := _cs ;
  Result.DefaultShapeType := _type;
end;

{ Retrieves a TGIS_LayerPixel from the viewer by name. }
// Gets a pixel layer with a given name from GIS
function TfrmHydrology.GetLayerGrd(
  const _name : String
) : TGIS_LayerPixel ;
begin
  Result := GIS.Get( _name ) as TGIS_LayerPixel ;
end;

{ Retrieves a TGIS_LayerVector from the viewer by name. }
// Gets a vector layer with a given name from GIS
function TfrmHydrology.GetLayerVec(
  const _name : String
) : TGIS_LayerVector ;
begin
  Result := GIS.Get( _name ) as TGIS_LayerVector ;
end;

{ Frees the TGIS_Hydrology toolset when the form closes. }
procedure TfrmHydrology.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  hydrologyToolset.Free ;
end;

{
  Loads the DEM raster (Bytowski County GeoTIFF) into the viewer,
  stores a reference to the base DEM layer and its spatial extent for
  subsequent hydrology operations, and creates the TGIS_Hydrology toolset.
}
procedure TfrmHydrology.FormShow(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
  GIS.RestrictedDrag := False ;
  GIS.Open(
    TGIS_Utils.GisSamplesDataDirDownload +
    'World\Countries\Poland\DEM\Bytowski_County.tif'
  ) ;

  dem := GIS.Items[0] as TGIS_LayerPixel ;
  ext := dem.Extent ;

  dem.Params.Pixel.Antialias := False ;
  dem.Params.Pixel.GridShadow := False ;
  GIS.InvalidateWholeMap ;

  hydrologyToolset := TGIS_Hydrology.Create ;
  hydrologyToolset.BusyEvent := doBusyEvent ;
end;

{ Zooms out by a factor of 3/4 centred on the mouse pointer. }
procedure TfrmHydrology.GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
begin
  if GIS.IsEmpty then
    exit ;
  pt := GIS.ScreenToClient( MousePos ) ;
  GIS.ZoomBy( 3/4, pt.X, pt.Y ) ;
end;

{ Zooms in by a factor of 4/3 centred on the mouse pointer. }
procedure TfrmHydrology.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
begin
  if GIS.IsEmpty then
    exit ;
  pt := GIS.ScreenToClient( MousePos ) ;
  GIS.ZoomBy( 4/3, pt.X, pt.Y ) ;
end;

{
  Step 1 — Identify DEM problems.
  Runs TGIS_Hydrology.Sink on the raw DEM to produce a grid where non-zero
  cells mark sinks (isolated depressions) and flat areas that would prevent
  proper flow routing.  Colours the result in red for easy identification.
}
procedure TfrmHydrology.btnSinkClick(Sender: TObject);
var
  mn, mx : String ;
  sinks  : TGIS_LayerPixel ;
begin
  btnSink.Enabled:= False;

  // creating a grid layer for sinks
  sinks := CreateLayerPix( dem, HYDRO_LAYER_SINK ) ;

  // the Sink algorithm requires only a grid layer with DEM
  hydrologyToolset.Sink( dem, ext, sinks ) ;

  GIS.Add( sinks ) ;

  // coloring pixels with sinks (pits) and flats
  mn := sinks.MinHeight.ToString ;
  mx := sinks.MaxHeight.ToString ;
  sinks.Params.Pixel.AltitudeMapZones.Add(
    Format( '%s,%s,165:15:21:255,%s-%s', [mn, mx, mn, mx] )
  ) ;
  GIS.InvalidateWholeMap ;

  btnFillSinks.Enabled:= True ;
end;

{
  Step 2 — Fill sinks.
  Runs TGIS_Hydrology.Fill on the raw DEM to raise all depressions to the
  level of their lowest outlet, producing a hydrologically conditioned DEM
  in which water flows continuously downhill to the edge of the grid.
  Applies a YellowGreen colour ramp with hillshading for visualisation.
}
procedure TfrmHydrology.btnFillSinksClick(Sender: TObject);
var
  hydro_dem       : TGIS_LayerPixel ;
  color_ramp      : TGIS_GradientMap ;
  color_map       : TGIS_ColorMapArray ;
begin
  btnFillSinks.Enabled := False ;

  // turning off layers
  dem.Active:= False ;
  GetLayerGrd( HYDRO_LAYER_SINK ).Active := False ;

  // creating a grid layer for a hydrologically conditioned DEM
  hydro_dem := CreateLayerPix( dem, HYDRO_LAYER_DEM ) ;

  // the Fill algorithm requires a grid layer with DEM
  hydrologyToolset.Fill( dem, ext, hydro_dem ) ;

  GIS.Add( hydro_dem ) ;

  // applying the layer symbology
  color_ramp := TGIS_Utils.GisColorRampList.ByName( TGIS_ColorRampNames.YellowGreen ) ;
  color_map := color_ramp.RealizeColorMap( TGIS_ColorMapMode.Continuous, 0, True ) ;
  hydro_dem.GenerateRampEx( hydro_dem.MinHeight, hydro_dem.MaxHeight, color_map, nil ) ;
  hydro_dem.Params.Pixel.GridShadow := True ;
  hydro_dem.Params.Pixel.Antialias := True ;
  hydro_dem.Params.Pixel.ShowLegend := False ;

  GIS.InvalidateWholeMap ;

  btnFlowDirection.Enabled := True ;
end;

{
  Step 3 — Flow Direction.
  Runs TGIS_Hydrology.FlowDirection on the conditioned DEM.
  Each output cell receives a power-of-two code (1, 2, 4, 8, 16, 32, 64, 128)
  indicating the D8 steepest-descent direction.
  A turbo colour ramp makes the eight directions visually distinct.
}
procedure TfrmHydrology.btnFlowDirectionClick(Sender: TObject);
var
  flowdir, hydro_dem : TGIS_LayerPixel ;
begin
  btnFlowDirection.Enabled := False ;

  hydro_dem := GetLayerGrd( HYDRO_LAYER_DEM ) ;
  hydro_dem.Active := False ;

  // creating a grid layer for flow directions
  flowdir := CreateLayerPix( dem, HYDRO_LAYER_DIRECTION ) ;

  // the FlowDirection algorithm requires a hydrologically conditioned DEM
  hydrologyToolset.FlowDirection( hydro_dem, ext, flowdir ) ;

  // applying a turbo color ramp for direction codes
  flowdir.Params.Pixel.AltitudeMapZones.Add( '1,1,48:18:59:255,1' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '2,2,71:117:237:255,2' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '4,4,29:206:214:255,4' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '8,8,98:252:108:255,8' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '16,16,210:232:53:255,16' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '32,32,254:154:45:255,32' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '64,64,217:56:6:255,64' ) ;
  flowdir.Params.Pixel.AltitudeMapZones.Add( '128,128,122:4:3:255,128' ) ;
  flowdir.Params.Pixel.ShowLegend := True ;

  GIS.Add( flowdir ) ;
  GIS.InvalidateWholeMap ;

  btnFlowAccumulation.Enabled := True ;
end;

procedure TfrmHydrology.btnFlowAccumulationClick(Sender: TObject);
var
  flowdir, flowacc   : TGIS_LayerPixel ;
  classifier         : TGIS_ClassificationPixel ;
begin
  btnFlowAccumulation.Enabled := False ;

  flowdir := GetLayerGrd( HYDRO_LAYER_DIRECTION ) ;
  flowdir.Active := False ;

  // creating a grid layer for flow accumulation
  flowacc := CreateLayerPix( dem, HYDRO_LAYER_ACCUMULATION) ;

  // the FlowAccumulation algorithm requires a flow accumulation grid
  hydrologyToolset.FlowAccumulation( flowdir, ext, flowacc ) ;

  GIS.Add( flowacc ) ;

  // performing a geometric classification for a better result visualization
  classifier := TGIS_ClassificationPixel.Create( flowacc ) ;
  try
    classifier.Method := TGIS_ClassificationMethod.GeometricalInterval ;
    classifier.Band := '1' ;
    classifier.NumClasses := 5 ;
    classifier.ColorRamp := TGIS_Utils.GisColorRampList.ByName( TGIS_ColorRampNames.Bathymetry2 ) ;
    classifier.ColorRamp.DefaultReverse := True ;

    classifier.Classify ;
    flowacc.Params.Pixel.ShowLegend := True ;
  finally
    classifier.Free ;
  end;

  GIS.InvalidateWholeMap ;

  btnAddOutlets.Enabled := True ;
end;

procedure TfrmHydrology.btnAddOutletsClick(Sender: TObject);
var
  outlets : TGIS_LayerVector ;
  shp     : TGIS_Shape ;
begin
  btnAddOutlets.Enabled := False ;

  // creating a grid layer for outlets (pour points)
  outlets := CreateLayerVec( HYDRO_LAYER_OUTLETS, dem.CS,TGIS_ShapeType.Point ) ;

  // adding point symbology
  outlets.Params.Marker.Style := TGIS_MarkerStyle.TriangleUp ;
  outlets.Params.Marker.SizeAsText := 'SIZE:8pt' ;

  // adding two sample pour points
  // outlets should be located to cells of high accumulated flow
  shp := outlets.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Projection ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 375007.548333318, 696503.13358447 ) );
  shp.Unlock ;

  shp := outlets.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Projection ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 399612.055851588, 706196.55502031 ) );
  shp.Unlock ;

  GIS.Add( outlets ) ;
  GIS.InvalidateWholeMap ;

  btnWatershed.Enabled := True ;
end;

procedure TfrmHydrology.btnWatershedClick(Sender: TObject);
var
  outlets              : TGIS_LayerVector ;
  flowdir, watershed   : TGIS_LayerPixel ;
begin
  btnWatershed.Enabled := False ;

  flowdir := GetLayerGrd( HYDRO_LAYER_DIRECTION ) ;
  outlets := GetLayerVec( HYDRO_LAYER_OUTLETS ) ;

  // creating a grid layer for watershed
  watershed := CreateLayerPix( dem, HYDRO_LAYER_WATERSHED ) ;

  // applying a symbology
  watershed.Params.Pixel.AltitudeMapZones.Add( '1,1,62:138:86:255,1' ) ;
  watershed.Params.Pixel.AltitudeMapZones.Add( '2,2,108:3:174:255,2' ) ;
  watershed.Transparency := 50 ;

  watershed.Params.Pixel.ShowLegend := True ;

  // the Watershed algorithm requires Flow Direction grid and outlets
  // (may be vector, or grid)
  hydrologyToolset.Watershed( flowdir, outlets, GIS_FIELD_UID, ext, watershed ) ;

  GIS.Add( watershed ) ;
  GIS.InvalidateWholeMap ;

  btnBasin.Enabled := True ;
end;

procedure TfrmHydrology.btnBasinClick(Sender: TObject);
var
  flowdir, flowacc : TGIS_LayerPixel ;
  basins           : TGIS_LayerPixel ;
  classifier       : TGIS_ClassificationPixel ;
begin
  btnBasin.Enabled := False ;

  flowdir := GetLayerGrd( HYDRO_LAYER_DIRECTION ) ;
  flowacc := GetLayerGrd( HYDRO_LAYER_ACCUMULATION ) ;
  flowacc.Active := False ;
  GetLayerGrd( HYDRO_LAYER_DEM ).Active := False ;
  GetLayerGrd( HYDRO_LAYER_WATERSHED ).Active := False ;
  GetLayerVec( HYDRO_LAYER_OUTLETS ).Active := False ;

  // creating a grid layer for Basin
  basins := CreateLayerPix( dem, HYDRO_LAYER_BASIN ) ;

  // the Basin algorithm only requires a Flow Direction grid
  hydrologyToolset.Basin( flowdir, ext, basins, Round( flowacc.MaxHeight/100 ) ) ;

  GIS.Add( basins ) ;

  // classifying basin grid by unique values
  classifier := TGIS_ClassificationPixel.Create( basins ) ;
  try
    classifier.Method := TGIS_ClassificationMethod.Unique ;
    classifier.Band := GIS_BAND_GRID ;
    classifier.ShowLegend := False ;
    classifier.ColorRampName := TGIS_ColorRampNames.UniquePastel ;
    classifier.ColorRamp.DefaultColorMapMode := TGIS_ColorMapMode.Discrete ;

    classifier.Classify ;
  finally
    classifier.Free ;
  end ;

  GIS.InvalidateWholeMap ;

  btnStreamOrderStrahler.Enabled := True ;
end;

procedure TfrmHydrology.btnStreamOrderStrahlerClick(Sender: TObject);
var
  flowdir, flowacc, stream_order : TGIS_LayerPixel ;
begin
  btnStreamOrderStrahler.Enabled := False ;

  flowdir := GetLayerGrd( HYDRO_LAYER_DIRECTION ) ;
  flowacc := GetLayerGrd( HYDRO_LAYER_ACCUMULATION ) ;

  // creating a grid layer for stream order
  stream_order := CreateLayerPix( dem, HYDRO_LAYER_STREAM_ORDER ) ;

  // applying a symbology from the "Blues" color ramp
  stream_order.Params.Pixel.AltitudeMapZones.Add( '1,1,78:179:211:255,1' ) ;
  stream_order.Params.Pixel.AltitudeMapZones.Add( '2,2,43:140:190:255,2' ) ;
  stream_order.Params.Pixel.AltitudeMapZones.Add( '3,3,8:104:172:255,3' ) ;
  stream_order.Params.Pixel.AltitudeMapZones.Add( '4,4,8:64:129:255,4' ) ;
  stream_order.Params.Pixel.ShowLegend := True ;

  // the StreamOrder algorithm requires Flow Direction and Accumulation grids
  hydrologyToolset.StreamOrder( flowdir, flowacc, ext, stream_order ) ;

  GIS.Add( stream_order ) ;
  GIS.InvalidateWholeMap ;

  btnVectorize.Enabled := True ;
end;

procedure TfrmHydrology.btnVectorizeClick(Sender: TObject);
var
  flowdir                 : TGIS_LayerPixel ;
  basins, streams         : TGIS_LayerPixel ;
  streams_vec, basins_vec : TGIS_LayerVector ;
  vectorizator            : TGIS_GridToPolygon ;
  classifier              : TGIS_ClassificationVector ;
begin
  btnVectorize.Enabled := False ;

  flowdir := GetLayerGrd( HYDRO_LAYER_DIRECTION ) ;
  streams := GetLayerGrd( HYDRO_LAYER_STREAM_ORDER ) ;
  basins  := GetLayerGrd( HYDRO_LAYER_BASIN ) ;

  streams.Active := False ;
  basins.Active := False ;

  // 1. Converting basins to polygon

  // creating a vector polygon layer for basins
  basins_vec:= CreateLayerVec( HYDRO_LAYER_BASIN_VEC, dem.CS, TGIS_ShapeType.Polygon ) ;
  basins_vec.AddField( HYDRO_FIELD_BASIN, TGIS_FieldType.Number, 10, 0 ) ;

  // using the GirdToPolygon vectorization tool
  vectorizator := TGIS_GridToPolygon.Create ;
  try
    vectorizator.BusyEvent := doBusyEvent ;
    vectorizator.Generate( basins, basins_vec, HYDRO_FIELD_BASIN ) ;
  finally
    vectorizator.Free ;
  end ;

  GIS.Add( basins_vec ) ;

  // classifying a basins vector layer by unique value
  classifier := TGIS_ClassificationVector.Create( basins_vec ) ;
  try
    classifier.Method := TGIS_ClassificationMethod.Unique ;
    classifier.Field := HYDRO_FIELD_BASIN ;
    classifier.ShowLegend := False ;
    classifier.ColorRampName := TGIS_ColorRampNames.Unique ;
    classifier.ColorRamp.DefaultColorMapMode := TGIS_ColorMapMode.Discrete ;


    classifier.Classify ;
  finally
    classifier.Free ;
  end ;

  // 2. Converting streams to polylines

  // creating a vector layer for streams from Stream Order grid
  streams_vec := CreateLayerVec( HYDRO_LAYER_STREAM_VEC, dem.CS, TGIS_ShapeType.Arc ) ;
  streams_vec.AddField( HYDRO_FIELD_ORDER, TGIS_FieldType.Number, 10, 0 ) ;

  // applying a symbology and width based on a stream order value, and labeling
  streams_vec.Params.Line.WidthAsText := 'RENDERER' ;
  streams_vec.Params.Line.ColorAsText := 'ARGB:FF045A8D';
  streams_vec.Params.Render.Expression := HYDRO_FIELD_ORDER ;
  streams_vec.Params.Render.Zones := 4 ;
  streams_vec.Params.Render.MinVal:= 1 ;
  streams_vec.Params.Render.MaxVal:= 5 ;
  streams_vec.Params.Render.StartSizeAsText := 'SIZE:1pt' ;
  streams_vec.Params.Render.EndSizeAsText := 'SIZE:4pt' ;
  streams_vec.Params.Labels.Value := Format('{%s}', [HYDRO_FIELD_ORDER] );
  streams_vec.Params.Labels.FontSizeAsText := 'SIZE:7pt' ;
  streams_vec.Params.Labels.FontColorAsText := 'ARGB:FF045A8D' ;
  streams_vec.Params.Labels.ColorAsText := 'ARGB:FFBDC9E1' ;
  streams_vec.Params.Labels.Alignment := TGIS_LabelAlignment.Follow ;

  hydrologyToolset.StreamToPolyline( flowdir, streams, ext, streams_vec, HYDRO_FIELD_ORDER ) ;

  GIS.Add( streams_vec ) ;
  GIS.InvalidateWholeMap ;

  btn3D.Enabled := True ;
end;

procedure TfrmHydrology.btn3DClick(Sender: TObject);
var
  hdem            : TGIS_LayerPixel ;
  streams, basins : TGIS_LayerVector ;
begin
  if GIS.View3D then begin
    btn3D.Caption := 'View in 3D' ;
    GIS.View3D := False ;
  end
  else begin
    btn3D.Caption := 'View in 2D' ;

    basins := GetLayerVec( HYDRO_LAYER_BASIN_VEC ) ;
    basins.Active := False ;

    hdem := GetLayerGrd( HYDRO_LAYER_DEM ) ;
    hdem.Active := True ;
    hdem.Params.ScaleZ := 1 ;
    hdem.Params.NormalizedZ := TGIS_3DNormalizationType.Range ;

    streams := GetLayerVec( HYDRO_LAYER_STREAM_VEC ) ;
    streams.Params.Labels.Visible := False ;
    streams.Layer3D := TGIS_3DLayerType.Off ;

    GIS.InvalidateWholeMap ;

    GIS.View3D := True ;
    GIS.Viewer3D.ShowLights := True ;
    GIS.Viewer3D.ShadowsLevel := 40 ;
  end ;
end;

end.
