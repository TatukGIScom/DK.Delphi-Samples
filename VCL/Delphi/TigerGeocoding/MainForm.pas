//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide Geocoding using name standarization
}
unit MainForm;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Contnrs,

  Winapi.Windows,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.Menus,
  Vcl.Clipbrd,

  //GisLicense,
  GisTypes,
  GisAllLayers,
  GisClasses,
  GisCsBase,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisGeocoding,
  GisParams,
  GisShortestPath,
  GisTopology,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlScale,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_ControlScale1: TGIS_ControlScale;
    ToolBar1: TToolBar;
    OpenDialog1: TOpenDialog;
    btnOpen: TButton;
    ProgressBar1: TProgressBar;
    Panel2: TPanel;
    gbxFind: TGroupBox;
    edtAddress: TEdit;
    chkExtended: TCheckBox;
    btnFindFirst: TButton;
    btnFindAll: TButton;
    btnHelp: TButton;
    sgrdMemo: TStringGrid;
    PopupMenu1: TPopupMenu;
    mnuCopy: TMenuItem;
    PopupMenu2: TPopupMenu;
    mnuCopyvalue: TMenuItem;
    btnMatches: TButton;
    btnOpenDefault: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnFindFirstClick(Sender: TObject);
    procedure btnFindAllClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure sgrdMemoSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);

    procedure sgrdMemoDblClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure sgrdMemoContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure mnuCopyvalueClick(Sender: TObject);
    procedure sgrdMemoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnMatchesClick(Sender: TObject);
    procedure btnOpenDefaultClick(Sender: TObject);
  private
    { Private declarations }
    layerSrc : TGIS_LayerVector ;
    layerResult : TGIS_LayerVector ;
    geoObj : TGIS_Geocoding ;
    infoFields : TStrings ;
    fieldNames : TStrings ;
    selectedRow : Integer ;
    popupMenuRow : Integer ;
    state : Integer ;
    doAbort : Boolean ;
    fShown : Boolean ;
    procedure showInfo;
    procedure hideInfo;
    function  parse         ( _findFirst : Boolean ;
                             _extendedScope : Boolean
                            ) : Integer ;
    procedure findAddress   ( _findFirst : Boolean ;
                              _extendedScope : Boolean
                            );
    procedure openCoverage  ( const _path : String )  ;
    procedure OnBusy        ( _sender : TObject ;
                              _pos, _end : Integer ;
                              var _abort : Boolean
                            );
  end;

var
  Form1: TForm1;

implementation

uses HelpForm, InfoForm, MatchesForm;

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  infoFields := TStringList.Create;
  infoFields.Add ( 'STATEFP' ) ;
  infoFields.Add ( 'COUNTYFP' ) ;
  infoFields.Add ( 'SMID' ) ;
  infoFields.Add ( 'FEATCAT' ) ;
  infoFields.Add ( 'MTFCC' ) ;
  fieldNames := TStringList.Create;
  fieldNames.Add ( 'FULLNAME' ) ;
  fieldNames.Add ( 'LFROMADD' ) ;
  fieldNames.Add ( 'LTOADD' ) ;
  fieldNames.Add ( 'RFROMADD' ) ;
  fieldNames.Add ( 'RTOADD' ) ;
  fieldNames.Add ( 'ZIPL'   ) ;
  fieldNames.Add ( 'ZIPR'   ) ;
  selectedRow := -1;
  state := -1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  infoFields.Free ;
  fieldNames.Free ;
  if Assigned ( geoObj ) then
    geoObj.Free;
  if Assigned ( layerSrc ) then
    GIS.Close;
end;

