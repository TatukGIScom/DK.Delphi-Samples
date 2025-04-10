//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
   How to attach bitmaps to shapes.
   Good results only under Windows NT/2000/XP.
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
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisLayerSHP,
  GisParams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ComboLabels: TComboBox;
    ComboStatistic: TComboBox;
    Panel3: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PaintShape( _sender : TOBject; _shape : TGIS_Shape );
    procedure ComboLabelsChange(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
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
  ll : TGIS_LayerSHP ;
begin
  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ;
  ll.UseConfig := False ;
  ll.Name := 'counties' ;

  //set custom painting routine
  ll.PaintShapeEvent := PaintShape ;
  GIS.Add(ll) ;

  GIS.FullExtent ;

  ComboStatistic.ItemIndex := 0 ;
  ComboLabels.ItemIndex := 0 ;
end;


procedure TForm1.PaintShape( _sender : TObject; _shape : TGIS_Shape ) ;
var
  population : double ;
  area       : double ;
  factor     : double ;
  oldBitmap  : TBitmap ;
begin

  // calculate parameters
  population := StrToFloat(_shape.GetField( 'population' ) ) ;
  area       := StrToFloat(_shape.GetField('area'));

  if area = 0 then Exit ;

  oldBitmap := nil;
  if assigned( _shape.Params.Area.Bitmap ) then
      if not ( _shape.Params.Area.Bitmap.IsEmpty ) then
          oldBitmap := _shape.Params.Area.Bitmap.NativeBitmap as TBitmap ;

  _shape.Params.Area.Bitmap := TGIS_Bitmap.Create ;
  _shape.Params.Area.Pattern := TGIS_BrushStyle.Solid ;
  _shape.Params.Area.Color := TGIS_Color.Red ;
  _shape.Params.Area.OutlineColor := TGIS_Color.DimGray ;
  _shape.Params.Area.OutlineWidth := 20 ;

  if ComboStatistic.itemIndex = 1 then begin
    factor := population/area ;

    // assing different bitmaps for factor value
    if      factor <      1 then _shape.Params.Area.Bitmap.NativeBitmap := Image1.Picture.Bitmap
    else if factor <      7 then _shape.Params.Area.Bitmap.NativeBitmap := Image2.Picture.Bitmap
    else if factor <     52 then _shape.Params.Area.Bitmap.NativeBitmap := Image3.Picture.Bitmap
    else if factor <    380 then _shape.Params.Area.Bitmap.NativeBitmap := Image4.Picture.Bitmap
    else if factor <   3000 then _shape.Params.Area.Bitmap.NativeBitmap := Image5.Picture.Bitmap
  end
  else begin
    factor := population ;
    if      factor <    5000 then _shape.Params.Area.Bitmap.NativeBitmap := Image1.Picture.Bitmap
    else if factor <   22000 then _shape.Params.Area.Bitmap.NativeBitmap := Image2.Picture.Bitmap
    else if factor <  104000 then _shape.Params.Area.Bitmap.NativeBitmap := Image3.Picture.Bitmap
    else if factor <  478000 then _shape.Params.Area.Bitmap.NativeBitmap := Image4.Picture.Bitmap
    else if factor < 2186000 then _shape.Params.Area.Bitmap.NativeBitmap := Image5.Picture.Bitmap ;
  end;

   // draw bitmaps
  _shape.Draw;

  _shape.Params.Area.Bitmap.NativeBitmap := oldBitmap ;
end;


procedure TForm1.ComboLabelsChange(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  // set labels for states
  ll := TGIS_LayerVector( Gis.Get( 'counties' ) ) ;
  if ll <> nil then begin
    case ComboLabels.ItemIndex of
      1 : ll.Params.Labels.Field := 'CNTYIDFP' ;
      2 : ll.Params.Labels.Field := 'NAME' ;
    else  ll.Params.Labels.Field := '' ;
    end ;
  end ;

  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.

