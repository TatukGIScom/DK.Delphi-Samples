//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//  How to manipulate grid layer presentation
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
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point        ptg        ;
  TGIS_LayerPixel  *ll         ;
  TGIS_Color        rgb        ;
  TGIS_DoubleArray  natives    ;
  Boolean           transp     ;

  if ( GIS->InPaint ) return ;

  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  if ( ll->Locate( ptg, rgb, natives, transp ) ) {
    StatusBar1->Panels->Items[1]->Text = FloatToStr( natives[0] ) ;
  }
  else {
    StatusBar1->Panels->Items[1]->Text = "Unknown" ;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() +
             "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf", true
           ) ;
}

void __fastcall TForm1::btnClearClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  ll->Params->Pixel->AltitudeMapZones->Clear() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnShadowClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  ll->Params->Pixel->GridShadow = ! ll->Params->Pixel->GridShadow ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnUserDefinedClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;

  ll->Params->Pixel->AltitudeMapZones->Clear() ;
  ll->Params->Pixel->AltitudeMapZones->Add( "200,  400 , OLIVE , VERY LOW") ;
  ll->Params->Pixel->AltitudeMapZones->Add( "400,  700 , OLIVE , LOW"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "700,  900 , GREEN , MID"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "900,  1200, BLUE  , HIGH"    ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "1200, 1700, RED   , SKY"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "1700, 2200, YELLOW, HEAVEN"  ) ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnUserIniClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  ll->ConfigName = GisSamplesDataDirDownload() +
                   "\\Samples\\Projects\\dem_ned.ini" ;
  ll->RereadConfig() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnReloadIniClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  ll->ConfigName = GisSamplesDataDirDownload() +
                   "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf.ini" ;
  ll->RereadConfig() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

