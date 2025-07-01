//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide basic pixel operations.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerVector,
  GisLayerPixel,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisLayerADF,
  GisDem,

  Vcl.GisViewerWnd,
  Vcl.GisControlLegend;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    ToolButton4: TToolButton;
    ImageList1: TImageList;
    GIS_Legend: TGIS_ControlLegend;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    dlgFileOpen: TOpenDialog;
    btn2: TToolButton;
    cbCheckPixels: TCheckBox;
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure cbCheckPixelsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function changePixels(
            _layer  : TObject     ;
      const _extent : TGIS_Extent ;
      const _source : TGIS_Pixels ;
        var _output : TGIS_Pixels ;
      const _width  : Integer     ;
      const _height : Integer
    ): Boolean;


  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  System.Math,
  GisRegistredLayers,
  GisAllLayers,
  GisRtl ;

procedure TForm1.FormCreate(Sender: TObject);
begin
  dlgFileOpen.Filter := GisSupportedFiles( [ TGIS_FileType.All ] , false);

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
            '\World\Countries\USA\States\California\San Bernardino\DOQ\37134877.jpg'
           ) ;
  cbCheckPixelsClick(Sender);
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.cbCheckPixelsClick(Sender: TObject);
var
  lp : TGIS_LayerPixel ;
begin
  if GIS.IsEmpty then exit ;

  lp := TGIS_LayerPixel( GIS.Items[0] ) ;
  if cbCheckPixels.Checked then
    lp.PixelOperationEvent := changePixels
  else
    lp.PixelOperationEvent := nil ;

  GIS.InvalidateWholeMap ;
end;

function TForm1.changePixels(
        _layer  : TObject     ;
  const _extent : TGIS_Extent ;
  const _source : TGIS_Pixels ;
    var _output : TGIS_Pixels ;
  const _width  : Integer     ;
  const _height : Integer
): Boolean;
var
  rmaxval, rminval : Integer ;
  gmaxval, gminval : Integer ;
  bmaxval, bminval : Integer ;
  i       : Integer ;
  rdelta  : Integer ;
  gdelta  : Integer ;
  bdelta  : Integer ;
  r, g, b : Integer ;
  pixval  : TGIS_Color ;
begin
  Result := True ;

  rmaxval := -1000 ;
  rminval :=  1000 ;
  gmaxval := -1000 ;
  gminval :=  1000 ;
  bmaxval := -1000 ;
  bminval :=  1000 ;

  for i := Low(_source) to High(_source) do begin
    pixval.ARGB := _source[i] ;
    r := pixval.R ;
    g := pixval.G ;
    b := pixval.B  ;

    if r > rmaxval then
      rmaxval := r ;
    if g > gmaxval then
      gmaxval := g ;
    if b > bmaxval then
      bmaxval := b ;

    if r < rminval then
      rminval := r ;
    if g < gminval then
      gminval := g ;
    if b < bminval then
      bminval := b ;
  end;

  rdelta := Max( 1, rmaxval -rminval ) ;
  gdelta := Max( 1, gmaxval -gminval ) ;
  bdelta := Max( 1, bmaxval -bminval ) ;

  for i := Low(_source) to High(_source) do begin
    pixval.ARGB := _source[i] ;
    r := pixval.R ;
    g := pixval.G ;
    b := pixval.B  ;
    r := Trunc(((r -rminval)/rdelta)*255.0);
    g := Trunc(((g -gminval)/gdelta)*255.0);
    b := Trunc(((b -bminval)/bdelta)*255.0);

    pixval := TGIS_Color.FromARGB( $FF, r, g, b ) ;
    _output[i] := pixval.ARGB ;
  end;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if not dlgFileOpen.Execute then exit ;

  GIS.Open( dlgFileOpen.FileName ) ;
end;

end.
