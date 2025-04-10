//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to support synchronized, two-windows display.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "math.h"
#include "assert.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
  bSentinel = false;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  // open the same project for two viewers
  GIS_ViewerWnd1->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", true ) ;
  GIS_ViewerWnd1->Zoom = GIS_ViewerWnd1->Zoom * 3 ;
  GIS_ViewerWnd1->Mode = TGIS_ViewerMode::Zoom ;

  GIS_ViewerWnd2->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", true ) ;
  GIS_ViewerWnd2->Zoom = GIS_ViewerWnd2->Zoom * 4 ;
  GIS_ViewerWnd2->Mode = TGIS_ViewerMode::Zoom ;
}

//---------------------------------------------------------------------------

void __fastcall TForm1::GIS_ViewerWnd1VisibleExtentChangeEvent(TObject *Sender)
{
  if (bSentinel) // avoid circular calls
	return;
  bSentinel = true;

  GIS_ViewerWnd1->Lock();

  GIS_ViewerWnd2->Center = GIS_ViewerWnd1->Center ;

  if ( CheckBox1->Checked )
	GIS_ViewerWnd2->Zoom = GIS_ViewerWnd1->Zoom ;

  GIS_ViewerWnd2->Unlock();

  bSentinel = false;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GIS_ViewerWnd2VisibleExtentChangeEvent(TObject *Sender)
{
  if (bSentinel) // avoid circular calls
	return;
  bSentinel = true;

  GIS_ViewerWnd1->Lock();

  GIS_ViewerWnd1->Center = GIS_ViewerWnd2->Center ;

  if ( CheckBox1->Checked )
	GIS_ViewerWnd1->Zoom = GIS_ViewerWnd1->Zoom ;

  GIS_ViewerWnd1->Unlock();

  bSentinel = false;
}
//---------------------------------------------------------------------------