procedure TForm1.openCoverage( const _path : String ) ;
begin
  // for pretty view
  Update();

  // free what it wants to
  hideInfo;
  if Assigned ( layerResult ) then
  begin
    GIS.Delete( layerResult.Name ) ;
    layerResult := nil ;
  end ;
  if Assigned ( geoObj ) then
    //geoObj.Free;
  if Assigned ( layerSrc ) then
    GIS.Close;
  btnFindFirst.Enabled := False ;
  btnFindAll.Enabled := False ;
  btnHelp.Enabled := False ;
  btnMatches.Enabled := False ;

  ProgressBar1.Visible := True;
  GIS.BusyEvent := OnBusy;
  GIS.Lock;
  GIS.Open( _path ) ;
  GIS.BusyEvent := nil;
  ProgressBar1.Visible := False;

  layerSrc := TGIS_LayerVector( GIS.Items[0] ) ;
  if not Assigned( layerSrc ) then exit ;
  if not ( layerSrc is TGIS_LayerVector ) then exit ;
  layerSrc.Params.Line.SmartSize := -1;
  layerSrc.Params.Labels.Field := 'FULLNAME';
  layerSrc.Params.Labels.Alignment := TGIS_LabelAlignment.Follow;
  layerSrc.Params.Labels.Color := TGIS_Color.Black;

  layerSrc.ParamsList.Add();
  layerSrc.Params.Query := 'MTFCC < ''S1400''';
  layerSrc.Params.Line.Width := -2;
  layerSrc.Params.Line.Style :=  TGIS_PenStyle.Solid ;
  layerSrc.UseConfig := False;

  // create route layer
  layerResult := TGIS_LayerVector.Create ;
  layerResult.UseConfig := False ;
  layerResult.Params.Line.Color := TGIS_Color.Red ;
  layerResult.Params.Line.Width := -2 ;
  layerResult.Params.Marker.OutlineWidth := 1 ;
  layerResult.Name := 'RouteDisplay' ;
  layerResult.CS := GIS.CS ;
  GIS.Add( layerResult ) ;

  // create geocod+ing object, set fields for routing
  geoObj := TGIS_Geocoding.Create( layerSrc ) ;
  geoObj.offset := 0.0001  ;
  geoObj.LoadFormulas ( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Geocoding\us_addresses.geo',
                        TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Geocoding\tiger2008.geo' ) ;

//?  GIS.RecalcExtent ;
  GIS.Unlock;
  GIS.FullExtent ;

  GIS_ControlScale1.Visible := True;

  btnFindFirst.Enabled := True ;
  btnFindAll.Enabled := True ;
  btnHelp.Enabled := True ;

  // focus on edit window
  edtAddress.Text := '';
  edtAddress.SetFocus;

  sgrdMemo.Cols[0].Clear;
  sgrdMemo.RowCount := 1;
  sgrdMemo.PopupMenu := nil;
  state := -1;
  selectedRow := -1;
end ;


{ Displays progress during opening file. }
procedure TForm1.OnBusy ( _sender : TObject ; _pos, _end : Integer ; var _abort : Boolean );
begin
  // show progress
  if _pos = 0 then
  begin
    ProgressBar1.Min := 0;
    ProgressBar1.Position := 0;
    ProgressBar1.Max := 100;
    doAbort := False;
  end
  else if _pos = -1 then
  begin
    ProgressBar1.Max := 100;
    ProgressBar1.Position := 100;
  end
  else begin
    if doAbort = True then
      _abort := True
    else begin
      ProgressBar1.Position := _pos;
      ProgressBar1.Max := _end;
    end;
  end;
  Application.ProcessMessages ;

end;

{ Opens a TIGER/Line file. }
procedure TForm1.btnOpenClick(Sender: TObject);
begin
  //open a file
  OpenDialog1.Filter := 'SHP files (*.shp)|*.shp';
  OpenDialog1.FilterIndex := 1;

  if OpenDialog1.Execute then          { Display Open dialog box }
  begin
    openCoverage( OpenDialog1.FileName ) ;
  end;
end;

procedure TForm1.btnFindFirstClick(Sender: TObject);
begin
  findAddress ( True, not chkExtended.Checked );
end;


procedure TForm1.btnFindAllClick(Sender: TObject);
begin
  findAddress ( False, not chkExtended.Checked );
end;

{ Matches the address string and searches geocoding results. }
function TForm1.parse ( _findFirst     : Boolean ;
                        _extendedScope : Boolean ) : Integer ;
var
  resolvedAddresses  : TGIS_ObjectList ;
  resolvedAddresses2 : TGIS_ObjectList ;
begin
  Result := 0 ;

  resolvedAddresses  := nil ;
  resolvedAddresses2 := nil ;

  try
    if geoObj.Match ( edtAddress.Text,
                      resolvedAddresses,
                      resolvedAddresses2 ) then
    begin
      FormMatches.ShowMatches ( resolvedAddresses,
                                resolvedAddresses2 );
      Result := geoObj.ParseEx ( resolvedAddresses,
                                 resolvedAddresses2,
                                 _findFirst,
                                 _extendedScope,
                                 True ) ;
      btnMatches.Enabled := True ;
    end ;
  finally
    if Assigned( resolvedAddresses  ) then
      resolvedAddresses.Free ;
    if Assigned( resolvedAddresses2 ) then
      resolvedAddresses2.Free ;
  end ;

end;


{ Finds address and displays results. }
procedure TForm1.findAddress ( _findFirst : Boolean ;
                               _extendedScope : Boolean
                             );
var
  i ,
  j   : Integer ;
  r   : Integer ;
  shp : TGIS_Shape ;
  s     : String ;
begin
  if not Assigned( geoObj ) then
  begin
    Application.MessageBox('Open a TIGER/Line file.', 'Open Error', 0);
    exit ;
  end;

  layerResult.RevertShapes ;
  hideInfo;
  sgrdMemo.Cols[0].Clear;
  sgrdMemo.RowCount := 1;
  sgrdMemo.PopupMenu := nil;
  state := -1;
  selectedRow := -1;
  btnMatches.Enabled := False ;

  // locate shapes meeting query
  Screen.Cursor := crHourGlass;
  try
    r := parse ( _findFirst, _extendedScope ) -1 ;
  except
    on E : EGIS_Exception do  begin
                                ShowMessage ( 'EGIS exception: ' + E.Message );
                                r := -1;
                              end;
    on E : Exception      do  begin
                                ShowMessage ( 'Exception: ' + E.Message      );
                                r := -1;
                              end;
  end;
  if r < 0 then
  begin
    edtAddress.Text := edtAddress.Text + ' ???';
  end
  else begin
    edtAddress.Text := geoObj.Query[0] ;
    if _findFirst = True then
    begin
      sgrdMemo.ShowHint := False;
      state := 0;
    end
    else begin
      sgrdMemo.ShowHint := True;
      state := 1;
    end;
  end;

  sgrdMemo.Cols[0].BeginUpdate;
  for i:=0 to r do
  begin
    // add found shape to route layer (red color)
    shp := layerSrc.GetShape( geoObj.Uid[i] ) ;
    layerResult.AddShape( shp ) ;

    if i = 0 then
    begin
      layerResult.Extent := shp.Extent ;
    end;

    if _findFirst = True then
    begin
      if i = 0 then
      begin
        for j := 0 to fieldNames.Count-1 do
        begin
          s := shp.GetField ( fieldNames.Strings[j] );
          if j > 0 then
            sgrdMemo.RowCount := sgrdMemo.RowCount + 1;
          sgrdMemo.Cells[0,sgrdMemo.RowCount-1] := fieldNames.Strings[j] + '=' + s;
        end;
      end;
    end
    else begin
      if i > 0 then
        sgrdMemo.RowCount := sgrdMemo.RowCount + 1;
      sgrdMemo.Cells[0,sgrdMemo.RowCount-1] := geoObj.Query[i] ;
    end;

    shp := layerSrc.GetShape( geoObj.UidEx[i] ) ;
    if Assigned( shp ) then
    begin
      layerResult.AddShape( shp ) ;
      if _findFirst = True then
      begin
        if i = 0 then
        begin
          sgrdMemo.RowCount := sgrdMemo.RowCount + 1;
          sgrdMemo.Cells[0,sgrdMemo.RowCount-1] := '---------------------------';
          for j := 0 to fieldNames.Count-1 do
          begin
            s := shp.GetField ( fieldNames.Strings[j] );
            sgrdMemo.RowCount := sgrdMemo.RowCount + 1;
            sgrdMemo.Cells[0,sgrdMemo.RowCount-1] := fieldNames.Strings[j] + '=' + s;
          end;
        end;
      end;
    end;

    // mark address as green squere
    shp := layerResult.CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent );
    shp.AddPart ;
    shp.AddPoint( geoObj.Point[i] ) ;
    shp.Params.Marker.Color := TGIS_Color.Yellow ;
    shp.Unlock ;
  end ;
  sgrdMemo.Cols[0].EndUpdate;

  GIS.Lock ;
  GIS.VisibleExtent := layerResult.Extent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;

  Screen.Cursor := crDefault;
  sgrdMemo.SetFocus;

