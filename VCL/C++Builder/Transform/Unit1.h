//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to transform a shape.
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
#include <Vcl.ExtCtrls.hpp>
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisFunctions.hpp"
#include "GisLayerVector.hpp"
#include "GisGeometryFactory.hpp"
#include "GISLayerPixel.hpp"
#include "GisResource.hpp"
#include "GisTransform.hpp"
#include "GisTypesUI.hpp"
#include "GisViewer.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TPanel *pnl1;
	TButton *btnTransform;
	TButton *btnCut;
	TButton *btnSave;
	TButton *btnLoad;
	void __fastcall btnCutClick(TObject *Sender);
	void __fastcall btnLoadClick(TObject *Sender);
	void __fastcall btnSaveClick(TObject *Sender);
	void __fastcall btnTransformClick(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);

private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
