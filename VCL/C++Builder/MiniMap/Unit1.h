//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to build minimap.
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
#include <Dialogs.hpp>
#include <Menus.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TImageList *ImageList1;
  TToolBar *ToolBar1;
  TToolButton *btnFullExtent;
  TToolButton *btnZoomIn;
  TToolButton *btnZoomOut;
  TToolButton *ToolButton1;
  TToolButton *btnZoom;
  TToolButton *btnSelect;
  TToolButton *btnDrag;
  TStatusBar *StatusBar1;
  TPanel *paLeft;
  TGroupBox *gbCanvasInfo;
  TLabel *lbP1;
  TLabel *lbP2;
  TLabel *lbP3;
  TLabel *lbP4;
  TGIS_ViewerWnd *GISm;
  TGIS_ViewerWnd *GIS;
  TPopupMenu *PopupMenu1;
  TMenuItem *Rectcolor1;
  TMenuItem *colorR;
  TMenuItem *Outlinecolor1;
  TMenuItem *colorO;
  TColorDialog *dlgColor;
  void __fastcall btnFullExtentClick(TObject *Sender);
  void __fastcall btnZoomInClick(TObject *Sender);
  void __fastcall btnZoomOutClick(TObject *Sender);
  void __fastcall btnZoomClick(TObject *Sender);
  void __fastcall btnSelectClick(TObject *Sender);
  void __fastcall btnDragClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall GISVisibleExtentChange(TObject *_sender);
  void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall GISmMouseUp(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall GISmMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall GISmMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall colorRClick(TObject *Sender);
  void __fastcall colorOClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  TGIS_Shape *minishp;              //minimap shape
  TGIS_Shape *minishpo;             //minimap shape outline
  boolean     fminiMove;            //flag for move mini rectangle
  TGIS_Point  lP1,lP2,lP3,lP4;      //large map extent points
  void _fastcall miniMapRefresh( TObject *Sender);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
