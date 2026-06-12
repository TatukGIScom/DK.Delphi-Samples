//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  View3D Sample — Demonstrates 3D visualization of geospatial data including
  building models, textures, and 3D geometry manipulation.

  Key concepts illustrated:
    - 3D view mode: switching between 2D and 3D perspective rendering
    - 3D layer visualization: displaying building geometries in 3D space
    - Texture mapping: applying bitmap textures to 3D surfaces
    - 3D navigation: standard and advanced navigation modes
    - MultiPatch geometry: 3D shapes composed of triangle fans and strips
    - Coordinate systems in 3D: XYZ coordinates for elevation
    - Z-axis visualization: height/elevation as the vertical dimension

  User workflow:
    1. Load a 3D building project (.ttkproject)
    2. Click "3D View" to switch to 3D perspective
    3. Use mouse to navigate: drag to rotate, scroll to zoom
    4. Toggle "Show Textures" to apply/remove building facade textures
    5. Switch between Standard and Advanced navigation modes
    6. Toggle "Lock Refresh" / "Unlock Refresh" for performance tuning

  3D visualization features:
    - Interactive rotation, pan, and zoom in 3D space
    - Real-time texture rendering on building surfaces
    - Fast mode: optimized for responsive navigation at lower quality
    - Advanced navigation: precise control with higher quality rendering
    - Roof and wall visualization for building structures

  Data: Building3D.ttkproject (3D building models with textures)

  3D geometry types supported:
    - MultiPatch: complex 3D shapes composed of triangle fans, strips, and rings
    - Part types: TriangleFan (roof), TriangleStrip (walls), OuterRing (base)
    - Coordinates: TGIS_Point3D with X, Y, Z (elevation) values
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

{
  btn2D3DClick
  Toggles between 2D and 3D view modes.
  When 3D is enabled, activates 3D-specific controls (textures, navigation, etc).
  When 3D is disabled, switches back to standard 2D map view.
}
procedure TForm1.btn2D3DClick(Sender: TObject);
begin
  { Guard: cannot switch view if no data loaded }
  if GIS.IsEmpty then exit ;

  { Toggle the 3D view mode }
  GIS.View3D := not GIS.View3D ;

  { Configure UI and controls based on the new view mode }
  if GIS.View3D then
  begin
    { Switch to 3D: change button text and enable 3D-specific controls }
    btn2D3D.Caption := '2D View' ;
    btnTextures.Enabled := true;         { Enable texture toggle }
    btnRoof.Enabled := true;             { Enable roof rendering control }
    btnWalls.Enabled := true;            { Enable wall rendering control }
    Button2.Enabled := true;             { Enable another 3D feature }
    GIS_3D.Enabled := true ;             { Enable the 3D control panel }
  end else begin
    { Switch to 2D: change button text and disable 3D-specific controls }
    btn2D3D.Caption := '3D View' ;
    btnTextures.Enabled := false;
    btnRoof.Enabled := false;
    btnWalls.Enabled := false;
    Button2.Enabled := false;
    GIS_3D.Enabled := false;
  end;

  { Reset 3D mode dropdown to default }
  cbx3DMode.ItemIndex := 0 ;
end;

{ Fit viewport to show all data: 2D extent zoom or 3D home view }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  { Different behavior depending on current view mode }
  if not GIS.View3D then
    { In 2D mode: zoom to fit all layers in the viewport }
    GIS.FullExtent
  else
    { In 3D mode: reset the 3D camera to the home/default view position }
    GIS.Viewer3D.ResetView ;
end;

