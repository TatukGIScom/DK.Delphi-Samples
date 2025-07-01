//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide SQL Layer support.
}
unit formLayerSQL;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Classes,

  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Data.Win.ADODB,
  Data.DB,

  GisLayer,
  GisTypes,
  GisParams,
  GisViewer ;

type
  TfrmLayerSQL = class(TForm)
    lbConnectionStr: TLabel;
    btnBuild: TButton;
    lbDialect: TLabel;
    cbDialects: TComboBox;
    treeLayers: TTreeView;
    ImgListObjectTypes: TImageList;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    SaveDialog1: TSaveDialog;
    btnSaveFile: TButton;
    btnAddLayer: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    cbStorage: TComboBox;
    Label4: TLabel;
    btnConnect: TButton;
    Label3: TLabel;
    memAdditional: TMemo;
    StatusBar1: TStatusBar;
    cbConnStr: TComboBox;
    rbADO: TRadioButton;
    rbSQLite: TRadioButton;
    lbPath: TLabel;
    btnPath: TButton;
    OpenDialog1: TOpenDialog;
    rbFileGDB: TRadioButton;
    rbOGR: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBuildClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnAddLayerClick(Sender: TObject);
    procedure treeLayersClick(Sender: TObject);
    procedure btnSaveFileClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbConnStrChange(Sender: TObject);
    procedure rbADOClick(Sender: TObject);
    procedure rbSQLiteClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure cbConnStrKeyPress(Sender: TObject; var Key: Char);
    procedure rbFileGDBClick(Sender: TObject);
    procedure rbOGRClick(Sender: TObject);
    procedure cbDialectsChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    function prepareConnectString( const _txt : String ) : TStrings ;
    function prepareADONETCS : String ;
    function prepareOCI : TStrings ;
    function getSQLPath(  const _storage  : String  ;
                          const _name     : String ;
                          const _isRaster : Boolean = False ;
                          const _isOci    : Boolean = False ;
                          const _isAdoNet : Boolean = False
                         ) : String ;
    procedure fillTree( const _name   : String ;
                        const _ls     : TGIS_LayerInfoList ;
                        const _type   : Integer
                       );
    procedure addNewLayer( const _name : String ;
                           const _type : Integer
                          );
    function getLayer( const _name : String ;
                        const _type : Integer
                       ) : TGIS_Layer ;
  public
    { Public declarations }
  end;

var
  frmLayerSQL: TfrmLayerSQL;

implementation

uses
   Data.Win.AdoConEd,
   WinApi.ShellAPI,
   WinApi.ShlObj,

   GisLayerVectorSql,
   GisLayerPixelSql,
   GislayerFGDB,
   GisLayerOGR,
   GisInternals,
   GisResource,
   GisConfig,
   GisFunctions,
   GisClasses,
   GisRegistredLayers ,
   GisRtl,
   Unit1;

{$R *.dfm}

const
  LAYERSQL_NATIVE           = 0 ;
  LAYERSQL_OPENGISBLOB      = 1 ;
  LAYERSQL_OPENGISBLOB2     = 2 ;
  LAYERSQL_GEOMEDIA         = 3 ;
  LAYERSQL_POSTGIS          = 4 ;
  LAYERSQL_PERSONALGDB      = 5 ;
  LAYERSQL_SDEBINARY        = 6 ;
  LAYERSQL_PIXELSTORE2      = 7 ;
  LAYERSQL_KATMAI           = 8 ;
  LAYERSQL_ORACLESPATIAL    = 9 ;
  LAYERSQL_SDERASTER        = 10;
  LAYERSQL_ORACLEGEORASTER  = 11 ;
  LAYERSQL_SPATIALWARE      = 12 ;
  LAYERSQL_DB2GSE           = 13 ;
  LAYERSQL_IFXSDB           = 14 ;
  LAYERSQL_FGDB             = 15 ;
  LAYERSQL_ORACLESPATIALPC  = 16 ;
  LAYERSQL_ORACLESPATIALTIN = 17 ;
  LAYERSQL_GEOMEDIA_MSSQL   = 18 ;
  LAYERSQL_GEOMEDIA_SDO     = 19 ;
  LAYERSQL_ANYWHERE_SPATIAL = 20 ;
  LAYERSQL_OGR              = 21 ;

