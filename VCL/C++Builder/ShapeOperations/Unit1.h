//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to transform shape.
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
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include "GisTypes.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include <System.Math.hpp>
#include "GisFunctions.hpp"
#include "GisRtl.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS ;
	TPageControl *pgc1 ;
	TTabSheet *ts1 ;
	TTabSheet *ts2 ;
	TTabSheet *ts3 ;
	TLabel *lblSelected ;
	void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
	void __fastcall GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
	void __fastcall pgc1Changing(TObject *Sender, bool &AllowChange);

private:	// User declarations
	bool handleMouseMove       ;
	TGIS_Point prevPtg         ;
	int prevX                  ;
	int prevY                  ;
	TGIS_LayerVector *edtLayer ;
	TGIS_Shape *curShape       ;
	TGIS_Shape *edtShape       ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	void __fastcall TranslateSelectedShape(TGIS_Shape *shape, double x_value, double y_value);
	void __fastcall ScaleSelectedShape(TGIS_Shape *shape, double x_value, double y_value);
	void __fastcall RotateSelectedShape(TGIS_Shape *shape, double angle) ;
	void __fastcall TransformSelectedShape(
				TGIS_Shape *shape,
				double xx,
				double yx,
				double xy,
				double yy,
				double dx,
				double dy );

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
