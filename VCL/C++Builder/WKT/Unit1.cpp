//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
  WKT Sample — Real-time WKT (Well-Known Text) parsing with interactive geometry visualization.

  Key concepts illustrated:
    - ISO SQL/MM WKT standard geometry text format
    - 5 standard geometry types (Point, MultiPoint, LineString, MultiLineString, Polygon)
    - Polygon with holes (interior rings)
    - Real-time text-to-geometry conversion (GisCreateShapeFromWKT)
    - Error detection and visual feedback (red text = invalid WKT)
    - Dynamic layer updates and viewport adjustment
    - Text editing with live geometry preview
    - Preset geometry templates via dropdown selector

  User workflow:
    1. Load form with default Polygon (with hole) selected
    2. Choose different geometry type from dropdown cbType
    3. WKT text updates and geometry renders on map
    4. Edit WKT text directly in memo for custom testing
    5. Valid geometries: black text, shape displayed
    6. Invalid geometries: red text, no shape (parsed shape is nil)
    7. Map automatically fits to geometry extent

  Implementation pattern:
    - Memo1Change: main parser (triggered on any text change)
    - cbTypeChange: updates memo with preset WKT strings
    - FormCreate: initialize empty layer with red fill color

  Error handling:
    - GisCreateShapeFromWKT returns nullptr for invalid WKT
    - Empty shapes cleared before reparsing (RevertShapes)
    - Font color indicates parsing success/failure
    - Exception catch prevents crash on bad input
*/

//  How to perform WKT operation.
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

#define STR_POINT        "POINT (30 30)"
#define STR_MULTIPOINT   "MULTIPOINT (4 4, 5 5, 6 6 ,7 7)"
#define STR_LINESTR      "LINESTRING (3 3, 10 10)"
#define STR_MULTILINESTR "MULTILINESTRING ((1 1 3 3 4 4 6 6),(1 1 3 3 4 4 6 6))"
#define STR_POLYGON      "POLYGON( ( 5 5, 25 5, 25 25, 5 25, 5 5), ( 10 10, 10 20, 20 20, 20 10, 10 10)  )"

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
/*
  FormCreate
  Initializes the sample with an empty vector layer and default Polygon WKT geometry.

  Steps:
    1. Create empty vector layer for displaying parsed geometries
    2. Set layer fill color to red for visibility
    3. Add layer to the GIS viewer
    4. Load default Polygon WKT string into text editor
    5. Select Polygon type in dropdown (ItemIndex 4)
    6. Trigger Memo1Change to parse and display the polygon
*/
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // Create empty vector layer to hold parsed geometries
  layerObj = new TGIS_LayerVector ;
  layerObj->Name = "output" ;
  // Set fill color to red for clear visibility of parsed shapes
  layerObj->Params->Area->Color = TGIS_Color::Red ;

  // Add the layer to the viewer
  GIS->Add( layerObj ) ;
  // Fit viewport to layer (initially empty)
  GIS->FullExtent() ;

  // Load default WKT polygon string (with hole)
  Memo1->Text = STR_POLYGON;
  // Select Polygon type in dropdown (index 4)
  cbType->ItemIndex = 4;
  // Parse the WKT and display the geometry
  Memo1Change(Sender) ;
}
//---------------------------------------------------------------------------
/*
  Memo1Change
  Parses WKT text and displays the resulting geometry on the map.
  Provides visual feedback: black text = valid, red text = invalid WKT.

  Algorithm:
    1. Clear all previous shapes from the layer
    2. Parse WKT text using GisCreateShapeFromWKT (returns nullptr if invalid)
    3. If parse succeeded (shp != nullptr): add shape to layer and clean up
    4. If parse failed (shp == nullptr): abort and show error state
    5. On success: set text color to black
    6. On error: catch exception and set text color to red
    7. Recalculate layer extent and zoom to fit all geometries

  Error handling:
    - Invalid WKT syntax: GisCreateShapeFromWKT returns nullptr
    - Unparseable text: exception caught, text colored red
    - Visual feedback: users see immediately if WKT is valid
*/
void __fastcall TForm1::Memo1Change(TObject *Sender)
{
  TGIS_Shape  *shp ;

  try {
    // Clear previous shapes before re-parsing
    layerObj->RevertShapes() ;

    // Parse WKT text string into a shape object
    // Returns nullptr if WKT syntax is invalid
    shp = TGIS_Utils::GisCreateShapeFromWKT( Memo1->Text ) ;

    if ( shp ) {
      // Successfully parsed: add shape to the layer
      // False = don't auto-recalc extent (we do it below)
      layerObj->AddShape( shp, False ) ;
      delete shp ;
    }
    else
      // Parse returned nullptr: abort to trigger catch
      Abort ;

    // Valid WKT: set text color to black
    Memo1->Font->Color = clBlack ;
  }
  catch(...) {
    // Invalid WKT or parsing error: set text color to red for visual feedback
    Memo1->Font->Color = clRed ;
  }

  // Recalculate layer extent based on parsed shapes
  layerObj->RecalcExtent() ;
  // Recalculate viewer extent
  GIS->RecalcExtent() ;
  // Zoom to fit all geometries
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------
/*
  cbTypeChange
  Updates memo with preset WKT string when user selects geometry type from dropdown.

  Dropdown items (ItemIndex):
    0: Single point (POINT)
    1: Multiple points (MULTIPOINT)
    2: Single line (LINESTRING)
    3: Multiple lines (MULTILINESTRING)
    4: Polygon with hole (POLYGON)

  Action: triggers Memo1Change to parse and display the new geometry
*/
void __fastcall TForm1::cbTypeChange(TObject *Sender)
{
  // Set memo text based on selected geometry type
  switch (cbType->ItemIndex) {
        case 0 : Memo1->Text = STR_POINT; break;           // Single point
        case 1 : Memo1->Text = STR_MULTIPOINT; break;      // Multiple points
        case 2 : Memo1->Text = STR_LINESTR; break;         // Single line
        case 3 : Memo1->Text = STR_MULTILINESTR; break;    // Multiple lines
        case 4 : Memo1->Text = STR_POLYGON; break;         // Polygon with hole
  }
  // Parse and display the new geometry
  Memo1Change(Sender) ;
}
//---------------------------------------------------------------------------

