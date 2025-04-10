//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to prepare small coverage previewer.
}

unit Unit1;

interface


uses
  System.IOUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Math,
  System.Actions,
  System.Rtti,
  System.Bindings.Outputs,
  System.Zip,

  Data.DB,
  Data.Bind.EngExt,
  Data.Bind.Components,
  Data.Bind.Grid,
  Data.Bind.DBScope,

  Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid,
  Fmx.Bind.Editors,
  FMX.Grid,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.ActnList,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Ani,
  FMX.Objects,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Layouts,
  FMX.ListBox,
  FMX.TreeView,
  FMX.MultiView,
  FMX.Menus,
  FMX.Effects,
  FMX.Platform,

  //GisLicense,
  GisAllLayers,
  GisCsSystems,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisDataSet,

  FMX.GisControlAttributes,
  FMX.GisViewerWnd,
  FMX.GisControlScale,
  FMX.GisControlNorthArrow,
  FMX.GisControlLegend;


type
  TForm1 = class(TForm)
    ToolBarUp: TToolBar;
    GIS: TGIS_ViewerWnd;
    btnFileOpen: TButton;
    btnClose: TButton;
    btnViewFullExtent: TButton;
    btnViewDragMode: TButton;
    btnViewZoomMode: TButton;
    btnSelect: TButton;
    ToolBarDown: TToolBar;
    btnZoomEx: TButton;
    Panel1: TPanel;
    lstAttrib: TListBox;
    btnHide: TButton;
    StyleBook1: TStyleBook;
    ActionList1: TActionList;
    actFile: TAction;
    actFileOpen: TAction;
    actFileExport: TAction;
    actFilePrint: TAction;
    actFileExit: TAction;
    actViewFullExtent: TAction;
    actViewZoomMode: TAction;
    actViewDragMode: TAction;
    actViewSelectMode: TAction;
    actView: TAction;
    actAdd: TAction;
    actSearch: TAction;
    actClose: TAction;
    actEditFile: TAction;
    actSaveToImage: TAction;
    actSaveAll: TAction;
    MultiView1: TMultiView;
    GIS_ControlLegend1: TGIS_ControlLegend;
    btnMultiView: TSpeedButton;
    GIS_ControlNorthArrow1: TGIS_ControlNorthArrow;
    GIS_ControlScale1: TGIS_ControlScale;
    btnChangeCS: TButton;
    btnHighRes: TButton;
    GIS_DataSet1: TGIS_DataSet;
    btnOpenDS: TButton;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure actFileOpenExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actViewFullExtentExecute(Sender: TObject);
    procedure actViewZoomModeExecute(Sender: TObject);
    procedure actViewDragModeExecute(Sender: TObject);
    procedure actViewSelectModeExecute(Sender: TObject);
    procedure btnZoomExClick(Sender: TObject);
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure btnHideClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GISTapLongEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure btnHighResClick(Sender: TObject);
    procedure btnChangeCSClick(Sender: TObject);
    procedure btnOpenDSClick(Sender: TObject);

  private
    { Private declarations }
    shpObj : TGIS_Shape ;
  public
    { Public declarations }
    procedure ShowInfo( const _shp : TGIS_Shape ) ;
  end;

var
  Form1: TForm1;
  isHide : Boolean ;
  isRotate : Boolean ;

implementation

{$R *.fmx}

{$IFDEF LEVEL_RX101_FMX}
  uses
    FMX.Grid.Style;
{$ENDIF}


procedure TForm1.actCloseExecute(Sender: TObject);
begin
  GIS.Close ;
  Panel1.Visible := False ;
  btnHide.Visible := False ;
end;

procedure DownloadSamples( const _path : String ) ;
var
  r    : TGIS_HttpResponse ;
  strm : TMemoryStream ;
  zip  : TZipFile ;
begin

  if System.IOUtils.TDirectory.Exists( _path, False ) then
    exit ;

  strm := TMemoryStream.Create ;
  try
    r := TGIS_WebUtils.HttpFetch(
           'https://download.tatukgis.com/pub/SampleData/Samples11mini.zip',
           strm,
           nil, False, 0, '', '', '', '', False
         ) ;

    if  r.Status <> GIS_HTTP_OK then begin
      ShowMessage( 'Sample data cannot be downloaded: ' + IntToStr( r.Status ) ) ;
      exit ;
    end
    else begin
      ShowMessage( 'SampleData downloaded' ) ;
    end ;

    strm.Position := 0 ;

    TDirectory.CreateDirectory( _path ) ;
    zip := TZipFile.Create ;
    try
      zip.Open( strm, TZipMode.zmRead );
      zip.ExtractAll( _path + PathDelim ) ;
    finally
      zip.Free ;
    end;
  finally
    strm.Free ;
  end;
end;

procedure TForm1.actFileOpenExecute(Sender: TObject);
var
  path : String ;
begin
  GIS.RotationAngle := 0 ;
  path := '' ;
  {$IF  Defined(WIN32) or Defined(WIN64)}
    path := TDirectory.GetParent( ParamStr(0) )  ;
  {$ELSEIF Defined(MACOS) and not Defined(IOS) }
    path := TDirectory.GetParent( TDirectory.GetParent( ParamStr(0) ) ) ;
  {$ELSEIF Defined(LINUX)}
    path := TDirectory.GetParent( TDirectory.GetParent( ParamStr(0) ) ) ;
  {$ELSEIF Defined(MACOS) and Defined(IOS)}
    path := System.IOUtils.TPath.GetDocumentsPath ;
  {$ELSE ANDROID}
    path := System.IOUtils.TPath.GetDocumentsPath ;
  {$ENDIF}

  path := path + PathDelim + 'SampleData' ;
  DownloadSamples( path ) ;
  GIS.Open( path + PathDelim + 'World/Countries/Poland/DCW/poland.ttkproject' ) ;
