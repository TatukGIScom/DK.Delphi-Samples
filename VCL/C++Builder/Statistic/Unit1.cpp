//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// How to provied simple statistical analyzes by overriding OnSPaintShape event.
//
// Check project\options\directories in a case of any problems during compilation
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
  TGIS_LayerSHP *ll ;

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp" ;
  ll->UseConfig = False ;
  ll->Name = "counties" ;
  ll->PaintShapeEvent = PaintShape ;
  GIS->Add(ll) ;

  GIS->FullExtent() ;

  ComboStatistic->ItemIndex = 0 ;
  ComboLabels->ItemIndex = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::PaintShape( TObject * _sender, TGIS_Shape * _shape  )
{
  double population  ;
  double area        ;
  double factor      ;

  population = StrToFloat( _shape->GetField("population") );
  area       = StrToFloat( _shape->GetField("area")       );

  if ( ComboStatistic->ItemIndex == 1 )
  {
    factor = area ;

    // assign different bitmaps for factor value
    if      ( factor <     40 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x0000F00C );
    else if ( factor <    130 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x00AEFFB3 );
    else if ( factor <    480 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x00CCCCFF );
    else if ( factor <   2000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x003535FF );
    else if ( factor <  10000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x000000B3 );
    else                        _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x003000B3 );
  }
  else
  {
    factor = population ;

    // assign different bitmaps for factor value
    if      ( factor <   5000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x0000F00C );
    else if ( factor <  22000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x00AEFFB3 );
    else if ( factor < 104000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x00CCCCFF );
    else if ( factor < 478000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x003535FF );
    else if ( factor <2186000 ) _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x000000B3 );
    else                        _shape->Params->Area->Color = TGIS_Color::FromRGB( 0x003000B3 );
  }
  _shape->Draw();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ComboChange(TObject *Sender)
{
  TGIS_LayerVector *ll  ;

  ll = (TGIS_LayerVector *)(GIS->Get( "counties" ) ) ;
  if ( ll ) {
    switch ( ComboLabels->ItemIndex ) {
      case 1  : {
                  ll->Params->Labels->Field = "CNTYIDFP" ;
                  break ;
                }
      case 2  : {
                  ll->Params->Labels->Field = "NAME" ;
                  break ;
                }
      default : {
                  ll->Params->Labels->Field = "" ;
                }
    }
  }

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------




