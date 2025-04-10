//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide SQL Layer support.
//  Edit gistest.ttkls to provied your database access
//  You can use *.ttkls as any other layer (for example open in editor) 
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
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() +  "\\Samples\\SQLLayers\\gistest.ttkls" , true ) ;
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
