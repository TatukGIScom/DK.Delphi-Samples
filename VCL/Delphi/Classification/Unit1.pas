unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ToolWin,
  Vcl.ComCtrls,

  VCL.GisControlLegend,
  VCL.GisViewerWnd,
  VCL.GisFramework,
  System.Math,
  System.UITypes,

  GisClasses,
  GisClassification,
  GisLayer,
  GisLayerVector,
  GisLayerPixel,
  GisRegistredLayers,
  GisResource,
  GisRtl,
  GisTypes,
  GisTypesUI,
  GisUtils,

  VCL.GisControlColor;

type
  TfrmClassification = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_Legend: TGIS_ControlLegend;
    pnlClassification: TPanel;
    cmbFields: TComboBox;
    cmbMethods: TComboBox;
    lblField: TLabel;
    lblMethod: TLabel;
    lblClasses: TLabel;
    cmbClasses: TComboBox;
    cmbRenderType: TComboBox;
    lblRender: TLabel;
    pnlParamsBasic: TPanel;
    lblStartColor: TLabel;
    pnlStartColor: TPanel;
    lblEndColor: TLabel;
    pnlEndColor: TPanel;
    lblInterval: TLabel;
    edtInterval: TEdit;
    cmbStdInterval: TComboBox;
    lblStartSize: TLabel;
    edtStartSize: TEdit;
    lblEndSize: TLabel;
    edtEndSize: TEdit;
    dlgColor: TColorDialog;
    cbxLegend: TCheckBox;
    edtClassIdField: TEdit;
    Label1: TLabel;
    btnOpen: TButton;
    dlgFileOpen: TOpenDialog;
    edtManualBreaks: TEdit;
    btnAddManualBreak: TButton;
    lblManual: TLabel;
    cbxForceStatisticsCalculation: TCheckBox;
    pnlParamsColorRamp: TPanel;
    cbxColorRampName: TCheckBox;
    cbxColorRamp: TCheckBox;
    cmbColorRamps: TComboBox;
    Label2: TLabel;
    cmbColormapMode: TComboBox;
    cbxReverse: TCheckBox;
    procedure cmbFieldsChange(Sender: TObject);
    procedure cmbMethodsChange(Sender: TObject);
    procedure cmbClassesChange(Sender: TObject);
    procedure cmbRenderTypeChange(Sender: TObject);
    procedure cmbStdIntervalChange(Sender: TObject);
    procedure pnlStartColorClick(Sender: TObject);
    procedure pnlEndColorClick(Sender: TObject);
    procedure validateEdit( Sender : TObject ) ;
    procedure btnOpenClick(Sender: TObject);
    procedure cbxLegendClick(Sender: TObject);
    procedure cbxColorRampClick(Sender: TObject);
    procedure cmbColorRampsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddManualBreakClick(Sender: TObject);
    procedure cbxForceStatisticsCalculationClick(Sender: TObject);
    procedure cbxReverseClick(Sender: TObject);
    procedure cmbColormapModeChange(Sender: TObject);
  private
    { Private declarations }
    procedure fillCmbFields ;
    procedure fillCmbColorRamps ;
    procedure doClassify(Sender: TObject) ;
    function  getLayer : TGIS_Layer ;
    procedure setColorRampControls( const _enable : Boolean ) ;
  public
    { Public declarations }
  end;
const
  GIS_CLASSIFY_METHOD_DI  :  String = 'Defined Interval' ;
  GIS_CLASSIFY_METHOD_EI  :  String = 'Equal Interval';
  GIS_CLASSIFY_METHOD_GI  :  String = 'Geometrical Interval' ;
  GIS_CLASSIFY_METHOD_MN  :  String = 'Manual' ;
  GIS_CLASSIFY_METHOD_NB  :  String = 'Natural Breaks' ;
  GIS_CLASSIFY_METHOD_KM  :  String = 'K-Means' ;
  GIS_CLASSIFY_METHOD_KMS :  String = 'K-Means Spatial' ;
  GIS_CLASSIFY_METHOD_QN  :  String = 'Quantile' ;
  GIS_CLASSIFY_METHOD_QR  :  String = 'Quartile' ;
  GIS_CLASSIFY_METHOD_SD  :  String = 'Standard Deviation' ;
  GIS_CLASSIFY_METHOD_SDC :  String = 'Standard Deviation with Central' ;
  GIS_CLASSIFY_METHOD_UNQ :  String = 'Unique' ;

