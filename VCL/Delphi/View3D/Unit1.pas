//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to create 3D View
}

unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.Variants,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Imaging.jpeg,

  //GisLicense,
  GisAllLayers,
  GisLayer,
  GisEditor,
  GisLayerVector,
  GisLayerGrd,
  GisParams,
  GisTypes,
  GisTypesUI,
  GisTypes3D,
  GisUtils,
  GisViewer,
  GisViewer3DBase,

  Vcl.GisControl3D,
  Vcl.GisControlLegend,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    btnOpen: TButton;
    btnFullExtent: TButton;
    btn2D3D: TButton;
    lb3DMode: TLabel;
    cbx3DMode: TComboBox;
    GIS_Legend: TGIS_ControlLegend;
    GIS: TGIS_ViewerWnd;
    GIS_3D: TGIS_Control3D;
    btnNavigation: TButton;
    btnRefresh: TButton;
    Button3: TButton;
    btnTextures: TButton;
    Image1: TImage;
    Image2: TImage;
    btnRoof: TButton;
    Button1: TButton;
    Button2: TButton;
    btnWalls: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btn2D3DClick(Sender: TObject);
    procedure cbx3DModeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GISMouseWheelDown(Sender: TObject;Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject;Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure btnNavigationClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnTexturesClick(Sender: TObject);
    procedure btnRoofClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnWallsClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btn2D3DClick(Sender: TObject);
begin
  if GIS.IsEmpty then exit ;

  GIS.View3D := not GIS.View3D ;
  if GIS.View3D then
  begin
    btn2D3D.Caption := '2D View' ;
    btnTextures.Enabled := true;
    btnRoof.Enabled := true;
    btnWalls.Enabled := true;
    Button2.Enabled := true;
    GIS_3D.Enabled := true ;
  end else begin
    btn2D3D.Caption := '3D View' ;
    btnTextures.Enabled := false;
    btnRoof.Enabled := false;
    btnWalls.Enabled := false;
    Button2.Enabled := false;
    GIS_3D.Enabled := false;
  end;
  cbx3DMode.ItemIndex := 0 ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  if not GIS.View3D then
    GIS.FullExtent
  else
    GIS.Viewer3D.ResetView ;
end;

procedure TForm1.btnOpenClick(Sender: TObject);
begin
  GIS.Lock;
  try
    if GIS.View3D then
      btn2D3DClick( self ) ;
    GIS.Close ;
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload() + 'Samples\3D\Building3D.ttkproject');

    cbx3DMode.ItemIndex := 0 ;
  finally
    GIS.Unlock ;
  end;
end;

procedure TForm1.btnNavigationClick(Sender: TObject);
begin
  if not GIS.View3D then exit ;
  if not GIS.Viewer3D.AdvNavigation then begin
    GIS.Viewer3D.AdvNavigation := True ;
    btnNavigation.Caption := 'Std. Navigation' ;
    GIS.Viewer3D.FastMode := True ;
    btnRefresh.Caption := 'Unlock Refresh' ;
  end
  else begin
    GIS.Viewer3D.AdvNavigation := False ;
    btnNavigation.Caption := 'Adv. Navigation' ;
    GIS.Viewer3D.FastMode := False ;
    btnRefresh.Caption := 'Lock Refresh' ;
  end;

end;

procedure TForm1.btnRefreshClick(Sender: TObject);
begin
  if not GIS.View3D then exit ;
  if not GIS.Viewer3D.FastMode then begin
    GIS.Viewer3D.FastMode := True ;
    btnRefresh.Caption := 'Unlock Refresh' ;
  end
  else begin
    GIS.Viewer3D.FastMode := False ;
    btnRefresh.Caption := 'Lock Refresh' ;
  end;
end;

procedure TForm1.btnTexturesClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
  bmp : TGIS_Bitmap ;
