//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to GPS NMEA Unit.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "VCL.GisGps.hpp"
#include "VCL.GisFramework.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TGIS_GpsNmea *GPS;
  TMemo *Memo1;
  TComboBox *cbxCom;
  TComboBox *cbxBaud;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GPSPosition(TObject *Sender);
  void __fastcall cbxComChange(TObject *Sender);
  void __fastcall cbxBaudChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