var
  frmClassification: TfrmClassification;

implementation

uses
  GisAllLayers,
  GisFunctions ;

{$R *.dfm}

const
  RENDER_TYPE_SIZE           = 'Size / Width' ;
  RENDER_TYPE_COLOR          = 'Color' ;
  RENDER_TYPE_OUTLINE_WIDTH  = 'Outline width' ;
  RENDER_TYPE_OUTLINE_COLOR  = 'Outline color' ;

  STD_INTERVAL_ONE           = '1 STDEV' ;
  STD_INTERVAL_ONE_HALF      = '1/2 STDEV' ;
  STD_INTERVAL_ONE_THIRD     = '1/3 STDEV' ;
  STD_INTERVAL_ONE_QUARTER   = '1/4 STDEV' ;

procedure TfrmClassification.FormShow(Sender: TObject);
begin
  dlgFileOpen.Filter := GisSupportedFiles( [TGIS_FileType.All] , false);

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
    'World\Countries\USA\States\California\Counties.shp'
  ) ;

  fillCmbFields ;
  fillCmbColorRamps ;
end;

procedure TfrmClassification.btnAddManualBreakClick(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.btnOpenClick(Sender: TObject);
var
  path : String ;
begin
  if not dlgFileOpen.Execute then
    exit ;

  path := dlgFileOpen.FileName ;

  GIS.Open( path ) ;

  fillCmbFields ;
  fillCmbColorRamps ;
end;

procedure TfrmClassification.fillCmbFields ;
var
  lyr   : TGIS_Layer ;
  lv    : TGIS_LayerVector ;
  lp    : TGIS_LayerPixel ;
  field : TGIS_FieldInfo ;
  i     : Integer;
begin
  cmbFields.Items.BeginUpdate ;
  cmbFields.Items.Clear ;

  lyr := TGIS_Layer( getLayer ) ;
  if lyr is TGIS_LayerVector then begin
    lv := TGIS_LayerVector ( getLayer ) ;

    cmbFields.Items.Add('GIS_UID');
    cmbFields.Items.Add('GIS_AREA');
    cmbFields.Items.Add('GIS_LENGTH');
    cmbFields.Items.Add('GIS_CENTROID_X');
    cmbFields.Items.Add('GIS_CENTROID_Y');

    for field in lv.Fields do begin
      case field.FieldType of
        TGIS_FieldType.Number,
        TGIS_FieldType.Float : cmbFields.Items.Add( field.Name ) ;
      end ;
    end ;
  end
  else if lyr is TGIS_LayerPixel then begin
    lp := TGIS_LayerPixel ( getLayer ) ;
    for i := 1 to lp.BandsCount do
      cmbFields.Items.Add( i.ToString ) ;
  end ;

  cmbFields.ItemIndex := 0 ;
  cmbFields.Items.EndUpdate ;
end;

procedure TfrmClassification.fillCmbColorRamps ;
var
  i : Integer ;
  ramp_name : String ;
begin
  cmbColorRamps.Items.BeginUpdate ;
  cmbColorRamps.Clear ;

  for i := 0 to GisColorRampList.Count - 1 do begin
    ramp_name := GisColorRampList.Items[i].Name ;

    cmbColorRamps.Items.Add( ramp_name ) ;

    if ramp_name = 'GreenBlue' then
      cmbColorRamps.ItemIndex := i ;

  end ;

  cmbColorRamps.Items.Add( 'None' ) ;
  cmbColorRamps.Items.EndUpdate ;
end;



function TfrmClassification.getLayer : TGIS_Layer ;
begin
  Result := nil ;
  if GIS.Items.Count <= 0 then
    exit ;
  
  Result := TGIS_Layer( GIS.Items[0] ) ;
end;

procedure TfrmClassification.validateEdit( Sender : TObject ) ;
var
  d : Double ;
begin
  if ( SameStr( cmbMethods.Text, GIS_CLASSIFY_METHOD_DI ) or
       SameStr( cmbRenderType.Text, RENDER_TYPE_SIZE ) or
       SameStr( cmbRenderType.Text, RENDER_TYPE_OUTLINE_WIDTH ) ) and
     TryStrToFloat( TEdit( Sender ).Text, d )
  then
    doClassify( Sender ) ;
end;

procedure TfrmClassification.pnlEndColorClick(Sender: TObject);
begin
  if not dlgColor.Execute then exit ;
  pnlEndColor.Color := dlgColor.Color ;

  doClassify( Sender ) ;
end;

procedure TfrmClassification.pnlStartColorClick(Sender: TObject);
begin
  if not dlgColor.Execute then
    exit ;
  pnlStartColor.Color := dlgColor.Color ;

  doClassify( Sender ) ;
end;

procedure TfrmClassification.setColorRampControls( const _enable : Boolean ) ;
begin
  cbxColorRampName.Enabled := _enable ;
  cmbColorRamps.Enabled := _enable ;
  cmbColormapMode.Enabled := _enable ;
  cbxReverse.Enabled := _enable ;
end;

procedure TfrmClassification.cmbFieldsChange(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbMethodsChange(Sender: TObject);
var
  f      : Single ;
  method : String ;

  procedure setInterval( val : Boolean ) ;
  begin
    edtInterval.Visible := val ;
    lblInterval.Visible := val ;
  end;

  procedure showInterval ;
  begin
    setInterval( True ) ;
  end;

  procedure hideInterval ;
  begin
    setInterval( False ) ;
  end;

  procedure setStdDev( val : Boolean ) ;
  begin
    cmbStdInterval.Visible := val ;
    lblInterval.Visible  := val ;
  end;

  procedure showStdDev ;
  begin
    setStdDev( True ) ;
  end;

  procedure hideStdDev ;
  begin
    setStdDev( False ) ;
  end;

  procedure setClasses( val : Boolean ) ;
  begin
    cmbClasses.Visible := val ;
    lblClasses.Visible  := val ;
  end;

  procedure showClasses ;
  begin
    setClasses( True ) ;
  end;

  procedure hideClasses ;
  begin
    setClasses( False ) ;
  end;

  procedure setManual( val : Boolean ) ;
  begin
    edtManualBreaks.Visible := val ;
    lblManual.Visible  := val ;
    btnAddManualBreak.Visible := val ;
  end;

  procedure showManual ;
  begin
    setManual( True ) ;
  end;

  procedure hideManual ;
  begin
    setManual( False ) ;
  end;

begin
  if not TryStrToFloat( edtInterval.Text, f ) then
    edtInterval.Text := '100' ;

  cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf(TGIS_ColorRampNames.GreenBlue) ;
  cmbColormapMode.ItemIndex := cmbColormapMode.Items.IndexOf( GIS_COLORMAPMODE_CONTINUOUS ) ;

  method := cmbMethods.Items[cmbMethods.ItemIndex] ;

  // no selection
  if cmbMethods.ItemIndex = 0 then begin
    hideInterval ;
    hideStdDev ;
    hideClasses ;
    hideManual ;
  end
  else if method = GIS_CLASSIFY_METHOD_DI then begin
    hideStdDev ;
    hideClasses ;
    hideManual ;

    showInterval ;
  end
  else if method = GIS_CLASSIFY_METHOD_MN then begin
    hideInterval ;
    hideStdDev ;
    hideClasses ;

    showManual ;
  end
  else if method = GIS_CLASSIFY_METHOD_QR then begin
    hideInterval ;
    hideStdDev ;
    hideClasses ;
    hideManual ;

    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.BrownGreen) ;
  end
  else if ( method = GIS_CLASSIFY_METHOD_SD ) or
          ( method = GIS_CLASSIFY_METHOD_SDC ) then
  begin
    hideInterval ;
    hideClasses ;
    hideManual ;

    showStdDev ;

    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.BrownGreen ) ;
  end
  else if method = GIS_CLASSIFY_METHOD_UNQ then
  begin
    hideInterval ;
    hideClasses ;
    hideStdDev ;
    hideManual ;

    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.Unique ) ;
    cmbColormapMode.ItemIndex := cmbColormapMode.Items.IndexOf( GIS_COLORMAPMODE_DISCRETE ) ;
    cbxColorRamp.Checked := True ;
  end
  else begin
    hideInterval ;
    hideStdDev ;
    hideManual ;

    showClasses ;
  end ;

  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbRenderTypeChange(Sender: TObject);
