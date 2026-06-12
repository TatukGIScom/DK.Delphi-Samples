//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  GeoCoding Sample - C++Builder VCL
//  ===================================
//  Demonstrates address geocoding and shortest-path routing using TatukGIS DK.
//
//  Geocoding translates a human-readable address string (e.g. "Chrysler 1345")
//  into geographic coordinates by matching it against street-range fields stored
//  in a vector layer.  The TGIS_Geocoding class performs this matching entirely
//  on the client side using the loaded shapefile — no external service is needed
//  (unless OSM online routing is enabled).
//
//  Routing finds the shortest path between two geocoded points via TGIS_ShortestPath,
//  which builds a Dijkstra graph from the road network.  The path segments are
//  visualised by copying them into a separate in-memory "RouteDisplay" layer
//  rendered in red, with green/red point markers for start and end positions.
//
//  Key concepts shown:
//    - Opening a TatukGIS project (.ttkproject) and accessing a named layer
//    - Constructing TGIS_Geocoding with TIGER/Line address-range field mappings
//    - Using TGIS_Geocoding::Parse to resolve typed text to coordinates
//    - Building a TGIS_ShortestPath graph with per-link-type cost modifiers
//    - Handling the LinkTypeEvent callback to classify road segments by MTFCC code
//    - Drawing route results and address markers into a TGIS_LayerVector overlay
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"  // Uncomment and configure if using a licensed build
#include "MainForm.h"
#include <typeinfo>
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

/// <summary>
///   Classifies a road segment as highway (link type 0) or local road (link type 1).
///
///   The US Census MTFCC code "S1400" and higher identify local/residential
///   streets, service roads, and alleys.  Codes below "S1400" are interstates,
///   US routes, state routes, and other major roads.
///
///   The routing engine multiplies each segment's base cost by CostModifiers[type].
///   A slider value of 10 for highways (CostModifiers[0] ≈ 0) makes highways
///   essentially free, routing the path onto them preferentially.
/// </summary>
void __fastcall TForm1::doLinkType( TObject * _sender, TGIS_ShapeArc * _shape,
                         int &_type )
{
  if ( _shape->GetField( "MTFCC" ) >= "S1400" ) {
    // MTFCC >= "S1400" → local/residential road
    _type = 1 ;
  }
  else {
    // MTFCC < "S1400" → highway or major road
    _type = 0 ;
  }
}
//---------------------------------------------------------------------------

/// <summary>
///   Called when the form is created.
///   Opens the California street project, creates the route-display overlay
///   layer, and initialises the geocoding and routing engines.
/// </summary>
/// <remarks>
///   GIS->Lock() / GIS->Unlock() suppress intermediate redraws during batch
///   setup — the standard DK pattern for multi-step viewer modifications.
/// </remarks>
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Lock() ;

  // Open the TatukGIS project file which references California street data.
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\California.ttkproject" ) ;

  // Retrieve the streets layer by name so the geocoding and routing engines
  // can operate on it directly.
  layerSrc = (TGIS_LayerVector *)( GIS->Get( "streets" ) ) ;

  if (layerSrc == NULL) return ;
  if ( !layerSrc->InheritsFrom( __classid(TGIS_LayerVector) ) ) return ;

  // Set the initial view to the full extent of the street network.
  GIS->VisibleExtent = layerSrc->ProjectedExtent ;

  // ------------------------------------------------------------------
  // Create an in-memory overlay layer for route visualisation.
  // UseConfig = False prevents the DK from writing a style file.
  // Red line, 2-pixel width (negative = device pixels).
  // ------------------------------------------------------------------
  layerRoute = new TGIS_LayerVector ;
  layerRoute->UseConfig = False ;
  layerRoute->Params->Line->Color = TGIS_Color::Red ;
  layerRoute->Params->Line->Width = -2 ;
  layerRoute->Params->Marker->OutlineWidth = 1 ;
  layerRoute->Name = "RouteDisplay" ;
  layerRoute->CS = GIS->CS ;  // Must share the viewer's coordinate system
  GIS->Add( layerRoute ) ;

  // ------------------------------------------------------------------
  // Configure the geocoding engine with TIGER/Line field mappings.
  //   Offset    — distance along the segment to offset the geocoded point
  //               from the road node, avoiding exact node placement.
  //   RoadName  — attribute field containing the full street name.
  //   LFrom/LTo — address number range, left side of the street.
  //   RFrom/RTo — address number range, right side of the street.
  // ------------------------------------------------------------------
  geoObj = new TGIS_Geocoding( layerSrc ) ;
  geoObj->Offset   = 0.0001 ;
  geoObj->RoadName = "FULLNAME" ;
  geoObj->LFrom    = "LFROMADD" ;
  geoObj->LTo      = "LTOADD" ;
  geoObj->RFrom    = "RFROMADD" ;
  geoObj->RTo      = "RTOADD" ;

  costFactor = 1 ;  // Placeholder for future cost scaling

  // ------------------------------------------------------------------
  // Configure the routing engine.
  //   LoadTheData builds the Dijkstra graph from all arc shapes.
  //   LinkTypeEvent classifies each segment; RoadName labels route steps.
  // ------------------------------------------------------------------
  rtrObj = new TGIS_ShortestPath( *GIS ) ;
  rtrObj->LinkTypeEvent = doLinkType ;
  rtrObj->LoadTheData( layerSrc ) ;
  rtrObj->RoadName = "FULLNAME" ;

  GIS->Unlock() ;

  // Display the scale bar in miles (EPSG 9035).
  GIS_ControlScale1->Units = CSUnitsList()->ByEPSG( 9035 ) ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Resolves the address in edtAddrFrom against the streets layer and
