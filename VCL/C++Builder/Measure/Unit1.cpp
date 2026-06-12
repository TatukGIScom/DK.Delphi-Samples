//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Measure Sample - TatukGIS DK VCL / C++Builder (implementation)
//
// Demonstrates how to interactively measure distance (polyline length) and
// area (polygon area) on a map using the built-in shape editor.
//
// Key concepts shown:
//   - Creating an in-memory TGIS_LayerVector to hold the temporary measurement
//     shape, rendered on top of the background basemap.
//   - Using GIS->Editor to create and track Arc (polyline) and Polygon shapes
//     as the user places vertices with the mouse.
//   - Responding to GISEditorChangeEvent (wired in the DFM) to recompute
//     measurements live after every vertex the user places.
//   - Using TGIS_CSUnits::AsLinear / AsAreal to format raw metre /
//     square-metre values into human-readable strings (e.g. "12.3 km").
//   - EPSG 904201 = TatukGIS standard metric unit set. Assigning EPSG 4326
//     (WGS-84 geographic) to the drawing layer ensures that LengthCS() and
//     AreaCS() return geodetically correct values.
//   - GIS->Mode transitions:
//       TGIS_ViewerMode::Select  - waiting for the first click to anchor shape
//       TGIS_ViewerMode::Edit    - editor is collecting additional vertices
//       TGIS_ViewerMode::Drag    - idle / panning (default)
//
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;

// Global state variables.  Declared at file scope so they are accessible
// from all event handlers without being member variables of TForm1.

/** In-memory vector layer holding the current measurement shape. */
TGIS_LayerVector *ll;

/** Unit formatter for metric output; EPSG 904201 = km / km². */
TGIS_CSUnits *units;

/** True when the viewer is in polyline (distance) measurement mode. */
bool isLine;

/** True when the viewer is in polygon (area) measurement mode. */
bool isPolygon;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------

/**
 * Initialises the viewer: loads the world basemap, creates the in-memory
 * measurement layer, and configures the shape editor.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // Lock suspends rendering while multiple map changes are made,
  // preventing partial redraws during initialisation.
  GIS->Lock();

  // Load a world outline shapefile as the background basemap.
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\WorldDCW\\world.shp");

  // Create an in-memory vector layer to hold the measurement shape.
  // No file is written; the shape exists only in memory.
  ll = new TGIS_LayerVector();
  ll->Params->Line->Color = TGIS_Color::Red;  // Red for high visibility
  ll->Params->Line->Width = 25;               // Thick line for easy reading

  // Assign WGS-84 geographic CS (EPSG 4326).
  // With a geographic CS, LengthCS() and AreaCS() perform geodetic calculations
  // that account for the curvature of the Earth.
  ll->SetCSByEPSG(4326);

  GIS->Add(ll);

  // Restrict scrolling to the initial full-world extent.
  GIS->RestrictedExtent = GIS->Extent;

  GIS->Unlock();

  // EPSG 904201 selects the TatukGIS standard metric unit formatter.
  units = CSUnitsList()->ByEPSG( 904201 ) ;

  isLine = false;
  isPolygon = false;

  // Widen the rubber-band preview line for better visibility.
  GIS->Editor->EditingLinesStyle->PenWidth = 10;

  // AfterActivePoint draws a live preview segment from the last placed
  // vertex to the current cursor position, giving real-time length feedback.
  GIS->Editor->Mode = TGIS_EditorMode::AfterActivePoint;
}
//---------------------------------------------------------------------------

/**
 * Fired by the editor every time a vertex is placed or the mouse moves
 * while editing.  Recomputes and displays the current length and, for
 * polygons, the enclosed area.
 */
void __fastcall TForm1::GISEditorChangeEvent(TObject *Sender)
{
  if (GIS->Editor->CurrentShape != NULL)
  {
    // Cast the generic IGIS_Shape interface to the concrete TGIS_Shape class
    // to access LengthCS() and AreaCS().
    TGIS_Shape *shp = (TGIS_Shape*)GIS->Editor->CurrentShape;

    if (isLine)
    {
      // LengthCS() returns the geodetic cumulative length in metres.
      // AsLinear formats it with the unit label (e.g. "5.3 km").
      edtLength->Text = units->AsLinear(shp->LengthCS(), true);
    }
    else if (isPolygon)
    {
      // For a polygon, LengthCS() is the perimeter.
      edtLength->Text = units->AsLinear(shp->LengthCS(), true);
      // AreaCS() returns the geodetic enclosed area in square metres.
      // '%s' is the format template; AsAreal appends the unit abbreviation.
      edtArea->Text = units->AsAreal(shp->AreaCS(), true, '%s');
    }
  }
}
//---------------------------------------------------------------------------

/**
 * Handles the first mouse press on the map that creates a new measurement
 * shape.  Once created the viewer switches to Edit mode and the editor manages
 * all subsequent vertex placements internally.
 */
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  // If the editor is already active, additional clicks are handled internally
  // by the editor — do not create a second shape.
  if (GIS->Mode == TGIS_ViewerMode::Edit)
  {
    return;
  }

  // Convert the screen pixel position to geographic map coordinates.
  TGIS_Point ptg = GIS->ScreenToMap(Point(X, Y));

  if (isLine)
  {
    // Arc = polyline; LengthCS() sums all segment lengths geodetically.
    GIS->Editor->CreateShape(ll, ptg, TGIS_ShapeType::Arc);
    // Transfer vertex control to the editor for all subsequent mouse events.
    GIS->Mode = TGIS_ViewerMode::Edit;
  }
  else if (isPolygon)
  {
    // Polygon; both AreaCS() and LengthCS() (perimeter) are available.
    GIS->Editor->CreateShape(ll, ptg, TGIS_ShapeType::Polygon);
    // Transfer vertex control to the editor for all subsequent mouse events.
    GIS->Mode = TGIS_ViewerMode::Edit;
  }
}
//---------------------------------------------------------------------------

/**
 * Prepares the viewer for polyline distance measurement.
 * Discards any existing shape, clears the result fields, and sets the viewer
 * to Select mode so the next mouse click starts a new Arc (polyline) shape.
 */
void __fastcall TForm1::btnLineClick(TObject *Sender)
{
  // Remove any in-progress measurement shape.
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  // Only the length field will be updated; area stays empty.
  isPolygon = false;
  isLine = true;

  // Waiting for the first click that anchors the polyline's first vertex.
  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------

/**
 * Prepares the viewer for polygon area measurement.
 * Discards any existing shape, clears the result fields, and sets the viewer
 * to Select mode so the next mouse click starts a new Polygon shape.
 */
void __fastcall TForm1::btnPolygonClick(TObject *Sender)
{
  // Remove any in-progress measurement shape.
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  // Both perimeter and area will be displayed in this mode.
  isPolygon = true;
  isLine = false;

  // Waiting for the first click that anchors the polygon's first vertex.
  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------

/**
 * Clears the current measurement shape, resets the result fields, and
 * returns the viewer to drag/pan mode.
 */
void __fastcall TForm1::btnClearClick(TObject *Sender)
{
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  // Return to normal pan/zoom interaction.
  GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------
