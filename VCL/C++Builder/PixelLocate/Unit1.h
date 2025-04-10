//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide basic pixel support.
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerJPG.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"
#include "GisLayerADF.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TGIS_ViewerWnd *GIS;
  TImageList *ImageList1;
  TPanel *paTop;
  TGroupBox *gbOriginal;
  TGroupBox *gbChannels;
  TLabel *lbRGBValueC;
  TPanel *paColorC;
  TGroupBox *gbBrightness;
  TTrackBar *tbBrightness;
  TMemo *Memo1;
	TButton *btnImage;
	TButton *btnGrid;
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall tbBrightnessChange(TObject *Sender);
	void __fastcall btnImageClick(TObject *Sender);
	void __fastcall btnGridClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
