//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisSymbol.hpp"
#include <Vcl.ComCtrls.hpp>
//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblHint;
	TGIS_ViewerWnd *GIS;
	TButton *btnFullExtent;
	TButton *btnReset;
	TGroupBox *gbMapMode;
	TRadioButton *rbtnZoom;
	TRadioButton *rbtnAddObserver;
	TGroupBox *gbVisibleLayer;
	TRadioButton *rbtnViewshedBinary;
	TRadioButton *rbtnViewshedFreq;
	TRadioButton *rbtnAGL;
	TLabel *lblObserverElevation;
	TEdit *edtObserverElevation;
    TStatusBar *StatusBar1;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnResetClick(TObject *Sender);
	void __fastcall rbtnZoomClick(TObject *Sender);
	void __fastcall rbtnAddObserverClick(TObject *Sender);
	void __fastcall rbtnViewshedBinaryClick(TObject *Sender);
	void __fastcall rbtnAGLClick(TObject *Sender);
	void __fastcall rbtnViewshedFreqClick(TObject *Sender);
	void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);

private:	// User declarations
	TGIS_LayerPixel  *lTerrain;
	TGIS_LayerVector *lObservers;
	TGIS_LayerPixel  *lViewshed;
	TGIS_LayerPixel  *lAGL;
	void __fastcall setLayerActive();
	void __fastcall makeViewshedRamp();
    void __fastcall showComment();
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
