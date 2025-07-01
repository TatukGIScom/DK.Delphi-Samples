//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to transform a shape.
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
void __fastcall TForm1::btnCutClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn  ;
  TGIS_LayerPixel *lp  ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;
  
  trn = new TGIS_TransformPolynomial ;

  trn->AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                True
               ) ;
  trn->AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn->AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 244759.524147727 ),
                2,
                True
               ) ;
  trn->AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;
  trn->CuttingPolygon = "POLYGON((421.508902077151 -320.017804154303,"
                        "518.161721068249 -223.364985163205,"
                        "688.725519287834 -210.572700296736,"
                        "864.974777448071 -254.635014836795,"
                        "896.244807121662 -335.652818991098,"
                        "894.823442136499 -453.626112759644,"
                        "823.755192878338 -615.661721068249,"
                        "516.740356083086 -607.13353115727,"
                        "371.761127596439 -533.222551928783,"
                        "340.491097922849 -456.46884272997,"
                        "421.508902077151 -320.017804154303))" ;

  trn->Prepare( TGIS_PolynomialOrder::First ) ;
  lp->Transform = trn ;
  lp->Transform->Active = true ;
  GIS->RecalcExtent() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnLoadClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn ;
  TGIS_LayerPixel *lp  ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  trn = new TGIS_TransformPolynomial ;
  trn->LoadFromFile( "satellite.jpg"
                     GIS_TRN_EXT ) ;
  lp->Transform = trn ;
  lp->Transform->Active = true ;

  GIS->RecalcExtent() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnSaveClick(TObject *Sender)
{
  TGIS_LayerPixel *lp ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;
  
  if ( lp->Transform != NULL){
    lp->Transform->SaveToFile( "satellite.jpg"
                               GIS_TRN_EXT ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnTransformClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn ;
  TGIS_LayerPixel *lp ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  trn = new TGIS_TransformPolynomial ;

  trn->AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                true
               ) ;
  trn->AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                true
               ) ;
  trn->AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 245859.524147727 ),
                2,
                true
               ) ;
  trn->AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                true
               ) ;
  trn->Prepare( TGIS_PolynomialOrder::First ) ;
  lp->Transform = trn ;
  lp->Transform->Active = true ;
  lp->SetCSByEPSG( 102748 ) ;

  GIS->RecalcExtent() ;
  GIS->FullExtent() ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "\\Samples\\Rectify\\satellite.jpg" ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y)

{
  TGIS_Point ptg ;
  String str ;

  if( GIS->IsEmpty ) return ;

  // let's locate our position on the map and display coordinates, zoom
  ptg = GIS->ScreenToMap( Point(X,Y) ) ;
  StatusBar1->SimpleText = str.sprintf( L"X : %.4f | Y : %.4f", ptg.X, ptg.Y ) ;
}
//---------------------------------------------------------------------------

