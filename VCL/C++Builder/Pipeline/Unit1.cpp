//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to add layer to the map.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
   mmoCode->Lines->LoadFromFile( GisSamplesDataDirDownload() + "\\Samples\\Pipeline\\Contouring.ttkpipeline" );

  oPipeline = new TGIS_Pipeline ;
  oPipeline->GIS = interface_cast< IGIS_Viewer >(GIS) ;
  oPipeline->ShowMessageEvent = this->doPipelineMessage ;
  oPipeline->ShowFormEvent 	  = this->doPipelineForm ;
  oPipeline->LogErrorEvent    = this->doPipelineMessage ;
  oPipeline->LogWarningEvent  = this->doPipelineMessage ;

  prepareCommands() ;

  lstbxCommands->Items->AddStrings( oPipelineCommands ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::prepareCommands()
{
  oPipelineCommands = PipelineOperations()->Names ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::doPipelineMessage(
  const System::UnicodeString _message
)
{
	ShowMessage( _message ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::doPipelineForm(
  TGIS_PipelineOperationAbstract *_operation
)
{
	TGIS_PipelineParamsEditor *frm = new TGIS_PipelineParamsEditor( this ) ;
	try
    {
		if (frm->Execute( _operation, doPipelineHelp ) == mrOk) {
			mmoCode->Lines->Strings[oPipelineLine-1] = _operation->AsText() ;
		}
	}
	 __finally
	{
		delete  frm ;
	}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::doPipelineHelp(
  TObject *_sender,
  String _name
)
{
	AnsiString str = "https://docs.tatukgis.com/EDT5/guide:help:dkbuiltin:" + _name ;
	ShellExecute( 0, "open",
				  str.c_str(),
				 NULL, NULL, SW_SHOWNORMAL );
}

//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
	delete oPipeline ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::lstbxCommandsDblClick(TObject *Sender)
{
	oPipeline->ShowForm( lstbxCommands->Items->operator [](lstbxCommands->ItemIndex), 
						 mmoCode->CaretPos.Y ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::mmoCodeDblClick(TObject *Sender)
{
  oPipelineLine = mmoCode->CaretPos.Y + 1 ;
  oPipeline->SourceCode = mmoCode->Text ;
  oPipeline->ShowForm( oPipelineLine ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnExitClick(TObject *Sender)
{
  Application->Terminate() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnExecuteClick(TObject *Sender)
{
  oPipeline->SourceCode = mmoCode->Text ;
  oPipeline->Execute() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::mmoCodeClick(TObject *Sender)
{
	oPipelineLine = mmoCode->CaretPos.Y + 1 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnHelpClick(TObject *Sender)
{
  ShellExecute( 0, "open", "https://docs.tatukgis.com/DK11/doc:pipeline",
				NULL , NULL, SW_SHOWNORMAL );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnOpenClick(TObject *Sender)
{
	if (!dlgOpen->Execute()) exit ;

	TStringList *lstr = new TStringList() ;
	try
	{
		lstr->LoadFromFile( dlgOpen->FileName ) ;
		mmoCode->Lines->Text = lstr->Text ;
	}
	 __finally
	{
		delete lstr ;
	}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnSaveClick(TObject *Sender)
{
	if (!dlgSave->Execute()) exit ;

	TStringList *lstr = new TStringList() ;
	try
	{
		lstr->AddStrings( mmoCode->Lines) ;
		lstr->SaveToFile( dlgSave->FileName ) ;
	}
	 __finally
	{
		delete lstr ;
	}
}
//---------------------------------------------------------------------------

