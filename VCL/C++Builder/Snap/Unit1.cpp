//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to tracking points.
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
  TGIS_LayerVector *ll;

  // lets open streets
     GIS->Lock() ;
     GIS->Open( GisSamplesDataDirDownload() +
                "\\World\\Countries\\USA\\States\\California\\San Bernardino\\TIGER\\tl_2008_06071_edges_trunc.shp" ) ;
     GIS->Zoom = GIS->Zoom * 5 ;
     GIS->CenterViewport( GisPoint( -117.0208, 34.0629) );

  // now create a points layer
     ll = new TGIS_LayerVector;
     ll->Path = "trackingpoints" ;
     GIS->Add( ll ) ;
     ll->Params->Labels->Allocator = false ;
     ll->CachedPaint = False ;

  // and attach to it our test police-car point
     shpPolice = ll->CreateShape( TGIS_ShapeType::Point ) ;
     shpPolice->Params->Marker->Symbol =
       SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\police.bmp?TRUE" ) ;
     shpPolice->Params->Marker->Size = -13 ;
     shpPolice->Params->Labels->OutlineWidth = 0  ;
     shpPolice->Params->Labels->Pattern      = TGIS_BrushStyle::Solid ;
     shpPolice->Params->Labels->Position     <<  TGIS_LabelPosition::DownCenter ;
     shpPolice->Params->Labels->Value        = "112" ;
     GIS->Unlock() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  GIS->Close();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnWithoutSnappingClick(TObject *Sender)
{
  btnWithoutSnapping->Enabled = false ;
  btnWithSnapping->Enabled    = false ;

  shpPolice->SetPosition( GIS->Center, NULL, 0 ) ;

  cntPoint = 0 ;
  tmrWithoutSnapping->Enabled = true ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::tmrWithoutSnappingTimer(TObject *Sender)
{
  TGIS_Point ptg;

  // to protect against circular calling
     tmrWithoutSnapping->Enabled = false ;

  // let's move in some aribtrary direction
  // normally you can read here a GPS position etc.
     ptg.X = shpPolice->Centroid().X - 0.00020  ;
     ptg.Y = shpPolice->Centroid().Y + 0.00010 ;
     // ptg.X := GIS.CS.FromWgs84( GisPoint( objGps.Longitude, objGps.Latitude ) ) ;

  // move icon over the map
     shpPolice->SetPosition( ptg, NULL, 0 ) ;

     cntPoint++ ;

  // not end? - reenable the timer
     if ( cntPoint < 120 ) { tmrWithoutSnapping->Enabled = true;}
     else {
        btnWithoutSnapping->Enabled = true ;
        btnWithSnapping->Enabled    = true ;
     };
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnWithSnappingClick(TObject *Sender)
{
  btnWithoutSnapping->Enabled = false ;
  btnWithSnapping->Enabled    = false ;

  // Let's travel from Left-dwon to Upper-right
  shpPolice->SetPosition( GIS->Center, NULL, 0 ) ;

  cntPoint = 0 ;
  tmrWithSnapping->Enabled = true ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::tmrWithSnappingTimer(TObject *Sender)
{
  TGIS_Point ptg;

  // to protect against circular calling
     tmrWithSnapping->Enabled = false ;

  // let's move in some aribtrary direction
  // normally you can read here a GPS position etc.
     ptg.X = shpPolice->Centroid().X - 0.00020  ;
     ptg.Y = shpPolice->Centroid().Y + 0.00010 ;

  // move icon over the map
     shpPolice->Lock( TGIS_Lock::Projection ) ;
     shpPolice->SetPosition( ptg,
                            (TGIS_LayerVector *)( (GIS->Items)->Items[0] ),
                            0.005 ) ;
     shpPolice->Unlock() ;
     cntPoint++ ;

  // not end? - reenable the timer
     if ( cntPoint < 120 ) { tmrWithSnapping->Enabled = true; }
     else {
        btnWithoutSnapping->Enabled = true ;
        btnWithSnapping->Enabled    = true ;
     };
}
//---------------------------------------------------------------------------
