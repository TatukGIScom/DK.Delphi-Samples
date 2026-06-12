//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// PixelLocate sample — demonstrates how to query pixel values from raster
// (DEM and image) layers using TGIS_LayerPixel.Locate. Loads either a
// satellite image (DOQ) or a digital elevation model (DEM), then displays
// the RGB color and native pixel channel values when the user moves the
// cursor over the raster. Includes a brightness adjustment slider to modify
// raster appearance. Useful for analyzing pixel content in GIS applications.
//
// Check project\options\directories in a case of any problems during compilation
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

/* Queries pixel values under the cursor and displays RGB color and native channel values. */
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point        ptg;
  TGIS_LayerPixel   *ll;
  TGIS_Color        rgbMapped;
  TGIS_DoubleArray  *nativesVals;
  Boolean           bT;
  AnsiString        str;

  /* Skip if no layers are loaded. */
  if ( GIS->IsEmpty ) return;
  /* Skip if the map is being redrawn. */
  if ( GIS->InPaint ) return ;

  /* Skip if not in Select mode (only query pixels when in Select interaction mode). */
  if ( GIS->Mode != TGIS_ViewerMode::Select ) return;

  /* Convert screen coordinates to map coordinates. */
  ptg = GIS->ScreenToMap( Point(X, Y ) );
  /* Get the first (and likely only) pixel layer in the map. */
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[0] );
  if (ll == NULL) return;

  /* Create array to receive the native pixel values. */
  nativesVals = new TGIS_DoubleArray;

  /* Locate returns true if the point falls within the raster extent;
     it populates rgbMapped (the display color) and nativesVals (raw channel values). */
  if (ll->Locate( ptg, rgbMapped, *nativesVals, bT)) {
    /* Display the RGB color as a color swatch. */
    paColorC->Color = (TColor)RGB(rgbMapped.R,
                        rgbMapped.G,
                        rgbMapped.B );
    /* Show the RGB values in text format. */
    lbRGBValueC->Caption = str.sprintf( "RGB :  %d , %d , %d ",
                                        rgbMapped.R, rgbMapped.G, rgbMapped.B
                                      );
    /* Clear and populate the native channel values display. */
    Memo1->Clear();
    /* Iterate through all native channels (bands) and display their values. */
    for (int i = 0 ; i <= nativesVals->High; i++) {
      str = str.sprintf("CH%d = %.0f", i, (*nativesVals)[i]);
      Memo1->Lines->Add(str);
    }
  }
}
//---------------------------------------------------------------------------

/* Updates the brightness of the raster layer when the user moves the slider. */
void __fastcall TForm1::tbBrightnessChange(TObject *Sender)
{
  TGIS_LayerPixel *ll;

  /* Get the first (and likely only) pixel layer in the map. */
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[0] );
  if (ll == NULL) return;

  /* Apply the brightness adjustment from the slider. */
  ll->Params->Pixel->Brightness = tbBrightness->Position;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

/* Opens a satellite image (DOQ) for inspection and enables brightness adjustment. */
void __fastcall TForm1::btnImageClick(TObject *Sender)
{
  /* Load a Digital Orthophoto Quad (DOQ) satellite image. */
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\DOQ\\37134877.jpg");
  /* Enable brightness slider for images. */
  tbBrightness->Enabled = true ;
  tbBrightness->Position = 0 ;
}
//---------------------------------------------------------------------------

/* Opens a digital elevation model (DEM) for analysis; disables brightness adjustment for DEMs. */
void __fastcall TForm1::btnGridClick(TObject *Sender)
{
  /* Load a National Elevation Dataset (NED) grid in ArcInfo format. */
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf");
  /* Disable brightness slider for elevation data (not applicable). */
  tbBrightness->Enabled = false ;
  tbBrightness->Position = 0 ;
}
//---------------------------------------------------------------------------

