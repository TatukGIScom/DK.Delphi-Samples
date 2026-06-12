//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include <GisUtils.hpp>
#include <GisViewshed.hpp>
#include <GisAllLayers.hpp>
#include <GisSymbol.hpp>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TfrmMain *frmMain;
const char* SAMPLE_VIEWSHED_NAME = "Viewshed";
const char* SAMPLE_AGL_NAME      = "Above-Ground-Level";
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
/* Toggles active state between the viewshed and AGL layers based on the selected
   radio button, refreshes the color ramp, and updates the hint label. */
void __fastcall TfrmMain::setLayerActive()
{
  GIS->Lock();
  makeViewshedRamp();
  if( GIS->Get( SAMPLE_VIEWSHED_NAME ) != NULL )
  {
	lViewshed->Active = !rbtnAGL->Checked;
	lAGL->Active = rbtnAGL->Checked;
	GIS->InvalidateWholeMap();
  }
  GIS->Unlock();
}
//---------------------------------------------------------------------------
/* Applies a binary (green = visible) or frequency (red-to-green gradient) color
   ramp to the viewshed layer based on the selected radio button. */
void __fastcall TfrmMain::makeViewshedRamp()
{
  if( GIS->Get( SAMPLE_VIEWSHED_NAME ) == NULL )
	return;

  lViewshed->Transparency = 50;
  lViewshed->Params->Pixel->GridShadow = False;
  lViewshed->Params->Pixel->AltitudeMapZones->Clear();

  // create color ramp for binary viewshed
  if( rbtnViewshedBinary->Checked )
  {
	lViewshed->GenerateRamp(
	  TGIS_Color::FromARGB( 127, 0, 255, 0 ),
	  TGIS_Color::None,
	  TGIS_Color::FromARGB( 127, 0, 255, 0 ),
	  lViewshed->MinHeight, 0.01,
	  lViewshed->MaxHeight, false,
	  ( lViewshed->MaxHeight - lViewshed->MinHeight )/100,
	  ( lViewshed->MaxHeight - lViewshed->MinHeight )/10,
      NULL, false
	) ;
  }
  else
  // create color ramp for frequency viewshed
  if( rbtnViewshedFreq->Checked )
  {
    lViewshed->GenerateRamp(
	  TGIS_Color::FromARGB( 127, 255, 0, 0),
	  TGIS_Color::None,
	  TGIS_Color::FromARGB( 127, 0, 255, 0),
      0, 1,
	  lViewshed->MaxHeight, false,
	  ( lViewshed->MaxHeight - lViewshed->MinHeight )/100,
	  ( lViewshed->MaxHeight - lViewshed->MinHeight )/10,
      NULL, false
	) ;
  }
}
//---------------------------------------------------------------------------
/* Updates the hint label with a description of the currently active layer's
   color scheme. */
void __fastcall TfrmMain::showComment()
{
  String str="" ;
  if( rbtnViewshedBinary->Checked )
  {
	lblHint->Caption = "Green - area of visibility." ;
  }
  else
  if( rbtnViewshedFreq->Checked )
  {
	str = str + "Visibility frequency; " +
				"Red - one  observer is visible; " +
				"Green - all observers are visible." ;
	lblHint->Caption = str ;
  }
  else
  if( rbtnAGL->Checked && ( lAGL != NULL ) )
  {
	str = str + "Minimum height that must be added to a nonvisible cell " +
				"to make it visible by at least one observer; " +
				"Red = " + IntToStr( (Integer)lAGL->MaxHeight ) + " m" ;
	lblHint->Caption = str ;
  }
}
//---------------------------------------------------------------------------
/* Opens the DEM raster for San Bernardino, CA; creates an Observers vector layer
   with a tower symbol; and zooms to the full extent.

   Steps:
   1. Load the National Elevation Dataset (NED) raster layer.
   2. Cache a reference to the terrain layer for later viewshed computation.
   3. Create an empty Observers layer with the same coordinate system as the DEM.
   4. Configure tower symbols to visualize observer locations.
   5. Add the observers layer to the viewer and fit the viewport. */
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  /* Lock the viewer to batch all initialization operations before repainting. */
  GIS->Lock();
  /* Load the San Bernardino NED digital elevation model (USGS raster format). */
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf"
  );
  /* Cache a reference to the terrain layer for viewshed calculations. */
  lTerrain = (TGIS_LayerPixel *)GIS->Get( "w001001" );

  /* Create an in-memory vector layer to hold observer point geometries and symbols. */
  lObservers = new TGIS_LayerVector();
  lObservers->Name = "Observers";
  /* Use the same coordinate system as the DEM to ensure all geometries align. */
  lObservers->CS = lTerrain->CS;
  lObservers->Open();

  /* Load and configure tower symbols from the SVG symbol library for visual identification. */
  lObservers->Params->Marker->Symbol =
    SymbolList()->Prepare("LIBSVG:std:TowerCommunication01");
  /* White tower symbols with white outline for visibility on terrain. */
  lObservers->Params->Marker->Color = TGIS_Color::White;
  lObservers->Params->Marker->OutlineColor = TGIS_Color::White;
  /* Size in screen pixels (negative = screen-space, not map-space). */
  lObservers->Params->Marker->Size = -32;
  /* Unlock the viewer so it can repaint with the configured layers. */
  GIS->Unlock();

  /* Add the observers layer to the viewer. */
  GIS->Add( lObservers );
  /* Fit the viewport to show the full extent of all loaded layers. */
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

