//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to override OnPaintShapeLabel.
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
  TGIS_LayerSHP *ll ;

  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp" ;
  ll->Name = "counties" ;
  ll->Params->Labels->Position << TGIS_LabelPosition::MiddleCenter << TGIS_LabelPosition::Flow ;
  ll->PaintShapeLabelEvent = PaintLabel ;
  GIS->Add(ll) ;

  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::PaintLabel( TObject * _sender, TGIS_Shape * _shape )
{
  String sname = _shape->GetField("NAME") ;
  String spopulation = FloatToStr( (Double)_shape->GetField("POPULATION") ) ;

  _shape->Layer->Params->Labels->Value =
    "My:<BR><B>" + sname  +  "</B><BR><U>"+ spopulation + "</U>" ;
  _shape->DrawLabel();
}

//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------





