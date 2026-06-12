//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Rotation sample — demonstrates rotating map view and handling rotation controls (C++Builder/VCL).
//
// What the sample shows:
//   - Loading a map dataset (countries shapefile) into the main viewer
//   - Creating a TGIS_ControlNorthArrow indicator showing current rotation angle
//   - Rotating the map view using a numeric input field (0-360 degrees)
//   - Using a slider/trackbar for interactive rotation angle adjustment
//   - Creating synchronized viewer windows displaying different rotation angles
//   - Applying rotation to all viewers: north, east, south, west orientations
//   - Using OnRotationChanged event to update controls when map rotates
//   - Displaying compass rose / north arrow at current rotation angle
//   - Handling viewer extent synchronization across rotated views
//   - Controlling labels and symbol orientation under rotation
//   - Real-time rotation feedback with degree display
//   - Toggling rotation lock behavior
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control with rotation support
//   TGIS_ControlNorthArrow      - north arrow indicator showing rotation angle
//   Rotation angle              - numeric value in degrees (0-360)
//   OnRotationChanged           - event triggered when map rotates
//   SetRotation / GetRotation   - programmatic rotation control
//   TTrackBar                   - slider for rotation adjustment
//   Extent synchronization      - multi-window extent sharing
//   TGIS_Params                 - layer styling with rotation
//   Symbol rotation             - orientation of point markers under map rotation
//   Label rotation              - text orientation matching map rotation
//
//  How to rotate the map.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisControlNorthArrow.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlNorthArrow.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include <Vcl.ExtCtrls.hpp>

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TStatusBar *StatusBar1;
  TImageList *ImageList1;
  TToolButton *btnFullExtent;
  TToolButton *btnZoomIn;
  TToolButton *btnZoomOut;
  TToolButton *ToolButton1;
  TToolButton *ToolButton2;
  TButton *Button1;
  TToolButton *ToolButton3;
  TCheckBox *CheckBox1;
	TGIS_ViewerWnd *GIS;
	TButton *decreaseBtn;
	TButton *increaseBtn;
	TTrackBar *rotationTB;
	TLabel *degLabel;
	TGIS_ControlNorthArrow *GIS_NorthArrow;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall btnFullExtentClick(TObject *Sender);
  void __fastcall btnZoomInClick(TObject *Sender);
  void __fastcall btnZoomOutClick(TObject *Sender);
  void __fastcall Button1Click(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
	void __fastcall increaseBtnClick(TObject *Sender);
	void __fastcall decreaseBtnClick(TObject *Sender);
	void __fastcall rotationTBChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
