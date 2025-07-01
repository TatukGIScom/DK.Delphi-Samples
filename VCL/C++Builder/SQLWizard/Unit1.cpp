//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  SQLWizard Sample.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
    GIS->FullExtent();
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

void __fastcall TForm1::btnSqlWizardClick(TObject *Sender)
{
    frmLayerSQL->Show();
}
//---------------------------------------------------------------------------