function TfrmLayerSQL.prepareConnectString(const _txt: String): TStrings;
var
  tkn : TGIS_tokenizer  ;
begin
  tkn := TGIS_Tokenizer.Create ;
  try
    tkn.ExecuteEx( _txt, ';' ) ;
    Result := TStringList.Create ;
    Result.AddStrings( tkn.Result ) ;
  finally
    tkn.free ;
  end;
end;

procedure TfrmLayerSQL.rbADOClick(Sender: TObject);
begin
  if rbADO.Checked then begin
    lbPath.Visible := False ;
    btnPath.Visible := False ;
    lbConnectionStr.Visible := True ;
    btnBuild.Visible := True ;
  end;
end;
procedure TfrmLayerSQL.rbFileGDBClick(Sender: TObject);
begin
  if rbFileGDB.Checked then begin
    lbPath.Visible := True ;
    btnPath.Visible := True ;
    lbConnectionStr.Visible := False ;
    OpenDialog1.FilterIndex := 2 ;
    btnBuild.Visible := False ;
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_INI_LAYERSQL_FILEGDB ) ;
    cbDialectsChange( self ) ;
  end;
end;

procedure TfrmLayerSQL.rbOGRClick(Sender: TObject);
begin
  if rbOGR.Checked then begin
    lbPath.Visible := True ;
    btnPath.Visible := True ;
    lbConnectionStr.Visible := False ;
    OpenDialog1.FilterIndex := 3 ;
    btnBuild.Visible := False ;
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_INI_LAYERSQL_OGR ) ;
    cbDialectsChange( self ) ;
  end;
end;

procedure TfrmLayerSQL.rbSQLiteClick(Sender: TObject);
begin
  if rbSQLite.Checked then begin
    lbPath.Visible := True ;
    btnPath.Visible := True ;
    lbConnectionStr.Visible := False ;
    btnBuild.Visible := False ;
    OpenDialog1.FilterIndex := 1 ;
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_SQLITE ) ;
    cbDialectsChange( self ) ;
  end;
end;

procedure TfrmLayerSQL.treeLayersClick(Sender: TObject);
var
  ll : TGIS_Layer ;
  i  : Integer ;
begin
  if Assigned( treeLayers.Selected ) and ( treeLayers.Selected.Level > 0 ) then
  begin
    btnAddLayer.Enabled := True ;
    btnSaveFile.Enabled := True ;

    ll := getLayer( treeLayers.Selected.Text, Integer( treeLayers.Selected.Data ) ) ;
    try
      memAdditional.Clear ;
      if ll is TGIS_LayerVectorSqlAbstract then
        for i := 0 to TGIS_LayerVectorSqlAbstract(ll).SQLParametersEx.Count-1 do
          memAdditional.Lines.Add(
              TGIS_LayerVectorSqlAbstract(ll).SQLParametersEx[i] + '='
          )
      else if ll is TGIS_LayerPixelSqlAbstract then
        for i := 0 to TGIS_LayerPixelSqlAbstract(ll).SQLParametersEx.Count-1 do
          memAdditional.Lines.Add(
              TGIS_LayerPixelSqlAbstract(ll).SQLParametersEx[i] + '='
          ) ;
    finally
      FreeObject( ll ) ;
    end ;

    StatusBar1.SimpleText := 'Selected layer : ' + treeLayers.Selected.Text ;
  end
  else begin
    btnAddLayer.Enabled := False ;
    btnSaveFile.Enabled := False ;
    StatusBar1.SimpleText := '' ;
  end;

end;

procedure TfrmLayerSQL.fillTree( const _name  : String ;
                                 const _ls    : TGIS_LayerInfoList ;
                                 const _type  : Integer
                                 );
var
  i, m  : Integer ;
  tr    : TTreeNode;
  tc    : TTreeNode;
begin
  treeLayers.Items.BeginUpdate;
  try
    tr := treeLayers.Items.AddNode( nil, nil, _name, nil, naAdd ) ;
    tr.ImageIndex := ImgListObjectTypes.Count -1;
    tr.SelectedIndex := ImgListObjectTypes.Count -1;
    _ls.Sort ;

    for i := 0 to _ls.Count - 1 do begin
      tc := treeLayers.Items.AddChild( tr, _ls[ i ].Name );
      m  := Integer( _ls[ i ].ShapeType);
      if m = - 1 then
        m := ImgListObjectTypes.Count -1 ;
      tc.ImageIndex := m ;
      tc.SelectedIndex := m ;
      tc.Data := TObject( _type ) ;
    end;
    tr.Expanded := True ;
  finally
    treeLayers.Items.EndUpdate;
  end;
