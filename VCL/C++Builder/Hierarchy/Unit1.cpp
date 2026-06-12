//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * Hierarchy sample implementation — demonstrates TGIS_Hierarchy for organizing layers into groups.
 *
 * Creates a hierarchical layer structure with nested groups, assigns layers to groups, moves groups
 * between parents, and parses a hierarchy from an INI format string. Uses TGIS_ControlLegend to
 * display the resulting hierarchy as a tree view.
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

/* Button1Click
   Demonstrates hierarchical layer organization using TGIS_Hierarchy.

   Steps:
   1. Load the Poland project containing multiple layers (Cities, Rivers, Lakes, etc.).
   2. Clear any previous hierarchy and set legend to Groups display mode.
   3. Create a flat "My group" and add half the layers to it.
   4. Create nested groups: Root → Leaf → node, with node containing the city1 layer.
   5. Create a Poland hierarchy with nested structure:
      - Poland/Waters: containing Lakes and Rivers
      - Poland/Areas: containing city and Country area layers
   6. Add ungrouped layers to the root level via AddOtherLayers().
   7. Parse a hierarchy from INI format strings (alternative to programmatic creation).
   8. Refresh the legend display and zoom to full extent. */
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  IGIS_HierarchyGroup *group  ;
  Integer i    ;
  TStrings *list  ;

  /* Close any previously loaded project and reset the viewer. */
  GIS->Close() ;
  /* Set the legend to Groups display mode so the hierarchy is shown as a tree structure
     with expandable/collapsible groups instead of a flat list. */
  GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Groups ;

  /* Load the Poland project which contains multiple layers: Cities, Rivers, Lakes, etc.
     The second parameter (False) means do not use the saved project's hierarchy configuration. */
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", False ) ;

  /* Remove all existing groups from the hierarchy (start fresh). */
  GIS->Hierarchy->ClearGroups() ;

  /* --- Demonstrate flat group creation and layer assignment --- */
  /* Create a top-level group named "My group". */
  group = GIS->Hierarchy->CreateGroup( "My group" ) ;

  /* Add the first half of all layers to "My group". */
  for (i = 0 ; i<((int)(GIS->Items->Count / 2 ) - 1) ;i++ )
    group->AddLayer(GIS->Items->Items[i] ) ;

  /* Remove the same layers from "My group" (demonstrates DeleteLayer). */
  for ( i = 0 ; i<(GIS->Items->Count / 2 )- 1 ;i++ )
    group->DeleteLayer(GIS->Items->Items[i] ) ;

  /* --- Demonstrate nested group creation --- */
  /* Create a "Root" group at the top level. */
  group = GIS->Hierarchy->CreateGroup( "Root" ) ;
  /* Create "Leaf" as a sub-group of Root (nesting). */
  group->CreateGroup( "Leaf" ) ;

  /* Access the "Leaf" group by name, create a "node" sub-group inside it, and add the city1 layer.
     This creates a three-level hierarchy: Root → Leaf → node (containing city1). */
  GIS->Hierarchy->Groups["Leaf"]->CreateGroup("node")->AddLayer( GIS->Get( "city1") ) ;

  /* Move the "My group" group to be a child of "Root" (reparenting).
     Now Root contains both Leaf and My group as sub-groups. */
  GIS->Hierarchy->MoveGroup( "Root", "My group" ) ;

  /* --- Demonstrate complex nested hierarchies --- */
  /* Create a top-level "Poland" group. */
  group = GIS->Hierarchy->CreateGroup("Poland") ;
  /* Create a "Waters" sub-group inside Poland and add related layers. */
  group = group->CreateGroup("Waters") ;
  group->AddLayer( GIS->Get( "Lakes") ) ;
  group->AddLayer( GIS->Get( "Rivers") ) ;

  /* Access the Poland group and create an "Areas" sub-group, adding city and country area layers. */
  group = GIS->Hierarchy->Groups["Poland"]->CreateGroup("Areas") ;
  group->AddLayer( GIS->Get( "city") ) ;
  group->AddLayer( GIS->Get( "Country area") ) ;

  /* Add any layers not yet assigned to a group to the top level via AddOtherLayers(). */
  GIS->Hierarchy->AddOtherLayers() ;

  /* --- Demonstrate hierarchy parsing from INI format --- */
  /* Create a string list with INI-format hierarchy definitions:
     "Poland\\Waters=Lakes;Rivers" means:
       - Create Poland group, create Waters sub-group, assign Lakes and Rivers layers to it.
     "Poland\\Areas=city;Country area" means:
       - In the existing Poland group, create Areas sub-group, assign city and Country area to it. */
  list = new TStringList;
  try
  {
    list->Add( "Poland\\Waters=Lakes;Rivers" ) ;
    list->Add( "Poland\\Areas=city;Country area" ) ;

    /* Clear the manually-built hierarchy and parse the INI-format list instead. */
    GIS->Hierarchy->ClearGroups() ;
    /* ParseHierarchy deserializes the INI text and reconstructs the hierarchy from it. */
    GIS->Hierarchy->ParseHierarchy( list, TGIS_ConfigFormat::Ini ) ;
  }
  __finally
  {
    delete list;
  };

  /* Refresh the legend display to show the new hierarchy structure. */
  GIS_ControlLegend->Update() ;
  /* Zoom the viewport to show the full extent of all loaded layers. */
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