var
  ll : TGIS_Layer ;
begin
  ll := getLayer ;
  if ll is TGIS_LayerVector then begin
    ll.ParamsList.ClearAndSetDefaults ;
    if ( TGIS_LayerVector( ll ).DefaultShapeType = TGIS_ShapeType.Polygon ) and
       ( cmbRenderType.Items[cmbRenderType.ItemIndex] = RENDER_TYPE_SIZE ) then begin // "Size / Width"
      messagedlg( 'Method not allowed for polygons.', mtWarning, [mbOK], 0 ) ;
      cmbRenderType.ItemIndex := 1 ;
    end ;
  end ;
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbStdIntervalChange(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cbxColorRampClick(Sender: TObject);
begin
  setColorRampControls( cbxColorRamp.Checked ) ;

  doClassify( Sender ) ;
end;

procedure TfrmClassification.cbxForceStatisticsCalculationClick(
  Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cbxLegendClick(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cbxReverseClick(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbClassesChange(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbColormapModeChange(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbColorRampsChange(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

procedure TfrmClassification.doClassify(Sender: TObject) ;
var
  lyr              : TGIS_Layer ;
  lv               : TGIS_LayerVector ;
  method           : String ;
  render_type      : String ;
  std_interval     : String ;
  class_id_field   : String ;
  create_field     : Boolean ;
  classifier       : TGIS_ClassificationAbstract ;
  classifier_vec   : TGIS_ClassificationVector ;
  class_breaks_arr : TArray< String > ;
  class_break_str  : String ;
  class_break_val  : Double ;
  colormap_mode    : TGIS_ColorMapMode ;
  ramp_name        : String ;
begin
  if cmbMethods.ItemIndex <= 0 then exit ;

  create_field := False ;
  lyr := TGIS_Layer( getLayer ) ;
  if not assigned( lyr ) then
    exit ;

  if lyr is TGIS_LayerVector then begin
    lv := TGIS_LayerVector( lyr ) ;

    // add "ClassIdField" if provided
    class_id_field := edtClassIdField.Text ;
    create_field := ( length( class_id_field ) > 0 ) ;
    if create_field and ( lv.FindField( class_id_field ) < 0 ) then
      lv.AddField( class_id_field, TGIS_FieldType.Number, 3, 0 ) ;
  end
  else if not ( lyr is TGIS_LayerPixel ) then begin
    messagedlg(
      Format( 'Layer ''%s'' is not supported.', [TGIS_LayerPixel( lyr ).Name] ),
      mtWarning, [mbOK], 0
    ) ;
    exit ;
  end ;

  classifier := TGIS_ClassificationFactory.CreateClassifier( lyr ) ;
  try
    // set common properties
    classifier.Target := cmbFields.Items[ cmbFields.ItemIndex ] ;
    { NumClasses property is automatically calculated for methods:
      DefinedInterval, Quartile, StandardDeviation(s) }
    classifier.NumClasses := cmbClasses.ItemIndex + 1 ;
    classifier.StartColor := TGIS_Color.FromBGR( pnlStartColor.Color ) ;
    classifier.EndColor := TGIS_Color.FromBGR( pnlEndColor.Color ) ;
    classifier.ShowLegend := cbxLegend.Checked ;

    // set method
    method := cmbMethods.Items[cmbMethods.ItemIndex] ;
    if method = GIS_CLASSIFY_METHOD_DI then
      classifier.Method := TGIS_ClassificationMethod.DefinedInterval
    else if method = GIS_CLASSIFY_METHOD_EI then
      classifier.Method := TGIS_ClassificationMethod.EqualInterval
    else if method = GIS_CLASSIFY_METHOD_GI then
      classifier.Method := TGIS_ClassificationMethod.GeometricalInterval
    else if method = GIS_CLASSIFY_METHOD_KM then
      classifier.Method := TGIS_ClassificationMethod.KMeans
    else if method = GIS_CLASSIFY_METHOD_KMS then
      classifier.Method := TGIS_ClassificationMethod.KMeansSpatial
    else if method = GIS_CLASSIFY_METHOD_MN then
      classifier.Method := TGIS_ClassificationMethod.Manual
    else if method = GIS_CLASSIFY_METHOD_NB then
      classifier.Method := TGIS_ClassificationMethod.NaturalBreaks
    else if method = GIS_CLASSIFY_METHOD_QN then
      classifier.Method := TGIS_ClassificationMethod.Quantile
    else if method = GIS_CLASSIFY_METHOD_QR then
      classifier.Method := TGIS_ClassificationMethod.Quartile
    else if method = GIS_CLASSIFY_METHOD_SD then
      classifier.Method := TGIS_ClassificationMethod.StandardDeviation
    else if method = GIS_CLASSIFY_METHOD_SDC then
      classifier.Method := TGIS_ClassificationMethod.StandardDeviationWithCentral
    else if method = GIS_CLASSIFY_METHOD_UNQ then
      classifier.Method := TGIS_ClassificationMethod.Unique
    else
      classifier.Method := TGIS_ClassificationMethod.NaturalBreaks ;

    // set interval
    classifier.Interval := DotStrToFloat( edtInterval.Text ) ;
    if ( method = GIS_CLASSIFY_METHOD_SD ) or
       ( method = GIS_CLASSIFY_METHOD_SDC ) then
    begin
      std_interval := cmbStdInterval.Items[cmbStdInterval.ItemIndex] ;
      if std_interval = STD_INTERVAL_ONE then
        classifier.Interval := 1
      else if std_interval = STD_INTERVAL_ONE_HALF then
        classifier.Interval := 1/2
      else if std_interval = STD_INTERVAL_ONE_THIRD then
        classifier.Interval := 1/3
      else if std_interval = STD_INTERVAL_ONE_QUARTER then
        classifier.Interval := 1/4
      else
        classifier.Interval := 1;
    end ;

    // set manual
    class_breaks_arr := string(edtManualBreaks.Text).Split( [',', ';', '/'] ) ;
    for class_break_str in class_breaks_arr do
    begin
      try
        class_break_val := DotStrToFloat(class_break_str) ;
      except
        continue;
      end;

      classifier.AddClassBreak(class_break_val) ;
    end;

    if cbxColorRamp.Checked and ( cmbColorRamps.Text <> 'None' ) then begin
      // colormap mode
      if cmbColormapMode.Items[cmbColormapMode.ItemIndex] = GIS_COLORMAPMODE_CONTINUOUS then
        colormap_mode := TGIS_ColorMapMode.Continuous
      else
        colormap_mode := TGIS_ColorMapMode.Discrete ;

      // ramp can be assigned directly (ColorRamp) or by name (ColorRampName)
      ramp_name := cmbColorRamps.Items[cmbColorRamps.ItemIndex] ;
      if cbxColorRampName.Checked then
        classifier.ColorRampName := ramp_name
      else
        classifier.ColorRamp := GisColorRampList.ByName( ramp_name ) ;

      classifier.ColorRamp.DefaultColorMapMode := colormap_mode ;
      classifier.ColorRamp.DefaultReverse := cbxReverse.Checked ;
    end
    else begin
      classifier.ColorRamp := nil ;
    end ;

    // vector-only params
    if classifier is TGIS_ClassificationVector then begin
      classifier_vec := TGIS_ClassificationVector( classifier ) ;
      classifier_vec.StartSize := StrToInt( edtStartSize.Text ) ;
      classifier_vec.EndSize := StrToInt( edtEndSize.Text ) ;
      classifier_vec.ClassIdField := class_id_field ;

      // render type
      render_type := cmbRenderType.Items[cmbRenderType.ItemIndex] ;
      if render_type = RENDER_TYPE_SIZE then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Size
      else if render_type = RENDER_TYPE_COLOR then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Color
      else if render_type = RENDER_TYPE_OUTLINE_WIDTH then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.OutlineWidth
      else if render_type = RENDER_TYPE_OUTLINE_COLOR then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.OutlineColor
      else
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Color ;
    end ;

    { The classification process is based on layer statistics.
      By default, the classifier will force the calculation of the required statistics.
      If the user wants to have control over it,
      "ForceStatisticsCalculation" property should be set to False.
      See the usual code in this case. }
    classifier.ForceStatisticsCalculation := cbxForceStatisticsCalculation.Checked ;
    if (not classifier.ForceStatisticsCalculation) and classifier.MustCalculateStatistics then begin
      if messagedlg('Statistics need to be calculated.', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
        lyr.Statistics.Calculate ;
      end
      else begin
        lyr.Statistics.ResetModified ;
        exit ;
      end ;
    end ;

    if classifier.Classify and create_field and assigned( lv ) then
      lv.SaveData ;
  finally
    FreeObject( classifier ) ;
  end ;
  GIS.InvalidateWholeMap ;
end;

end.
