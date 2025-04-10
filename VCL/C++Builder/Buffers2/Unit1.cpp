//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
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
  int i  ;
  TGIS_LayerAbstract *la ;
  TGIS_LayerVector   *lb ;
  GIS->Lock() ;
  la = GisCreateLayer(
          "counties",
          GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp"
        ) ;
  GIS->Add( la ) ;

  lb = new TGIS_LayerVector ;
  lb->Name = "buffer" ;
  lb->Transparency = 70 ;
  lb->Params->Area->Color = TGIS_Color::Yellow ;
  GIS->Add( lb ) ;
  GIS->Unlock() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
  TGIS_LayerVector *ll  ;
  TGIS_LayerVector *lb  ;
  TGIS_Shape       *shp ;
  TGIS_Shape       *tmp ;
  TGIS_Shape       *buf ;
  TGIS_Topology    *tpl ;

  Timer1->Enabled = False ;

  try {
    // find buffer for vistual river
    ll = (TGIS_LayerVector *)( GIS->Get( "counties" ) ) ;
    if ( ll == NULL ) return ;
    lb = (TGIS_LayerVector *)( GIS->Get( "buffer" ) ) ;
    if ( lb == NULL ) return ;

    shp = ll->FindFirst( GisWholeWorld(), "NAME='Merced'", NULL, "", true );

    if ( shp == NULL ) return ;

    tpl = new TGIS_Topology ;
    try {
      lb->RevertShapes() ;
      tmp = tpl->MakeBuffer( shp, TrackBar1->Position / 100.0 ) ;
      if ( tmp ) {
        buf = lb->AddShape( tmp ) ;
        delete tmp ;
      }
      else
        buf = NULL ;
    }
    __finally
    {
      delete tpl ;
    } ;


    // find all states crossing by buffer of Vistula river
    if ( buf == NULL ) return ;

    ll = (TGIS_LayerVector *)( GIS->Get( "counties" ) ) ;
    if ( ll == NULL ) return ;
    ll->RevertShapes() ;
    ll->IgnoreShapeParams = False ;
    Memo1->Clear() ;
    Memo1->Lines->BeginUpdate() ;

    tmp = ll->FindFirst( buf->Extent );
    while ( tmp ) {
      if ( buf->IsCommonPoint( tmp ) ) {
        tmp = tmp->MakeEditable() ;
        Memo1->Lines->Add( tmp->GetField( "NAME" )  ) ;
        tmp->Params->Area->Color = TGIS_Color::Blue ;
      }
      tmp = ll->FindNext() ;
    }
    Memo1->Lines->EndUpdate() ;
  }
  __finally {
    GIS->InvalidateWholeMap() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar1Change(TObject *Sender)
{
  Timer1->Enabled = False ;
  StatusBar1->SimpleText = IntToStr( TrackBar1->Position ) + "km" ;
  Timer1->Enabled = True ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnPlusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position + 5 ;
  Timer1Timer( Sender ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnMinusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position - 5 ;
  Timer1Timer( Sender ) ;
}
//---------------------------------------------------------------------------




