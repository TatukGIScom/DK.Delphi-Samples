//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to cut polygon.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnCuttingClick(TObject *Sender)
{
  lp = (TGIS_LayerPixel *)( (GIS->Items)->Items[0] );;
  lp->CuttingPolygon = ( TGIS_ShapePolygon *)( ll->GetShape( 1 )->CreateCopyCS( lp->CS ) ) ;
  ll->Active = False ;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_Shape *shp ;
  
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\VisibleEarth\\world_8km.jpg");
  ll = new TGIS_LayerVector ;
  ll->Name = "shape" ;
  GIS->Add( ll );

  shp = ll->CreateShape( TGIS_ShapeType::Polygon);
  shp->Lock( TGIS_Lock::Extent ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( -5, 8 ) );
  shp->AddPoint( GisPoint( 40,2 ) );
  shp->AddPoint( GisPoint( 20, -20 ) ) ;
  shp->Unlock();
}
//---------------------------------------------------------------------------

