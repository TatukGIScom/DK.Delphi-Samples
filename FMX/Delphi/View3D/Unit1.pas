unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  Math,

  //GisLicense,
  GisTypes,
  GisTypesUI,
  GisLayerVector,
  GisLayerGRD,
  GisLayerTiff,
  GisUtils,
  GisLayer,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.GisControl3D,
  FMX.Layouts,
  FMX.TreeView,
  FMX.GisControlLegend,
  FMX.GisViewerWnd,
  FMX.ListBox, FMX.Objects;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_Legend: TGIS_ControlLegend;
    btnRoof: TButton;
    btnWalls: TButton;
    btnShowOpt: TButton;
    Panel1: TPanel;
    Button1: TButton;
    btn2D3D: TButton;
    btnNavigation: TButton;
    btnFullExtent: TButton;
    cbx3DMode: TComboBox;
    Button2: TButton;
    ScrollBox1: TScrollBox;
    GIS_3D: TGIS_Control3D;
    ToolBar1: TToolBar;
    procedure btn2D3DClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnNavigationClick(Sender: TObject);
    procedure btnRoofClick(Sender: TObject);
    procedure btnWallsClick(Sender: TObject);
    procedure cbx3DModeChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnShowOptClick(Sender: TObject);
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GISMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    mousePos : TPoint ;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses System.IOUtils ;

procedure TForm1.btn2D3DClick(Sender: TObject);
begin
  if GIS.IsEmpty then exit ;

  GIS.View3D := not GIS.View3D ;
  if GIS.View3D then
  begin
    btn2D3D.Text := '2D' ;
    btnRoof.Visible := true;
    btnWalls.Visible := true;
    btnRoof.BringToFront ;
    btnWalls.BringToFront ;
  end else begin
    btn2D3D.Text := '3D' ;
    btnRoof.Visible := false;
    btnWalls.Visible := false;
  end;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  if not GIS.View3D then
    GIS.FullExtent
  else
    GIS.Viewer3D.ResetView ;
end;

procedure TForm1.btnNavigationClick(Sender: TObject);
begin
  if not GIS.View3D then exit ;
  if not GIS.Viewer3D.AdvNavigation then begin
    GIS.Viewer3D.AdvNavigation := True ;
    btnNavigation.Text := 'Std. Navigation' ;
    GIS.Viewer3D.FastMode := True ;
  end
  else begin
    GIS.Viewer3D.AdvNavigation := False ;
    btnNavigation.Text := 'Adv. Navigation' ;
    GIS.Viewer3D.FastMode := False ;
  end;
end;

procedure TForm1.btnRoofClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  if lv.Params.Area.Pattern = TGIS_BrushStyle.Clear then begin
    btnRoof.Text := 'Hide roof' ;
    lv.Params.Area.Pattern := TGIS_BrushStyle.Solid ;
  end
  else begin
    lv.Params.Area.Pattern := TGIS_BrushStyle.Clear ;
    btnRoof.Text := 'Show roof' ;
  end ;
  GIS.Viewer3D.UpdateWholeMap ;
end;


procedure TForm1.btnShowOptClick(Sender: TObject);
begin
  if GIS_3D.Visible then begin
    GIS_3D.Visible := False ;
    btnShowOpt.Text := 'Show Options';
  end
  else begin
    GIS_3D.Visible := True ;
    btnShowOpt.Text := 'Hide Options';
  end;
end;

procedure TForm1.btnWallsClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  if lv.Params.Area.OutlinePattern = TGIS_BrushStyle.Clear then begin
    btnWalls.Text := 'Hide walls' ;
    lv.Params.Area.OutlinePattern := TGIS_BrushStyle.Solid ;
  end
  else begin
    lv.Params.Area.OutlinePattern := TGIS_BrushStyle.Clear ;
    btnWalls.Text := 'Show walls' ;
  end ;
 GIS.Viewer3D.UpdateWholeMap ;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Panel1.Visible := not Panel1.Visible ;
  if not Panel1.Visible then
    GIS_Legend.Align := TAlignLayout.Left
  else begin
    GIS_Legend.Align := TAlignLayout.None ;
    GIS_Legend.Position.Y := 312 ;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  GIS_Legend.Visible := not GIS_Legend.Visible ;
  if GIS_Legend.Visible then
    Button2.Text := 'Hide Legend'
  else
    Button2.Text := 'Show Legend' ;
end;

procedure TForm1.cbx3DModeChange(Sender: TObject);
begin
  if not GIS.View3D then exit ;

  case cbx3DMode.ItemIndex of
    0 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraPosition;
    1 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ ;
    2 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXY ;
    3 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraRotation ;
    4 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.SunPosition ;
    5 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Zoom ;
    6 : GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Select ;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GIS.View3D := False ;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  str  : String ;
begin
  str := '' ;
  GIS.Close ;
  {$IF  Defined(WIN32) or Defined(WIN64)}
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload() + '\Samples\3D\Building3D.ttkproject');
  {$ELSEIF Defined(MACOS) and not Defined(IOS) }
    str := TDirectory.GetParent( TDirectory.GetParent( ParamStr(0) ) ) ;
    GIS.Open( str + '/Data/Building3D.ttkproject' ) ;
  {$ELSEIF Defined(MACOS) and Defined(IOS)}
    GIS.Open( TPath.GetDocumentsPath + PathDelim + 'Building3D.ttkproject' ) ;
  {$ELSE ANDROID}
    str := TPath.GetDocumentsPath + PathDelim + 'Building3D.ttkproject' ;
    GIS.Open( str ) ;
  {$ENDIF}

  GIS_3D.GIS_Viewer := GIS;
  cbx3DMode.ItemIndex := 0 ;
  cbx3DModeChange(Self);
  GIS_3D.Visible := False ;
  Panel1.Visible := False ;
  GIS_Legend.Visible := False ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  mousePos := Point( Trunc(X), Trunc(Y) ) ;
end;

procedure TForm1.GISMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
var
  cam: TGIS_Point3D ;
begin
  if GIS.IsEmpty then exit ;

  if GIS.View3D then begin
    // allows MouseWheel works properly in ZoomMode
    GIS.Viewer3D.StoreMousePos( mousePos ) ;

    cam := GIS.Viewer3D.CameraPosition ;
    if WheelDelta > 0 then
      cam.Z := cam.Z  * ( 1 + 0.05 )
    else
      cam.Z := cam.Z  / ( 1 + 0.05 ) ;

    GIS.Viewer3D.CameraPosition := cam ;
  end
  else begin
    if WheelDelta > 0 then
      GIS.ZoomBy( 2/3, mousePos.X, mousePos.Y )
    else
      GIS.ZoomBy( 3/2, mousePos.X, mousePos.Y );
  end;

  Handled := True ;
end;

procedure TForm1.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  shp  : TGIS_Shape ;
  prec : Integer ;
begin
  // if there is no layer or we are not in select mode, exit
  if GIS.IsEmpty then exit ;
  if GIS.View3D and ( GIS.Viewer3D.Mode = TGIS_Viewer3DMode.Select ) then begin

    prec := 20 ;
    shp := TGIS_Shape(GIS.Locate(Point(Round(X), Round(Y)), prec));
    if Assigned(shp) then begin
      shp.IsSelected := not shp.IsSelected;
      GIS.Viewer3D.UpdateAllSelectedObjects;
      GIS.Viewer3D.ControlRepaint;
    end;

  end ;

end;

initialization
  // GlobalUseDX := False ; // uncomment this line if 3D view is improper
  GlobalUseGDIPlusClearType := False ;
end.
