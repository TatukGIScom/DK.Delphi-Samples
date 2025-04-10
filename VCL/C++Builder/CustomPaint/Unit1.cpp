//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Gdiplus.h"
//#include "GisLicense.hpp"
#include "Unit1.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
TGIS_LayerVector  *ll        ;
TGIS_Bitmap       *bmp       ;
TGIS_Pixels       px         ;


__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}

//---------------------------------------------------------------------------
void __fastcall TForm1::initialize_pixels()
{

  px[ 0] = (int)(0xFFFF0000) ;
  px[ 1] = (int)(0xFFFF0000) ;
  px[ 2] = (int)(0xFFFF0000) ;
  px[ 3] = (int)(0xFFFF0000) ;
  px[ 4] = (int)(0xFFFF0000) ;
  px[ 5] = (int)(0x00000000) ;
  px[ 6] = (int)(0x00000000) ;
  px[ 7] = (int)(0xFF0000FF) ;
  px[ 8] = (int)(0x00000000) ;
  px[ 9] = (int)(0x00000000) ;
  px[10] = (int)(0x00000000) ;
  px[11] = (int)(0x00000000) ;
  px[12] = (int)(0xFF0000FF) ;
  px[13] = (int)(0x00000000) ;
  px[14] = (int)(0x00000000) ;
  px[15] = (int)(0x00000000) ;
  px[16] = (int)(0x00000000) ;
  px[17] = (int)(0xFF0000FF) ;
  px[18] = (int)(0x00000000) ;
  px[19] = (int)(0x00000000) ;
  px[20] = (int)(0x00000000) ;
  px[21] = (int)(0x00000000) ;
  px[22] = (int)(0xFF0000FF) ;
  px[23] = (int)(0x00000000) ;
  px[23] = (int)(0x00000000) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_Shape *shp  ;
  int i ;

  px.set_length( 24 );
  initialize_pixels() ;

  ll = new TGIS_LayerVector;
  ll->Name = "CustomPaint";

  GIS->Add(ll);

  ll->PaintShapeEvent = GISPaintShapeEvent;
  ll->AddField("type", TGIS_FieldType::String,100,0);
  ll->Extent = GIS->Extent;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(-25,25) );
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Rectangle" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(25,25) );
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Ellipse" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(-25,-25) );
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Image1" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(25,-25) );
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Image2" );
  shp->Unlock() ;

  ll->Extent = TGIS_Utils::GisExtent(-100,-100,100,100) ;

  bmp = new TGIS_Bitmap;
  bmp->LoadFromFile( TGIS_Utils::GisSamplesDataDirDownload() + "Symbols\\police.bmp");

  GIS->FullExtent();

  cbRenderer->Items->Clear() ;
  for ( i = 0; i < RendererManager()->Names->Count; i++ )
  {
	cbRenderer->Items->Add((*RendererManager()->Names)[i]);
  }
  cbRenderer->ItemIndex = RendererManager()->Names->IndexOf(GIS->Renderer->ClassName());
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete bmp ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cbRendererChange(TObject *_sender)
{
  if ( cbRenderer->ItemIndex >= 0 )
  {
	GIS->Renderer = RendererManager()->CreateInstance( (*RendererManager()->Names)[cbRenderer->ItemIndex] ) ;
  }

  GIS->ControlUpdateWholeMap();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode)
{
  Gdiplus::GpGraphics     *cnvGDIP    ;
  Gdiplus::GpFont         *font       ;
  Gdiplus::GpSolidFill    *brush      ;
  Gdiplus::GpFontFamily   *fontFamily ;
  Gdiplus::GpStringFormat *sf         ;
  Gdiplus::GpRectF        rect        ;
  wchar_t      		      *text       ;
  TCanvas        	      *cnvGDI32   ;
  TDirect2DCanvas         *cnvD2D     ;
  #ifdef SKIA
  ISkCanvas               *cnvSK      ;
  #endif

  // drawing with native objects, not recommended
  if ( _renderer->InheritsFrom( __classid( TGIS_RendererVclGdiPlus ) ) )
  {
	cnvGDIP = ( Gdiplus::GpGraphics *)( ( ( TGIS_GdipGraphics *)(_renderer->CanvasNative() ) )->Native);

	Gdiplus::DllExports::GdipCreateSolidFill( 0xFF0000FF, &brush ) ;
	Gdiplus::DllExports::GdipCreateFontFamilyFromName( L"Arial", NULL, &fontFamily) ;
	Gdiplus::DllExports::GdipCreateFont(fontFamily, 8, Gdiplus::FontStyleRegular, Gdiplus::UnitPoint, &font) ;
	Gdiplus::DllExports::GdipCreateStringFormat(0, LANG_NEUTRAL, &sf) ;
	text = L"Hello from GDI+";

	try{
	  rect.X = 50 ;
	  rect.Y = 50 ;
	  rect.Width = 100 ;
	  rect.Height = 100 ;

	  Gdiplus::DllExports::GdipDrawString(
		cnvGDIP,
		text,
		wcslen(text),
		font,
		&rect,
		sf,
		brush
		);
	}
	__finally{
	  Gdiplus::DllExports::GdipDeleteBrush(brush);
	  Gdiplus::DllExports::GdipDeleteFont(font);
	  Gdiplus::DllExports::GdipDeleteFontFamily(fontFamily);
	  Gdiplus::DllExports::GdipDeleteStringFormat(sf);
	}
  }
  else
  if( _renderer->InheritsFrom( __classid( TGIS_RendererVclGdi32 ) ) )
  {
	cnvGDI32 = ( TCanvas *)(_renderer->CanvasNative());
	cnvGDI32->TextOut(50,50, "Hello from GDI32");
  }
  else
  if( _renderer->InheritsFrom( __classid( TGIS_RendererVclDirect2D ) ) )
  {
	cnvD2D = (TDirect2DCanvas *)(_renderer->CanvasNative());
	cnvD2D->TextOut(50,50, "Hello from D2D");
  }
  else
  #ifdef SKIA
  if( _renderer->InheritsFrom( __classid( TGIS_RendererVclSkia ) ) )
  {
	cnvSK = interface_cast<ISkCanvas>(_renderer->CanvasNative());
	auto typefaceSK = TSkTypeface::MakeFromName("Arial", TSkFontStyle::Normal());
	auto fontSK = SkFont(typefaceSK, 12, 1, 0);
	auto paintSK = SkPaint();
	cnvSK->DrawSimpleText("Hello from Skia", 50, 50, fontSK, paintSK);
  }
  else
  #endif
  {
	//for other renderers
  }
}

