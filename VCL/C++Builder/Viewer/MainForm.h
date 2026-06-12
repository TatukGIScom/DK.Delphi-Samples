//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
  Viewer Sample — Full-featured GIS document viewer with layer management and file export.

  Key concepts illustrated:
    - Multi-window GIS application (main viewer + floating windows)
    - Project file loading (.ttkproject, legacy .ttkgp)
    - Layer management: load, remove, reorder, style
    - Legend control: toggle layer visibility, nested groups
    - Coordinate system display and control
    - Zoom navigation: full extent, zoom box, pan modes
    - Print preview and image export
    - Layer editing in separate forms
    - File I/O: open projects, append layers, export to various formats
    - Batch layer operations (save all, export selections)
    - Multi-renderer support (GDI, GDI+, Direct2D)
    - Color picker for layer styling
    - Status bar with coordinate display
    - Tabbed or dockable layer/attribute panels

  User workflow:
    1. Open a project file (GIS.Open)
    2. Browse layers in the legend panel
    3. Toggle layer visibility by clicking in legend
    4. Click legend items to select/highlight layers
    5. Use zoom buttons or draw rectangles to zoom
    6. Right-click layers for styling, editing, export options
    7. Preview or print the map
    8. Export map as image
    9. Close project or append additional layers

  Core features:
    - File menu: Open projects, append layers, export, print, exit
    - View menu: zoom modes (full extent, zoom box, pan), coordinate system
    - Layer operations: add, remove, edit, style, reorder, visibility
    - Legend: hierarchical display of layers and layer groups
    - Coordinate system selector: change working projection
    - Print preview: before/after print dialog
    - Image export: save visible map as PNG, JPEG, BMP, GIF, TIFF
    - Editor forms: separate window for editing layer properties

  Key API:
    - TGIS_ViewerWnd: main map viewer
    - TGIS_ControlLegend: layer tree display and interaction
    - TGIS_ControlCSSystem: coordinate system selector
    - TGIS_LayerVector/TGIS_LayerPixel: vector and raster layers
    - GisCreateLayer: auto-detect layer type from file
    - TGIS_PixelExportManager: export viewer to image format
    - PrintPreview: map printing with preview

  Actions/Menu structure:
    - File: Open, Append, Export, Print, Exit
    - View: FullExtent, ZoomMode, DragMode, SelectMode, CoordSystem
    - Layer: Add, Remove, Edit, Style
    - Save: SaveToImage, SaveAll (layers)
*/

//  How to prepare small coverage previewer.
//  Main window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ComCtrls.hpp>
#include <Menus.hpp>
#include <ToolWin.hpp>

#include "GisAllLayers.hpp"
#include "GisPixelExportManager.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"
#include "VCL.GisControlCSSystem.hpp"
#include "VCL.GisRendererGdiPlus.hpp"
#include "GisControlPrintPreviewSimple.hpp"

//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
  TImageList *ImageList1;
  TActionList *ActionList1;
  TAction *actFile;
  TAction *actFileOpen;
  TAction *actFileExport;
  TAction *actFilePrint;
  TAction *actFileExit;
  TAction *actViewFullExtent;
  TAction *actViewZoomMode;
  TAction *actViewDragMode;
  TAction *actViewSelectMode;
  TAction *actView;
  TAction *actAdd;
  TAction *actSearch;
  TAction *actClose;
  TAction *actEditFile;
  TAction *actSaveToImage;
  TAction *actSaveAll;
  TOpenDialog *dlgFileOpen;
  TOpenDialog *dlgFileAppend;
  TSaveDialog *dlgSaveImage;
  TSaveDialog *dlgFileSave;
  TTimer *tmrCreated;
  TColorDialog *ColorDialog1;
  TMainMenu *MainMenu1;
  TMenuItem *mnuFile;
  TMenuItem *mnuFileOpen;
  TMenuItem *Add1;
  TMenuItem *actEditFile1;
  TMenuItem *mnuExportLayer;
  TMenuItem *mnuFilePrint;
  TMenuItem *Close1;
  TMenuItem *N1;
  TMenuItem *mnuFileExit;
  TMenuItem *mnuView;
  TMenuItem *actFullExtent1;
  TMenuItem *N2;
  TMenuItem *mnuZoomMode;
  TMenuItem *mnutDragMode;
  TMenuItem *mnuSlectMode;
  TMenuItem *Options1;
  TMenuItem *UseRTree1;
  TMenuItem *Color1;
  TMenuItem *Search1;
  TMenuItem *Findshape1;
  TToolBar *ToolBar2;
  TToolButton *btnFileOpen;
  TToolButton *btnAppend;
  TToolButton *btnClose;
  TToolButton *btnFilePrint;
  TToolButton *ToolButton1;
  TToolButton *btnSaveToImage;
  TToolButton *ToolButton2;
  TToolButton *btnViewFullExtent;
  TToolButton *btnViewZoomMode;
  TToolButton *btnViewDragMode;
  TToolButton *ToolButton6;
  TToolButton *btnViewSelectMode;
  TToolButton *btnSearch;
  TToolButton *btnSaveAll;
  TStatusBar *stsBar;
  TGIS_ViewerWnd *GIS;
  TSplitter *Splitter1;
  TGIS_ControlLegend *GIS_ControlLegend;
	TToolButton *btnChangeMode;
	TToolButton *btnCS;
	TGIS_ControlPrintPreviewSimple *GIS_ControlPrintPreviewSimple;
  TAction *actCS;
  TAction *actChangeMode;
  void __fastcall tmrCreatedTimer(TObject *Sender);
  void __fastcall FormShow(TObject *Sender);
  void __fastcall GISBusy(const TObject *_sender, int _pos,
          int _end, bool &_abort);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall dlgFileSaveTypeChange(TObject *Sender);
  void __fastcall actFileOpenExecute(TObject *Sender);
  void __fastcall actFileExportExecute(TObject *Sender);
  void __fastcall actFilePrintExecute(TObject *Sender);
  void __fastcall actFileExitExecute(TObject *Sender);
  void __fastcall actViewFullExtentExecute(TObject *Sender);
  void __fastcall actViewZoomModeExecute(TObject *Sender);
  void __fastcall actViewDragModeExecute(TObject *Sender);
  void __fastcall actViewSelectModeExecute(TObject *Sender);
  void __fastcall ActionList1Update(TBasicAction *Action, bool &Handled);
  void __fastcall UseRTree1Click(TObject *Sender);
  void __fastcall Color1Click(TObject *Sender);
  void __fastcall actAddExecute(TObject *Sender);
  void __fastcall actSearchExecute(TObject *Sender);
  void __fastcall actCloseExecute(TObject *Sender);
  void __fastcall actEditFileExecute(TObject *Sender);
  void __fastcall actSaveToImageExecute(TObject *Sender);
  void __fastcall actSaveAllExecute(TObject *Sender);
	void __fastcall btnChangeModeClick(TObject *Sender);
  void __fastcall actCSExecute(TObject *Sender);
  void __fastcall actChangeModeExecute(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TfrmMain(TComponent* Owner);
  void __fastcall OpenCoverage  ( AnsiString _path ) ;
  void __fastcall AppendCoverage( AnsiString _path ) ;
  void __fastcall do_reg ( TRegistry *reg, AnsiString _path, int _type ) ;
  void __fastcall reg_ext( TRegistry *reg, AnsiString _ext ) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
