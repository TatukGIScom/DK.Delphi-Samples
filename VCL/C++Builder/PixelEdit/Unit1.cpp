//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
//
//  Use TGIS_LayerPixel.LockPixels & Loop to edit pixel content.
//
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


void __fastcall TForm1::btnAvargeColorClick(TObject *Sender)
{
  TGIS_LayerPixel  *lp      ;
  TGIS_LayerVector *lv      ;
  TGIS_Shape       *shp     ;
  TGIS_PixelItem   *px       ;
  Double           r,g,b    ;
  Integer          cnt      ;
  TGIS_Color       cl       ;
  TGIS_LayerPixelEnumerator *loop ;

  Memo1->Clear() ;

  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "\\Samples\\PixelEdit\\bitmap.ttkproject" ) ;

  lp = ( TGIS_LayerPixel *)( GIS->Get( "bluemarble" ) ) ;
  lv = ( TGIS_LayerVector *)( GIS->Get( "countries" ) ) ;

  shp = ( lv->GetShape( 679 ))->MakeEditable() ; // Spoin
  GIS->Lock() ;
  GIS->VisibleExtent = shp->ProjectedExtent ;
  GIS->Zoom = GIS->Zoom / 2.0 ;
  GIS->Unlock() ;


  cnt = 0 ;
  r = 0;
  g = 0;
  b = 0;

  loop = lp->Loop( shp->Extent, 0, shp, "T", false )->GetEnumerator();
  while( loop->MoveNext() ){
	px = loop->Current ;
	r = r + px->Color.R ;
	g = g + px->Color.G ;
	b = b + px->Color.B ;
	cnt = cnt + 1 ;
  }
  delete loop ;

  if( cnt > 0 ) {
	cl = TGIS_Color::FromRGB( trunc(r/cnt) , trunc(g/cnt), trunc(b/cnt) ) ;
	loop = lp->Loop( shp->Extent, 0, shp, "T", true )->GetEnumerator();
	while( loop->MoveNext() ){
	  px = loop->Current ;
	  px->Color = cl ;
	}
	delete loop ;
  }

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------



