//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to attach bitmaps to shapes.
//  Good results only under Windows NT/2000/XP.
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
  double  population ;
  double  area       ;
  double  factor     ;
  TBitmap *oldBitmap ;

  population = StrToFloat( _shape->GetField("population") );
  area       = StrToFloat( _shape->GetField("area")       );

  if ( area == 0 ) return;

  oldBitmap = NULL;
  if ( _shape->Params->Area->Bitmap != NULL ) 
      if ( !(_shape->Params->Area->Bitmap->IsEmpty) ) 
          oldBitmap = (TBitmap *)(_shape->Params->Area->Bitmap->NativeBitmap) ;
  
  _shape->Params->Area->Bitmap = new TGIS_Bitmap ;
  _shape->Params->Area->Pattern = TGIS_BrushStyle::Solid ;
  _shape->Params->Area->Color = TGIS_Color::Red ;
  _shape->Params->Area->OutlineColor = TGIS_Color::DimGray ;
  _shape->Params->Area->OutlineWidth = 20 ;

  if ( ComboStatistic->ItemIndex == 1 )
  {
    factor = population/area ;

    // assing different bitmaps for factor value
    if      ( factor <      1 ) _shape->Params->Area->Bitmap->NativeBitmap = Image1->Picture->Bitmap ;
    else if ( factor <      7 ) _shape->Params->Area->Bitmap->NativeBitmap = Image2->Picture->Bitmap ;
    else if ( factor <     52 ) _shape->Params->Area->Bitmap->NativeBitmap = Image3->Picture->Bitmap ;
    else if ( factor <    380 ) _shape->Params->Area->Bitmap->NativeBitmap = Image4->Picture->Bitmap ;
    else if ( factor <   3000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image5->Picture->Bitmap ;
  }
  else
  {
    factor = population ;
   //   assing different bitmaps for factor value
    if      ( factor <   5000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image1->Picture->Bitmap ;
    else if ( factor <  22000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image2->Picture->Bitmap ;
    else if ( factor < 104000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image3->Picture->Bitmap ;
    else if ( factor < 478000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image4->Picture->Bitmap ;
    else if ( factor <2186000 ) _shape->Params->Area->Bitmap->NativeBitmap = Image5->Picture->Bitmap ;
  }
  _shape->Draw();

  _shape->Params->Area->Bitmap->NativeBitmap = oldBitmap ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ComboChange(TObject *Sender)
{
  TGIS_LayerVector *ll  ;

  ll = (TGIS_LayerVector *)(GIS->Get( "counties" ) ) ;
  if ( ll != NULL ) {
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


