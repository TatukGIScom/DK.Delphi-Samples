//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Simple BIM viewer.
  To read IFC files, please follow instructions from Deployment\ICF\Readme.txt
  BIM support requires Enterprise license.
}
unit Forms.Main ;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit,
  Vcl.ComCtrls, Vcl.Menus, Vcl.GisViewerWnd,
  GisLayerVector, System.Types,
  //GisLicense,
  GisTypes, BimModel,  GisLayerWexBIM, GisLayerIFC, VCL.GisControl3D, Vcl.StdCtrls ;

type
  TfrmMain = class(TForm)
    tvSpatialModel : TTreeView ;
    Panel1 : TPanel ;
    Splitter1 : TSplitter ;
    lvAttributes : TListView ;
    StatusBar1 : TStatusBar ;
    MainMenu1 : TMainMenu ;
    File1 : TMenuItem ;
    actFileOpen : TMenuItem ;
    Close1 : TMenuItem ;
    View1 : TMenuItem ;
    N2D1 : TMenuItem ;
    N3D1 : TMenuItem ;
    GIS : TGIS_ViewerWnd ;
    Splitter2 : TSplitter ;
    OpenFileDialog : TOpenDialog ;
    HeaderControl1 : THeaderControl ;
    Opendefault1 : TMenuItem ;
    Options1: TMenuItem;
    Options2: TMenuItem;
    Mode1: TMenuItem;
    Mode2: TMenuItem;
    Zoom1: TMenuItem;
    Zoom2: TMenuItem;
    Fullextent1: TMenuItem;
    Rotate1: TMenuItem;
    N1: TMenuItem;
    N3DView1: TMenuItem;
    N3DView2: TMenuItem;
    Showbasemap1: TMenuItem;
    Showbasemap2: TMenuItem;
    Showedges1: TMenuItem;
    chkGroup: TCheckBox;
    est1: TMenuItem;
    ExporttoSHP1: TMenuItem;
    ExporttoSqlite1: TMenuItem;
    GIS_Control3D1: TGIS_Control3D;
    pnl3D: TPanel;
    advNav: TMenuItem;
    refreshLock: TMenuItem;
    btnDemo: TMenuItem;
    tmrDemo: TTimer;
    btnVectorSimplification: TMenuItem;
    procedure actFileOpenClick(Sender : TObject) ;
    procedure N3D1Click(Sender : TObject) ;
    procedure N2D1Click(Sender : TObject) ;
    procedure FormCreate(Sender : TObject) ;
    procedure tvSpatialModelClick(Sender : TObject) ;
    procedure GISBusyEvent(_sender : TObject ; _pos, _end : Integer ; var _abort : Boolean) ;
    procedure GISMouseWheelDown(Sender : TObject ; Shift : TShiftState ; MousePos : TPoint ; var Handled : Boolean) ;
    procedure GISMouseWheelUp(Sender : TObject ; Shift : TShiftState ; MousePos : TPoint ; var Handled : Boolean) ;
    procedure Opendefault1Click(Sender : TObject) ;
    procedure FormDestroy(Sender : TObject) ;
    procedure Options2Click(Sender: TObject);
  {$IF CompilerVersion >= 35.0}
    procedure tvSpatialModelCheckStateChanged(Sender: TCustomTreeView;
      Node: TTreeNode; CheckState: TNodeCheckState);
  {$ENDIF}
    procedure tvSpatialModelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Mode2Click(Sender: TObject);
    procedure Zoom1Click(Sender: TObject);
    procedure Zoom2Click(Sender: TObject);
    procedure Fullextent1Click(Sender: TObject);
    procedure Rotate1Click(Sender: TObject);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure N3DView2Click(Sender: TObject);
    procedure Showbasemap1Click(Sender: TObject);
    procedure Showbasemap2Click(Sender: TObject);
    procedure Showedges1Click(Sender: TObject);
    procedure tvSpatialModelDblClick(Sender: TObject);
    procedure chkGroupClick(Sender: TObject);
    procedure ExporttoSHP1Click(Sender: TObject);
    procedure ExporttoSqlite1Click(Sender: TObject);
    procedure advNavClick(Sender: TObject);
    procedure refreshLockClick(Sender: TObject);
    procedure btnDemoClick(Sender: TObject);
    procedure tmrDemoTimer(Sender: TObject);
    procedure btnVectorSimplificationClick(Sender: TObject);
    procedure Close1Click(Sender: TObject);
  private
    { Private declarations }
    lbim      : TGIS_LayerVector ;
    model     : TModelBuilder ;
    draw2d    : Boolean ;
    wasCheck  : Boolean ;
    oldMode   : TGIS_ViewerMode ;
    oldMode3D : TGIS_Viewer3DMode ;
    oldMBtn   : TMouseButton ;
    isIFC     : Boolean ;
    isWEX     : Boolean ;
    isSQL     : Boolean ;
    procedure openLayer(const _path : String) ;
    procedure buildBimModel(const _path : String) ;
    procedure showAttributes(const _e : TGIS_IfcElement) ;
    procedure buildSpatialStructure ;
    procedure buildSpatialStructure2( const _e : TGIS_IfcElement ) ;
    function  findNodeById( const _id : Integer ) : TTreeNode ;
    function  readMetadataFromSql( const _path : String ) : TStream ;
    function  parseElement( const _data : String ) : TGIS_IfcElement ;
  public
    { Public declarations }
  end ;