end;



function TfrmLayerSQL.prepareADONETCS : String ;
var
  tkn : TGIS_Tokenizer ;
  i   : Integer ;
begin
  tkn := TGIS_Tokenizer.Create ;
  try
    tkn.Execute( cbConnStr.Text, [';'] ) ;
    Result := '' ;
    for i := 0 to tkn.Result.Count - 1 do begin
      if ( tkn.Result.Names[i] = 'Integrated Security'  ) or
         ( tkn.Result.Names[i] = 'Persist Security Info') or
         ( tkn.Result.Names[i] = 'User ID'              ) or
         ( tkn.Result.Names[i] = 'Initial Catalog'      ) or
         ( tkn.Result.Names[i] = 'Password'             ) or
         ( tkn.Result.Names[i] = 'Data Source'          ) then

        Result := Result + tkn.Result[i] + ';' ;
    end;

    Result := Result + 'MultipleActiveResultSets=True';
  finally
    tkn.Free ;
  end;

end ;

function TfrmLayerSQL.prepareOCI : TStrings ;
var
  str : TStrings ;
begin
  Result := TStringList.Create ;
  str := prepareConnectString( cbConnStr.Text ) ;
  try
    Result.Add( Format( '%s=%s', [ GIS_INI_LAYERSQL_USER,     str.Values['User ID'] ] ) );
    Result.Add( Format( '%s=%s', [ GIS_INI_LAYERSQL_PASSWORD, str.Values['Password'] ] ) );
    Result.Add( Format( '%s=%s', [ GIS_INI_LAYERSQL_DATABASE, str.Values['Data Source'] ] ) );
  finally
    str.Free ;
  end;
end ;

function TfrmLayerSQL.getSQLPath( const _storage  : String ;
                                  const _name     : String ;
                                  const _isRaster : Boolean = False ;
                                  const _isOci    : Boolean = False ;
                                  const _isAdoNet : Boolean = False
                                 ) : String ;
var
  r   : Integer ;
  str : TStrings ;
  cs  : String ;
  cn  : String ;
