//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to perform Buffer operation.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "GisTopology.hpp"
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
  lb : TGIS_LayerVector *lb ;
  
  GIS->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology.shp", true ) ;
  lb = new TGIS_LayerVector ;
  lb->Name = "buffer" ;
  lb->Transparency = 50 ;
  lb->Params->Area->Color = TGIS_Color::Red ;
  GIS->Add( lb ) ;
  GIS->Unlock() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar1Change(TObject *Sender)
{
  TGIS_LayerVector *ll  ;
  TGIS_LayerVector *lb  ;
  TGIS_Shape       *shp ;
  TGIS_Shape       *tmp ;
  TGIS_Topology    *tpl ;
  void *p ;

  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
  if ( ll == NULL ) return ;
  lb = (TGIS_LayerVector *)( GIS->Get( "buffer" ) ) ;
  if ( lb == NULL ) return ;
  shp = ll->GetShape( 2 ) ;
  if ( shp == NULL ) return ;

  tpl = new TGIS_Topology ;
  try {
    lb->RevertShapes() ;
    tmp = tpl->MakeBuffer( shp, TrackBar1->Position * 1000 ) ;
    if ( tmp ) {
       lb->AddShape( tmp, False ) ;
       delete tmp ;
    }
    ll->RecalcExtent() ;
    lb->RecalcExtent() ;
    GIS->RecalcExtent() ;
    GIS->FullExtent() ;
  }
  __finally {
    delete tpl ;
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnPlusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position + 1 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnMinusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position - 1 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Point ptg ;
  TGIS_Shape *shp ;

  if ( GIS->InPaint ) return ;

  if (GIS==NULL) {
    return ;
  }
  
  ptg = GIS->ScreenToMap( Point(X, Y) );
  shp = ( TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom ) ); //5 pixels precision

  //remember id to use buffer on selected shape
  if (shp != NULL) {
    shp_id = shp->Uid ;
    shp->Flash();
  }
}
//---------------------------------------------------------------------------

