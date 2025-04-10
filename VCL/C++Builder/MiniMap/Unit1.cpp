//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to build minimap.
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

//defines for minimap
#define MINIMAP_R_NAME  "minimap_rect"
#define MINIMAP_O_NAME  "minimap_rect_outline"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void _fastcall TForm1::miniMapRefresh(TObject *Sender)
{
  TGIS_Point  ptg1 ;
  TGIS_Point  ptg2 ;
  TGIS_Point  ptg3 ;
  TGIS_Point  ptg4 ;
  TGIS_Extent ex   ;

  if ( GIS->IsEmpty ) return ;

  ex = GISm->CS->ExtentFromCS( GIS->CS, GIS->VisibleExtent ) ;
  ex = GIS->UnrotatedExtent( ex ) ;

  if ( ( ex.XMin < -360 ) &&
       ( ex.XMax >  360 ) &&
       ( ex.YMin < -180 ) &&
       ( ex.YMax >  180 )
     )
    return ;

  ptg1 = GisPoint( ex.XMin, ex.YMin ) ;
  ptg2 = GisPoint( ex.XMax, ex.YMin ) ;
  ptg3 = GisPoint( ex.XMax, ex.YMax ) ;
  ptg4 = GisPoint( ex.XMin, ex.YMax ) ;

  minishp->Reset() ;
  minishp->Lock( TGIS_Lock::Extent ) ;
    minishp->AddPart() ;
    minishp->AddPoint( ptg1 );
    minishp->AddPoint( ptg2 );
    minishp->AddPoint( ptg3 );
    minishp->AddPoint( ptg4 );
  minishp->Unlock() ;

  minishpo->Reset() ;
  minishpo->Lock( TGIS_Lock::Extent ) ;
    minishpo->AddPart() ;
    minishpo->AddPoint( ptg1 );
    minishpo->AddPoint( ptg2 );
    minishpo->AddPoint( ptg3 );
    minishpo->AddPoint( ptg4 );
    minishpo->AddPoint( ptg1 );
  minishpo->Unlock() ;

  GISm->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom / 2;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnSelectClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector *llm ;
  TGIS_LayerVector *lv  ;
  TGIS_LayerVector *lw  ;

  GIS->Lock() ;
  GISm->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;

  GIS->SetCSByEPSG( 2180 );

  llm = ( TGIS_LayerVector * )GisCreateLayer(
           "country",
           GisSamplesDataDirDownload() +
           "\\World\\Countries\\Poland\\DCW\\country.shp"
        ) ;
  llm->UseConfig = False ;
  llm->Params->Area->Color = TGIS_Color::White ;
  llm->Params->Area->OutlineColor = TGIS_Color::Silver ;
  GISm->Add( llm ) ;
  llm->CachedPaint = False ;

  lv = new TGIS_LayerVector ;    //minimap transparent rectangle
  lv->Transparency = 30 ;
  lv->Params->Area->Color = TGIS_Color::Red ;
  lv->Params->Area->OutlineWidth = -2 ;
  lv->Name = MINIMAP_R_NAME;
  lv->CS = llm->CS ;
  GISm->Add(lv);
  lv->CachedPaint = False ;

  minishp = (( TGIS_LayerVector *)( GISm->Get(MINIMAP_R_NAME) ))->CreateShape( TGIS_ShapeType::Polygon );
  lw = new TGIS_LayerVector ;
  lw->Params->Line->Color = TGIS_Color::Maroon ;
  lw->Params->Line->Width = -2 ;
  lw->Name = MINIMAP_O_NAME;
  lw->CS = llm->CS ;
  GISm->Add( lw );
  minishpo = (( TGIS_LayerVector *)( GISm->Get(MINIMAP_O_NAME) ))->CreateShape( TGIS_ShapeType::Arc );
  lw->CachedPaint = False ;

  GISm->FullExtent() ;
  GIS->FullExtent() ;

  GISm->RestrictedExtent = GISm->Extent ;
  minishp->Layer->Extent = GISm->Extent ;
  GISm->Cursor = crDrag;
  GIS->Unlock() ;
  GISm->Unlock() ;
  fminiMove = false;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point ptg;
  AnsiString str;

  if ( GIS->IsEmpty ) return;

  ptg = GIS->ScreenToMap( Point( X, Y ) );
  StatusBar1->SimpleText = str.sprintf( "x: %.2f   y: %.2f", ptg.X, ptg.Y ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISVisibleExtentChange(TObject *Sender)
{
  TGIS_Extent ex;
  AnsiString  str;

  ex  = GIS->VisibleExtent;
  lP1 = GisPoint( ex.XMin, ex.YMin ) ;
  lP2 = GisPoint( ex.XMax, ex.YMin ) ;
  lP3 = GisPoint( ex.XMax, ex.YMax );
  lP4 = GisPoint( ex.XMin, ex.YMax );
  lbP1->Caption = str.sprintf( "P1 : x: %.2f   y: %.2f", lP1.X, lP1.Y ) ;
  lbP2->Caption = str.sprintf( "P2 : x: %.2f   y: %.2f", lP2.X, lP2.Y ) ;
  lbP3->Caption = str.sprintf( "P3 : x: %.2f   y: %.2f", lP3.X, lP3.Y ) ;
  lbP4->Caption = str.sprintf( "P4 : x: %.2f   y: %.2f", lP4.X, lP4.Y ) ;
  miniMapRefresh( this );
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;
  miniMapRefresh( this );
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISmMouseUp(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg;
  TGIS_Point p1,p2,p3,p4;

  ptg = GISm->ScreenToMap( Point( X, Y ) );

  minishp->SetPosition( ptg, NULL, 1 );

  GISm->InvalidateWholeMap() ;
  fminiMove = false;

  p1 = minishp->GetPoint(0,0);
  p2 = minishp->GetPoint(0,1);
  p3 = minishp->GetPoint(0,2);
  p4.X = p1.X + (p2.X - p1.X)/2;
  p4.Y = p1.Y + (p3.Y - p2.Y)/2;
  GIS->Center = GISm->CS->ToCS( GIS->CS, p4 ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISmMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point ptg;

  if ( (!fminiMove) && (!(Shift.Contains(ssCtrl))) ) return;
  ptg = GISm->ScreenToMap( Point( X, Y ) );
  minishp->SetPosition( ptg, NULL, 1 );
  GISm->InvalidateWholeMap() ;

  if (Shift.Contains(ssCtrl)) GISmMouseUp( Sender, TMouseButton(0), Shift, X, Y );
  if ( Shift.Contains( ssShift )) {
    fminiMove = True ;
    GISmMouseUp( Sender, TMouseButton( 0 ), Shift, X, Y ) ;
  }

  }
//---------------------------------------------------------------------------
void __fastcall TForm1::GISmMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  if ( GIS->IsEmpty ) return;

  if ( Button == mbRight ) return;
  fminiMove = true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::colorRClick(TObject *Sender)
{
  TGIS_LayerVector *lv;

  if ( !dlgColor->Execute() ) return;
  lv = ( TGIS_LayerVector * )( GISm->Get( MINIMAP_R_NAME ) );
  lv->Params->Area->Color = TGIS_Color::FromBGR( dlgColor->Color ) ;
  GISm->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::colorOClick(TObject *Sender)
{
  TGIS_LayerVector *lv;

  if ( !dlgColor->Execute() ) return;
  lv = ( TGIS_LayerVector * )( GISm->Get( MINIMAP_O_NAME ) );
  lv->Params->Line->Color = TGIS_Color::FromBGR ( dlgColor->Color );
  GISm->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------
