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
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm10 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TPanel *pMenu;
	TLabel *lblMethod;
	TLabel *lblRadius;
	TLabel *lblThreshhold;
	TComboBox *cbxMethod;
	TComboBox *cbxRadius;
	TComboBox *cbxThreshhold;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall cbxMethodChange(TObject *Sender);
	void __fastcall cbxRadiusChange(TObject *Sender);
	void __fastcall cbxThreshholdChange(TObject *Sender);
private:	// User declarations
	void __fastcall readDefaultValues();
	void __fastcall changeAggregation();
	TStringList *names;
public:		// User declarations
	__fastcall TForm10(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm10 *Form10;
//---------------------------------------------------------------------------
#endif