begin
  if _isOci then begin
    str := prepareConnectString( cbConnStr.Text ) ;

    Result := Format( '[%s]'#13 , [ GIS_INI_LAYER_HEADER ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_STORAGE, _storage ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_DIALECT, cbDialects.Text ] ) +
              Format( '%s=%s'#13, [ 'USER_NAME', str.Values['User ID'] ] ) +
              Format( '%s=%s'#13, [ 'PASSWORD',  str.Values['Password'] ] ) +
              Format( '%s=%s'#13, [ 'DATABASE',  str.Values['Data Source'] ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_LAYER, _name ] ) ;
    str.Free ;
  end
  else begin
    if _isAdoNet then
      cs := prepareADONETCS
    else if rbFileGDB.checked then
      cs := cbConnStr.Text
    else
      cs := cbConnStr.Text ;

    if rbSqlite.checked then
      cn :=  GIS_INI_LAYERSQL_CONNECTOR_SQLITE
    else if _isAdoNet then
      cn := GIS_INI_LAYERSQL_CONNECTOR_ADONET
    else if rbFileGDB.checked or rbOGR.checked then
      cn := GIS_INI_PATH
    else
      cn := GIS_INI_LAYERSQL_CONNECTOR_ADO ;

    Result := Format( '[%s]'#13 , [ GIS_INI_LAYER_HEADER ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_STORAGE, _storage ] ) +
              Format( '%s=%s'#13, [ cn, cs ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_DIALECT, cbDialects.Text ] ) +
              Format( '%s=%s'#13, [ GIS_INI_LAYERSQL_LAYER, _name ] ) ;
  end;

  for r := 0 to memAdditional.Lines.Count - 1 do
    Result := Result + Format( #13'%s=%s'#13, [ memAdditional.Lines.Names[ r ],
                                            memAdditional.Lines.ValueFromIndex[ r ]
                                           ]
                              ) ;
  if _isRaster then
    Result := Result + GIS_TTKPS_EXT
  else
    Result := Result + GIS_TTKLS_EXT ;

  Result := ConstructParamString( Result ) ;
end ;


function TfrmLayerSQL.getLayer( const _name : String ;
                                const _type : Integer
                               ) : TGIS_Layer ;
begin
  case _type of
    LAYERSQL_NATIVE          :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_NATIVE     , _name ) ) ;
    LAYERSQL_OPENGISBLOB     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB, _name ) ) ;
    LAYERSQL_OPENGISBLOB2     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB2, _name ) ) ;
    LAYERSQL_GEOMEDIA        :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIA   , _name ) ) ;
    LAYERSQL_POSTGIS         :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_POSTGIS    , _name ) ) ;
    LAYERSQL_PERSONALGDB     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_PERSONALGDB, _name ) ) ;
    LAYERSQL_SDEBINARY       :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SDEBINARY  , _name ) ) ;
    LAYERSQL_PIXELSTORE2     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_PIXELSTORE2, _name, True ) ) ;
    LAYERSQL_KATMAI          :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_KATMAI     , _name, False, False, True ) ) ;
    LAYERSQL_ORACLESPATIAL   :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL, _name, False, True ) ) ;
    LAYERSQL_SDERASTER       :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SDERASTER, _name, True ) ) ;
    LAYERSQL_ORACLEGEORASTER :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLEGEORASTER, _name, True, True ) ) ;
    LAYERSQL_SPATIALWARE     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SPATIALWARE, _name ) ) ;
    LAYERSQL_DB2GSE     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_DB2GSE, _name ) ) ;
    LAYERSQL_IFXSDB     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_IFXSDB, _name ) ) ;
    LAYERSQL_FGDB     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_FILEGDB, _name ) ) ;
    LAYERSQL_ORACLESPATIALPC     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_PC, _name, False, True ) ) ;
    LAYERSQL_ORACLESPATIALTIN     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN, _name, False, True ) ) ;
    LAYERSQL_GEOMEDIA_MSSQL        :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL, _name, False, False, True ) ) ;
    LAYERSQL_GEOMEDIA_SDO        :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL, _name, False, True ) ) ;
    LAYERSQL_ANYWHERE_SPATIAL     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ANYWHERESPATIAL, _name ) ) ;
    LAYERSQL_OGR     :
      Result := GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OGR, _name ) )
  else
      Result := nil ;
  end;
end ;

procedure TfrmLayerSQL.addNewLayer( const _name : String ;
                                    const _type : Integer
                                   ) ;
var
  ll : TGIS_Layer ;
begin
  ll := getLayer( _name, _type ) ;
  if Assigned( ll ) then begin
    try
      ll.Open ;
      Form1.GIS.Add( ll ) ;
    except
      on e : Exception do begin
        FreeObject( ll ) ;
        ShowMessage( e.Message ) ;
      end ;
    end;
  end ;
end;


procedure TfrmLayerSQL.btnAddLayerClick(Sender: TObject);
var
  tr : TTreeNode;
begin
  tr := treeLayers.Items.GetFirstNode ;
  while Assigned( tr ) do begin
    if tr.Level > 0 then begin
      if tr.Selected then
        AddNewLayer( tr.Text, Integer( tr.Data ) );
    end;

    tr := tr.GetNext ;
  end;
  if Form1.GIS.Items.Count = 1 then
    Form1.GIS.FullExtent
  else
    Form1.GIS.InvalidateWholeMap ;
end;

procedure TfrmLayerSQL.btnBuildClick(Sender: TObject);
begin
  cbConnStr.Text := PromptDataSource(Handle, cbConnStr.Text);

  if Pos( 'SQLOLEDB', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_MSSQL )
  else if Pos( 'SQLNCLI', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_MSSQL )
  else if Pos( 'MSDAORA', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_ORACLE )
  else if Pos( 'ORACLE', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_ORACLE )
  else if Pos( 'POSTGRES', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_POSTGRESQL )
  else if Pos( 'ACE', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_MSJET )
  else if Pos( 'JET', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_MSJET )
  else if Pos( 'MS ACCESS', UpperCase(cbConnStr.Text) ) >= 1 then
    cbDialects.ItemIndex := cbDialects.Items.IndexOf( GIS_SQL_DIALECT_NAME_MSJET ) ;

  cbDialectsChange(self);
end;


procedure TfrmLayerSQL.btnCancelClick(Sender: TObject);
begin
  Close ;
end;