var
  frmMain : TfrmMain ;

implementation

uses
  {$IF CompilerVersion >= 35.0}
  System.JSON.Serializers,
  {$ENDIF}
  System.JSON,
  System.IOUtils,
  StrUtils,
  System.Math,
  GisInternals,
  GisRtl,
  GisFunctions,
  GisLayerSHP,
  GisTypes3D,
  GisDbSqlite,
  GisLayerSqlSqlite,
  GisConfig,
  GisRegistredLayers,
  GisAllLayers,
  GisResource ;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender : TObject) ;
begin
  model  := TModelBuilder.Create ;
  draw2d := True ;
  lbim   := nil ;
  GIS.AutoStyle := False ;
  {$IF CompilerVersion >= 35.0}
  tvSpatialModel.CheckBoxes := True ;
  {$ENDIF}
end ;

procedure TfrmMain.FormDestroy(Sender : TObject) ;
begin
  model.Free ;
end ;

procedure TfrmMain.Zoom1Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Zoom ;
end ;

procedure TfrmMain.Zoom2Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ ;
end;

procedure TfrmMain.actFileOpenClick(Sender : TObject) ;
begin
  if OpenFileDialog.Execute() then
    openLayer(OpenFileDialog.FileName) ;
end ;


procedure TfrmMain.Fullextent1Click(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.ResetView
  else
    GIS.FullExtent ;
end;

procedure TfrmMain.GISBusyEvent(_sender : TObject ; _pos, _end : Integer ; var _abort : Boolean) ;
begin
  if _end <= 0 then
    StatusBar1.SimpleText := ''
  else
    StatusBar1.SimpleText := Format('%s %d%%', [GIS.BusyText, Trunc(_pos / _end * 100)]) ;

  Application.ProcessMessages ;
end ;

procedure TfrmMain.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp  : TGIS_Shape;
  data : String ;
  node : TTreeNode ;
  elm  : TGIS_IfcElement ;
begin
  if GIS.IsEmpty then exit;

  if GIS.View3D then begin
    oldMode3D := GIS.Viewer3D.Mode ;
    oldMBtn := GIS.ModeMouseButton ;
    if Button = TMouseButton.mbLeft then begin
      if ssShift in Shift then
        GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ
      else
        GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraPosition ;
    end
    else if Button = TMouseButton.mbRight then
      GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Select
    else if Button = TMouseButton.mbMiddle then begin
      GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraXYZ ;
      GIS.ModeMouseButton := TMouseButton.mbMiddle;
    end;

    if (GIS.Viewer3D.Mode = TGIS_Viewer3DMode.Select ) then begin
      shp := TGIS_Shape(GIS.Locate( Point(X, Y), 5 ));
      if not Assigned(shp) then exit;
      shp.Layer.DeselectAll ;
      shp.IsSelected := not shp.IsSelected;

      node := findNodeById( VarToInt32(shp.GetField('ifcProductLabel')) );
      if assigned( node ) then begin
        showAttributes( TGIS_IfcElement(node.Data) );
        tvSpatialModel.Select(node) ;
      end
      else begin
        data := VarToString( shp.GetField('ifcProps') ) ;
        elm := parseElement( data ) ;
        try
          showAttributes( elm );
        finally
          FreeObject( elm ) ;
        end ;
      end;
    end ;
    exit;
  end
  else begin
    oldMode := GIS.Mode ;
    if Button = TMouseButton.mbMiddle then begin
      GIS.Mode := TGIS_ViewerMode.Drag ;
      GIS.ModeMouseButton := TMouseButton.mbMiddle;
    end ;
  end;

  shp := TGIS_Shape(GIS.Locate(GIS.ScreenToMap(Point(X, Y)), 5 / GIS.Zoom));
  if GIS.Mode = TGIS_ViewerMode.Select then begin
    if not Assigned(shp) then exit;
    shp.Layer.DeselectAll ;
    shp.IsSelected := not shp.IsSelected;

    node := findNodeById( VarToInt32(shp.GetField('ifcProductLabel')) );
    if assigned( node ) then begin
      showAttributes( TGIS_IfcElement(node.Data) );
      tvSpatialModel.Select(node) ;
    end
    else begin
      data := VarToString( shp.GetField('ifcProps') ) ;
      elm := parseElement( data ) ;
      try
        showAttributes( elm );
      finally
        FreeObject( elm ) ;
      end ;
    end;
  end;

end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg   : TGIS_Point;
begin
  if GIS.IsEmpty then exit;

  ptg := GIS.ScreenToMap(Point(X, Y));
  StatusBar1.SimpleText := Format('X : %.4f | Y : %.4f', [ptg.X, ptg.Y]);
end;

procedure TfrmMain.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.View3D then begin
    GIS.Viewer3D.Mode   := oldMode3D ;
    GIS.ModeMouseButton := oldMBtn  ;
  end
  else begin
    if Button = TMouseButton.mbMiddle then begin
      GIS.Mode := oldMode ;
      GIS.ModeMouseButton := oldMBtn;
    end ;
  end;
end;

procedure TfrmMain.GISMouseWheelDown(Sender : TObject ; Shift : TShiftState ; MousePos : TPoint ;
  var Handled : Boolean) ;
var
  pt  : TPoint ;
  cam : TGIS_Point3D ;
begin
  if GIS.IsEmpty then exit ;

  pt := GIS.ScreenToClient(MousePos) ;

  if GIS.View3D then begin
    cam                         := GIS.Viewer3D.CameraPosition ;
    cam.Z                       := cam.Z * (1 + 0.05) ;
    GIS.Viewer3D.CameraPosition := cam ;
  end
  else
    GIS.ZoomBy(8 / 9, pt.X, pt.Y) ;

  Handled := True ;
end ;

procedure TfrmMain.GISMouseWheelUp(Sender : TObject ; Shift : TShiftState ; MousePos : TPoint ; var Handled : Boolean) ;
var
  pt  : TPoint ;
  cam : TGIS_Point3D ;
begin
  if GIS.IsEmpty then  exit ;

  pt := GIS.ScreenToClient(MousePos) ;

  if GIS.View3D then begin
    cam                         := GIS.Viewer3D.CameraPosition ;
    cam.Z                       := cam.Z / (1 + 0.05) ;
    GIS.Viewer3D.CameraPosition := cam ;
  end
  else
    GIS.ZoomBy(9 / 8, pt.X, pt.Y) ;

  Handled := True ;
end ;

procedure TfrmMain.Mode2Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select ;
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.Select ;
end;

procedure TfrmMain.N2D1Click(Sender : TObject) ;
begin
  GIS.View3D := False ;
  N2D1.Checked := True ;
  N3D1.Checked := False ;
  pnl3D.Visible := False ;
end ;

procedure TfrmMain.N3D1Click(Sender : TObject) ;
begin
  pnl3D.Visible := True ;
  GIS.View3D := True ;
  if GIS.View3D then begin
    GIS.Viewer3D.ShowLights := True ;
    Showbasemap1Click(sender) ;
    refreshLockClick(sender) ;
  end ;
  N3D1.Checked := True ;
  N2D1.Checked := False ;
end ;

procedure TfrmMain.N3DView2Click(Sender: TObject);
begin
  if GIS.View3D then begin
    N3DView2.Checked := not N3DView2.Checked ;
    GIS.Viewer3D.ShowLights := N3DView2.Checked ;
  end;
end;

procedure TfrmMain.Opendefault1Click(Sender : TObject) ;
begin
  openLayer('.\Data\SampleHouse4.wexBIM') ;
end ;

procedure TfrmMain.openLayer(const _path : String) ;
begin
  GIS.Close ;
  tmrDemo.Enabled := False ;
  N2D1.Checked := True ;
  N3D1.Checked := False ;

  tvSpatialModel.Items.Clear ;
  lvAttributes.Items.Clear ;
  lvAttributes.Groups.Clear ;

  isIFC := GetFileExt( _path ) = '.ifc' ;
  isWEX := GetFileExt( _path ) = '.wexBIM' ;
  isSQL := GetFileExt( _path ) = '.ttkls' ;

  if isIFC then begin
    lbim := TGIS_LayerIFC.Create ;
    TGIS_LayerWexBIM(lbim).Draw2D := draw2d ;
  end
  else if isWEX then begin
    lbim := TGIS_LayerWexBIM.Create ;
    TGIS_LayerWexBIM(lbim).Draw2D := draw2d ;
  end
  else begin
    lbim := GisCreateLayer( _path, _path ) as TGIS_LayerVector ;
    assert(lbim <> nil);
  end ;

  lbim.Path := _path ;

  if not isIFC then begin
    buildBimModel( _path ) ;
    if isWEX and assigned( model.Project ) then
      TGIS_LayerWexBIM(lbim).OffsetExtent := model.Project.Extent ;

    buildSpatialStructure ;
  end ;

  GIS.Add( lbim ) ;
  if isIFC then
     buildSpatialStructure2(TGIS_LayerIFC(lbim).IFCProject) ;

  GIS.FullExtent ;
  GIS.InvalidateWholeMap ;
end ;

procedure TfrmMain.Options2Click(Sender: TObject);
begin
  Options2.Checked := not Options2.Checked ;
  draw2d := Options2.Checked ;
  if assigned( lbim ) then begin
    if isIFC or isWEX then
    TGIS_LayerWexBIM(lbim).Draw2D := draw2d ;
    if not GIS.View3D then
      GIS.InvalidateWholeMap ;
  end;
end;

procedure TfrmMain.Rotate1Click(Sender: TObject);
begin
  if GIS.View3D then
    GIS.Viewer3D.Mode := TGIS_Viewer3DMode.CameraPosition ;
end;

procedure TfrmMain.Showbasemap1Click(Sender: TObject);
var
  bp : TGIS_Viewer3DBasePlane ;
begin
  if GIS.View3D then begin
    Showbasemap1.Checked := not Showbasemap1.Checked ;
    bp := GIS.Viewer3D.BasePlane ;
    bp.Active := Showbasemap1.Checked ;
    GIS.Viewer3D.BasePlane := bp ;
  end;
end;

procedure TfrmMain.Showbasemap2Click(Sender: TObject);
begin
  if GIS.View3D then begin
    Showbasemap2.Checked := not Showbasemap2.Checked ;
    GIS.Viewer3D.ShowWireframe := Showbasemap2.Checked ;
  end;
end;

procedure TfrmMain.Showedges1Click(Sender: TObject);
begin
  if GIS.View3D then begin
    Showedges1.Checked := not Showedges1.Checked ;
    GIS.Viewer3D.ShowVectorEdges := Showedges1.Checked ;
  end;
end;

procedure TfrmMain.advNavClick(Sender: TObject);
begin
  if GIS.View3D then begin
    advNav.Checked := not advNav.Checked ;
    GIS.Viewer3D.AdvNavigation := advNav.Checked ;
  end;
end;

procedure TfrmMain.btnDemoClick(Sender: TObject);
begin
  tmrDemo.Enabled := not tmrDemo.Enabled ;
  btnDemo.Checked := not btnDemo.Checked ;
end;

procedure TfrmMain.btnVectorSimplificationClick(Sender: TObject);
begin
  if GIS.View3D then begin
    btnVectorSimplification.Checked := not btnVectorSimplification.Checked ;
    GIS.Viewer3D.VectorSimplification := not GIS.Viewer3D.VectorSimplification ;
  end ;
end;

procedure TfrmMain.buildBimModel(const _path : String) ;
var
  stm : TStream ;
begin
  model.Reset ;
  if isSQL then begin
    stm := readMetadataFromSql(_path) ;
    if stm <> nil then begin
      try
        model.Load( stm ) ;
      finally
        stm.Free ;
      end;
    end
  end
  else
    model.Load(_path) ;
end ;

procedure TfrmMain.buildSpatialStructure ;

  procedure buildTree(const o : TGIS_IfcElement ; const _node : TTreeNode) ;
  var
    node        : TTreeNode ;
    str         : String ;
    i           : Integer ;
    cnt         : Integer ;
    lastIfcType : String ;
    node2       : TTreeNode ;
    shp         : TGIS_Shape ;
    e           : TGIS_IfcElement ;
  begin
    if (length(o.Elements) = 0) and chkGroup.Checked then
      str := Format(' %s #%d', [ IfThen( o.Name.Trim.IsEmpty, o.IfcType, o.Name ), o.Id ])
    else
      str := Format(' [ %s ] %s #%d', [o.IfcType, o.Name, o.Id]) ;

    node := tvSpatialModel.Items.AddChild(_node, str) ;
    node.Data    := o ;
    node.Expanded := node.Level <= 2 ;
    lastIfcType := '' ;

    if o.IfcType = 'IfcSpace' then begin
      {$IF CompilerVersion >= 35.0}
      node.Checked := False ;
      {$ENDIF}
      shp := lbim.FindFirst(lbim.Extent, Format('ifcProductLabel=%d', [o.Id])) ;
      if assigned(shp) then
        shp.MakeEditable.IsHidden := True ;
    end
    else
    {$IF CompilerVersion >= 35.0}
      node.Checked := True
    {$ENDIF} ;

    if chkGroup.Checked then begin
      cnt := length(o.Elements) ;
      i := 0 ;
      while i < cnt do begin
        e := o.Elements[i] ;
        if (node.Level > 2 ) and (lastIfcType <> e.IfcType) then begin
          str  := Format(' [ %ss ]', [e.IfcType]) ;
          node2 := tvSpatialModel.Items.AddChild(node, str) ;
          {$IF CompilerVersion >= 35.0}
          node2.Checked := True ;
          {$ENDIF} ;
          lastIfcType := e.IfcType ;
        end
        else begin
          buildTree(e, node) ;
          inc(i) ;
          continue ;
        end;

        repeat
          buildTree(e, node2) ;
          inc(i) ;
          if (i < cnt) then
            e := o.Elements[i] ;
        until not ((lastIfcType = e.IfcType) and (i < cnt) ) ;
      end
    end
    else begin
      for e in o.Elements do
        buildTree(e, node) ;
    end ;

    if assigned( node ) then
      node.Expanded := node.Level <= 2 ;
  end ;

begin
  if not isIFC then
    if not assigned(model.Project) then
      exit ;

  tvSpatialModel.Items.BeginUpdate ;
  try
    tvSpatialModel.Items.Clear ;
    if not isIFC then
      buildTree(TGIS_IfcElement(model.Project), nil)
    else
      buildTree(TGIS_LayerIFC(lbim).IFCProject, nil);
  finally
    tvSpatialModel.Items.EndUpdate ;
  end ;
end ;

procedure TfrmMain.buildSpatialStructure2( const _e : TGIS_IfcElement ) ;

  procedure buildTree(const o : TGIS_IfcElement ; const _node : TTreeNode) ;
  var
    node        : TTreeNode ;
    str         : String ;
    i, cnt      : Integer ;
    lastIfcType : String ;
    node2       : TTreeNode ;
    shp         : TGIS_Shape ;
    e           : TGIS_IfcElement ;
  begin
    if (length(o.Elements) = 0) and chkGroup.Checked then
      str := Format(' %s #%d', [ IfThen( o.Name.Trim.IsEmpty, o.IfcType, o.Name ), o.Id ])
    else
      str := Format(' [ %s ] %s #%d', [o.IfcType, o.Name, o.Id]) ;

    node := tvSpatialModel.Items.AddChild(_node, str) ;
    node.Data     := o ;
    node.Expanded := node.Level <= 2 ;
    lastIfcType := '' ;

    if o.IfcType = 'IfcSpace' then begin
      {$IF CompilerVersion >= 35.0}
      node.Checked := False ;
      {$ENDIF}
      shp := lbim.FindFirst(lbim.Extent, Format('ifcProductLabel=%d', [o.Id])) ;
      if assigned(shp) then
        shp.IsHidden := True ;
    end
    else
      {$IF CompilerVersion >= 35.0}
      node.Checked := True
      {$ENDIF} ;

    if chkGroup.Checked then begin
      cnt := length(o.Elements) ;
      i := 0 ;
      while i < cnt do begin
        e := o.Elements[i] ;
        if (node.Level > 2 ) and (lastIfcType <> e.IfcType) then begin
          str  := Format(' [ %ss ]', [e.IfcType]) ;
          node2 := tvSpatialModel.Items.AddChild(node, str) ;
          {$IF CompilerVersion >= 35.0}
          node2.Checked := True ;
          {$ENDIF}
          lastIfcType := e.IfcType ;
        end
        else begin
          buildTree(e, node) ;
          inc(i) ;
          continue ;
        end;

        repeat
          buildTree(e, node2) ;
          inc(i) ;
          if (i < cnt) then
            e := o.Elements[i] ;
        until not ((lastIfcType = e.IfcType) and (i < cnt) ) ;
      end
    end
    else begin
      for e in o.Elements do
        buildTree(e, node) ;
    end ;

    if assigned( node ) then
      node.Expanded := node.Level <= 2 ;
  end ;

begin
  if not assigned(_e) then    exit ;

  tvSpatialModel.Items.BeginUpdate ;
  try
    tvSpatialModel.Items.Clear ;
    buildTree(_e, nil) ;
  finally
    tvSpatialModel.Items.EndUpdate ;
  end ;
end ;

procedure TfrmMain.chkGroupClick(Sender: TObject);
begin
  buildSpatialStructure ;
end;

procedure TfrmMain.Close1Click(Sender: TObject);
begin
  Close ;
end;

procedure TfrmMain.ExporttoSHP1Click(Sender: TObject);
var
  ll : TGIS_LayerVector ;
  {$IF CompilerVersion >= 35.0}
  ser : TJsonSerializer ;
  {$ENDIF}
begin
  if GIS.IsEmpty then exit ;

  ll := TGIS_LayerSHP.Create ;
  try
    ll.Path := ExtractFileDir(Application.ExeName) + '\export' + GetRandom(1000).ToString + '.shp' ;
    ll.BusyEvent := GISBusyEvent ;
    ll.ImportLayer( lbim, lbim.Extent, TGIS_ShapeType.MultiPatch, '', false ) ;
    ll.ParamsList.Assign(lbim.ParamsList);
    ll.ParamsList.SaveToFile( ll.Path + GIS_TTKSTYLE_EXT ) ;
    ll.ConfigName := ll.Path + GIS_TTKSTYLE_EXT ;
    ll.WriteConfig ;
    if assigned( ll.ConfigFile ) then
      TGIS_Config(ll.ConfigFile).Save ;

    if isIFC then begin
      {$IF CompilerVersion >= 35.0}
      ser := TJsonSerializer.Create;
      try
        var json := ser.Serialize<TGIS_IfcElement>( TGIS_LayerIFC(lbim).IFCProject ) ;
        var jo := (TJSONObject.ParseJSONValue(json) as TJSONObject);
        json := jo.Format(2);
        jo.Free ;
        TFile.WriteAllText( GetPathNoExt(ll.Path) + '.json', json, TEncoding.UTF8 ) ;
      finally
        ser.Free ;
      end;
      {$ENDIF}
    end;
  finally
    ll.Free ;
  end;
end;

procedure TfrmMain.ExporttoSqlite1Click(Sender: TObject);
var
  json : String ;
  path : String ;
  ll : TGIS_LayerSqlSqlite ;
  lst : TStringList ;
  {$IF CompilerVersion >= 35.0}
  ser : TJsonSerializer ;
  {$ENDIF}
  odb : TGIS_DbSqlite ;
  oDbCfg : TStringList ;
  proj : TGIS_IfcElement ;
  proj2 : Element ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;

  ll := TGIS_LayerSqlSqlite.Create ;
  try
    path := ExtractFileDir(Application.ExeName) + '\test.ttkls' ;
    lst := TStringList.Create ;
    try
      lst.Add( '['+GIS_INI_LAYER_HEADER+']' );
      lst.Add( 'Dialect=SQLITE' );
      lst.Add( 'Layer=test' );
      lst.Add( 'Storage=Native' );
      lst.Add( 'ENGINEOPTIONS=16' );
      lst.Add( 'Sqlite=test.db' ) ;
      lst.SaveToFile( path ) ;
    finally
      lst.Free ;
    end;
    ll.Path := path ;

    if isIFC then begin
      if lbim.FindField('ifcProps') = -1 then
        lbim.AddField('ifcProps', TGIS_FieldType.String, 2000, 0) ;

      {$IF CompilerVersion >= 35.0}
      ser := TJsonSerializer.Create;
      try
        for shp in lbim.Loop do begin
          var id := shp.GetField('ifcProductLabel') ;
          var elm := TGIS_LayerIFC(lbim).IFCProject.FindElement(id);
          if assigned(elm) then begin
            json := ser.Serialize<TGIS_IfcElement>( elm ) ;
            shp.MakeEditable.SetField( 'ifcProps', json ) ;
          end;
        end ;
      finally
        ser.Free ;
      end;
      {$ENDIF}
    end;

    ll.ImportLayer( lbim, lbim.Extent, TGIS_ShapeType.MultiPatch, '', false ) ;
    ll.BusyEvent := GISBusyEvent ;
    ll.ParamsList.Assign(lbim.ParamsList);
    ll.ParamsList.SaveToFile( ll.Path + GIS_TTKSTYLE_EXT ) ;
    ll.ConfigName := ll.Path + GIS_TTKSTYLE_EXT ;
    ll.WriteConfig ;
    if assigned( ll.ConfigFile ) then
      TGIS_Config(ll.ConfigFile).Save ;
  finally
    ll.Free ;
  end;

  odb := TGIS_DbSqlite.Create;
  try
    odb.InitializeProvider ;
    oDbCfg := TStringList.Create ;
    try
      oDbCfg.Values[ GIS_INI_LAYERSQL_CONNECTOR_SQLITE ] := ExtractFileDir(Application.ExeName) + '\test.db' ;
      oDbCfg.Text := oDbCfg.Text + #13#10 + GetSQLDialect( GIS_SQL_DIALECT_NAME_SQLITE );
      odb.sqlInitialize( oDbCfg, oDbCfg ) ;
      odb.sqlConnect( ExtractFileDir(Application.ExeName), oDbCfg ) ;
      try
        odb.sqlExec('CREATE TABLE ifcMetadata (name TEXT, ifcdata TEXT)');
      except
      end;

      proj := nil ;
      if isIFC then begin
        proj := TGIS_LayerIFC(lbim).IFCProject ;
        if proj = nil then exit ;
        {$IF CompilerVersion >= 35.0}
        ser := TJsonSerializer.Create;
        try
          json := ser.Serialize<TGIS_IfcElement>( proj ) ;
        finally
          ser.Free ;
        end ;
        {$ENDIF}
      end
      else begin
        proj2 := model.Project ;
        if proj2 = nil then exit ;
        {$IF CompilerVersion >= 35.0}
        ser := TJsonSerializer.Create;
        try
          json := ser.Serialize<Element>( proj2 ) ;
        finally
          ser.Free ;
        end ;
        {$ENDIF}
      end ;

      odb.sqlQueryOpen( 'select * from ifcMetadata where name=''test''', 0 ) ;
      if odb.sqlQueryEof(0) then begin
        odb.sqlQueryClose(0);
        odb.sqlTableAppend(0, 'INSERT INTO ifcMetadata (name, ifcdata) values (''test'',:ifcdata)');
        try
          odb.sqlTableSetField(0, 'ifcdata', json, -1) ;
          odb.sqlTablePost(0);
        finally
          odb.sqlTableClose(0) ;
        end ;
      end
      else begin
        odb.sqlQueryClose(0);
        odb.sqlTableOpenWrite(0, 'UPDATE ifcMetadata SET ifcdata = :ifcdata where name=''test''');
        try
          odb.sqlTableSetField(0, 'ifcdata', json, -1) ;
          odb.sqlTablePost(0);
        finally
          odb.sqlTableClose(0) ;
        end ;
      end ;
    finally
      oDbCfg.Free ;
    end;
  finally
    odb.Free ;
  end;
end;

function TfrmMain.readMetadataFromSql(const _path: String): TStream;
var
  odb : TGIS_DbSqlite ;
  oDbCfg : TStringList ;
begin
  Result := nil ;
  odb := TGIS_DbSqlite.Create;
  try
    odb.InitializeProvider ;

    oDbCfg := TStringList.Create ;
    try
      oDbCfg.Values[ GIS_INI_LAYERSQL_CONNECTOR_SQLITE ] := ExtractFileDir(_path) + '\test.db' ;
      oDbCfg.Text := oDbCfg.Text + #13#10 + GetSQLDialect( GIS_SQL_DIALECT_NAME_SQLITE );
      odb.sqlInitialize( oDbCfg, oDbCfg ) ;
      odb.sqlConnect( ExtractFileDir(Application.ExeName), oDbCfg ) ;

      odb.sqlQueryOpen( 'select * from ifcMetadata where name=''test''', 0 ) ;
      try
        if not odb.sqlQueryEof(0) then begin
          Result := odb.sqlQueryGetBlob('ifcdata', 0) ;
        end
      finally
        odb.sqlQueryClose(0);
      end;
    finally
      oDbCfg.Free ;
    end;
  finally
    odb.Free ;
  end;
end;

procedure TfrmMain.refreshLockClick(Sender: TObject);
begin
  if GIS.View3D then begin
    refreshLock.Checked := not refreshLock.Checked ;
    GIS.Viewer3D.FastMode := refreshLock.Checked ;
  end;

end;

function TfrmMain.findNodeById(const _id : Integer) : TTreeNode;
var
  i : Integer ;
  node : TTreeNode ;
  dt : TGIS_IfcElement ;
begin
  Result := nil ;
  for i := 0 to tvSpatialModel.Items.Count-1 do begin
    node := tvSpatialModel.Items[i] ;
    dt := tvSpatialModel.Items[i].Data ;
    if assigned( dt ) and (TGIS_IfcElement(dt).Id = _id) then begin
      Result := node ;
      break ;
    end;
  end;
end;

function TfrmMain.parseElement(const _data : String) : TGIS_IfcElement;
{$IF CompilerVersion >= 35.0}
var
  json_slr : TJsonSerializer ;
{$ENDIF}
begin
  {$IF CompilerVersion >= 35.0}
  json_slr := TJsonSerializer.Create ;
  try
    Result := json_slr.Deserialize<TGIS_IfcElement>( _data ) ;
  finally
    FreeObject( json_slr ) ;
  end ;
  {$ELSE}
  Result := nil ;
  {$ENDIF}
end;

procedure TfrmMain.tmrDemoTimer(Sender: TObject);
var
  factor : Double ;
  val    : Double       ;
  cam    : TGIS_Point3D ;
begin
  if not GIS.View3D then exit ;

  factor := 0.01 ;
  val := factor * DegToRad( 15 ) ;
  cam := GIS.Viewer3D.CameraPosition ;
  cam.Y := cam.Y + val ;
  GIS.Viewer3D.CameraPosition := cam ;
end;

{$IF CompilerVersion >= 35.0}
procedure TfrmMain.tvSpatialModelCheckStateChanged(Sender: TCustomTreeView;
  Node: TTreeNode; CheckState: TNodeCheckState);
begin
  if tvSpatialModel.IsDrawingLocked then exit ;

  for var I := 0 to Node.Count-1 do
    Node.Item[I].CheckState := CheckState;

  var elm := TGIS_IfcElement(Node.Data) ;
  if not assigned( elm ) then exit ;

  var shp := lbim.FindFirst(lbim.Extent, Format('ifcProductLabel=%d', [elm.Id])) ;

  while assigned(shp) do begin
    shp.IsHidden := not Node.Checked ;
    wasCheck := True ;
    shp := lbim.FindNext ;
  end ;
end;
{$ENDIF}

procedure TfrmMain.tvSpatialModelClick(Sender : TObject) ;
var
  node : TTreeNode ;
  shp : TGIS_Shape ;
  elm : TGIS_IfcElement ;
begin
  node := tvSpatialModel.Selected ;
  if not assigned(node) then exit ;

  lvAttributes.Items.BeginUpdate ;
  try
    if not assigned( node.Data ) then exit ;

    showAttributes(TGIS_IfcElement(node.Data)) ;
    shp := lbim.FindFirst(lbim.Extent, Format('ifcProductLabel=%d', [TGIS_IfcElement(node.Data).Id])) ;
    lbim.DeselectAll ;
    GIS.Lock ;
    try
      while assigned(shp) do begin
        shp.IsSelected := True ;
        shp := lbim.FindNext ;
      end ;
    finally
      GIS.Unlock ;
    end;
  finally
    lvAttributes.Items.EndUpdate ;
  end ;

  if (lbim is TGIS_LayerIFC) and assigned( TGIS_LayerIFC(lbim).IFCProject ) then
    elm := TGIS_LayerIFC(lbim).IFCProject.FindElement( TGIS_IfcElement(node.Data).Id ) ;
end ;

procedure TfrmMain.tvSpatialModelDblClick(Sender: TObject);
var
  node : TTreeNode ;
  shp : TGIS_Shape ;
  ext : TGIS_Extent ;
begin
  node := tvSpatialModel.Selected ;
  if not assigned(node) then exit ;
  if not assigned( node.Data ) then exit ;

  shp := lbim.FindFirst(lbim.Extent, Format('ifcProductLabel=%d', [TGIS_IfcElement(node.Data).Id])) ;
  if assigned(shp) then begin
    ext := shp.Extent ;
    while assigned( shp ) do begin
      ext := GisMaxExtent( ext, shp.Extent ) ;
      shp := lbim.FindNext ;
    end;
    if GIS.View3D then
      GIS.Viewer3D.VisibleExtent := ext
    else
      GIS.VisibleExtent := ext ;
  end ;
end;

procedure TfrmMain.tvSpatialModelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if wasCheck then
    GIS.InvalidateWholeMap ;
  wasCheck := False ;
end;

procedure TfrmMain.showAttributes(const _e : TGIS_IfcElement) ;
var
  grp : TListGroup ;
  li : TListItem ;
  ps : TGIS_IfcElementPropertySet ;
  pi : TGIS_IfcPropertyInfo ;
begin
  if not assigned(_e) then
    exit ;

  lvAttributes.Items.BeginUpdate ;
  lvAttributes.Groups.BeginUpdate ;
  try
    lvAttributes.Items.Clear ;
    lvAttributes.Groups.Clear ;

    grp    := lvAttributes.Groups.Add ;
    grp.Header := 'General' ;

    li     := lvAttributes.Items.Add ;
    li.Caption := 'Id' ;
    li.SubItems.Add(_e.Id.ToString) ;
    li.GroupID := grp.GroupID ;

    li         := lvAttributes.Items.Add ;
    li.Caption := 'Name' ;
    li.SubItems.Add(_e.Name) ;
    li.GroupID := grp.GroupID ;

    li         := lvAttributes.Items.Add ;
    li.Caption := 'IfcType' ;
    li.SubItems.Add(_e.IfcType) ;
    li.GroupID := grp.GroupID ;

    li         := lvAttributes.Items.Add ;
    li.Caption := 'Guid' ;
    li.SubItems.Add(_e.Guid) ;
    li.GroupID := grp.GroupID ;

    for ps in _e.PropertySets do begin
      grp        := lvAttributes.Groups.Add ;
      grp.Header := ps.SetName ;
      for pi in ps.Properties do begin
        li         := lvAttributes.Items.Add ;
        li.Caption := pi.Name ;
        li.SubItems.Add(pi.Value) ;
        li.GroupID := grp.GroupID ;
      end ;
    end ;
  finally
    lvAttributes.Items.EndUpdate ;
    lvAttributes.Groups.EndUpdate ;
  end;
end ;

end.
