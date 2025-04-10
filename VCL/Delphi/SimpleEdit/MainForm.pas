//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide editing functionality.
}
unit MainForm;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Grids,
  Vcl.ImgList,
  System.ImageList,

  //GisLicense,
  GisClasses,
  GisEditor,
  GisLayer,
  GisLayerPixel,
  GisLayerSHP,
  GisLayerVector,
  GisRendererAbstract,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisEditorTools,
  Vcl.GisViewerWnd;

type
  TfrmMain = class(TForm)
    tlbMain: TToolBar;
    GIS: TGIS_ViewerWnd;
    stsBar: TStatusBar;
    cmbLayer: TComboBox;
    dlgPrint: TPrintDialog;
    mnuPopup: TPopupMenu;
    mnuAddPart: TMenuItem;
    mnuDeletePart: TMenuItem;
    cmbSnap: TComboBox;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    btnSave: TToolButton;
    btnPrint: TToolButton;
    ToolButton2: TToolButton;
    btnFullExtent: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    btnSelect: TToolButton;
    btnEdit: TToolButton;
    ToolButton3: TToolButton;
    btnAddShape: TToolButton;
    ToolButton4: TToolButton;
    btnUndo: TToolButton;
    btnRedo: TToolButton;
    btnRevert: TToolButton;
    btnDelete: TToolButton;
    btnWinding: TToolButton;
    ToolButton5: TToolButton;
    btnShowInfo: TToolButton;
    btnAutoCenter: TToolButton;
    ToolButton6: TToolButton;
    btnNewStyle: TToolButton;
    btnEditorTools: TToolButton;
    N1: TMenuItem;
    Endedit1: TMenuItem;
    ToolButton7: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISEditorChange(Sender: TObject);
    procedure GISKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GISKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSaveClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnAddShapeClick(Sender: TObject);
    procedure btnRedoClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure btnRevertClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnShowInfoClick(Sender: TObject);
    procedure btnAutoCenterClick(Sender: TObject);
    procedure cmbLayerChange(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnWindingClick(Sender: TObject);
    procedure mnuAddPartClick(Sender: TObject);
    procedure mnuDeletePartClick(Sender: TObject);
    procedure cmbSnapChange(Sender: TObject);
    procedure btnNewStyleClick(Sender: TObject);
    procedure GISAfterPaintEvent(Sender: TObject; _canvas: TObject);
    procedure btnEditorToolsClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure Endedit1Click(Sender: TObject);
  private
    { Private declarations }
    vkControl : Boolean ;
    editLayer : TGIS_Layer ;
    menuPos   : TGIS_Point ;
    procedure endEdit ;

  private
    oEditorHelper : TGIS_EditorHelper ;
    procedure doNotifyChanges(Sender: TObject);
    procedure doEditorToolChange(Sender: TObject);
    procedure doNotifyAction(const prompt: String);

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;


implementation

uses
  InfoForm,
  ToolsForm,
  Math;

{$R *.DFM}


procedure TfrmMain.endEdit ;
begin
  btnEdit.Enabled    := False ;
  btnRevert.Enabled  := False ;
  btnDelete.Enabled  := False ;
  btnWinding.Enabled := False ;
  btnEditorTools.Enabled := False ;

  editLayer := nil ;
  oEditorHelper.DoEndEdit ;
  GIS.Editor.EndEdit ;
  GIS.Editor.EditorMode := TGIS_EditorModeEx.Normal ;
  frmEditorTools.cbEditingTool.ItemIndex := 0 ;
  frmEditorTools.cbEditingTool.OnChange( Self ) ;

  if btnShowInfo.Down then
    frmInfo.ShowInfo( nil ) ;
end ;

procedure TfrmMain.Endedit1Click(Sender: TObject);
begin
  endEdit ;
  btnSelectClick( self ) ;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  ll : TGIS_Layer ;
  i  : Integer ;
begin
  stsBar.Panels[3].Text := 'See: www.tatukgis.com' ;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\samples\SimpleEdit\simpleedit.ttkproject' ) ;

  cmbLayer.Items.Add( 'Show all' ) ;
  for i:=0 to GIS.Items.Count - 1 do
  begin
    ll := TGIS_Layer(GIS.Items[i]) ;
    if ll is TGIS_LayerVector then
      cmbLayer.Items.Add( ll.Name ) ;
  end ;

  if GIS.Items.Count > 0 then
    cmbLayer.ItemIndex := 0 ;

  cmbSnap.Items.Add( 'No snapping' ) ;
  for i:=0 to GIS.Items.Count - 1 do
  begin
    ll := TGIS_Layer( GIS.Items[i] ) ;
    if ll is TGIS_LayerVector then
      cmbSnap.Items.Add( ll.Name ) ;
  end ;

  if GIS.Items.Count>0 then
    cmbSnap.ItemIndex := 0 ;

  oEditorHelper := TGIS_EditorHelper.Create( GIS ) ;
  oEditorHelper.NotifyChanges  := doNotifyChanges ;
  oEditorHelper.NotifyAction   := doNotifyAction ;

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  endEdit ;
  btnSelectClick( self ) ;

  if not GIS.MustSave then exit ;

  oEditorHelper.Free ;

  if Application.MessageBox( 'Save all unsaved work ?',
                             'TatukGIS', MB_YESNO) = IDYES
  then
    GIS.SaveAll ;
end ;

procedure TfrmMain.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt   : TPoint ;
  ptg  : TGIS_Point ;
  shp  : TGIS_Shape ;
  ishp : TGIS_Shape ;
  dist : Double ;
  part : Integer ;
  proj : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  ptg := GIS.ScreenToMap( Point( x, y ) ) ;

  case Button of
    mbRight : begin
                if GIS.Mode = TGIS_ViewerMode.Edit then
                begin
                  menuPos := ptg ;
                  pt := self.ClientToScreen( Point( x, y ) ) ;
                  mnuPopUp.PopUp( pt.x, pt.y ) ;
                end ;
              end ;
    mbLeft  : begin
                if GIS.Mode = TGIS_ViewerMode.Edit then
                begin
                  oEditorHelper.DoMouseUp( Point(X, Y) ) ;
                  if editLayer = nil then
                  begin
                    exit ;
                  end
                  else
                  begin
                    GIS.Editor.CreateShape( editLayer, ptg, TGIS_ShapeType.Unknown ) ;
                    if cmbSnap.ItemIndex > 0 then
                      GIS.Editor.SnapLayer := GIS.Get( cmbSnap.Items[ cmbSnap.ItemIndex ] )
                    else
                      GIS.Editor.SnapLayer := nil ;

                    oEditorHelper.DoStartEdit ;
                    GIS.InvalidateEditor(True);

                    if btnShowInfo.Down then
                      frmInfo.ShowInfo( TGIS_Shape( GIS.Editor.CurrentShape ) ) ;
                    editLayer := nil ;
                    btnEditClick( self ) ;
                  end ;
                end
                else if GIS.Mode = TGIS_ViewerMode.Select then
                begin
                  endEdit ;
                  if btnShowInfo.Down then
                   frmInfo.ShowInfo( nil ) ;
                  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom  ) ) ;
                  if shp = nil then exit ;

                  if cmbLayer.ItemIndex <> 0 then
                    if shp.Layer <> GIS.Get( cmbLayer.Items[cmbLayer.ItemIndex] ) then exit ;

                  shp := shp.Layer.LocateEx( ptg, 5/GIS.Zoom, -1, dist, part, proj ) ;
                  if shp <> nil then begin
                    if shp.ShapeType = TGIS_ShapeType.Complex then begin
                      ishp := TGIS_ShapeComplex(shp).Locate( ptg, 5/GIS.Zoom, True, dist ) ;
                      if ishp = nil then exit ;
                      shp.MakeEditable ;
                      GIS.Editor.EditShape( ishp, part ) ;
                    end
                    else
                      GIS.Editor.EditShape( shp, part ) ;

                    oEditorHelper.DoStartEdit ;
                    if cmbSnap.ItemIndex > 0 then
                      GIS.Editor.SnapLayer := GIS.Get( cmbSnap.Items[ cmbSnap.ItemIndex ] )
                    else
                      GIS.Editor.SnapLayer := nil ;

                    GIS.Mode := TGIS_ViewerMode.Edit ;
                    GIS.InvalidateEditor(True);

                    if btnShowInfo.Down then
                      frmInfo.ShowInfo( shp ) ;
                    btnEditClick( self ) ;
                  end
                  else
                    oEditorHelper.DoMouseUp( Point(X, Y) ) ;
                end ;
              end ;
  end ;
