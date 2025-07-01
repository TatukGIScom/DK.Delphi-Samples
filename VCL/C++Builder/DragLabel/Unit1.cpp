//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to construct draggable labels
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

void TForm1::synchroMove( TGIS_Shape *_shp, int _x, int _y )
{
  TGIS_LayerVector *ll ;
  TGIS_Shape  *shp  ;
  TGIS_Point   ptgA ;
  TGIS_Point   ptgB ;
  TGIS_Extent  ex   ;

  // move main shape
    ptgA = _shp->GetPoint( 0, 0 ) ;
    ptgA.X = ptgA.X + _x ;
    ptgA.Y = ptgA.Y + _y ;
    _shp->SetPosition( ptgA , NULL, 0 ) ;

  // move "sidekick"
    ll = (TGIS_LayerVector *)( GIS->Get("sidekicks") ) ;
    shp = ll->GetShape( _shp->Uid ) ;
    ptgB = shp->GetPoint( 0, 0 ) ;
    ptgB.X = ptgB.X + _x ;
    ptgB.Y = ptgB.Y + _y ;
    shp->SetPosition( ptgB , NULL, 0 ) ;

  // additional invalidation - we have now a big combo shape
    ex.XMin = Min( ptgA.X, ptgB.X ) ;
    ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
    ex.XMax = Max( ptgA.X, ptgB.X ) ;
    ex.YMax = Max( ptgA.Y, ptgB.Y ) ;

}

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  int i ;
  TGIS_Shape *shp  ;

  shp = ((TGIS_LayerVector *)( GIS->Get("realpoints") ))->GetShape( 5 ) ;
  for (i=0; i<=90; i++) {
    synchroMove( shp, 2, 1 ) ;
    Sleep( 100 ) ;
    Application->ProcessMessages() ;
  } ;
}

void __fastcall  TForm1::doLabelPaint( TObject * _sender, TGIS_Shape * _shape )
{
  TPoint ptA, ptB ;
  TGIS_LayerVector *ll ;
  TGIS_Shape *shp ;
  TGIS_RendererAbstract *rdr ;

  // draw line to real point
     ll = (TGIS_LayerVector *)( GIS->Get("realpoints") );
     shp = ll->GetShape( _shape->Uid ) ;
     ptA = _shape->Viewer->Ref->MapToScreen( shp->GetPoint( 0, 0 ) ) ;
     ptB = _shape->Viewer->Ref->MapToScreen( _shape->GetPoint( 0, 0 ) ) ;

     rdr = GIS->Renderer ;
     rdr->CanvasPen->Color = TGIS_Color::Blue ;
     rdr->CanvasPen->Style = TGIS_PenStyle::Solid;
     rdr->CanvasPen->Width = 1 ;
     rdr->CanvasDrawLine( ptA.x, ptA.y, ptB.x, ptB.y );

  // draw label itself
     _shape->Params->Labels->Value = shp->GetField("name") ;
     _shape->DrawLabel() ;
}

