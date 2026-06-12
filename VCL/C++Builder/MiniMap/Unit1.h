//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  MiniMap sample — demonstrates creating a synchronized overview/minimap window (C++Builder/VCL).
//
//  What the sample shows:
//    - Creating a second TGIS_ViewerWnd control as an overview minimap
//    - Loading the same dataset into both main viewer and minimap
//    - Synchronizing extent between viewers: changes in main view update minimap bounds
//    - Displaying a tracking rectangle in minimap showing the current main view extent
//    - Using a separate in-memory vector layer to hold the minimap bounds rectangle
//    - Drawing the bounds rectangle with distinctive styling (red outline, semi-transparent fill)
//    - Updating rectangle geometry when main view pans or zooms
//    - Using OnExtentChanged event to trigger minimap synchronization
//    - Handling mouse events in minimap to navigate the main view
//    - Scaling minimap to show full dataset extent while main view zooms freely
//    - Customizing rectangle colour via context menu (Rect color, Outline color)
//    - Lock types: Projection (layer coordinate system) vs Extent (world coordinates)
//
//  Key TatukGIS API concepts shown here:
//    TGIS_ViewerWnd              - main visual map control + synchronized secondary control
//    TGIS_LayerVector            - vector layer for bounds rectangle
//    TGIS_Shape                  - polygon representing current main view bounds
//    TGIS_Params                 - styling parameters for bounds rectangle
//    OnExtentChanged             - event triggered when view pans/zooms
//    FullExtent                  - zoom to layer extent (for minimap)
//    VisibleExtent / SetExtent   - synchronize viewer extents programmatically
//    TGIS_Lock                   - coordinate system locking (Projection vs Extent)
//    ContextMenuStrip            - custom colour selection menu
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
