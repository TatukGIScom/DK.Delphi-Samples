//---------------------------------------------------------------------------

#include <vcl.h>
#include "GisTypes.hpp"
#include "GisFunctions.hpp"
#include "GisLayerWebTiles.hpp"
#include "GisUtils.hpp"
#include "GisOSMServices.hpp"
#pragma hdrstop

#include "formMain.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlScale"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TfrmMain *frmMain;
const UnicodeString LOCAL_LAYER_TILES = "tiles";
//---------------------------------------------------------------------------

__fastcall TfrmMain::TfrmMain(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------

TGIS_Extent __fastcall growExtent(TGIS_Extent _ext, double _fac)
{
  TGIS_Point ctr = GisPoint(0.5*(_ext.XMin + _ext.XMax),
							0.5*(_ext.YMin + _ext.YMax));
  double xsiz = 0.5*_fac*(_ext.XMax - _ext.XMin);
  double ysiz = 0.5*_fac*(_ext.YMax - _ext.YMin);

  return GisExtent(ctr.X - xsiz, ctr.Y - ysiz,
				   ctr.X + xsiz, ctr.Y + ysiz);
}

//---------------------------------------------------------------------------

TGIS_Extent __fastcall resizeExtent(TGIS_Extent _ext, double _siz)
{
  double xsiz = _ext.XMax - _ext.XMin;
  double ysiz = _ext.YMax - _ext.YMin;

  if ((xsiz > _siz) || (ysiz > _siz))
	return _ext;

  TGIS_Point ctr = GisPoint(0.5*(_ext.XMin + _ext.XMax),
							0.5*(_ext.YMin + _ext.YMax));

  return GisExtent(ctr.X - 0.5*_siz, ctr.Y - 0.5*_siz,
				   ctr.X + 0.5*_siz, ctr.Y + 0.5*_siz);
}

//---------------------------------------------------------------------------

UnicodeString __fastcall sign2dir(int _sign)
{
  UnicodeString res = "";
  switch (_sign)
  {
	case -99 : res = "[unknown]"; break;
	case -98 : res = "Make a u-turn"; break;
	case -8  : res = "Make a left u-turn"; break;
	case -7  : res = "Keep left"; break;
	case -6  : res = "Exit roundabout"; break;
	case -3  : res = "Sharp turn left"; break;
	case -2  : res = "Turn left"; break;
	case -1  : res = "Slight turn left"; break;
	case 0   : res = "Continue"; break;
	case 1   : res = "Slight turn right"; break;
	case 2   : res = "Turn right"; break;
	case 3   : res = "Sharp turn right"; break;
	case 4   : res = "Finish"; break;
	case 5   : res = "Reach the intermediate destination"; break;
	case 6   : res = "Enter roundabout and take the "; break;
	case 7   : res = "Keep right"; break;
	case 8   : res = "Make a right u-turn"; break;
	case 101 : res = "Start trip"; break;
	case 102 : res = "Transfer"; break;
	case 103 : res = "End trip"; break;
	default  : res = "Ignore";
  }
  return res;
}

//---------------------------------------------------------------------------

UnicodeString __fastcall exitNumber(UnicodeString _str)
{
  UnicodeString res = "";
  switch (_str[StringLast(_str)])
  {
	case '1' : res = _str + "st";
	case '2' : res = _str + "nd";
	case '3' : res = _str + "rd";
	default  : res = _str + "th";
  }
  return res;
}

//---------------------------------------------------------------------------

void __fastcall TfrmMain::loadTiles(T_mapStyle _style)
{
  bool b = GIS->Get(LOCAL_LAYER_TILES) != NULL;

  if (b)
	GIS->Delete(LOCAL_LAYER_TILES);

  TGIS_LayerWebTiles *lwt = new TGIS_LayerWebTiles();
  UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
					   "\\Samples\\WebServices\\";
  switch (_style)
  {
	case T_mapStyle::International :
	  path += "TatukGIS OpenStreetMap Tiles.ttkwp";
	  break;
	case T_mapStyle::English :
	  path += "TatukGIS OpenStreetMap Tiles (English).ttkwp";
	  break;
	case T_mapStyle::InternationalHillshade :
	  path += "TatukGIS OpenStreetMap Hillshade Tiles.ttkwp";
	  break;
	case T_mapStyle::EnglishHillshade :
	  path += "TatukGIS OpenStreetMap Hillshade Tiles (English).ttkwp";
	  break;
  }
  lwt->Path = path;
  lwt->Open();
  lwt->Name = LOCAL_LAYER_TILES;

  GIS->Add(lwt);
  lwt->Move(999);
  if (b)
	GIS->InvalidateWholeMap();
  else
	GIS->VisibleExtent = lwt->Extent;
}

//---------------------------------------------------------------------------

void __fastcall TfrmMain::addDirection(UnicodeString _str, TGIS_Uid _uid)
{
  if (!IsStringEmpty(strgrdRoutingDir->Cells[0][0]))
	strgrdRoutingDir->RowCount = strgrdRoutingDir->RowCount+1;
  strgrdRoutingDir->Cells[0][strgrdRoutingDir->RowCount-1] = _str;
  shpList->push_back(_uid);
}

//---------------------------------------------------------------------------

void __fastcall TfrmMain::resetLayers()
{
  if (GIS->Get("fgeocoding") != NULL)
	GIS->Delete("fgeocoding");

  if (GIS->Get("route") != NULL)
	GIS->Delete("route");

  if (GIS->Get("isochrone") != NULL)
	GIS->Delete("isochrone");
}

//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  Application->Title = "Online Services";

  strgrdRouting->ColWidths[0] = 64;
  strgrdRouting->ColWidths[1] =
	strgrdRouting->Width - strgrdRouting->ColWidths[0] - 4;

  strgrdRouting->Cells[0][0] = "From";
  strgrdRouting->Cells[0][1] = "Through";
  strgrdRouting->Cells[0][2] = "To";

  strgrdRouting->Cells[1][0] = "Gdynia";
  strgrdRouting->Cells[1][1] = "Czestochowa";
  strgrdRouting->Cells[1][2] = "Wroclaw";

  loadTiles(T_mapStyle::English);

  shpList = new std::vector<TGIS_Uid>();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormDestroy(TObject *Sender)
{
  delete shpList;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::cmbbxMapChange(TObject *Sender)
{
  switch (cmbbxMap->ItemIndex)
  {
	case 0 : loadTiles(T_mapStyle::International); break;
	case 1 : loadTiles(T_mapStyle::English); break;
	case 2 : loadTiles(T_mapStyle::InternationalHillshade); break;
	case 3 : loadTiles(T_mapStyle::EnglishHillshade); break;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnGeocodingClick(TObject *Sender)
{
  resetLayers();

  if (IsStringEmpty(edtGeocodingAddress->Text))
  {
	ShowMessage("Address not specified.");
	return;
  }

  TGIS_OSMGeocoding *ogeo = new TGIS_OSMGeocoding();

  ogeo->Limit = StrToInt(cmbbxGeocodingLimit->Text);
  TGIS_LayerVector *lgeo = ogeo->Forward(edtGeocodingAddress->Text);
  if (lgeo->GetLastUid() > 0)
  {
	  lblRoutingDirDist->Caption = "Total distance: ?";
	  lblRoutingDirTime->Caption = "Total time: ?";
	  strgrdRoutingDir->RowCount = 1;
	  strgrdRoutingDir->Cells[0][0] = "";

	  GIS->Add(lgeo);

	  TGIS_Extent ext = resizeExtent(lgeo->ProjectedExtent, 500.0);
	  ext = growExtent(ext, 1.2);

	  GIS->VisibleExtent = ext;
  }
  else
	  ShowMessage("Address not found.");

  delete ogeo;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnRoutingAddClick(TObject *Sender)
{
  strgrdRouting->RowCount = strgrdRouting->RowCount+1;
  strgrdRouting->Cells[0][strgrdRouting->RowCount-2] = "Through";
  strgrdRouting->Cells[0][strgrdRouting->RowCount-1] = "To";
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnRoutingDeleteClick(TObject *Sender)
{
  if (strgrdRouting->RowCount == 2) return;

  strgrdRouting->RowCount = strgrdRouting->RowCount-1;
  strgrdRouting->Cells[0][strgrdRouting->RowCount-1] = "To";
}
//---------------------------------------------------------------------------


void __fastcall TfrmMain::btnRoutingClick(TObject *Sender)
{
  resetLayers();

  for(int i = 0; i < strgrdRouting->RowCount; i++)
  {
	if (IsStringEmpty(strgrdRouting->Cells[1][i]))
	{
	  ShowMessage("Address not specified.");
	  return;
	}
  }

  TGIS_StringList *names = new TGIS_StringList();
  TGIS_OSMRouting *ortg = new TGIS_OSMRouting();

  if (rbtnRoutingProfileCar->Checked)
	ortg->Profile = TGIS_OSMRoutingProfile::Car;
  else
  if (rbtnRoutingProfileBike->Checked)
	ortg->Profile = TGIS_OSMRoutingProfile::Bike;
  else
  if (rbtnRoutingProfileFoot->Checked)
	ortg->Profile = TGIS_OSMRoutingProfile::Foot;

  for (int i = 0; i < strgrdRouting->RowCount; i++)
	names->Add(strgrdRouting->Cells[1][i]);

  TGIS_LayerVector *lrtg = ortg->Route(names);

  if (lrtg != NULL)
  {
	bool b = false;
	int dist = 0;
	int time = 0;
	TGIS_Shape *shp;

	TGIS_LayerVectorEnumerator *lve = lrtg->Loop(
	  lrtg->Extent, "( type = 'route' )"
	)->GetEnumerator();
	while(lve->MoveNext())
	{
	  shp = lve->GetCurrent();
	  dist += VarToInt32(shp->GetField("distance"));
	  time += VarToInt32(shp->GetField("time"));
	  b = true;
	}
	delete lve;

	GIS->Add(lrtg);
	TGIS_Extent ext = resizeExtent(lrtg->ProjectedExtent, 500.0);
	GIS->VisibleExtent = growExtent(ext, 1.2);

	if (b)
	{
	  UnicodeString str = "";

	  if (dist < 1000)
		str = IntToStr(dist) + " m";
	  else
		str = DotFloatToStrPrec(dist/1000.0, 2) + " km";

	  lblRoutingDirDist->Caption = "Total distance: " + str;

	  int hrs = time/3600;
	  int mns = ( time/60 ) - hrs*60;
	  if (hrs == 0)
		str = IntToStr(mns) + " min";
	  else
		str = IntToStr(hrs) + " h " + IntToStr(mns) + " min";

	  lblRoutingDirTime->Caption = "Total time: " + str;

	  bool bfin = false;
	  strgrdRoutingDir->RowCount = 1;
	  strgrdRoutingDir->Cells[0][0] = "";
	  shpList->clear();

	  TGIS_Uid uid;
	  lve = lrtg->Loop( lrtg->Extent, "( type = 'route' )" )->GetEnumerator();
	  while (lve->MoveNext())
	  {
		shp = lve->GetCurrent();

		uid = shp->Uid;
		int i = VarToInt32(shp->GetField("sign"));
		str = VarToString(shp->GetField("name"));

        UnicodeString dir = "";
		switch (i)
		{
			case -98 :
			case  -8 :
			case   8 :
			case   5 :
			  dir = sign2dir(i); break;
			case   6 :
			  dir = sign2dir(i) +
					exitNumber(VarToString(shp->GetField("exit"))) +
					" exit";
			default  :
			  dir = sign2dir(i);
			  if (!IsStringEmpty(str))
			  {
				if (i == 0)
				  dir += " on " + str;
				else
				  dir += " onto " + str;
			  }
		}

		if (i == 5)
		{
		  addDirection(dir, uid);
		  bfin = true ;
		  continue ;
		}

		dist = VarToInt32(shp->GetField("distance"));
		if (dist < 1000)
		  dir += " (" + IntToStr(dist) + " m, ";
		else
		  dir += " (" + DotFloatToStrPrec(dist/1000.0, 2) + " km, ";

		time = VarToInt32(shp->GetField("time"));
		hrs = time/3600 ;
		mns = ( time/60 ) - hrs*60 ;
		if (hrs == 0)
		{
		  if (mns == 0)
			dir += "<1 min)";
		  else
			dir += IntToStr(mns) + " min)";
		}
		else
		  dir += IntToStr(hrs) + " h " + IntToStr(mns) + " min)";

		addDirection(dir, uid);
	  }
      delete lve;

	  if (bfin)
		addDirection("Reach the final destination", uid);
	  else
		addDirection("Reach the destination", uid);

	}
	else
	  ShowMessage("Route not found.");
  }

  delete ortg;
  delete names;
}

//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnIsochroneClick(TObject *Sender)
{
  resetLayers();

  if (IsStringEmpty(edtIsochroneAddress->Text))
  {
	ShowMessage("Address not specified.");
	return;
  }

  int time;
  if (!TryStrToInt(edtIsochroneTime->Text, time))
  {
	ShowMessage( "'" + edtIsochroneTime->Text +
				 "' is not a positive number." ) ;
	return;
  }

  TGIS_OSMIsochrone *oiso = new TGIS_OSMIsochrone();
  if (rbtnIsochroneProfileCar->Checked)
	oiso->Profile = TGIS_OSMRoutingProfile::Car;
  else
  if (rbtnIsochroneProfileBike->Checked)
	oiso->Profile = TGIS_OSMRoutingProfile::Bike;
  else
  if (rbtnIsochroneProfileFoot->Checked)
	oiso->Profile = TGIS_OSMRoutingProfile::Foot;

  oiso->Buckets = StrToInt(cmbbxIsochroneBuckets->Text);
  oiso->TimeLimit = time ;
  TGIS_LayerVector *liso = oiso->Isochrone(edtIsochroneAddress->Text);

  if (liso->GetLastUid() > 0)
  {
	lblRoutingDirDist->Caption = "Total distance: ?";
	lblRoutingDirTime->Caption = "Total time: ?";
	strgrdRoutingDir->RowCount = 1;
	strgrdRoutingDir->Cells[0][0] = "";

	GIS->Add(liso);

	TGIS_Extent ext = resizeExtent(liso->ProjectedExtent, 500.0);
	ext = growExtent(ext, 1.2);

	GIS->VisibleExtent = ext;
  }
  else
    ShowMessage("Address not found.");

  delete oiso ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::strgrdRoutingDirDblClick(TObject *Sender)
{
  TGIS_LayerVector *lrtg = (TGIS_LayerVector*)GIS->Get("route");

  if (lrtg == NULL) return;

  TGIS_Shape *shp = lrtg->GetShape(shpList->at(strgrdRoutingDir->Row));
  GIS->VisibleExtent = resizeExtent(shp->ProjectedExtent, 500.0);
}
//---------------------------------------------------------------------------

