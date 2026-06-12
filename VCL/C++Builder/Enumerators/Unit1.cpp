/*
 * Enumerators sample — demonstrates using TGIS_LayerVector::Loop() enumerators to compute
 * the neighbor count for every shape in a polygon layer.
 *
 * Loads the California Counties shapefile.  Clicking "Enumerate" runs btnEnumerateClick: an outer
 * Loop() visits every county while an inner Loop(extent, "", shape, "****T", true) counts
 * topologically adjacent neighbors using the DE-9IM "T" filter.  Each county's neighbor count is
 * written to a COUNT field via MakeEditable, then the layer is rendered as a 5-zone white-to-red
 * color ramp keyed on that field.
 */
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

/* Loads the California Counties shapefile and fits the viewer to its full extent. */
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
/* Toggles the viewer between Drag and Select mode. */
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
/* Resets the viewer to the full map extent. */
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------
/* Doubles the current zoom level. */
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------
/* Halves the current zoom level. */
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
   GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------
/* Counts topological neighbors for every county and renders the result as a 5-zone white-to-red
   color ramp.  The COUNT field is added if it does not yet exist.  Uses nested Loop() enumerators:
   outer loop visits every county, inner loop uses Loop() with DE-9IM "****T" filter to find
   adjacent neighbors (touching boundary). */
void __fastcall TForm1::btnEnumerateClick(TObject *Sender)
{
  TGIS_Shape *shp ;
  Integer cnt          ;
  TGIS_LayerVectorEnumerator *loop1        ;
  TGIS_LayerVectorEnumerator *loop2     ;
  Integer max_cnt     ;
  TGIS_LayerVector *lv          ;

  /* Initialize maximum neighbor count. */
  max_cnt = 0 ;

  /* Get the vector layer (counties). */
  lv = ( TGIS_LayerVector *)GIS->Items->Items[ 0 ] ;

  /* Create a COUNT field to store the neighbor count for each shape
     (only create if it doesn't already exist). */
  if ( lv->FindField( "COUNT" ) < 0 )
	lv->AddField( "COUNT", TGIS_FieldType::Number, 10, 0 );

  try {

	/* Iterate through each county polygon in the layer. */
	loop1 = lv->Loop(
			   GIS->VisibleExtent, "", 0, "", True
			 )->GetEnumerator() ;
	try {
	  while ( loop1->MoveNext() ) {
		/* Get the current shape (county). */
		shp = loop1->Current ;

		/* Initialize neighbor count to -1 (will be incremented for each neighbor found). */
		cnt = -1 ;
		/* Use Loop() with the DE-9IM "****T" predicate to find topologically adjacent shapes.
		   The "T" in the predicate means the boundaries must touch. */
		loop2 = lv->Loop(
				   shp->ProjectedExtent, "", shp, "****T", True
				 )->GetEnumerator() ;
		try {
		  /* Count each topologically adjacent neighbor. */
		  while (loop2->MoveNext()) {
			cnt = cnt + 1;
		  }
		  }
		__finally
		{
		  delete loop2 ;
		} ;

		/* Make the shape editable and store the neighbor count in the COUNT field. */
		shp->MakeEditable()->SetField( "COUNT", cnt ) ;
		/* Track the maximum neighbor count for color ramp scaling. */
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
	/* Configure labels to display the COUNT field value for each county. */
	lv->Params->Labels->Field      = "COUNT" ;
	/* Use the COUNT field for color rendering. */
	lv->Params->Render->Expression = "COUNT" ;
	lv->Params->Render->MinVal     = 1 ;
	/* Set the maximum value based on the highest neighbor count found. */
	lv->Params->Render->MaxVal     = max_cnt ;
	/* Create a white-to-red color gradient (low neighbor count = white, high = red). */
	lv->Params->Render->StartColor = TGIS_Color::White ;
	lv->Params->Render->EndColor   = TGIS_Color::Red ;
	/* Divide the color range into 5 discrete zones for clearer visualization. */
	lv->Params->Render->Zones      = 5 ;
    /* Apply the gradient color to polygon fill. */
    lv->Params->Area->Color        = TGIS_Color::RenderColor ;
    /* Repaint the map to display the neighbor count colors. */
    GIS->InvalidateWholeMap() ;
  } ;
}
//---------------------------------------------------------------------------

