//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"

// Macro to round an integer
#define round(a) int((a)+0.5)
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlAttributes"
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisControlNorthArrow"
#pragma link "VCL.GisControlScale"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnOpenClick(TObject *Sender)
{
  GIS->Open( "..\\data\\world.shp");
}
//---------------------------------------------------------------------------

// button "Zoom" click event
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;
}
//---------------------------------------------------------------------------

// button "Drag" click event
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------

// button "Select" click event
void __fastcall TForm1::btnSelectClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------


void __fastcall TForm1::btnCreateShapeClick(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_LayerVector *lv ;

  // lets find if such layer already exists
  ll = ( TGIS_LayerVector *)( GIS->Get( "edit layer" ) );
  if( ll != NULL ){
	return;
  }

  // create a new layer and add it to the viewer
  ll = new TGIS_LayerVector();
  ll->Name = "edit layer" ;
  ll->CS = GIS->CS ; // same coordinate system as a viewer

  // in a previous sample we created a solid polygon
  // to make it nicer we need it to be transparent

  ll->Params->Area->OutlineColor = TGIS_Color::Blue ;
  ll->Params->Area->Pattern = TGIS_BrushStyle::Clear ;
  GIS->Add( ll );

  // create a new shape and immediately add it to the layer
  // create a shape and add it to polygon
  shp = ll->CreateShape( TGIS_ShapeType::Polygon ) ;

  // we group operation together
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ; // shape can have multiple parts like islands, holes

  // add some veritices
  shp->AddPoint( TGIS_Utils::GisPoint( 10, 10 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 10, 80 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 80, 90 ) );
  shp->AddPoint( TGIS_Utils::GisPoint( 90, 10 ) );

  shp->Unlock() ; // unlock operation, close shape if necessary

  // and now refresh map
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnRelationClick(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_Shape *selshp ;
  TGIS_LayerVector *lv ;
  TGIS_Shape *tmpshp ;
  TGIS_LayerVectorEnumerator *loop1 ;

  // lets find if such layer already exists
  ll = ( TGIS_LayerVector *)( GIS->Get( "edit layer") );
  if( ll == NULL ){
	return ;
  }

  // and we need a created shape, with we want
  // to use as selection shape
  selshp = ll->GetShape(1); // just a first shape form the layer

  // for file based layer we should pin shape to memory
  // otherwise it should be discarded
  selshp = selshp->MakeEditable() ;


  // lets get a layer with world shape
  // names are constructed based on layer name
  lv = ( TGIS_LayerVector *)( GIS->Get( "world" ) );

  // deselect all shapes on the map
  lv->DeselectAll();
  // so now we search for all shapes with DE9_IM relationship
  // in this case we will fine "T*****FF*" contains relationship
  GIS->Lock();
  // be careful on specific syntax for loop in c++
  loop1 = lv->Loop( selshp->Extent, "label LIKE 's%'", selshp, "T*****FF*" )->GetEnumerator();
  while (loop1->MoveNext()) {
	tmpshp = loop1->Current ;
	tmpshp->IsSelected = True ;
  }
  GIS->Unlock();
  // and now refresh map
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISTapSimpleEvent(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Shape *shp ;
  TGIS_Point ptg ;
  Double precision ;
  TGIS_LayerVector *lv ;

  // ignore clicking if mode is other then select
  if ( GIS->Mode != TGIS_ViewerMode::Select ){
	return;
  }

  lv = ( TGIS_LayerVector *)( GIS->Get("world") );
  if (lv == NULL) {
	return;
  }
  //deselect all shapes on the layer
  lv->DeselectAll();
  // convert screen coordinates to map coordinates
  ptg = GIS->ScreenToMap( Point( round(X), round(Y) ) );

  // calculate precision of location as 5 pixels
  precision = 5 / GIS->Zoom ;


  // let's try to locate a selected shape on the map
  shp = ( TGIS_Shape *)( GIS->Locate( ptg, precision ) );

  // not found?
  if( shp == NULL ){
   return ;
  }

  // mark shape as selected
  shp->IsSelected = !(shp->IsSelected) ;

  // and refresh a map
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

