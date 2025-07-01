//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to perform WKT operation.
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

#define STR_POINT        "POINT (30 30)"
#define STR_MULTIPOINT   "MULTIPOINT (4 4, 5 5, 6 6 ,7 7)"
#define STR_LINESTR      "LINESTRING (3 3, 10 10)"
#define STR_MULTILINESTR "MULTILINESTRING ((1 1 3 3 4 4 6 6),(1 1 3 3 4 4 6 6))"
#define STR_POLYGON      "POLYGON( ( 5 5, 25 5, 25 25, 5 25, 5 5), ( 10 10, 10 20, 20 20, 20 10, 10 10)  )"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  layerObj = new TGIS_LayerVector ;
  layerObj->Name = "output" ;
  layerObj->Params->Area->Color = TGIS_Color::Red ;

  GIS->Add( layerObj ) ;
  GIS->FullExtent() ;
  Memo1->Text = STR_POLYGON;
  cbType->ItemIndex = 4;
  Memo1Change(Sender) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Memo1Change(TObject *Sender)
{
  TGIS_Shape  *shp ;

  try {
    layerObj->RevertShapes() ;
    shp = TGIS_Utils::GisCreateShapeFromWKT( Memo1->Text ) ;
    if ( shp ) {
      layerObj->AddShape( shp, False ) ;
      delete shp ;
    }
    else
      Abort ;
    Memo1->Font->Color = clBlack ;
  }
  catch(...) {
    Memo1->Font->Color = clRed ;
  }
  layerObj->RecalcExtent() ;
  GIS->RecalcExtent() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cbTypeChange(TObject *Sender)
{
  switch (cbType->ItemIndex) {
        case 0 : Memo1->Text = STR_POINT; break;
        case 1 : Memo1->Text = STR_MULTIPOINT; break;
        case 2 : Memo1->Text = STR_LINESTR; break;
        case 3 : Memo1->Text = STR_MULTILINESTR; break;
        case 4 : Memo1->Text = STR_POLYGON; break;
  }
  Memo1Change(Sender) ;
}
//---------------------------------------------------------------------------

