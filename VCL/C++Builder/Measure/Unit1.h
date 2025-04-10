//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TButton *btnLine;
	TButton *btnPolygon;
	TButton *btnClear;
	TPanel *Panel1;
	TStatusBar *StatusBar1;
	TGIS_ViewerWnd *GIS;
	TLabel *lblLength;
	TEdit *edtLength;
	TLabel *lblArea;
	TEdit *edtArea;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISEditorChangeEvent(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall btnLineClick(TObject *Sender);
	void __fastcall btnPolygonClick(TObject *Sender);
	void __fastcall btnClearClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
