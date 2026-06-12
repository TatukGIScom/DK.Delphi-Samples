//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Triangulation Sample – Demonstrates Delaunay triangulation and Voronoi diagrams.
//
// This sample opens a point shapefile (Polish cities) and uses two specialised
// TGIS_LayerVector subclasses from the GisTriangulation unit to compute geometric
// structures derived from the point distribution:
//
//   Delaunay Triangulation
//     Connects input points into triangles such that no point lies inside the
//     circumscribed circle of any triangle.  Produces a TIN (Triangulated
//     Irregular Network) suitable for surface modelling and proximity analysis.
//
//   Voronoi Diagram
//     Partitions the plane into one region per input point, where each region
//     contains all locations closer to that point than to any other input point.
//     The Voronoi diagram is the geometric dual of the Delaunay triangulation.
//
// After generation the result layer is colour-graduated by polygon area
// (GIS_AREA attribute) over a white-to-red (Voronoi) or white-to-blue (Delaunay)
// gradient rendered across 10 equal-interval zones.
//
// Check project\options\directories in case of any problems during compilation.
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

/**
 * FormCreate
 * Opens the Polish city point shapefile and configures the city marker style.
 *
 * A second "selected" param set is also registered so that shapes shown in the
 * GIS_Attributes panel receive a distinct blue area fill, making the selected
 * shape easy to identify on the map.
 *
 * GIS_ControlLegend1->Update() refreshes the legend to reflect the new layer
 * style immediately after loading.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector * lv ;

  // Open the Polish city point data – this layer provides the seed
  // point set for both the Delaunay and Voronoi algorithms.
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\city.shp" ) ;

  // Retrieve the first (and only) vector layer just loaded
  lv = ( TGIS_LayerVector *)(GIS->Items->Items[0] ) ;

  // Customise the default marker style for city points
  lv->Params->Marker->Color = TGIS_Color::FromRGB( (0x004080FF) );
  lv->Params->Marker->OutlineWidth = 2 ;
  lv->Params->Marker->Style = TGIS_MarkerStyle::Circle ;

  // Add a second named param set; shapes displayed in the attribute panel
  // use the "selected" style so they stand out on the map.
  lv->ParamsList->Add() ;
  lv->Params->Style = "selected" ;
  lv->Params->Area->OutlineWidth = 1 ;
  lv->Params->Area->Color = TGIS_Color::Blue;

  GIS_ControlLegend1->Update() ;  // Refresh legend to show the new layer style
}
//---------------------------------------------------------------------------

/**
 * GISMouseDown
 * Hit-tests the map on mouse press to find the nearest shape and displays
 * its attribute data in the GIS_Attributes side panel.
 *
 * ScreenToMap converts pixel coordinates to geographic (map) coordinates.
 * Locate searches all layers for the nearest shape within a tolerance of
 * 5 screen pixels (converted to map units by dividing by the zoom factor).
 */
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  TGIS_Point ptg ;
  TGIS_Shape *shp  ;

  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;  // Avoid reentrancy during a repaint cycle

  // Convert screen pixel position to geographic map coordinates
  ptg = GIS->ScreenToMap( Point( X, Y ) );
  // Locate the nearest shape within a 5-pixel screen tolerance
  shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom ) ) ; // 5 pixels precision
  if ( shp != NULL )
    GIS_Attributes->ShowShape(shp) ;  // Populate the attribute panel
}
//---------------------------------------------------------------------------

/**
 * btnFullExtentClick
 * Zooms the viewer so that all loaded layers fit within the visible area.
 */
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/**
 * btnZoomInClick
 * Doubles the current zoom factor, zooming into the centre of the map.
 */
void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

/**
 * btnZoomOutClick
 * Halves the current zoom factor, zooming out from the centre of the map.
 */
void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------