end;

procedure TForm1.btnHelpClick(Sender: TObject);
begin
  formHelp.Show;
end;

procedure TForm1.sgrdMemoSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  // check if the cell can be selected
  CanSelect := ( ARow < sgrdMemo.Cols[0].Count ) and
               not ( ( sgrdMemo.Cols[0].Count = 1 ) and
               ( sgrdMemo.Cells[ACol,ARow] = '' ) );
  if ( CanSelect = True ) and ( state = 1 ) then
    selectedRow := ARow;
end;

procedure TForm1.sgrdMemoDblClick(Sender: TObject);
begin
  if fShown = False then
    showInfo;
end;

procedure TForm1.sgrdMemoClick(Sender: TObject);
begin
  fShown := False ;
  if FormInfo.Visible = True then
  begin
    showInfo;
    fShown := True ;
  end ;
end ;

{ Displays info in the window. }
procedure TForm1.showInfo;
var
  shp : TGIS_Shape ;
  j   : Integer    ;
begin

  if not Assigned ( layerSrc ) then exit;
  if selectedRow = -1 then exit;

  FormInfo.sgrdInfo.Cols[0].Clear;
  FormInfo.sgrdInfo.Cols[1].Clear;

  // get current shape
  shp := layerSrc.GetShape( geoObj.Uid[selectedRow] ) ;
  GIS.VisibleExtent := shp.Extent  ;

  FormInfo.sgrdInfo.Cells[0,0] := 'Shape Id' ;
  FormInfo.sgrdInfo.Cells[1,0] := IntToStr ( shp.Uid );
  for j := 1 to fieldNames.Count do
  begin
    FormInfo.sgrdInfo.Cells[0,j] := fieldNames.Strings[j-1];
    FormInfo.sgrdInfo.Cells[1,j] := shp.GetField ( fieldNames.Strings[j-1] );
  end;

  // display info in the info window
  shp := layerSrc.GetShape( geoObj.UidEx[selectedRow] ) ;
  if Assigned( shp ) then
  begin
    FormInfo.sgrdInfo.Cells[0,fieldNames.Count+1] := '------------------------';
    FormInfo.sgrdInfo.Cells[1,fieldNames.Count+1] := '------------------------';
    FormInfo.sgrdInfo.Cells[0,fieldNames.Count+2] := 'Shape Id' ;
    FormInfo.sgrdInfo.Cells[1,fieldNames.Count+2] := IntToStr ( shp.Uid );
    for j := 1 to fieldNames.Count do
    begin
      FormInfo.sgrdInfo.Cells[0,fieldNames.Count+2+j]
         := fieldNames.Strings[j-1];
      FormInfo.sgrdInfo.Cells[1,fieldNames.Count+2+j]
         := shp.GetField ( fieldNames.Strings[j-1] );
    end;
    FormInfo.Height := 465;
  end else
    FormInfo.Height := 241;

  GIS.Zoom := 0.7 * GIS.Zoom ;

  //show Info
  if FormInfo.Visible = False then
  begin
    FormInfo.FormStyle := fsStayOnTop ;
    FormInfo.Show
  end else
    FormInfo.Update;

