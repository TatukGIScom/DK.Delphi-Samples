//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to add layer to the map.
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


void __fastcall TForm1::CreateLayerButtonClick(TObject *Sender)
{
  TGIS_LayerVector *lv  ;
  TGIS_Shape *shp   ;
  Integer i    ;
  Double an   ;

  GIS->Close() ;

  lv = new TGIS_LayerVector ;
  lv->Name = "Fields" ;
  lv->Open() ;

  lv->AddField( "rotateLabel", TGIS_FieldType::Float, 10, 4 ) ;
  lv->AddField( "rotateSymbol", TGIS_FieldType::Float, 10, 4 ) ;
  lv->AddField( "color", TGIS_FieldType::Number, 10, 0 ) ;
  lv->AddField( "outlinecolor", TGIS_FieldType::Number, 10, 0 ) ;
  lv->AddField( "size", TGIS_FieldType::Number, 10, 0 ) ;
  lv->AddField( "label", TGIS_FieldType::String, 1, 0 ) ;
  lv->AddField( "position", TGIS_FieldType::String, 1, 0 ) ;
  lv->AddField( "scale", TGIS_FieldType::Float, 10, 4 ) ;

  for ( i = 0 ; i <= 10 ;i++ ){
    shp = lv->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Projection ) ;
    shp->AddPart() ;
    shp->AddPoint( GisPoint( random( 20 ), random( 20 ) ) ) ;
    an = random( 360 ) ;
    shp->SetField( "rotateLabel",  an ) ;
    shp->SetField( "rotateSymbol", an ) ;
    shp->SetField( "color", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) ) ) ;
    shp->SetField( "outlinecolor", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) ) ) ;
    shp->SetField( "label", "Point" + IntToStr( i ) ) ;
	shp->SetField( "size", random( 400 ) ) ;
	TGIS_LabelPositions labelpos ;
	labelpos << TGIS_LabelPosition( random( 9 ) ) ;
	shp->SetField( "position", ConstructParamPosition( labelpos  ) );
	shp->SetField( "scale", 3.1415/180 ) ;
	shp->Unlock() ;
  };

  shp = lv->CreateShape( TGIS_ShapeType::Arc );
  shp->Lock( TGIS_Lock::Extent ) ;
    shp->AddPart() ;
    for ( i = 0 ; i<= 10 ; i++ ){
      shp->AddPoint( GisPoint( random( 20 ) - 10 , random( 20 ) - 10 ) );
    } ;
    an = random( 360 ) ;
    shp->SetField( "rotateLabel",  an ) ;
    shp->SetField( "rotateSymbol", an ) ;
    shp->SetField( "color", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) )) ;
    shp->SetField( "label", "Point" + IntToStr( 1 ) ) ;
    shp->SetField( "outlinecolor", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) )) ;
    shp->SetField( "scale", 3.1415/180 ) ;
  shp->Unlock() ;

  for ( i = 1 ; i<= 11 ;i++){
    shp = lv->CreateShape( TGIS_ShapeType::Arc );
    shp->Lock( TGIS_Lock::Extent ) ;
      shp->AddPart() ;
      shp->AddPoint( GisPoint( 20+ 2*i , 0 ) );
      shp->AddPoint( GisPoint( 30+ 2*i , 10 ) );
      an = random( 360 ) ;
      shp->SetField( "rotateLabel",  an ) ;
      shp->SetField( "rotateSymbol", an ) ;
	  shp->SetField( "size", i ) ;
	  shp->SetField( "color", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) )) ;
	  shp->SetField( "outlinecolor", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) )) ;
	  shp->SetField( "scale", 3.1415/180 ) ;
	shp->Unlock() ;
  } ;

  shp = lv->CreateShape( TGIS_ShapeType::Polygon );
  shp->Lock( TGIS_Lock::Extent ) ;
	shp->AddPart() ;
	for ( i = 0 ; i<=3 ; i++) {
	  shp->AddPoint( GisPoint( random( 20 ) - 10 , random( 20 ) - 10 ) );
	} ;
	an = random( 360 ) ;
	shp->SetField( "rotateLabel",  an ) ;
	shp->SetField( "rotateSymbol", an ) ;
	shp->SetField( "color", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) )) ;
	shp->SetField( "outlinecolor", (TColor) ( (random(256) << 16) + (random( 256 ) << 8) + random ( 256 ) ) ) ;
	shp->SetField( "label", "Point" + IntToStr( 2 ) ) ;
  shp->Unlock() ;

  lv->Params->Marker->ColorAsText         = "FIELD:color" ;
  lv->Params->Marker->OutlineColorAsText  = "FIELD:outlinecolor" ;
  lv->Params->Marker->OutlineWidth          = 1 ;
  lv->Params->Marker->Size                  = 20 * 20 ; //converting points to twips -> 1pt = 20 twips

  if  (chkUseSymbols->Checked ) {
    lv->Params->Marker->Symbol              = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
	lv->Params->Marker->SizeAsText          = "FIELD:size:1 dip" ;
	lv->Params->Marker->SymbolRotateAsText  = "FIELD:rotateSymbol" ;
  };

  lv->Params->Labels->Field                 = "label" ;
  lv->Params->Labels->Allocator             = False ;
  lv->Params->Labels->ColorAsText           = "FIELD:color" ;
  lv->Params->Labels->OutlineColorAsText    = "FIELD:outlinecolor" ;
  lv->Params->Labels->PositionAsText        = "FIELD:position" ;
  lv->Params->Labels->FontColorAsText       = "FIELD:color" ;
  lv->Params->Labels->RotateAsText          = "FIELD:rotateLabel:1 deg" ;


  if ( chkUseSymbols->Checked ) {
	lv->Params->Line->Symbol                = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\1301.cgm" ) ;
	lv->Params->Line->SymbolRotateAsText    = "FIELD:rotateSymbol:1 deg";
  };
  lv->Params->Line->ColorAsText           = "FIELD:color" ;
  lv->Params->Line->OutlineColorAsText    = "FIELD:outlinecolor" ;
  lv->Params->Line->WidthAsText           = "FIELD:size:1 dip" ;

  lv->Params->Area->SymbolRotateAsText    = "rotateSymbol" ;
  if (chkUseSymbols->Checked )
    lv->Params->Area->Symbol                = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\1301.cgm" ) ;
  lv->Params->Area->ColorAsText             = "FIELD:color" ;
  lv->Params->Area->OutlineColorAsText      = "FIELD:outlinecolor" ;

  GIS->Add( lv ) ;
  GIS->FullExtent() ;
  GIS_ControlLegend->GIS_Layer = lv ;
  GIS_ControlLegend->Update() ;

  GIS_DataSet1->Open( lv, lv->Extent ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GIS_DataSet1AfterPost(TDataSet *DataSet)
{
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

