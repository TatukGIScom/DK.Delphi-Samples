//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//  How to use GPS Nmea unit.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include <math.h>
//---------------------------------------------------------------------------

#pragma package(smart_init)
#pragma resource "*.dfm"

#pragma startup MyInit
#pragma exit MyFinal

TForm1 *Form1;
TCriticalSection *CriticalSection;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void MyInit(void)
{
  CriticalSection = new TCriticalSection;
}
//---------------------------------------------------------------------------
void MyFinal(void)
{
  if ( CriticalSection ) delete CriticalSection;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector *lv;
  TGIS_LayerSHP    *llshp ;

  cbxCom->ItemIndex = GPS->Com - 1 ;

  for (int i = 0 ; i <= cbxBaud->Items->Count - 1 ; i++) {
    if ( StrToInt( cbxBaud->Items->Strings[ i ] ) == GPS->BaudRate) {
       cbxBaud->ItemIndex = i ;
       break ;
    }
  }
  GPS->Active = true ;


  llshp = new TGIS_LayerSHP;
  llshp->Path = GisSamplesDataDirDownload() + "\\World\\WorldDCW\\world.shp";
  GIS->Add( llshp ) ;
  GIS->FullExtent();

  if (!FileExists( "routes.kml" ) ) {
    llshp->Build( "routes.kml", llshp->Extent, TGIS_ShapeType::Arc ) ;
  }
  if (!FileExists( "points.kml" ) ) {
    llshp->Build( "points.kml", llshp->Extent, TGIS_ShapeType::Arc ) ;
  }
  llshp = new TGIS_LayerSHP ;
  llshp->Path = "routes.kml";
  llshp->Name = "routes";
  GIS->Add( llshp ) ;

  lv = ( TGIS_LayerVector * )(GIS->Get("routes") ) ;
  lv->Params->Line->Color = TGIS_Color::Red ;
  try {
    lv->AddField( "Date", TGIS_FieldType::String, 10, 0 ) ;
  }
  catch( ... ) {}

  llshp = new TGIS_LayerSHP ;
  llshp->Path = "points.kml";
  llshp->Name = "points";
  GIS->Add( llshp ) ;


  lv = ( TGIS_LayerVector * )(GIS->Get("points") ) ;
  try {
    lv->AddField( "Name", TGIS_FieldType::String, 10, 0 ) ;
  }
  catch( ... ) {}

  try {
    lv->AddField( "Date", TGIS_FieldType::String, 10, 0 ) ;
  }
  catch( ... ) {}
  lv->Params->Labels->Value = "{Name}<br><i>{date}</i>";

  GPS->Active = True ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::GPSPosition(TObject *Sender)
{
  TGIS_Point    ptg ;
  double        dist ;
  double        prec ;
  TGIS_CSGeographicCoordinateSystem *cs ;

  CriticalSection->Enter();

  try {
    if ( double( Now() - double( GPS->PositionTime ) ) < 1/24 ) {
      edtPoint->Enabled = true ;
      btnAdd->Enabled = true ;
    }
    else {
      edtPoint->Enabled = false ;
      btnAdd->Enabled = false ;
    }

    // calculate delta of two read-out (in meters)
    cs = CSGeographicCoordinateSystemList()->ByEPSG( 4326 ) ;
    ptg = GisPoint( GPS->Longitude, GPS->Latitude ) ;
    dist = cs->Datum->Ellipsoid->Distance( ptg, lastPointGps ) ;
    lastPointGps = ptg ;
    lastPointMap = GIS->CS->FromWGS( ptg );

    if (!actRecord->Checked) return;

    prec = GPS->PositionPrec ;
    if( prec == 0 ) {
        prec = 5 ;
    }

    if ( dist < prec ) {
        return;
    }

    if ( currShape != NULL) {
      currShape->AddPoint( lastPointMap ) ;
      currShape->SetField( "Date", FormatDateTime( "yyyy/mm/dd HH:nn.ss", Now() ) ) ;
    }
    currShape = ((TGIS_LayerVector *)( GIS->Get( "routes") ))->CreateShape( TGIS_ShapeType::Arc );
    currShape->AddPart();
    currShape->AddPoint( lastPointMap ) ;

    GIS->Center = lastPointMap ;
  }
  __finally {
    CriticalSection->Leave();
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point ptg;
  String     lon, lat ;
  String     str ;

  if ( GIS->IsEmpty ) return;

  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;

  try
  {
    lon = GisLongitudeToStr( ptg.X ) ;
  }
  catch (Exception &exception)
  {
    lon = "???" ;
  }

  try
  {
    lat = GisLatitudeToStr( ptg.Y ) ;
  }
  catch (Exception &exception)
  {
    lat = "???" ;
  }

  paInfo->Caption = Format( "%s : %s", OPENARRAY(TVarRec, (lon,lat) ) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbxComChange(TObject *Sender)
{
  GPS->Com = cbxCom->ItemIndex + 1 ;
  GPS->Active = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::actAddExecute(TObject *Sender)
{
  TGIS_Shape        *shp;

  CriticalSection->Enter();

  try {
    shp = ( (TGIS_LayerVector *)( GIS->Get("points") ) )->CreateShape( TGIS_ShapeType::Point ) ;
    shp->AddPart() ;
    shp->AddPoint( lastPointMap ) ;
    shp->SetField( "Date", FormatDateTime( "yyyy/mm/dd HH:nn.ss", Now() ) ) ;
    shp->SetField( "Name", edtPoint->Text ) ;

    GIS->Center =  lastPointMap ;
  }
  __finally {
    CriticalSection->Leave() ;
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::actSaveExecute(TObject *Sender)
{
  CriticalSection->Enter();
  try {
    if (Sender != btnSave) {
      btnSave->Down = True ;
      Application->ProcessMessages() ;
    }

    if ( currShape != NULL ) {
      currShape->AddPoint( lastPointMap ) ;
      currShape = NULL ;
    }
    GIS->SaveAll();
    if ( Sender != btnSave ) {
      btnSave->Down = false ;
      Application->ProcessMessages() ;
    }
  }
  __finally {
    CriticalSection->Leave() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::actRecordExecute(TObject *Sender)
{
  actRecord->Checked = (!actRecord->Checked) ;

  // make recording incative
  if ( !actRecord->Checked ) currShape = NULL ;
}
//---------------------------------------------------------------------------


void __fastcall TForm1::FormCloseQuery(TObject *Sender, bool &CanClose)
{
  GIS->Editor->EndEdit() ;
  if ( !GIS->MustSave() ) return;

  if ( Application->MessageBox( L"Save all unsaved work?", L"TatukGIS", MB_YESNO) == IDYES)
    GIS->SaveAll() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbxBaudChange(TObject *Sender)
{
  GPS->BaudRate = StrToInt( cbxBaud->Items->Strings[ cbxBaud->ItemIndex ] ) ;
  GPS->Active   = true ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::actListUpdate(TBasicAction *Action, bool &Handled)
{
  btnRecord->Down = actRecord->Checked ;
}
//---------------------------------------------------------------------------


