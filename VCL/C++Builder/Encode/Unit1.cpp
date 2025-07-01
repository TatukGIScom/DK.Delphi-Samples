//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//  How to encode SHP Layer
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
void __fastcall TForm1::btnCloseAllClick(TObject *Sender)
{
  GIS->Close() ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnOpenBaseClick(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  GIS->Close() ;

  // add states layer
  ll = ( TGIS_LayerSHP *)GisCreateLayer(
         "base",
         GisSamplesDataDirDownload() + "\\World\\WorldDCW\\world.shp"
       )  ;
  ll->Params->Labels->Field = "NAME" ;
  GIS->Add(ll) ;
  GIS->FullExtent() ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnEncodeClick(TObject *Sender)
{
  TGIS_LayerVector *ls ;
  TGIS_LayerSHP    *ld ;

   if ( GIS->IsEmpty ) {
     ShowMessage( "Open Base layer first" ) ;
     return ;
   } ;

   ls = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
   if ( ls->Name == "encoded" ) {
     ShowMessage( "This layer is alredy encoded, Open Base layer" ) ;
     return ;
   }
   try {
     ld = new TGIS_LayerSHP ;
     ld->ReadEvent  = doRead  ;
     ld->WriteEvent = doWrite ;
     ld->Path = "encoded.shp" ;
     ld->ImportLayer( ls, GIS->Extent, TGIS_ShapeType::Polygon, "", FALSE ) ;
   } __finally {
     delete ld;
   }

}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnOpenEncodedClick(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  GIS->Close() ;

  // add states layer
  ll = new TGIS_LayerSHP ;
  ll->Path = "encoded.shp" ;
  ll->Name = "encoded" ;
  ll->ReadEvent  = doRead ;
  ll->WriteEvent = doWrite ;
  ll->Params->Labels->Field = "NAME" ;
  ll->Params->Area->Color = TGIS_Color::Green ;
  GIS->Add(ll) ;
  GIS->FullExtent() ;
}

//---------------------------------------------------------------------------
// do decoding with incrementing XOR value
void __fastcall TForm1::doRead( TObject * _sender, int _pos, void *_buffer, int _count )
{
  for( int i=0; i<_count; i++ ) {
    *( (char*)_buffer + i) = *( (char*)_buffer + i) ^ ( (int)( _pos + i ) % 256 ) ;
  }
}

//---------------------------------------------------------------------------
// do encoding with incrementing XOR value
void __fastcall TForm1::doWrite( TObject * _sender, int _pos, void *_buffer, int _count )
{
  for( int i=0; i<_count; i++ ) {
    *( (char*)_buffer + i) = *( (char*)_buffer + i) ^ ( (int)( _pos + i ) % 256 ) ;
  }
}

