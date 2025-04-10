//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to display map hints.
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
#include <ImgList.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TStatusBar *StatusBar1;
  TGIS_ViewerWnd *GIS;
  TImageList *ImageList1;
  TToolButton *btnFullExtent;
  TToolButton *btnZoomIn;
  TToolButton *btnZoomOut;
  TToolButton *ToolButton4;
  TToolButton *btnHint;
  void __fastcall btnFullExtentClick(TObject *Sender);
  void __fastcall btnZoomInClick(TObject *Sender);
  void __fastcall btnZoomOutClick(TObject *Sender);
  void __fastcall btnHintClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall ToolBar1MouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
private:	// User declarations
public:		// User declarations
	String      hintField;          //name of field to display
	String      hintLayer;          // name of hint layer  

    Boolean     hintDisplay;        //display map hints flag
    TColor      hintColor;          //map hints color
    TColor      hintColorStd;       //standard hint color

  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
