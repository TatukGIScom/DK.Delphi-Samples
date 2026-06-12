//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  GeoCoding Sample - C++Builder VCL (header)
//  ===========================================
//  Declares the main form class for the GeoCoding & Routing sample.
//
//  Geocoding translates a human-readable address string into geographic
//  coordinates by matching it against street-range attribute fields stored
//  in a vector layer (TGIS_Geocoding).  Routing then finds the shortest path
//  between two geocoded points using a Dijkstra graph built from the road
//  network (TGIS_ShortestPath).  Results are visualised in an in-memory
//  "RouteDisplay" layer rendered in red on top of the street map.
//
//  Key concepts shown:
//    - Loading a TatukGIS project (.ttkproject) containing a roads layer
//    - Constructing TGIS_Geocoding with TIGER/Line address-range field mappings
//    - Using TGIS_Geocoding::Parse to resolve typed addresses to coordinates
//    - Building a TGIS_ShortestPath graph with per-link-type cost modifiers
//    - Handling the LinkTypeEvent callback to classify road segments
//    - Drawing route results into a temporary TGIS_LayerVector
//
//  Data used:
//    California.ttkproject references US Census TIGER/Line street data.
//    MTFCC field codes: values >= "S1400" identify local/residential roads;
//    values below "S1400" are highways and major routes.
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <ComCtrls.hpp>
#include <DB.hpp>
#include "GisShortestPath.hpp"    // TGIS_ShortestPath — Dijkstra routing engine
#include "GisGeocoding.hpp"       // TGIS_Geocoding — address-to-coordinate resolution
#include "VCL.GisControlScale.hpp" // Scale-bar overlay control
#include "GisViewer.hpp"           // Base TatukGIS viewer class
#include "VCL.GisViewerWnd.hpp"    // VCL windowed map viewer component
#include "GisTypesUI.hpp"          // TGIS_ViewerMode, TGIS_Color, TGIS_Lock, etc.
#include "GisLayerADF.hpp"         // ArcInfo Binary Grid driver (used by some projects)

//---------------------------------------------------------------------------

/// <summary>
///   Main application form for the GeoCoding C++Builder sample.
///   Hosts a TGIS_ViewerWnd displaying California street data and provides
///   address geocoding (btnResolve) and shortest-path routing (btnRoute).
/// </summary>
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TGIS_ViewerWnd    *GIS ;              // Map viewer — renders street data and the route
    TGIS_ControlScale *GIS_ControlScale1; // Scale-bar overlay linked to the viewer
    TPanel            *Panel2 ;           // Right-hand panel hosting the controls
    TMemo             *memRoute ;         // Read-only text area for turn-by-turn directions
    TGroupBox         *GroupBox1 ;        // Groups the routing parameter controls
    TTrackBar         *trkSmallRoads ;    // Preference slider for local roads (1–10)
    TTrackBar         *trkHighways ;      // Preference slider for highways (1–10)
    TLabel            *lblSmallRoads ;    // Label for trkSmallRoads
    TLabel            *lblHighways ;      // Label for trkHighways
    TEdit             *edtAddrFrom ;      // Start address input (e.g. "Chrysler 1345")
    TButton           *btnResolve ;       // Resolve and highlight the start address on the map
    TEdit             *edtAddrTo ;        // End address input (e.g. "wash")
    TButton           *btnRoute ;         // Geocode both addresses and find the shortest route
    TLabel            *lblAddrFrom ;      // Label for edtAddrFrom
    TLabel            *lblAddrTo ;        // Label for edtAddrTo

    /// <summary>Opens the project, builds geocoding and routing objects.</summary>
    void __fastcall FormCreate(TObject *Sender);
    /// <summary>Geocodes the start address and highlights it on the map.</summary>
    void __fastcall btnResolveClick(TObject *Sender);
    /// <summary>Geocodes both addresses, finds the route, and draws it.</summary>
    void __fastcall btnRouteClick(TObject *Sender);
    /// <summary>Frees the geocoding and routing objects.</summary>
    void __fastcall FormDestroy(TObject *Sender);

private:    // User declarations
    TGIS_LayerVector  *layerSrc ;    // Source streets layer loaded from the project
    TGIS_LayerVector  *layerRoute ;  // In-memory layer for route visualisation
    TGIS_ShortestPath *rtrObj ;      // Routing engine; builds graph from layerSrc
    TGIS_Geocoding    *geoObj ;      // Geocoding engine; resolves address text to coords
    double             costFactor ;  // Reserved cost scaling factor (currently fixed at 1)

    /// <summary>
    ///   Classifies each road segment as highway (0) or local road (1).
    ///   Called by TGIS_ShortestPath for every arc during graph traversal.
    ///   MTFCC >= "S1400" identifies local/residential streets.
    /// </summary>
    void __fastcall doLinkType( TObject * _sender, TGIS_ShapeArc * _shape,
                                int &_type ) ;

public:     // User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