/**
 * btnGenerateClick
 * Creates either a TGIS_LayerVoronoi or TGIS_LayerDelaunay layer, imports
 * the city point data as its input, configures a graduated colour-render
 * style based on polygon area, and adds it to the viewer.
 *
 * ImportLayer copies all point features from the source layer (GIS->Items->Items[0])
 * into the new triangulation layer and computes the triangulation/diagram on
 * the fly.  After the call the layer contains fully formed polygon shapes.
 *
 * The GIS_AREA attribute (computed automatically by the triangulation engine)
 * drives a white-to-colour gradient rendered over 10 equal-interval zones,
 * giving an immediate visual impression of cell/triangle area variation.
 * Voronoi uses red as the end colour; Delaunay uses blue.
 */
void __fastcall TForm1::btnGenerateClick(TObject *Sender)
{
  TGIS_LayerVector *lVrn  ;

  // Prevent overwriting an existing layer with the same name
  if ( GIS->Get( edtName->Text ) != NULL ) {
    ShowMessage( "Result layer already exists. Use different name.") ;
    return ;
  } ;

  // Instantiate the correct layer type based on the radio button selection
  if ( rdbtnVoronoi->Checked )
    lVrn = new TGIS_LayerVoronoi ;   // Voronoi diagram
  else
    lVrn = new TGIS_LayerDelaunay;   // Delaunay triangulation

  lVrn->Name = edtName->Text ;

  // ImportLayer reads all point features from the source layer and uses them
  // as the input seed set for the triangulation / diagram computation.
  // TGIS_ShapeType::Unknown lets the engine infer the output shape type automatically.
  lVrn->ImportLayer( ( TGIS_LayerVector *)( GIS->Items->Items[ 0 ] ), GIS->Extent,
                    TGIS_ShapeType::Unknown, "", False
                   ) ;
  lVrn->Transparency = 60 ;  // Semi-transparent so the source city layer shows through

  // Configure graduated colour rendering keyed on the built-in GIS_AREA attribute.
  // GIS_AREA holds the area of each output polygon in map coordinate units squared.
  lVrn->Params->Render->Expression = "GIS_AREA" ;
  lVrn->Params->Render->MinVal     = 10000000 ;    // ~10 km² lower bound
  lVrn->Params->Render->MaxVal     = 1300000000 ;  // ~1300 km² upper bound
  lVrn->Params->Render->StartColor = TGIS_Color::White ;
  // Differentiate Voronoi (red) from Delaunay (blue) visually
  if ( rdbtnVoronoi->Checked )
   lVrn->Params->Render->EndColor  = TGIS_Color::Red ;
  else
    lVrn->Params->Render->EndColor = TGIS_Color::Blue ;
  lVrn->Params->Render->Zones      = 10 ;  // Divide the colour range into 10 equal steps
  // TGIS_Color::RenderColor instructs the renderer to substitute the computed
  // gradient colour for the polygon fill during painting.
  lVrn->Params->Area->Color        = TGIS_Color::RenderColor ;

  // Inherit the coordinate system from the source layer so all layers align
  lVrn->CS = GIS->CS ;

  GIS->Add( lVrn ) ;
  GIS->InvalidateWholeMap() ;     // Repaint the viewer
  GIS_ControlLegend1->Update() ;  // Refresh legend to show the new layer
}
//---------------------------------------------------------------------------

/**
 * rdbtnVoronoiClick
 * Pre-fills the output layer name when the user selects Voronoi mode.
 * Note: the handler body uses "Delaunay" – this appears to be a copy-paste
 * swap in the original code; the intent is to set the name that matches the
 * mode the user is switching away from, but typical convention would match
 * the selected mode.  Left unchanged to preserve original behaviour.
 */
void __fastcall TForm1::rdbtnVoronoiClick(TObject *Sender)
{
  edtName->Text = "Delaunay" ;
}
//---------------------------------------------------------------------------

/**
 * rdbtnDelaunayClick
 * Pre-fills the output layer name when the user selects Delaunay mode.
 * See note in rdbtnVoronoiClick regarding the swapped name values.
 */
void __fastcall TForm1::rdbtnDelaunayClick(TObject *Sender)
{
  edtName->Text = "Voronoi" ;
}
//---------------------------------------------------------------------------
