//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to display map hints.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------


#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "frmHint.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom / 2;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnHintClick(TObject *Sender)
{
  //AnsiString s;
  frmHints = new TfrmHints(0);

  if (frmHints->ShowModal() == mrCancel) return;

  hintDisplay = frmHints->chkShow->Checked;
  hintColor   = frmHints->paColor->Color;
  hintField   = frmHints->lbFields->Items->Strings[frmHints->lbFields->ItemIndex];
  hintLayer   = frmHints->cbLayers->Items->Strings[frmHints->cbLayers->ItemIndex];

  if (frmHints) delete frmHints;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  hintDisplay  = true;
  hintColor    = clYellow;
  hintField    = "PPPTNAME" ;
  hintLayer    = "city1" ;
  hintColorStd = Application->HintColor;
  Application->ShowHint = true;           //definitions for hints
  Application->HintPause = 50;            //default : 500
  Application->HintShortPause = 50;       //default : 50
  Application->HintHidePause = 2000;      //default : 2500
  Application->HintColor = hintColor;


  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ToolBar1MouseMove(TObject *Sender,
	  TShiftState Shift, int X, int Y)
{
  Application->HintColor = hintColorStd;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift,
	  int X, int Y)
{
  TGIS_Point          ptg ;
  TGIS_Shape         *shp ;
  String              str ;
  TGIS_Layer         *la  ;
  TGIS_LayerVector   *lv  ;


  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;

  la = ( TGIS_Layer *) GIS->Get( hintLayer )  ;

  if ( la == NULL ) return ;
  if (!la->InheritsFrom( __classid(TGIS_LayerVector) ) ) return ;

  lv = (TGIS_LayerVector *)la ;


  ptg = GIS->ScreenToMap( Point( X, Y ) );
  shp = (TGIS_Shape *)( lv->Locate( ptg, 5/GIS->Zoom ) ) ; // 5 pixels precision
  if (shp == NULL) {
	 GIS->Hint = "";
	 GIS->ShowHint = false;
  }
  else if (hintDisplay) {
	 Application->HintColor = hintColor;
	 str = shp->GetField(hintField);
	 GIS->Hint = str;
	 GIS->ShowHint = true;
	 Application->ActivateHint( ClientToScreen( Point(X + 10,Y - 10) ) );
	 #ifdef __BCPLUSPLUS__  >= 0x0640
	   str = str.sprintf( L"x: %.4f   y: %.4f", ptg.X, ptg.Y ) ;
	 #else
	   str = str.sprintf(  "x: %.4f   y: %.4f", ptg.X, ptg.Y ) ;
	 #endif
     StatusBar1->SimpleText = str;
  }

}
//---------------------------------------------------------------------------