procedure TfrmLayerSQL.btnConnectClick(Sender: TObject);
var
  ls    : TGIS_LayerInfoList ;
  lv    : TGIS_LayerVectorSqlAbstract ;
  lp    : TGIS_LayerPixelSqlAbstract  ;
  lname : String ;
  lf    : TGIS_LayerFGDB ;
  lo    : TGIS_LayerOGR ;

  function canUseStorage( const _type : String ) : Boolean ;
  begin
    Result := True ;

    if ( cbStorage.Text = '' ) or ( cbStorage.Text = '*' ) then exit ;

    Result := Uppercase( cbStorage.Text ) = UpperCase( _type ) ;
  end ;

  function canUseDialect( const _type : String ) : Boolean ;
  begin
    Result := Uppercase( cbDialects.Text ) = UpperCase( _type ) ;
  end ;

begin
  if ( cbConnStr.Text = '' ) or ( cbDialects.Text = '' ) then begin
    ShowMessage( 'Fill database parameters first.' ) ;
    exit ;
  end ;

  lname := 'test';
  treeLayers.Items.Clear;
  memAdditional.Lines.Clear ;

  if canUseStorage( GIS_INI_LAYERSQL_NATIVE ) then begin
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_NATIVE, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Native', ls, LAYERSQL_NATIVE );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_OPENGISBLOB ) then begin
    // OpenGIS
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'OpenGIS', ls, LAYERSQL_OPENGISBLOB );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end
  else if canUseStorage( GIS_INI_LAYERSQL_OPENGISBLOB2  ) then begin
    // OpenGIS
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB2, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'OpenGIS', ls, LAYERSQL_OPENGISBLOB2 );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_PIXELSTORE2 ) then begin
    // PixelStore 2
    lp := TGIS_LayerPixelSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_PIXELSTORE2, lname, True ) )
          ) ;
    if Assigned( lp ) then begin
      try
        ls := lp.GetAvailableLayers ;
        try
          fillTree( 'PixelStore', ls, LAYERSQL_PIXELSTORE2 );
        finally
          ls.free;
        end;
      finally
        lp.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_GEOMEDIA ) and
     (canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL  ) or
      canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) or
      canUseDialect( GIS_SQL_DIALECT_NAME_MSJET  )) then begin
    // Geomedia
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIA, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Geomedia', ls, LAYERSQL_GEOMEDIA );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_PERSONALGDB ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_MSJET ) then begin
    // Personal GDB
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_PERSONALGDB, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Personal GDB', ls, LAYERSQL_PERSONALGDB );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_POSTGIS ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_POSTGRESQL ) then begin
    // PostGIS
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_POSTGIS, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'PostGIS', ls, LAYERSQL_POSTGIS );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if (canUseStorage( GIS_INI_LAYERSQL_SDEBINARY ) or
      canUseStorage( GIS_INI_LAYERSQL_SDEOGCWKB )) and
     (canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL  ) or
      canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )) then begin
    // SDE
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SDEBINARY, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'ArcSDE Vector', ls, LAYERSQL_SDEBINARY );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_SDERASTER ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) then begin
    lp := TGIS_LayerPixelSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SDERASTER, lname, True ) )
          ) ;
    if Assigned( lp ) then begin
      try
        ls := lp.GetAvailableLayers ;
        try
          fillTree( 'ArcSDE Raster', ls, LAYERSQL_SDERASTER );
        finally
          ls.free;
        end;
      finally
        lp.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_KATMAI ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) then begin
    // MsSqlSpatial
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_KATMAI, lname, False, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'MsSql Spatial', ls, LAYERSQL_KATMAI );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_SPATIALWARE ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) then begin
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SPATIALWARE, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'SpatialWare', ls, LAYERSQL_SPATIALWARE );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )
    then begin
    // Oracle Spatial
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL, lname, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Oracle Spatial', ls, LAYERSQL_ORACLESPATIAL );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_ORACLEGEORASTER ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) then begin
    // Oracle Georaster
    lp := TGIS_LayerPixelSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLEGEORASTER, lname, True, True ) )
          ) ;
    if Assigned( lp ) then begin
      try
        ls := lp.GetAvailableLayers ;
        try
          fillTree( 'Oracle Georaster', ls, LAYERSQL_ORACLEGEORASTER );
        finally
          ls.free;
        end;
      finally
        lp.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_DB2GSE ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_DB2 ) then begin
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_DB2GSE, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'DB2 Spatial Extender', ls, LAYERSQL_DB2GSE );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_IFXSDB ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_INFORMIX ) then begin
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_IFXSDB, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'IFX Spatial Data Blade', ls, LAYERSQL_IFXSDB );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_FILEGDB ) and
     canUseDialect( GIS_INI_LAYERSQL_FILEGDB ) then begin
    lf := TGIS_LayerFGDB.Create ;
      try
        lf.Path := cbConnStr.Text ;
        ls := lf.GetAvailableLayers ;
        try
          fillTree( GIS_INI_LAYERSQL_FILEGDB, ls, LAYERSQL_FGDB );
        finally
          ls.free;
        end;
      finally
        lf.free;
      end;
  end ;


  if canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL_PC ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )
    then begin
    // Oracle Spatial
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_PC, lname, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Oracle Spatial PC', ls, LAYERSQL_ORACLESPATIALPC );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )
    then begin
    // Oracle Spatial
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN, lname, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Oracle Spatial TIN', ls, LAYERSQL_ORACLESPATIALTIN );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL ) and
   canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) then begin

    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL, lname, False, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Geomedia MsSpatial', ls, LAYERSQL_GEOMEDIA_MSSQL );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end ;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )
    then begin
    // Oracle Spatial
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL, lname, False, True ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Geomedia Oracle Spatial', ls, LAYERSQL_GEOMEDIA_SDO );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_ANYWHERESPATIAL ) and
     canUseDialect( GIS_SQL_DIALECT_NAME_SYBASE ) then begin
    lv := TGIS_LayerVectorSqlAbstract(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ANYWHERESPATIAL, lname ) )
          ) ;
    if Assigned( lv ) then begin
      try
        ls := lv.GetAvailableLayers ;
        try
          fillTree( 'Anywhere Spatial', ls, LAYERSQL_ANYWHERE_SPATIAL );
        finally
          ls.free;
        end;
      finally
        lv.free;
      end;
    end;
  end ;

  if canUseStorage( GIS_INI_LAYERSQL_OGR ) and
     canUseDialect( GIS_INI_LAYERSQL_OGR ) then begin
    lo := TGIS_LayerOGR.Create ;
      try
        lo.Path := cbConnStr.Text ;
        ls := lo.GetAvailableLayers ;
        try
          fillTree( GIS_INI_LAYERSQL_OGR, ls, LAYERSQL_OGR );
        finally
          ls.free;
        end;
      finally
        lo.free;
      end;
  end ;
