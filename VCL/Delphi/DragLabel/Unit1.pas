//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to construct draggable labels
}

unit Unit1;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisInterfaces,
  GisLayer,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    currShape : TGIS_Shape ;
    procedure doLabelPaint( _sender : TObject            ;
                            _shape  : TGIS_Shape
                          )  ;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  LABEL_TEXT = 'Ship ' ;

implementation

uses
  GisRendererAbstract ;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  i   : Integer    ;
  shp : TGIS_Shape ;

  procedure synchroMove( _shp : TGIS_Shape ; _x,_y : Integer ) ;
  var
    ll  : TGIS_LayerVector ;
    shp : TGIS_Shape ;
    ptgA : TGIS_Point ;
    ptgB : TGIS_Point ;
    ex  : TGIS_Extent ;
  begin
    // move main shape
    ptgA := _shp.GetPoint( 0, 0 ) ;
    ptgA.x := ptgA.X + _x ;
    ptgA.Y := ptgA.Y + _y ;
    _shp.SetPosition( ptgA , nil, 0 ) ;

    // move "sidekick"
    ll := TGIS_LayerVector( GIS.Get( 'sidekicks' ) ) ;
    shp := ll.GetShape( _shp.Uid ) ;
    ptgB := shp.GetPoint( 0, 0 ) ;
    ptgB.x := ptgB.X + _x ;
    ptgB.Y := ptgB.Y + _y ;
    shp.SetPosition( ptgB , nil, 0 ) ;

    // aditional invalidation - we have now a starnge big
    // combo shape
    ex.XMin := Min( ptgA.X, ptgB.X ) ;
    ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
    ex.XMax := Max( ptgA.X, ptgB.X ) ;
    ex.YMax := Max( ptgA.Y, ptgB.Y ) ;
  end ;

begin
  shp := TGIS_LayerVector( GIS.Get( 'realpoints' ) ).GetShape( 5 ) ;
  for i:=0 to 90 do begin
    synchroMove( shp, 2, 1 ) ;
    Sleep( 100 ) ;
    Application.ProcessMessages ;
  end ;
end;

procedure TForm1.doLabelPaint(
  _sender : TObject ;
  _shape  : TGIS_Shape
) ;
var
  ptA, ptB : TPoint ;
  ll : TGIS_LayerVector ;
  shp : TGIS_Shape ;
  rdr : TGIS_RendererAbstract ;
begin
  // draw line to real point
  ll := TGIS_LayerVector( GIS.Get('realpoints') ) ;
  shp := ll.GetShape( _shape.Uid ) ;
  ptA := _shape.Viewer.Ref.MapToScreen( shp.GetPoint( 0, 0 ) ) ;
  ptB := _shape.Viewer.Ref.MapToScreen( _shape.GetPoint( 0, 0 ) ) ;

  rdr := GIS.Renderer as TGIS_RendererAbstract ;
  with rdr do
  begin
   CanvasPen.Color := TGIS_Color.Blue ;
   CanvasPen.Style := TGIS_PenStyle.Solid ;
   CanvasPen.Width := 1 ;
   CanvasDrawLine( ptA.x, ptA.y, ptB.x, ptB.y ) ;
  end ;
  // draw label itself
  _shape.Params.Labels.Value := shp.GetField('name') ;
  _shape.DrawLabel ;
end ;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ll  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // start editing of some shape from sidekicks
  ll := TGIS_LayerVector( GIS.Get('sidekicks') ) ;
  shp := ll.Locate( GIS.ScreenToMap( Point(x,y) ), 100/GIS.Zoom ) ;
  currShape := shp ;

  if currShape = nil then exit ;
  // we are not changing the GIS.Mode to TGIS_ViewerMode.Edit because we want to control
  // editing on our own, so instead we will call MouseBegin, MouseMove and MouseEnd
  // "manually"
  GIS.Editor.MouseBegin( Point(x,y), True ) ;
end;

procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;
  currShape := nil ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ll  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
  ptgA : TGIS_Point ;
  ptgB : TGIS_Point ;
    ex  : TGIS_Extent ;
begin
  if GIS.IsEmpty then exit ;
  if currShape = nil then exit ;

  // aditional invalidation - we have now a strange big
  // combo shape
  ptgA := currShape.GetPoint( 0, 0 ) ;
  ll  := TGIS_LayerVector( GIS.Get( 'realpoints' ) ) ;
  shp := ll.GetShape( currShape.Uid ) ;
  ptgB := shp.GetPoint( 0, 0 ) ;
  ex.XMin := Min( ptgA.X, ptgB.X ) ;
  ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax := Max( ptgA.X, ptgB.X ) ;
  ex.YMax := Max( ptgA.Y, ptgB.Y ) ;
  //GIS.InvalidateWholeMap;

  ptgA := GIS.ScreenToMap( Point(x,y) ) ;
  if TGIS_Utils.GisIsPointInsideExtent( ptgA, GIS.Extent ) then
    currShape.SetPosition( ptgA, nil, 0 );

  // aditional invalidation - we have now a starnge big
  // combo shape
  ptgA := currShape.GetPoint( 0, 0 ) ;
  ll  := TGIS_LayerVector( GIS.Get( 'realpoints' ) );
  shp := ll.GetShape( currShape.Uid ) ;
  ptgB := shp.GetPoint( 0, 0 ) ;
  ex.XMin := Min( ptgA.X, ptgB.X ) ;
  ex.YMin := Min( ptgA.Y, ptgB.Y ) ;
  ex.XMax := Max( ptgA.X, ptgB.X ) ;
  ex.YMax := Max( ptgA.Y, ptgB.Y ) ;
  // GIS.InvalidateWholeMap ;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  i   : Integer    ;
  shp : TGIS_Shape ;
  ptg : TGIS_Point ;
begin
  // create real point layer
  ll := TGIS_LayerVector.Create ;
  ll.Params.Marker.Symbol := SymbolList.Prepare(
    TGIS_Utils.GisSamplesDataDirDownload +
    '\Symbols\2267.cgm'
  ) ;
  ll.Name:='realpoints' ;
  ll.CachedPaint := False ;

  GIS.Add( ll ) ;
  ll.AddField( 'name', TGIS_FieldType.String, 100, 0 );
  ll.Extent := TGIS_Utils.GisExtent( -180, -180, 180, 180 ) ;

  // create display sidekick
  ll := TGIS_LayerVector.Create ;
  ll.Name:='sidekicks' ;
  ll.Params.Marker.Size := 0 ;
  ll.Params.Labels.Position := [TGIS_LabelPosition.MiddleCenter] ;
  ll.CachedPaint := False ;

  GIS.Add( ll ) ;
  ll.PaintShapeLabelEvent := doLabelPaint ;
  ll.Params.Labels.Allocator := False ;

  // add points
  for i:=0 to 20 do begin
    ptg := TGIS_Utils.GisPoint( Random( 360 ) - 180 , Random( 180 ) - 90 ) ;

    // add a real point
    shp := TGIS_LayerVector( GIS.Get('realpoints') ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;
    shp.AddPoint( ptg );
    shp.Params.Marker.SymbolRotate := (shp.Uid);
    shp.Params.Marker.Size :=250;
    shp.Params.Marker.Color := TGIS_Color.FromRGB( Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;

    shp.SetField( 'name', Format( LABEL_TEXT + ': %d', [shp.Uid] ) );
    shp.Unlock ;

    // add sideckicks
    shp := TGIS_LayerVector( GIS.Get('sidekicks') ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;

    // with a small offset
    ptg.x := ptg.x + 15/GIS.Zoom ;
    ptg.y := ptg.y + 15/GIS.Zoom ;
    shp.AddPoint( ptg );
    shp.Unlock ;
  end ;

  GIS.FullExtent ;
end;

end.
