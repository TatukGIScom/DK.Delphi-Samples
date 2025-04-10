//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide zoom on mouse drag
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
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseWheelDown(TObject *Sender,
      TShiftState Shift, TPoint &MousePos, bool &Handled)
{
  TPoint  pt;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  GIS->ZoomBy( 5./4., pt.x, pt.y );
  Handled = true ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseWheelUp(TObject *Sender, TShiftState Shift,
      TPoint &MousePos, bool &Handled)
{
  TPoint  pt;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  GIS->ZoomBy( 4./5., pt.x, pt.y );
  Handled = true ;
}
//---------------------------------------------------------------------------