end;

function BrowseDialog(const Title: string; const Flag: integer): string;
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  Result:='';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  with BrowseInfo do begin
    hwndOwner := Application.Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    ulFlags := Flag;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;

procedure TfrmLayerSQL.btnPathClick(Sender: TObject);
var
  path : String ;
begin
  if rbFileGDB.Checked then begin
    path := BrowseDialog( 'Select folder', BIF_RETURNONLYFSDIRS ) ;
    if path <> '' then
      cbConnStr.Text := path ;
  end
  else begin
    if not OpenDialog1.Execute then
      exit ;

    cbConnStr.Text := OpenDialog1.FileName ;
  end ;
end;

procedure TfrmLayerSQL.btnSaveFileClick(Sender: TObject);
var
  layername     : String   ;
  ttklspath     : String   ;
  storage       : String ;
  ini           : TGIS_Config ;
  p             : Integer ;
  str           : TStrings ;
  lt            : Integer ;
  isttkps       : Boolean ;
begin
  if not Assigned( treeLayers.Selected ) or ( treeLayers.Selected.Level = 0 ) then begin
    ShowMessage( 'Select a layer from the list first.' ) ;
    exit ;
  end ;

  lt := Integer( treeLayers.Selected.Data ) ;
  isttkps := ( lt = LAYERSQL_PIXELSTORE2 ) or ( lt = LAYERSQL_SDERASTER ) or
             ( lt = LAYERSQL_ORACLEGEORASTER ) ;

  if isttkps then
    SaveDialog1.FilterIndex := 2
  else
    SaveDialog1.FilterIndex := 1 ;

  if SaveDialog1.Execute then begin

    ttklspath := SaveDialog1.FileName ;

    layername := treeLayers.Selected.Text ;

    case lt of
      LAYERSQL_NATIVE           : storage := GIS_INI_LAYERSQL_NATIVE ;
      LAYERSQL_OPENGISBLOB      : storage := GIS_INI_LAYERSQL_OPENGISBLOB ;
      LAYERSQL_OPENGISBLOB2     : storage := GIS_INI_LAYERSQL_OPENGISBLOB2 ;
      LAYERSQL_GEOMEDIA         : storage := GIS_INI_LAYERSQL_GEOMEDIA ;
      LAYERSQL_POSTGIS          : storage := GIS_INI_LAYERSQL_POSTGIS ;
      LAYERSQL_PERSONALGDB      : storage := GIS_INI_LAYERSQL_PERSONALGDB ;
      LAYERSQL_SDEBINARY        : storage := GIS_INI_LAYERSQL_SDEBINARY ;
      LAYERSQL_PIXELSTORE2      : storage := GIS_INI_LAYERSQL_PIXELSTORE2 ;
      LAYERSQL_KATMAI           : storage := GIS_INI_LAYERSQL_KATMAI ;
      LAYERSQL_ORACLESPATIAL    : storage := GIS_INI_LAYERSQL_ORACLESPATIAL ;
      LAYERSQL_SDERASTER        : storage := GIS_INI_LAYERSQL_SDERASTER ;
      LAYERSQL_ORACLEGEORASTER  : storage := GIS_INI_LAYERSQL_ORACLEGEORASTER ;
      LAYERSQL_SPATIALWARE      : storage := GIS_INI_LAYERSQL_SPATIALWARE ;
      LAYERSQL_DB2GSE           : storage := GIS_INI_LAYERSQL_DB2GSE ;
      LAYERSQL_IFXSDB           : storage := GIS_INI_LAYERSQL_IFXSDB ;
      LAYERSQL_FGDB             : storage := GIS_INI_LAYERSQL_FILEGDB ;
      LAYERSQL_OGR              : storage := GIS_INI_LAYERSQL_OGR ;
      LAYERSQL_ORACLESPATIALPC  : storage := GIS_INI_LAYERSQL_ORACLESPATIAL_PC ;
      LAYERSQL_ORACLESPATIALTIN : storage := GIS_INI_LAYERSQL_ORACLESPATIAL_TIN ;
      LAYERSQL_ANYWHERE_SPATIAL : storage := GIS_INI_LAYERSQL_ANYWHERESPATIAL
    else                          storage := GIS_INI_LAYERSQL_NATIVE ;
    end;

    ini := TGIS_ConfigFactory.CreateConfig( nil, ttklspath ) ;
    try
      ini.Section := GIS_INI_LAYER_HEADER ;
      ini.WriteString( GIS_INI_LAYERSQL_STORAGE,
                       storage,
                       ''
                     ) ;
      ini.WriteString( GIS_INI_LAYERSQL_LAYER,
                       layername,
                       ''
                     ) ;
      ini.WriteString( GIS_INI_LAYERSQL_DIALECT,
                       cbDialects.Text,
                       ''
                     ) ;
      if storage = GIS_INI_LAYERSQL_KATMAI then
        ini.WriteString( ini.Section, GIS_INI_LAYERSQL_CONNECTOR_ADONET,
                                 prepareADONETCS
                               )
      else if storage = GIS_INI_LAYERSQL_ORACLESPATIAL then begin
        str := prepareOCI ;
        try
          for p := 0 to str.Count - 1 do
            ini.WriteString( str.Names[ p ], str.ValueFromIndex[ p ], '' ) ;
        finally
          str.Free ;
        end;
      end
      else begin
        if rbSqlite.checked then
          ini.WriteString( ini.Section, GIS_INI_LAYERSQL_CONNECTOR_SQLITE,
                                  GetPathRelative( GetFilePath( ttklspath ),
                                                   cbConnStr.Text
                                                  )
                                )
        else if rbFileGDB.checked or rbOGR.checked then
          ini.WriteString( ini.Section, GIS_INI_PATH,
                                  GetPathRelative( GetFilePath( ttklspath ),
                                                   cbConnStr.Text
                                                  )
                                )
        else
          ini.WriteString( ini.Section, GIS_INI_LAYERSQL_CONNECTOR_ADO,
                                  cbConnStr.Text
                                ) ;
      end ;

      for p := 0 to memAdditional.Lines.Count - 1 do
        ini.WriteString( memAdditional.Lines.Names[ p ],
                         memAdditional.Lines.ValueFromIndex[ p ], '' ) ;

    finally
      ini.Save ;
      FreeObject( ini ) ;
    end ;
  end ;

