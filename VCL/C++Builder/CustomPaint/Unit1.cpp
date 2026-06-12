//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// CustomPaint sample (C++Builder / VCL variant) - demonstrates how to perform
// custom drawing on top of a TatukGIS map viewer using two paint-hook callbacks.
//
// Key concepts:
//
//   PaintShapeEvent (GISPaintShapeEvent)
//     Registered on a TGIS_LayerVector.  Fires once per shape per repaint,
//     completely replacing the layer's default shape rendering.  The handler
//     reads the "type" field to choose a drawing primitive and calls
//     MapToScreen to convert the shape's geographic position to screen pixels.
//     All drawing is done via TGIS_RendererAbstract Canvas* methods, which
//     work regardless of the active backend (GDI+, GDI32, Direct2D, Skia).
//
//   PaintExtraEvent (GISPaintExtraEvent)
//     Fires once per frame after all layers have finished rendering.
//     Demonstrates accessing the renderer's native canvas handle to call
//     platform-specific APIs (GDI+, GDI32, Direct2D, Skia).  Using native
//     handles is NOT recommended for portable code because it ties drawing
//     logic to a specific backend; prefer TGIS_RendererAbstract instead.
//
//   Renderer switching (cbRenderer combo box)
//     RendererManager()->Names lists registered renderer class names.
//     RendererManager()->CreateInstance() creates a fresh instance by name.
//     Assigning to GIS->Renderer replaces the backend at runtime.
//
// Layer layout:
//   "CustomPaint" TGIS_LayerVector with four invisible point shapes.
//   A "type" string field selects the drawing primitive in GISPaintShapeEvent:
//     "Rectangle" at (-25, 25)  -> CanvasDrawRectangle (red border, yellow fill)
//     "Ellipse"   at ( 25, 25)  -> CanvasDrawEllipse   (black border, red fill)
//     "Image1"    at (-25,-25)  -> CanvasDrawBitmap(TGIS_Bitmap from police.bmp)
//     "Image2"    at ( 25,-25)  -> CanvasDrawBitmap(TGIS_Pixels raw ARGB buffer)
//
// Global variables:
//   ll  - the "CustomPaint" layer
//   bmp - TGIS_Bitmap loaded from police.bmp (Image1 case)
//   px  - TGIS_Pixels raw ARGB buffer (Image2 case)
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
TGIS_LayerVector  *ll        ;  // the "CustomPaint" layer
TGIS_Bitmap       *bmp       ;  // bitmap loaded from police.bmp (Image1)
TGIS_Pixels       px         ;  // raw ARGB pixel buffer (Image2)


__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}

//---------------------------------------------------------------------------
// initialize_pixels
// Fills the global px array with a 5x5 ARGB test image:
//   Row 0  (indices 0-4):  opaque red   (0xFFFF0000)
//   Diagonal column 2 pixels [7],[12],[17],[22]: opaque blue (0xFF0000FF)
//   All other pixels:      fully transparent (0x00000000)
//
// The pixel format is ARGB: the high byte is alpha (0xFF = opaque),
// followed by red, green, and blue bytes, matching TGIS_BitmapFormat::ARGB.
//
// px.set_length(24) allocates 24 elements; the 25th (index 24) is not
// set explicitly - the caller accesses only up to index 23.
void __fastcall TForm1::initialize_pixels()
{
  // Row 0: five opaque red pixels
  px[ 0] = (int)(0xFFFF0000) ;
  px[ 1] = (int)(0xFFFF0000) ;
  px[ 2] = (int)(0xFFFF0000) ;
  px[ 3] = (int)(0xFFFF0000) ;
  px[ 4] = (int)(0xFFFF0000) ;
  // Row 1: transparent, blue at column 2
  px[ 5] = (int)(0x00000000) ;
  px[ 6] = (int)(0x00000000) ;
  px[ 7] = (int)(0xFF0000FF) ; // opaque blue
  px[ 8] = (int)(0x00000000) ;
  px[ 9] = (int)(0x00000000) ;
  // Row 2
  px[10] = (int)(0x00000000) ;
  px[11] = (int)(0x00000000) ;
  px[12] = (int)(0xFF0000FF) ;
  px[13] = (int)(0x00000000) ;
  px[14] = (int)(0x00000000) ;
  // Row 3
  px[15] = (int)(0x00000000) ;
  px[16] = (int)(0x00000000) ;
  px[17] = (int)(0xFF0000FF) ;
  px[18] = (int)(0x00000000) ;
  px[19] = (int)(0x00000000) ;
  // Row 4
  px[20] = (int)(0x00000000) ;
  px[21] = (int)(0x00000000) ;
  px[22] = (int)(0xFF0000FF) ;
  px[23] = (int)(0x00000000) ;
  px[23] = (int)(0x00000000) ; // note: index 23 assigned twice
}

