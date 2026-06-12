/*
 * Encode sample — demonstrates transparent layer encoding using ReadEvent and WriteEvent callbacks.
 *
 * A base world shapefile is loaded, then exported to a new file with an XOR cipher applied
 * byte-by-byte (keyed on file position) via the write callback.  The encoded file can be
 * re-opened: the same XOR callback in the read handler transparently decodes it on the fly.
 */
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
/* Closes all loaded layers. */
void __fastcall TForm1::btnCloseAllClick(TObject *Sender)
{
  GIS->Close() ;
}

//---------------------------------------------------------------------------
/* Opens the base world shapefile (WorldDCW) with country name labels. */
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
/* Exports the base layer to encoded.shp via ImportLayer with an XOR write callback applied to every byte. */
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
/* Opens the encoded shapefile with the ReadEvent wired so the XOR cipher is reversed on every read.  Layer is tinted green. */
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
/* Decodes each byte by XOR-ing it with (position + index) mod 256, reversing the encoding. */
void __fastcall TForm1::doRead( TObject * _sender, int _pos, void *_buffer, int _count )
{
  for( int i=0; i<_count; i++ ) {
    *( (char*)_buffer + i) = *( (char*)_buffer + i) ^ ( (int)( _pos + i ) % 256 ) ;
  }
}

//---------------------------------------------------------------------------
/* Encodes each byte by XOR-ing it with (position + index) mod 256. */
void __fastcall TForm1::doWrite( TObject * _sender, int _pos, void *_buffer, int _count )
{
  for( int i=0; i<_count; i++ ) {
    *( (char*)_buffer + i) = *( (char*)_buffer + i) ^ ( (int)( _pos + i ) % 256 ) ;
  }
}

