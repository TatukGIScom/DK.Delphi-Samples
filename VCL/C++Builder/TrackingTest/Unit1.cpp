//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to create tracked layer.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
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
  TGIS_LayerVector *ll;
  TGIS_Shape       *shp;

  GIS->Lock() ;
  try
  {
    GIS->Open( GisSamplesDataDirDownload() + "\\World\\VisibleEarth\\world_8km.jpg", true );
    GIS->Zoom = GIS->Zoom * 2 ;

	  // create a layer and add a field
	  ll = new TGIS_LayerVector;
	  ll->Params->Marker->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
	  ll->Params->Marker->SymbolRotate = M_PI / 2 ;
	  ll->Params->Marker->Size = -20 ;
	  ll->Params->Line->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\1301.cgm" ) ;
	  ll->Params->Line->Width  = -5 ;
	  ll->CachedPaint = FALSE ;
	  GIS->Add( ll ) ;
	  ll->AddField( "Name", TGIS_FieldType::String, 255, 0 ) ;
	  ll->Params->Labels->Field = "Name" ;
	
	  // add random plains
	  ll = ( TGIS_LayerVector *)( ( GIS->Items )->Items[1] );
	  randomize();
	  for ( int i = 0 ; i <= 100 ; i++ ) {
	    shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
	    shp->SetField("Name", IntToStr( i+1 ));
	    shp->Params->Marker->SymbolRotate = DegToRad( 1.0*random( 360 ) ) ;
	    shp->Params->Marker->Color = TGIS_Color::FromRGB( random(256), random(256), random(256) ) ;
	    shp->Params->Marker->OutlineColor = shp->Params->Marker->Color;
	    shp->Lock( TGIS_Lock::Extent );
	    shp->AddPart() ;
	    shp->AddPoint( GisPoint( -180 + Random( 360 ) , ( 90 - Random( 180 ) )) );
	    shp->Unlock();
	  }
  }
  __finally
  {
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAnimateClick(TObject *Sender)
{
  TGIS_Shape          *shp;
  TGIS_Point           pt;
  int                  delta;
  TGIS_LayerAbstract  *ll;
  TGIS_LayerVector    *lv;

  btnAnimate->Enabled = false ;

  ll = ( TGIS_LayerAbstract *)( (GIS->Items)->Items[1] );
  lv = ( TGIS_LayerVector *)( (GIS->Items)->Items[1] );

  for ( int i = 0 ; i <= 90 ; i++ ) {
    if ( chkUseLock->Checked) GIS->Lock() ;

    // move plains
    for ( int j = 1 ; j <= 90 ; j++ ) {
      shp = lv->GetShape( j ) ;
      pt = shp->Centroid() ;
      delta = fmod( j, 3.0 ) - 1 ;
      shp->SetPosition( GisPoint( pt.X + delta, pt.Y ), NULL, 0 ) ;
      Application->ProcessMessages() ;
    }

    if ( chkUseLock->Checked ) {
      GIS->Unlock() ;
      Application->ProcessMessages() ;
    }
    else GIS->LabelsReg->Reset() ;
  }

  btnAnimate->Enabled = true ;

}
//---------------------------------------------------------------------------

