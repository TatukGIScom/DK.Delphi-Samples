//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
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
