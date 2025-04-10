//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "GisLayerVector.hpp"
#include "GisAllLayers.hpp"
#include "GisVectorization.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ExtCtrls.hpp>
#include "VCL.GisControlAttributes.hpp"
#include <Vcl.ComCtrls.hpp>
//---------------------------------------------------------------------------
class TForm10 : public TForm
{
__published:	// IDE-managed Components
	TPanel *pnl;
	TGroupBox *grpData;
	TButton *btnDem;
	TButton *btnLandCover;
	TGroupBox *grpGridToPolygon;
	TLabel *lblTolerance;
	TEdit *edtTolerance;
	TCheckBox *chkSplit;
	TButton *btnGenerate;
	TGroupBox *grpSelected;
	TGIS_ControlAttributes *GIS_ControlAttributes;
	TPanel *pnl1;
	TGIS_ViewerWnd *GIS;
	TProgressBar *pbprogress;
	void __fastcall FormShow(TObject *Sender);
	void __fastcall btnLandCoverClick(TObject *Sender);
	void __fastcall btnDemClick(TObject *Sender);
	void __fastcall btnGenerateClick(TObject *Sender);
	void __fastcall doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
	void __fastcall GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);

public:		// User declarations
	__fastcall TForm10(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm10 *Form10;
//---------------------------------------------------------------------------
#endif
