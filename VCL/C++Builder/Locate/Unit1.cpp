//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to locate object based on mouse position
//
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

  GIS->Open(  GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp" ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point  ptg  ;
  TGIS_Shape *shp  ;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;
  
  ptg = GIS->ScreenToMap( Point(X, Y ) );
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ; // 5 pixels precision
  if (shp == NULL)
    StatusBar->SimpleText = "" ;
  else
    StatusBar->SimpleText = shp->GetField("name") ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point   ptg  ;
  TGIS_Shape  *shp  ;

  if ( GIS->IsEmpty ) return;
  ptg = GIS->ScreenToMap( Point(X, Y) );
  if (!GIS->InPaint)  
    shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ; // 5 pixels precision
  else
    return;
  if ( shp )
     shp->Flash(4, 100);
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




