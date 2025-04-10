//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide SQL Layer support.
  Edit gistest.ttkls to provied your database access
  You can use *.ttkls as any other layer (for example open in editor)
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,

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

  GisInternals,
  GisTypesUI,

  Vcl.GisViewerWnd,
  Vcl.GisControlLegend;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    ToolButton2: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    Panel1: TPanel;
    btnBuildLayer: TButton;
    btnAttachTraceLog: TButton;
    btnLogging: TButton;
    btnOpenProject: TButton;
    mmoLog: TMemo;
    btnReadStyles: TButton;
    cbbStyles: TComboBox;
    btnApplyStyle: TButton;
    btnReadProjects: TButton;
    cbbProjects: TComboBox;
    btnGetProject: TButton;
    btnWriteStyles: TButton;
    btnWriteProject: TButton;
    GIS_ControlLegend1: TGIS_ControlLegend;
    btnWriteLayers: TButton;
    grp1: TGroupBox;
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnBuildLayerClick(Sender: TObject);
    procedure btnAttachTraceLogClick(Sender: TObject);
    procedure btnLoggingClick(Sender: TObject);
    procedure btnOpenProjectClick(Sender: TObject);
    procedure btnWriteProjectClick(Sender: TObject);
    procedure btnWriteStylesClick(Sender: TObject);
    procedure btnReadStylesClick(Sender: TObject);
    procedure btnApplyStyleClick(Sender: TObject);
    procedure btnReadProjectsClick(Sender: TObject);
    procedure btnGetProjectClick(Sender: TObject);
    procedure btnWriteLayersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    currDir : String ;
    function getGISTESTPath( const _useLogging : Boolean
                            ) : String ;
  public
    { Public declarations }
    procedure traceLog(const S: string) ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  //GisLicense,
  GisRtl,
  GisTypes,
  GisLayerVector,
  GisLayerSHP,
  GisLayerSqlSqlite,
  GisLayer,
  GisUtils,
  GisParams,
  GisInterfaces,
  GisConfig,
  GisClasses,
  GisResource,
  GisLayerVectorSql ;


procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnOpenProjectClick(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  currDir := GetPathDirSep( GetFilePath( Application.ExeName ) ) ;
end;

function TForm1.getGISTESTPath( const _useLogging : Boolean ) : String;
var
  str : String ;
begin
  if _useLogging then
    str := '\nLogging=True\n'
  else
    str := '' ;
  Result := Format( '[TatukGIS Layer]\n' +
                    'Storage=Native\n' +
                    'LAYER=GISTEST\n' +
                    'DIALECT=SQLITE\n' +
                    'Sqlite=%sgistest.sqlite\n' +
                    'ENGINEOPTIONS=16%s\n.ttkls',
                    [currDir, str]
                   ) ;
end;

procedure TForm1.traceLog(const S: string);
begin
  mmoLog.Lines.Add( S ) ;
end;

procedure TForm1.btnWriteProjectClick(Sender: TObject);
var
  lv   : TGIS_LayerVectorSqlAbstract ;
  lst  : TStrings ;
  i    : Integer ;
  la   : TGIS_Layer ;
  cfg  : TGIS_Config ;
begin
  if GIS.IsEmpty then exit ;

  lst := TStringList.Create ;
  try
    for i := 0 to GIS.Items.Count-1 do begin
      la := TGIS_Layer( GIS.Items[i] ) ;
      la.Path := Format( '[TatukGIS Layer]\\nStorage=Native\\n' +
                         'Sqlite=<#PATH#>gistest.sqlite\\n'+
                         'Dialect=SQLITE\\nLayer=%s\\nStyle=%s\\n.ttkls',
                         [ TGIS_Utils.GisCanonicalSQLName( la.Name ), TGIS_utils.GisCanonicalSQLName( la.Name ) ]
                        ) ;
    end ;
    cfg := TGIS_ConfigFactory.CreateConfig( nil, 'test.ttkproject' ) ;
    try
      GIS.SaveProjectAsEx( cfg, '' ) ;
      cfg.GetStrings( lst );
    finally
      FreeObject( cfg ) ;
    end;

    lv := TGIS_LayerSqlSqlite.Create ;
    lv.Path :=  getGISTESTPath( False ) ;
    GIS.Add( lv ) ;
    lv.CreateProjectTable ;
    lv.WriteProject( 'POLAND', 'Map of Poland', lst.Text ) ;
  finally
    FreeObject( lst ) ;
  end;

end;


procedure TForm1.btnWriteStylesClick(Sender: TObject);
var
  lv  : TGIS_LayerVectorSqlAbstract ;
  lst : TStrings ;
  la  : TGIS_LayerAbstract ;
  lp  : TGIS_Layer ;
begin
  if GIS.IsEmpty then exit ;

  lv := TGIS_LayerVectorSqlAbstract( GIS.Get('GISTEST') ) ;
  lv.CreateStyleTable ;

  lst := TStringList.Create ;
  try
    for la in GIS.Items do begin
      lp := TGIS_Layer( la ) ;
      TGIS_Config(GIS.ProjectFile).SetLayer( lp ) ;
      lst.Clear ;
      lp.ParamsList.SaveToStrings( lst ) ;
      lv.WriteStyle( TGIS_Utils.GisCanonicalSQLName( lp.Name ), lp.Caption, lst.Text ) ;
    end;
  finally
    FreeObject( lst ) ;
  end;

end;

procedure TForm1.btnReadStylesClick(Sender: TObject);
var
  lv  : TGIS_LayerVectorSqlAbstract ;
  lst : TStrings ;
begin
  lv := TGIS_LayerVectorSqlAbstract( GIS.Get('GISTEST') ) ;
  if not assigned( lv ) then begin ;
    lv := TGIS_LayerSqlSqlite.Create ;
    lv.Path :=  getGISTESTPath( False ) ;
    GIS.Add( lv ) ;
  end ;

  lst := lv.GetAvailableStyles ;
  try
    cbbStyles.Items.AddStrings( lst ) ;
  finally
    FreeObject( lst ) ;
  end;

end;

procedure TForm1.btnLoggingClick(Sender: TObject);
var
  lsql : TGIS_LayerSqlSqlite ;
  i    : Integer ;
  shp  : TGIS_Shape ;
  logs : TStrings ;
begin
  GIS.Close ;

  lsql := TGIS_LayerSqlSqlite.Create ;
  lsql.Path :=  getGISTESTPath( True ) ;
  lsql.SetCSByEPSG( 4326 ) ;
  lsql.Build( lsql.Path,
              TGIS_Utils.GisExtent( 14, 49, 24, 55),
              TGIS_ShapeType.Point,
              TGIS_DimensionType.XY
             ) ;
  GIS.Add( lsql ) ;
  for i := 1 to 10 do begin
    shp := lsql.CreateShape( TGIS_ShapeType.Point, TGIS_DimensionType.XY ) ;
    shp.AddPart ;
    shp.AddPoint( TGIS_Utils.GisPoint( 14+Random(10),49+Random(6) ) ) ;
  end ;
  GIS.SaveData ;
  GIS.FullExtent ;
  GIS.InvalidateWholeMap ;

  logs := lsql.GetLogs ;
  try
    mmoLog.Lines.AddStrings( logs ) ;
  finally
    FreeObject( logs ) ;
  end;

end;

procedure TForm1.btnWriteLayersClick(Sender: TObject);
var
  i   : Integer ;
  la  : TGIS_LayerVector ;
  lsql : TGIS_LayerSqlSqlite ;
begin
  if GIS.IsEmpty then exit ;

  for i := 0 to GIS.Items.Count-1 do begin
    la := TGIS_LayerVector( GIS.Items[i] ) ;

    lsql := TGIS_LayerSqlSqlite.Create ;
    try
      lsql.Path := Format( '[TatukGIS Layer]\n' +
                           'Storage=Native\n' +
                           'LAYER=%s\n' +
                           'DIALECT=SQLITE\n' +
                           'Sqlite=%sgistest.sqlite\n' +
                           'ENGINEOPTIONS=16\n.ttkls',
                           [ TGIS_Utils.GisCanonicalSQLName( la.Name ), currDir ]
                    ) ;

      lsql.SetCSByEPSG( la.CS.EPSG ) ;
      lsql.ImportLayer( la, la.Extent, TGIS_ShapeType.Unknown, '', False ) ;
    finally
      FreeObject( lsql ) ;
    end;
  end ;

end;

procedure TForm1.btnApplyStyleClick(Sender: TObject);
var
  lv  : TGIS_LayerVectorSqlAbstract ;
begin
  if gis.IsEmpty then exit ;

  lv := TGIS_LayerVectorSqlAbstract( GIS.Get('GISTEST') ) ;
  if not assigned( lv ) then exit ;

  lv.ApplyStyle( lv.ReadStyle( cbbStyles.Items[cbbStyles.ItemIndex] ) ) ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnReadProjectsClick(Sender: TObject);
var
  lv  : TGIS_LayerVectorSqlAbstract ;
  lst : TStrings ;
begin
  lv := TGIS_LayerVectorSqlAbstract( GIS.Get('GISTEST') ) ;
  if not assigned( lv ) then begin ;
    lv := TGIS_LayerSqlSqlite.Create ;
    lv.Path :=  getGISTESTPath( False ) ;
    GIS.Add( lv ) ;
  end ;

  lst := lv.GetAvailableProjects ;
  try
    cbbProjects.Items.AddStrings( lst ) ;
  finally
    FreeObject( lst ) ;
  end;
end;

procedure TForm1.btnGetProjectClick(Sender: TObject);
var
  lv  : TGIS_LayerVectorSqlAbstract ;
  tkn : TStringList ;
  name: String ;
begin
  lv := TGIS_LayerVectorSqlAbstract( GIS.Get('GISTEST') ) ;
  if not assigned( lv ) then exit ;

  tkn := TStringList.Create ;
  try
    tkn.Add( 'PATH=' + ConstructParamString( currDir ) ) ;
    name := cbbProjects.Items[cbbProjects.ItemIndex] ;
    if name = '' then
      name := 'POLAND';
    GIS.OpenEx( lv.GetProject(name+'.ttkproject', tkn), '.ttkproject' ) ;
  finally
    FreeObject( tkn ) ;
  end;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnAttachTraceLogClick(Sender: TObject);
var
  lsql : TGIS_LayerSqlSqlite ;
begin
  GIS.Close ;

  lsql := TGIS_LayerSqlSqlite.Create ;
  lsql.Path := getGISTESTPath( False ) ;
  lsql.SQLExecuteEvent := traceLog ;

  GIS.Add( lsql ) ;
  GIS.FullExtent ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnBuildLayerClick(Sender: TObject);
var
  lsql : TGIS_LayerSqlSqlite ;
begin
  lsql := TGIS_LayerSqlSqlite.Create ;
  try
    lsql.SetCSByEPSG( 4326 ) ;
    lsql.Path := getGISTESTPath( False ) ;
    lsql.Build( lsql.Path, TGIS_Utils.GisExtent( 14, 49, 24, 55),
                TGIS_ShapeType.Point, TGIS_DimensionType.XY
               ) ;
  except
    // layer can exist
  end ;
  GIS.Add( lsql ) ;
  GIS.FullExtent ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
