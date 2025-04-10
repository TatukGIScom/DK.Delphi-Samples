//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.hpp>
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisLayerPixel.hpp"
//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblFormula;
	TEdit *edtFormula;
	TLabel *lblResultType;
	TLabel *lblSource;
	TButton *btnExecute;
	TProgressBar *pbrProgress;
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GIS_Legend;
	TButton *btnOpenGrid;
	TButton *btnOpenPixel;
	TButton *btnOpenVector;
	TRadioButton *rbtnResultPixel;
	TRadioButton *rbtnResultGrid;
	void __fastcall btnOpenPixelClick(TObject *Sender);
	void __fastcall btnOpenGridClick(TObject *Sender);
	void __fastcall btnOpenVectorClick(TObject *Sender);
	void __fastcall btnExecuteClick(TObject *Sender);
private:	// User declarations
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
	void __fastcall applyRamp(TGIS_LayerPixel *_l);
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
