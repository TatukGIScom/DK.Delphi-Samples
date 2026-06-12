//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
  View3D Sample — Demonstrates 3D visualization of vector data with terrain models.

  Key concepts illustrated:
    - 3D rendering mode: TGIS_Control3D for three-dimensional visualization
    - Elevation models (DEM grids) as terrain base
    - Vector layer 3D visualization (buildings, features)
    - 2D/3D mode switching with RotationAngle property
    - 3D navigation: mouse drag rotation, mouse wheel zoom
    - Renderer selection (GDI+, Direct2D, Skia for 3D)
    - Texture mapping: apply bitmaps to 3D features
    - 3D layer styling: color, height exaggeration, transparency
    - Legend and scale display in 3D mode
    - Building roofs/walls rendering with textures
    - Extent and zoom controls in 3D
    - Navigation mode switching (rotate, pan, zoom)
    - Refresh modes: fast rendering vs. high-quality

  User workflow:
    1. Load a DEM (terrain/elevation model)
    2. Load vector layer (buildings, roads, features)
    3. Click "2D/3D" toggle to switch to 3D mode
    4. Drag mouse to rotate the 3D view
    5. Use mouse wheel to zoom in/out
    6. Select 3D mode (Perspective, Orthographic)
    7. Apply textures to buildings (roof/walls)
    8. Toggle walls/roof rendering
    9. Use legend to control layer visibility

  3D visualization features:
    - Perspective projection: realistic 3D view with vanishing point
    - Orthographic projection: parallel projection (no perspective)
    - Rotation: interactive rotation around vertical axis
    - Elevation exaggeration: scale height values for visibility
    - Texture mapping: bitmap textures on 3D surfaces
    - Lighting: directional light with ambient/diffuse shading

  Key API:
    - TGIS_Control3D: 3D viewer control
    - RotationAngle: rotation around vertical axis
    - ViewerMode: switch between 2D and 3D
    - Refresh rates: fast mode vs. high-quality mode
    - Texture application: bitmap textures on vector geometries
    - 3D extent: viewport fitting in 3D space
    - Navigation modes: rotation sensitivity and speed
*/

//  How to create 3D View.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControl3D.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.Graphics.hpp>
#include "GisAllLayers.hpp"
#include "GisLayer.hpp"
#include "GisEditor.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerGrd.hpp"
#include "GisParams.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "GisTypes3D.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisViewer3DBase.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TButton *btnOpen;
	TButton *btnFullExtent;
	TButton *btn2D3D;
	TLabel *lb3DMode;
	TComboBox *cbx3DMode;
	TGIS_ControlLegend *GIS_Legend;
	TGIS_ViewerWnd *GIS;
	TGIS_Control3D *GIS_3D;
	TButton *btnNavigation;
	TButton *btnRefresh;
	TButton *Button3;
	TButton *btnTextures ;
	TImage *Image1;
	TImage *Image2;
	TButton *btnRoof;
	TButton *Button1;
	TButton *Button2;
	TButton *btnWalls;
	void __fastcall btn2D3DClick(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnOpenClick(TObject *Sender);
	void __fastcall btnNavigationClick(TObject *Sender);
	void __fastcall btnRefreshClick(TObject *Sender);
	void __fastcall btnTexturesClick(TObject *Sender);
	void __fastcall Button1Click(TObject *Sender);
	void __fastcall Button2Click(TObject *Sender);
	void __fastcall Button3Click(TObject *Sender);
	void __fastcall btnWallsClick(TObject *Sender);
	void __fastcall btnRoofClick(TObject *Sender);
	void __fastcall cbx3DModeChange(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall FormMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
	void __fastcall FormMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
