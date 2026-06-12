//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Buffers1 - How to perform a Buffer operation using TGIS_Topology::MakeBuffer.
//
// This sample demonstrates:
//   - Loading a vector shapefile into the GIS viewer
//   - Creating a separate in-memory vector layer to hold the buffer result
//   - Letting the user click on any shape to select it as the buffer source
//   - Using TGIS_Topology::MakeBuffer to compute a planar buffer polygon around
//     the selected shape, with the buffer distance controlled by a TrackBar
//     (range -50..+50 km; negative values produce an inward/erosion buffer)
//   - Adding the resulting buffer shape to the buffer layer and refreshing
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd   - the main visual map control
//   TGIS_LayerVector - an in-memory or file-backed vector layer
//   TGIS_Topology    - utility class for spatial operations (MakeBuffer, etc.)
//   TGIS_Shape       - a single geographic feature (point, line, or polygon)
//   GIS->Locate      - hit-test: finds the topmost shape at a map coordinate
//   GIS->ScreenToMap - converts pixel coordinates to map (geographic) coordinates
//   lb->RevertShapes - removes all shapes from the buffer layer so it always
//                      shows only the current result
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "GisTopology.hpp"
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

// FormCreate
// Sets up the initial map state when the form is first shown.
//
// Steps:
//   1. Lock the viewer to suppress intermediate repaints during setup.
//   2. Open the topology sample shapefile (becomes layer index 0).
//   3. Create an empty in-memory "buffer" layer (50 % transparent, red fill)
//      so the buffer result is visually distinct from the source shapes.
//   4. Unlock the viewer and zoom to the full data extent.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector *lb;  // in-memory buffer overlay layer

  GIS->Lock();
  GIS->Open(GisSamplesDataDirDownload() + "\\Samples\\Topology\\topology.shp", true);
  lb = new TGIS_LayerVector;
  lb->Name = "buffer";
  lb->Transparency = 50;                    // 50 % transparent - source shapes remain visible
  lb->Params->Area->Color = TGIS_Color::Red;
  GIS->Add(lb);
  GIS->Unlock();
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

// TrackBar1Change
// Recomputes the buffer polygon each time the slider value changes.
//
// Algorithm:
//   1. Retrieve the source layer (index 0) and the "buffer" overlay layer.
//   2. Fetch shape with hardcoded Uid 2 (note: in the C++Builder edition the
//      shape is always index 2; the Delphi/NDK editions use shp_id updated by
//      mouse clicks).
//   3. Create a TGIS_Topology instance and call MakeBuffer.
//      Distance = TrackBar1->Position * 1000 metres (position is in km;
//      negative values produce an inward/erosion buffer).
//   4. Clear the buffer layer (RevertShapes) then add the new result.
//   5. Recalculate extents for all layers and refresh the view.
void __fastcall TForm1::TrackBar1Change(TObject *Sender)
{
  TGIS_LayerVector *ll;   // source layer containing the shapes
  TGIS_LayerVector *lb;   // buffer overlay layer
  TGIS_Shape       *shp;  // the shape being buffered
  TGIS_Shape       *tmp;  // temporary buffer result from MakeBuffer
  TGIS_Topology    *tpl;  // topology engine

  ll = (TGIS_LayerVector *)(GIS->Items->Items[0]);
  if (ll == NULL) return;
  lb = (TGIS_LayerVector *)(GIS->Get("buffer"));
  if (lb == NULL) return;
  // Retrieve the currently selected shape (defaults to Uid 2)
  shp = ll->GetShape(2);
  if (shp == NULL) return;

  tpl = new TGIS_Topology;
  try {
    lb->RevertShapes();  // discard any previously computed buffer polygon
    // MakeBuffer expands the shape by the given distance in metres.
    // Multiplying by 1000 converts the track-bar km value to metres.
    tmp = tpl->MakeBuffer(shp, TrackBar1->Position * 1000);
    if (tmp) {
       lb->AddShape(tmp, False);  // transfer to the buffer overlay layer
       delete tmp;
    }
    // Recalculate extents after adding the new shape
    ll->RecalcExtent();
    lb->RecalcExtent();
    GIS->RecalcExtent();
    GIS->FullExtent();
  }
  __finally {
    delete tpl;
  }
}
//---------------------------------------------------------------------------

// btnPlusClick
// Increments the track-bar position by 1 step (increases buffer distance).
// TrackBar1Change fires automatically as a result.
void __fastcall TForm1::btnPlusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position + 1;
}
//---------------------------------------------------------------------------

// btnMinusClick
// Decrements the track-bar position by 1 step (decreases buffer distance).
// TrackBar1Change fires automatically as a result.
void __fastcall TForm1::btnMinusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position - 1;
}
//---------------------------------------------------------------------------

// GISMouseDown
// Handles mouse clicks on the map to select the shape that will be buffered.
//
// Steps:
//   1. Guard against clicks during painting or on a NULL viewer.
//   2. Convert the screen pixel position to map coordinates via ScreenToMap.
//   3. Call GIS->Locate to find the nearest shape within a 5-pixel tolerance
//      (converted to map units via GIS->Zoom).
//   4. Remember the shape's Uid in shp_id and briefly flash it to give
//      visual feedback to the user.
void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Point  ptg;   // clicked point in map coordinates
  TGIS_Shape *shp;   // shape found at the click position

  if (GIS->InPaint) return;  // do not process clicks during map rendering

  if (GIS == NULL) {
    return;
  }

  // Convert screen pixels to map (geographic) coordinates
  ptg = GIS->ScreenToMap(Point(X, Y));
  // Locate the nearest shape within 5 pixels of the click
  shp = (TGIS_Shape *)(GIS->Locate(ptg, 5 / GIS->Zoom));  // 5 pixels precision

  // Store the Uid so TrackBar1Change can buffer the correct shape
  if (shp != NULL) {
    shp_id = shp->Uid;
    shp->Flash();  // brief visual highlight to confirm selection
  }
}
//---------------------------------------------------------------------------
