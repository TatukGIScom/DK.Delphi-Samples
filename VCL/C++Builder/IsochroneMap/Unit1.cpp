//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to add layer to the map.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "GisUtils.hpp"
#include "GisCsBase.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisControlScale"
#pragma resource "*.dfm"
TfrmMain *frmMain;

//---------------------------------------------------------------------------
void __fastcall TfrmMain::doLinkCostEvent(
  TObject *_sender,
  TGIS_ShapeArc *_shape,
  Double &_cost,
  Double &_revcost
)
{
  if (_shape->Layer->CS->EPSG == 0)
  {
	_cost = _shape->Length();
  }
  else
  {
	_cost = _shape->LengthCS();
  }
  _revcost = _cost ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::doLinkType(
  TObject *_sender,
  TGIS_ShapeArc *_shape,
  Integer &_type
)
{
  if (_shape->GetField( "MTFCC" ) >= "S1400")
  {
	// local roads
	_type = 1;
  }
  else
  {
	_type = 0;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::doLinkDynamic(
  TObject *_sender,
  Integer _uid,
  Double &_cost,
  Double &_revcost
)
{
  TGIS_Shape *shp;

  if (trkHighways->Position == 1)
  {
	// block all highways
	shp = layerSrc->GetShape( _uid ) ;
	if (shp->GetField( "MTFCC" ) < "S1400")
	{
	  _cost    = -1 ;
	  _revcost = -1 ;
	}
  }
}

//---------------------------------------------------------------------------

__fastcall TfrmMain::TfrmMain(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  GIS->Lock() ;

  GIS->Open(
	TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\USA\\States\\California\\San Bernardino\\TIGER\\tl_2008_06071_edges_trunc.SHP"
  ) ;
  layerSrc = (TGIS_LayerVector*)GIS->Get( "tl_2008_06071_edges_trunc" ) ;

  if (layerSrc == NULL)
	return ;

  // update the layer parameters to show roads types
  layerSrc->ParamsList->Add();
  layerSrc->Params->Line->Width = -2 ;
  layerSrc->Params->Query = "MTFCC<'S1400'" ;
  layerSrc->ParamsList->Add() ;
  layerSrc->Params->Line->Width = 1 ;
  layerSrc->Params->Line->Style = TGIS_PenStyle::Dash ;
  layerSrc->Params->Query = "MTFCC='S1400'" ;

  GIS->VisibleExtent = layerSrc->Extent ;
//  GIS_ControlScale1->Units = CSUnitsList->ByEPSG( 9035 ) ; // mile

  // initial traversing cost
  costFactor = 5000.0 ;
  numZones   = 5 ;

  // create route layer for result isochrone map
  layerRoute = new TGIS_LayerVector() ;
  layerRoute->UseConfig = false ;
  layerRoute->Name = "Isochrone map for route" ;
  layerRoute->CS = GIS->CS ;
  layerRoute->Params->Render->Expression = "GIS_COST" ;
  layerRoute->Params->Render->MinVal     = 0 ;
  layerRoute->Params->Render->MaxVal     = costFactor ;
  layerRoute->Params->Render->Zones      = numZones ;
  layerRoute->Params->Area->Color        = TGIS_Color::RenderColor ;
  layerRoute->Params->Area->ShowLegend   = true ;
  layerRoute->Transparency = 50 ;
  GIS->Add( layerRoute ) ;

  // create marker layer to show position
  layerMarker = new TGIS_LayerVector();
  layerMarker->UseConfig = false ;
  layerMarker->Name = "Current Position" ;
  layerMarker->CS = GIS->CS ;
  layerMarker->Params->Marker->Color = TGIS_Color::Red ;
  GIS->Add( layerMarker ) ;

  markerShp = NULL ;

  // initialize isochrone map generator
  rtrObj = new TGIS_IsochroneMap( *GIS ) ;

  // initialize shortest path and attach events
  srtpObj = new TGIS_ShortestPath( *GIS ) ;
  srtpObj->LinkCostEvent    = doLinkCostEvent ;
  srtpObj->LinkTypeEvent    = doLinkType ;
  srtpObj->LinkDynamicEvent = doLinkDynamic ;

  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormDestroy(TObject *Sender)
{
  delete srtpObj;
  delete rtrObj;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnZoomOutClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{

  TGIS_Point ptg;

  // if there is no layer or we are not in select mode, exit
  if (GIS->IsEmpty)
	return;
  if (GIS->Mode != TGIS_ViewerMode::Select)
	return;

  ptg = GIS->ScreenToMap( Point(X, Y) ) ;

  // recreate a marker shape indicating start position
  if (markerShp == NULL )
  {
	markerShp = layerMarker->CreateShape( TGIS_ShapeType::Point ) ;
	markerShp->Lock( TGIS_Lock::Extent );
	markerShp->AddPart() ;
	markerShp->AddPoint( ptg ) ;
	markerShp->Unlock() ;
	markerShp->Invalidate() ;
  }
  else
  {
	markerShp->SetPosition( ptg, NULL, 0 ) ;
  }

  generateIsochrone() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::generateIsochrone()
{
  Integer i;
  TGIS_Shape *shp;
  TGIS_LayerVectorEnumerator *en;

  if ( markerShp == NULL )
  {
	ShowMessage( "Please select a start point on the map" ) ;
	return ;
  }

  layerRoute->RevertShapes() ;

  // maximum traversing cost for the isochrone map
  numZones   = StrToInt( edtZones->Text ) ;
  costFactor = StrToInt( edtDistance->Text ) ;

  // update the renderer range
  layerRoute->Params->Render->MaxVal = costFactor ;
  layerRoute->Params->Render->Zones  = numZones ;

  // calculate wages
  srtpObj->CostModifiers[0] = 1 - 1/11 * trkHighways->Position ;
  srtpObj->CostModifiers[1] = 1 - 1/11 * trkSmallRoads->Position ;

  // generate the isochrone maps
  for (i = 1;i<=numZones;i++)
  {
	rtrObj->Generate( layerSrc, srtpObj, layerRoute, TGIS_ShapeType::Polygon,
					  markerShp->Centroid(), costFactor/i, 0
					) ;
  }

  // smooth the result polygons shapes
  en = layerRoute->Loop()->GetEnumerator() ;
  while(en->MoveNext())
  {
	shp = en->GetCurrent() ;
	shp->Smooth( 10, False ) ;
  }
  delete en;

  layerRoute->RecalcExtent() ;
  GIS->Lock() ;
  GIS->VisibleExtent = layerRoute->ProjectedExtent ;
  GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

