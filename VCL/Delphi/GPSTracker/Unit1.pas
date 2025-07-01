//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
   TatukGIS sample - How to GPS NMEA Unit
}
unit Unit1;


interface

uses
  System.Classes,
  System.Math,
  System.SyncObjs,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.ActnList,

  //GisLicense,
  GisCSSystems,
  GisEditor,
  GisLayerShp,
  GisLayerVector,
  GisRegistredLayers,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisGps,
  Vcl.GisViewerWnd;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    ToolButton6: TToolButton;
    btnSave: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    btnRecord: TSpeedButton;
    Panel1: TPanel;
    edtPoint: TEdit;
    btnAdd: TButton;
    Panel2: TPanel;
    cbxCom: TComboBox;
    actList: TActionList;
    actAdd: TAction;
    actSave: TAction;
    actRecord: TAction;
    cbxBaud: TComboBox;
    GPS: TGIS_GpsNmea;
    procedure FormCreate(Sender: TObject);
    procedure GPSPosition(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure cbxComChange(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actRecordExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbxBaudChange(Sender: TObject);
    procedure actListUpdate(Action: TBasicAction;
      var Handled: Boolean);
  private
    { Private declarations }
    currShape    : TGIS_Shape ;
    lastPointGps : TGIS_Point ;
    lastPointMap : TGIS_Point ;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;


implementation

uses
  GisAllLayers ;

var
  CriticalSection : TCriticalSection ;

{$R *.DFM}


procedure TfrmMain.FormCreate(Sender: TObject);
var
  i  : Integer ;
  lv : TGIS_LayerVector ;
begin
  cbxCom.ItemIndex := GPS.Com-1 ;

  for i:=0 to cbxBaud.Items.Count - 1 do
  begin
    if StrToInt( cbxBaud.Items[ i ] ) = GPS.BaudRate then
    begin
       cbxBaud.ItemIndex := i ;
       break ;
    end
  end ;
  GPS.Active := True ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\world.shp' ) ;


  GIS.Add( GisCreateLayer( 'routes', 'routes.kml' ) ) ;
  GIS.Add( GisCreateLayer( 'points', 'points.kml' ) ) ;

  lv := TGIS_LayerVector( GIS.Get( 'routes' ) ) ;
  lv.Params.Line.Color := TGIS_Color.Red ;
  try
    lv.AddField( 'Date', TGIS_FieldType.String, 10, 0 ) ;
  except
  end ;

  lv := TGIS_LayerVector( GIS.Get( 'points' ) ) ;
  try
    lv.AddField( 'Name', TGIS_FieldType.String, 10, 0 ) ;
  except
  end ;
  lv := TGIS_LayerVector( GIS.Get( 'points' ) ) ;
  try
    lv.AddField( 'Date', TGIS_FieldType.String, 10, 0 ) ;
  except
  end ;
  lv.Params.Labels.Value :='{Name}<br><i>{date}</i>';

  GPS.Active := True ;
end;

procedure TfrmMain.GPSPosition(Sender: TObject);
var
  ptg   : TGIS_Point ;
  dist  : Double     ;
  prec  : Double     ;
  cs    : TGIS_CSGeographicCoordinateSystem ;
begin
  CriticalSection.Enter ;
  try
    if ( Now - GPS.PositionTime ) < 1/24 then
    begin
      edtPoint.Enabled := True ;
      btnAdd.Enabled := True ;
    end
    else begin
      edtPoint.Enabled := False ;
      btnAdd.Enabled := False ;
    end ;

    // calculate delta of two read-out (in meters)

    cs := CSGeographicCoordinateSystemList.ByEPSG( 4326 ) ;

    ptg  := TGIS_Utils.GisPoint( gps.Longitude, gps.Latitude ) ;
    dist := cs.Datum.Ellipsoid.Distance( ptg, lastPointGps ) ;
    lastPointGps := ptg ;
    lastPointMap := GIS.CS.FromWGS( ptg ) ;

    if not actRecord.Checked then exit ;

    prec := gps.PositionPrec ;
    if prec = 0 then
      prec := 5 ;

    // check if point in tolerance

    if dist < prec then
      exit ;

    if Assigned( currShape ) then
    begin
      currShape.AddPoint( lastPointMap ) ;
      currShape.SetField( 'Date', FormatDateTime( 'yyyy/mm/dd HH:nn.ss', Now ) ) ;
    end ;
    currShape := TGIS_LayerVector( GIS.Get( 'routes') ).CreateShape( TGIS_ShapeType.Arc ) ;
    currShape.AddPart ;
      currShape.AddPoint( lastPointMap ) ;

    GIS.Center := lastPointMap ;
  finally
    CriticalSection.Leave ;
  end ;
end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg      : TGIS_Point ;
  lon, lat : String     ;
begin
  if GIS.IsEmpty then exit ;

  ptg := GIS.CS.ToWGS( GIS.ScreenToMap( Point( x, y ) ) ) ;

  try
    lon := TGIS_Utils.GisLongitudeToStr( ptg.X ) ;
  except
    lon := '???' ;
  end ;

  try
    lat := TGIS_Utils.GisLatitudeToStr( ptg.Y ) ;
  except
    lat := '???' ;
  end ;

  Panel2.Caption := Format( '%s : %s', [ lon, lat ] ) ;
end;

procedure TfrmMain.cbxComChange(Sender: TObject);
begin
  GPS.Com := cbxCom.ItemIndex + 1 ;
  GPS.Active := True ;
end;

procedure TfrmMain.actAddExecute(Sender: TObject);
var
  shp  : TGIS_Shape ;
begin
  CriticalSection.Enter ;
  try
    shp := TGIS_LayerVector( GIS.Get('points')  ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.AddPart ;
    shp.AddPoint( lastPointMap ) ;
    shp.SetField( 'Name', edtPoint.Text ) ;
    shp.SetField( 'Date', FormatDateTime( 'yyyy/mm/dd HH:nn.ss', Now ) ) ;

    GIS.Center := lastPointMap ;
  finally
    CriticalSection.Leave ;
  end ;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  CriticalSection.Enter ;
  try
    if Sender <> btnSave then
    begin
      btnSave.Down := True ;
      Application.ProcessMessages ;
    end ;

    if Assigned( currShape ) then
    begin
      currShape.AddPoint( lastPointMap ) ;
      currShape := nil ;
    end ;

    GIS.SaveAll ;

    if Sender <> btnSave then
    begin
      btnSave.Down := False ;
      Application.ProcessMessages ;
    end ;
  finally
    CriticalSection.Leave ;
  end ;

end;

procedure TfrmMain.actRecordExecute(Sender: TObject);
begin
  actRecord.Checked := not actRecord.Checked ;

  if not actRecord.Checked then
  begin
    // make recording incative
    currShape := nil ;
  end ;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  GIS.Editor.EndEdit ;
  if not GIS.MustSave then exit ;

  if Application.MessageBox( 'Save all unsaved work?',
                             'TatukGIS', MB_YESNO) = IDYES
  then
    GIS.SaveAll ;
end;

procedure TfrmMain.cbxBaudChange(Sender: TObject);
begin
  GPS.BaudRate := StrToInt( cbxBaud.Items[ cbxBaud.ItemIndex ] ) ;
  GPS.Active := True ;
end;

procedure TfrmMain.actListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  btnRecord.Down := actRecord.Checked ;
end;

initialization
  CriticalSection := TCriticalSection.Create ;

finalization
  CriticalSection.Free ;

end.

