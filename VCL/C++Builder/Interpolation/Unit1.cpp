//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include <GisUtils.hpp>
#include <GisCsFactory.hpp>
#include <GisLayerVector.hpp>
#include <GisLayerPixel.hpp>
#include <GisInterpolation.hpp>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
  if (_pos < 0)
  {
	pbProgress->Position = pbProgress->Max ;
  }
  else
  if (_pos == 0)
  {
	pbProgress->Min = 0 ;
	pbProgress->Max = _end ;
	pbProgress->Position = 0 ;
  }
  else
  {
	if (_pos % 1000 == 0)
	  pbProgress->Position = _pos ;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::doRbtnAnyClick(TObject *Sender)
{
  if (rbtnKriging->Checked)
  {
	lblSemivariance->Visible = True ;
	cmbSemivariance->Visible = True ;
  }
  else
  {
	lblSemivariance->Visible = False ;
	cmbSemivariance->Visible = False ;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "Samples\\Interpolation\\Interpolation.ttkproject" ) ;
  GIS->CS = TGIS_CSFactory::ByEPSG( 3395 ) ;
  GIS->FullExtent() ;

  rbtnIDW->OnClick = doRbtnAnyClick;
  rbtnKriging->OnClick = doRbtnAnyClick;
  rbtnSplines->OnClick = doRbtnAnyClick;
  rbtnHeatMap->OnClick = doRbtnAnyClick;
  rbtnConcentrationMap->OnClick = doRbtnAnyClick;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnGenerateGridClick(TObject *Sender)
{
  btnGenerateGrid->Enabled = False ;

  // obtain a handle to the source layer
  TGIS_LayerVector *src = (TGIS_LayerVector *)GIS->Get("temperatures");
  // obtain a handle to the polygonal layer (largest extent)
  TGIS_LayerVector *plg = (TGIS_LayerVector *)GIS->Get("country");

  // remove any previously created grid layer
  if (GIS->Get("grid"))
	GIS->Delete("grid");

  // get the source layer extent
  TGIS_Extent ext = plg->Extent;

  // calculate the height/width ratio of the extent to properly set the grid
  // resolution
  double rat = (ext.YMax - ext.YMin)/(ext.XMax - ext.XMin);

  // create and initialize the destination layer
  TGIS_LayerPixel *dst = new TGIS_LayerPixel();
  dst->Name = "grid";
  dst->Build(true, src->CS, ext, GRID_RESOLUTION, RoundS(rat * GRID_RESOLUTION));
  dst->Params->Pixel->GridShadow = false;

  // choose the start color of the grid ramp
  TGIS_Color clr = TGIS_Color::Blue;

  // find out which vector-to-grid has beeno chosen
  if (rbtnIDW->Checked)
  {
	TGIS_InterpolationIDW *vtg = new TGIS_InterpolationIDW();

	// for windowed version of this method you need to set Windowed=True
	// and at least the Radius, e.g.
	// vtg->Windowed = true ;
	// vtg->Radius = ( ext.XMax - ext.XMin )/5.0;

	// attach the event to automatically update the progress bar
	vtg->BusyEvent = doBusyEvent;
	// set the exponent parameter of the IDW formula (default is 2.0,
	// 3.0 gives nice results in most cases)
	vtg->Exponent = 3.0;
	// generate the Inverse Distance Squared (IDW) interpolation grid
	vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

	vtg->Free();
  }
  else
  if (rbtnKriging->Checked)
  {
	TGIS_InterpolationKriging *vtg = new TGIS_InterpolationKriging();

	// for windowed version of this method you need to set Windowed=True
	// and at least the Radius, e.g.
	// vtg->Windowed = true ;
	// vtg->Radius = ( ext.XMax - ext.XMin )/5.0;

	// attach the event to automatically update the progress bar
	vtg->BusyEvent = doBusyEvent;
	// set Semivarinace; default is Power Law (code for case 0 is not needed)
	switch (cmbSemivariance->ItemIndex)
	{
	  case 0: vtg->Semivariance = new TGIS_SemivariancePowerLaw(); break;
	  case 1: vtg->Semivariance = new TGIS_SemivarianceExponential(); break;
	  case 2: vtg->Semivariance = new TGIS_SemivarianceGaussian(); break;
	  case 3: vtg->Semivariance = new TGIS_SemivarianceSpherical(); break;
	  case 4: vtg->Semivariance = new TGIS_SemivarianceCircular(); break;
	  case 5: vtg->Semivariance = new TGIS_SemivarianceLinear(); break;
	}
	// generate the Kriging interpolation grid
	vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

	vtg->Free();
  }
  else
  if (rbtnSplines->Checked)
  {
	TGIS_InterpolationSplines *vtg = new TGIS_InterpolationSplines();

	// for windowed version of this method you need to set Windowed=True
	// and at least the Radius, e.g.
	// vtg->Windowed = true ;
	// vtg->Radius = ( ext.XMax - ext.XMin )/5.0;

	// attach the event to automatically update the progress bar
	vtg->BusyEvent = doBusyEvent ;
	// set the tension parameter of Splines (value need to be adjusted for
	// the data)
	vtg->Tension = 1e-9 ;
	// generate the Completely Regularized Splines interpolation grid
	vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

	vtg->Free();
  }
  else
  if (rbtnHeatMap->Checked)
  {
	TGIS_GaussianHeatmap *vtg = new TGIS_GaussianHeatmap() ;

	// attach the event to automatically update the progress bar
	vtg->BusyEvent = doBusyEvent ;
	// estimate the 3-sigma for Gaussian (can be set manually with Radius)
	vtg->EstimateRadius(src, src->Extent, dst);
	// correct the Radius after estimation (if needed)
	vtg->Radius = vtg->Radius/2.0 ;
	// generate the Heat/Concentaration Map grid
	vtg->Generate(src, src->Extent, FIELD_VALUE, dst, dst->Extent);

	vtg->Free();

	clr = TGIS_Color::FromARGB(0, 0, 0, 255);
  }
  else
  if (rbtnConcentrationMap->Checked)
  {
	TGIS_GaussianHeatmap *vtg = new TGIS_GaussianHeatmap() ;

	// for Concentration Map the coordinate must be None and source field
	// must be empty
	vtg->Coordinate = TGIS_VectorToGridCoordinate::None ;

	// attach the event to automatically update the progress bar
	vtg->BusyEvent = doBusyEvent ;
	// estimate the 3-sigma for Gaussian (can be set manually with Radius)
	vtg->EstimateRadius(src, src->Extent, dst);
	// correct the Radius after estimation (if needed)
	vtg->Radius = vtg->Radius/2.0 ;
	// generate the Heat/Concentaration Map grid
	vtg->Generate(src, src->Extent, "", dst, dst->Extent);

	vtg->Free();

	clr = TGIS_Color::FromARGB(0, 0, 0, 255);
  }

  // apply color ramp to the grid layer
  dst->GenerateRamp(
	clr, TGIS_Color::Lime, TGIS_Color::Red,
	dst->MinHeight,
	(dst->MaxHeight - dst->MinHeight)/2.0,
	dst->MaxHeight, False,
	(dst->MaxHeight - dst->MinHeight)/100.0,
	(dst->MaxHeight - dst->MinHeight)/10.0,
	NULL, False
  );

  // limit the grid visibility only to the pixels contained within a polygon
  dst->CuttingPolygon = (TGIS_ShapePolygon *)plg->GetShape(6)->CreateCopy();

  // add the grid layer to the viewer
  GIS->Add(dst);
  // update the viewer to show the grid layer
  GIS->FullExtent();

  // reset the progress bar
  pbProgress->Position = 0;

  btnGenerateGrid->Enabled = true;
}
//---------------------------------------------------------------------------

