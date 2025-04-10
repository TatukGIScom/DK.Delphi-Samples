//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to perform Buffer operation.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisLayer,
  GisParams,
  GisTopology,
  GisRegistredLayers,
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
    Timer1: TTimer;
    btnPlus: TToolButton;
    btnMinus: TToolButton;
    ImageList1: TImageList;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnMinusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  la : TGIS_Layer ;
  lb : TGIS_LayerVector ;

begin
  la := GisCreateLayer(
          'counties',
          TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp'
        ) ;
  GIS.Lock;
  GIS.Add( la ) ;

  lb := TGIS_LayerVector.Create ;
  lb.Name := 'buffer' ;
  lb.Transparency := 70 ;
  lb.Params.Area.Color := TGIS_Color.Yellow ;
  lb.CS := GIS.CS ;
  GIS.Unlock;
  GIS.Add( lb ) ;

  GIS.FullExtent ;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  lb  : TGIS_LayerVector ;
  shp : TGIS_Shape       ;
  tmp : TGIS_Shape       ;
  buf : TGIS_Shape       ;
  tpl : TGIS_Topology    ;
begin
  Timer1.Enabled := False ;

  try
    // find buffer
    ll := TGIS_LayerVector( GIS.Get( 'counties' ) ) ;
    if not Assigned( ll ) then exit ;
    lb := TGIS_LayerVector( GIS.Get( 'buffer' ) ) ;
    if not Assigned( lb ) then exit ;

    shp := ll.FindFirst( TGIS_Utils.GisWholeWorld, 'NAME=''Merced''' ) ;

    if not Assigned( shp ) then exit ;

    tpl := TGIS_Topology.Create ;
    try
      lb.RevertShapes ;
      tmp := tpl.MakeBuffer( shp, TrackBar1.Position / 100 ) ;
      if Assigned( tmp ) then begin
        buf := lb.AddShape( tmp ) ;
        tmp.Free ;
      end else
        buf := nil ;
    finally
      tpl.Free ;
    end ;


    // find all states crossing by buffer
    if not Assigned( buf ) then exit ;

    ll := TGIS_LayerVector( GIS.Get( 'counties' ) ) ;
    ll.IgnoreShapeParams := False ;
    if not Assigned( ll ) then exit ;
    ll.RevertShapes ;
    Memo1.Clear ;
    Memo1.Lines.BeginUpdate ;

    // check all shapes
    tmp := ll.FindFirst( buf.Extent );
    while Assigned( tmp ) do begin
      // if any has a common point with buffer mark it as blue
      if buf.IsCommonPoint( tmp ) then begin
        tmp := tmp.MakeEditable ;
        Memo1.Lines.Add( tmp.GetField( 'name' ) ) ;
        tmp.Params.Area.Color := TGIS_Color.Blue ;
      end;
      tmp := ll.FindNext ;
    end ;
    Memo1.Lines.EndUpdate ;

  finally
    GIS.InvalidateWholeMap ;
  end ;

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Timer1.Enabled := False ;
  StatusBar1.SimpleText := IntToStr( TrackBar1.Position ) + ' km' ;
  Timer1.Enabled := True ;
end;

procedure TForm1.btnPlusClick(Sender: TObject);
begin
  TrackBar1.Position := TrackBar1.Position + 5 ;
  Timer1Timer( Self ) ;
end;

procedure TForm1.btnMinusClick(Sender: TObject);
begin
  TrackBar1.Position := TrackBar1.Position - 5 ;
  Timer1Timer( Self ) ;
end;

end.
