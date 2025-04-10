//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  Use TGIS_LayerPixel.LockPixels & Loop to edit pixel content.
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  GisAllLayers,
  GisUtils,
  GisTypes,
  GisTypesUI,
  GisCsFactory,
  GisLayerVector,
  GisLayerPixel,
  GisLayerJpg,
  GisLayerGrd,
  VCL.GisViewerWnd,
  VCL.GisControlLegend ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    btnProfile: TButton;
    btnMinMax: TButton;
    btnAvargeColor: TButton;
    btnCreateBitmap: TButton;
    btnCreateGrid: TButton;
    GIS_Legend: TGIS_ControlLegend;
    Memo1: TMemo;
    procedure btnProfileClick(Sender: TObject);
    procedure btnMinMaxClick(Sender: TObject);
    procedure btnAvargeColorClick(Sender: TObject);
    procedure btnCreateBitmapClick(Sender: TObject);
    procedure btnCreateGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnAvargeColorClick(Sender: TObject);
var
  lp     : TGIS_LayerPixel  ;
  lv     : TGIS_LayerVector ;
  shp    : TGIS_Shape       ;
  px     : TGIS_PixelItem   ;
  r,g,b  : Double           ;
  cnt    : Integer          ;
  cl     : TGIS_Color       ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\bitmap.ttkproject' ) ;

  lp := TGIS_LayerPixel( GIS.Get( 'bluemarble' ) ) ;
  lv := TGIS_LayerVector( GIS.Get( 'countries' ) ) ;

  shp := lv.GetShape( 679 ).MakeEditable ; // Spain
  GIS.Lock ;
  GIS.VisibleExtent := shp.ProjectedExtent ;
  GIS.Zoom := GIS.Zoom / 2.0 ;
  GIS.Unlock ;

  cnt := 0 ;
  r := 0;
  g := 0;
  b := 0;

  for px in lp.Loop( shp.Extent, 0, shp, 'T', false ) do begin
    r := r + px.Color.R ;
    g := g + px.Color.G ;
    b := b + px.Color.B ;
    Inc( cnt ) ;
  end;

  if cnt > 0 then begin
    cl := TGIS_Color.FromRGB( Trunc(r/cnt) , Trunc(g/cnt), Trunc(b/cnt) ) ;
    for px in lp.Loop( shp.Extent, 0, shp, 'T', true ) do begin
      px.Color := cl ;
    end;
  end;

  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnCreateBitmapClick(Sender: TObject);
var
  lp : TGIS_LayerJPG ;
  lck : TGIS_LayerPixelLock ;
  x, y : Integer ;
  test_jpg : string  ;
begin
  Memo1.Clear ;

  test_jpg := 'test.jpg';
  if FileExists(test_jpg) then
    DeleteFile(test_jpg);

  lp := TGIS_LayerJPG.Create ;
  try
    lp.Build( test_jpg, TGIS_CSFactory.ByEPSG( 4326 ),
              TGIS_Utils.GisExtent( -180, -90, 180, 90 ), 360, 180
            ) ;

    // direct access to pixels
    lck := lp.LockPixels( TGIS_Utils.GisExtent( -45, -45, 45, 45 ), lp.CS, True ) ;
    try
      for x := lck.Bounds.Left to lck.Bounds.Right do begin
        for y := lck.Bounds.Top to lck.Bounds.Bottom do begin
          lck.Bitmap[ lck.BitmapPos(x,y) ] := Integer( TGIS_Color.Red.ARGB );
        end;
      end;
    finally
      lp.UnlockPixels( lck );
    end;

    lp.SaveData ;
  finally
    lp.Free ;
  end;

  GIS.Open( test_jpg ) ;
end;

procedure TForm1.btnCreateGridClick(Sender: TObject);
var
  lp : TGIS_LayerGRD ;
  lck : TGIS_LayerPixelLock ;
  x, y : Integer ;
  test_grd : string ;