end;

procedure TfrmMain.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
begin
  oEditorHelper.Renderer := _renderer ;

  oEditorHelper.DoCanvasPaint
end;

procedure TfrmMain.GISAfterPaintEvent(Sender: TObject; _canvas: TObject);
begin
  stsBar.Panels[0].Text := Format( 'zoom: %.4f', [GIS.ZoomEx] ) ;
end;

procedure TfrmMain.GISEditorChange(Sender: TObject);
begin
  btnUndo.Enabled := GIS.Editor.CanUndo ;
  btnRedo.Enabled := GIS.Editor.CanRedo ;
end;

procedure TfrmMain.GISKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
    if not vkControl then // avoid multiple call on key repeat ;
    begin
      GIS.Mode := TGIS_ViewerMode.Select ;
      vkControl := True ;
    end ;
  if Key = VK_DELETE then
    if GIS.Mode = TGIS_ViewerMode.Edit then
    begin
      GIS.Editor.DeleteShape ;
      GIS.Mode := TGIS_ViewerMode.Select ;
    end ;
end;

procedure TfrmMain.GISKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
  begin
    if btnEdit.Down then
      GIS.Mode := TGIS_ViewerMode.Edit
    else if btnDrag.Down then
      GIS.Mode := TGIS_ViewerMode.Drag ;
    vkControl := False ;
  end ;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  endEdit ;
  btnSelectClick( self ) ;
  GIS.SaveAll ;
