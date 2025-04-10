//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to compute relations beetwen two shapes.
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
  // open project
  GIS->Open(GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology2.shp", true);

  // set style params
  ((TGIS_LayerVector *)( GIS->Items->Items[0]))->ParamsList->Add();
  ((TGIS_LayerVector *)( GIS->Items->Items[0]))->Params->Style = "selected";
  ((TGIS_LayerVector *)( GIS->Items->Items[0]))->Params->Area->OutlineWidth = 1;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg;
  TGIS_Shape *shp;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;

  // let's locate a shape after click
  ptg = GIS->ScreenToMap( Point(X, Y ) );
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE ) ) ; // 5 pixels precision
  if (shp == NULL) return;

  shp = shp->MakeEditable() ;

  if (Button == mbLeft) {
    // if selected shapeA, deselect it
    if ( shpA != NULL )
    {
      shpA->Params->Area->Color = TGIS_Color::Gray;
      shpA->Params->Labels->Value = "";
      shpA->Invalidate();
      ShapeA->Caption = "Unselected";
    }
    shpA = shp;
    shpA->Params->Area->Color = TGIS_Color::Blue;
    shpA->Params->Labels->Value = "Shape A";
    shpA->Params->Labels->Position <<  TGIS_LabelPosition::UpLeft ;
    shpA->Invalidate();
    ShapeA->Caption = "Selected";
  }

  if (Button == mbRight) {
    // if selected shapeB, deselect it
    if ( shpB != NULL )
    {
      shpB->Params->Area->Color = TGIS_Color::Gray;
      shpB->Params->Labels->Value = "";
      shpB->Invalidate();
      ShapeB->Caption = "Unselected";
    }
    shpB = shp;
    shpB->Params->Area->Color = TGIS_Color::Red;
    shpB->Params->Labels->Value = "Shape B";
    shpB->Params->Labels->Position <<  TGIS_LabelPosition::UpLeft ;
    shpB->Invalidate();
    ShapeB->Caption = "Selected";
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnCheckClick(TObject *Sender)
{
  Relations->Lines->Clear();
  if ((shpA == NULL) || (shpB == NULL)) return;

  // check all relations
  if (shpA->Relate(shpB,RELATE_EQUALITY))       Relations->Lines->Add("EQUALITY");
  if (shpA->Relate(shpB,RELATE_DISJOINT))       Relations->Lines->Add("DISJOINT");
  if (shpA->Relate(shpB,RELATE_INTERSECT))      Relations->Lines->Add("INTERSECT");
  if (shpA->Relate(shpB,RELATE_INTERSECT1))     Relations->Lines->Add("INTERSECT1");
  if (shpA->Relate(shpB,RELATE_INTERSECT2))     Relations->Lines->Add("INTERSECT2");
  if (shpA->Relate(shpB,RELATE_INTERSECT3))     Relations->Lines->Add("INTERSECT3");
  if (shpA->Relate(shpB,RELATE_WITHIN))         Relations->Lines->Add("WITHIN");
  if (shpA->Relate(shpB,RELATE_CROSS))          Relations->Lines->Add("CROSS");
  if (shpA->Relate(shpB,RELATE_CROSS_LINE))     Relations->Lines->Add("CROSS_LINE");
  if (shpA->Relate(shpB,RELATE_TOUCH))          Relations->Lines->Add("TOUCH");
  if (shpA->Relate(shpB,RELATE_TOUCH_INTERIOR)) Relations->Lines->Add("TOUCH_INTERIOR");
  if (shpA->Relate(shpB,RELATE_CONTAINS))       Relations->Lines->Add("CONTAINS");
  if (shpA->Relate(shpB,RELATE_OVERLAP))        Relations->Lines->Add("OVERLAP");
  if (shpA->Relate(shpB,RELATE_OVERLAP_LINE))   Relations->Lines->Add("OVERLAP_LINE");
}
//---------------------------------------------------------------------------