//---------------------------------------------------------------------------
// FormCreate - builds the demo layer, registers the paint callbacks,
// creates the four invisible point shapes, loads the bitmap, and populates
// the renderer combo box.
//
// "CustomPaint" layer:
//   No file backing - all geometry is created in code.
//   PaintShapeEvent = GISPaintShapeEvent replaces default rendering.
//   A "type" string field selects the drawing primitive in the callback.
//   Extent is set to (-100,-100,100,100) to enclose all four shapes.
//
// Renderer combo box:
//   Populated from RendererManager()->Names.  The selected entry is used in
//   cbRendererChange() to create and assign a new renderer instance.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_Shape *shp  ;
  int i ;

  // Allocate and initialise the raw pixel buffer for Image2
  px.set_length( 24 );
  initialize_pixels() ;

  // Create the demo layer; no file - all geometry is in memory.
  ll = new TGIS_LayerVector;
  ll->Name = "CustomPaint";

  GIS->Add(ll);

  // Wire the per-shape paint callback.
  // GISPaintShapeEvent fires once per shape per repaint cycle.
  ll->PaintShapeEvent = GISPaintShapeEvent;
  // Add the "type" attribute field read by the paint callback
  ll->AddField("type", TGIS_FieldType::String,100,0);
  ll->Extent = GIS->Extent;

  // --- Create the four invisible demo point shapes ---
  // Marker.Size=0 means no default symbol is drawn; all visuals come from
  // the PaintShapeEvent callback.
  // Lock(Extent) prevents the layer from auto-expanding its extent during
  // AddPoint; Unlock() releases the lock after shape construction.

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(-25,25) );   // NW quadrant
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Rectangle" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(25,25) );    // NE quadrant
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Ellipse" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(-25,-25) );  // SW quadrant
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Image1" );
  shp->Unlock() ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint(25,-25) );   // SE quadrant
  shp->Params->Marker->Size = 0;
  shp->SetField( "type", "Image2" );
  shp->Unlock() ;

  // Set the layer extent to enclose all four shapes
  ll->Extent = TGIS_Utils::GisExtent(-100,-100,100,100) ;

  // Load the file-based bitmap for the Image1 drawing case.
  // TGIS_Bitmap is TatukGIS's cross-renderer bitmap wrapper.
  bmp = new TGIS_Bitmap;
  bmp->LoadFromFile( TGIS_Utils::GisSamplesDataDirDownload() + "Symbols\\police.bmp");

  GIS->FullExtent();

  // Populate the renderer selector with all registered backends.
  // RendererManager()->Names lists available renderer class names.
  cbRenderer->Items->Clear() ;
  for ( i = 0; i < RendererManager()->Names->Count; i++ )
  {
	cbRenderer->Items->Add((*RendererManager()->Names)[i]);
  }
  // Pre-select the currently active renderer in the combo box
  cbRenderer->ItemIndex = RendererManager()->Names->IndexOf(GIS->Renderer->ClassName());
}

//---------------------------------------------------------------------------
// FormDestroy - frees the TGIS_Bitmap object.
// The layer and pixel array are cleaned up by TatukGIS and VCL respectively.
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete bmp ;
}