///   highlights all matching segments on the map.
///
///   If matches are found, the corresponding street shapes are copied to
///   layerRoute (red) and a green marker is placed at each geocoded point.
///   The view then zooms to the result set.  "???" is appended if no match
///   is found.
/// </summary>
void __fastcall TForm1::btnResolveClick(TObject *Sender)
{
  int i ;
  int r ;
  TGIS_Shape *shp ;

  if ( geoObj == NULL ) return ;

  // Clear any previously displayed route or address highlights.
  layerRoute->RevertShapes() ;

  // Parse returns the number of matching candidates; subtract 1 for the
  // last valid array index.  If no match, append "???" to indicate failure.
  r = geoObj->Parse( edtAddrFrom->Text, true, true ) - 1 ;
  if ( r <= 0 ) edtAddrFrom->Text = edtAddrFrom->Text + " ???" ;

  for (i = 0; i <= r; i++) {
    // Update the text box to show the canonical name of each matched street.
    edtAddrFrom->Text = geoObj->Query[i] ;
    Application->ProcessMessages() ;  // Allow the UI to refresh between results

    // Copy the primary matched segment to the route display layer.
    shp = layerSrc->GetShape( geoObj->Uid[i] ) ;
    layerRoute->AddShape( shp, False ) ;
    if (i == 0)
      layerRoute->Extent = shp->ProjectedExtent ;  // Seed the bounding extent

    // Add the secondary (adjacent/complementary) segment if available.
    shp = layerSrc->GetShape( geoObj->UidEx[i] ) ;
    if ( shp )
      layerRoute->AddShape( shp ) ;

    // Place a green marker at the geocoded point coordinate.
    // Lock/Unlock brackets shape modification to maintain internal extent.
    shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Extent ) ;
      shp->AddPart() ;
      shp->AddPoint( geoObj->Point[i] ) ;
      shp->Params->Marker->Color = TGIS_Color::Green ;
    shp->Unlock() ;
  }

  // Zoom to the matched results, pulling back slightly for context.
  GIS->Lock() ;
    GIS->VisibleExtent = layerRoute->ProjectedExtent ;
    GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Geocodes both addresses, computes the shortest route between them,
