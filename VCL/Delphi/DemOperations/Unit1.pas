//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  DemOperations sample - demonstrates terrain analysis derived from a DEM raster.

  The sample opens an ADF elevation grid and lets the user choose from the
  following TGIS_DemGenerator operations:
    Hillshade      - simulates sun illumination to produce a shaded relief image
    Slope          - steepness at each cell (degrees or percent)
    Slope Hydro    - hydrologically corrected slope
    Aspect         - compass direction of the downslope face
    TRI            - Terrain Ruggedness Index
    TPI            - Topographic Position Index
    Roughness      - local surface roughness
    Total Curvature - profile or plan curvature
    Matrix Gain    - local gain matrix
    Flow Dir       - D8 flow direction

  A custom hillshade implementation (changeDEM) is also provided to demonstrate
  the TGIS_LayerPixel.GridOperationEvent callback mechanism.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerVector,
  GisLayerPixel,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisLayerADF,
  GisDem,

  Vcl.GisViewerWnd,
  Vcl.GisControlLegend ;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    ToolButton4: TToolButton;
    ImageList1: TImageList;
    paTop: TPanel;
    GroupBox1: TGroupBox;
    tbShadowAngle: TTrackBar;
    btnGenerate: TButton;
    cbDemOperation: TComboBox;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    cbCombined: TCheckBox;
    eZFactor: TEdit;
    eAzimuth: TEdit;
    eAltitude: TEdit;
    Label18: TLabel;
    Label17: TLabel;
    cbSlopeMode: TComboBox;
    eScale: TEdit;
    GIS_Legend: TGIS_ControlLegend;
    Label1: TLabel;
    pboperation: TProgressBar;
    cbCustomOperation: TCheckBox;
    gbMain: TGroupBox;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    dlgFileOpen: TOpenDialog;
    chkAngleAzimuth: TCheckBox;
    gbHillShadeParams: TGroupBox;
    gbSlopeParams: TGroupBox;
    cbCurvatureMode: TComboBox;
    Label2: TLabel;
    gbCurvature: TGroupBox;
    btn1: TToolButton;
    btn2: TToolButton;
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbShadowAngleChange(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure doBusyEvent(_sender: TObject; _pos, _end: Integer;
      var _abort: Boolean);
    procedure cbCustomOperationClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure cbDemOperationChange(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function changeDEM(       _layer  : TObject        ;
                        const _extent : TGIS_Extent    ;
                        const _source : TGIS_GridArray ;
                          var _output : TGIS_GridArray ;
                        const _width  : Integer        ;
                        const _height : Integer        ;
                          var _minz   : Single         ;
                          var _maxz   : Single
                        ) : Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  System.Math,
  GisRegistredLayers,
  GisAllLayers,
  GisRtl ;

{ Resets the viewer to show the full spatial extent of all loaded layers. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.FullExtent
  else
    GIS.FullExtent ;
end;

{ Creates an output grid layer matching the source DEM, instantiates the
  DEM operation selected in cbDemOperation, runs TGIS_DemGenerator.Process,
  and adds the result layer to the viewer. }
{ btnGenerateClick - Core DEM analysis algorithm dispatcher

  Algorithm pipeline:
    1. Retrieve source DEM layer from viewer (lp)
    2. Create output raster layer (ld) with same extent and dimensions
    3. Select appropriate TGIS_DemOperation subclass based on user choice
    4. Create TGIS_DemGenerator engine
    5. Process source DEM through selected operation, writing result to output layer
    6. Update viewer to display result
    7. Progress reported via doBusyEvent callback

  Operation selection (10 types):
    - Hillshade: sun illumination shaded relief (parameters: z-factor, azimuth, altitude)
    - Slope: steepness in degrees or percent
    - SlopeHydro: hydrologically corrected slope
    - Aspect: compass direction of downslope (0-360°)
    - TRI: Terrain Ruggedness Index
    - TPI: Topographic Position Index
    - Roughness: local surface roughness
    - TotalCurvature: profile or plan curvature
    - MatrixGain: local gain matrix
    - FlowDir: D8 flow direction encoding

  Output handling:
    - Output layer created with same spatial reference as input
    - Named "out_<operation>" to avoid conflicts
    - Previous output of same name deleted to avoid duplication
    - GridShadow disabled on output to show computed values
}
procedure TForm1.btnGenerateClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel ;  { Source DEM layer from viewer }
  ld  : TGIS_LayerPixel ;  { Output layer to hold result }
  dem : TGIS_DemGenerator ; { DEM processing engine }
  dop : TGIS_DemOperation ; { Selected operation (Hillshade, Slope, etc.) }
  sm  : TGIS_DemSlopeMode ; { Slope calculation mode (Degrees or Percent) }
  cm  : TGIS_DemTotalCurvatureMode ; { Curvature type (Profile or Plan) }
begin
  { Get source DEM layer }
  lp := TGIS_LayerPixel( GIS.Items[0] );

  { Create output layer with identical spatial properties }
  ld := TGIS_LayerPixel.Create ;
  ld.Name := 'out_' ;
  ld.CS := lp.CS ;  { Preserve coordinate system }
  { Build layer: empty, with same extent and dimensions as source }
  ld.Build( True, lp.CS, lp.Extent, lp.BitWidth, lp.BitHeight ) ;

  { Create DEM processing engine }
  dem := TGIS_DemGenerator.Create ;
  try
    { Instantiate the selected DEM operation based on combobox selection }
    case cbDemOperation.ItemIndex of
      {Hillshade: sun illumination parameters}
      0 : begin
            dop := TGIS_DemOperationHillShade.Create(
                      DotStrToFloat( eZFactor.Text ),   { Z-factor: elevation exaggeration }
                      DotStrToFloat( eAzimuth.Text ),   { Azimuth: light direction (0-360°) }
                      DotStrToFloat( eAltitude.Text),   { Altitude: light angle above horizon }
                      cbCombined.Checked                { Combined: overlay original with hillshade }
                    ) ;
          end ;
      {Slope: steepness calculation}
      1 : begin
            { Select slope output unit: degrees or percent }
            case cbSlopeMode.ItemIndex of
              0 : sm := TGIS_DemSlopeMode.Degrees ;     { Rise/run in degrees (0-90) }
              1 : sm := TGIS_DemSlopeMode.Percent       { Rise/run percentage (0-∞) }
            else  sm := TGIS_DemSlopeMode.Degrees ;
            end;
            dop := TGIS_DemOperationSlope.Create(
                      sm,
                      DotStrToFloat( eScale.Text )      { Scale factor for output }
                    ) ;
          end ;
      {SlopeHydro: hydrologically corrected slope}
      2 : begin
            case cbSlopeMode.ItemIndex of
              0 : sm := TGIS_DemSlopeMode.Degrees ;
              1 : sm := TGIS_DemSlopeMode.Percent
            else  sm := TGIS_DemSlopeMode.Degrees ;
            end;
            dop := TGIS_DemOperationSlopeHydro.Create(
                      sm,
                      DotStrToFloat( eScale.Text )
                    ) ;
          end ;
      {Aspect: compass direction of downslope face}
      3 : dop := TGIS_DemOperationAspect.Create( chkAngleAzimuth.Checked ) ;
      {TRI: Terrain Ruggedness Index (local elevation variance)}
      4 : dop := TGIS_DemOperationTRI.Create ;
      {TPI: Topographic Position Index (relative elevation)}
      5 : dop := TGIS_DemOperationTPI.Create ;
      {Roughness: local surface roughness measure}
      6 : dop := TGIS_DemOperationRoughness.Create ;
      {TotalCurvature: profile or plan curvature}
      7 : begin
            case cbCurvatureMode.ItemIndex of
              0 : cm := TGIS_DemTotalCurvatureMode.Profile ; { Along-slope curvature }
              1 : cm := TGIS_DemTotalCurvatureMode.Plan      { Cross-slope curvature }
            else  cm := TGIS_DemTotalCurvatureMode.Profile ;
            end;
            dop := TGIS_DemOperationTotalCurvature.Create( cm ) ;
          end;
      {MatrixGain: local gain matrix computation}
      8 : dop := TGIS_DemOperationMatrixGain.Create ;
      {FlowDir: D8 flow direction encoding (1,2,4,8,16,32,64,128)}
      9 : dop := TGIS_DemOperationFlowDir.Create
    else
      dop := TGIS_DemOperation.Create ;  { Fallback: base operation }
    end;

    { Set output layer name to include operation description }
    ld.Name := 'out_' + dop.Description ;

    { Remove any previous output of same name to avoid conflicts }
    if GIS.Get( ld.Name ) <> nil then
      GIS.Delete( ld.Name ) ;

    { Configure output layer for result display }
    ld.Params.Pixel.GridShadow := False ;  { Disable shading, show computed values }
    GIS.Add( ld ) ;  { Add output layer to viewer }

    try
      { Execute the DEM operation: read from lp, write to ld, report progress via callback }
      dem.Process( lp, lp.Extent, ld, dop, doBusyEvent ) ;
    finally
      FreeObject( dop ) ;  { Clean up operation }
    end;

    GIS.InvalidateWholeMap ;  { Refresh display with result }
  finally
    FreeObject( dem ) ;  { Clean up DEM generator }
  end ;
end;

{ Switches the viewer interaction mode to zoom. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Zoom
  else
    GIS.Mode := TGIS_ViewerMode.Zoom ;
end;


{ Attaches or detaches the custom changeDEM hillshade callback on the source
  layer when the checkbox state changes.  When attached, the built-in grid
  rendering is replaced by the manual hillshade computation. }
procedure TForm1.cbCustomOperationClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[0] );
  if not Assigned(ll) then exit;

  if cbCustomOperation.Checked then begin
    TGIS_LayerPixel(ll).Params.Pixel.AltitudeMapZones.Clear ;
    TGIS_LayerPixel(ll).Params.Pixel.GridShadow := False ;
    TGIS_LayerPixel(ll).GridOperationEvent := changeDEM ;
  end
  else begin
    TGIS_LayerPixel(ll).GridOperationEvent := nil ;
    TGIS_LayerPixel(ll).Params.Pixel.GridShadow := True ;
  end;

  GIS.InvalidateWholeMap ;
end;

{ Shows or hides the parameter sub-panels that are relevant to the currently
  selected DEM operation (e.g. hillshade params, slope mode, curvature mode). }
procedure TForm1.cbDemOperationChange(Sender: TObject);
begin
  gbHillShadeParams.Visible := False ;
  gbSlopeParams.Visible := False ;
  chkAngleAzimuth.Visible := False ;
  gbCurvature.Visible := False ;
  gbSlopeParams.Top := gbHillShadeParams.Top ;
  gbCurvature.Top := gbHillShadeParams.Top ;

  chkAngleAzimuth.Top := gbHillShadeParams.Top ;

  case cbDemOperation.ItemIndex of
    0 : gbHillShadeParams.Visible := True ;
    1 : gbSlopeParams.Visible := True ;
    2 : gbSlopeParams.Visible := True ;
    3 : chkAngleAzimuth.Visible := True ;
    7 : gbCurvature.Visible := True
  end;

  gbMain.Height := 250 ;

  btnGenerate.Top := gbMain.Top + 260 ;
end;

{ Toggles the viewer between 2-D map view and 3-D perspective view. }
procedure TForm1.btn1Click(Sender: TObject);
begin
  GIS.View3D := not GIS.View3D ;
end;

{ Switches the viewer interaction mode to pan/drag. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ
  else
    GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{ Initialises the open-file filter and loads the default sample DEM on startup. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  dlgFileOpen.Filter := GisSupportedFiles( [ TGIS_FileType.All ] , false);

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
            '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf'
           ) ;
  cbDemOperationChange( Sender ) ;
end;

{ Reports DEM processing progress on the progress bar.  Shows and updates the
  bar while _end > 0, and hides it when the operation completes. }
procedure TForm1.doBusyEvent(_sender: TObject; _pos, _end: Integer;
  var _abort: Boolean);
begin
  // show busy state
  if _end <= 0 then
    pboperation.Visible := False
  else begin
    pboperation.Visible := True ;
    pboperation.Position := Trunc( _pos / _end * 100 ) ;
  end;

  pboperation.Update ;

  Application.ProcessMessages ;
end;

{ Updates the grid shadow angle on the source layer as the track bar position
  changes, giving an interactive sun-position preview. }
procedure TForm1.tbShadowAngleChange(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[0] );
  if not Assigned(ll) then exit;

  ll.Params.Pixel.GridShadowAngle := tbShadowAngle.Position;
  if not GIS.InPaint then
    GIS.InvalidateWholeMap;
end;

{ Opens a file dialog and loads the chosen raster file into the viewer. }
procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if not dlgFileOpen.Execute then exit ;

  GIS.Open( dlgFileOpen.FileName ) ;
end;

{ Custom GridOperationEvent callback that computes a hillshade value for every
  cell using a 3x3 neighbourhood (Horn's algorithm).  The function reads the
  nine-cell window from _source, calculates the cosine of the sun incidence
  angle (cang), and writes the shaded value (1..255) to _output.  Cells that
  contain the layer's NoData value are passed through unchanged.
  Returns True to indicate the output grid is valid. }
function TForm1.changeDEM(
         _layer : TObject        ;
  const _extent : TGIS_Extent    ;
  const _source : TGIS_GridArray ;
    var _output : TGIS_GridArray ;
  const _width  : Integer        ;
  const _height : Integer        ;
    var _minz   : Single         ;
    var _maxz   : Single
): Boolean;
const
  RAD_TO_DEG    = 180.0 / Pi ;
  DEG_TO_RAD    = Pi / 180.0 ;
  SQUARE_M_PI_2 = (Pi*Pi)/4 ;
var
  i, j           : Integer ;
  sin_alt_rad    : Double ;
  cos_alt_zsf    : Double ;
  az_rad         : Double ;
  square_z_sf    : Double ;
  z_scale_factor : Double ;
  minz, maxz     : Single ;
  ZFactor        : Double ;
  Azimuth        : Double ;
  Altitude       : Double ;
  Combined       : Boolean ;
  NoDataValue    : Single ;
  XRes           : Double ;
  YRes           : Double ;
  Scale          : Double ;
  AWindow        : array [0..8] of Single ;
  k,l            : Integer ;
  xsize          : Integer ;
  ysize          : Integer ;
  xscale         : Double ;
  yscale         : Double ;
  val            : Single ;
  usealg         : Boolean ;
  abrt           : Boolean ;
  l1,l2,l3       : Integer ;
  inodata        : Single ;
  x, y, aspect,
  xx_plus_yy,
  cang           : Double ;
begin
  Result := True ;

  xsize   := _width ;
  ysize   := _height ;
  xscale  := (_extent.XMax - _extent.XMin ) / xsize ;
  yscale  := ( _extent.YMax - _extent.YMin ) / ysize ;
  abrt    := False ;
  inodata := TGIS_LayerPixel(_layer).NoDataValue ;

  XRes    := xscale ;
  YRes    := yscale ;
  Scale   := 1 ;
  minz    := GIS_MAX_SINGLE ;
  maxz    := -GIS_MAX_SINGLE ;

  ZFactor   := 0.00002 ;
  Azimuth   := 225.0 ;
  Altitude  := 45 ;
  Combined  := False ;

  sin_alt_rad     := Sin(Altitude * DEG_TO_RAD) ;
  az_rad          := Azimuth * DEG_TO_RAD ;
  z_scale_factor  := ZFactor / (2*Scale) ;
  cos_alt_zsf     := Cos(Altitude*DEG_TO_RAD) * z_scale_factor ;
  square_z_sf     := z_scale_factor * z_scale_factor ;

  for i := 2 to _height-1 do begin
    l1 := i-2 ;
    l2 := i-1 ;
    l3 := i ;
    for j := 1 to _width-2 do begin
      AWindow[0] := _source[l1,j-1] ;
      AWindow[1] := _source[l1,j  ] ;
      AWindow[2] := _source[l1,j+1] ;
      AWindow[3] := _source[l2,j-1] ;
      AWindow[4] := _source[l2,j  ] ;
      AWindow[5] := _source[l2,j+1] ;
      AWindow[6] := _source[l3,j-1] ;
      AWindow[7] := _source[l3,j  ] ;
      AWindow[8] := _source[l3,j+1] ;

      usealg := True ;
      val := inodata ;
      if Abs(AWindow[4] - inodata) < 1e-10 then begin
        val := inodata ;
        usealg := False ;
      end
      else begin
        for k := 0 to 8 do begin
          if Abs(AWindow[k] - inodata) < 1e-10 then begin
            val := inodata ;
            usealg := False ;
            break ;
          end ;
        end ;
      end ;

      if usealg then begin
        x := (AWindow[3] - AWindow[5]) / XRes ;
        y := (AWindow[7] - AWindow[1]) / YRes ;

        xx_plus_yy := x * x + y * y;
        aspect := System.Math.ArcTan2(y,x);
        cang := (sin_alt_rad - cos_alt_zsf * sqrt(xx_plus_yy) *
                 Sin(aspect - az_rad)) /Sqrt(1 + square_z_sf * xx_plus_yy);
        if (cang <= 0.0) then
          cang := 1.0
        else
          cang := 1.0 + (254.0 * cang);
        val := cang ;
      end ;

      if _source[l1,j] <> inodata then
        _output[l1,j] := val ;

      if ( val < minz ) and
         ( val <> inodata ) then
        minz := val ;

      if ( val > maxz      ) and
         ( val <> inodata ) then
        maxz := val ;
    end;
  end  ;
  _minz := minz ;
  _maxz := maxz ;
end;


end.
