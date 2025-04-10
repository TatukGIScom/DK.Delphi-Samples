//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to perform Geocoding & Routing.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "MainForm.h"
#include <typeinfo>
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

void __fastcall TForm1::doLinkType( TObject * _sender, TGIS_ShapeArc * _shape,
                         int &_type )
{
  if ( _shape->GetField( "MTFCC" ) >= "S1400" ){
    // local roads
    _type = 1 ;
  }
  else
    _type = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\California.ttkproject" ) ;
  layerSrc = (TGIS_LayerVector *)( GIS->Get( "streets" ) ) ;

  if (layerSrc==NULL) return ;
  if ( !layerSrc->InheritsFrom( __classid(TGIS_LayerVector) ) ) return ;

  GIS->VisibleExtent = layerSrc->ProjectedExtent ;

  layerRoute = new TGIS_LayerVector ;
  layerRoute->UseConfig = False ;
  layerRoute->Params->Line->Color = TGIS_Color::Red ;
  layerRoute->Params->Line->Width = -2 ;
  layerRoute->Params->Marker->OutlineWidth = 1 ;
  layerRoute->Name = "RouteDisplay" ;
  layerRoute->CS = GIS->CS ;
  GIS->Add( layerRoute ) ;

  geoObj = new TGIS_Geocoding( layerSrc ) ;
  geoObj->Offset   = 0.0001  ;
  geoObj->RoadName = "FULLNAME" ;
  geoObj->LFrom    = "LFROMADD" ;
  geoObj->LTo      = "LTOADD"   ;
  geoObj->RFrom    = "RFROMADD" ;
  geoObj->RTo      = "RTOADD"   ;

  costFactor = 1 ;
  rtrObj = new TGIS_ShortestPath( *GIS ) ;
  rtrObj->LinkTypeEvent = doLinkType ;
  rtrObj->LoadTheData( layerSrc ) ;
  rtrObj->RoadName = "FULLNAME" ;
  GIS->Unlock() ;
  GIS_ControlScale1->Units = CSUnitsList()->ByEPSG( 9035 ) ; // mile
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnResolveClick(TObject *Sender)
{
  int i ;
  int r ;
  TGIS_Shape *shp ;

  if ( geoObj == NULL ) return ;

  layerRoute->RevertShapes() ;

  r = geoObj->Parse( edtAddrFrom->Text, true, true ) -1 ;
  if ( r <= 0 ) edtAddrFrom->Text = edtAddrFrom->Text + " ???" ;

  for (i=0; i<=r; i++) {
    edtAddrFrom->Text = geoObj->Query[i] ;
    Application->ProcessMessages() ;

    shp = layerSrc->GetShape( geoObj->Uid[i] ) ;
    layerRoute->AddShape( shp, False ) ;
    if (i == 0)
      layerRoute->Extent = shp->ProjectedExtent ;
    shp = layerSrc->GetShape( geoObj->UidEx[i] ) ;
    if ( shp )
      layerRoute->AddShape( shp ) ;

    shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Extent );
      shp->AddPart() ;
      shp->AddPoint( geoObj->Point[i] ) ;
      shp->Params->Marker->Color = TGIS_Color::Green ;
    shp->Unlock() ;
  }

  GIS->Lock() ;
    GIS->VisibleExtent = layerRoute->ProjectedExtent ;
    GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnRouteClick(TObject *Sender)
{
  int         i      ;
  TGIS_Shape *shp    ;
  int         res    ;
  TGIS_Point  pt_a   ;
  TGIS_Point  pt_b   ;
  String      ang    ;
  String      oldnam ;

  rtrObj->CostModifiers[0] = 1.0 - 1.0/11 * trkHighways->Position ;
  rtrObj->CostModifiers[1] = 1.0 - 1.0/11 * trkSmallRoads->Position ;

  res = geoObj->Parse( edtAddrFrom->Text ) ;
  if ( res > 0 ) edtAddrFrom->Text = geoObj->Query[0] ;
  else           edtAddrFrom->Text = edtAddrFrom->Text + " ???" ;

  if (res <= 0) return ;
  pt_a = geoObj->Point[0]  ;

  res = geoObj->Parse( edtAddrTo->Text ) ;
  if (res > 0) edtAddrTo->Text = geoObj->Query[0] ;
  else         edtAddrTo->Text = edtAddrTo->Text + " ???" ;

  if (res <= 0) return ;
  pt_b = geoObj->Point[0]  ;

  rtrObj->UpdateTheData() ;
  rtrObj->Find( layerRoute->Unproject( pt_a ), layerRoute->Unproject( pt_b ) ) ;

  memRoute->Lines->BeginUpdate() ;
  memRoute->Clear() ;
  oldnam = "#$@3eqewe" ;
  for (i=0; i<=rtrObj->ItemsCount -1; i++) {
    switch ( rtrObj->Items[i]->Compass ) {
      case  0 : ang = "FWD  " ; break ;
      case  1 : ang = "RIGHT" ; break ;
      case  2 : ang = "RIGHT" ; break ;
      case  3 : ang = "RIGHT" ; break ;
      case  4 : ang = "BACK " ; break ;
      case -1 : ang = "LEFT " ; break ;
      case -2 : ang = "LEFT " ; break ;
      case -3 : ang = "LEFT " ; break ;
      case -4 : ang = "BACK " ; break ;
    }


    if ( oldnam == rtrObj->Items[i]->Name ) continue ;
    oldnam = rtrObj->Items[i]->Name ;

    memRoute->Lines->Add( ang + " " + rtrObj->Items[i]->Name ) ;
  }
  memRoute->Lines->EndUpdate() ;

  layerRoute->RevertShapes() ;

  for (i=0; i<=rtrObj->ItemsCount -1; i++) {
    shp = rtrObj->Items[i]->Layer->GetShape( rtrObj->Items[i]->Uid ) ;
    if ( shp==NULL ) continue ;
    layerRoute->AddShape( shp, False ) ;
    if (i == 0)
      layerRoute->Extent = shp->Extent ;
  }

  shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent );
    shp->AddPart() ;
    shp->AddPoint( pt_a ) ;
    shp->Params->Marker->Color = TGIS_Color::Green ;
  shp->Unlock() ;

  shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent );
    shp->AddPart() ;
    shp->AddPoint( pt_b ) ;
  shp->Unlock() ;

  GIS->Lock() ;
    GIS->VisibleExtent = layerRoute->Extent ;
    GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete geoObj ;
  delete rtrObj ;
}
//---------------------------------------------------------------------------