end;

procedure TfrmMain.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TfrmMain.btnZoomClick(Sender: TObject);
begin
  endEdit ;
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TfrmMain.btnDragClick(Sender: TObject);
begin
  endEdit ;
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TfrmMain.btnSelectClick(Sender: TObject);
begin
  btnSelect.Down := True ;
  endEdit ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TfrmMain.btnEditClick(Sender: TObject);
begin
  btnEdit.Enabled    := True ;
  btnRevert.Enabled  := True ;
  btnDelete.Enabled  := True ;
  btnWinding.Enabled := True ;
  btnEditorTools.Enabled := True ;

  btnEdit.Down := True ;
  if GIS.Mode = TGIS_ViewerMode.Edit then exit ;
  endEdit ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TfrmMain.btnEditorToolsClick(Sender: TObject);
begin
  frmEditorTools.OnEditorToolChange := doEditorToolChange ;
  if btnEditorTools.Down then
  begin
    frmEditorTools.Left := Self.Left + Self.Width ;
    frmEditorTools.Top  := Self.Top ;
    frmEditorTools.Show ;
  end
  else
    frmEditorTools.Hide ;
end;

procedure TfrmMain.btnAddShapeClick(Sender: TObject);
begin
  endEdit ;
  GIS.Mode  := TGIS_ViewerMode.Edit ;
  editLayer := TGIS_Layer( GIS.Get( cmbLayer.Items[ cmbLayer.ItemIndex ] ) ) ;
end;

procedure TfrmMain.btnRedoClick(Sender: TObject);
begin
  GIS.Editor.Redo ;
  if GIS.AutoCenter then
    GIS.Zoom := GIS.Zoom ;
  oEditorHelper.DoRedo ;
end;

procedure TfrmMain.btnUndoClick(Sender: TObject);
begin
  GIS.Editor.Undo ;
  if GIS.AutoCenter then
    GIS.Zoom := GIS.Zoom ;
  oEditorHelper.DoUndo ;
end;

procedure TfrmMain.btnRevertClick(Sender: TObject);
begin
  GIS.Editor.RevertShape ;
  if btnShowInfo.Down then
    frmInfo.ShowInfo( TGIS_Shape( GIS.Editor.CurrentShape ) ) ;
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape ;
  btnSelectClick( self ) ;
end;

procedure TfrmMain.btnShowInfoClick(Sender: TObject);
begin
  if btnShowInfo.Down then
  begin
    frmInfo.ShowInfo( TGIS_Shape( GIS.Editor.CurrentShape ) ) ;
    frmInfo.Show ;
  end
  else
    frmInfo.Hide ;
end;

procedure TfrmMain.btnAutoCenterClick(Sender: TObject);
begin
  GIS.AutoCenter := btnAutocenter.Down ;
end;


procedure TfrmMain.cmbLayerChange(Sender: TObject);
var
  i : Integer ;
  ll : TGIS_Layer ;
begin
  endEdit ;
  GIS.SetFocus ;
  btnSelectClick( self ) ;

  for i:=1 to cmbLayer.Items.Count - 1 do
  begin
    ll := TGIS_Layer( GIS.Get( cmbLayer.Items[ i ] ) ) ;
    if cmbLayer.ItemIndex = 0 then begin
      ll.Active := True ;
    end
    else
      ll.Active := i = cmbLayer.ItemIndex ;

    if ll.Active then
      oEditorHelper.Layer := ll ;
  end ;

  btnAddShape.Enabled := cmbLayer.ItemIndex <> 0 ;

  GIS.InvalidateWholeMap ;
end;

procedure TfrmMain.btnPrintClick(Sender: TObject);
begin
  if dlgPrint.Execute then
  begin
    GIS.Print ;
  end ;
end;

procedure TfrmMain.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  oEditorHelper.CtrlPressed  := ssCtrl  in Shift;
  oEditorHelper.ShiftPressed := ssShift in Shift;

  if Button = TMouseButton.mbLeft then
    oEditorHelper.DoMouseDown( Point(X, Y) ) ;
