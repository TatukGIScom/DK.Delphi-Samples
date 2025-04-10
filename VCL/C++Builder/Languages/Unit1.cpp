//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to add multilanguage support.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "math.h"
#include "assert.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

// text in non-unicode encodings
#include "unicode.h"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------



void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll  ;
  TGIS_Shape        *shp ;

  ll = new TGIS_LayerVector ;
  ll->Name = "points" ;
  ll->Params->Labels->Position <<  TGIS_LabelPosition::UpLeft ;
  ll->Params->Labels->Allocator = False ;

  GIS->Add( ll ) ;
  ll->Extent = GisExtent( -180, -90, 180, 90 ) ;

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( -45, -45 ) ) ;


  ll = new TGIS_LayerVector ;
  ll->Name = "lines" ;
  ll->AddField( "name", TGIS_FieldType::String, 256, 0 ) ;
  ll->Params->Labels->Alignment = TGIS_LabelAlignment::Follow ;
  ll->Params->Labels->Font->Size = 12 ;
  ll->Params->Labels->Color = TGIS_Color::FromRGB( 0x010101 ) ;
  ll->Params->Labels->Font->Color = TGIS_Color::FromRGB( 0x010101 );
  ll->Params->Labels->Allocator = False ;

  GIS->Add( ll ) ;
  ll->Extent = GisExtent( -180, -90, 180, 90 ) ;


  shp = ll->CreateShape( TGIS_ShapeType::Arc ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( -90,  90 ) ) ;
  shp->AddPoint( GisPoint( 180, -90 ) ) ;

  GIS->FullExtent() ;

  ComboBox1->ItemIndex = 0 ;
  ComboBox1Change( NULL ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ComboBox1Change(TObject *Sender)
{
  TGIS_LayerVector  *ll   ;
  String             txt  ;
  Integer            cp   ;

  switch ( ComboBox1->ItemIndex ) {
    case 1  : { // Chinese
                txt = TXT_CHINESE  ;
                cp  = 936          ;
                break ;
              }
    case 2  : { // Japanse
                txt = TXT_JAPANESE ;
                cp  = 932          ;
                break ;
              }
    case 3  : { // Arabic
                txt = TXT_ARABIC   ;
                cp  = 1256         ;
                break ;
              }
    case 4  : { // Hebrew
                txt = TXT_HEBREW   ;
                cp  = 1255         ;
                break ;
              }
    case 5  : { // Greek
                txt = TXT_GREEK    ;
                cp  = 1253         ;
                break ;
              }
    default : { // English
                txt = TXT_ENGLISH  ;
                cp  = 1250         ;
              }
  }

  ll = (TGIS_LayerVector *)( GIS->Get( "points" ) );
  ll->CodePage = cp ;
  ll->Params->Labels->Value = Format( "%s %d", OPENARRAY(TVarRec, ( txt, 1) ) ) ;

  ll = (TGIS_LayerVector *)( GIS->Get( "lines" ) ) ;
  ll->CodePage = cp ;
  ll->Params->Labels->Value = Format( "%s %d", OPENARRAY(TVarRec, ( txt, 2) ) ) ;

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