void __fastcall TForm1::btnCreateBitmapClick(TObject *Sender)
{
  TGIS_LayerJPG *lp  ;
  TGIS_LayerPixelLock *lck ;
  Integer x, y ;

  Memo1->Clear() ;

  lp = new TGIS_LayerJPG() ;
  try {
	// full UniCodeString cast provided ,
	// if not C++Builder chooses a wrong overload
	lp->Build( (UnicodeString)("test.jpg"), TGIS_CSFactory::ByEPSG( 4326 ),
			  TGIS_Utils::GisExtent( -180, -90, 180, 90 ), 360, 180
			) ;


	// direct access to pixels
	lck = lp->LockPixels( TGIS_Utils::GisExtent( -45, -45, 45, 45 ), lp->CS, True ) ;
	try {
	  for( x = lck->Bounds.Left; x<=lck->Bounds.Right ; x++ )
	  {
		for( y = lck->Bounds.Top; y<=lck->Bounds.Bottom; y++ ){
		  lck->Bitmap[ lck->BitmapPos(x,y) ] = (int)(TGIS_Color::Red.ARGB) ;
		}
	  }
	}
	__finally {
	  lp->UnlockPixels( lck );
	}

	lp->SaveData() ;
  }
  __finally {
	delete lp ;
  }

  GIS->Open( "test.jpg" ) ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnCreateGridClick(TObject *Sender)
{
  TGIS_LayerGRD *lp ;
  TGIS_LayerPixelLock *lck ;
  Integer x, y ;

  Memo1->Clear() ;

  lp = new TGIS_LayerGRD() ;
  try{
	// full UniCodeString cast provided,
	// if not C++Builder chooses a wrong overload
	lp->Build( UnicodeString("test.grd"), TGIS_CSFactory::ByEPSG( 4326 ),
			  TGIS_Utils::GisExtent( -180, -90, 180, 90 ), 360, 180
			) ;

	// direct access to pixels
	lck = lp->LockPixels( TGIS_Utils::GisExtent( -45, -45, 45, 45 ), lp->CS, True ) ;
	try {
	  for( x = lck->Bounds.Left; x<=lck->Bounds.Right ; x++ )
	  {
		for( y = lck->Bounds.Top; y<=lck->Bounds.Bottom ; y++ )
		{
		  lck->Grid[y][x] = Random(100) ;
		}
	  }
	}
	__finally{
	  lp->UnlockPixels( lck );
	}

	lp->SaveData() ;
  }
  __finally{
	delete lp ;
  }

  GIS->Open( "test.grd" ) ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnMinMaxClick(TObject *Sender)
{
  TGIS_LayerPixel *lp        ;
  TGIS_LayerVector *lv       ;
  TGIS_LayerVector *ltmp     ;
  TGIS_Shape *shp            ;
  TGIS_Shape *shptmp         ;
  TGIS_PixelItem *px         ;
  Double dmin, dmax          ;
  TGIS_Point ptmin, ptmax    ;
  AnsiString  str            ;
  TGIS_LayerPixelEnumerator *loop ;
  Memo1->Clear() ;

  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "\\Samples\\PixelEdit\\grid.ttkproject" ) ;


  lp = ( TGIS_LayerPixel *)( GIS->Get( "elevation" ) ) ;
  lv = ( TGIS_LayerVector *)( GIS->Get( "polygon" ) ) ;
  shp = ( lv->GetShape( 1 ) )->MakeEditable() ;
  shp->IsSelected = True ;

  dmax = -1e38 ;
  dmin =  1e38 ;

  loop = lp->Loop( shp->Extent, 0, shp, "T", false )->GetEnumerator();
  while( loop->MoveNext() ){
	px = loop->Current ;
	if( px->Value < dmin ){
	  dmin  = px->Value  ;
	  ptmin = px->Center ;
	}

	if( px->Value > dmax ){
	  dmax  = px->Value  ;
	  ptmax = px->Center ;
	}
  }
  delete loop ;

  ltmp = new TGIS_LayerVector() ;
  ltmp->CS = lp->CS ;
  GIS->Add( ltmp );

  ltmp->Params->Marker->Style = TGIS_MarkerStyle::Cross ;
  ltmp->Params->Marker->Size = -10 ;
  ltmp->Params->Marker->Color = TGIS_Color::Black  ;

  shptmp = ltmp->CreateShape( TGIS_ShapeType::Point ) ;
  shptmp->AddPart() ;
  shptmp->AddPoint( ptmin ) ;

  shptmp = ltmp->CreateShape( TGIS_ShapeType::Point ) ;
  shptmp->AddPart() ;
  shptmp->AddPoint( ptmax ) ;

  GIS->InvalidateWholeMap() ;

  Memo1->Lines->Add( str.sprintf( "Min: %f, Location: %f %f", dmin, ptmin.X, ptmin.Y  ) ) ;
  Memo1->Lines->Add( str.sprintf( "Max: %f, Location: %f %f", dmax, ptmax.X, ptmax.Y ) ) ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnProfileClick(TObject *Sender)
{
  TGIS_LayerPixel   *lp   ;
  TGIS_LayerVector  *lv   ;
  TGIS_Shape        *shp   ;
  TGIS_PixelItem    *px    ;
  TGIS_LayerPixelEnumerator *loop ;
  AnsiString str ;


  Memo1->Clear() ;

  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "\\Samples\\PixelEdit\\grid.ttkproject" ) ;

  lp = ( TGIS_LayerPixel *)( GIS->Get( "elevation" ) ) ;
  lv = ( TGIS_LayerVector *)( GIS->Get( "line" ) ) ;
  shp = lv->GetShape( 1 )->MakeEditable() ;
  shp->IsSelected = True ;

  Memo1->Lines->BeginUpdate() ;
  try{
	loop = lp->Loop( 0, shp, false )->GetEnumerator();
	while( loop->MoveNext() ){
	  px = loop->Current ;
	  Memo1->Lines->Add( str.sprintf( "Distance: %f, Height:%f", px->Distance, px->Value ) ) ;

	}
  }
  __finally{
	Memo1->Lines->EndUpdate() ;
	delete loop ;
  }
}
//---------------------------------------------------------------------------

double __fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}