end;

{ Hides the info window. }
procedure TForm1.hideInfo;
begin
  if not Assigned( FormInfo ) then exit ;
  if FormInfo.Visible = True then
    FormInfo.Hide;
end;

procedure TForm1.sgrdMemoContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  // check if menu can be displayed
  if state = 1 then
  begin
    sgrdMemo.PopupMenu := popupMenu1;
    popupMenuRow := Integer(MousePos.Y div sgrdMemo.DefaultRowHeight) + sgrdMemo.TopRow;
    if popupMenuRow > sgrdMemo.Cols[0].Count-1 then
      Handled := True
    else
      Handled := False;
  end
  else if state = 0 then
  begin
    sgrdMemo.PopupMenu := popupMenu2;
    popupMenuRow := Integer(MousePos.Y div sgrdMemo.DefaultRowHeight) + sgrdMemo.TopRow;
    if popupMenuRow > sgrdMemo.Cols[0].Count-1 then
      Handled := True
    else
      Handled := False;
  end
  else
    Handled := True;
end;

{ Writes a field value to the clipboard. }
procedure TForm1.mnuCopyvalueClick(Sender: TObject);
begin
  if state = 0 then
    Clipboard.SetTextBuf(
      PChar(sgrdMemo.Cols[0].Values[sgrdMemo.Cols[0].Names[popupMenuRow]])
    );
end;

{ Writes a row text to the clipboard. }
procedure TForm1.mnuCopyClick(Sender: TObject);
begin
  if state = 1 then
    Clipboard.SetTextBuf(
      PChar(sgrdMemo.Cells[0,popupMenuRow])
    );
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  doAbort := True;
end;

procedure TForm1.btnMatchesClick(Sender: TObject);
begin
  formMatches.Show;
end;

procedure TForm1.btnOpenDefaultClick(Sender: TObject);
begin
  openCoverage( TGIS_Utils.GisSamplesDataDirDownload +
                '\World\Countries\USA\States\California\San Bernardino\TIGER\tl_2008_06071_edges_trunc.shp'
               ) ;
end;

end.


