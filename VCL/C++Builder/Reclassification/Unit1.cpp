//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Reclassification.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma resource "*.dfm"
TfrmReclassification *frmReclassification;
//---------------------------------------------------------------------------
__fastcall TfrmReclassification::TfrmReclassification(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TfrmReclassification::FormShow(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;

  // Set header
  sgrdReclassTable->Cells[0][0] = "Start";
  sgrdReclassTable->Cells[1][0] = "End";
  sgrdReclassTable->Cells[2][0] = " New";

  // Set reclass table
  for (int i = 1; i<= 4; i++) {
	sgrdReclassTable->Cells[0][i] = IntToStr(100*i);
	sgrdReclassTable->Cells[1][i] = IntToStr(100*(i+1));
	sgrdReclassTable->Cells[2][i] = IntToStr(i);
  };

  sgrdReclassTable->Cells[0][5] = "311";
  sgrdReclassTable->Cells[1][5] = "";
  sgrdReclassTable->Cells[2][5] = "6";

  sgrdReclassTable->Cells[0][6] = "nodata";
  sgrdReclassTable->Cells[1][6] = "";
  sgrdReclassTable->Cells[2][6] = "999";

  // open image to reclassify
  OpenSampleForReclassTable();
}

void __fastcall TfrmReclassification::OpenSampleForReclassTable()
{
  useAltitudeMapZones = False;

  GIS->Lock();
  try {
	GIS->Open(TPath::Combine(
	  TGIS_Utils::GisSamplesDataDirDownload(),
	  "World\\Countries\\Luxembourg\\CLC2018_CLC2018_V2018_20_Luxembourg.tif"
	));

    // apply Unique style classification
	TGIS_LayerPixel *lp = (TGIS_LayerPixel *)(GIS->Items->Items[0]);
	ApplyUniqueStyle(lp, "UniquePastel");
  }
  __finally {
	GIS->Unlock();
  };
}

void __fastcall TfrmReclassification::OpenSampleForUseAltitudeZones()
{
  useAltitudeMapZones = True;

  GIS->Lock();
  try {
	GIS->Open(TPath::Combine(
	  TGIS_Utils::GisSamplesDataDirDownload(),
	  "Samples\\3D\\elevation.grd"
	));

    // apply Unique style classification
	TGIS_LayerPixel *lp = (TGIS_LayerPixel *)(GIS->Items->Items[0]);
	ApplyNaturalBreaksStyle(lp, "Geology");
  }
  __finally {
	GIS->Unlock();
  };
}

void __fastcall TfrmReclassification::ApplyUniqueStyle(TGIS_LayerPixel* _lp, AnsiString _colorRampName )
{
  TGIS_ClassificationPixel *classifier = new TGIS_ClassificationPixel(_lp);
  try {
	classifier->Method = TGIS_ClassificationMethod::Unique;
	classifier->EstimateNumClasses();
	classifier->ColorRamp = GisColorRampList()->ByName(_colorRampName)->RealizeColorMap(TGIS_ColorMapMode::Discrete, classifier->NumClasses);

	if (classifier->MustCalculateStatistics()) {
	  _lp->Statistics->Calculate();
	}
	classifier->Classify();
  }
  __finally  {
    delete classifier;
  };
}

void __fastcall TfrmReclassification::ApplyNaturalBreaksStyle(TGIS_LayerPixel* _lp, AnsiString _colorRampName )
{
  TGIS_ClassificationPixel *classifier = new TGIS_ClassificationPixel(_lp);
  try {
	classifier->Method = TGIS_ClassificationMethod::NaturalBreaks;
	classifier->ColorRamp = GisColorRampList()->ByName(_colorRampName)->RealizeColorMap(TGIS_ColorMapMode::Discrete);

	if (classifier->MustCalculateStatistics()) {
	  _lp->Statistics->Calculate();
	}
	classifier->Classify();
  }
  __finally  {
    delete classifier;
  };
}

//---------------------------------------------------------------------------

void __fastcall TfrmReclassification::btnUseTableClick(TObject *Sender)
{
  #if CompilerVersion >= 35
  grpbReclassification->LockDrawing();
  try {
  #endif
	lblAltitudeZones->Visible = False;
	sgrdReclassTable->Visible = True;
	lblReclassTable->Visible = True;
  #if CompilerVersion  >= 35
  }
  __finally {
	grpbReclassification->UnlockDrawing();
  };
  #endif

  OpenSampleForReclassTable();
}
//---------------------------------------------------------------------------

void __fastcall TfrmReclassification::btnUseAltitudeZonesClick(TObject *Sender)
{
  #if CompilerVersion  >= 35
  grpbReclassification->LockDrawing();
  try {
  #endif
	lblAltitudeZones->Visible = False;
	sgrdReclassTable->Visible = False;
	lblReclassTable->Visible = True;
  #if CompilerVersion  >= 35
  }
  __finally {
	grpbReclassification->UnlockDrawing();
  };
  #endif

  OpenSampleForUseAltitudeZones();
}
//---------------------------------------------------------------------------

void __fastcall TfrmReclassification::btnReclassifyClick(TObject *Sender)
{
  TGIS_LayerPixel *lp = (TGIS_LayerPixel *)(GIS->Items->Items[0]);

  // Remove a layer from GIS if exist
  UnicodeString name = lp->Name + " (reclass)";
  if (GIS->Get(name) != NULL)
	GIS->Delete(name) ;

  // Prepare the destination layer
  TGIS_LayerPixel* lp_reclass = new TGIS_LayerPixel();
  lp_reclass->Name = name;
  lp_reclass->Build(True, lp->CS, lp->Extent, lp->BitWidth, lp->BitHeight);

  TGIS_Reclassification* reclassifier = new TGIS_Reclassification();
  try {
	reclassifier->BusyEvent = doBusyEvent;

    // Collect reclass definitions
	for (int row = 1 ; row <= sgrdReclassTable->RowCount-1; row++) {
	  AnsiString startValStr = sgrdReclassTable->Cells[0][row];
	  AnsiString endValStr = sgrdReclassTable->Cells[1][row];
	  AnsiString newValStr = sgrdReclassTable->Cells[2][row];

	  if (startValStr.IsEmpty()) continue;

	  float startVal  ;
	  float startExist = TryStrToFloat(startValStr, startVal);

	  float endVal  ;
	  float endExist = TryStrToFloat(endValStr, endVal);

	  float newVal  ;
	  float newExist = TryStrToFloat(newValStr, newVal);

	  // Assign a new value for the existing nodata
	  if (((startValStr == "nd") || (startValStr == "nodata" ) || (startValStr == "no-data" )) && newExist)
		reclassifier->ReclassNoDataValue = newVal ;
	  // Simple value-to-value reclassification
	  else if ((endValStr.IsEmpty() || SameValue(startVal, endVal)) && startExist && newExist )
		reclassifier->AddReclassValue(startVal, newVal) ;
	  // Assgin a new value for a value within the range
	  else if (startExist && endExist && newExist )
        reclassifier->AddReclassRange(startVal, endVal, newVal);
    };

    // Assign NoData for unclassified cells if True, or leave existing values if False
    reclassifier->UseNoDataForMissingValues = chkNodata->Checked;

    // Run the reclassification tool
	reclassifier->Generate(lp, lp->Extent, lp_reclass, useAltitudeMapZones);
  }
  __finally {
    delete reclassifier;
  };

  if (!useAltitudeMapZones)
	ApplyUniqueStyle(lp_reclass, "UniqueDeep");

  lp_reclass->Params->Pixel->GridShadow = False ;
  lp_reclass->Params->Pixel->Antialias = False ;

  GIS->Add(lp_reclass);
  GIS->InvalidateWholeMap();
}

void __fastcall TfrmReclassification::doBusyEvent(TObject *_sender, int _pos,  int _end, bool &_abort)
{
  switch (_pos) {
   case	0: {
	  progress->Min = 0;
	  progress->Max = 100;
	  progress->Position = 0;
	}; break;
   case	-1: progress->Position = 0; break;
   default : progress->Position = _pos;
  };

  Application->ProcessMessages();
}
//---------------------------------------------------------------------------

void __fastcall TfrmReclassification::chkNodataClick(TObject *Sender)
{
  if (chkNodata->Checked)
	lblNoData->Caption = "Cell values outside the defined ranges will be filled with NODATA value." ;
  else
    lblNoData->Caption = "Cell values outside the defined ranges will be filled with original value." ;
}
//---------------------------------------------------------------------------

