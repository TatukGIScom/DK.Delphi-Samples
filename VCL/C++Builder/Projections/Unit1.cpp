//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Projections Sample  (C++ Builder / VCL edition)
// ================================================
// Demonstrates how TatukGIS DK supports on-the-fly coordinate reprojection
// for map display in a C++ Builder VCL application.
//
// Key concepts covered:
//
//   CSProjList()
//       The global registry of all known map-projection methods (Mercator,
//       Lambert Conformal Conic, Albers, UTM, etc.).  Each entry exposes an
//       IsStandard flag and a WKT identifier string.
//
//   TGIS_CSProjectedCoordinateSystem  (heap-allocated, owned by the viewer)
//       A full CRS assembled at runtime from three building blocks:
//         - A geographic datum   (TGIS_CSGeographicCoordinateSystem, EPSG 4030)
//         - A linear unit        (TGIS_CSUnits, looked up by WKT "METER")
//         - A projection method  (TGIS_CSProjAbstract, looked up by WKT name)
//       EPSG = -1 marks it as a user-defined (temporary) CRS.
//
//   CSGeographicCoordinateSystemList()->ByEPSG(4030)
//       Returns WGS 84 unscaled — the geographic datum base used for every
//       dynamically constructed projected CRS in this sample.
//
//   GIS->CS
//       Assigning a new TGIS_CSCoordinateSystem pointer to this property
//       triggers immediate on-the-fly reprojection of all loaded layers.
//       No source data is modified or reloaded.
//
//   GIS->FullExtent()
//       Zooms the viewport to the combined bounding box of all layers,
//       recalculated in the newly assigned coordinate system.
//
// Workflow:
//   1. FormCreate populates a sorted combo box with the WKT names of all
//      "standard" projections from the global catalogue, opens the bundled
//      world map project, then applies the first projection.
//   2. cbxSrcProjectionChange builds a new projected CRS for the selected
//      projection and assigns it to GIS->CS for on-the-fly reprojection.
//
// Check project | Options | Directories if any problems arise during
// compilation (missing TatukGIS include paths).
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "math.h"
#include "assert.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//  FormCreate
// -----------------------------------------------------------------------------
// Called once when the main form is created.
//
// Responsibilities:
//   1. Build a sorted TStringList of "standard" projection names from the
//      global TatukGIS projection catalogue (CSProjList()).  "Standard" means
//      well-known and fully parameterised — filtering avoids showing partial
//      or experimental entries in the UI.
//   2. Transfer the sorted names into the combo box.
//   3. Apply the first projection before loading the project so the viewer
//      starts in a defined coordinate system.
//   4. Open the bundled world map project; GisSamplesDataDirDownload() resolves
//      the path to the TatukGIS sample data directory.
// -----------------------------------------------------------------------------
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  Integer      i   ;
  TStringList *lst ;

  // Use a temporary sorted string list so the combo box entries appear in
  // alphabetical order regardless of their order in CSProjList().
  lst = new TStringList() ;
  lst->Sorted = True ;
  __try
  {
    lst->Clear() ;
    for ( i = 0; i < CSProjList()->Count(); i++ )
    {
      // IsStandard filters out non-standard / experimental entries.
      // WKT returns the Well-Known Text identifier used as both the
      // display label and the catalogue lookup key.
      if ( (*CSProjList())[i]->IsStandard )
      {
        lst->Add( (*CSProjList())[i]->WKT ) ;
      }
    }

    // Transfer the sorted entries into the combo box.
    for (i = 0; i < lst->Count; i++ )
    {
      cbxSrcProjection->Items->AddObject( lst->Strings[i], lst->Objects[i] ) ;
    }
    cbxSrcProjection->ItemIndex = 0 ;
  }
  __finally
  {
    delete lst ;
  }

  // Apply the first projection before loading the project so the viewer
  // has a valid display CRS from the start.
  cbxSrcProjectionChange( this ) ;

  // Open the bundled world map project.
  GIS->Open( GisSamplesDataDirDownload() + "\\Samples\\Projects\\world.ttkproject" ) ;
}
//---------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//  cbxSrcProjectionChange
// -----------------------------------------------------------------------------
// Called whenever the user selects a different projection in the combo box.
//
// This function demonstrates the core on-the-fly reprojection pattern:
//   1. Resolve the geographic datum: WGS 84 unscaled, EPSG 4030.  This is a
//      datum-only CRS suitable as the base for any projected CRS.
//   2. Resolve the linear unit: Metre, by WKT name.
//   3. Resolve the projection method from the global catalogue by WKT name.
//   4. Construct a TGIS_CSProjectedCoordinateSystem combining those three
//      components.  DefaultParams() supplies sensible default values for the
//      projection parameters (e.g. central meridian = 0, standard parallels)
//      so the map renders without manual configuration.  EPSG = -1 flags the
//      CRS as user-defined rather than a registered EPSG entry.
//   5. Assign the new CRS to GIS->CS.  The viewer reprojects all loaded layers
//      in memory; no source data is modified or reloaded.
//   6. Call GIS->FullExtent() to re-zoom to the world extent in the new CRS.
//
// Lock()/Unlock() prevent intermediate repaints between the CS assignment and
// the extent reset, eliminating visual flicker.  The inner try/catch is
// intentional: some projection methods cannot represent the global extent (e.g.
// polar projections applied to world-wide data) and will throw an exception;
// the viewer is left in its last valid state when this happens.
// -----------------------------------------------------------------------------
void __fastcall TfrmMain::cbxSrcProjectionChange(TObject *Sender)
{
  String                             sproj ;
  TGIS_CSCoordinateSystem           *ocs   ;
  TGIS_CSGeographicCoordinateSystem *ogcs  ;
  TGIS_CSUnits                      *ounit ;
  TGIS_CSProjAbstract               *oproj ;

  // Retrieve the WKT name of the projection chosen by the user.
  sproj = cbxSrcProjection->Items->Strings[cbxSrcProjection->ItemIndex] ;

  // WGS 84 unscaled — the standard geographic datum base for on-the-fly CRS
  // construction without committing to a specific ellipsoid scaling.
  ogcs  = CSGeographicCoordinateSystemList()->ByEPSG( 4030 ) ;

  // Metre — the most common linear unit for projected coordinate systems.
  ounit = CSUnitsList()->ByWKT( "METER" ) ;

  // Look up the projection method object from the global catalogue.
  oproj = CSProjList()->ByWKT( sproj ) ;

  // Build a complete projected CRS dynamically.
  // EPSG = -1 : user-defined, not registered in the EPSG database.
  // "Test"    : temporary display name for this CRS.
  // DefaultParams provides canonical parameter values (central meridian,
  // standard parallels, etc.) for the projection so no manual input
  // is required.
  ocs = new TGIS_CSProjectedCoordinateSystem(
           -1, "Test",
           ogcs->EPSG, ounit->EPSG, oproj->EPSG,
           CSProjectedCoordinateSystemList()->DefaultParams( oproj->EPSG )
         );

  // Lock prevents repaints during the combined CS + extent update.
  GIS->Lock() ;
  try
  {
    try
    {
      // Assigning CS triggers on-the-fly reprojection of all layers.
      GIS->CS = ocs ;

      // Re-zoom to the full world extent expressed in the new CRS.
      GIS->FullExtent() ;
    }
    catch(Exception &exception)
    {
      // Some projection methods cannot represent the global extent.
      // Silently ignore to leave the viewer in its last valid state.
    }
  }
  __finally
  {
    GIS->Unlock() ;
  }
}
//---------------------------------------------------------------------------
