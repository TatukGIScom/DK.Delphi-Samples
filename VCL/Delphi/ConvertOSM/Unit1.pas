//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  Convert OSM to other formats : SHP, SQL Native
}
unit Unit1;

interface

uses

  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisTypesUI,

  Vcl.GisViewerBmp ;

type
  TForm1 = class(TForm)
    grpTTKLS: TGroupBox;
    btnOSM: TButton;
    edtOSMPath: TEdit;
    grp1: TGroupBox;
    btnSelectFolder: TButton;
    edExportDir: TEdit;
    grp2: TGroupBox;
    cbep: TCheckBox;
    cbel: TCheckBox;
    cbepp: TCheckBox;
    rgLayerFormat: TRadioGroup;
    btnConvert: TButton;
    mmolog: TMemo;
    dlgOpenOSM: TOpenDialog;
    stat1: TStatusBar;
    procedure btnOSMClick(Sender: TObject);
    procedure btnSelectFolderClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
  private
    { Private declarations }
    vwr   : TGIS_ViewerBmp ;
  public
    { Public declarations }
    procedure doLog     ( const _txt : String )  ;
    procedure convertOSM( const _osmPath    : String ;
                          const _exportPath : String ;
                          const _ltype      : Integer
                        ) ;
    procedure doBusy    (       _sender    : TObject ;
                                _pos, _end : Integer ;
                          var   _abort     : Boolean
                        ) ;
  end ;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  ShlObj,

  GisLayerOSM,
  GisLayerSHP,
  GisLayerSqlAdo,
  GisLayerVector,
  GisInternals,
  GisLayerSqlSqlite ;

function createLayer(
  _ltype : Integer;
    var _ext   : String
 ) : TGIS_LayerVector ;
begin
    case _ltype of
      0 : begin
            Result := TGIS_LayerSHP.Create ;
            _ext := '.shp' ;
          end ;
      1 : begin
            Result := TGIS_LayerSqlAdo.Create ;
            _ext := '.ttkls' ;
          end ;
      2 : begin
            Result := TGIS_LayerSqlSqlite.Create ;
            _ext := '.ttkls' ;
          end
     else begin
            Result := TGIS_LayerSHP.Create ;
            _ext := '.shp' ;
          end ;
    end ;
end ;

function BrowseDialog(
  const Title : String;
  const Flag  : Integer
) : String;
var
  lpItemID    : PItemIDList;
  BrowseInfo  : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath    : array[0..MAX_PATH] of char;
begin
  Result:='';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  with BrowseInfo do begin
    hwndOwner := Application.Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    ulFlags := Flag;
  end ;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := TempPath;
    GlobalFreePtr(lpItemID);
  end ;
end ;

procedure TForm1.doBusy(
      _sender    : TObject ;
      _pos, _end : Integer ;
  var _abort     : Boolean
);
begin
  // show busy state
  if _end <= 0 then
    stat1.SimpleText := ''
  else
    stat1.SimpleText := Format( '%s %d%%', [ vwr.BusyText, Trunc( _pos / _end * 100 ) ] ) ;

  Application.ProcessMessages ;
  _abort := False ;
end ;

procedure TForm1.doLog( const _txt : String ) ;
begin
  mmolog.Lines.Add( _txt ) ;
  Application.ProcessMessages ;
end ;

procedure TForm1.convertOSM(
  const _osmPath    : String ;
  const _exportPath : String ;
  const _ltype      : Integer
) ;
var
  imp   : TGIS_OSMImporter ;
  lp    : TGIS_LayerVector ;
  fname : String ;
  ext   : String ;
begin
  vwr := TGIS_ViewerBmp.Create ;
  try
    vwr.BusyEvent := doBusy ;
    imp := TGIS_OSMImporter.Create( vwr ) ;
    try
      imp.ImportLogEvent := doLog ;
      imp.ImportOSMFile( _osmPath ) ;

      fname := GetFileName( _osmPath ) ;

      if cbep.Checked then begin
          lp := createLayer( _ltype, ext ) ;
          try
            lp.Path := _exportPath + '\' + fname + '_pt' + ext ;
            lp.Name := fname + '_pt';
            lp.ConfigName := lp.Path ;
            lp.UseConfig := True ;
            imp.ExportOsmPoints( lp ) ;
            lp.ParamsList.SaveToFile( lp.ConfigName ) ;
          finally
            lp.free ;
          end ;
      end ;

      if cbel.Checked then begin
          lp := createLayer( _ltype, ext ) ;
          try
            lp.Path := _exportPath + '\' + fname + '_l' + ext ;
            lp.Name := fname + '_l';
            lp.ConfigName := lp.Path ;
            lp.UseConfig := True ;
            imp.ExportOsmLines( lp ) ;
            lp.ParamsList.SaveToFile( lp.ConfigName ) ;
          finally
            lp.free ;
          end ;
      end ;

      if cbepp.Checked then begin
          lp := createLayer( _ltype, ext ) ;
          try
            lp.Path := _exportPath + '\' + fname + '_p' + ext ;
            lp.Name := fname + '_p' ;
            lp.ConfigName := lp.Path ;
            lp.UseConfig := True ;
            imp.ExportOsmPolygons( lp ) ;
            lp.ParamsList.SaveToFile( lp.ConfigName ) ;
          finally
            lp.free ;
          end ;
      end ;

    finally
      imp.Free ;
    end ;
  finally
    vwr.Free ;
  end ;
end ;

procedure TForm1.btnConvertClick(Sender: TObject);
begin
  btnConvert.Enabled := False ;
  try
    if edtOSMPath.Text = '' then begin
      ShowMessage('Select osm file first');
      exit ;
    end ;

    if edExportDir.Text = '' then begin
      ShowMessage('Select export directory first');
      exit ;
    end ;

    convertOSM( edtOSMPath.Text, edExportDir.Text, rgLayerFormat.ItemIndex ) ;

    ShowMessage('Done');
  finally
    btnConvert.Enabled := True ;
  end;
end ;

procedure TForm1.btnOSMClick(Sender: TObject);
begin
  if dlgOpenOSM.Execute() then
    edtOSMPath.Text := dlgOpenOSM.FileName ;
end ;

procedure TForm1.btnSelectFolderClick(Sender: TObject);
var
  path : String ;
begin
  path := BrowseDialog( 'Select source folder', BIF_RETURNONLYFSDIRS ) ;
  if path = '' then exit ;
  edExportDir.Text := path ;
end ;

end.