begin
  Memo1.Clear ;

  test_grd := 'test.grd';
  if FileExists(test_grd) then
    DeleteFile(test_grd);

  lp := TGIS_LayerGRD.Create ;
  try
    lp.Build( test_grd, TGIS_CSFactory.ByEPSG( 4326 ),
              TGIS_Utils.GisExtent( -180, -90, 180, 90 ), 360, 180
            ) ;

    // direct access to pixels
    lck := lp.LockPixels( TGIS_Utils.GisExtent( -45, -45, 45, 45 ), lp.CS, True ) ;
    try
      for x := lck.Bounds.Left to lck.Bounds.Right do begin
        for y := lck.Bounds.Top to lck.Bounds.Bottom do begin
          lck.Grid[y][x] := Random(100) ;
        end;
      end;
    finally
      lp.UnlockPixels( lck );
    end;

    lp.SaveData ;
  finally
    lp.Free ;
  end;

  GIS.Open( test_grd ) ;
end;

procedure TForm1.btnMinMaxClick(Sender: TObject);
var
  lp     : TGIS_LayerPixel  ;
  lv     : TGIS_LayerVector ;
  ltmp   : TGIS_LayerVector ;
  shp    : TGIS_Shape       ;
  shptmp : TGIS_Shape       ;
  px     : TGIS_PixelItem  ;
  dmin,
  dmax  : Double ;
  ptmin,
  ptmax : TGIS_Point ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\grid.ttkproject' ) ;

  lp := TGIS_LayerPixel( GIS.Get( 'elevation' ) ) ;
  lv := TGIS_LayerVector( GIS.Get( 'polygon' ) ) ;
  shp := lv.GetShape( 1 ).MakeEditable ;
  shp.IsSelected := True ;

  dmax := -1e38 ;
  dmin :=  1e38 ;
  for px in lp.Loop( shp.Extent, 0, shp, 'T', false ) do begin
    if px.Value < dmin then begin
      dmin  := px.Value  ;
      ptmin := px.Center ;
    end;

    if px.Value > dmax then begin
      dmax  := px.Value  ;
      ptmax := px.Center ;
    end;
  end;

  ltmp := TGIS_LayerVector.Create ;
  ltmp.CS := lp.CS ;
  GIS.Add( ltmp );

  ltmp.Params.Marker.Style := TGIS_MarkerStyle.Cross ;
  ltmp.Params.Marker.Size := -10 ;
  ltmp.Params.Marker.Color := TGIS_Color.Black  ;

  shptmp := ltmp.CreateShape( TGIS_ShapeType.Point ) ;
  shptmp.AddPart ;
  shptmp.AddPoint( ptmin ) ;

  shptmp := ltmp.CreateShape( TGIS_ShapeType.Point ) ;
  shptmp.AddPart ;
  shptmp.AddPoint( ptmax ) ;

  GIS.InvalidateWholeMap ;

  Memo1.Lines.Add( Format( 'Min: %f, Location: %f %f', [ dmin, ptmin.X, ptmin.Y ] ) ) ;
  Memo1.Lines.Add( Format( 'Max: %f, Location: %f %f', [ dmax, ptmax.X, ptmax.Y ] ) ) ;
end;

procedure TForm1.btnProfileClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel  ;
  lv  : TGIS_LayerVector ;
  shp : TGIS_Shape       ;
  px  : TGIS_PixelItem   ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\grid.ttkproject' ) ;

  lp := TGIS_LayerPixel( GIS.Get( 'elevation' ) ) ;
  lv := TGIS_LayerVector( GIS.Get( 'line' ) ) ;
  shp := lv.GetShape( 1 ).MakeEditable ;
  shp.IsSelected := True ;

  Memo1.Lines.BeginUpdate ;
  try
    for px in lp.Loop( 0, shp, False ) do begin
      Memo1.Lines.Add( Format( 'Distance: %f, Height:%f', [ px.Distance, px.Value ] ) ) ;
      px.Value := 0 ;
    end;
  finally
    Memo1.Lines.EndUpdate ;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

end.
