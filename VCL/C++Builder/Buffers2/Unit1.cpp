//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Buffers2 - Advanced buffer operation with spatial intersection query.
//
// This sample extends the Buffers1 concept by demonstrating how to combine
// TGIS_Topology::MakeBuffer with a spatial search to find all features that
// intersect the resulting buffer polygon.
//
// What the sample shows:
//   - Loading a real-world county shapefile (California counties) via the
//     GisCreateLayer factory function, which selects the correct layer class
//     for the file format automatically
//   - Creating a semi-transparent in-memory overlay layer (TGIS_LayerVector)
//     to hold the buffer polygon (yellow, 70 % transparent)
//   - Using TGIS_LayerVector::FindFirst with an attribute filter
//     ("NAME='Merced'") to locate a specific county as the buffer source shape
//   - Calling TGIS_Topology::MakeBuffer to generate a buffer around that county
//     (distance = TrackBar1->Position / 100.0 degrees in the planar/geographic CRS)
//   - Performing a two-stage spatial intersection query:
//       Stage 1 - FindFirst(buf->Extent): bounding-box pre-filter (fast)
//       Stage 2 - buf->IsCommonPoint(tmp): precise geometric overlap test
//   - Marking intersecting counties blue (MakeEditable + Params->Area->Color)
//     and listing their names in a Memo control
//   - Using TTimer to debounce rapid track-bar changes so the expensive
//     buffer + intersection query only runs after the slider has been idle
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd       - the main visual map control
//   TGIS_LayerVector     - file-backed or in-memory vector layer
//   TGIS_LayerAbstract   - base pointer type returned by GisCreateLayer
//   GisCreateLayer       - factory function that opens a layer of the correct
//                          subclass for the given file format
//   TGIS_Topology        - utility class for spatial operations (MakeBuffer)
//   TGIS_Shape           - a single geographic feature
//   FindFirst / FindNext - query iterator for shapes within an extent/filter
//   IsCommonPoint        - precise overlap test (true if shapes share any point)
//   MakeEditable         - returns a writable copy of a read-only shape so its
//                          display parameters can be changed
//   IgnoreShapeParams    - when False, per-shape Params override layer defaults
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
// Sets up the initial map state when the form is first displayed.
//
// Steps:
//   1. Lock the viewer to suppress intermediate repaints during setup.
//   2. Open the California counties shapefile via GisCreateLayer with the
//      logical name "counties".  GisCreateLayer picks the right TGIS_Layer
//      subclass for the SHP format automatically.
//   3. Create an empty in-memory "buffer" overlay layer (70 % transparent,
//      yellow fill) and add it to the viewer.
//   4. Unlock and zoom to the full data extent.
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  int                  i;    // unused loop variable (legacy)
  TGIS_LayerAbstract  *la;   // file-backed county layer
  TGIS_LayerVector    *lb;   // in-memory buffer overlay layer

  GIS->Lock();
  // GisCreateLayer selects the correct layer class for the SHP format and
  // assigns the logical name "counties" used later by GIS->Get.
  la = GisCreateLayer(
          "counties",
          GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\Counties.shp"
        );
  GIS->Add(la);

  // Buffer overlay: 70 % transparent yellow so the county boundaries show through
  lb = new TGIS_LayerVector;
  lb->Name = "buffer";
  lb->Transparency = 70;
  lb->Params->Area->Color = TGIS_Color::Yellow;
  GIS->Add(lb);
  GIS->Unlock();
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