//---------------------------------------------------------------------------
// cbRendererChange - replaces the viewer's active rendering backend.
//
// RendererManager()->CreateInstance() constructs a fresh renderer instance
// by class name.  Assigning to GIS->Renderer replaces the backend while
// keeping all layers intact.  ControlUpdateWholeMap() forces an immediate
// full repaint with the new renderer so the change is visible immediately.
void __fastcall TForm1::cbRendererChange(TObject *_sender)
{
  if ( cbRenderer->ItemIndex >= 0 )
  {
	GIS->Renderer = RendererManager()->CreateInstance( (*RendererManager()->Names)[cbRenderer->ItemIndex] ) ;
  }

  GIS->ControlUpdateWholeMap();
}

//---------------------------------------------------------------------------
// GISPaintExtraEvent - PaintExtraEvent callback.
// Fires once per frame after all layers have finished rendering.
// This is the correct place for full-frame overlays (watermarks, HUD text).
//
// Demonstrates accessing the renderer's native canvas handle for
// platform-specific drawing.  Using native handles is NOT recommended
// for portable code; prefer TGIS_RendererAbstract Canvas* methods instead.
//
// Backend-specific canvas types:
//   TGIS_RendererVclGdiPlus  -> Gdiplus::GpGraphics* (flat GDI+ API)
//   TGIS_RendererVclGdi32    -> TCanvas*             (VCL GDI canvas)
//   TGIS_RendererVclDirect2D -> TDirect2DCanvas*
//   TGIS_RendererVclSkia     -> ISkCanvas*           (Skia; compile with SKIA define)
//
// The native canvas is obtained via _renderer->CanvasNative() and cast to the
// appropriate type after checking the renderer class with InheritsFrom().
void __fastcall TForm1::GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode)
{
  Gdiplus::GpGraphics     *cnvGDIP    ;  // GDI+ graphics context
  Gdiplus::GpFont         *font       ;
  Gdiplus::GpSolidFill    *brush      ;
  Gdiplus::GpFontFamily   *fontFamily ;
  Gdiplus::GpStringFormat *sf         ;
  Gdiplus::GpRectF        rect        ;  // GDI+ rectangle (floating-point)
  wchar_t      		      *text       ;
  TCanvas        	      *cnvGDI32   ;  // VCL TCanvas wrapping a GDI DC
  TDirect2DCanvas         *cnvD2D     ;  // VCL Direct2D canvas
  #ifdef SKIA
  ISkCanvas               *cnvSK      ;  // Skia canvas (RAD RX12+)
  #endif

  // --- GDI+ backend ---
  // InheritsFrom checks whether the active renderer is a GDI+ instance.
  // Cast CanvasNative() -> TGIS_GdipGraphics -> .Native to get the GpGraphics*.
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
      // Always release GDI+ resources to avoid handle leaks
	  Gdiplus::DllExports::GdipDeleteBrush(brush);
	  Gdiplus::DllExports::GdipDeleteFont(font);
	  Gdiplus::DllExports::GdipDeleteFontFamily(fontFamily);
	  Gdiplus::DllExports::GdipDeleteStringFormat(sf);
	}
  }
  else
  // --- GDI32 backend ---
  // CanvasNative() is a VCL TCanvas wrapping a Windows GDI device context.
  if( _renderer->InheritsFrom( __classid( TGIS_RendererVclGdi32 ) ) )
  {
	cnvGDI32 = ( TCanvas *)(_renderer->CanvasNative());
	cnvGDI32->TextOut(50,50, "Hello from GDI32");
  }
  else
  // --- Direct2D backend ---
  if( _renderer->InheritsFrom( __classid( TGIS_RendererVclDirect2D ) ) )
  {
	cnvD2D = (TDirect2DCanvas *)(_renderer->CanvasNative());
	cnvD2D->TextOut(50,50, "Hello from D2D");
  }
  else
  #ifdef SKIA
  // --- Skia backend (RAD RX12 / Delphi 12 and later) ---
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
	// Future or unrecognised renderer backends: no action required
  }
}

