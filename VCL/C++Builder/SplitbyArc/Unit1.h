//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to split shapes by arc.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include "GisTypes.hpp"
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTopology.hpp"
#include "GisTypesUI.hpp"
#include "System.Classes.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TPanel *paLeft;
  TGIS_ViewerWnd *GIS;
  TStatusBar *StatusBar1;
  TButton *btnLine;
  TButton *btnSplit;
  TGroupBox *gbAfterSplit;
  TLabel *lbInfo;
  void __fastcall btnLineClick(TObject *Sender);
  void __fastcall btnSplitClick(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
  void __fastcall GISMouseUp(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
  void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
    TGIS_LayerVector  *layerObj;        //layer for new shapes
    TGIS_ShapePolygon *shpPolygon;      //shape for split
    TGIS_ShapeArc     *shpArc;          //shape for line
    TGIS_LayerVector  *layerPolygon;
    TGIS_LayerVector  *layerArc;

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
