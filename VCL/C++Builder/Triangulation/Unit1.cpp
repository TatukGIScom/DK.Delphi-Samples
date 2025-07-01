//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
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
  TGIS_LayerVector * lv ;
  // open a file
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\city.shp" ) ;
  lv = ( TGIS_LayerVector *)(GIS->Items->Items[0] ) ;
  lv->Params->Marker->Color = TGIS_Color::FromRGB( (0x004080FF) );
  lv->Params->Marker->OutlineWidth = 2 ;
  lv->Params->Marker->Style = TGIS_MarkerStyle::Circle ;
  lv->ParamsList->Add() ;
  lv->Params->Style = "selected" ;
  lv->Params->Area->OutlineWidth = 1 ;
  lv->Params->Area->Color = TGIS_Color::Blue;

  GIS_ControlLegend1->Update() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg ;
  TGIS_Shape *shp  ;

  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;

  // let's locate a shape after click
  ptg = GIS->ScreenToMap( Point( X, Y ) );
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom ) ) ; // 5 pixels precision
  if ( shp != NULL )
    GIS_Attributes->ShowShape(shp) ;
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


void __fastcall TForm1::btnGenerateClick(TObject *Sender)
{
  TGIS_LayerVector *lVrn  ;

  if ( GIS->Get( edtName->Text ) != NULL ) {
    ShowMessage( "Result layer already exists. Use different name.") ;
    return ;
  } ;

  if ( rdbtnVoronoi->Checked )
    lVrn = new TGIS_LayerVoronoi ;
  else
    lVrn = new TGIS_LayerDelaunay;

  lVrn->Name = edtName->Text ;
  lVrn->ImportLayer( ( TGIS_LayerVector *)( GIS->Items->Items[ 0 ] ), GIS->Extent,
                    TGIS_ShapeType::Unknown, "", False
                   ) ;
  lVrn->Transparency = 60 ;

  lVrn->Params->Render->Expression = "GIS_AREA" ;
  lVrn->Params->Render->MinVal     = 10000000 ;
  lVrn->Params->Render->MaxVal     = 1300000000 ;
  lVrn->Params->Render->StartColor = TGIS_Color::White ;
  if ( rdbtnVoronoi->Checked )
   lVrn->Params->Render->EndColor  = TGIS_Color::Red ;
  else
    lVrn->Params->Render->EndColor = TGIS_Color::Blue ;
  lVrn->Params->Render->Zones      = 10 ;
  lVrn->Params->Area->Color        = TGIS_Color::RenderColor ;
  lVrn->CS = GIS->CS ;

  GIS->Add( lVrn ) ;
  GIS->InvalidateWholeMap() ;
  GIS_ControlLegend1->Update() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rdbtnVoronoiClick(TObject *Sender)
{
  edtName->Text = "Delaunay" ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rdbtnDelaunayClick(TObject *Sender)
{
  edtName->Text = "Voronoi" ;
}
//---------------------------------------------------------------------------

