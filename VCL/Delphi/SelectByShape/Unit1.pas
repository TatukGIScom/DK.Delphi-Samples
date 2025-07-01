//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform Circle/Rectangle buffer operation.
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
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.Buttons,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisRendererAbstract,
  GISTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    ToolBar1: TToolBar;
    btnRect: TSpeedButton;
    btnCircle: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
  private
    { Private declarations }
    oldPos1   : TPoint      ;
    oldPos2   : TPoint      ;
    oldRadius : Integer     ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisAllLayers ;

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload+'\World\Countries\USA\States\California\Counties.shp' );

  ll := TGIS_layerVector.Create;
  ll.Params.Area.color := TGIS_Color.Blue;
  ll.Transparency := 50;
  ll.Name := 'Points';
  ll.CS := GIS.CS ;
  GIS.Add( ll );

  ll := TGis_layerVector.Create;
  ll.Params.Area.color := TGIS_Color.Blue;
  ll.Params.Area.OutlineColor := TGIS_Color.Blue;
  ll.Transparency := 60;
  ll.Name := 'Buffers';
  ll.CS := GIS.CS ;
  GIS.Add( ll );
  GIS.Unlock;
  btnRect.Down := true;
end;

procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ll        : TGis_LayerVector;
  tmp       : TGis_Shape;
  buf       : TGis_Shape;
  ptg       : TGis_Point;
  ptg1      : TGis_Point;
  ptg2      : TGis_Point;
  distance  : double;
  tpl       : TGIS_Topology;
begin
  if GIS.IsEmpty then exit ;

  buf := nil ;

  if Button = mbRight then
  begin
   GIS.mode := TGIS_ViewerMode.Select;
   exit;
  end;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit ;
  if btnRect.Down then
    if ( oldPos2.X = oldPos1.X ) and ( oldPos2.Y = oldPos1.Y ) then exit  ;
  if btnCircle.Down then
    if oldRadius  = 0 then exit;

  ll := TGIS_LayerVector( GIS.Get( 'Points' ) ) ;
  ll.Lock;
  tmp := ll.CreateShape(TGIS_ShapeType.Point);
  tmp.Params.Marker.Size := 0;
  tmp.Lock(TGIS_Lock.Extent);
  tmp.AddPart;

  if btnCircle.Down then begin
    ptg := Gis.ScreenToMap(oldPos1);
    ll := TGIS_LayerVector( GIS.Get( 'Points' ) ) ;
    ll.Lock;
    tmp := ll.CreateShape(TGIS_ShapeType.Point);
    tmp.Params.Marker.Size := 0;
    tmp.Lock(TGIS_Lock.Extent);
    tmp.AddPart;
    tmp.AddPoint( ptg );
    tmp.Unlock;
    ll.Unlock;
    ptg1 := GIS.ScreenToMap( Point( oldPos1.X + oldRadius, Y ) ) ;
  end;

  if btnRect.Down then begin
    ptg := Gis.ScreenToMap(oldPos1);
    tmp.AddPoint( ptg );
    tmp.Unlock;
    tmp := ll.CreateShape(TGIS_ShapeType.Point);
    tmp.Params.Marker.Size := 0;
    tmp.Lock(TGIS_Lock.Extent);
    tmp.AddPart;
    ptg := Gis.ScreenToMap(oldPos2);
    tmp.AddPoint( ptg );
    tmp.Unlock;
    ll.Unlock;
    ptg1 := Gis.ScreenToMap(oldPos1);
  end;

  ll := TGIS_LayerVector( GIS.Get('Buffers') ) ;
  ll.RevertShapes;



  if btnCircle.Down then begin
    distance := ptg1.X - ptg.X ;

    tpl := TGIS_Topology.Create ;
    try
      buf := tpl.MakeBuffer( tmp, distance, 32, True ) ;
      buf := ll.AddShape( buf ) ;
    finally
      tpl.Free ;
    end ;
  end;

  if btnRect.Down then begin
    ptg2 := Gis.ScreenToMap(oldPos2);
    buf := ll.CreateShape( TGIS_ShapeType.Polygon ) ;
    buf.AddPart ;
    buf.AddPoint( ptg1 ) ;
    buf.AddPoint( TGIS_Utils.GisPoint( ptg1.X, ptg2.Y ) ) ;
    buf.AddPoint( ptg2 ) ;
    buf.AddPoint( TGIS_Utils.GisPoint( ptg2.X, ptg1.Y ) ) ;
  end;


  ll := TGIS_LayerVector( GIS.Items[0] ) ;
  if not Assigned( ll ) then begin
    Gis.InvalidateWholeMap;
    exit ;
  end;

  ll.DeselectAll ;

  Gis.InvalidateWholeMap;

  Memo1.Clear ;
  Memo1.Lines.BeginUpdate ;
  GIS.Lock ;
  // check all shapes

  if not (btnRect.Down or btnCircle.Down) then begin
    MessageBox(Handle, 'Please select mode first', 'Select mode', MB_OK);
    exit;
  end;


  tmp := ll.FindFirst( buf.Extent, '', buf, RELATE_INTERSECT );
  while Assigned( tmp ) do
  begin
    // if any has a common point with buffer mark it
    Memo1.Lines.Add( tmp.GetField( 'name' ) ) ;
    tmp.IsSelected := True ;
    tmp := ll.FindNext ;
  end ;
  GIS.UnLock ;
  Memo1.Lines.EndUpdate ;
end;

procedure TForm1.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
var
  rdr : TGIS_RendererAbstract ;
begin
  rdr := _renderer ;
  rdr.CanvasPen.Width   := 1 ;
  rdr.CanvasPen.Color   := TGIS_Color.FromBGR( Cardinal(Random( $FFFFFF )) ) ;
  rdr.CanvasPen.Style := TGIS_PenStyle.Solid ;
  rdr.CanvasBrush.Style := TGIS_BrushStyle.Clear ;
  if btnRect.Down then begin
    if (oldPos1.X = oldPos2.X) and (oldPos1.Y = oldPos2.Y) then exit ;
    rdr.CanvasDrawRectangle( Rect( oldPos1.X, oldPos1.Y, oldPos2.X, oldPos2.Y ) ) ;
  end;
  if btnCircle.Down then begin
    rdr.CanvasDrawEllipse(oldPos1.X - Round(oldRadius), oldPos1.Y - Round(oldRadius),
                          oldRadius * 2, oldRadius * 2);
  end;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if GIS.IsEmpty then exit ;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit ;
  if not ( ssLeft in Shift ) then exit ;

  if btnRect.Down then
     oldPos2 := Point( X, Y ) ;

  if btnCircle.Down then begin
    oldRadius := Round(Sqrt( Sqr( oldPos1.X - X ) + Sqr( oldPos1.Y - Y ) ) );
  end;


  GIS.Invalidate
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  if Button = mbRight then
  begin
    GIS.Mode := TGIS_ViewerMode.Zoom;
    exit;
  end;

  oldPos1   := Point( X, Y )  ;
  oldPos2   := Point( X, Y )  ;
  oldRadius := 0              ;
end;

end.
