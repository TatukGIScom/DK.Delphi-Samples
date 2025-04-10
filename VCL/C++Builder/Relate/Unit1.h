//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to compute relations beetwen two shapes.
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TStatusBar *StatusBar1;
  TPanel *paLeft;
  TGroupBox *gbShapes;
  TGroupBox *GroupBox1;
  TMemo *Relations;
  TLabel *Label1;
  TLabel *ShapeA;
  TLabel *Label3;
  TLabel *ShapeB;
  TButton *btnCheck;
  TGIS_ViewerWnd *GIS;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall btnCheckClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  TGIS_Shape *shpA;
  TGIS_Shape *shpB;
  TGIS_Shape *currshape;

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