//---------------------------------------------------------------------------
// GISPaintShapeEvent - PaintShapeEvent callback.
// Fires once per shape in the "CustomPaint" layer during each repaint pass,
// replacing the layer's default rendering for that shape.
//
// _shape is the shape being painted.  It has Marker.Size=0 so no default
// symbol would appear.  The handler:
//   1. Obtains the abstract renderer from the shape's owning layer.
//   2. Calls GIS->MapToScreen(_shape->PointOnShape()) to get the screen position.
//      MapToScreen converts geographic/projected coordinates to pixel coordinates
//      relative to the viewer's top-left corner.
//   3. Calls _shape->Draw() to run any remaining default rendering hooks
//      (no-op for Marker.Size=0 shapes, but good practice to call).
//   4. Reads the "type" field and draws the appropriate primitive.
//
// All pixel sizes are fixed at 20x20 and do not scale with the zoom level.
//
// "Rectangle" - red-bordered yellow filled box + "Rectangle" label 20px above.
// "Ellipse"   - black-bordered red ellipse + "Ellipse" label 20px above.
// "Image1"    - TGIS_Bitmap (police.bmp) stretched to 20x20 + label above.
// "Image2"    - raw px TGIS_Pixels buffer (ARGB, top-to-bottom) to 20x20 + label.
//               Point(5,5) as source offset skips the solid-red first row.
void __fastcall TForm1::GISPaintShapeEvent(TObject *_sender, TGIS_Shape *_shape){
  TGIS_RendererAbstract *rdr ;  // abstract renderer for this layer/viewer
  TPoint pt                ;    // screen-pixel position of the shape

  // Obtain the abstract renderer from the shape's owning layer
  rdr = ( TGIS_RendererAbstract *)( _shape->Layer->Renderer );
  // MapToScreen converts geographic coordinates to screen pixels.
  // PointOnShape() returns the representative point of the geometry.
  pt = GIS->MapToScreen( _shape->PointOnShape() ) ;
  // Run any remaining default rendering hooks (no-op for Marker.Size=0)
  _shape->Draw() ;

  // --- Select drawing primitive by "type" attribute field ---

  if ( _shape->GetField("type") == "Rectangle" ){
    // Yellow-filled, red-bordered rectangle at the shape's screen position
	rdr->CanvasPen->Color = TGIS_Color::Red ;
    rdr->CanvasBrush->Color = TGIS_Color::Yellow ;
	rdr->CanvasDrawRectangle( Rect( pt.X, pt.Y, pt.X + 20, pt.Y + 20));
    // Draw label 20 pixels above the rectangle
	pt.Y = pt.Y - 20 ;
	rdr->CanvasDrawText(Rect(pt.X, pt.Y, pt.X+20, pt.Y + 20), "Rectangle");
  }
  else
  if ( _shape->GetField("type") == "Ellipse" ) {
    // Red-filled, black-bordered ellipse; width=20, height=20
	rdr->CanvasPen->Color = TGIS_Color::Black ;
	rdr->CanvasBrush->Color = TGIS_Color::Red ;
	rdr->CanvasDrawEllipse(pt.X ,pt.Y ,20 ,20) ;
	pt.Y = pt.Y - 20 ;
	rdr->CanvasDrawText( Rect(pt.X, pt.Y, pt.X + 20, pt.Y + 20), "Ellipse");
  }
  else
  if( _shape->GetField("type") == "Image1" )
  {
    // Stretch the TGIS_Bitmap (police.bmp) into the 20x20 destination rect.
    // TGIS_Bitmap is TatukGIS's cross-renderer bitmap wrapper.
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
    // Draw using the raw TGIS_Pixels ARGB buffer.
    // Point(5,5) = source offset: skip the first 5 pixels (solid-red row),
    //   start reading from pixel (5,5) within the 5-wide buffer.
    // TGIS_BitmapFormat::ARGB = 0xAARRGGBB layout per element.
    // TGIS_BitmapLinesOrder::Down = scanlines run top-to-bottom.
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
