//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to use GPS Nmea unit.
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
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <SyncObjs.hpp>
#include <ActnList.hpp>
#include <ImgList.hpp>
#include <DB.hpp>
#include "Vcl.GisGps.hpp"
#include "GisViewer.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include "GisRegistredLayers.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TPanel *paLeft;
  TGIS_GpsNmea *GPS;
  TPanel *paInfo;
  TGIS_ViewerWnd *GIS;
  TToolButton *btnSave;
  TToolButton *btnRecord;
  TToolButton *ToolButton3;
  TEdit *edtPoint;
  TButton *btnAdd;
  TActionList *actList;
  TAction *actAdd;
  TAction *actRecord;
  TAction *actSave;
  TToolButton *ToolButton4;
  TComboBox *cbxCom;
  TComboBox *cbxBaud;
  TImageList *ImageList1;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GPSPosition(TObject *Sender);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall cbxComChange(TObject *Sender);
  void __fastcall actAddExecute(TObject *Sender);
  void __fastcall actSaveExecute(TObject *Sender);
  void __fastcall actRecordExecute(TObject *Sender);
  void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
  void __fastcall cbxBaudChange(TObject *Sender);
  void __fastcall actListUpdate(TBasicAction *Action, bool &Handled);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  TGIS_Shape  *currShape;
  TGIS_Point  lastPointGps;
  TGIS_Point  lastPointMap;


};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;

extern void MyInit(void);
extern void MyFinal(void);
//---------------------------------------------------------------------------
#endif
