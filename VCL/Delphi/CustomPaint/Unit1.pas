//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to use custom painting events.
}
unit Unit1;

{$INCLUDE GisInclude.inc}

{$IFDEF LEVEL_RX12_VCL}
  {$DEFINE SKIA}
{$ENDIF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPAPI,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  VCL.Direct2D,

  VCL.GisViewerWnd,
  VCL.GisRenderer,
  VCL.GisRendererGdiPlus,
  VCL.GisRendererGdi32,
  VCL.GisRendererDirect2D,
  VCL.GisGdiPlus,

  {$IFDEF SKIA}
    VCL.GisRendererSkia,
    System.Skia,
  {$ENDIF}

  GisUtils,
  GisLayerVector,
  GisRendererAbstract,
  GisTypes,
  GisTypesUI,
  GisParams,
  GisRtl, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    cbRenderer: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure GISPaintShapeEvent(_sender: TObject; _shape : TGIS_Shape);
    procedure FormDestroy(Sender: TObject);
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure cbRendererChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1   : TForm1            ;
  ll      : TGIS_LayerVector  ;
  bmp     : TGIS_Bitmap       ;
  px      : TGIS_Pixels       ;
implementation

{$R *.dfm}

procedure TForm1.cbRendererChange(Sender: TObject);
begin
  if cbRenderer.ItemIndex >= 0 then
    GIS.Renderer := RendererManager.CreateInstance( RendererManager.Names[cbRenderer.ItemIndex] ) ;

  GIS.ControlUpdateWholeMap;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  shp  : TGIS_Shape  ;
  name : String ;
  i : Integer ;

  procedure initialize_pixels ;
  begin
    px[ 0] := Integer($FFFF0000) ;
    px[ 1] := Integer($FFFF0000) ;
    px[ 2] := Integer($FFFF0000) ;
    px[ 3] := Integer($FFFF0000) ;
    px[ 4] := Integer($FFFF0000) ;
    px[ 5] := Integer($00000000) ;
    px[ 6] := Integer($00000000) ;
    px[ 7] := Integer($FF0000FF) ;
    px[ 8] := Integer($00000000) ;
    px[ 9] := Integer($00000000) ;
    px[10] := Integer($00000000) ;
    px[11] := Integer($00000000) ;
    px[12] := Integer($FF0000FF) ;
    px[13] := Integer($00000000) ;
    px[14] := Integer($00000000) ;
    px[15] := Integer($00000000) ;
    px[16] := Integer($00000000) ;
    px[17] := Integer($FF0000FF) ;
    px[18] := Integer($00000000) ;
    px[19] := Integer($00000000) ;
    px[20] := Integer($00000000) ;
    px[21] := Integer($00000000) ;
    px[22] := Integer($FF0000FF) ;
    px[23] := Integer($00000000) ;
    px[23] := Integer($00000000) ;
  end;
begin
  SetLength(px, 25);

  initialize_pixels ;

  ll := TGIS_LayerVector.Create;
  ll.Name := 'CustomPaint';

  GIS.Add(ll);

  ll.PaintShapeEvent := GISPaintShapeEvent;
  ll.AddField('type', TGIS_FieldType.String,100,0);
  ll.Extent := GIS.Extent;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(-25,25) );
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Rectangle' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(25,25) );
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Ellipse' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(-25,-25) );
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Image1' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(25,-25) );
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Image2' );
  shp.Unlock ;

  ll.Extent := TGIS_Utils.GisExtent(-100,-100,100,100)     ;

  bmp := TGIS_Bitmap.Create;
  bmp.LoadFromFile(TGIS_Utils.GisSamplesDataDirDownload + 'Symbols\police.bmp');

  GIS.FullExtent;

  cbRenderer.Items.Clear ;
  for i := 0 to RendererManager.Names.Count-1 do
    cbRenderer.Items.Add(RendererManager.Names[i]);
  cbRenderer.ItemIndex := RendererManager.Names.IndexOf(GIS.Renderer.ClassName);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeObject(bmp);
end;

