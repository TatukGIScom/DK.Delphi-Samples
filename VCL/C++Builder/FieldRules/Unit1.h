//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to use Field Rules.
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
#include "VCL.GisControlAttributes.hpp"
#include <Vcl.ExtCtrls.hpp>
#include "GisLayerVector.hpp"
#include "GisRtl.hpp"
#include "GisFieldRules.hpp"
#include "GisTypes.hpp"
#include "GisResource.hpp"
#include "GisFunctions.hpp"
#include "GisClasses.hpp"

#define EMAIL_REGEX "[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ControlAttributes *GIS_ControlAttributes1 ;
	TButton *btnAddAlias ;
	TButton *btnAddCheck ;
	TButton *btnAddList ;
	TButton *btnAddField ;
	TButton *btnAddValidate ;
	TButton *btnAddDefault ;
	TButton *btnSaveRules ;
	TButton *btn2 ;
	void __fastcall btnAddValidateClick(TObject *Sender);
	void __fastcall btnSaveRulesClick(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall btn2Click(TObject *Sender);
	void __fastcall btnAddAliasClick(TObject *Sender);
	void __fastcall btnAddCheckClick(TObject *Sender);
	void __fastcall btnAddDefaultClick(TObject *Sender);
	void __fastcall btnAddFieldClick(TObject *Sender);
	void __fastcall btnAddListClick(TObject *Sender);
private:	// User declarations
  TGIS_LayerVector *lv ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