/* In UserDefined mode, adds the clicked point as an observer, runs TGIS_Viewshed.Generate
   to compute viewshed and AGL rasters, and refreshes the display with the appropriate
   color ramp.

   Algorithm:
   1. Guard: only process clicks when in UserDefined mode.
   2. Validate the observer elevation offset from the text field.
   3. Convert screen pixel to map coordinates.
   4. Guard: skip if the point is outside the DEM extent.
   5. Create a point shape at the click location and add it to the observers layer.
   6. Clear any previous viewshed/AGL results.
   7. Create empty in-memory raster layers for viewshed and AGL outputs.
   8. Configure TGIS_Viewshed with elevation and Earth curvature settings.
   9. Call Generate() to compute visibility from all accumulated observer points.
   10. Color-map the output rasters and refresh the display. */
void __fastcall TfrmMain::GISMouseDown(TObject *Sender, TMouseButton Button,
  TShiftState Shift, int X, int Y)
{
  TGIS_Point pt;
  TGIS_Shape *shp;
  TGIS_Viewshed *vs;
  Single elev;

  if( GIS->Mode == TGIS_ViewerMode::UserDefined )
  {
	/* Read the observer height offset from the input field (height above DEM elevation). */
	try
	{
	  elev = DotStrToFloat( edtObserverElevation->Text );
	}
	catch(...)
	{
	  ShowMessage( "'" + edtObserverElevation->Text +
				   "' is not a valid floating point value."
	  );
	  return;
	}

	/* Convert screen pixel coordinates (X,Y) to map geographic coordinates. */
	pt = GIS->ScreenToMap( Point( X, Y ) );
	/* Guard: skip if the clicked location is outside the DEM area (no elevation data). */
	if( !GisIsPointInsideExtent( pt, lTerrain->Extent ) )
	   return;

	/* Lock the viewer to batch multiple modifications before repainting. */
	GIS->Lock();

	/* Create a new point shape at the clicked location and add it to the observers layer. */
	shp = lObservers->CreateShape(
	  TGIS_ShapeType::Point, TGIS_DimensionType::XY
	);
	shp->AddPart();
	shp->AddPoint( pt );

	/* Remove any previously computed viewshed and AGL rasters before recalculating. */
	if( GIS->Get( SAMPLE_VIEWSHED_NAME ) != NULL )
	{
	  GIS->Delete( SAMPLE_VIEWSHED_NAME );
	  lViewshed = NULL;
	  GIS->Delete( SAMPLE_AGL_NAME );
	  lAGL = NULL;
	}

	/* Create an empty in-memory raster layer to hold the viewshed output.
	   Build creates a new raster with the same extent and resolution as the DEM. */
	lViewshed = new TGIS_LayerPixel();
	lViewshed->Build( true, lTerrain->CS, lTerrain->Extent,
					  lTerrain->BitWidth, lTerrain->BitHeight );
	lViewshed->Name = SAMPLE_VIEWSHED_NAME;
	lViewshed->Open();

	/* Create an empty in-memory raster layer to hold the AGL (Above-Ground-Level) output.
	   AGL shows the minimum height needed for non-visible cells to become visible. */
	lAGL = new TGIS_LayerPixel();
	lAGL->Build( true, lTerrain->CS, lTerrain->Extent,
				 lTerrain->BitWidth, lTerrain->BitHeight );
	lAGL->Name = SAMPLE_AGL_NAME;
	lAGL->Open();

	/* Create and configure the TGIS_Viewshed terrain analysis engine. */
	vs = new TGIS_Viewshed();
	/* Set observer elevation source: OnDem = read from the DEM; alternative is elevation offset only. */
	vs->ObserverElevation = TGIS_ViewshedObserverElevation::OnDem;
	/* Enable Earth curvature and atmospheric refraction correction for long-distance sightlines.
	   This accounts for the spherical shape of Earth and light refraction through the atmosphere. */
	vs->CurvedEarth = true;

	/* Execute the viewshed computation using all accumulated observer points in lObservers.
	   Generate populates lViewshed (visibility per cell) and lAGL (minimum height for visibility).
	   The 'elev' parameter is an additional height offset added to each observer's position. */
	vs->Generate(lTerrain, lObservers, lViewshed, lAGL, 0.0, "", elev);
	delete vs;

	/* Set the initial visible layer based on the currently selected radio button. */
	lViewshed->Active = !rbtnAGL->Checked;
	lAGL->Active = rbtnAGL->Checked;

	/* Add both output rasters to the viewer so they can be toggled on/off via radio buttons. */
	GIS->Add( lAGL );
	GIS->Add( lViewshed );
	/* Set 50% transparency for both rasters so the underlying terrain remains visible. */
	lAGL->Transparency = 50;
	lViewshed->Transparency = 50;
	/* Move the observers layer 2 positions down in the rendering order so it's visible on top. */
	lObservers->Move( -2 );

	/* Apply a color ramp to the viewshed layer (binary green or frequency red-to-green gradient). */
	makeViewshedRamp();

	/* Apply a color ramp to the AGL layer: green for zero height needed, red for 500+ m needed. */
	lAGL->Params->Pixel->GridShadow = false;
	lAGL->GenerateRamp(
	  TGIS_Color::FromARGB( 127, 0, 255, 0),   /* Start color: semi-transparent green */
	  TGIS_Color::None,                        /* No transparency ramp */
	  TGIS_Color::FromARGB( 127, 255, 0, 0),   /* End color: semi-transparent red */
	  0, 1,                                     /* Data range: 0 to max height */
	  lAGL->MaxHeight, false,
	  ( lAGL->MaxHeight - lAGL->MinHeight )/100,
	  ( lAGL->MaxHeight - lAGL->MinHeight )/10,
	  NULL, false
	);

	/* Repaint the map to display the computed viewshed visualization. */
	GIS->InvalidateWholeMap();

	/* Unlock the viewer so the user can interact with the map again. */
	GIS->Unlock();
  }
}
//---------------------------------------------------------------------------

