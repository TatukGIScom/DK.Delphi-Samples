//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to select by circle.
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerVector.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include <Vcl.Buttons.hpp>

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1;
        TMemo *Memo1;
  TGIS_ViewerWnd *GIS;
	TToolBar *ToolBar1;
	TSpeedButton *btnRect;
	TSpeedButton *btnCircle;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
	void __fastcall GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
		  TGIS_DrawMode _mode);
private:	// User declarations
		TPoint            oldPos1;
		TPoint			  oldPos2;
		Integer           oldColor;
		Integer			  oldRadius ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