procedure TForm1.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
var
  cnvGDIP     : GPGRAPHICS            ;
  font        : GPFONT                ;
  brush       : GPBRUSH               ;
  fontFamily  : GPFONTFAMILY          ;
  sf          : GPSTRINGFORMAT        ;
  rect        : TGPRectF              ;
  text        : PWideChar             ;
  cnvGDI32    : TCanvas               ;
  cnvD2D      : TDirect2DCanvas       ;
  {$IFDEF SKIA}
    cnvSkia   : ISkCanvas             ;
  {$ENDIF}
begin
  // drawing with native objects, not recommended
  if _renderer is TGIS_RendererVclGdiPlus then begin
    cnvGDIP := GPGRAPHICS(TGIS_GdipGraphics(_renderer.CanvasNative).Native);
    GdipCreateSolidFill( $FF0000FF, brush ) ;
    GdipCreateFontFamilyFromName(PWideChar('Arial'), nil, fontFamily) ;
    GdipCreateFont(fontFamily, 8, FontStyleRegular, ord(UnitPoint), font) ;
    GdipCreateStringFormat(0, LANG_NEUTRAL, sf) ;
    text := 'Hello from GDI+';

    try
      rect := MakeRect( 50.0, 50.0, 150.0, 100.0 ) ;

      GdipDrawString(
        cnvGDIP,
        PWideChar(text),
        Length(text),
        font,
        @rect,
        sf,
        brush
        );
    finally
     GdipDeleteBrush(brush);
     GdipDeleteFont(font);
     GdipDeleteFontFamily(fontFamily);
     GdipDeleteStringFormat(sf);
    end;
  end
  else
  if _renderer is TGIS_RendererVclGdi32 then begin
    cnvGDI32 := TCanvas(_renderer.CanvasNative);
    cnvGDI32.TextOut(50,50, 'Hello from GDI32');
  end
  else
  if _renderer is TGIS_RendererVclDirect2D then begin
    cnvD2D := TDirect2DCanvas(_renderer.CanvasNative);
    cnvD2D.TextOut(50,50, 'Hello from D2D');
  end
  else
  {$IFDEF SKIA}
  if _renderer is TGIS_RendererVclSkia then begin
    cnvSkia := TSkCanvas(_renderer.CanvasNative);
    cnvSkia.DrawSimpleText('Hello from Skia', 50, 50, TSkFont.Create, TSkPaint.Create);
  end
  else
  {$ENDIF}
  begin
    //for other renderers
  end;
end;

procedure TForm1.GISPaintShapeEvent(_sender: TObject; _shape : TGIS_Shape);
var
  rdr       : TGIS_RendererAbstract ;
  pt        : TPoint                ;
begin
  pt := GIS.MapToScreen( _shape.PointOnShape ) ;
  _shape.Draw ;
  rdr := _shape.Layer.Renderer as TGIS_RendererAbstract;
  //Drawing with our renderer
  if _shape.GetField('type') = 'Rectangle' then begin
    rdr.CanvasPen.Color := TGIS_Color.Red ;
    rdr.CanvasBrush.Color := TGIS_Color.Yellow ;
    rdr.CanvasDrawRectangle(TRect.Create(pt, 20, 20));
    pt.Y := pt.Y - 20 ;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Rectangle');
  end
  else
  if _shape.GetField('type') = 'Ellipse' then begin
    rdr.CanvasPen.Color := TGIS_Color.Black ;
    rdr.CanvasBrush.Color := TGIS_Color.Red ;
    rdr.CanvasDrawEllipse(pt.X ,pt.Y ,20 ,20) ;
    pt.Y := pt.Y - 20 ;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Ellipse');
  end
  else
  if _shape.GetField('type') = 'Image1' then begin
    rdr.CanvasDrawBitmap(
    bmp,
    TRect.Create(
      pt.X ,
      pt.Y ,
      pt.X + 20,
      pt.Y + 20
    )) ;
    pt.Y := pt.Y - 20;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Image1');
  end
  else
  if _shape.GetField('type') = 'Image2' then begin
    rdr.CanvasDrawBitmap(
      px,
      Point( 5, 5),
      TRect.Create( pt.X , pt.Y , pt.X + 20, pt.Y + 20 ),
      TGIS_BitmapFormat.ARGB,
      TGIS_BitmapLinesOrder.Down
    ) ;
    pt.Y := pt.Y - 20;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Image2');
  end

end ;

end.