end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;

  ptg := GIS.ScreenToMap( Point( x, y ) ) ;
  stsBar.Panels[1].Text := Format( 'x: %.4f', [ptg.X] ) ;
  stsBar.Panels[2].Text := Format( 'y: %.4f', [ptg.Y] ) ;

  oEditorHelper.CtrlPressed  := ssCtrl  in Shift;
  oEditorHelper.ShiftPressed := ssShift in Shift;
  oEditorHelper.DoMouseMove( Point(X, Y) ) ;

  GIS.Invalidate ;
end;

procedure TfrmMain.btnWindingClick(Sender: TObject);
begin
  GIS.Editor.ChangeWinding ;
end;

procedure TfrmMain.mnuAddPartClick(Sender: TObject);
begin
   GIS.Editor.CreatePart( TGIS_Utils.GisPoint3DFrom2D( menuPos ) ) ;
   oEditorHelper.DoStartEdit ;
end;

procedure TfrmMain.mnuDeletePartClick(Sender: TObject);
begin
  GIS.Editor.DeletePart ;
end;

procedure TfrmMain.btnNewStyleClick(Sender: TObject);
begin
  with GIS.Editor.EditingLinesStyle do
  begin
    PenStyle := TGIS_PenStyle.Dash ;
    PenColor := TGIS_Color.Lime ;
  end;

  with GIS.Editor.EditingPointsStyle do
  begin
    PointsFont.Name           := 'Verdana' ;
    PointsFont.Size           := 8 ;
    PointsFont.Color          := TGIS_Color.White ;
    PointsBackground          := TGIS_Color.Green ;

    ActivePoints.BrushStyle   := TGIS_BrushStyle.Solid ;
    ActivePoints.BrushColor   := TGIS_Color.Green ;
    ActivePoints.PenStyle     := TGIS_PenStyle.Solid ;
    ActivePoints.PenColor     := TGIS_Color.Black ;

    InactivePoints.BrushStyle := TGIS_BrushStyle.Solid ;
    InactivePoints.BrushColor := TGIS_Color.Blue ;
    InactivePoints.PenStyle   := TGIS_PenStyle.Solid ;
    InactivePoints.PenColor   := TGIS_Color.Black ;

    SelectedPoints.BrushStyle := TGIS_BrushStyle.Solid ;
    SelectedPoints.BrushColor := TGIS_Color.Red ;
    SelectedPoints.PenStyle   := TGIS_PenStyle.Solid ;
    SelectedPoints.PenColor   := TGIS_Color.Black ;

    Points3D.BrushStyle       := TGIS_BrushStyle.Solid ;
    Points3D.BrushColor       := TGIS_Color.Purple ;
    Points3D.PenStyle         := TGIS_PenStyle.Solid ;
    Points3D.PenColor         := TGIS_Color.Olive ;

    SnappingPoints.BrushStyle := TGIS_BrushStyle.Solid ;
    SnappingPoints.BrushColor := TGIS_Color.Red ;
    SnappingPoints.PenStyle   := TGIS_PenStyle.Solid ;
    SnappingPoints.PenColor   := TGIS_Color.Yellow ;
  end;

  if GIS.Editor.InEdit then
    GIS.Editor.RefreshShape;
end;

procedure TfrmMain.cmbSnapChange(Sender: TObject);
begin
  if cmbSnap.ItemIndex > 0 then
    GIS.Editor.SnapLayer := GIS.Get( cmbSnap.Items[ cmbSnap.ItemIndex ] )
  else
    GIS.Editor.SnapLayer := nil ;

  GIS.InvalidateEditor( True ) ;
end;

procedure TfrmMain.doNotifyChanges(Sender: TObject);
begin
  frmEditorTools.NotifyChange ;
end;

procedure TfrmMain.doNotifyAction(const prompt: String);
begin
  frmEditorTools.NotifyAction( prompt ) ;
end;

procedure TfrmMain.doEditorToolChange(Sender: TObject);
begin
  if oEditorHelper.DrawingTool <> frmEditorTools.editingTool then
    oEditorHelper.DrawingTool := frmEditorTools.editingTool ;

  if oEditorHelper.DrawingTool <> nil then
    GIS.Editor.EditorMode := TGIS_EditorModeEx.Extended
  else
    GIS.Editor.EditorMode := TGIS_EditorModeEx.Normal ;

  oEditorHelper.PolarSnapTracing := frmEditorTools.cbPolarTracking.Checked ;
  oEditorHelper.PolarAngle       := DegToRad( frmEditorTools.sePolarIncAngle.Value ) ;
  oEditorHelper.SnapTracing      := frmEditorTools.cbTracing.Checked ;
end;


end.


