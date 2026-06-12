//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  Pixel - demonstrates how to open and display raster (pixel) layers using
//  different rendering modes provided by TatukGIS.
//
//  The sample loads a pre-built .ttkproject file that contains a raster layer
//  and lets the user switch between rendering profiles via a combo box:
//    - Normal, Normal with histogram, Grayscale, Transparent,
//      Colorize, Inversion, Inversion by RGB.
//
//  Key TatukGIS API concepts shown here:
//    - TGIS_ViewerWnd  : the main map viewer control
//    - GisSamplesDataDirDownload() : resolves the sample-data root path so
//        hard-coded absolute paths are avoided
//    - GIS->Open()     : opens a .ttkproject (or any supported raster/vector
//        file) and adds all its layers to the viewer
//    - GIS->FullExtent(): zooms the view to fit all loaded layers
//    - TGIS_ViewerMode : enumeration controlling user-interaction mode
//        (Zoom = rubber-band zoom, Drag = pan/scroll)
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

// FormCreate - runs when the form is first created.
// Selects the first project in the combo box and triggers an initial load
// so the viewer is populated as soon as the application starts.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  ComboProject->ItemIndex = 0 ;
  ComboProjectChange( Sender ) ;
}
//---------------------------------------------------------------------------

// btnFullExtentClick - resets the map view so that all loaded layers are
// visible simultaneously.
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

// ComboProjectChange - fires whenever the user picks a different project from
// the combo box. Calls GIS->Open() with the path to the selected .ttkproject
// file. GisSamplesDataDirDownload() returns the base directory for sample
// data, keeping the path independent of any particular installation layout.
void __fastcall TForm1::ComboProjectChange(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\" +
    ComboProject->Items->Strings[ ComboProject->ItemIndex ] ) ;
}
//---------------------------------------------------------------------------

// btnZoomClick - switches the viewer to Zoom mode: the user draws a rectangle
// to zoom in, or right-clicks to zoom out.
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

// btnDragClick - switches the viewer to Drag mode: the user can pan the map
// by clicking and dragging.
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------
