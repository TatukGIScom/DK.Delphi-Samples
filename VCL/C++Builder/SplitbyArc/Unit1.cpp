//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to split shapes by arc.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include <stdlib.h>

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
  GIS->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology3.shp", true );

  layerPolygon = ( TGIS_LayerVector *)( (GIS->Items)->Items[0] );
  shpPolygon = ( TGIS_ShapePolygon *)( layerPolygon->GetShape( 1 )->MakeEditable() ) ;
  if ( shpPolygon == NULL ) return;

  layerArc = new TGIS_LayerVector ;       //create layer for line
  layerArc->Params->Line->Color = TGIS_Color::Red;
  layerArc->Params->Line->Width = 25;
  if ( layerArc == NULL ) return;
  GIS->Add( layerArc );

  layerArc = ( TGIS_LayerVector *)( (GIS->Items)->Items[1] );
  shpArc = ( TGIS_ShapeArc *)( layerArc->CreateShape( TGIS_ShapeType::Arc ) );
  if ( shpArc == NULL ) return;
  shpArc->AddPart() ;

  layerObj = new TGIS_LayerVector;      //create layer for new shapes - after split
  layerObj->Name = "Splits" ;
  GIS->Add( layerObj );

  GIS->Unlock() ;
  GIS->FullExtent() ;
  GIS->RestrictedExtent = GIS->Extent;

}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnLineClick(TObject *Sender)
{
  layerObj->RevertShapes() ;        //clear layer with new polygons
  shpArc->Reset();               //clear line
  shpArc->AddPart() ;            //initiate for new points
  lbInfo->Caption = "...";
  GIS->InvalidateWholeMap();
  btnSplit->Enabled = false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnSplitClick(TObject *Sender)
{
  TGIS_ObjectList   *shape_list;
  TGIS_Topology     *topology_obj;
  TGIS_Shape        *shp;

  layerObj->RevertShapes() ;
  topology_obj = new TGIS_Topology;
  try {
    shape_list = topology_obj->SplitByArc(shpPolygon, shpArc, true);
    if ( shape_list != NULL ) {
     lbInfo->Caption = IntToStr( shape_list->Count ) ;
     randomize() ;
     for ( int n = 0 ; n <= shape_list->Count - 1 ; n++) {
       shp = ( TGIS_Shape *)( shape_list->Items[ n ] );
       shp->Params->Area->Color = TGIS_Color::FromRGB( random( 255 ) * 256 * 256 + random( 255 ) * 256 + random( 256 ) );
       layerObj->AddShape( ( TGIS_Shape *)shape_list->Items[ n ] , false ) ;
     }
     //  if (shape_list) delete shape_list;
     // fix for improper generated destructors for Delphi generics
     FreeObjectNotNil( shape_list ) ;
    }
  }
  __finally {
    if (topology_obj) delete topology_obj;
  }

  GIS->InvalidateWholeMap() ;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{ //add point to line
  TGIS_Point ptg;

  if ( GIS->IsEmpty ) return;

  ptg = GIS->ScreenToMap( Point( X, Y ) );
  shpArc->Lock( TGIS_Lock::Extent ) ;
  shpArc->AddPoint( ptg );
  shpArc->Unlock();
  GIS->InvalidateWholeMap();
  if (shpArc->Intersect( shpPolygon )) btnSplit->Enabled = true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseUp(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{//
  TGIS_Point ptg;

  if ( GIS->IsEmpty ) return;

  ptg = GIS->ScreenToMap( Point( X, Y ) );
  shpArc->Lock( TGIS_Lock::Extent ) ;
  shpArc->AddPoint( ptg );
  shpArc->Unlock();
  GIS->InvalidateWholeMap();
  if (shpArc->Intersect( shpPolygon )) btnSplit->Enabled = true;
}
//---------------------------------------------------------------------------
