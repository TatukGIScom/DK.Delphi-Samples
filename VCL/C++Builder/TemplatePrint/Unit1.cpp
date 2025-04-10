//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide template based printing
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------


#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "GisTemplatePrint.hpp"
#include "GisFunctions.hpp"
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
  // open a file
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  // show full map
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  // set zoom mode
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  // set drag mode
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

void __fastcall TForm1::GISAfterPaint(TObject *_sender, TObject *_canvas)
{
  StatusBar1->Panels->Items[1]->Text = GIS->ScaleAsText ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  TGIS_TemplatePrint *tmp;
  TGIS_PrintManager *pm;

  tmp = new TGIS_TemplatePrint() ;
  tmp->TemplatePath = GisSamplesDataDirDownload() +  "\\Samples\\PrintTemplate\\printtemplate.tpl" ;
  tmp->GIS_Viewer[ 1 ]
	= interface_cast< IGIS_Viewer >(GIS) ;
  tmp->GIS_Legend[ 1 ]
	= interface_cast< IGIS_PrintableControl >(GIS_ControlLegend1) ;
  tmp->GIS_Scale[ 1 ]
	= interface_cast< IGIS_PrintableControl >(GIS_ControlScale1) ;
  tmp->GIS_NorthArrow[ 1 ]
	= interface_cast< IGIS_PrintableControl >(GIS_ControlNorthArrow1) ;
  tmp->GIS_ViewerExtent[ 1 ] = GIS->Extent ;
  tmp->Text[1] = "Title" ;
  tmp->Text[2] = "Copyright" ;
  try {
	pm = new TGIS_PrintManager() ;
	pm->Template = tmp ;
	GIS_ControlPrintPreviewSimple1->Preview(pm) ;
  }
  __finally {
	delete pm ;
  }
}
//---------------------------------------------------------------------------


