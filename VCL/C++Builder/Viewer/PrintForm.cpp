//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to prepare small coverage previewer.
//  Print window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "PrintForm.h"
#include "MainForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmPrint *frmPrint;
//---------------------------------------------------------------------------
__fastcall TfrmPrint::TfrmPrint(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmPrint::btnRefreshClick(TObject *Sender)
{
  // refresh print preview
 // GIS_ControlPrintPreview1->Preview( 1, ' ' ) ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmPrint::btnPreviewClick(TObject *Sender)
{
  // show print preview form
//  GIS_ControlPrintPreviewSimple1->Preview() ;
}
//---------------------------------------------------------------------------
int __fastcall TfrmPrint::inch(double _value)
{
  return Ceil( _value * Canvas->Font->PixelsPerInch ) ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmPrint::GISPrintPage(TObject * _sender,
           TGIS_Printer * _printer, bool &_lastpage)
{
    double     scale;
    TRect      r;
    AnsiString str;

    _printer->Canvas->Brush->Color = clBlack ;
    _printer->Canvas->Brush->Style = bsSolid ;

    r.Left   = 0 ;
    r.Top    = 10 ;
    r.Right  = _printer->PageWidth  ;
    r.Bottom = _printer->PageHeight ;

    r.Left = r.Right  - _printer->TwipsToX( 2*1440 ) ;
    _printer->Canvas->Brush->Color = clGray ;
    _printer->Canvas->Brush->Style = bsSolid ;
    _printer->Canvas->FillRect( r );

    r.Left   = r.Left   - inch( 0.1 ) ;
    r.Top    = r.Top    - inch( 0.1 ) ;
    r.Right  = r.Right  - inch( 0.1 ) ;
    r.Bottom = r.Bottom - inch( 0.1 ) ;
    _printer->Canvas->Brush->Color = clWhite ;
    _printer->Canvas->Brush->Style = bsSolid ;
    _printer->Canvas->FillRect( r );
    _printer->Canvas->Brush->Color = clBlack ;
    _printer->Canvas->FrameRect( r );

    r.Left   = r.Left   + Ceil( 20.0 / Canvas->Font->PixelsPerInch ) ;
    r.Top    = r.Top    + Ceil( 20.0 / Canvas->Font->PixelsPerInch ) ;
    r.Right  = r.Right  - Ceil( 20.0 / Canvas->Font->PixelsPerInch ) ;
    r.Bottom = r.Bottom - Ceil( 20.0 / Canvas->Font->PixelsPerInch ) ;
//    frmMain->GIS_ControlLegend->PrintRect( _printer, r, 0 ) ;

    r.Left   = inch( 0.1 ) ;
    r.Top    = inch( 0.1 ) ;
    r.Right  = _printer->PageWidth  ;
    r.Bottom = _printer->PageHeight ;

    r.Right = r.Right  - _printer->TwipsToX( 2*1440 ) - inch( 0.2 ) ;
    _printer->Canvas->Brush->Color = clGray ;
    _printer->Canvas->Brush->Style = bsSolid ;
    _printer->Canvas->FillRect( r );

    r.Left   = r.Left   - inch( 0.1 ) ;
    r.Top    = r.Top    - inch( 0.1 ) ;
    r.Right  = r.Right  - inch( 0.1 ) ;
    r.Bottom = r.Bottom - inch( 0.1 ) ;
    _printer->Canvas->Brush->Color = clWhite ;
    _printer->Canvas->Brush->Style = bsSolid ;
    _printer->Canvas->FillRect( r );
    _printer->Canvas->Brush->Color = clBlack ;
    _printer->Canvas->FrameRect( r );

    r.Left   = r.Left   + inch( 0.2 ) ;
    r.Top    = r.Top    + inch( 0.2 ) ;
    r.Right  = r.Right  - inch( 0.1 ) ;
    r.Bottom = r.Bottom - inch( 0.1 ) ;

//    frmMain->GIS->PrintRect( _printer, r, frmMain->GIS->Extent, scale ) ;
    str = "Page " + IntToStr(_printer->PageNumber );
//    _printer->Canvas->TextOut( _printer->TwipsToX(720) ,_printer->TwipsToY( 720),  str);

  if (_printer->PageNumber >= 2)  _lastpage = True;
  else _lastpage = False ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmPrint::FormCreate(TObject *Sender)
{
  // let's set the viewer
 // GIS_ControlPrintPreview1->GIS_Viewer = frmMain->GIS;
 // GIS_ControlPrintPreviewSimple1->GIS_Viewer = frmMain->GIS;
}
//---------------------------------------------------------------------------
