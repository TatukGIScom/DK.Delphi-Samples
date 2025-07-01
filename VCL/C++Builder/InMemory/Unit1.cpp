//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to add in-memory layers.
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

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------


void __fastcall TForm1::Button1Click(TObject *Sender)
{
  TGIS_LayerVector *ll ;

  ll = new TGIS_LayerVector ;
  ll->Params->Marker->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
  ll->Params->Marker->SymbolRotate = M_PI/2 ;
  ll->Params->Marker->Size = -20 ;
  ll->Params->Line->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\1301.cgm" ) ;
  ll->Params->Line->Width = -5 ;
  GIS->Add( ll ) ;
  ll->Extent = GisExtent( -180, -90, 180, 90 ) ;
  GIS->FullExtent() ;
  Button1->Enabled = FALSE ;
  StatusBar1->SimpleText = " Layer created.";
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  if ( GIS->IsEmpty ) {
    ShowMessage( "Create a layer first" ) ;
    return ;
  }

  for (i=0; i<=100; i++) {
    shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Params->Marker->SymbolRotate = DegToRad( 1.0*random( 360 ) ) ;
    shp->Params->Marker->Color = TGIS_Color::FromRGB((random(256) << 16) + (random( 256 ) <<  8) + random ( 256 ) );
    shp->Params->Marker->OutlineColor = shp->Params->Marker->Color ;
    shp->Lock( TGIS_Lock::Extent );
    shp->AddPart() ;
    shp->AddPoint( GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) );
    shp->Unlock();
  }
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button3Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  if ( GIS->IsEmpty ) {
    ShowMessage( "First create Layer" ) ;
    return ;
  } ;

  assert( GIS->Items->Count > 0 ) ;
  shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Arc );
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  for (i=0; i<=20; i++) {
    shp->AddPoint( GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) );
  }
  shp->Unlock() ;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button4Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp ;

  if ( GIS->IsEmpty ) {
    ShowMessage( "First create Layer" ) ;
    return ;
  } ;

  assert( GIS->Items->Count > 0 ) ;
  shp = ((TGIS_LayerVector *)( GIS->Items->Items[0] ))->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( 0 , 0 ) );

  shp->Params->Marker->Color = TGIS_Color::Blue ;
  shp->Params->Marker->OutlineColor = TGIS_Color::Blue ;
  shp->Params->Marker->Size = -20 ;

  shp->Unlock() ;
  shp->Invalidate();

  for (i=0; i<=90; i++) {
    shp->SetPosition( GisPoint( i * 2, i ), NULL, 0 ) ;
    Sleep( 10 ) ;
    Application->ProcessMessages() ;
  }
}
//---------------------------------------------------------------------------

