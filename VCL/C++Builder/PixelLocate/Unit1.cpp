//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide basic pixel support.
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
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point        ptg;
  TGIS_LayerPixel   *ll;
  TGIS_Color        rgbMapped;
  TGIS_DoubleArray  *nativesVals;
  Boolean           bT;
  AnsiString        str;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;

  if ( GIS->Mode != TGIS_ViewerMode::Select ) return;

  ptg = GIS->ScreenToMap( Point(X, Y ) );
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[0] );
  if (ll == NULL) return;

  nativesVals = new TGIS_DoubleArray;
  
  if (ll->Locate( ptg, rgbMapped, *nativesVals, bT)) {
	paColorC->Color = (TColor)RGB(rgbMapped.R,
						  rgbMapped.G,
                          rgbMapped.B );
    lbRGBValueC->Caption = str.sprintf( "RGB :  %d , %d , %d ",
                                        rgbMapped.R, rgbMapped.G, rgbMapped.B
                                      );
    Memo1->Clear();
    for (int i = 0 ; i <= nativesVals->High; i++) {
      str = str.sprintf("CH%d = %.0f", i, (*nativesVals)[i]);
      Memo1->Lines->Add(str);
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::tbBrightnessChange(TObject *Sender)
{
  TGIS_LayerPixel *ll;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[0] );
  if (ll == NULL) return;

  ll->Params->Pixel->Brightness = tbBrightness->Position;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnImageClick(TObject *Sender)
{
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\DOQ\\37134877.jpg");
  tbBrightness->Enabled = true ;
  tbBrightness->Position = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnGridClick(TObject *Sender)
{
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf");
  tbBrightness->Enabled = false ;
  tbBrightness->Position = 0 ;
}
//---------------------------------------------------------------------------

