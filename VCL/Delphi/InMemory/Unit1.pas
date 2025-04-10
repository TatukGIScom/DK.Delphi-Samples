//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to add in-memory layers.
}

unit Unit1;


interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,

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
  GisEditor,
  GisLayerVector,
  GisSymbol,
  GisParams,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GIS: TGIS_ViewerWnd;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.Button1Click(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  // create a layer loading symbols for marker and line
  ll := TGIS_LayerVector.Create ;
  ll.Params.Marker.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\2267.cgm' ) ;
  ll.Params.Marker.SymbolRotate := Pi/2 ;
  ll.Params.Marker.Size := -20 ;
  ll.Params.Line.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\1301.cgm' ) ;
  ll.Params.Line.Width   := -5 ;
  GIS.Add( ll ) ;
  ll.CachedPaint := False ;
  ll.Extent := TGIS_Utils.GisExtent( -180, -90, 180, 90 ) ;
  GIS.FullExtent ;
  StatusBar1.SimpleText :=' Layer created.' ;
  Button1.Enabled :=false ;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i   : Integer    ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then begin
    ShowMessage( 'Create a layer first !' ) ;
    exit ;
  end ;

  // fill the viewer with points
  for i:=0 to 100 do begin
    shp := TGIS_LayerVector( GIS.Items[0] ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.Params.Marker.SymbolRotate := DegToRad( Random( 360 ) ) ;
    shp.Params.Marker.Color := TGIS_Color.FromRGB(Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
    shp.Params.Marker.OutlineColor := shp.Params.Marker.Color ;
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;
    shp.AddPoint( TGIS_Utils.GisPoint( Random( 360 ) - 180 , Random( 180 ) - 90 ) ) ;
    shp.UnLock ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.Button3Click(Sender: TObject) ;
var
  i   : Integer    ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then begin
    ShowMessage( 'Create a layer first !' ) ;
    exit ;
  end ;

  // add lines
  Assert( GIS.Items.Count > 0 ) ;
  shp := TGIS_LayerVector( GIS.Items[0] ).CreateShape( TGIS_ShapeType.Arc ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  for i:=0 to 20 do
  begin
    shp.AddPoint( TGIS_Utils.GisPoint( Random( 360 ) - 180 , Random( 180 ) - 90 ) ) ;
  end ;
  shp.Unlock ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i   : Integer    ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then
  begin
    ShowMessage( 'Create a layer first !' ) ;
    exit ;
  end ;

  // create a ship and fly
  Assert( GIS.Items.Count > 0 ) ;
  shp := TGIS_LayerVector( GIS.Items[0] ).CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0 , 0 ) );

  shp.Params.Marker.Color := TGIS_Color.Blue ;
  shp.Params.Marker.OutlineColor := TGIS_Color.Blue ;
  shp.Params.Marker.Size := -20 ;

  shp.Unlock ;
  shp.Invalidate ;

  for i:=0 to 90 do
  begin
    shp.SetPosition( TGIS_Utils.GisPoint( i * 2, i ), nil, 0 ) ;
    Sleep( 10 ) ;
    Application.ProcessMessages ;
  end ;

end;

end.
