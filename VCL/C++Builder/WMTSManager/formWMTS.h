//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
  WMTSManager Sample — Demonstrates Web Map Tile Service (WMTS) layer management and integration.

  Key concepts illustrated:
    - WMTS (Web Map Tile Service) standard: OGC specification for tile-based maps
    - Remote web tile servers: connecting to publicly available WMTS services
    - TGIS_LayerWMTS: dynamic tile-based raster layer for web map tiles
    - Tile caching: automatic on-disk caching of downloaded tiles
    - Server discovery: listing available WMTS services and their layers
    - Layer selection: browsing available layers from a WMTS server
    - Coordinate system handling: supporting multiple projections per server
    - Axis inversion: handling coordinate axis order differences (EPSG vs. common convention)
    - Dynamic layer loading: tiles load on-demand as user pans/zooms

  User workflow:
    1. Select a WMTS server from dropdown (OpenStreetMap, Bing, USGS, etc.)
    2. Click "Connect" to fetch server metadata and available layers
    3. Layer list populates with available map styles/variants
    4. Select desired layer from cbLayers dropdown
    5. Click "Add" to add layer to map viewer
    6. Optionally check "Invert Axis" if coordinate axis order needs reversal
    7. Map viewer automatically downloads and caches tiles

  WMTS Features:
    - Standard web tile service: 256x256 or 512x512 pixel tiles
    - Multiple projections: Web Mercator, EPSG:4326, and others
    - Layer metadata: description, attribution, supported coordinate systems
    - Tile matrix: zoom levels, tile organization, boundaries
    - Fast rendering: pre-rendered tiles from servers
    - Offline support: cached tiles available without network (when cached)

  Web servers supported:
    - OpenStreetMap (various tile providers)
    - Bing Maps (satellite, roads, hybrid)
    - USGS (topographic, imagery, etc.)
    - Natural Earth
    - Custom WMTS servers

  Key API:
    - TGIS_LayerWMTS: WMTS layer implementation
    - WMTS service discovery: fetch GetCapabilities document
    - Layer metadata parsing: extract available layers from capabilities
    - TGIS_Tokenizer: XML/token parsing for WMTS responses
    - Coordinate systems: TGIS_CsFactory for projection handling

  Configuration:
    - Server URLs: known WMTS endpoint addresses
    - Layer templates: URL templates for tile requests
    - Tile matrix sets: available zoom levels and projections
    - Coordinate axis order: EPSG vs. standard conventions
*/

//  How to provide WMTS Layer support.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef formWMTSH
#define formWMTSH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "GisFileWFS.hpp"
#include "GisFunctions.hpp"
#include "GisTypes.hpp"
#include "GisClasses.hpp"
#include "GisResource.hpp"
#include "GisLayerWMTS.hpp"
#include "GisCsSystems.hpp"
#include "GisCsFactory.hpp"
//---------------------------------------------------------------------------
class TfrmWMTS : public TForm
{
__published:	// IDE-managed Components
	TLabel *lbl5;
	TComboBox *cbLayers;
	TButton *btnAdd;
	TLabel *lbl4;
	TComboBox *cbServers;
	TButton *btnConnect;
	TCheckBox *cbInvertAxis;
	void __fastcall btnConnectClick(TObject *Sender);
	void __fastcall btnAddClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
private:	// User declarations
	TGIS_Tokenizer *tkn ;
public:		// User declarations
	__fastcall TfrmWMTS(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmWMTS *frmWMTS;
//---------------------------------------------------------------------------
#endif
