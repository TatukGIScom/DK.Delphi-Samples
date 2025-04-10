unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,

  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  VCL.GisViewerWnd,
  Vcl.CheckLst,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,

  //GisLicense,
  GisLayer,
  GisStatistics;

type
  TfrmStatistics = class(TForm)
    gbxResults: TGroupBox;
    pnlLeft: TPanel;
    gbxLayers: TGroupBox;
    rbtnVector: TRadioButton;
    rbtnGrid: TRadioButton;
    rbtnPixel: TRadioButton;
    rbtnCustom: TRadioButton;
    gbxStatistics: TGroupBox;
    chlbxStatistics: TCheckListBox;
    gbxDefinitions: TGroupBox;
    chlbxDefinitions: TCheckListBox;
    btnCalculate: TButton;
    btnOpen: TButton;
    openDialog: TOpenDialog;
    pnlStatisticsButtons: TPanel;
    btnBasic: TButton;
    btnStandard: TButton;
    btnAll: TButton;
    mmResults: TMemo;
    pnlDefinitionsButtons: TPanel;
    btnSelect: TButton;
    btnDeselect: TButton;
    pnlMain: TPanel;
    progress: TProgressBar;
    GIS: TGIS_ViewerWnd;
    cbxFastStatistics: TCheckBox;
    cbxUseBesselCorrection: TCheckBox;
    pnlResultsIO: TPanel;
    btnLoadStat: TButton;
    btnSaveStat: TButton;
    procedure rbtnPixelClick(Sender: TObject);
    procedure rbtnVectorClick(Sender: TObject);
    procedure rbtnGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbtnCustomClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnBasicClick(Sender: TObject);
    procedure btnStandardClick(Sender: TObject);
    procedure btnAllClick(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnDeselectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveStatClick(Sender: TObject);
    procedure btnLoadStatClick(Sender: TObject);
    procedure doBusyEvent(_sender: TObject; _pos, _end: Integer;
      var _abort: Boolean);

  private
    { Private declarations }
    abrt : Boolean ;
    sample_vector : String ;
    sample_grid   : String ;
    sample_pixel  : String ;
    custom_path   : String ;

    procedure openFile ;
    procedure enableOpenButton ;
    procedure disableOpenButton ;
    procedure prepareStatisticsDefinitions ( const _layer : TGIS_Layer );
    procedure openLayerAndStats ( const _path : String ) ;
    procedure checkPredefined ( const _predefined_funcs : array of String ) ;
    procedure showResults ( const _stats_engine     : TGIS_StatisticsAbstract ;
                            const _clear            : Boolean
                          ) ;
    function prepareFunctions ( var    _funcs            : TGIS_StatisticalFunctions
                              ) : Boolean ;
    function getLayer : TGIS_Layer ;


  public
    { Public declarations }
  end;

var
  frmStatistics: TfrmStatistics;

implementation

{$R *.dfm}

uses
  System.Math,
  System.UITypes,
  System.Diagnostics,

  GisAllLayers,
  GisClasses,
  GisInterfaces,
  GisLayerPixel,
  GisLayerVector,
  GisRegistredLayers,
  GisResource,
  GisRtl,
  GisTypes,
  GisUtils;

const
  // buttons captions
  BUTTON_CALCULATE = 'Calculate statistics' ;
  BUTTON_CANCEL    = 'Cancel' ;

  // predefined sets of statistical functions
  // find in documentation: GisStatisticsAll, GisStatisticsBasic, GisStatisticsStandard
  STATISTICS_BASIC : array[0..4] of string = (
    'Average',
    'Count',
    'Max',
    'Min',
    'Sum'
  ) ;
  STATISTICS_STANDARD : array[0..9] of string = (
    'Average',
    'Count',
    'CountMissings',
    'Max',
    'Median',
    'Min',
    'Range',
    'StandardDeviation',
    'Sum',
    'Variance'
  ) ;

procedure TfrmStatistics.FormCreate(Sender: TObject);
var
  sample_dir : String ;
begin
  abrt := False ;
  btnCalculate.Caption := BUTTON_CALCULATE ;

  GIS.Mode := TGIS_ViewerMode.Zoom ;

  openDialog.Filter := GisSupportedFiles(
    [TGIS_FileType.Vector, TGIS_FileType.Pixel, TGIS_FileType.Grid],
    false
  ) ;

  // set file paths
  sample_dir := TGIS_Utils.GisSamplesDataDirDownload + 'World\Countries\USA\States\California' ;
  sample_vector := sample_dir + '\Counties.shp' ;
  sample_grid := sample_dir + '\San Bernardino\NED\w001001.adf' ;
  sample_pixel := sample_dir + '\San Bernardino\DOQ\37134877.jpg' ;
  custom_path := '' ;

  // open sample vector layer
  rbtnVector.Checked := True ;

  // set common functions
  checkPredefined( STATISTICS_STANDARD ) ;
end;

procedure TfrmStatistics.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  abrt := True ;
end;

procedure TfrmStatistics.doBusyEvent(
      _sender: TObject ;
      _pos   : Integer ;
      _end   : Integer ;
  var _abort : Boolean
) ;
begin
  case _pos of
    // initialize progress bar
    0  : begin
      progress.Min := 0 ;
      progress.Max := 100 ;
      progress.Position := 0 ;
    end ;
    // end of progress - reset progress bar
    -1 : progress.Position := 0 ;
  else
    progress.Position := _pos ;
  end ;

  _abort := abrt ;
  Application.ProcessMessages ;
end;

function TfrmStatistics.getLayer : TGIS_Layer ;
begin
  Result := TGIS_Layer( GIS.Items[0] ) ;
end;

// -----------------------------------------------------------------------------
// SELECT LAYER
// -----------------------------------------------------------------------------
procedure TfrmStatistics.enableOpenButton ;
begin
  btnOpen.Enabled := True ;
end;

procedure TfrmStatistics.disableOpenButton ;
begin
  btnOpen.Enabled := False ;
end;

procedure TfrmStatistics.openLayerAndStats( const _path : String ) ;
var
  ll : TGIS_Layer ;
begin
  GIS.Open( _path ) ;
  ll := getLayer ;
  prepareStatisticsDefinitions( ll ) ;
  showResults( ll.Statistics, true ) ;
end;

procedure TfrmStatistics.rbtnVectorClick(Sender: TObject);
begin
  disableOpenButton ;
  openLayerAndStats( sample_vector ) ;
end;

procedure TfrmStatistics.rbtnGridClick(Sender: TObject);
begin
  disableOpenButton ;
  openLayerAndStats( sample_grid ) ;
end;

procedure TfrmStatistics.rbtnPixelClick(Sender: TObject);
begin
  disableOpenButton ;
  openLayerAndStats( sample_pixel ) ;
end;

procedure TfrmStatistics.rbtnCustomClick(Sender: TObject);
begin
  enableOpenButton ;

  if not IsStringEmpty( custom_path ) then begin
    openLayerAndStats( custom_path ) ;
  end
  else begin
    openFile ;
  end ;
end;

procedure TfrmStatistics.btnOpenClick(Sender: TObject);
begin
  openFile ;
end;

procedure TfrmStatistics.openFile ;
begin
  if not openDialog.Execute() then begin
    if IsStringEmpty( custom_path ) then
      rbtnVector.Checked := True ;
    exit ;
  end ;
  custom_path := openDialog.FileName ;

  openLayerAndStats( custom_path ) ;
end;

// -----------------------------------------------------------------------------
// SELECT STATISTICS
// -----------------------------------------------------------------------------
procedure TfrmStatistics.btnBasicClick(Sender: TObject);
begin
  checkPredefined( STATISTICS_BASIC ) ;
end;

procedure TfrmStatistics.btnStandardClick(Sender: TObject);
begin
  checkPredefined( STATISTICS_STANDARD ) ;
end;

procedure TfrmStatistics.btnAllClick(Sender: TObject);
begin
  chlbxStatistics.CheckAll( cbChecked ) ;
end;

procedure TfrmStatistics.checkPredefined(
  const _predefined_funcs : array of String
) ;
var
  id       : Integer ;
  stat_fun : String ;
begin
  chlbxStatistics.CheckAll( cbUnchecked ) ;

  for stat_fun in _predefined_funcs do begin
    id := chlbxStatistics.Items.IndexOf( stat_fun ) ;
    chlbxStatistics.State[id] := cbChecked ;
  end ;
end;

// -----------------------------------------------------------------------------
// STATISTICS DEFINITIONS
// -----------------------------------------------------------------------------
procedure TfrmStatistics.btnSelectClick(Sender: TObject);
begin
  chlbxDefinitions.CheckAll( cbChecked ) ;
end;

procedure TfrmStatistics.btnDeselectClick(Sender: TObject);
begin
  chlbxDefinitions.CheckAll( cbUnchecked ) ;
end;

// depending on layer's type prepare list of available statistics definitions
// field names for vector layers; band names for pixel layers
procedure TfrmStatistics.prepareStatisticsDefinitions(
  const _layer : TGIS_Layer
) ;
var
  lv    : TGIS_LayerVector ;
  lp    : TGIS_LayerPixel ;
  field : TGIS_FieldInfo ;
  band  : String ;
  i     : Integer ;
begin
  chlbxDefinitions.Items.BeginUpdate ;

  chlbxDefinitions.Clear ;
  if _layer is TGIS_LayerVector then begin
    lv := TGIS_LayerVector (_layer ) ;
    gbxDefinitions.Caption := 'Select fields' ;

    // fill with virtual field names
    chlbxDefinitions.Items.Add( GIS_FIELD_UID ) ;
    chlbxDefinitions.Items.Add( GIS_FIELD_AREA ) ;
    chlbxDefinitions.Items.Add( GIS_FIELD_LENGTH ) ;
    chlbxDefinitions.Items.Add( GIS_FIELD_COORD_Z ) ;

    // fill with layer field names
    for field in lv.Fields do
      chlbxDefinitions.Items.Add( field.NewName ) ;

    chlbxDefinitions.CheckAll( cbChecked ) ;
  end
  else if _layer is TGIS_LayerPixel then begin
    lp := TGIS_LayerPixel( _layer ) ;
    gbxDefinitions.Caption := 'Select bands' ;

    // fill with appropriate band names
    if lp.IsGrid then
      chlbxDefinitions.Items.Add( GIS_BAND_DEFAULT ) ;

    for i := 0 to lp.BandsCount - 1 do
      chlbxDefinitions.Items.Add( ( i + 1 ).ToString ) ;

    if lp.IsGrid then begin
      chlbxDefinitions.Items.Add( GIS_BAND_GRID ) ;
      chlbxDefinitions.Checked[ chlbxDefinitions.Items.Count-1 ] := True ;
    end
    else begin
      chlbxDefinitions.Items.Add( GIS_BAND_A ) ;
      chlbxDefinitions.Items.Add( GIS_BAND_R ) ;
      chlbxDefinitions.Checked[ chlbxDefinitions.Items.Count-1 ] := True ;
      chlbxDefinitions.Items.Add( GIS_BAND_G ) ;
      chlbxDefinitions.Checked[ chlbxDefinitions.Items.Count-1 ] := True ;
      chlbxDefinitions.Items.Add( GIS_BAND_B ) ;
      chlbxDefinitions.Checked[ chlbxDefinitions.Items.Count-1] := True ;
      chlbxDefinitions.Items.Add( GIS_BAND_H ) ;
      chlbxDefinitions.Items.Add( GIS_BAND_S ) ;
      chlbxDefinitions.Items.Add( GIS_BAND_L ) ;
    end ;
  end ;

  chlbxDefinitions.Items.EndUpdate ;
end;

function TfrmStatistics.prepareFunctions(
 var  _funcs : TGIS_StatisticalFunctions
) : Boolean ;
var
  i: Integer;
begin
  Result := False ;
  _funcs := TGIS_StatisticalFunctions.EmptyStatistics ;

  for i := 0 to chlbxStatistics.Items.Count - 1 do begin
    if chlbxStatistics.Checked[i] then begin
      Result := True ;

      if ( chlbxStatistics.Items.Strings[i] = 'Average' ) then
        _funcs.Average := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Count' ) then
        _funcs.Count := True
      else if ( chlbxStatistics.Items.Strings[i] = 'CountMissings' ) then
        _funcs.CountMissings := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Max' ) then
        _funcs.Max := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Majority' ) then
        _funcs.Majority := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Median' ) then
        _funcs.Median := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Min' ) then
        _funcs.Min := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Minority' ) then
        _funcs.Minority := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Range' ) then
        _funcs.Range := True
      else if ( chlbxStatistics.Items.Strings[i] = 'StandardDeviation' ) then
        _funcs.StandardDeviation := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Sample' ) then
        _funcs.Sample := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Sum' ) then
        _funcs.Sum := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Variance' ) then
        _funcs.Variance := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Variety' ) then
        _funcs.Variety := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Unique' ) then
        _funcs.Unique := True
      else if ( chlbxStatistics.Items.Strings[i] = 'Percentile' ) then
        _funcs.Percentile := True ;
    end ;
  end ;
end;

procedure TfrmStatistics.btnCalculateClick(Sender: TObject);
var
  i     : Integer ;
  ll    : TGIS_Layer ;
  funcs : TGIS_StatisticalFunctions ;
begin
  // cancel calculation
  if SameStr( btnCalculate.Caption, BUTTON_CANCEL ) then begin
    abrt := True ;
    btnCalculate.Caption := BUTTON_CALCULATE ;
    exit ;
  end ;

  btnCalculate.Caption := BUTTON_CANCEL ;
  abrt := False ;
  try
    // statistical functions
    if not prepareFunctions( funcs ) then begin
      messagedlg( 'Select at least one statistical function.', mtError, [mbOK], 0 ) ;
      exit ;
    end ;

    // creating statistics engine
    ll := getLayer ;
    ll.Statistics.Reset ;

    // use Bessel's correction
    // if True, calculate "sample" standard devation and variance;
    // if False, calculate "population" version (this is default)
    ll.Statistics.UseBesselCorrection := cbxUseBesselCorrection.Checked ;

    // collect statistics definitions (fields or bands)
    for i := 0 to chlbxDefinitions.Items.Count - 1 do begin
      if chlbxDefinitions.Checked[i] then
        ll.Statistics.Add( chlbxDefinitions.Items.Strings[i], funcs ) ;
    end ;

    if ll.Statistics.DefinedResults.Count = 0 then begin
      messagedlg( 'Select at least one field for vector layer or band for pixel layer.', mtError, [mbOK], 0 ) ;
      exit ;
    end ;

    // here the calculations start...

    // statistics class can calaculate statistics for a given extent;
    // for filtering data: "_extent", "_shape", "_de9im" and only for vector layers:
    // "_query", "_useSelected" parameters can be used

    // "Fast Statistics" works only for pixel layers (for now);
    // big pixel layers are resampled to avoid long calculation;
    // the results are approximate with high accuracy
    ll.Statistics.Calculate( GIS.VisibleExtent, nil, '', cbxFastStatistics.Checked ) ;

    // print results on TMemo control
    showResults( ll.Statistics, True ) ;
  finally
    btnCalculate.Caption := BUTTON_CALCULATE ;
  end ;
end;

// -----------------------------------------------------------------------------
// STATISTICS RESULTS
// -----------------------------------------------------------------------------
procedure TfrmStatistics.showResults(
  const _stats_engine : TGIS_StatisticsAbstract ;
  const _clear        : Boolean
) ;
const
  DASHED_LINE = '----------------------------------------';
var
  stats_name      : String ;
  stats_result    : TGIS_StatisticsResult ;  // may be also TGIS_StatisticsLayerResult
  stats_available : Tlist< TGIS_StatisticsItem > ;
  stats_item      : TGIS_StatisticsItem ;
  node_string     : String ;
begin
  mmResults.Lines.BeginUpdate ;
  if _clear then
    mmResults.Lines.Clear ;

  for stats_name in _stats_engine.AvailableResults do begin
    mmResults.Lines.Add( DASHED_LINE ) ;
    mmResults.Lines.Add(stats_name ) ;
    mmResults.Lines.Add( DASHED_LINE ) ;

    stats_result := _stats_engine.Get( stats_name ) ;
    stats_available := stats_result.AvailableStatistics ;
    try
      for stats_item in stats_available do begin
        node_string := Format( '    + %s = %s', [stats_item.Name, stats_item.ToString] ) ;
        mmResults.Lines.Add( node_string ) ;
      end ;
    finally
      FreeObject( stats_available ) ;
    end ;
  end ;
  mmResults.Lines.EndUpdate ;

if _stats_engine.Obsolete and
     ( CompareDateTime( _stats_engine.Age, EncodeDate( 1899, 12, 30 ) ) > 0 ) then
    messagedlg( 'Statistics are outdated.', mtWarning, [mbOK], 0 ) ;
end;

procedure TfrmStatistics.btnSaveStatClick(Sender: TObject);
var
  ll : TGIS_Layer ;
begin
  ll := getLayer ;
  ll.Statistics.SaveToFile ;
end;

procedure TfrmStatistics.btnLoadStatClick(Sender: TObject);
var
  ll : TGIS_Layer ;
begin
  ll := getLayer ;
  if not ll.Statistics.LoadFromFile then
    messagedlg( 'Loading failed .', mtError, [mbOK], 0 ) ;

  showResults( ll.Statistics, true ) ;
end;

end.