///   and displays the result as a red path with turn-by-turn directions.
///
///   Cost modifiers derived from the highway/local-road sliders are applied
///   before routing so the user can tune road-type preference at runtime.
///
///   The Compass property encodes the turn direction: 0 = straight,
///   1..3 = right turns, 4 = U-turn, -1..-3 = left turns, -4 = left U-turn.
///   Consecutive steps on the same named street are merged in the directions.
/// </summary>
void __fastcall TForm1::btnRouteClick(TObject *Sender)
{
  int         i ;
  TGIS_Shape *shp ;
  int         res ;
  TGIS_Point  pt_a ;
  TGIS_Point  pt_b ;
  String      ang ;
  String      oldnam ;

  // Apply slider-derived cost modifiers.
  // CostModifiers[0] = highway cost; CostModifiers[1] = local-road cost.
  // Formula maps slider 1..10 to multiplier 1.0..~0.09 (lower = cheaper = preferred).
  rtrObj->CostModifiers[0] = 1.0 - 1.0/11 * trkHighways->Position ;
  rtrObj->CostModifiers[1] = 1.0 - 1.0/11 * trkSmallRoads->Position ;

  // Geocode the start address.
  res = geoObj->Parse( edtAddrFrom->Text ) ;
  if ( res > 0 ) edtAddrFrom->Text = geoObj->Query[0] ;
  else           edtAddrFrom->Text = edtAddrFrom->Text + " ???" ;

  if (res <= 0) return ;    // Abort if start address not resolved
  pt_a = geoObj->Point[0] ; // Geocoded start coordinate

  // Geocode the end address.
  res = geoObj->Parse( edtAddrTo->Text ) ;
  if (res > 0) edtAddrTo->Text = geoObj->Query[0] ;
  else         edtAddrTo->Text = edtAddrTo->Text + " ???" ;

  if (res <= 0) return ;    // Abort if end address not resolved
  pt_b = geoObj->Point[0] ; // Geocoded end coordinate

  // UpdateTheData refreshes the graph (e.g. after data edits).
  // Find computes the shortest path; Unproject converts viewer coords to layer coords.
  rtrObj->UpdateTheData() ;
  rtrObj->Find( layerRoute->Unproject( pt_a ), layerRoute->Unproject( pt_b ) ) ;

  // Build the turn-by-turn directions text.
  memRoute->Lines->BeginUpdate() ;
  memRoute->Clear() ;
  oldnam = "#$@3eqewe" ;  // Sentinel value to detect the first direction step

  for (i = 0; i <= rtrObj->ItemsCount - 1; i++) {
    // Convert numeric Compass value to a direction abbreviation.
    switch ( rtrObj->Items[i]->Compass ) {
      case  0 : ang = "FWD  " ; break ;
      case  1 : ang = "RIGHT" ; break ;  // Slight right
      case  2 : ang = "RIGHT" ; break ;  // Right
      case  3 : ang = "RIGHT" ; break ;  // Sharp right
      case  4 : ang = "BACK " ; break ;  // U-turn
      case -1 : ang = "LEFT " ; break ;  // Slight left
      case -2 : ang = "LEFT " ; break ;  // Left
      case -3 : ang = "LEFT " ; break ;  // Sharp left
      case -4 : ang = "BACK " ; break ;  // Left U-turn
    }

    // Skip consecutive segments with the same street name to reduce clutter.
    if ( oldnam == rtrObj->Items[i]->Name ) continue ;
    oldnam = rtrObj->Items[i]->Name ;

    memRoute->Lines->Add( ang + " " + rtrObj->Items[i]->Name ) ;
  }
  memRoute->Lines->EndUpdate() ;

  // Repopulate the route display layer with the computed path segments.
  layerRoute->RevertShapes() ;

  for (i = 0; i <= rtrObj->ItemsCount - 1; i++) {
    shp = rtrObj->Items[i]->Layer->GetShape( rtrObj->Items[i]->Uid ) ;
    if ( shp == NULL ) continue ;
    layerRoute->AddShape( shp, False ) ;
    if (i == 0)
      layerRoute->Extent = shp->Extent ;  // Seed the bounding extent
  }

  // Place a green marker at the start point.
  shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
    shp->AddPart() ;
    shp->AddPoint( pt_a ) ;
    shp->Params->Marker->Color = TGIS_Color::Green ;
  shp->Unlock() ;

  // Place a red (default colour) marker at the end point.
  shp = layerRoute->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Extent ) ;
    shp->AddPart() ;
    shp->AddPoint( pt_b ) ;
  shp->Unlock() ;

  // Zoom to the route bounding box, pulling back slightly for context.
  GIS->Lock() ;
    GIS->VisibleExtent = layerRoute->Extent ;
    GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock() ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Frees the geocoding and routing engine objects when the form is destroyed.
///   layerRoute is owned by the viewer (added via GIS->Add) and is freed
///   automatically when the viewer is destroyed.
/// </summary>
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete geoObj ;
  delete rtrObj ;
}
//---------------------------------------------------------------------------
