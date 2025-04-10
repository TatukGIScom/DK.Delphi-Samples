//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to select several shapes
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
  TGIS_LayerVector *ll ;

  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp", true ) ;

  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
  ll->ParamsList->Add() ;
  ll->Params->Style = "selected" ;
  ll->Params->Area->OutlineWidth = 1 ;
  ll->Params->Area->Color = TGIS_Color::Blue ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point        ptg;
  TGIS_Shape        *shp;
  TGIS_Shape        *tmp_shp, *tmp2_shp;
  TGIS_LayerVector  *ll;
  Integer           i;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;

  ll = ( TGIS_LayerVector *)( GIS->Items->Items[0] );

  // let's locate a shape after click
  ptg = GIS->ScreenToMap( Point( X, Y ) );
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5 / GIS->Zoom, TRUE ) ) ; // 5 pixels precision

  if (shp != NULL) {
    shp = shp->MakeEditable() ;
    // if any found
    if (Shift.Contains(ssCtrl)) { // multiple select
      // set it as selected
      shp->IsSelected = !shp->IsSelected ;
      shp->Invalidate() ;
      lbSelected->Clear() ;

      // find a selected shape
      tmp_shp = ll->FindFirst( GisWholeWorld(), "GIS_SELECTED=True" ) ;
      // if not found clear attribute control
      if ( tmp_shp == NULL ) GIS_Attributes->Clear();

      // let's locate another one, if also found - show statistic attributes
      tmp2_shp = ll->FindNext();
      if ( tmp2_shp = NULL ) GIS_Attributes->ShowShape( tmp_shp );

      for ( int i = 0 ; i <= ll->Items->Count - 1 ; i++ ) {
        // we can do this because selected items are MakeEditable so
        // they exist on Items list
        tmp_shp = ( TGIS_Shape *)( ll->Items->Items[i] );
        // add selected shapes to list
        if ( tmp_shp->IsSelected ) {
          lbSelected->Items->Add( tmp_shp->GetField( "name" ) ) ;
        }
      }
    }
    else {
      // deselect existing
      ll->DeselectAll();
      lbSelected->Clear() ;
      lbSelected->Items->Add( shp->GetField( "name" ) ) ;
      // set as selected this clicked
      shp->IsSelected = true ;
      shp->Invalidate() ;
      // update attribute control
      GIS_Attributes->ShowShape( shp ) ;
    }
  }
  else {
    // deselect existing
    ll->DeselectAll();
    lbSelected->Clear() ;
    GIS_Attributes->Clear() ;
  }

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


