/* HelloDK sample — introductory demonstration of core TatukGIS DK workflows (C++Builder/VCL).

   What the sample shows:
     - Opening a vector Shapefile (world map) into the GIS viewer
     - Switching the viewer interaction mode: Zoom / Drag / Select
     - Creating an in-memory editable vector layer with a transparent polygon style
     - Building a polygon shape programmatically by adding explicit vertices
     - Click-to-select a feature using screen-to-map coordinate conversion
     - Spatial proximity search via GIS->Locate to identify shapes near cursor
     - Spatial containment query using DE-9IM matrix "T*****FF*" (touches/inside)
     - SQL WHERE filtering to find shapes with attributes starting with 's'

   Key TatukGIS API concepts shown here:
     TGIS_ViewerWnd              - main visual map control
     TGIS_LayerVector            - vector layer (shapefile or in-memory)
     TGIS_Shape                  - individual geographic feature
     TGIS_ViewerMode             - interaction modes (Zoom, Drag, Select)
     GIS->Locate()               - spatial proximity search at point
     GIS->ScreenToMap()          - convert screen pixels to geographic coords
     TGIS_LayerVector.Loop()     - spatial enumeration with DE-9IM filtering
     Shape attributes / SQL WHERE - feature filtering and selection
*/

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlAttributes.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisControlNorthArrow.hpp"
#include "VCL.GisControlScale.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.Buttons.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisUtils.hpp"
//---------------------------------------------------------------------------
/* HelloDK sample — introductory demonstration of core TatukGIS DK workflows.
   Opens a world shapefile, creates an in-memory vector layer with a polygon, performs spatial containment
   queries using DE-9IM topology predicates, and switches between interaction modes (Zoom, Drag, Select).
   Demonstrates screen-to-map coordinate conversion, feature location via GIS->Locate(), and SQL filtering. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	// "Open project" button - loads the sample world shapefile
	TSpeedButton *btnOpen;
	// "Zooming" button - enables rubber-band zoom interaction
	TSpeedButton *btnZoom;
	// "Dragging" button - enables pan/drag interaction
	TSpeedButton *btnDrag;
	// "Selecting" button - enables click-to-select interaction
	TSpeedButton *btnSelect;
	// "Create Shape" button - adds an editable layer with a sample polygon
	TSpeedButton *btnCreateShape;
	// "Find Shape" (Relation) button - runs DE-9IM spatial containment query
	TSpeedButton *btnRelation;
	// The central GIS map viewer control
	TGIS_ViewerWnd *GIS;
	TToolBar *ToolBar1;

	void __fastcall btnOpenClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall btnSelectClick(TObject *Sender);
	void __fastcall btnCreateShapeClick(TObject *Sender);
	void __fastcall btnRelationClick(TObject *Sender);
	// TapSimple event - fired on every single mouse click on the viewer
	void __fastcall GISTapSimpleEvent(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
