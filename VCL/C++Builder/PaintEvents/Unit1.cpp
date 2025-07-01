//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to use TGIS_ViewerWnd Paint events.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
		: TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp" ;
  ll->Name = "counties" ;
  GIS->Add(ll) ;
  GIS->FullExtent() ;
  center_ptg = GIS->CenterPtg ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkDragClick(TObject *Sender)
{
  // change viewer mode
  if ( chkDrag->Checked )
    GIS->Mode = TGIS_ViewerMode::Drag ;
  else
    GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISBeforePaintRendererEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode)
{
  TObject *cn ;
  TGIS_RendererAbstract *rdr ;
  TGIS_Color bcl ;
  TDirect2DCanvas *canvasD2D ;
  TGIS_GdipGraphics *canvasPlus ;
  TGIS_GdipSolidBrush *brushPlus ;
  TCanvas *canvasVcl ;

  rdr = _renderer;
  cn  = rdr->CanvasNative();
  bcl = TGIS_Color::FromRGB(0xEE, 0xE8, 0xAA);
  if( cn->InheritsFrom( __classid( TDirect2DCanvas ) ) ) {
    canvasD2D = (TDirect2DCanvas*)cn;
    canvasD2D->Brush->Color = (TColor)bcl.ToBGR() ;
    canvasD2D->FillRect( Rect(0, 0, GIS->Width, GIS->Height) );
  } else if( cn->InheritsFrom( __classid( TGIS_GdipGraphics ) ) ) {
    canvasPlus = (TGIS_GdipGraphics*)cn;
    brushPlus = new TGIS_GdipSolidBrush( bcl ) ;
    canvasPlus->FillRectangle( brushPlus, Rect(0, 0, GIS->Width, GIS->Height ));
    brushPlus->Free();
  } else if( cn->InheritsFrom( __classid( TCanvas ) ) ) {
    canvasVcl = (TCanvas*)cn;
    canvasVcl->Brush->Color = (TColor)bcl.ToBGR() ;
    canvasVcl->Brush->Style = bsSolid ;
    canvasVcl->FillRect( Rect(0, 0, GIS->Width, GIS->Height));
  }
  rdr->CanvasPen->Color = TGIS_Color::Blue;
  rdr->CanvasPen->Width = 1;
  rdr->CanvasBrush->Style = TGIS_BrushStyle::Clear;
  rdr->CanvasDrawRectangle( Rect(10, 10, GIS->Width-10, GIS->Height-10));
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISBeforePaintEvent(TObject *_sender, TObject *_canvas)
{
  TGIS_Color bcl ;
  TDirect2DCanvas *canvasD2D ;
  D2D_RECT_F rct ;
  TCanvas *canvasVcl ;

  bcl = TGIS_Color::Blue ;
  if( _canvas->InheritsFrom( __classid( TDirect2DCanvas ) ) ) {
    canvasD2D = (TDirect2DCanvas*)_canvas;
    canvasD2D->Pen->Color = (TColor)bcl.ToBGR() ;
    canvasD2D->Pen->Width = 1 ;
    rct.left = 40 ;
    rct.top = 40 ;
    rct.right = GIS->Width - 40 ;
    rct.bottom = GIS->Height - 40 ;
    canvasD2D->DrawRectangle( rct ) ;
  } else {
    canvasVcl = (TCanvas*)_canvas ;
    canvasVcl->Pen->Color = (TColor)bcl.ToBGR() ;
    canvasVcl->Pen->Width = 1 ;
    canvasVcl->Brush->Style = bsClear ;
    canvasVcl->Rectangle( Rect(40, 40, GIS->Width-40, GIS->Height-40) );
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode)
{
  String txt ;
  TPoint pt ;
  TPoint ptc ;

  txt = "PaintExtra" ;
  _renderer->CanvasFont->Name = "Courier New" ;
  _renderer->CanvasFont->Size = 24 ;
  _renderer->CanvasFont->Color = TGIS_Color::Blue ;
  pt = _renderer->CanvasTextExtent( txt ) ;
  ptc = GIS->MapToScreen( center_ptg ) ;
  _renderer->CanvasDrawText( Rect( ptc.X - pt.X / 2,
                                   ptc.Y - pt.Y / 2,
                                   ptc.X + pt.X / 2,
                                   ptc.Y + pt.Y / 2 ),
                             txt ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISAfterPaintEvent(TObject *_sender, TObject *_canvas)
{
  TGIS_Color bcl ;
  TDirect2DCanvas *canvasD2D ;
  D2D_RECT_F rct ;
  TCanvas *canvasVcl ;

  bcl = TGIS_Color::Blue ;
  if( _canvas->InheritsFrom( __classid( TDirect2DCanvas ) ) ) {
    canvasD2D = (TDirect2DCanvas*)_canvas ;
    canvasD2D->Pen->Color = (TColor)bcl.ToBGR() ;
    canvasD2D->Pen->Width = 1 ;
    rct.left = 70 ;
    rct.top = 70 ;
    rct.right = GIS->Width - 70 ;
    rct.bottom = GIS->Height - 70 ;
    canvasD2D->DrawRectangle( rct ) ;
  } 
  else if( _canvas->InheritsFrom( __classid( TCanvas ) ) ) {
    canvasVcl = (TCanvas*)_canvas ;
    canvasVcl->Pen->Color = (TColor)bcl.ToBGR() ;
    canvasVcl->Pen->Width = 1;
    canvasVcl->Brush->Style = bsClear;
    canvasVcl->Rectangle( Rect( 70, 70, GIS->Width-70, GIS->Height-70 ) ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISAfterPaintRendererEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode)
{
  TGIS_RendererAbstract *rdr ;

  rdr = _renderer;
  rdr->CanvasPen->Color = TGIS_Color::Blue;
  rdr->CanvasPen->Width = 1 ;
  rdr->CanvasBrush->Style = TGIS_BrushStyle::Clear ;
  rdr->CanvasDrawRectangle( Rect( 100, 100, GIS->Width-100, GIS->Height-100 ) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkBeforePaintRendererEventClick(TObject *Sender)
{
  if ( chkBeforePaintRendererEvent->Checked )
    GIS->BeforePaintRendererEvent = GISBeforePaintRendererEvent ;
  else
    GIS->BeforePaintRendererEvent = NULL ;
  GIS->Invalidate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkBeforePaintEventClick(TObject *Sender)
{
  if ( chkBeforePaintEvent->Checked )
    GIS->BeforePaintEvent = GISBeforePaintEvent ;
  else
    GIS->BeforePaintEvent = NULL ;
  GIS->Invalidate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkPaintExtraEventClick(TObject *Sender)
{
  if ( chkPaintExtraEvent->Checked )
    GIS->PaintExtraEvent = GISPaintExtraEvent ;
  else
    GIS->PaintExtraEvent = NULL ;
  GIS->Invalidate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkAfterPaintEventClick(TObject *Sender)
{
  if ( chkAfterPaintEvent->Checked )
    GIS->AfterPaintEvent = GISAfterPaintEvent ;
  else
    GIS->AfterPaintEvent = NULL ;
  GIS->Invalidate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkAfterPaintRendererEventClick(TObject *Sender)
{
  if ( chkAfterPaintRendererEvent->Checked )
    GIS->AfterPaintRendererEvent = GISAfterPaintRendererEvent ;
  else
    GIS->AfterPaintRendererEvent = NULL ;
  GIS->Invalidate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnTestPrintBmpClick(TObject *Sender)
{
  TBitmap *bitmap ;

  if ( !SaveDialog1->Execute() ) return ;
  bitmap = NULL ;
  try
  {
    GIS->PrintBmp( bitmap, chkPrintBmpWithEvents->Checked ) ;
    bitmap->SaveToFile( SaveDialog1->FileName ) ;
  }
  __finally
  {
    bitmap->Free() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rbDirect2DClick(TObject *Sender)
{
  GIS->Renderer = new TGIS_RendererVclDirect2D ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rbGdiPlusClick(TObject *Sender)
{
  GIS->Renderer = new TGIS_RendererVclGdiPlus ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rbGdi32Click(TObject *Sender)
{
  GIS->Renderer = new TGIS_RendererVclGdiPlus ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

