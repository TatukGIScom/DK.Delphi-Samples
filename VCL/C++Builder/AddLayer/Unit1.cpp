//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to add layer to the map.
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
  TGIS_LayerSHP *ll ;

  ll = new TGIS_LayerSHP;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\country.shp" ;
  ll->Name = "country";
  GIS->Add(ll) ;

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\lwaters.shp" ;
  ll->UseConfig = False ;
  ll->Params->Line->OutlineWidth = 0;
  ll->Params->Line->Width = 3;
  ll->Params->Line->Color = TGIS_Color::Blue;
  GIS->Add(ll) ;

  GIS->FullExtent() ;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::chkDragClick(TObject *Sender)
{
  if ( chkDrag->Checked ) {
     GIS->Mode = TGIS_ViewerMode::Drag ;
  }
  else {
     GIS->Mode = TGIS_ViewerMode::Select ;
  } ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------
