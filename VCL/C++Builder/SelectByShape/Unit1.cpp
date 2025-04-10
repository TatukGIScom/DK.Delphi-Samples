//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to select by circle/rectangle.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------


#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include <math.h>
#include <cmath>
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
  
  GIS->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp", true );

  ll = new TGIS_LayerVector;
  ll->Params->Area->Color = TGIS_Color::Blue;
  ll->Transparency = 50;
  ll->Name = "Points";
  ll->CS = GIS->CS ;
  GIS->Add( ll );

  ll = new TGIS_LayerVector;
  ll->Params->Area->Color = TGIS_Color::Blue;
  ll->Params->Area->OutlineColor = TGIS_Color::Blue;
  ll->Transparency = 60;
  ll->Name = "Buffers";
  ll->CS = GIS->CS ;
  GIS->Add( ll );
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  
  if (Button == mbRight) {
    GIS->Mode = TGIS_ViewerMode::Zoom;
    return;
  }
  oldPos1 = Point( X, Y ) ;
  oldPos2 = Point( X, Y ) ;
  oldRadius = 0 ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  if ( GIS->Mode != TGIS_ViewerMode::Select ) return;
  if (!(Shift.Contains(ssLeft))) return ;

  if ( btnRect->Down){
    oldPos2 = Point( X, Y );
  }
  if ( btnCircle->Down ) {
    oldRadius = RoundS( (Sqrt( pow( double( oldPos1.X - X), 2 )  + pow( double( oldPos1.Y - Y), 2 ) ) ) );
  }
  GIS->Invalidate();

}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Topology     *tpl;
  TGIS_LayerVector  *ll;
  TGIS_Shape        *tmp;
  TGIS_Shape        *buf;
  TGIS_Point        ptg;
  TGIS_Point        ptg1;
  TGIS_Point        ptg2;
  double            distance;

  if ( GIS->IsEmpty ) return;

  if (Button == mbRight) {
    GIS->Mode = TGIS_ViewerMode::Select;
    return;
  }
  if (GIS->Mode != TGIS_ViewerMode::Select) return;
  if ( btnRect->Down ) {
    if ( (oldPos2.X == oldPos1.X) && (oldPos2.Y == oldPos1.Y)) return;
  }
  if ( ( btnCircle->Down ) && ( oldRadius ==0 ) ) {
    return ;
  }
  ll = (TGIS_LayerVector *)( GIS->Get("Points") );
  ll->Lock();
  tmp = ll->CreateShape( TGIS_ShapeType::Point );
  tmp->Params->Marker->Size = 0;
  tmp->Lock( TGIS_Lock::Extent );
  tmp->AddPart();

  if ( btnCircle->Down ) {
    ptg = GIS->ScreenToMap(oldPos1);
    tmp = ll->CreateShape( TGIS_ShapeType::Point );
    tmp->Params->Marker->Size = 0;
    tmp->Lock( TGIS_Lock::Extent );
    tmp->AddPart();
    tmp->AddPoint( ptg );
    tmp->Unlock();
    ll->Unlock();
    ptg1 = GIS->ScreenToMap( Point( oldPos1.X + oldRadius, Y ) );
  }

  if ( btnRect->Down ) {
    ptg = GIS->ScreenToMap(oldPos1);
    tmp->AddPoint( ptg );
    tmp->Unlock();
    ll->CreateShape( TGIS_ShapeType::Point );
    tmp->Params->Marker->Size = 0;
    tmp->Lock( TGIS_Lock::Extent );
    tmp->AddPart();
    ptg = GIS->ScreenToMap(oldPos2);
    tmp->AddPoint( ptg );
    tmp->Unlock();
    ll->Unlock();
    ptg1 = GIS->ScreenToMap( oldPos1 );
  }
  ll = (TGIS_LayerVector *)(GIS->Get("Buffers") );
  ll->RevertShapes();

  if ( btnCircle->Down ) {
    distance = ptg1.X - ptg.X ;
    tpl = new TGIS_Topology ;
    try {
      buf = tpl->MakeBuffer( tmp, distance/2, 32, True );
      buf = ll->AddShape( buf ) ;
    } __finally {
      delete tpl ;
    }
  }
  if ( btnRect->Down ) {
    ptg2 = GIS->ScreenToMap( oldPos2 );
    buf = ll->CreateShape( TGIS_ShapeType::Polygon ) ;
    buf->AddPart() ;
    buf->AddPoint( ptg1 ) ;
    buf->AddPoint( GisPoint( ptg1.X, ptg2.Y ) );
    buf->AddPoint( ptg2 );
    buf->AddPoint( GisPoint( ptg2.X, ptg1.Y ) );
  }

  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;

  if (ll == NULL) {
    GIS->InvalidateWholeMap();
    return;
  }

  ll->DeselectAll();

  GIS->InvalidateWholeMap() ;
  Memo1->Clear() ;
  Memo1->Lines->BeginUpdate() ;
  GIS->Lock() ;

  //check all shapes
  tmp = ll->FindFirst( buf->Extent, "", buf, RELATE_INTERSECT ) ;

  if (tmp == NULL) return;
  do {
    // if any has a common point with buffer mark it
    Memo1->Lines->Add( tmp->GetField( "name" ) ) ;
    tmp->IsSelected = true ;
    tmp = ll->FindNext();
  } while( tmp != NULL);
  GIS->Unlock();
  Memo1->Lines->EndUpdate();

}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode)
{
  TGIS_RendererAbstract  *rdr ;

  rdr = _renderer ;
  rdr->CanvasPen->Width   = 1 ;
  rdr->CanvasPen->Color   = TGIS_Color::FromBGR( Random( 0xFFFFFFFF ) ) ;
  rdr->CanvasPen->Style = TGIS_PenStyle::Solid ;
  rdr->CanvasBrush->Style = TGIS_BrushStyle::Clear ;

  if ( btnRect->Down ) {
    if ( (oldPos1.X == oldPos2.X) && (oldPos1.Y == oldPos2.Y) ) return;
    rdr->CanvasDrawRectangle( Rect( oldPos1.X, oldPos1.Y, oldPos2.X, oldPos2.Y) );
  }
  if ( btnCircle->Down ) {
    rdr->CanvasDrawEllipse( oldPos1.X - RoundS( oldRadius/2 ), oldPos1.Y - RoundS( oldRadius/2 ),
                            oldRadius, oldRadius);
  }
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