// Timer1Timer
// Performs the buffer computation and spatial intersection query.
//
// This handler is triggered by the debounce timer started in TrackBar1Change.
// Disabling the timer at the start ensures it fires only once per slider-move
// gesture rather than on every intermediate tick.
//
// Algorithm:
//   1. Retrieve the "counties" and "buffer" layers by name via GIS->Get.
//   2. Find the "Merced" county using FindFirst with an attribute filter and
//      GisWholeWorld() as the bounding-box envelope (no spatial pre-filtering).
//   3. Create a TGIS_Topology and call MakeBuffer.
//      Distance = TrackBar1->Position / 100.0 (degrees in the geographic CRS).
//   4. Clear the buffer layer (RevertShapes) and add the new buffer polygon.
//   5. Two-stage spatial query:
//        Stage 1 - FindFirst(buf->Extent): bounding-box pre-filter
//        Stage 2 - buf->IsCommonPoint(tmp): precise geometric intersection test
//   6. Matching counties are coloured blue (via MakeEditable) and their names
//      are added to Memo1.
//   7. GIS->InvalidateWholeMap redraws the display in the __finally block.
void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
  TGIS_LayerVector *ll;   // the county source layer
  TGIS_LayerVector *lb;   // the buffer overlay layer
  TGIS_Shape       *shp;  // the Merced county shape (buffer source)
  TGIS_Shape       *tmp;  // iterator shape during FindFirst/FindNext loop
  TGIS_Shape       *buf;  // the computed buffer polygon stored in lb
  TGIS_Topology    *tpl;  // topology engine

  // Disable the timer immediately so it does not fire again while processing
  Timer1->Enabled = False;

  try {
    // Retrieve layers by their logical names
    ll = (TGIS_LayerVector *)(GIS->Get("counties"));
    if (ll == NULL) return;
    lb = (TGIS_LayerVector *)(GIS->Get("buffer"));
    if (lb == NULL) return;

    // FindFirst with an attribute filter locates the Merced county shape.
    // GisWholeWorld() passes the full-world extent so no shape is excluded
    // by bounding-box pre-filtering.
    shp = ll->FindFirst(GisWholeWorld(), "NAME='Merced'", NULL, "", true);
    if (shp == NULL) return;

    tpl = new TGIS_Topology;
    try {
      lb->RevertShapes();  // discard any previously computed buffer polygon
      // MakeBuffer distance is in the layer's native units (degrees here).
      // Dividing by 100.0 converts the integer track-bar value to a fractional degree.
      tmp = tpl->MakeBuffer(shp, TrackBar1->Position / 100.0);
      if (tmp) {
        // AddShape copies the geometry into the overlay layer and returns the
        // stored shape reference (buf) needed for the intersection query below.
        buf = lb->AddShape(tmp);
        delete tmp;
      }
      else
        buf = NULL;
    }
    __finally {
      delete tpl;
    };

    // ── Intersection query ────────────────────────────────────────────────────
    // Only proceed if the buffer was successfully created.
    if (buf == NULL) return;

    ll = (TGIS_LayerVector *)(GIS->Get("counties"));
    if (ll == NULL) return;
    ll->RevertShapes();               // reset per-shape style overrides from the previous run
    ll->IgnoreShapeParams = False;    // allow per-shape colour overrides to take effect
    Memo1->Clear();
    Memo1->Lines->BeginUpdate();

    // Stage 1: FindFirst with buf->Extent as a bounding-box pre-filter.
    // Only shapes whose envelope overlaps the buffer's bounding box are visited.
    tmp = ll->FindFirst(buf->Extent);
    while (tmp) {
      // Stage 2: precise geometric test - does the shape share any point with
      // the buffer polygon?
      if (buf->IsCommonPoint(tmp)) {
        // MakeEditable returns a writable copy so Params->Area->Color can be set.
        // Modifying Params on a read-only (file-backed) shape has no effect.
        tmp = tmp->MakeEditable();
        Memo1->Lines->Add(tmp->GetField("NAME"));   // add county name to the list
        tmp->Params->Area->Color = TGIS_Color::Blue;
      }
      tmp = ll->FindNext();  // advance to the next bounding-box candidate
    }
    Memo1->Lines->EndUpdate();
  }
  __finally {
    // Always redraw the map, even if an early return occurred above.
    GIS->InvalidateWholeMap();
  }
}
//---------------------------------------------------------------------------

// TrackBar1Change
// Debounces rapid slider movement by resetting and re-enabling the timer.
//
// When the user drags the slider quickly this event fires many times per
// second.  Instead of running the expensive buffer+intersect query on every
// tick, we restart the timer so the query only runs after the slider has been
// idle for one timer interval (250 ms by default).
void __fastcall TForm1::TrackBar1Change(TObject *Sender)
{
  Timer1->Enabled = False;
  // Show the current distance in the status bar while dragging
  StatusBar1->SimpleText = IntToStr(TrackBar1->Position) + "km";
  Timer1->Enabled = True;
}

//---------------------------------------------------------------------------
// btnPlusClick
// Increases the buffer distance by 5 track-bar units and immediately triggers
// the buffer recompute by calling Timer1Timer directly (bypassing the debounce
// so the result is shown immediately on button click).
void __fastcall TForm1::btnPlusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position + 5;
  Timer1Timer(Sender);
}
//---------------------------------------------------------------------------

// btnMinusClick
// Decreases the buffer distance by 5 track-bar units and immediately triggers
// the buffer recompute by calling Timer1Timer directly.
void __fastcall TForm1::btnMinusClick(TObject *Sender)
{
  TrackBar1->Position = TrackBar1->Position - 5;
  Timer1Timer(Sender);
}
//---------------------------------------------------------------------------