/* Zooms the viewer to the full extent of all layers. */
void __fastcall TfrmMain::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

/* Removes the viewshed and AGL layers and reverts all observer points to reset
   the display. */
void __fastcall TfrmMain::btnResetClick(TObject *Sender)
{
  GIS->Lock();
  if( GIS->Get( SAMPLE_VIEWSHED_NAME ) != NULL )
  {
	GIS->Delete( SAMPLE_VIEWSHED_NAME );
	lViewshed = NULL;
	GIS->Delete( SAMPLE_AGL_NAME );
	lAGL = NULL;
  }
  lObservers->RevertAll();
  GIS->FullExtent();
  GIS->Unlock();
}
//---------------------------------------------------------------------------

/* Switches the viewer to Zoom mode. */
void __fastcall TfrmMain::rbtnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

/* Switches the viewer to UserDefined mode for adding observer points. */
void __fastcall TfrmMain::rbtnAddObserverClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::UserDefined ;
}
//---------------------------------------------------------------------------

/* Refreshes the visible layer when the binary viewshed radio button changes. */
void __fastcall TfrmMain::rbtnViewshedBinaryClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

/* Refreshes the visible layer when the frequency viewshed radio button changes. */
void __fastcall TfrmMain::rbtnViewshedFreqClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

/* Refreshes the visible layer when the AGL radio button changes. */
void __fastcall TfrmMain::rbtnAGLClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

/* Reads viewshed frequency and AGL values at the cursor position and displays
   them in the status bar. */
void __fastcall TfrmMain::GISMouseMove(TObject *Sender, TShiftState Shift,
  int X, int Y)
{
  TGIS_Point ptg;
  TGIS_Color cl;
  TGIS_DoubleArray vals;
  Boolean transp;
  String str="";

  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;

  if(( lViewshed != NULL ) && (lViewshed->Locate( ptg, cl, vals, transp )))
  {
	if ( vals[0] != lViewshed->NoDataValue )
	{
	  str = str + "Frequency: " + FloatToStr( vals[0] ) ;
	}
  }
  if(( lAGL != NULL ) && (lAGL->Locate( ptg, cl, vals, transp )))
  {
    if ( vals[0] != lAGL->NoDataValue )
    {
      str = str + "Above-Ground-Level: " + IntToStr( (Integer)vals[0] ) ;
    }
  }

  StatusBar1->SimpleText = str ;

}
//---------------------------------------------------------------------------

