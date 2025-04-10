//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to create tracked layer.
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
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
  GisEditor,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    btnAnimate: TButton;
    chkUseLock: TCheckBox;
    ToolButton1: TToolButton;
    procedure btnAnimateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnAnimateClick(Sender: TObject);
var
  i,j   : Integer    ;
  shp : TGIS_Shape ;
  pt : TGIS_Point ;
  delta : Integer ;
begin
  btnAnimate.Enabled := False ;

  for i:=0 to 90 do
  begin
    if chkUseLock.Checked then
    begin
      GIS.Lock ;
    end ;

    // move plains
    for j :=1 to 90 do
    begin
      shp := TGIS_LayerVector( GIS.Items[1] ).GetShape( j ) ;
      pt := shp.Centroid ;
      delta := j mod 3 -1 ;
      shp.SetPosition( TGIS_Utils.GisPoint( pt.X + delta, pt.Y  ), nil, 0 ) ;
      Application.ProcessMessages ;
    end ;

    if chkUseLock.Checked then
    begin
      GIS.UnLock ;
      GIS.Invalidate;
      Application.ProcessMessages ;
    end
    else
    //  GIS.LabelsReg.Reset ;
  end ;

  btnAnimate.Enabled := True ;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  i   : Integer    ;
  shp : TGIS_Shape ;
begin
  GIS.Lock ;
  try
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg' );
    GIS.Zoom := GIS.Zoom * 2 ;

    // create a layer and add a field
    ll := TGIS_LayerVector.Create ;
    ll.Params.Marker.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\2267.cgm' ) ;
    ll.Params.Marker.SymbolRotate := Pi/2 ;
    ll.Params.Marker.Size := -20 ;
    ll.Params.Line.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\1301.cgm' ) ;
    ll.Params.Line.Width   := -5 ;
    ll.CachedPaint := False ;
    ll.CS := GIS.CS ;
    GIS.Add( ll ) ;
  finally
    GIS.Unlock ;
  end;
  ll.AddField('Name', TGIS_FieldType.String, 255, 0 ) ;
  ll.Params.Labels.Field := 'Name' ;

  // add random plains
  for i:=0 to 100 do
  begin
    shp := TGIS_LayerVector( GIS.Items[1] ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.SetField('Name', IntToStr( i+1 ));
    shp.Params.Marker.SymbolRotate := DegToRad( Random( 360 ) ) ;
    shp.Params.Marker.Color := TGIS_Color.FromRGB( Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) );
    shp.Params.Marker.OutlineColor := shp.Params.Marker.Color ;
    shp.Lock( TGIS_Lock.Extent );
    shp.AddPart ;
    shp.AddPoint( TGIS_Utils.GisPoint( -180 + Random( 360 ) , ( 90 - Random( 180 ) )) );
    shp.UnLock;
  end ;

end;


end.
