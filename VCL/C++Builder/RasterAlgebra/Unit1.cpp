//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#include <cmath>
#include "GisUtils.hpp"
#include "GisRegistredLayers.hpp"
#include "GisLayerVector.hpp"
#include "GisRasterAlgebra.hpp"
#include "GisAllLayers.hpp"
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmMain *frmMain;

#define round(a) int((a)+0.5)
const UnicodeString SAMPLE_RESULT = "Result";
//---------------------------------------------------------------------------

/* Reports raster algebra execution progress on the progress bar.
   _pos = 0 initializes the bar; _pos = -1 resets it after completion. */
void __fastcall TfrmMain::doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
	switch (_pos)
	{
		// initialize progress bar
		case 0 :
			pbrProgress->Min = 0;
			pbrProgress->Max = 100;
			pbrProgress->Position = 0;
			break;
		// end of progress - reset progress bar
		case -1 :
			pbrProgress->Position = 0;
			break;
		default :
			pbrProgress->Position = _pos;
            break;
	}
}
//---------------------------------------------------------------------------

/* Applies a blue-lime-red colour ramp to grid layer _l, mapping its full
   value range to the ramp and disabling the default grid shadow. */
void __fastcall TfrmMain::applyRamp(TGIS_LayerPixel *_l)
{
	_l->GenerateRamp(
		TGIS_Color::Blue, TGIS_Color::Lime, TGIS_Color::Red,
		1.0*FloorS( _l->MinHeight ),
		( _l->MaxHeight + _l->MinHeight )/2.0,
		1.0*Ceil( _l->MaxHeight ), true,
		( _l->MaxHeight - _l->MinHeight )/100.0,
		( _l->MaxHeight - _l->MinHeight )/10.0,
		NULL, false
	) ;
	_l->Params->Pixel->GridShadow = false;
}
//---------------------------------------------------------------------------

__fastcall TfrmMain::TfrmMain(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
/* Closes the viewer, loads a JPEG aerial photo as a pixel layer, and sets a
   default colour-inversion formula for the raster algebra expression field. */
void __fastcall TfrmMain::btnOpenPixelClick(TObject *Sender)
{
	GIS->Close();

	UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"\\World\\Countries\\USA\\States\\California\\San Bernardino\\DOQ\\37134877.jpg";

	TGIS_LayerPixel *lp = (TGIS_LayerPixel*)GisCreateLayer("pixel", path);
	GIS->Add(lp);
	GIS->FullExtent();

	rbtnResultPixel->Checked = true;
	edtFormula->Text = "RGB(255 - pixel.R, 255 - pixel.G, 255 - pixel.B)";
}
//---------------------------------------------------------------------------

/* Closes the viewer, loads an ADF elevation grid, applies a colour ramp, and
   sets a default threshold formula that clamps values to MIN or MAX. */
void __fastcall TfrmMain::btnOpenGridClick(TObject *Sender)
{
	GIS->Close();

	UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf";

	TGIS_LayerPixel *lp = (TGIS_LayerPixel*)GisCreateLayer("grid", path);
	lp->UseConfig = false;
	GIS->Add(lp);
	applyRamp(lp);
	GIS->FullExtent();

	rbtnResultGrid->Checked = true;
    edtFormula->Text = "IF(grid < AVG(grid), MIN(grid), MAX(grid))";
}
//---------------------------------------------------------------------------

/* Closes the viewer, loads a TIGER shapefile as a vector layer, and sets a
   default formula that rasterizes features green where data exists and red
   where no data is present. */
void __fastcall TfrmMain::btnOpenVectorClick(TObject *Sender)
{
	GIS->Close();

	UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"\\World\\Countries\\USA\\States\\California\\San Bernardino\\TIGER\\tl_2008_06071_edges_trunc.shp";

	TGIS_LayerVector *lv = (TGIS_LayerVector*)GisCreateLayer("vector", path);
	lv->UseConfig = false;
	GIS->Add(lv);
	GIS->FullExtent();

	rbtnResultPixel->Checked = true;
    edtFormula->Text = "IF(NODATA(vector.GIS_UID), RGB(0,255,0), RGB(255,0,0))";
}
//---------------------------------------------------------------------------

/* Builds an output pixel or grid layer whose dimensions match the highest-
   resolution source layer, registers all viewer layers with a TGIS_RasterAlgebra
   engine, and evaluates the formula entered in edtFormula.  The result layer
   "Result" replaces any previous run.  A colour ramp is applied automatically
   when the output is a grid. */
void __fastcall TfrmMain::btnExecuteClick(TObject *Sender)
{
	if (GIS->IsEmpty)
	{
		ShowMessage("The viewer is empty!");
		return;
	}

	if (GIS->Get(SAMPLE_RESULT) != NULL)
	    GIS->Delete(SAMPLE_RESULT);

	double lew, gew = GIS->Extent.XMax - GIS->Extent.XMin;

	TGIS_LayerPixel *src = NULL;
	int w, siz = 0;
	for (int i = 0; i < GIS->Items->Count; i++)
	{
		
		if ( GIS->Items->Items[i]->InheritsFrom( __classid(TGIS_LayerPixel) ) )
		{
			src = (TGIS_LayerPixel*)GIS->Items->Items[i];
			lew = src->Extent.XMax - src->Extent.XMin;
			w = (int)round(1.0*gew*src->BitWidth/lew);
			siz = Max(w, siz);
		}
	}

	TGIS_LayerPixel *dst = new TGIS_LayerPixel();
	if (src != NULL)
		dst->Build(rbtnResultGrid->Checked, GIS->CS, GIS->Extent, siz, 0);
	else
		dst->Build(rbtnResultGrid->Checked, GIS->CS, GIS->Extent, GIS->Width, 0);
	dst->Name = SAMPLE_RESULT;

	GIS->Add(dst);

	TGIS_RasterAlgebra *ra = new TGIS_RasterAlgebra();
	ra->BusyEvent = doBusyEvent;

	for (int i = 0; i < GIS->Items->Count; i++)
		ra->AddLayer((TGIS_Layer*)GIS->Items->Items[i]);

	try
	{
		ra->Execute(SAMPLE_RESULT + " = " + edtFormula->Text);
	}
	catch(...)
	{
		GIS->Delete(dst->Name);
		ShowMessage("Incorrect formula!");
	}

	delete ra;

	if (dst->IsGrid())
	  applyRamp(dst);

    GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

