//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide Legend control
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
  GIS->Open( GisSamplesDataDirDownload() +  "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", true ) ;
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
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  if ( GIS->IsEmpty ) return ;

  // save the project
  GIS->SaveAll() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISAfterPaint(TObject *_sender, TObject *_canvas)
{
  StatusBar1->SimpleText = GIS->ScaleAsText ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TabControl1Change(TObject *Sender)
{
  if ( TabControl1->TabIndex == 0 )
    GIS_ControlLegend1->Mode = TGIS_ControlLegendMode::Layers ;
  else
    GIS_ControlLegend1->Mode = TGIS_ControlLegendMode::Groups ;
}
//---------------------------------------------------------------------------

