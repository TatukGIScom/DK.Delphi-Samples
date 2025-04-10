//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to rotate the map.
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
  TGIS_LayerSHP *ll;
  // clear rotation angle
  GIS->RotationAngle = 0 ;

  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" );

  // show layers in the viewer and set a rotation point in central point of extent
  GIS->FullExtent() ;
  GIS->Zoom = GIS->Zoom * 2  ;
  GIS->RotationPoint = GisCenterPoint( GIS->Extent ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->RecalcExtent();
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

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  rotationTB->Position = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  // if clicked change a rotation point and move viewport
  if ( GIS->IsEmpty ) return;
  
  GIS->RotationPoint = GIS->ScreenToMap( Point( X, Y ) );

  if (CheckBox1->Checked) GIS->Center = GIS->ScreenToMap( Point( X, Y ) );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  // show coordinates
  TGIS_Point ptg;
  TGIS_Shape *shp;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;
  
  ptg = GIS->ScreenToMap( Point(X, Y ) );
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ; // 5 picels precision
  if (shp == NULL)
    StatusBar1->Panels->Items[1]->Text = "";
  else {
    StatusBar1->Panels->Items[1]->Text = shp->GetField("name");
  }
}
//---------------------------------------------------------------------------


void __fastcall TForm1::increaseBtnClick(TObject *Sender)
{
  rotationTB->Position = rotationTB->Position + 1 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::decreaseBtnClick(TObject *Sender)
{
  rotationTB->Position = rotationTB->Position - 1 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::rotationTBChange(TObject *Sender)
{
  GIS->RotationAngle = DegToRad( 1.0* (rotationTB->Position) ) ;
  GIS->InvalidateWholeMap();
  degLabel->Caption = "Degree: " + IntToStr( rotationTB->Position ) ;
}
//---------------------------------------------------------------------------

