//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to use PrintPreview controls.
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
  TFontStyles style;

  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;

  printManager = new TGIS_PrintManager() ;
  printManager->Title = edPrintTitle->Text;
  printManager->Subtitle = edPrintSubTitle->Text;
  printManager->Footer = "Footer";

  printManager->TitleFont->Name = "Arial" ;
  printManager->TitleFont->Size = 18 ;
  printManager->TitleFont->Style = to_gis_fontstyle(style << TFontStyle::fsBold);
  printManager->TitleFont->Color = to_gis_color(clWindowText);

  printManager->SubtitleFont->Name = "Arial";
  printManager->SubtitleFont->Size = 14;
  printManager->SubtitleFont->Style = to_gis_fontstyle(style);
  printManager->SubtitleFont->Color = to_gis_color(clWindowText);

  printManager->FooterFont->Name = "Arial";
  printManager->FooterFont->Size = 10;
  printManager->FooterFont->Style = to_gis_fontstyle(style.Clear());
  printManager->FooterFont->Color = to_gis_color(clWindowText);

  printManager->PrintPageEvent = GISPrintPage;
  GIS_ControlPrintPreview1->Preview( 1, printManager ) ;
}

//---------------------------------------------------------------------------
TColor __fastcall TForm1::to_native_color(TGIS_Color _cl)
{
  return VCLColor( _cl ) ;
}

//---------------------------------------------------------------------------
TGIS_Color __fastcall TForm1::to_gis_color(TColor _cl)
{
   return GISColor( _cl ) ;
}

//---------------------------------------------------------------------------
TFontStyles __fastcall TForm1::to_native_fontstyle(TGIS_FontStyles _st )
{
  TFontStyles style;
  if ( _st.Contains( TGIS_FontStyle::Bold ) )
    style << TFontStyle::fsBold ;
  if ( _st.Contains( TGIS_FontStyle::Italic ) )
    style << TFontStyle::fsItalic;
  if ( _st.Contains( TGIS_FontStyle::StrikeOut ) )
    style << TFontStyle::fsStrikeOut;
  if ( _st.Contains( TGIS_FontStyle::Underline ) )
    style << TFontStyle::fsUnderline;
  return style ;
}

