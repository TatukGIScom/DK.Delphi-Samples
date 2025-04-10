//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to transform shape.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TransformSelectedShape(
                TGIS_Shape *shape,
                double xx,
                double yx,
                double xy,
                double yy,
                double dx,
                double dy )
{
  TGIS_Point centroid ;

  if( shape == NULL ) return ;

  centroid = shape->Centroid();

  // transform
  // x' = x*xx + y*xy + dx
  // y' = x*yx + y*yy + dx
  // z' = z
  shape->Transform( GisPoint3DFrom2D( centroid ),
                   xx, yx, 0,
                   xy, yy, 0,
                    0,  0, 1,
                   dx, dy, 0,
                   False
                  );
  GIS->InvalidateTopmost();
}

// rotate
void __fastcall TForm1::RotateSelectedShape(TGIS_Shape *shape, double angle)
{
  TransformSelectedShape(
    shape,
     Cos(angle), Sin(angle),
    -Sin(angle), Cos(angle),
             0 ,        0
  );
}

// scale
void __fastcall TForm1::ScaleSelectedShape(TGIS_Shape *shape, double x_value, double y_value)
{
  TransformSelectedShape(
    shape,
     x_value ,        0  ,
           0 ,   y_value ,
           0 ,        0
  );
}

// translate
void __fastcall TForm1::TranslateSelectedShape( TGIS_Shape *shape, double x_value, double y_value)
{
  TransformSelectedShape(
    shape,
         1 ,         0 ,
         0 ,         1 ,
    x_value,   y_value
  );
}

void __fastcall TForm1::FormCreate( TObject *Sender)
{
  curShape = NULL ;
  edtShape = NULL ;
  handleMouseMove = false ;
  pgc1->ActivePageIndex = 2 ;
  lblSelected->Caption = "Select shape on the map to start transform" ;
  
  GIS->Lock() ;
  GIS->Open( GisSamplesDataDirDownload() + "Samples\\3D\\buildings.shp");
  
  edtLayer = new TGIS_LayerVector() ;
  edtLayer->CS =  GIS->CS ;
  edtLayer->CachedPaint = false ; // make tracking layer
  edtLayer->Params->Area->Pattern = TGIS_BrushStyle::Clear ;
  edtLayer->Params->Area->OutlineColor = TGIS_Color::Red ;
  GIS->Add( edtLayer );
  
  GIS->Unlock() ;
  GIS->Zoom = GIS->Zoom * 4 ;
}

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg ;

  if ( edtShape == NULL ) return ;

  // rotate
  if ( handleMouseMove ) {

    ptg = GIS->ScreenToMap( Point( X, Y ) ) ;

    if ( pgc1->ActivePageIndex == 0 )
      RotateSelectedShape(edtShape, DegToRad(1.0*((X - prevX)*(Y - prevY)))) ;
	else if ( pgc1->ActivePageIndex == 1 )
	{
	  if ((prevX != 0) && (prevY != 0))
		 ScaleSelectedShape(edtShape, X / ( prevX * 1.0)  , Y / ( prevY *1.0 )) ;
	}
	else
	  TranslateSelectedShape( edtShape, (ptg.X - prevPtg.X), (ptg.Y - prevPtg.Y) );

	prevPtg.X = ptg.X ;
    prevPtg.Y = ptg.Y ;
    prevX     = X ;
    prevY     = Y ;
  }
}

void __fastcall TForm1::GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Shape *shp  ;
  TGIS_Point ptg  ;
  AnsiString str ;

  lblSelected->Caption = "No selected shape";

  // if there is no layer or we are not in select mode, exit
  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;
  
  if ( GIS->Mode != TGIS_ViewerMode::Select ) return ;

  if ( curShape != NULL ){
	curShape->CopyGeometry( edtShape );
	edtLayer->RevertAll() ;
	curShape = NULL ;
	edtShape = NULL;
    GIS->InvalidateWholeMap() ;
	handleMouseMove = false;
    if ( pgc1->ActivePageIndex == 2 )
      lblSelected->Caption = "Select shape to start moving." ;
    else if ( pgc1->ActivePageIndex == 1 )
      lblSelected->Caption = "Select shape to start scaling." ;
    else
      lblSelected->Caption = "Select shape to start rotating." ;

    return;
  }

  ptg = GIS->ScreenToMap( Point( X, Y ) )  ;
  // let's try to locate a selected shape on the map
  shp = ( TGIS_Shape *)( GIS->Locate( ptg, (5.0/GIS->Zoom ) ) ) ;
  if ( shp == NULL )
    return ;

  curShape = shp->MakeEditable() ;
  
  edtShape = edtLayer->AddShape( curShape->CreateCopy() ) ;
  

  lblSelected->Caption = str.sprintf( "Selected shape : %d. Click to commit changes.",
                                 curShape->Uid
                                ) ;
  prevPtg.X = ptg.X;
  prevPtg.Y = ptg.Y;
  prevX     = X ;
  prevY     = Y ;

  handleMouseMove = !handleMouseMove;
}

void __fastcall TForm1::GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  TPoint pt;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  GIS->ZoomBy( 9./8., pt.X, pt.Y );

  Handled = true ;
}

void __fastcall TForm1::GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  TPoint pt ;

  if ( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  GIS->ZoomBy( 8./9., pt.X, pt.Y );

  Handled = true ;
}

void __fastcall TForm1::pgc1Changing(TObject *Sender, bool &AllowChange)
{
  handleMouseMove = False;
}
//---------------------------------------------------------------------------