//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_LayerVector  *ll  ;
  TGIS_Shape        *shp ;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint)  return ;

  
  // start editing of some shape from sidekicks
     ll = (TGIS_LayerVector *)( GIS->Get("sidekicks") );
     if (!GIS->InPaint)  
       shp = ll->Locate( GIS->ScreenToMap( Point(X,Y) ), 100/GIS->Zoom, TRUE ) ;
     else
       return;
     currShape = shp ;

     if ( currShape == NULL ) return ;

  // we are not changing the GIS.Mode to TGIS_ViewerMode.Edit because we want to control
  // editing on our own, so instead we will call MouseBegin, MouseMove and MouseUp
  // "manually"
     GIS->Editor->MouseBegin( Point(X,Y), True );

}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  currShape = NULL ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_LayerVector  *ll  ;
  TGIS_Shape        *shp ;
  TGIS_Point  ptgA ;
  TGIS_Point  ptgB ;
  TGIS_Extent ex   ;

  if ( GIS->IsEmpty ) return;
  if ( currShape == NULL ) return;

  // additional invalidation - we have now a big combo shape
     ptgA = currShape->GetPoint( 0, 0 ) ;
     ll  = (TGIS_LayerVector *)( GIS->Get("realpoints") );
     shp = ll->GetShape( currShape->Uid ) ;
     ptgB = shp->GetPoint( 0, 0 ) ;
     ex.XMin = Min( ptgA.X, ptgB.X ) ;
     ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
     ex.XMax = Max( ptgA.X, ptgB.X ) ;
     ex.YMax = Max( ptgA.Y, ptgB.Y ) ;

  ptgA = GIS->ScreenToMap( Point(X,Y) ) ;
  if ( GisIsPointInsideExtent( ptgA, GIS->Extent ) )
    currShape->SetPosition( ptgA, NULL, 0 );

  // additional invalidation - we have now a big combo shape
     ptgA = currShape->GetPoint( 0, 0 ) ;
     ll  = (TGIS_LayerVector *)( GIS->Get("realpoints") );
     shp = ll->GetShape( currShape->Uid ) ;
     ptgB = shp->GetPoint( 0, 0 ) ;
     ex.XMin = Min( ptgA.X, ptgB.X ) ;
     ex.YMin = Min( ptgA.Y, ptgB.Y ) ;
     ex.XMax = Max( ptgA.X, ptgB.X ) ;
     ex.YMax = Max( ptgA.Y, ptgB.Y ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll  ;
  int                i   ;
  TGIS_Shape        *shp ;
  TGIS_Point         ptg ;

  // create real point layer
     ll = new TGIS_LayerVector ;
     ll->Params->Marker->Symbol = SymbolList()->Prepare( GisSamplesDataDirDownload() + "\\Symbols\\2267.cgm" ) ;
     ll->Name = "realpoints" ;
     ll->CachedPaint = False ;

     GIS->Add( ll ) ;
     ll->AddField( "name", TGIS_FieldType::String, 100, 0 );
     ll->Extent = GisExtent( -180, -180, 180, 180 ) ;

  // create display sidekick
     ll = new TGIS_LayerVector ;
     ll->Name = "sidekicks" ;
     ll->Params->Marker->Size = 0 ;
     ll->Params->Labels->Position <<  TGIS_LabelPosition::MiddleCenter ;
     ll->CachedPaint = False ;

     GIS->Add( ll ) ;
     ll->PaintShapeLabelEvent = doLabelPaint ;
     ll->Params->Labels->Allocator = False ;

  GIS->FullExtent() ;


  // add points
     for (i=0; i<=20; i++) {
       ptg = GisPoint( random( 360 ) - 180 , random( 180 ) - 90 ) ;

       // add a real point
          shp = ((TGIS_LayerVector *)( GIS->Get("realpoints") ) )->CreateShape( TGIS_ShapeType::Point ) ;
          shp->Lock( TGIS_Lock::Extent ) ;
          shp->AddPart() ;
          shp->AddPoint( ptg );
          shp->Params->Marker->SymbolRotate = shp->Uid ;
          shp->Params->Marker->Size = 250 ;
          shp->Params->Marker->Color = TGIS_Color::FromRGB((random(256) << 16) + (random( 256 ) <<  8) + random ( 256 ) );

          shp->SetField( "name", Format( "Ship: %d", OPENARRAY(TVarRec, ( shp->Uid) ) ) );
          shp->Unlock() ;

       // add sideckicks
          shp = ((TGIS_LayerVector *)( GIS->Get("sidekicks") ) )->CreateShape( TGIS_ShapeType::Point ) ;
          shp->Lock( TGIS_Lock::Extent ) ;
          shp->AddPart() ;

          // with a small offset
          ptg.X = ptg.X + 15/GIS->Zoom ;
          ptg.Y = ptg.Y + 15/GIS->Zoom ;
          shp->AddPoint( ptg );
          shp->Unlock() ;
     }

  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------