//---------------------------------------------------------------------------
TGIS_FontStyles __fastcall TForm1::to_gis_fontstyle(TFontStyles _st )
{
  TGIS_FontStyles style;
  if ( _st.Contains( TFontStyle::fsBold ) )
    style << TGIS_FontStyle::Bold ;
  if ( _st.Contains( TFontStyle::fsItalic ) )
    style << TGIS_FontStyle::Italic ;
  if ( _st.Contains( TFontStyle::fsStrikeOut ) )
    style << TGIS_FontStyle::StrikeOut ;
  if ( _st.Contains( TFontStyle::fsUnderline ) )
    style << TGIS_FontStyle::Underline ;
  return style ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  GIS_ControlPrintPreviewSimple1->Preview( printManager );
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button2Click(TObject *Sender)
{
  GIS_ControlPrintPreview1->Preview(1, printManager);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnTitleFontClick(TObject *Sender)
{
  dlgFontT->Font->Name = printManager->TitleFont->Name;
  dlgFontT->Font->Size = printManager->TitleFont->Size;
  dlgFontT->Font->Style = to_native_fontstyle(printManager->TitleFont->Style);
  dlgFontT->Font->Color = to_native_color(printManager->TitleFont->Color);
  if (!dlgFontT->Execute()) exit;
  printManager->TitleFont->Name = dlgFontT->Font->Name ;
  printManager->TitleFont->Size = dlgFontT->Font->Size ;
  TFontStyles style = dlgFontT->Font->Style ;
  printManager->TitleFont->Style = to_gis_fontstyle(style);
  printManager->TitleFont->Color = to_gis_color(dlgFontT->Font->Color);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnSubTitleFontClick(TObject *Sender)
{
  dlgFontST->Font->Name = printManager->SubtitleFont->Name;
  dlgFontST->Font->Size = printManager->SubtitleFont->Size;
  dlgFontST->Font->Style = to_native_fontstyle(printManager->SubtitleFont->Style);
  dlgFontST->Font->Color = to_native_color(printManager->SubtitleFont->Color);
  if (!dlgFontST->Execute()) exit;
  printManager->SubtitleFont->Name = dlgFontST->Font->Name ;
  printManager->SubtitleFont->Size = dlgFontST->Font->Size ;
  TFontStyles style = dlgFontST->Font->Style ;
  printManager->SubtitleFont->Style = to_gis_fontstyle(style);
  printManager->SubtitleFont->Color = to_gis_color(dlgFontST->Font->Color);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::dlgFontTApply(TObject *Sender, HWND Wnd)
{
  printManager->TitleFont->Name = dlgFontT->Font->Name ;
  printManager->TitleFont->Size = dlgFontT->Font->Size ;
  TFontStyles style = dlgFontT->Font->Style ;
  printManager->TitleFont->Style = to_gis_fontstyle(style);
  printManager->TitleFont->Color = to_gis_color(dlgFontT->Font->Color);
  GIS_ControlPrintPreview1->Preview(1, printManager);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::dlgFontSTApply(TObject *Sender, HWND Wnd)
{
  printManager->SubtitleFont->Name = dlgFontST->Font->Name ;
  printManager->SubtitleFont->Size = dlgFontST->Font->Size ;
  TFontStyles style = dlgFontST->Font->Style ;
  printManager->SubtitleFont->Style = to_gis_fontstyle(style);
  printManager->SubtitleFont->Color = to_gis_color(dlgFontST->Font->Color);
  GIS_ControlPrintPreview1->Preview(1, printManager);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::edPrintTitleChange(TObject *Sender)
{
  printManager->Title = edPrintTitle->Text;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::edPrintSubTitleChange(TObject *Sender)
{
  printManager->Subtitle = edPrintSubTitle->Text;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::chkStandardPrintClick(TObject *Sender)
{
  if (chkStandardPrint->Checked)
    printManager->PrintPageEvent = NULL ;
  else
    printManager->PrintPageEvent = this->GISPrintPage;

  GIS_ControlPrintPreview1->Preview( 1, printManager ) ;
}

//---------------------------------------------------------------------------
int __fastcall TForm1::inch(TGIS_Printer *_printer, double _value)
{
  return Ceil( _value * _printer->Canvas->Font->PixelsPerInch ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISPrintPage(TObject *_sender,
       TGIS_PrintManager *_printmanager, bool &_lastpage)
{
    TGIS_PrintManager *pm ;
    TGIS_Printer *pr ;
    double     scale;
    TRect      r;
    TRect      fr;
    TRect      mr;
    int        h;
    AnsiString str;

    pm = _printmanager;
    pr = pm->Printer;

    // left panel
    r.Left   = inch( pr, 0.1 ) ;
    r.Top    = inch( pr, 0.5 ) ;
    r.Right  = pr->PageWidth  ;
    r.Bottom = pr->PageHeight ;

    // left panel: gray rectangle
    r.Right = r.Right  - pr->TwipsToX( 2*1440 ) - inch( pr, 0.2 ) ;
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::Gray ) ;
    pr->Canvas->Brush->Style = bsSolid ;
    pr->Canvas->FillRect( r );

    // left panel: white rectangle
    r.Left   = r.Left   - inch( pr, 0.1 ) ;
    r.Top    = r.Top    - inch( pr, 0.1 ) ;
    r.Right  = r.Right  - inch( pr, 0.1 ) ;
    r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::White ) ;
    pr->Canvas->Brush->Style = bsSolid ;
    pr->Canvas->FillRect( r );
    fr = r ;

    // left panel: map
    r.Left   = r.Left   + inch( pr, 0.1 ) ;
    r.Top    = r.Top    + inch( pr, 0.1 ) ;
    r.Right  = r.Right  - inch( pr, 0.1 ) ;
    r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
    scale=0 ;
    // 'scale' returned by the function is the real map scale used during printing.
    // It should be passed to the following DrawControl methods.
    // If legend or scale controls have to be printed before map (for some reason)
    // use the following frame:
    //    scale := 0 ;
    //    pm->GetDrawingParams( GIS, GIS.Extent, r, scale ) ; ...
    //    pm->DrawControl( GIS_ControlLegend1, r1, scale ) ;  ...
    //    pm->DrawMap( GIS, GIS.Extent, r, scale ) ;
    pm->DrawMap( interface_cast< IGIS_Viewer >(GIS), GIS->Extent, r, scale ) ;
    mr = r ;

    // left panel: black frame
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::Black ) ;
    pr->Canvas->FrameRect( fr );

    // right panel
    r.Left   = 0 ;
    r.Top    = inch( pr, 0.5 ) ;
    r.Right  = pr->PageWidth  ;
    r.Bottom = pr->PageHeight ;

    // right panel: gray rectangle
    r.Left = r.Right  - pr->TwipsToX( 2*1440 ) ;
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::Gray ) ;
    pr->Canvas->Brush->Style = bsSolid ;
    pr->Canvas->FillRect( r );

    // right panel: white rectangle
    r.Left   = r.Left   - inch( pr, 0.1 ) ;
    r.Top    = r.Top    - inch( pr, 0.1 ) ;
    r.Right  = r.Right  - inch( pr, 0.1 ) ;
    r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::White ) ;
    pr->Canvas->Brush->Style = bsSolid ;
    pr->Canvas->FillRect( r );
    fr = r ;

    // right panel: legend
    r.Left   = r.Left   + inch( pr, 0.1 ) ;
    r.Top    = r.Top    + inch( pr, 0.1 ) ;
    r.Right  = r.Right  - inch( pr, 0.1 ) ;
    r.Bottom = r.Bottom - inch( pr, 0.1 ) ;
    pm->DrawControl( (_di_IGIS_PrintableControl)(*GIS_ControlLegend1), r, scale ) ;

    // right panel: black frame
    pr->Canvas->Brush->Color = to_native_color( TGIS_Color::Black ) ;
    pr->Canvas->FrameRect( fr );


    // page number
    str = "Page " + IntToStr(pr->PageNumber );
    pr->Canvas->Font->Name = "Arial";
    pr->Canvas->Font->Size = 12;
    pr->Canvas->Brush->Color = clWhite ;
    pr->Canvas->TextOut( pr->TwipsToX(720) ,pr->TwipsToY( 720),  str);

    r = mr ;
    // title
    pr->Canvas->Font->Name = pm->TitleFont->Name;
    pr->Canvas->Font->Size = pm->TitleFont->Size;
    pr->Canvas->Font->Style = to_native_fontstyle(pm->TitleFont->Style);
    pr->Canvas->Font->Color = to_native_color(pm->TitleFont->Color);
    pr->Canvas->TextOut( Ceil( (r.Right - r.Left) / 2.0 ) -
						 Ceil( pr->Canvas->TextWidth( pm->Title ) / 2.0),
						 pr->TwipsToY( 720),
						 pm->Title );

    // subtitle
    h = pr->Canvas->TextHeight( pm->Title ) ;
    pr->Canvas->Font->Name = pm->SubtitleFont->Name;
    pr->Canvas->Font->Size = pm->SubtitleFont->Size;
    pr->Canvas->Font->Style = to_native_fontstyle(pm->SubtitleFont->Style);
	pr->Canvas->Font->Color = to_native_color(pm->SubtitleFont->Color);
    pr->Canvas->TextOut( Ceil( (r.Right - r.Left) / 2.0 ) -
                         Ceil( pr->Canvas->TextWidth(pm->Subtitle ) / 2.0),
                         pr->TwipsToY(720 + 200 ) + h,
                         pm->Subtitle );

    _lastpage = True;

}
//---------------------------------------------------------------------------
