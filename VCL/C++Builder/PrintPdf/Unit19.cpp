//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit19.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisControlScale"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
String PdfFileName;
TForm19 *Form19;
//---------------------------------------------------------------------------
__fastcall TForm19::TForm19(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm19::FormCreate(TObject *Sender)
{
  // open a file
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
  GIS->Mode = TGIS_ViewerMode::Zoom ;
  //PdfFileName = '';
}
//---------------------------------------------------------------------------
void __fastcall TForm19::btnFullExtentClick(TObject *Sender)
{
  // set drag mode
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm19::btnZoomClick(TObject *Sender)
{
  // set zoom mode
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TForm19::btnDragClick(TObject *Sender)
{
  // set drag mode
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

void __fastcall TForm19::Button1Click(TObject *Sender)
{
	TGIS_PrintManager *pm;
	TGIS_TemplatePrint *tp;

	// choose a file
	if (PdfFileName == "")
	{
	  dlgSave->InitialDir = GetCurrentDir() ;
	  dlgSave->FileName = "";
	}
	else
	{
	  dlgSave->InitialDir = ExtractFilePath(PdfFileName);
	  dlgSave->FileName = ExtractFileName(PdfFileName);
	} ;
	if (!dlgSave->Execute()) return;
	PdfFileName = dlgSave->FileName ;
	StatusBar1->SimpleText = PdfFileName;

	// all PrintPdf methods below
	// have its versions with a stream instead of file name
	if (RadioGroup1->ItemIndex == 0)
	{
	  // GIS.PrintPdf
	  GIS->PrintPdf( PdfFileName,
					210 * 72 / 25.4,
					297 * 72 / 25.4
				  ) ;
	}
	else if (RadioGroup1->ItemIndex == 1)
	{
	  // standard print
	  pm = new TGIS_PrintManager() ;
	  try
	  {
		pm->PrintPdf( interface_cast< IGIS_Viewer >(GIS), PdfFileName,
					 (float)210 * 72 / 25.4,
					 (float)297 * 72 / 25.4
				   ) ;
	  }
	  __finally
	  {
		delete pm ;
	  } ;
	}
	else if (RadioGroup1->ItemIndex == 2)
	{
	  // template
	  tp = new TGIS_TemplatePrint() ;
	  tp->TemplatePath = GisSamplesDataDirDownload() + "Samples\\PrintTemplate\\printtemplate.tpl" ;
	  tp->GIS_Viewer[ 1 ] = interface_cast< IGIS_Viewer >(GIS) ;
	  tp->GIS_ViewerExtent[ 1 ] = GIS->VisibleExtent ;
	  tp->GIS_ViewerScale[ 1 ]  = 0 ;
	  tp->GIS_Scale[ 1 ] = interface_cast< IGIS_PrintableControl >(GISScale) ;
	  tp->GIS_Legend[ 1 ] = interface_cast< IGIS_PrintableControl >(GISLegend) ;
	  tp->Text[ 1 ] = "Title Title" ;
	  tp->Text[ 2 ] = "Copyright" ;

	  pm = new TGIS_PrintManager() ;
	  try
	  {
		pm->Template = tp ;
		pm->PrintPdf( interface_cast< IGIS_Viewer >(GIS), PdfFileName,
					 210 * 72 / 25.4,
					 297 * 72 / 25.4
				   ) ;
	  }
	  __finally
	  {
		delete pm;
	  };
	}
	else if (RadioGroup1->ItemIndex == 3)
	{
	  //PrintPage event
	  pm = new TGIS_PrintManager() ;
	  try
	  {
		// PrintPage for custom paint
		pm->PrintPageEvent = PrintPage ;
		pm->PrintPdf( interface_cast< IGIS_Viewer >(GIS), PdfFileName,
					 210 * 72 / 25.4,
					 297 * 72 / 25.4
				   ) ;
	  }
	  __finally
	  {
		delete pm ;
	  }
	}
	else if (RadioGroup1->ItemIndex == 4)
	{
	  // multi-page: mix of different scenarios
	  pm = new TGIS_PrintManager() ;
	  try
	  {
		// BeforePrintPage defines the way a page will be printed
		pm->BeforePrintPageEvent = BeforePrintPage ;
		pm->PrintPdf( interface_cast< IGIS_Viewer >(GIS), PdfFileName,
					 210 * 72 / 25.4,
					 297 * 72 / 25.4
				   ) ;
	  }
	  __finally
	  {
		delete pm ;
	  } ;
	} ;
}
//---------------------------------------------------------------------------
int __fastcall TForm19::inch(TGIS_Printer *_printer, double _value)
{
  return Ceil( _value * _printer->PPI ) ;
}

//---------------------------------------------------------------------------
void __fastcall TForm19::PrintPage(TObject *_sender,
	   TGIS_PrintManager *_printmanager, bool &_lastpage)
{
  TRect r;
  TRect r1;
  Double scale;
  String s;
  int h;
  TPoint pt;
  TGIS_PrintManager *pm;
  TGIS_Printer *pr;
  TGIS_RendererAbstract *rd;

  pm = _printmanager ;
  pr = pm->Printer ;
  rd = pr->Renderer ;

  rd->CanvasBrush->Color = TGIS_Color::Black ;
  rd->CanvasBrush->Style = TGIS_BrushStyle::Solid ;

  r.Left   = 0 ;
  r.Top    = inch( pr, 0.5 ) ;
  r.Right  = pr->PageWidth  ;
  r.Bottom = pr->PageHeight ;

  // right panel
  r.Left = r.Right  - pr->TwipsToX( 2*1440 ) ;
  rd->CanvasBrush->Color = TGIS_Color::Gray ;
  rd->CanvasBrush->Style = TGIS_BrushStyle::Solid ;
  rd->CanvasPen->Style   = TGIS_PenStyle::Clear ;
  rd->CanvasDrawRectangle( r ) ;

  r.Left   = r.Left   - inch( pr, 0.1 ) ;
  r.Top    = r.Top    - inch( pr, 0.1 ) ;
  r.Right  = r.Right  - inch( pr, 0.1 ) ;
  r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
  rd->CanvasBrush->Color = TGIS_Color::White ;
  rd->CanvasBrush->Style = TGIS_BrushStyle::Solid ;
  rd->CanvasPen->Color   = TGIS_Color::Black ;
  rd->CanvasPen->Style   = TGIS_PenStyle::Solid ;
  rd->CanvasPen->Width   = rd->TwipsToPoints( 20 ) ;
  rd->CanvasDrawRectangle( r ) ;

  // legend
  r.Left   = r.Left   + 1 ;
  r.Top    = r.Top    + 1 ;
  r.Right  = r.Right  - 1 ;
  r.Bottom = r.Bottom - 1 ;
  pm->DrawControl( interface_cast< IGIS_PrintableControl >(GISLegend), r ) ;

  r.Left   = inch( pr, 0.1 ) ;
  r.Top    = inch( pr, 0.5 ) ;
  r.Right  = pr->PageWidth  ;
  r.Bottom = pr->PageHeight ;

  // left panel
  r.Right = r.Right  - pr->TwipsToX( 2*1440 ) - inch( pr, 0.2 ) ;
  rd->CanvasBrush->Color = TGIS_Color::Gray ;
  rd->CanvasBrush->Style = TGIS_BrushStyle::Solid ;
  rd->CanvasPen->Style   = TGIS_PenStyle::Clear ;
  rd->CanvasDrawRectangle( r ) ;
  // for future use
  r1 = r ;

  r.Left   = r.Left   - inch( pr, 0.1 ) ;
  r.Top    = r.Top    - inch( pr, 0.1 ) ;
  r.Right  = r.Right  - inch( pr, 0.1 ) ;
  r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
  rd->CanvasBrush->Color = TGIS_Color::White ;
  rd->CanvasBrush->Style = TGIS_BrushStyle::Solid ;
  rd->CanvasPen->Color   = TGIS_Color::Black ;
  rd->CanvasPen->Style   = TGIS_PenStyle::Solid ;
  rd->CanvasPen->Width   = rd->TwipsToPoints( 20 ) ;
  rd->CanvasDrawRectangle( r ) ;

  // map
  r.Left   = r.Left   + 1 ;
  r.Top    = r.Top    + 1 ;
  r.Right  = r.Right  - 1 ;
  r.Bottom = r.Bottom - 1 ;
  scale = 0 ;
  pm->DrawMap( interface_cast< IGIS_Viewer >(GIS), GIS->Extent, r, scale ) ;

  // scale
  r.Left   = r.Left   + inch( pr, 0.5 ) ;
  r.Top    = r.Bottom - inch( pr, 1.0 ) ;
  r.Right  = r.Left   + inch( pr, 3.0 ) ;
  r.Bottom = r.Bottom - inch( pr, 0.5 ) ;
  pm->DrawControl( interface_cast< IGIS_PrintableControl >(GISScale), r ) ;

  // page number
  rd->CanvasBrush->Color = TGIS_Color::White ;
  rd->CanvasFont->Color = TGIS_Color::Black ;
  rd->CanvasFont->Name = "Arial" ;
  rd->CanvasFont->Size = 12 ;
  s = "Page " + IntToStr(pr->PageNumber) ;
  pt = rd->CanvasTextExtent( s ) ;
  r.Left   = pr->TwipsToX(720) ;
  r.Top    = r1.Top + pr->TwipsToY(720) ;
  r.Right  = r.Left + pt.X ;
  r.Bottom = r.Top + pt.Y ;
  rd->CanvasDrawText( r, s );

  // title
  pm->Title = "Print Title";
  s = pm->Title ;
  rd->CanvasFont->Assign( pm->TitleFont ) ;
  pt = rd->CanvasTextExtent( pm->Title ) ;
  r.Left   = Ceil( (r1.Right - r1.Left) / 2.0 ) - Ceil( pt.X / 2.0 ) ;
  r.Top    = r1.Top + pr->TwipsToY(720) ;
  r.Right  = r.Left + pt.X ;
  r.Bottom = r.Top + pt.Y ;
  rd->CanvasDrawText( r, s );
  h = r.Height() ;

  // subitle
  pm->Subtitle = "Print Subtitle";
  s = pm->Subtitle ;
  rd->CanvasFont->Assign( pm->SubtitleFont ) ;
  pt = rd->CanvasTextExtent( pm->Subtitle ) ;
  r.Left   = Ceil( (r1.Right - r1.Left) / 2.0 ) - Ceil( pt.X / 2.0 ) ;
  r.Top    = r1.Top + pr->TwipsToY(720) + h + pr->TwipsToY(200) ;
  r.Right  = r.Left + pt.X ;
  r.Bottom = r.Top + pt.Y ;
  rd->CanvasDrawText( r, s );

  if (pr->PageNumber >= 2) _lastpage = True;
  else                     _lastpage = False ;
}
//---------------------------------------------------------------------------

void __fastcall TForm19::BeforePrintPage(TObject *_sender,
	   TGIS_PrintManager *_printmanager, bool &_lastpage)
{
	TGIS_PrintManager *pm ;
	TGIS_Printer *pr ;
	TGIS_TemplatePrint *tp ;

  pm = _printmanager ;
  pr = pm->Printer ;

  if (pr->PageNumber == 1)
  {
	// prepare first page: PrintPage event
	pm->Template = NULL ;
	pm->PrintPageEvent = PrintPage ;
  }
  else if (pr->PageNumber == 2 )
  {
	// prepare second page: standard print
	pm->Template = NULL ;
	pm->PrintPageEvent = NULL ;
  }
  else if (pr->PageNumber == 3)
  {
	// prepare third page: ttktemplate
	tp = new TGIS_TemplatePrint() ;
	tp->TemplatePath = GisSamplesDataDirDownload() + "Samples\\PrintTemplate\\printtemplate.tpl" ;
	tp->GIS_Viewer[ 1 ] = interface_cast< IGIS_Viewer >(GIS) ;
	tp->GIS_ViewerExtent[ 1 ] = GIS->VisibleExtent ;
	tp->GIS_ViewerScale[ 1 ]  = GIS->ScaleAsFloat ;
	tp->GIS_Scale[ 1 ] = interface_cast< IGIS_PrintableControl >(GISScale) ;
	tp->GIS_Legend[ 1 ] = interface_cast< IGIS_PrintableControl >(GISLegend) ;
	tp->Text[ 1 ] = "Page " + IntToStr(pr->PageNumber) ;
	tp->Text[ 2 ] = tp->TemplatePath ;
	pm->Template = tp;
	pm->PrintPageEvent = NULL ;
  }

  if (pr->PageNumber >= 3) _lastpage = true  ;
  else                     _lastpage = false ;
}
//---------------------------------------------------------------------------

