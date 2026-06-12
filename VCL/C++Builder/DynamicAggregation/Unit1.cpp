/*
 * DynamicAggregation sample — demonstrates TGIS_DynamicAggregatorFactory for real-time point
 * clustering on a GIS layer.
 *
 * Loads a TatukGIS project (Aggregation.ttkproject) containing a "cities" point layer.  A left
 * panel offers three controls: Aggregation method (Off or a factory-registered name), Radius,
 * and Threshold.  Changing any control calls changeAggregation which installs or removes the
 * selected TGIS_DynamicAggregator on the layer via TGIS_DynamicAggregatorFactory::CreateInstance.
 */
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm10 *Form10;
//---------------------------------------------------------------------------
__fastcall TForm10::TForm10(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
/* Opens the project, populates the method combo with all registered aggregator names, and
   sets initial selections with Radius and Threshold disabled. */
void __fastcall TForm10::FormCreate(TObject *Sender)
{
  /* Load the GIS project file containing the cities point layer. */
  GIS->Open(GisSamplesDataDirDownload() + "\\Samples\\Aggregation\\Aggregation.ttkproject");
  /* Populate the aggregation method combo box.
     Start with "Off" to disable aggregation as the first option. */
  cbxMethod->Items->Add("Off");
  /* Enumerate all registered aggregator types from the factory.
     The factory maintains a list of available aggregation algorithms. */
  names = TGIS_DynamicAggregatorFactory::Names ;
  cbxMethod->Items->AddStrings(TGIS_DynamicAggregatorFactory::Names);
  /* Set initial selections.
     Aggregation is off by default. */
  cbxMethod->ItemIndex = 0 ;
  /* Set default radius index (40 pt). */
  cbxRadius->ItemIndex = 3 ;
  /* Set default threshold index. */
  cbxThreshhold->ItemIndex = 1;
  /* Disable radius and threshold controls when aggregation is off. */
  cbxRadius->Enabled = false ;
  cbxThreshhold->Enabled = false ;
}
//---------------------------------------------------------------------------
/* Resets the default radius for the chosen method, then applies the new aggregator. */
void __fastcall TForm10::cbxMethodChange(TObject *Sender)
{
  readDefaultValues();
  changeAggregation();
}
//---------------------------------------------------------------------------

/* Re-applies the aggregator with the newly selected radius. */
void __fastcall TForm10::cbxRadiusChange(TObject *Sender)
{
  changeAggregation();
}
//---------------------------------------------------------------------------

/* Re-applies the aggregator with the newly selected threshold. */
void __fastcall TForm10::cbxThreshholdChange(TObject *Sender)
{
  changeAggregation();
}

/* Sets a sensible default radius index when the method changes: index 0 (5 pt) for
   ShapeReduction, index 3 (40 pt) for all other methods. */
void __fastcall TForm10::readDefaultValues()
{
  if ( cbxMethod->Items->Strings[cbxMethod->ItemIndex] == "ShapeReduction" )
  {
	cbxRadius->ItemIndex = 0 ;
  }
  else
  {
	cbxRadius->ItemIndex = 3 ;
  }
}

/* Installs or removes the selected TGIS_DynamicAggregator on the "cities" layer,
   applies the current Radius and Threshold, and redraws the map. */
void __fastcall TForm10::changeAggregation()
{
  UnicodeString dyn_agg_name ;
  TGIS_LayerVector *lv;

  /* Get the aggregation method name from the combo box. */
  dyn_agg_name = cbxMethod->Items->Strings[cbxMethod->ItemIndex];
  /* Fetch the cities layer from the GIS viewer. */
  lv = (TGIS_LayerVector *)(GIS->Get("cities")) ;
  /* Set transparency so clustered points are semi-transparent (visible when stacked). */
  lv->Transparency = 70;

  if ( dyn_agg_name == "Off" )
  {
	/* Disable aggregation: turn off radius and threshold controls. */
	cbxThreshhold->Enabled = false ;
	cbxRadius->Enabled = false ;
	/* Remove any existing aggregator from the layer. */
	lv->DynamicAggregator = NULL ;
  }
  else
  {
	/* Enable aggregation: activate radius and threshold controls. */
	cbxThreshhold->Enabled = true ;
	cbxRadius->Enabled = true ;
	/* Create an aggregator instance using the factory pattern.
	   The factory creates the appropriate aggregator type based on the name
	   (e.g., "ShapeReduction", "QuadTree", etc.). */
	lv->DynamicAggregator = TGIS_DynamicAggregatorFactory::CreateInstance( dyn_agg_name, lv ) ;
	/* Set the aggregation threshold: minimum cluster size to trigger aggregation
	   (0 = always aggregate, higher values = fewer clusters). */
	lv->DynamicAggregator->Threshold = StrToInt( cbxThreshhold->Items->Strings[cbxThreshhold->ItemIndex] ) ;
	/* Set the radius in screen pixels (e.g., "SIZE: 5 pt", "SIZE: 40 pt").
	   Radius determines the cluster distance threshold in the viewer. */
	lv->DynamicAggregator->RadiusAsText = "SIZE: " + cbxRadius->Items->Strings[cbxRadius->ItemIndex];
  }

  /* Repaint the map to apply the new aggregation settings. */
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

