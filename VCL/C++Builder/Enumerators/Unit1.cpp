//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to add layer to the map.
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

  GIS->Add(
    GisCreateLayer(
      "world",
      GisSamplesDataDirDownload() +
      "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp"
    )
  )  ;

  GIS->FullExtent() ;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::chkDragClick(TObject *Sender)
{
  if ( chkDrag->Checked ) {
     GIS->Mode = TGIS_ViewerMode::Drag ;
  }
  else {
     GIS->Mode = TGIS_ViewerMode::Select ;
  } ;
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
void __fastcall TForm1::btnEnumerateClick(TObject *Sender)
{
  TGIS_Shape *shp ;
  Integer cnt          ;
  TGIS_LayerVectorEnumerator *loop1        ;
  TGIS_LayerVectorEnumerator *loop2     ;
  Integer max_cnt     ;
  TGIS_LayerVector *lv          ;

  max_cnt = 0 ;

  lv = ( TGIS_LayerVector *)GIS->Items->Items[ 0 ] ;

  if ( lv->FindField( "COUNT" ) < 0 )
	lv->AddField( "COUNT", TGIS_FieldType::Number, 10, 0 );

  try {

	// mark all shapes that can be affected as editable
	// to keep the layer consistent after modyfying shapes
	// also compute number of shape that can be affected

	loop1 = lv->Loop(
			   GIS->VisibleExtent, "", 0, "", True
			 )->GetEnumerator() ;
	try {
	  while ( loop1->MoveNext() ) {
		shp = loop1->Current ;

		cnt = -1 ;
		loop2 = lv->Loop(
				   shp->ProjectedExtent, "", shp, "****T", True
				 )->GetEnumerator() ;
		try {
		  while (loop2->MoveNext()) {
			cnt = cnt + 1;
		  }
		  }
		__finally
		{
		  delete loop2 ;
		} ;

		shp->MakeEditable()->SetField( "COUNT", cnt ) ;
		if (cnt > max_cnt) {
		  max_cnt = cnt ;
		} ;
	  } ;
	  }
	__finally
	  {
		delete loop1 ;
	  }
	}
  __finally
	{
	lv->Params->Labels->Field      = "COUNT" ;
	lv->Params->Render->Expression = "COUNT" ;
	lv->Params->Render->MinVal     = 1 ;
	lv->Params->Render->MaxVal     = max_cnt ;
	lv->Params->Render->StartColor = TGIS_Color::White ;
	lv->Params->Render->EndColor   = TGIS_Color::Red ;
	lv->Params->Render->Zones      = 5 ;
    lv->Params->Area->Color        = TGIS_Color::RenderColor ;
    GIS->InvalidateWholeMap() ;
  } ;
}
//---------------------------------------------------------------------------

