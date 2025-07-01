// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// =============================================================================
{
  How to prepare small coverage previewer.
  Main window.
}
unit MainForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  System.Types,

  Winapi.Windows,
  Winapi.ShlObj,

  Vcl.Forms,
  Vcl.Printers,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.StdCtrls,

  //GisLicense,

  GisEditor,
  GisLayer,
  GisLayerPixel,
  GisLayerVector,
  GisPixelExportManager,
  GisRegistredLayers,
  GisUtils,
  GisTypes,
  GisTypesUI,
  GisViewer,
  GisLegend,

  Vcl.GisControlAttributes,
  GisRendererAbstract,
  Vcl.GisControlLegend,
  Vcl.GisControlScale,
  Vcl.GisViewerBmp,
  Vcl.GisViewerWnd,
  GisControlPrintPreviewSimple;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    tmrCreated: TTimer;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileOpen: TMenuItem;
    dlgFileOpen: TOpenDialog;
    dlgFileSave: TSaveDialog;
    mnuExportLayer: TMenuItem;
    mnuFilePrint: TMenuItem;
    N1: TMenuItem;
    mnuFileExit: TMenuItem;
    ActionList1: TActionList;
    actFileOpen: TAction;
    actFileExport: TAction;
    actFilePrint: TAction;
    actFileExit: TAction;
    actViewFullExtent: TAction;
    actViewZoomMode: TAction;
    actViewDragMode: TAction;
    actViewSelectMode: TAction;
    mnuView: TMenuItem;
    actFullExtent1: TMenuItem;
    N2: TMenuItem;
    mnuZoomMode: TMenuItem;
    mnutDragMode: TMenuItem;
    mnuSlectMode: TMenuItem;
    ToolBar2: TToolBar;
    btnViewFullExtent: TToolButton;
    btnViewZoomMode: TToolButton;
    btnViewDragMode: TToolButton;
    btnViewSelectMode: TToolButton;
    ToolButton6: TToolButton;
    ImageList1: TImageList;
    stsBar: TStatusBar;
    actFile: TAction;
    actView: TAction;
    GIS_ControlLegend: TGIS_ControlLegend;
    Splitter1: TSplitter;
    Options1: TMenuItem;
    ColorDialog1: TColorDialog;
    Color1: TMenuItem;
    btnAppend: TToolButton;
    dlgFileAppend: TOpenDialog;
    Add1: TMenuItem;
    actAdd: TAction;
    Search1: TMenuItem;
    btnSearch: TToolButton;
    actSearch: TAction;
    Findshape1: TMenuItem;
    btnClose: TToolButton;
    actClose: TAction;
    Close1: TMenuItem;
    ToolButton1: TToolButton;
    actEditFile: TAction;
    actEditFile1: TMenuItem;
    actSaveToImage: TAction;
    dlgSaveImage: TSaveDialog;
    btnSaveAll: TToolButton;
    actSaveAll: TAction;
    UseRTree1: TMenuItem;
    ToolButton3: TToolButton;
    btnChangeMode: TToolButton;
    btnCS: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    GIS_ControlPrintPreviewSimple: TGIS_ControlPrintPreviewSimple;
    actChangeMode: TAction;
    actCS: TAction;
    procedure tmrCreatedTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GISBusy(_sender: TObject; _pos, _end: Integer;
      var _abort: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure dlgFileSaveTypeChange(Sender: TObject);
    procedure actFileOpenExecute(Sender: TObject);
    procedure actFileExportExecute(Sender: TObject);
    procedure actFilePrintExecute(Sender: TObject);
    procedure actFileExitExecute(Sender: TObject);
    procedure actViewZoomModeExecute(Sender: TObject);
    procedure actViewFullExtentExecute(Sender: TObject);
    procedure actViewDragModeExecute(Sender: TObject);
    procedure actViewSelectModeExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actFileExecute(Sender: TObject);
    procedure actViewExecute(Sender: TObject);
    procedure Color1Click(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actEditFileExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure UseRTree1Click(Sender: TObject);
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure actCSExecute(Sender: TObject);
    procedure actChangeModeExecute(Sender: TObject);
    procedure actSaveToImageExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
  private
    { Private declarations }
    procedure OpenCoverage(const _path: String);
    procedure AppendCoverage(const _path: String);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  InfoForm,
  ExportForm,
  EditForm,
  SearchForm,
  GisFunctions,
  GisAllLayers,
  GisInternals,
  GisLayerMIF,
  GisLayerSHP,
  GisLayerDXF,

  Vcl.GisControlCsSystem,
  Vcl.GisPrinters,
  Vcl.GisRendererGdiPlus;

{$R *.DFM}

procedure TfrmMain.OpenCoverage(const _path: String);
var
  i: Integer;
begin
  // clear the viewer
  GIS.Close;
  stsBar.Panels[3].Text := '';

  try
    // open selected file
    GIS.Open(_path);

    mnuExportLayer.Enabled := False;
    for i := 0 to (GIS.Items.Count - 1) do
    begin
      // for layers of TGIS_LayerVector type enable export
      if TGIS_Layer(GIS.Items[i]) is TGIS_LayerVector then
        mnuExportLayer.Enabled := True;
    end;

    stsBar.Panels[3].Text := ExtractFileName(_path);
  except
    // if anything went wrong, show a warning
    on E: Exception do
    begin
      ShowMessage('File can''t be open'#13 + E.Message);
      GIS.Close;
      GIS_ControlLegend.Update;
    end;
  end;
  GIS.UseRTree := UseRTree1.Checked;
end;

procedure TfrmMain.tmrCreatedTimer(Sender: TObject);
begin
  // for console purposes
  tmrCreated.Enabled := False;
  tmrCreated.OnTimer := nil;
  if ParamStr(1) <> '' then
    OpenCoverage(ParamStr(1));
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  tmrCreated.Enabled := True;
end;

procedure TfrmMain.GISBusy(_sender: TObject; _pos, _end: Integer;
  var _abort: Boolean);
begin
  // show busy state
  if _end <= 0 then
    stsBar.Panels[0].Text := ''
  else
    stsBar.Panels[0].Text := Format('Busy %d%%', [Trunc(_pos / _end * 100)]);
  Application.ProcessMessages;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if DebugHook = 0 then
    Position := poDefault;

  // set File dialogs filters
  dlgFileOpen.Filter := GisSupportedFiles([TGIS_FileType.All], False);
  dlgFileAppend.Filter := GisSupportedFiles([TGIS_FileType.All], False);
  dlgFileSave.Filter := GisSupportedFiles([TGIS_FileType.Pixel], True);
end;

procedure TfrmMain.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp: TGIS_Shape;
begin
  // if there is no layer or we are not in select mode, exit
  if GIS.IsEmpty then
    exit;
  if GIS.InPaint then
    exit;

  if GIS.Mode <> TGIS_ViewerMode.Select then
    exit;
  // let's try to locate a selected shape on the map
  shp := TGIS_Shape(GIS.Locate(GIS.ScreenToMap(Point(X, Y)), 5 / GIS.Zoom));
  if not Assigned(shp) then
    exit;

  shp.Layer.DeselectAll;
  // if any found select it and show shape info
  shp.IsSelected := not shp.IsSelected;
  FrmInfo.ShowInfo(shp);
end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  ptg: TGIS_Point;
begin
  if GIS.IsEmpty then
    exit;

  // let's locate our position on the map and display coordinates, zoom
  ptg := GIS.ScreenToMap(Point(X, Y));
  stsBar.Panels[1].Text := Format('X : %.4f | Y : %.4f', [ptg.X, ptg.Y]);
  stsBar.Panels[2].Text := Format('Zoom : %.4f | ZoomEx : %.4f',
    [GIS.Zoom, GIS.ZoomEx]);
end;

procedure TfrmMain.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
begin
  // here you can make custom drawing
end;

procedure TfrmMain.dlgFileSaveTypeChange(Sender: TObject);
var
  i, j, k: Integer;
begin
  k := 0;
  for i := 1 to Length(dlgFileSave.Filter) - 1 do
  begin
    if (dlgFileSave.Filter[i] = '|') and (dlgFileSave.Filter[i + 1] = '*') then
    begin
      dlgFileSave.DefaultExt := '';
      for j := i + 3 to Length(dlgFileSave.Filter) do
      begin
        if (dlgFileSave.Filter[j] = '|') then
        begin
          Inc(k);
          if k = dlgFileSave.FilterIndex then
            exit
          else
            break;
        end;
        dlgFileSave.DefaultExt := dlgFileSave.DefaultExt +
          dlgFileSave.Filter[j];
      end;
    end;
  end;
end;

procedure TfrmMain.actFileOpenExecute(Sender: TObject);
var
  str, ext: String;
begin
  if not dlgFileOpen.Execute then
    exit;

  str := dlgFileOpen.FileName;
  ext := ExtractFileExt(str);
  // if project selected, load it to editor
  if (CompareText(ext, '.ttkproject') = 0) or (CompareText(ext, '.ttkgp') = 0)
    or (CompareText(ext, '.ttkls') = 0) then
  begin
    fEdit.StatusBar1.Panels[1].Text := str;
    fEdit.Editor.Enabled := True;
    fEdit.Editor.Lines.Clear;
    fEdit.Editor.Lines.LoadFromFile(str);
    fEdit.btnSave.Enabled := False;
  end
  else
    // if config found, load it to editor
    if FileExists(str + '.ini') then
    begin
      fEdit.StatusBar1.Panels[1].Text := str + '.ini';
      fEdit.Editor.Enabled := True;
      fEdit.Editor.Lines.Clear;
      fEdit.Editor.Lines.LoadFromFile(str + '.ini');
      fEdit.btnSave.Enabled := False;
    end
    else
    begin
      fEdit.Editor.Enabled := False;
      fEdit.StatusBar1.Panels[1].Text := '';
      fEdit.Editor.Lines.Clear;
      fEdit.btnSave.Enabled := False;
    end;
  // check file extension
  case dlgFileOpen.FilterIndex of
    8:
      str := str + '?ARC';
    9:
      str := str + '?PAL';
    10:
      str := str + '?LAB';
  end;
  // open selected file
  OpenCoverage(str);
end;

procedure TfrmMain.actFileExportExecute(Sender: TObject);
var
  ll: TGIS_LayerVector;
  extent: TGIS_Extent;
  shape_type: TGIS_ShapeType;
  clipping: Boolean;
  ext: String;
begin
  if frmExportLayer.ShowModal = mrCancel then
    exit;

  dlgFileSaveTypeChange(Self);
  dlgFileSave.FileName := '';
  if not dlgFileSave.Execute then
    exit;

  // check the extension to choose a proper layer
  ext := ExtractFileExt(dlgFileSave.FileName);
  if CompareText(ext, '.shp') = 0 then
    ll := TGIS_LayerSHP.Create
  else if CompareText(ext, '.mif') = 0 then
    ll := TGIS_LayerMIF.Create
  else if CompareText(ext, '.dxf') = 0 then
    ll := TGIS_LayerDXF.Create
  else if CompareText(ext, '.ttkls') = 0 then
    ll := TGIS_LayerVector(GisCreateLayer('', dlgFileSave.FileName))
  else
  begin
    ShowMessage('Unrecognized file extension');
    exit;
  end;

  shape_type := TGIS_ShapeType.Unknown;
  extent := TGIS_Utils.GisWholeWorld;
  clipping := False;

  // set the extent
  case frmExportLayer.grpSelectExtent.ItemIndex of
    0:
      begin
        extent := TGIS_Utils.GisWholeWorld;
        clipping := False;
      end;
    1:
      begin
        extent := GIS.VisibleExtent;
        clipping := False;
      end;
    2:
      begin
        extent := GIS.VisibleExtent;
        clipping := True;
      end;
  else
    Assert(False, 'Untested case');
  end;

  // set layer type
  case frmExportLayer.cmbShapeType.ItemIndex of
    0:
      shape_type := TGIS_ShapeType.Unknown;
    1:
      shape_type := TGIS_ShapeType.Arc;
    2:
      shape_type := TGIS_ShapeType.Polygon;
    3:
      shape_type := TGIS_ShapeType.Point;
    4:
      shape_type := TGIS_ShapeType.MultiPoint;
  else
    Assert(False, 'Untested case');
  end;

  try
    // try to import existing layer to a new one and save it to the file
    ll.Path := dlgFileSave.FileName;
    ll.CS := frmExportLayer.CS;
    ll.ImportLayer(TGIS_LayerVector(GIS.Get(frmExportLayer.cmbLayersList.Text)),
      extent, shape_type, frmExportLayer.edtQuery.Text, clipping);
  finally
    ll.Free;
  end;
end;

procedure TfrmMain.actFilePrintExecute(Sender: TObject);
begin
  // let's see a print preview form
  GIS_ControlPrintPreviewSimple.Preview;
end;

procedure TfrmMain.actFileExitExecute(Sender: TObject);
begin
  // close the application
  Application.Terminate;
end;

procedure TfrmMain.actViewFullExtentExecute(Sender: TObject);
begin
  // show the whole world
  GIS.FullExtent;
end;

procedure TfrmMain.actViewZoomModeExecute(Sender: TObject);
begin
  // set zoom mode
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;

procedure TfrmMain.actViewDragModeExecute(Sender: TObject);
begin
  // set drag mode
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

procedure TfrmMain.actViewSelectModeExecute(Sender: TObject);
begin
  // set select mode
  GIS.Mode := TGIS_ViewerMode.Select;
end;

procedure TfrmMain.actCSExecute(Sender: TObject);
var
  dlg: TGIS_ControlCSSystem;
  he: TGIS_HelpEvent;
begin
  dlg := TGIS_ControlCSSystem.Create(Self);
  try
    he := nil;
    if dlg.Execute(GIS.CS, he) = mrOk then
    begin
      GIS.CS := dlg.CS;
    end;
  finally
    dlg.Free;
  end;
end;

procedure TfrmMain.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
var
  notbusy: Boolean;
begin
  // update toolbar controls
  actViewZoomMode.Checked := GIS.Mode = TGIS_ViewerMode.Zoom;
  actViewDragMode.Checked := GIS.Mode = TGIS_ViewerMode.Drag;
  actViewSelectMode.Checked := GIS.Mode = TGIS_ViewerMode.Select;
  actSearch.Checked := FSearch.Visible;

  notbusy := True;
  actFileOpen.Enabled := notbusy;
  actFileExit.Enabled := notbusy;
  actFileExport.Enabled := notbusy and (not GIS.IsEmpty);
  actFilePrint.Enabled := notbusy and (not GIS.IsEmpty);
  actViewFullExtent.Enabled := notbusy and (not GIS.IsEmpty);
  actViewZoomMode.Enabled := notbusy and (not GIS.IsEmpty);
  actViewDragMode.Enabled := notbusy and (not GIS.IsEmpty);
  actViewSelectMode.Enabled := notbusy and (not GIS.IsEmpty);
  actAdd.Enabled := notbusy and (not GIS.IsEmpty);
  actSearch.Enabled := notbusy and (not GIS.IsEmpty);
  actClose.Enabled := notbusy and (not GIS.IsEmpty);
  actEditFile.Enabled := notbusy and (not GIS.IsEmpty) and
    (fEdit.StatusBar1.Panels[1].Text <> '');
  actSaveToImage.Enabled := notbusy and (not GIS.IsEmpty);
  actSaveAll.Enabled := notbusy and (GIS.MustSave);
  actChangeMode.Enabled := notbusy and (not GIS.IsEmpty);
  actCS.Enabled := notbusy and (not GIS.IsEmpty);
end;

procedure TfrmMain.actFileExecute(Sender: TObject);
begin
  // do nothing
end;

procedure TfrmMain.actViewExecute(Sender: TObject);
begin
  // do nothing
end;

procedure TfrmMain.Color1Click(Sender: TObject);
begin
  // let's change the viewer color
  if not ColorDialog1.Execute then
    exit;

  GIS.Color := ColorDialog1.Color;
  GIS.InvalidateWholeMap;
end;

procedure TfrmMain.AppendCoverage(const _path: String);
var
  ll: TGIS_Layer;
begin
  stsBar.Panels[3].Text := '';
  try
    mnuExportLayer.Enabled := False;
    // create a new layer
    ll := GisCreateLayer(ExtractFileName(_path), _path);
    // and add it to the viewer
    if Assigned(ll) then
    begin
      ll.ReadConfig;
      GIS.Add(ll);
      if ll is TGIS_LayerVector then
        mnuExportLayer.Enabled := True;
    end;

    stsBar.Panels[3].Text := stsBar.Panels[3].Text +
      ExtractFileName(_path) + ' ';
  except
    on E: Exception do
      ShowMessage('File can''t be open'#13 + E.Message);
  end;
  GIS.UseRTree := UseRTree1.Checked;
  GIS.InvalidateWholeMap;
end;

procedure TfrmMain.actSearchExecute(Sender: TObject);
begin
  // show search form
  FSearch.Show;
end;

procedure TfrmMain.actAddExecute(Sender: TObject);
var
  i: Integer;
  File_name: String;
begin
  if not dlgFileAppend.Execute then
    exit;

  for i := 0 to dlgFileAppend.Files.Count - 1 do
  begin
    File_name := dlgFileAppend.Files.Strings[i];
    case dlgFileAppend.FilterIndex of
      8:
        File_name := File_name + '?ARC';
      9:
        File_name := File_name + '?PAL';
      10:
        File_name := File_name + '?LAB';
    end;
    // add all selected files to the viewer
    AppendCoverage(File_name);
  end;
end;

procedure TfrmMain.actChangeModeExecute(Sender: TObject);
begin
  if GIS_ControlLegend.Mode = TGIS_ControlLegendMode.Layers then
    GIS_ControlLegend.Mode := TGIS_ControlLegendMode.Groups
  else
    GIS_ControlLegend.Mode := TGIS_ControlLegendMode.Layers;
end;

procedure TfrmMain.actCloseExecute(Sender: TObject);
begin
  GIS.Close;
end;

procedure TfrmMain.actEditFileExecute(Sender: TObject);
begin
  fEdit.Show;
end;

procedure TfrmMain.actSaveAllExecute(Sender: TObject);
begin
  GIS.SaveAll;
end;

procedure TfrmMain.actSaveToImageExecute(Sender: TObject);
var
  pem: TGIS_PixelExportManager;
  lp: TGIS_LayerPixel;
  w, h: Integer;
  dpi: Integer;
  sf: TGIS_LayerPixelSubFormat;
  vbmp: TGIS_ViewerBmp;
  Path: String;
  ext: String;
  ex: TGIS_Extent;
  sub: TGIS_PixelSubformat;
  comp: TGIS_CompressionType;
begin
  ex := GIS.extent;

  w := 1024;
  h := Round((ex.YMax - ex.YMin) / (ex.XMax - ex.XMin) * w);
  ex := GisExtent(ex.XMin, ex.YMin, ex.XMax,
    ex.YMin + ((ex.XMax - ex.XMin) / w) * h);

  dpi := 96;
  if not dlgSaveImage.Execute then
    exit;
  Path := dlgSaveImage.FileName;

  case dlgSaveImage.FilterIndex of
    1:
      begin
        ext := '.bmp';
        sub := TGIS_PixelSubformat.BMP;
        comp := TGIS_CompressionType.None;
      end;
    2:
      begin
        ext := '.jpg';
        sub := TGIS_PixelSubformat.JPEG;
        comp := TGIS_CompressionType.JPEG;
      end;
    3:
      begin
        ext := '.png';
        sub := TGIS_PixelSubformat.PNG;
        comp := TGIS_CompressionType.PNG;
      end;
    4:
      begin
        ext := '.tif';
        sub := TGIS_PixelSubformat.None;
        comp := TGIS_CompressionType.None;
      end;
  else
    begin
      ext := '';
      sub := TGIS_PixelSubformat.None;
      comp := TGIS_CompressionType.None;
    end;
  end;

  if GetFileExt(Path) = '' then
    Path := Path + ext;

  lp := GisCreateLayer(Path, Path) as TGIS_LayerPixel;
  try
    sf := TGIS_LayerPixelSubFormat.Create(TGIS_PixelFormat.RGB, False, sub,
      comp, 90);
    lp.Build(lp.Path, False, GIS.CS, ex, w, h, sf);

    pem := TGIS_PixelExportManager.Create(lp);
    try
      pem.BusyEvent := GISBusy;
      vbmp := TGIS_ViewerBmp.Create;
      try
        vbmp.PaintExtraEvent := GIS.PaintExtraEvent;
        pem.ExportFrom(GIS, vbmp, ex, dpi);
      finally
        vbmp.Free;
      end;
    finally
      pem.Free;
    end;
  finally
    lp.SaveData;
    lp.Free;
  end;
end;

procedure TfrmMain.UseRTree1Click(Sender: TObject);
begin
  UseRTree1.Checked := not UseRTree1.Checked;
  GIS.UseRTree := UseRTree1.Checked;
  GIS.InvalidateWholeMap;
end;

end.
