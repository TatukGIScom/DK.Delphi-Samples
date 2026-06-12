//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Grid Sample (C++Builder / VCL edition)
//
// How to manipulate grid (raster/DEM) layer presentation.
// See Unit1.h for the full description of what this sample demonstrates.
//
// Check project->Options->Directories in case of any problems during compilation.
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
// FormCreate
// Opens the sample NED elevation grid.  TGIS_ViewerWnd::Open auto-detects
// the ArcInfo Binary Grid (.adf) format, creates a TGIS_LayerPixel internally
// and adds it to the viewer's layer list.  The second parameter (true) adds
// the layer with default settings.
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() +
             "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf", true
           ) ;
}

//---------------------------------------------------------------------------
// btnFullExtentClick
// Zooms the viewer to the combined extent of all loaded layers so the entire
// dataset is visible at once.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  // show full map
  GIS->FullExtent() ;
}

//---------------------------------------------------------------------------
// btnZoomClick
// Switches the viewer interaction mode to Zoom, allowing the user to drag a
// rectangle to zoom into an area of interest.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  // set zoom mode
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}

//---------------------------------------------------------------------------
// btnDragClick
// Switches the viewer interaction mode to Drag (pan), allowing the user to
// scroll the map by clicking and dragging.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  // set drag mode
  GIS->Mode = TGIS_ViewerMode::Drag ;
}

//---------------------------------------------------------------------------
// GISMouseMove
// Reads the raw (native) elevation value from the DEM at the geographic point
// under the mouse cursor and shows it in status bar panel[1].
//
// How it works:
//   1. GIS->ScreenToMap converts the screen pixel (X, Y) to map coordinates.
//   2. TGIS_LayerPixel::Locate queries the raster at that point and fills:
//        rgb     - the rendered colour at the queried cell
//        natives - array of raw band values; natives[0] = elevation in metres
//        transp  - true if the queried point is outside the data extent
//   3. The InPaint guard prevents re-entrant calls during map redraws.
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point        ptg        ;  // Geographic map coordinate
  TGIS_LayerPixel  *ll         ;  // Reference to the raster layer
  TGIS_Color        rgb        ;  // Rendered colour at the queried point
  TGIS_DoubleArray  natives    ;  // Raw band values; [0] = elevation
  Boolean           transp     ;  // True if the queried point is outside data area

  // Avoid querying while the map is being redrawn to prevent re-entrant calls
  if ( GIS->InPaint ) return ;

  // Convert screen coordinates to geographic map coordinates
  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;

  // Locate returns true when the point falls within the raster extent
  if ( ll->Locate( ptg, rgb, natives, transp ) ) {
    // natives[0] holds the raw DEM elevation in the layer's native unit (metres)
    StatusBar1->Panels->Items[1]->Text = FloatToStr( natives[0] ) ;
  }
  else {
    StatusBar1->Panels->Items[1]->Text = "Unknown" ;
  }
}

//---------------------------------------------------------------------------
// btnClearClick
// Removes all custom altitude colour zones from the pixel layer, reverting it
// to the default greyscale gradient.  AltitudeMapZones is the list of
// "minElevation, maxElevation, colourName, zoneLabel" strings that define a
// hypsometric tint; clearing it removes all custom colour assignments.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnClearClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  // Cast Items[0] to TGIS_LayerPixel to access raster-specific properties
  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  // Remove all elevation-to-colour mappings
  ll->Params->Pixel->AltitudeMapZones->Clear() ;
  // Force a full redraw so the change is immediately visible
  GIS->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------
// btnShadowClick
// Toggles the hill-shading (GridShadow) effect on the DEM layer.
// Hill-shading simulates a directional light source over the terrain surface,
// darkening north-facing slopes and brightening south-facing ones, which
// dramatically improves the perceived depth of the landscape.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnShadowClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  // Flip the current shadow state (on -> off, or off -> on)
  ll->Params->Pixel->GridShadow = ! ll->Params->Pixel->GridShadow ;
  GIS->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------
// btnUserDefinedClick
// Demonstrates defining a custom hypsometric (altitude-to-colour) scheme
// directly in code.  Each zone string follows the format:
//   "minElevation, maxElevation, colourName, zoneLabel"
// Elevation values are in the native unit of the DEM (metres for NED data).
//---------------------------------------------------------------------------
void __fastcall TForm1::btnUserDefinedClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;

  // Always clear before adding new zones to avoid duplicate entries
  ll->Params->Pixel->AltitudeMapZones->Clear() ;
  // Define six elevation bands covering the terrain range in this DEM
  ll->Params->Pixel->AltitudeMapZones->Add( "200,  400 , OLIVE , VERY LOW") ;
  ll->Params->Pixel->AltitudeMapZones->Add( "400,  700 , OLIVE , LOW"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "700,  900 , GREEN , MID"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "900,  1200, BLUE  , HIGH"    ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "1200, 1700, RED   , SKY"     ) ;
  ll->Params->Pixel->AltitudeMapZones->Add( "1700, 2200, YELLOW, HEAVEN"  ) ;
  // Redraw the viewer so the new colour scheme is applied immediately
  GIS->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------
// btnUserIniClick
// Loads a pre-built sample INI file (dem_ned.ini) that ships with the
// TatukGIS sample data.  This demonstrates that the entire colour zone and
// rendering configuration can be stored externally and applied at runtime
// without modifying source code.  ConfigName points to the INI file;
// RereadConfig re-parses it and applies all stored display parameters.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnUserIniClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  // Point ConfigName to the bundled sample INI configuration file
  ll->ConfigName = GisSamplesDataDirDownload() +
                   "\\Samples\\Projects\\dem_ned.ini" ;
  // Re-read and apply the configuration from the INI file
  ll->RereadConfig() ;
  GIS->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------
// btnReloadIniClick
// Reloads the display configuration from the INI file co-located with the
// grid data file.  The INI suffix is appended explicitly here so the path
// resolves to the data file's own "w001001.adf.ini" companion file.
// RereadConfig parses the file and updates all display parameters.
//---------------------------------------------------------------------------
void __fastcall TForm1::btnReloadIniClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = (TGIS_LayerPixel *)( GIS->Items->Items[ 0 ] ) ;
  // Point ConfigName to the data file's companion INI file
  ll->ConfigName = GisSamplesDataDirDownload() +
                   "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf.ini" ;
  // Re-read and apply the configuration
  ll->RereadConfig() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