end;

procedure TfrmLayerSQL.cbConnStrChange(Sender: TObject);
var
  i : Integer ;
begin
  i := cbConnStr.ItemIndex ;

  if i < 0 then exit ;

  cbConnStr.Hint := cbConnStr.Items[ cbConnStr.ItemIndex ] ;
end;

procedure TfrmLayerSQL.cbConnStrKeyPress(Sender: TObject; var Key: Char);
begin
  if CharInSet( Key, [#8, '0'..'9', 'a'..'z' ] ) then
    cbConnStr.Hint := '' ;
end;

procedure TfrmLayerSQL.cbDialectsChange(Sender: TObject);
begin
  cbStorage.Items.Clear ;

  if cbDialects.Text = GIS_SQL_DIALECT_NAME_FGDB then
    cbStorage.Items.Add( GIS_INI_LAYERSQL_FILEGDB             )
  else if cbDialects.Text = GIS_INI_LAYERSQL_OGR then
    cbStorage.Items.Add( GIS_INI_LAYERSQL_OGR                 )
  else begin
    cbStorage.Items.Add( '*'                                  ) ;
    cbStorage.Items.Add( GIS_INI_LAYERSQL_NATIVE              ) ;
    cbStorage.Items.Add( GIS_INI_LAYERSQL_OPENGISBLOB         ) ;
    cbStorage.Items.Add( GIS_INI_LAYERSQL_OPENGISBLOB2        ) ;
    cbStorage.Items.Add( GIS_INI_LAYERSQL_PIXELSTORE2         ) ;

    if cbDialects.Text = GIS_SQL_DIALECT_NAME_ORACLE then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLEGEORASTER     ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL       ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL_PC    ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN   ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_SDEBINARY           ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_SDERASTER           ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_POSTGRESQL then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_POSTGIS             ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_MSSQL then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIA            ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL   ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_KATMAI              ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_SDEBINARY           ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_SDERASTER           ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_SPATIALWARE         ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_DB2 then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_DB2GSE              ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_INFORMIX then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_IFXSDB              ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_SYBASE then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_ANYWHERESPATIAL     ) ;
    end
    else if cbDialects.Text = GIS_SQL_DIALECT_NAME_MSJET then begin
      cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIA            ) ;
      cbStorage.Items.Add( GIS_INI_LAYERSQL_PERSONALGDB         ) ;
    end ;
  end;

  cbStorage.ItemIndex := 0 ;
