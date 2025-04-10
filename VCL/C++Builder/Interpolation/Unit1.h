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
//---------------------------------------------------------------------------
const String FIELD_VALUE = "TEMP";
const int GRID_RESOLUTION = 400;
//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TLabel *lblMethod;
	TRadioButton *rbtnIDW;
	TRadioButton *rbtnKriging;
	TRadioButton *rbtnSplines;
	TRadioButton *rbtnHeatMap;
	TRadioButton *rbtnConcentrationMap;
	TLabel *lblSemivariance;
	TComboBox *cmbSemivariance;
	TButton *btnGenerateGrid;
	TGIS_ViewerWnd *GIS;
	TProgressBar *pbProgress;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall doRbtnAnyClick(TObject *Sender);
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
	void __fastcall btnGenerateGridClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