begin
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  if not Assigned( lv.Params.Area.Bitmap ) or lv.Params.Area.Bitmap.IsEmpty then
  begin
    bmp := TGIS_Bitmap.Create ;
    try
      btnTextures.Caption := 'Hide Textures' ;
      bmp.LoadFromBitmap(Image2.Picture.Bitmap, '');
      lv.Params.Area.Bitmap := bmp ;
      bmp.LoadFromBitmap(Image1.Picture.Bitmap, '');
      lv.Params.Area.OutlineBitmap := bmp;
    finally
      bmp.Free ;
    end;
  end
  else begin
    btnTextures.Caption := 'Show Textures' ;
    lv.Params.Area.Bitmap := nil ;
    lv.Params.Area.OutlineBitmap := nil ;
  end ;

  GIS.Viewer3D.UpdateWholeMap ;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  GIS.Lock ;
  try
    GIS.Close ;

    lv := TGIS_LayerVector.Create ;
    lv.Name := 'multipatch' ;
    lv.Params.Area.Color := TGIS_Color.Yellow ;
    GIS.Add( lv ) ;
    shp := lv.CreateShape( TGIS_ShapeType.MultiPatch, TGIS_DimensionType.XYZ ) as TGIS_ShapeMultiPatch ;
    shp.Lock(TGIS_Lock.Projection);

    shp.AddPart ;
    shp.SetPartType( 0, TGIS_PartType.TriangleFan ) ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(5,4,10));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 0,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 10,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 10,8,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 0,8,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,5));
    shp.AddPart ;
    shp.SetPartType( 1, TGIS_PartType.TriangleStrip ) ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,0,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,8,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,8,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,8,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,8,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,0));
    shp.AddPart ;
    shp.SetPartType( 2, TGIS_PartType.OuterRing ) ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(4,0,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(4,0,3));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(6,0,3));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(6,0,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,0,0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(10,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,5));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(0,0,0));
    shp.AddPart ;
    shp.SetPartType( 3, TGIS_PartType.InnerRing ) ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(1,0,2));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(1,0,4));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(3,0,4));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(3,0,2));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(1,0,2));
    shp.AddPart ;
    shp.SetPartType( 4, TGIS_PartType.InnerRing ) ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(7,0,2));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(7,0,4));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(9,0,4));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(9,0,2));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(7,0,2));

    shp.Unlock ;

    GIS.FullExtent ;

    GIS.Zoom := GIS.Zoom / 2 ;
    btn2D3DClick( self ) ;
    GIS.Viewer3D.CameraPosition := TGIS_Utils.GisPoint3D( DegToRad(10), DegToRad(200),28) ;
    GIS.Viewer3D.ShowLights := True ;
    GIS.Viewer3D.ShowVectorEdges := False ;
  finally
    GIS.Unlock;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if GIS.View3D then begin
    GIS.Viewer3D.LightVector := not GIS.Viewer3D.LightVector ;
    GIS.Viewer3D.UpdateWholeMap ;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  GIS.Lock ;
  try
    GIS.Close ;

    lv := TGIS_LayerVector.Create ;
    lv.Name := 'volumetric_lines' ;
    GIS.Add( lv ) ;
    shp := lv.CreateShape( TGIS_ShapeType.Arc, TGIS_DimensionType.XYZ ) as TGIS_ShapeArc ;
    shp.Params.Line.Color := TGIS_Color.Red ;
    shp.Params.Line.Width := 450 ;
    shp.Params.Line.OutlinePattern := TGIS_BrushStyle.Clear ;
    shp.Lock(TGIS_Lock.Projection);
    shp.AddPart ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(-50, 50, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(  0,  0,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 50,  0,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 50, 50,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 50, 50, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(100, 50, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(150, 50,  0));
    shp.Unlock ;

    shp := lv.CreateShape( TGIS_ShapeType.Arc, TGIS_DimensionType.XYZ ) as TGIS_ShapeArc ;
    shp.Params.Line.Color := TGIS_Color.Blue ;
    shp.Params.Line.Width := 350 ;
    shp.Params.Line.OutlinePattern := TGIS_BrushStyle.Clear ;
    shp.Lock(TGIS_Lock.Projection);
    shp.AddPart ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(-50,  40, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(  0, -10,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 60, -10,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 60,  40,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 60,  40, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(110,  40, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(160,  40,  0));
    shp.Unlock ;

    shp := lv.CreateShape( TGIS_ShapeType.Arc, TGIS_DimensionType.XYZ ) as TGIS_ShapeArc ;
    shp.Params.Line.Color := TGIS_Color.Green ;
    shp.Params.Line.Width := 250 ;
    shp.Params.Line.OutlinePattern := TGIS_BrushStyle.Clear ;
    shp.Lock(TGIS_Lock.Projection);
    shp.AddPart ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(-50,  30, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(  0, -20,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 70, -20,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 70,  30,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 70,  30, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(120,  30, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(170,  30,  0));
    shp.Unlock ;

    shp := lv.CreateShape( TGIS_ShapeType.Arc, TGIS_DimensionType.XYZ ) as TGIS_ShapeArc ;
    shp.Params.Line.Color := TGIS_Color.Yellow ;
    shp.Params.Line.Width := 150 ;
    shp.Params.Line.OutlinePattern := TGIS_BrushStyle.Clear ;
    shp.Lock(TGIS_Lock.Projection);
    shp.AddPart ;
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(-50,  20, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(  0, -30,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 80, -30,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 80,  20,  0));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D( 80,  20, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(130,  20, 50));
    shp.AddPoint3D(TGIS_Utils.GisPoint3D(120,  30, 50));
    shp.Unlock ;

    GIS.FullExtent ;

    btn2D3DClick( self ) ;
    GIS.Viewer3D.ShowLights := True ;
  finally
    GIS.Unlock ;
  end;
end;

procedure TForm1.btnWallsClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  if lv.Params.Area.OutlinePattern = TGIS_BrushStyle.Clear then begin
    btnWalls.Caption := 'Hide walls' ;
    lv.Params.Area.OutlinePattern := TGIS_BrushStyle.Solid ;
  end
  else begin
    lv.Params.Area.OutlinePattern := TGIS_BrushStyle.Clear ;
    btnWalls.Caption := 'Show walls' ;
  end ;
 GIS.Viewer3D.UpdateWholeMap ;

end;

procedure TForm1.btnRoofClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  if lv.Params.Area.Pattern = TGIS_BrushStyle.Clear then begin
    btnRoof.Caption := 'Hide roof' ;
    lv.Params.Area.Pattern := TGIS_BrushStyle.Solid ;
  end
  else begin
    lv.Params.Area.Pattern := TGIS_BrushStyle.Clear ;
    btnRoof.Caption := 'Show roof' ;
  end ;
  GIS.Viewer3D.UpdateWholeMap ;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  btnTextures.Enabled := false;
  btnRoof.Enabled := false;
  btnWalls.Enabled := false;
  Button2.Enabled := false;
  //GIS_3D.GIS_Viewer := GIS;
  cbx3DMode.ItemIndex := 0 ;
  cbx3DModeChange(Self);
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp  : TGIS_Shape ;
  prec : Integer ;
begin
  // if there is no layer or we are not in select mode, exit
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  if GIS.View3D and ( GIS.Viewer3D.Mode = TGIS_Viewer3DMode.Select ) then begin

    prec := 20 ;
    shp := TGIS_Shape(GIS.Locate(Point(X, Y), prec));

    if Assigned(shp) then begin
      shp.IsSelected := not shp.IsSelected;
      GIS.Viewer3D.UpdateAllSelectedObjects;
    end;
  end ;
end;

procedure TForm1.GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
  cam: TGIS_Point3D ;
begin
  if GIS.IsEmpty then exit ;

  pt := GIS.ScreenToClient( MousePos ) ;

  if GIS.View3D then begin
    // allows MouseWheel works properly in ZoomMode
    GIS.Viewer3D.StoreMousePos( pt ) ;

    cam := GIS.Viewer3D.CameraPosition ;
    cam.Z := cam.Z  / ( 1 + 0.05 ) ;
    GIS.Viewer3D.CameraPosition := cam ;
  end
  else
    GIS.ZoomBy( 3/2, pt.X, pt.Y );

  Handled := True ;
end;

procedure TForm1.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
  cam: TGIS_Point3D ;
begin
  if GIS.IsEmpty then exit ;

  pt := GIS.ScreenToClient( MousePos ) ;

  if GIS.View3D then begin
    // allows MouseWheel works properly in ZoomMode
    GIS.Viewer3D.StoreMousePos( pt ) ;

    cam := GIS.Viewer3D.CameraPosition ;
    cam.Z := cam.Z  * ( 1 + 0.05 ) ;
    GIS.Viewer3D.CameraPosition := cam ;
  end
  else
   GIS.ZoomBy( 2/3, pt.X, pt.Y );

  Handled := True ;
end;


end.