{
  btnOpenClick
  Loads a 3D building project file.
  Switches back to 2D mode if currently in 3D before loading new data.
}
procedure TForm1.btnOpenClick(Sender: TObject);
begin
  GIS.Lock;
  try
    { If in 3D mode, switch back to 2D before loading new data }
    if GIS.View3D then
      btn2D3DClick( self ) ;

    { Close any previously loaded data }
    GIS.Close ;

    { Load the 3D building project (.ttkproject bundles layers, styles, CRS) }
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload() + 'Samples\3D\Building3D.ttkproject');

    { Reset 3D mode dropdown to default }
    cbx3DMode.ItemIndex := 0 ;
  finally
    GIS.Unlock ;
  end;
end;

{
  btnNavigationClick
  Toggles between Standard and Advanced 3D navigation modes.
  Advanced: precise control with higher quality rendering.
  Standard: optimized for responsive fast navigation.
}
procedure TForm1.btnNavigationClick(Sender: TObject);
begin
  { Guard: only applicable in 3D mode }
  if not GIS.View3D then exit ;

  { Toggle between navigation modes }
  if not GIS.Viewer3D.AdvNavigation then
  begin
    { Switch to Advanced navigation: precise, high-quality rendering }
    GIS.Viewer3D.AdvNavigation := True ;
    btnNavigation.Caption := 'Std. Navigation' ;
    { Enable fast mode for performance }
    GIS.Viewer3D.FastMode := True ;
    btnRefresh.Caption := 'Unlock Refresh' ;
  end
  else begin
    { Switch to Standard navigation: responsive, lower quality }
    GIS.Viewer3D.AdvNavigation := False ;
    btnNavigation.Caption := 'Adv. Navigation' ;
    { Disable fast mode for higher quality }
    GIS.Viewer3D.FastMode := False ;
    btnRefresh.Caption := 'Lock Refresh' ;
  end;
end;

{
  btnRefreshClick
  Toggles FastMode for 3D rendering performance tuning.
  FastMode: optimized for smooth interaction, lower quality.
  Locked:   higher quality, may be slower during interaction.
}
procedure TForm1.btnRefreshClick(Sender: TObject);
begin
  { Guard: only applicable in 3D mode }
  if not GIS.View3D then exit ;

  { Toggle fast mode for performance }
  if not GIS.Viewer3D.FastMode then
  begin
    { Enable fast mode: optimized for responsive navigation }
    GIS.Viewer3D.FastMode := True ;
    btnRefresh.Caption := 'Unlock Refresh' ;
  end
  else begin
    { Disable fast mode: higher quality rendering }
    GIS.Viewer3D.FastMode := False ;
    btnRefresh.Caption := 'Lock Refresh' ;
  end;
end;

{
  btnTexturesClick
  Applies/removes texture bitmaps to building surfaces in 3D view.
  Textures consist of face textures (walls/roofs) and outline textures (edges).
}
procedure TForm1.btnTexturesClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
  bmp : TGIS_Bitmap ;
begin
  { Get the buildings vector layer from the viewer }
  lv := GIS.Get( 'buildings') as TGIS_LayerVector ;
  if not Assigned( lv ) then exit ;

  { Check if textures are currently applied }
  if not Assigned( lv.Params.Area.Bitmap ) or lv.Params.Area.Bitmap.IsEmpty then
  begin
    { Apply textures: load images and assign to layer }
    bmp := TGIS_Bitmap.Create ;
    try
      btnTextures.Caption := 'Hide Textures' ;

      { Load and assign the primary texture (building faces/walls) }
      bmp.LoadFromBitmap(Image2.Picture.Bitmap, '');
      lv.Params.Area.Bitmap := bmp ;

      { Load and assign the outline texture (building edges) }
      bmp.LoadFromBitmap(Image1.Picture.Bitmap, '');
      lv.Params.Area.OutlineBitmap := bmp;
    finally
      bmp.Free ;
    end;
  end
  else begin
    { Remove textures: revert to solid colors }
    btnTextures.Caption := 'Show Textures' ;
    lv.Params.Area.Bitmap := nil ;
    lv.Params.Area.OutlineBitmap := nil ;
  end ;

  { Refresh the 3D view to apply texture changes }
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