end;


procedure TForm1.actViewDragModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
  btnViewDragMode.IsPressed := True ;
end;

procedure TForm1.actViewFullExtentExecute(Sender: TObject);
begin
  GIS.FullExtent ;
  btnViewFullExtent.IsPressed := True ;
end;

procedure TForm1.actViewSelectModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select ;
  btnSelect.IsPressed := True ;
end;

procedure TForm1.actViewZoomModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
  btnViewDragMode.IsPressed := True ;
end;

procedure TForm1.btnZoomExClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.ZoomEx ;
  btnZoomEx.IsPressed := True ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  isHide := False ;
  isRotate := False ;
  GIS.Position.X := 233 ;
  GIS.Position.Y := 44 ;
  Panel1.Visible := False ;
  GIS.FullExtent ;
end;

procedure TForm1.btnOpenDSClick(Sender: TObject);
var
  lv : TGIS_LayerVector ;
begin
  if GIS.IsEmpty then exit ;

  StringGrid1.Visible := True ;
  lv := GIS.Items[0] as  TGIS_LayerVector ;

  GIS_DataSet1.Open( lv, lv.Extent );
end;

procedure TForm1.btnChangeCSClick(Sender: TObject);
var
  wgs84       : TGIS_CSGeographicCoordinateSystem ;
  mercator    : TGIS_CSProjectedCoordinateSystem ;
begin
  wgs84 := CSGeographicCoordinateSystemList.ByEPSG(4326) ;
  mercator := CSProjectedCoordinateSystemList.ByEPSG(3857) ;
  if GIS.CS = wgs84 then
    GIS.CS := mercator
  else if GIS.CS = mercator then
    GIS.CS := wgs84 ;
  GIS.FullExtent ;
end;

procedure TForm1.btnHideClick(Sender: TObject);
begin
  if isHide then
  begin
    Panel1.Visible := True ;
    Panel1.Align := TAlignLayout.Left ;
    btnHide.Text := 'Hide Panel' ;
    GIS.Position.X := 333 ;
    GIS.Position.Y := 44 ;
    isHide := False ;
  end
  else begin
    Panel1.Visible := False ;
    btnHide.Visible := False ;
    isHide := True ;
    GIS.Align := TAlignLayout.Client ;
    GIS.FullExtent ;
  end;
end;

procedure TForm1.ShowInfo( const _shp : TGIS_Shape ) ;
var
  i : Integer ;
  fldName : String ;
  lbGroupHeader : TListBoxGroupHeader;
begin
  // if not found, show nothing
  if _shp = nil then begin
    shpObj   := nil ;
    Caption := 'Shape: nil' ;
  end
  else begin
    Caption := Format( 'Shape: %d', [_shp.Uid ] )  ;
    // display all attributes for selected shape
    lbGroupHeader := TListBoxGroupHeader.Create(lstAttrib) ;
    lstAttrib.Clear ;
    lstAttrib.ItemHeight := 55 ;
    lstAttrib.Items.Add( _shp.Uid.ToString ) ;
    lstAttrib.Items.Add( _shp.Length.ToString );
    lstAttrib.Items.Add( _shp.Area.ToString ) ;
    lbGroupHeader.ItemData.Accessory := TListBoxItemData.TAccessory.aDetail ;
    lstAttrib.ItemByIndex(0).ItemData.Detail := 'GIS_UID' ;
    lstAttrib.ItemByIndex(1).ItemData.Detail := 'GIS_LENGTH' ;
    lstAttrib.ItemByIndex(2).ItemData.Detail := 'GIS_AREA' ;
    for i := 0 to _shp.Layer.Fields.Count - 1 do
    begin
      fldName := _shp.Layer.FieldInfo(i).Name ;
      lstAttrib.Items.Add( _shp.GetField( fldName ) ) ;
      lstAttrib.ItemByIndex( i+3 ).ItemData.Detail := fldName ;
    end;
  end ;
end ;

procedure TForm1.GISTapLongEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  shp : TGIS_Shape ;
  ll  : TGIS_LayerVector;
begin
  if GIS.IsEmpty then
    exit ;
  if GIS.Mode <> TGIS_ViewerMode.Select then
    exit ;
  ll := TGIS_LayerVector(GIS.Items[0]);
  ll.DeselectAll;
  shp := TGIS_Shape( GIS.Locate( GIS.ScreenToMap( Point( Round(X), Round(Y) ) ), 5 / GIS.Zoom ) ) ;

  if not Assigned( shp ) then
    exit ;
  // if any found select it and show shape info
  shp.IsSelected := not shp.IsSelected ;
  ShowInfo( shp ) ;

  if not Panel1.Visible then
  begin
    Panel1.Visible := True ;
    btnHide.Visible := True ;
    isHide := False ;
  end;
end;

procedure TForm1.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton ;
  Shift: TShiftState; X, Y: Single);
var
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then
    exit ;
  if GIS.Mode <> TGIS_ViewerMode.Select then
    exit ;

  // let's try to locate a selected shape on the map
  shp := TGIS_Shape( GIS.Locate( GIS.ScreenToMap( Point( Round(X), Round(Y) ) ), 5 / GIS.Zoom ) ) ;

  if not Assigned( shp ) then exit ;
  // if any found select it
  shp.IsSelected := not shp.IsSelected ;
end;

procedure TForm1.btnHighResClick(Sender: TObject);
begin
  GIS.HiRes := not GIS.HiRes;
end;

end.
