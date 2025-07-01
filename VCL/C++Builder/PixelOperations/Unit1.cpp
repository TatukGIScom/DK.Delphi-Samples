//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to do operations on pixel layer.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
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
  TGIS_FileTypes _mode;
  dlgFileOpen->Filter = GisSupportedFiles( _mode << TGIS_FileType::All, false );

  GIS->Open( GisSamplesDataDirDownload() +
            "\\World\\Countries\\USA\\States\\California\\San Bernardino\\DOQ\\37134877.jpg"
           ) ;
  cbCheckPixelsClick(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbCheckPixelsClick(TObject *Sender)
{
  TGIS_LayerPixel *lp ;

  if ( GIS->IsEmpty ) return;

  lp = ( TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;
  if ( cbCheckPixels->Checked )
    lp->PixelOperationEvent = changePixels ;
  else
    lp->PixelOperationEvent = NULL ;

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

double __fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}

bool __fastcall TForm1::changePixels(
  TObject* _layer,
  const TGIS_Extent &_extent,
  const TGIS_Pixels _source,
  TGIS_Pixels  &_output,
  const int _width,
  const int _height
){

  int rmaxval, rminval ;
  int gmaxval, gminval ;
  int bmaxval, bminval  ;
  int i ;
  int rdelta  ;
  int gdelta  ;
  int bdelta ;
  int r, g, b ;
  TGIS_Color pixval ;
  int pix ;
  bool Result ;

  Result = true ;

  rmaxval = -1000 ;
  rminval =  1000 ;
  gmaxval = -1000 ;
  gminval =  1000 ;
  bmaxval = -1000 ;
  bminval =  1000 ;

  for( i = _source.Low ; i <=_source.High ; i++ ){
    pixval.ARGB = _source[i] ;
    r = pixval.R ;
    g = pixval.G ;
    b = pixval.B  ;

    if( r > rmaxval )
      rmaxval = r ;
    if( g > gmaxval )
      gmaxval = g ;
    if( b > bmaxval )
      bmaxval = b ;

    if( r < rminval )
      rminval = r ;
    if( g < gminval )
      gminval = g ;
    if( b < bminval )
      bminval = b ;
  }

  rdelta = Max( 1, rmaxval -rminval ) ;
  gdelta = Max( 1, gmaxval -gminval ) ;
  bdelta = Max( 1, bmaxval -bminval ) ;

  for ( i = _source.Low; i<=_source.High; i++ ) {
    pixval.ARGB = _source[i] ;
    r = pixval.R ;
    g = pixval.G ;
    b = pixval.B  ;
    r = trunc(((r -rminval)/1.0/rdelta)*255.0);
    g = trunc(((g -gminval)/1.0/gdelta)*255.0);
    b = trunc(((b -bminval)/1.0/bdelta)*255.0);

    pixval = TGIS_Color::FromARGB( 0xFF, r, g, b ) ;
    _output[i] = pixval.ARGB ;

  }

  return Result ;
}
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton1Click(TObject *Sender)
{
  if( !dlgFileOpen->Execute() ) return ;

  GIS->Open( dlgFileOpen->FileName ) ;
}
//---------------------------------------------------------------------------

