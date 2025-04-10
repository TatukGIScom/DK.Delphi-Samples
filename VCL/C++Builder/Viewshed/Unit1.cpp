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
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  GIS->Lock();
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf"
  );
//  UnicodeString str = TGIS_Utils::GisSamplesDataDirDownload() +
//	"World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf" ;
//return;
  lTerrain = (TGIS_LayerPixel *)GIS->Get( "w001001" );

  lObservers = new TGIS_LayerVector();
  lObservers->Name = "Observers";
  lObservers->CS = lTerrain->CS;
  lObservers->Open();
  
  lObservers->Params->Marker->Symbol =
    SymbolList()->Prepare("LIBSVG:std:TowerCommunication01");
  lObservers->Params->Marker->Color = TGIS_Color::White;
  lObservers->Params->Marker->OutlineColor = TGIS_Color::White;
  lObservers->Params->Marker->Size = -32;
  GIS->Unlock();

  GIS->Add( lObservers );
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISMouseDown(TObject *Sender, TMouseButton Button,
  TShiftState Shift, int X, int Y)
{
  TGIS_Point pt;
  TGIS_Shape *shp;
  TGIS_Viewshed *vs;
  Single elev;

  if( GIS->Mode == TGIS_ViewerMode::UserDefined )
  {
	// read observer elevation offset
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

	// check if the point lays within the DEM area
	pt = GIS->ScreenToMap( Point( X, Y ) );
	if( !GisIsPointInsideExtent( pt, lTerrain->Extent ) )
	   return;

	GIS->Lock();

	// add observer to the observer layer
	shp = lObservers->CreateShape(
	  TGIS_ShapeType::Point, TGIS_DimensionType::XY
	);
	shp->AddPart();
	shp->AddPoint( pt );

	// remove previous viewshed/AGL layers
	if( GIS->Get( SAMPLE_VIEWSHED_NAME ) != NULL )
	{
	  GIS->Delete( SAMPLE_VIEWSHED_NAME );
	  lViewshed = NULL;
	  GIS->Delete( SAMPLE_AGL_NAME );
	  lAGL = NULL;
	}

	// create and set up the layer to host viewshed
	lViewshed = new TGIS_LayerPixel();
	lViewshed->Build( true, lTerrain->CS, lTerrain->Extent,
					  lTerrain->BitWidth, lTerrain->BitHeight );
	lViewshed->Name = SAMPLE_VIEWSHED_NAME;
	lViewshed->Open();

	// create and set up the layer to host above-ground-level
	lAGL = new TGIS_LayerPixel();
	lAGL->Build( true, lTerrain->CS, lTerrain->Extent,
				 lTerrain->BitWidth, lTerrain->BitHeight );
	lAGL->Name = SAMPLE_AGL_NAME;
	lAGL->Open();

	// create viewshed tool
	vs = new TGIS_Viewshed();
	// set the base observer elevation to be read from the DEM layer
	vs->ObserverElevation = TGIS_ViewshedObserverElevation::OnDem;
	// turn on the correction for earth curvature and refractivity
	vs->CurvedEarth = true;

	// initiate the viewshed/AGL generation process
	vs->Generate(lTerrain, lObservers, lViewshed, lAGL, 0.0, "", elev);
	delete vs;

	lViewshed->Active = !rbtnAGL->Checked;
	lAGL->Active = rbtnAGL->Checked;

	GIS->Add( lAGL );
	GIS->Add( lViewshed );
	lAGL->Transparency = 50;
	lViewshed ->Transparency = 50;
	lObservers->Move( -2 );

	// apply (binary or frequency) color ramp to the viewshed layer
	makeViewshedRamp();

	// apply color ramp to the AGL layer
	lAGL->Params->Pixel->GridShadow = false ;
	lAGL->GenerateRamp(
	  TGIS_Color::FromARGB( 127, 0, 255, 0),
	  TGIS_Color::None,
	  TGIS_Color::FromARGB( 127, 255, 0, 0),
	  0, 1,
	  lAGL->MaxHeight, false,
	  ( lAGL->MaxHeight - lAGL->MinHeight )/100,
	  ( lAGL->MaxHeight - lAGL->MinHeight )/10,
	  NULL, false
	) ;

	GIS->InvalidateWholeMap();

	GIS->Unlock();
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

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

void __fastcall TfrmMain::rbtnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::rbtnAddObserverClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::UserDefined ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::rbtnViewshedBinaryClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::rbtnViewshedFreqClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::rbtnAGLClick(TObject *Sender)
{
  setLayerActive();
}
//---------------------------------------------------------------------------

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

