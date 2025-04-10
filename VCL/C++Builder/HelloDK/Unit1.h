//---------------------------------------------------------------------------

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
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TSpeedButton *btnOpen;
	TSpeedButton *btnZoom;
	TSpeedButton *btnDrag;
	TSpeedButton *btnSelect;
	TSpeedButton *btnCreateShape;
	TSpeedButton *btnRelation;
	TGIS_ViewerWnd *GIS;
	TToolBar *ToolBar1;

	void __fastcall btnOpenClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall btnSelectClick(TObject *Sender);
	void __fastcall btnCreateShapeClick(TObject *Sender);
	void __fastcall btnRelationClick(TObject *Sender);
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
