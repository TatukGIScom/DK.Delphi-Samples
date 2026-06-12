//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Measure sample — demonstrates interactive distance and area measurement on a map (C++Builder/VCL).
//
// What the sample shows:
//   - Creating an in-memory TGIS_LayerVector to hold temporary measurement shapes
//   - Using TGIS_ViewerWnd->Editor to create and track polyline and polygon shapes
//   - Responding to EditorChangeEvent for live measurement updates
//   - Using TGIS_CSUnits::AsLinear and AsAreal for human-readable output formatting
//   - Polyline distance measurement with geodetic accuracy
//   - Polygon area measurement with coordinate system awareness
//   - Toggling between Line (distance) and Polygon (area) measurement modes
//   - Real-time display of measurements as user places vertices
//   - Clear button to reset and start new measurement
//
// Key TatukGIS API concepts shown here:
//   - TGIS_ViewerWnd: main visual map control
//   - TGIS_ViewerWnd->Editor: in-place shape creation and editing
//   - TGIS_LayerVector: in-memory measurement shape layer
//   - TGIS_Shape: polyline/polygon measurement geometry
//   - TGIS_CSUnits: unit formatting and conversion
//   - EditorChangeEvent: live measurement update trigger
//   - TGIS_ViewerMode: interaction modes (Select, Edit, Drag)
//   - EPSG 904201: metric unit set for geodetic calculations
//   - EPSG 4326: WGS-84 geographic coordinate system
//
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
//---------------------------------------------------------------------------
/* Main application form for the Measure sample.
   Hosts the TatukGIS viewer and provides controls to measure line lengths
   and polygon areas directly on the map. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TButton       *btnLine;     // Activates polyline distance measurement mode
	TButton       *btnPolygon;  // Activates polygon area measurement mode
	TButton       *btnClear;    // Clears the current measurement and returns to drag mode
	TPanel        *Panel1;      // Panel hosting the result label/edit pairs
	TStatusBar    *StatusBar1;  // Bottom status bar with usage hint
	TGIS_ViewerWnd *GIS;        // The TatukGIS map viewer control
	TLabel        *lblLength;   // "Length:" label
	TEdit         *edtLength;   // Read-only display of the measured length / perimeter
	TLabel        *lblArea;     // "Area:" label
	TEdit         *edtArea;     // Read-only display of the measured area (polygon mode only)

	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISEditorChangeEvent(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall btnLineClick(TObject *Sender);
	void __fastcall btnPolygonClick(TObject *Sender);
	void __fastcall btnClearClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