void __fastcall TForm1::GISPaintShapeEvent(TObject *_sender, TGIS_Shape *_shape){
  TGIS_RendererAbstract *rdr ;
  TPoint pt                ;

  rdr = ( TGIS_RendererAbstract *)( _shape->Layer->Renderer );
  pt = GIS->MapToScreen( _shape->PointOnShape() ) ;
  _shape->Draw() ;

  //Drawing with our renderer
  if ( _shape->GetField("type") == "Rectangle" ){
	rdr->CanvasPen->Color = TGIS_Color::Red ;
    rdr->CanvasBrush->Color = TGIS_Color::Yellow ;
	rdr->CanvasDrawRectangle( Rect( pt.X, pt.Y, pt.X + 20, pt.Y + 20));
	pt.Y = pt.Y - 20 ;
	rdr->CanvasDrawText(Rect(pt.X, pt.Y, pt.X+20, pt.Y + 20), "Rectangle");
  }
  else
  if ( _shape->GetField("type") == "Ellipse" ) {
	rdr->CanvasPen->Color = TGIS_Color::Black ;
	rdr->CanvasBrush->Color = TGIS_Color::Red ;
	rdr->CanvasDrawEllipse(pt.X ,pt.Y ,20 ,20) ;
	pt.Y = pt.Y - 20 ;
	rdr->CanvasDrawText( Rect(pt.X, pt.Y, pt.X + 20, pt.Y + 20), "Ellipse");
  }
  else
  if( _shape->GetField("type") == "Image1" )
  {
	rdr->CanvasDrawBitmap(
	  bmp,
	  Rect(
		pt.X,
		pt.Y ,
		pt.X + 20 ,
		pt.Y + 20
	  )
	) ;
	pt.Y = pt.Y - 20;
	rdr->CanvasDrawText( Rect(pt.X, pt.Y, pt.X + 20, pt.Y + 20), "Image1");
  }
  else
  if( _shape->GetField("type") == "Image2" ) {
	rdr->CanvasDrawBitmap(
	  px,
	  Point( 5, 5),
	  Rect( pt.X, pt.Y , pt.X + 20 , pt.Y + 20 ),
	  TGIS_BitmapFormat::ARGB,
	  TGIS_BitmapLinesOrder::Down
	) ;
	pt.Y = pt.Y - 20;
	rdr->CanvasDrawText( Rect(pt.X, pt.Y, pt.X + 20, pt.Y + 20), "Image2");
  }

}
//---------------------------------------------------------------------------
