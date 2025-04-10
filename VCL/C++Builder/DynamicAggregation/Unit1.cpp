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
void __fastcall TForm10::FormCreate(TObject *Sender)
{
  GIS->Open(GisSamplesDataDirDownload() + "\\Samples\\Aggregation\\Aggregation.ttkproject");
  cbxMethod->Items->Add("Off");
  names = TGIS_DynamicAggregatorFactory::Names ;
  cbxMethod->Items->AddStrings(TGIS_DynamicAggregatorFactory::Names);
  cbxMethod->ItemIndex = 0 ;
  cbxRadius->ItemIndex = 3 ;
  cbxThreshhold->ItemIndex = 1;
  cbxRadius->Enabled = false ;
  cbxThreshhold->Enabled = false ;
}
//---------------------------------------------------------------------------
void __fastcall TForm10::cbxMethodChange(TObject *Sender)
{
  readDefaultValues();
  changeAggregation();
}
//---------------------------------------------------------------------------

void __fastcall TForm10::cbxRadiusChange(TObject *Sender)
{
  changeAggregation();
}
//---------------------------------------------------------------------------

void __fastcall TForm10::cbxThreshholdChange(TObject *Sender)
{
  changeAggregation();
}

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

void __fastcall TForm10::changeAggregation()
{
  UnicodeString dyn_agg_name ;
  TGIS_LayerVector *lv;

  dyn_agg_name = cbxMethod->Items->Strings[cbxMethod->ItemIndex];
  lv = (TGIS_LayerVector *)(GIS->Get("cities")) ;
  lv->Transparency = 70;

  if ( dyn_agg_name == "Off" )
  {
	cbxThreshhold->Enabled = false ;
	cbxRadius->Enabled = false ;
	lv->DynamicAggregator = NULL ;
  }
  else
  {
	cbxThreshhold->Enabled = true ;
	cbxRadius->Enabled = true ;
	lv->DynamicAggregator = TGIS_DynamicAggregatorFactory::CreateInstance( dyn_agg_name, lv ) ;
	lv->DynamicAggregator->Threshold = StrToInt( cbxThreshhold->Items->Strings[cbxThreshhold->ItemIndex] ) ;
	lv->DynamicAggregator->RadiusAsText = "SIZE: " + cbxRadius->Items->Strings[cbxRadius->ItemIndex];
  }

  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

