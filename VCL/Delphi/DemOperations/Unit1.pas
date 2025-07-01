//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide basic dem operations.
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

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.FullExtent
  else
    GIS.FullExtent ;
end;

procedure TForm1.btnGenerateClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel ;
  ld  : TGIS_LayerPixel ;
  dem : TGIS_DemGenerator ;
  dop : TGIS_DemOperation ;
  sm  : TGIS_DemSlopeMode ;
  cm  : TGIS_DemTotalCurvatureMode ;
begin
  lp := TGIS_LayerPixel( GIS.Items[0] ); ;

  ld := TGIS_LayerPixel.Create ;
  ld.Name := 'out_' ;
  ld.CS := lp.CS ;
  ld.Build( True, lp.CS, lp.Extent, lp.BitWidth, lp.BitHeight ) ;

  dem := TGIS_DemGenerator.Create ;
  try
    case cbDemOperation.ItemIndex of
      {Hillshade }
      0 : begin
            dop := TGIS_DemOperationHillShade.Create(
                      DotStrToFloat( eZFactor.Text ),
                      DotStrToFloat( eAzimuth.Text ),
                      DotStrToFloat( eAltitude.Text),
                      cbCombined.Checked
                    ) ;
          end ;
      {Slope     }
      1 : begin
            case cbSlopeMode.ItemIndex of
              0 : sm := TGIS_DemSlopeMode.Degrees ;
              1 : sm := TGIS_DemSlopeMode.Percent
            else  sm := TGIS_DemSlopeMode.Degrees ;
            end;
            dop := TGIS_DemOperationSlope.Create(
                      sm,
                      DotStrToFloat( eScale.Text )
                    ) ;
          end ;
      {SlopeHydro}
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
      {Aspect    }
      3 : dop := TGIS_DemOperationAspect.Create( chkAngleAzimuth.Checked ) ;
      {TRI       }
      4 : dop := TGIS_DemOperationTRI.Create ;
      {TPI       }
      5 : dop := TGIS_DemOperationTPI.Create ;
      {Roughness }
      6 : dop := TGIS_DemOperationRoughness.Create ;
      {TotalCurvature}
      7 : begin
            case cbCurvatureMode.ItemIndex of
              0 : cm := TGIS_DemTotalCurvatureMode.Profile ;
              1 : cm := TGIS_DemTotalCurvatureMode.Plan
            else  cm := TGIS_DemTotalCurvatureMode.Profile ;
            end;
            dop := TGIS_DemOperationTotalCurvature.Create( cm ) ;
          end;
      {MatrixGain}
      8 : dop := TGIS_DemOperationMatrixGain.Create ;
      { Flow dir}
      9 : dop := TGIS_DemOperationFlowDir.Create
    else  dop := TGIS_DemOperation.Create ;
    end;

    ld.Name := 'out_' + dop.Description ;
    if GIS.Get( ld.Name ) <> nil then
      GIS.Delete( ld.Name ) ;

    ld.Params.Pixel.GridShadow := False ;
    GIS.Add( ld ) ;
    try
      dem.Process( lp, lp.Extent, ld, dop, doBusyEvent ) ;
    finally
      FreeObject( dop ) ;
    end;
    GIS.InvalidateWholeMap ;
  finally
    FreeObject( dem ) ;
  end ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Zoom
  else
    GIS.Mode := TGIS_ViewerMode.Zoom ;
end;


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

procedure TForm1.btn1Click(Sender: TObject);
begin
  GIS.View3D := not GIS.View3D ;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ
  else
    GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  dlgFileOpen.Filter := GisSupportedFiles( [ TGIS_FileType.All ] , false);

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
            '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf'
           ) ;
  cbDemOperationChange( Sender ) ;
end;

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

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if not dlgFileOpen.Execute then exit ;

  GIS.Open( dlgFileOpen.FileName ) ;
end;

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
