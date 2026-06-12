//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Locate sample — demonstrates how to locate shapes under the cursor using
// TGIS_Viewer.Locate. Loads a world map with USA state counties. When the user
// moves the mouse, Locate identifies the shape at that cursor position and
// displays the county name in the status bar. Clicking any shape causes it to
// flash. This technique is useful for interactive feature selection and
// information display in GIS applications.
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

/* Loads the California counties shapefile into the viewer for interaction. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  /* Open the counties layer; counties are polygons with a "name" field that will be displayed. */
  GIS->Open(  GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp" ) ;
}
//---------------------------------------------------------------------------

/* Locates shapes under the cursor and displays the county name in the status bar. */
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point  ptg  ;
  TGIS_Shape *shp  ;

  /* Skip if map is empty or currently painting. */
  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;

  /* Convert screen coordinates to map space. */
  ptg = GIS->ScreenToMap( Point(X, Y ) );
  /* Locate the shape at the current cursor position with 5-pixel tolerance. */
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ;
  /* If a shape exists, display its name field in the status bar; otherwise clear it. */
  if (shp == NULL)
    StatusBar->SimpleText = "" ;
  else
    StatusBar->SimpleText = shp->GetField("name") ;
}
//---------------------------------------------------------------------------

/* Locates and flashes the shape beneath the mouse click. */
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point   ptg  ;
  TGIS_Shape  *shp  ;

  /* Skip if map is empty. */
  if ( GIS->IsEmpty ) return;
  /* Convert screen coordinates to map space. */
  ptg = GIS->ScreenToMap( Point(X, Y) );
  /* Skip if currently painting. */
  if (!GIS->InPaint)
  {
    /* Use Locate to find any shape at this position (with 5-pixel tolerance for easier selection). */
    shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ;
    /* If a shape was found, flash it to provide visual feedback to the user. */
    if ( shp )
       shp->Flash(4, 100);
  }
}
//---------------------------------------------------------------------------

/* Resets the map view to display the full extent of all layers. */
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/* Zooms in by doubling the zoom factor. */
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

/* Zooms out by halving the zoom factor. */
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------




