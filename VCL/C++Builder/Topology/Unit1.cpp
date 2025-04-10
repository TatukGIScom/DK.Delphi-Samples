//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//   How to perform Topology operation.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
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


void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll ;

  topologyObj = new TGIS_Topology ;
  
  GIS->Lock();
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology.shp", true ) ;

  ll = (TGIS_LayerVector *)(GIS->Items->Items[0]) ;
  if ( ll == NULL ) return ;

  shpA = (TGIS_ShapePolygon *)( ll->GetShape( 1 )->MakeEditable() );
  if ( shpA == NULL ) return ;

  shpB = (TGIS_ShapePolygon *)( ll->GetShape( 2 )->MakeEditable() );
  if ( shpB == NULL ) return ;

  layerObj = new TGIS_LayerVector ;
  layerObj->Name = "output" ;
  layerObj->Transparency = 50 ;
  layerObj->Params->Area->Color  = TGIS_Color::Red ;

  GIS->Add( layerObj ) ;
  GIS->Unlock();
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnAplusBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Union, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnAmultBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Intersection, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnAminusBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::Difference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnBminusAClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpB, shpA, TGIS_TopologyCombineType::Difference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnAxorBClick(TObject *Sender)
{
  TGIS_Shape  *tmp ;

  layerObj->RevertShapes() ;
  tmp = topologyObj->Combine( shpA, shpB, TGIS_TopologyCombineType::SymmetricalDifference, false ) ;
  if ( tmp ) {
    layerObj->AddShape( tmp, False ) ;
    delete tmp ;
  } ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
