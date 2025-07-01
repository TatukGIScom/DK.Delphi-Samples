//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform Buffer operation
}

unit Unit1;


interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    TrackBar1: TTrackBar;
    btnPlus: TToolButton;
    btnMinus: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnMinusClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  shp_id : Integer;

implementation

uses
  GisAllLayers ;
{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  lb : TGIS_LayerVector ;
begin
  // open a project
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology.shp' ) ;
  shp_id := 2;
  // create a layer for buffer
  lb := TGIS_LayerVector.Create ;
  lb.Name := 'buffer' ;
  lb.Transparency := 50 ;
  lb.Params.Area.Color := TGIS_Color.Red ;
  GIS.Add( lb ) ;
  GIS.Unlock;
  GIS.FullExtent ;
end;

procedure TForm1.btnPlusClick(Sender: TObject);
begin
  // change bar position and recalculate buffer
  TrackBar1.Position := TrackBar1.Position + 1 ;
end;

procedure TForm1.btnMinusClick(Sender: TObject);
begin
  // change bar position and recalculate buffer
  TrackBar1.Position := TrackBar1.Position - 1 ;
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    ptg : TGIS_Point ;
    shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // locate a shape after click
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision

  // remember id to use buffer on selected shape
  if shp <> nil then
  begin
      shp_id := shp.Uid ;
      shp.Flash ;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  lb  : TGIS_LayerVector ;
  shp : TGIS_Shape       ;
  tmp : TGIS_Shape       ;
  tpl : TGIS_Topology    ;
begin
  ll := TGIS_LayerVector(GIS.Items[0]) ;
  if not Assigned( ll ) then exit ;

  lb := TGIS_LayerVector( GIS.Get( 'buffer' ) ) ;
  if not Assigned( lb ) then exit ;

  shp := ll.GetShape( shp_id ) ;
  if not Assigned( shp ) then exit ;

  // create a buffer using topology
  tpl := TGIS_Topology.Create ;
  try
    lb.RevertShapes ;
    tmp := tpl.MakeBuffer( shp, TrackBar1.Position * 1000 ) ;
    if Assigned( tmp ) then
    begin
      lb.AddShape( tmp ) ;
      tmp.Free ;
    end ;
    // check extents
    ll.RecalcExtent ;
    lb.RecalcExtent ;
    GIS.RecalcExtent ;
    GIS.FullExtent ;
  finally
    tpl.Free ;
  end ;
end;

end.