end;

procedure TfrmLayerSQL.FormCreate(Sender: TObject);
begin
  cbDialects.Items.Clear;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_ADVANTAGE    ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_BLACKFISHSQL ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_DB2          ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_FGDB         ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_INFORMIX     ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_INTERBASE    ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_MSJET        ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_MSSQL        ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_MYSQL        ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_NEXUSDB      ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_ORACLE       ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_POSTGRESQL   ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_SAPDB        ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_SQLITE       ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_SYBASE       ) ;
  cbDialects.Items.Add( GIS_SQL_DIALECT_NAME_INTERSYSTEMS ) ;
  cbDialects.Items.Add( GIS_INI_LAYERSQL_OGR              ) ;

  cbStorage.Items.Clear ;
  cbStorage.Items.Add( '*'                                    ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_ANYWHERESPATIAL       ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_DB2GSE                ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_FILEGDB               ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIA              ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL     ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_IFXSDB                ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_KATMAI                ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_NATIVE                ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_OPENGISBLOB           ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_OPENGISBLOB2          ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLEGEORASTER       ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL         ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL_PC      ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN     ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_PERSONALGDB           ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_PIXELSTORE2           ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_POSTGIS               ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_SDEBINARY             ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_SDERASTER             ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_SPATIALWARE           ) ;
  cbStorage.Items.Add( GIS_INI_LAYERSQL_OGR                   ) ;

  cbStorage.ItemIndex := 0 ;

  cbConnStr.Text    := '' ;

  memAdditional.Clear ;
  treeLayers.Items.Clear ;

  btnAddLayer.Enabled := False ;
  btnSaveFile.Enabled := False ;


  if cbConnStr.Items.Count > 0 then begin
    cbConnStr.ItemIndex := 0 ;
    cbConnStrChange( Self ) ;
  end ;
end;

procedure TfrmLayerSQL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
     ModalResult := mrCancel ;
end;

end.
