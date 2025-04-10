unit formMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls,

  //GisLicense,
  GisLayerPixel,
  VCL.GisViewerWnd,
  VCL.GisControlLegend;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    edtFormula: TEdit;
    lblFormula: TLabel;
    btnExecute: TButton;
    pbrProgress: TProgressBar;
    lblResultType: TLabel;
    rbtnResultPixel: TRadioButton;
    rbtnResultGrid: TRadioButton;
    GIS_Legend: TGIS_ControlLegend;
    btnOpenGrid: TButton;
    btnOpenPixel: TButton;
    btnOpenVector: TButton;
    lblSource: TLabel;
    procedure btnExecuteClick(Sender: TObject);
    procedure btnOpenGridClick(Sender: TObject);
    procedure btnOpenPixelClick(Sender: TObject);
    procedure btnOpenVectorClick(Sender: TObject);
  private
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
    procedure applyRamp(
      const _l : TGIS_LayerPixel
    ) ;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.Math,
  GisRtl,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisLayer,
  GisLayerVector,
  GisRasterAlgebra,
  GisRegistredLayers,
  GisAllLayers ;


const
  SAMPLE_RESULT : String = 'Result' ;


procedure TfrmMain.doBusyEvent(
      _sender : TObject ;
      _pos    : Integer ;
      _end    : Integer ;
  var _abort  : Boolean
) ;
begin
  case _pos of
    // initialize progress bar
    0  : begin
      pbrProgress.Min := 0 ;
      pbrProgress.Max := 100 ;
      pbrProgress.Position := 0 ;
    end ;
    // end of progress - reset progress bar
    -1 : pbrProgress.Position := 0 ;
  else
    pbrProgress.Position := _pos ;
  end ;
end ;


procedure TfrmMain.applyRamp(
  const _l : TGIS_LayerPixel
) ;
begin
  _l.GenerateRamp(
    TGIS_Color.Blue, TGIS_Color.Lime, TGIS_Color.Red,
    1.0*FloorS( _l.MinHeight ),
    ( _l.MaxHeight + _l.MinHeight )/2.0,
    1.0*Ceil( _l.MaxHeight ), True,
    ( _l.MaxHeight - _l.MinHeight )/100.0,
    ( _l.MaxHeight - _l.MinHeight )/10.0,
    nil, False
  ) ;
  _l.Params.Pixel.GridShadow := False ;
end ;


procedure TfrmMain.btnOpenPixelClick(Sender: TObject);
var
  path : String ;
  lp   : TGIS_LayerPixel ;
begin
  GIS.Close ;

  path := TGIS_Utils.GisSamplesDataDirDownload +
    '\World\Countries\USA\States\California\San Bernardino\DOQ\37134877.jpg' ;

  lp := TGIS_LayerPixel( GisCreateLayer( 'Pixel', path ) ) ;
  GIS.Add( lp ) ;
  GIS.FullExtent ;

  rbtnResultPixel.Checked := True ;
  edtFormula.Text := 'RGB(255 - pixel.R, 255 - pixel.G, 255 - pixel.B)' ;
end;


procedure TfrmMain.btnOpenGridClick(Sender: TObject);
var
  path : String ;
  lp   : TGIS_LayerPixel ;
begin
  GIS.Close ;

  path := TGIS_Utils.GisSamplesDataDirDownload +
    '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf' ;

  lp := TGIS_LayerPixel( GisCreateLayer( 'grid', path ) ) ;
  lp.UseConfig := False ;
  GIS.Add( lp ) ;
  applyRamp( lp ) ;
  GIS.FullExtent ;

  rbtnResultGrid.Checked := True ;
  edtFormula.Text := 'IF(grid < AVG(grid), MIN(grid), MAX(grid))' ;
end;


procedure TfrmMain.btnOpenVectorClick(Sender: TObject);
var
  path : String ;
  lv   : TGIS_LayerVector ;
begin
  GIS.Close ;

  path := TGIS_Utils.GisSamplesDataDirDownload +
    '\World\Countries\USA\States\California\San Bernardino\TIGER\' +
//    'tl_2008_06071_areawater_trunc.shp' ;
    'tl_2008_06071_edges_trunc.shp' ;

  lv := TGIS_LayerVector( GisCreateLayer( 'vector', path ) ) ;
  lv.UseConfig := False ;
  GIS.Add( lv ) ;
  GIS.FullExtent ;

  rbtnResultPixel.Checked := True ;
  edtFormula.Text := 'IF(NODATA(vector.GIS_UID), RGB(0,255,0), RGB(255,0,0))' ;
end;


procedure TfrmMain.btnExecuteClick(Sender: TObject);
var
  src : TGIS_LayerPixel ;
  dst : TGIS_LayerPixel ;
  ra  : TGIS_RasterAlgebra ;
  gew : Double ;
  lew : Double ;
  w   : Integer ;
  siz : Integer ;
  i   : Integer ;
begin
  if GIS.IsEmpty then begin
    ShowMessage( 'The viewer is empty!' ) ;
    exit ;
  end ;

  if Assigned( GIS.Get( SAMPLE_RESULT ) ) then
    GIS.Delete( SAMPLE_RESULT ) ;

  gew := GIS.Extent.XMax - GIS.Extent.XMin ;

  src := nil ;
  siz := 0 ;
  for i := 0 to GIS.Items.Count - 1 do begin
    if GIS.Items.Items[i] is TGIS_LayerPixel then begin
      src := TGIS_LayerPixel( GIS.Items.Items[i] ) ;
      lew := src.Extent.XMax - src.Extent.XMin ;
      w := Round( gew*src.BitWidth/lew ) ;
      siz := Max( w, siz ) ;
    end ;
  end ;

  dst := TGIS_LayerPixel.Create ;
  if Assigned( src ) then
    dst.Build( rbtnResultGrid.Checked, GIS.CS, GIS.Extent, siz, 0 )
  else
    dst.Build( rbtnResultGrid.Checked, GIS.CS, GIS.Extent, GIS.Width, 0 ) ;
  dst.Name := SAMPLE_RESULT ;

  GIS.Add( dst ) ;

  ra := TGIS_RasterAlgebra.Create ;
  try
    ra.BusyEvent := doBusyEvent ;

    for i := 0 to GIS.Items.Count - 1 do
      ra.AddLayer( TGIS_Layer( GIS.Items.Items[i] ) ) ;

    try
      ra.Execute( SAMPLE_RESULT + ' = ' + edtFormula.Text ) ;
    except
      GIS.Delete( dst.Name ) ;
      ShowMessage( 'Incorrect formula!' ) ;
    end ;

  finally
    FreeObject( ra ) ;
  end ;

  if dst.IsGrid then
    applyRamp( dst ) ;

  GIS.InvalidateWholeMap ;
end ;

end.
