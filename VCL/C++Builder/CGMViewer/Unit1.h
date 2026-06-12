/*
 * CGMViewer sample — demonstrates rendering CGM (Computer Graphics Metafile) symbol files
 * as point markers using SymbolList.
 *
 * A FileListBox shows *.cgm files from the Symbols directory.  Selecting one renders it
 * centred on a crosshair layer sized to fit two-thirds of the smaller viewer dimension.
 * Button1 rotates the marker by 90° each click.
 */
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
#include <Graphics.hpp>
#include <FileCtrl.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1 ;
        TGIS_ViewerWnd *GIS ;
        TPanel *Panel1 ;
        TFileListBox *FileList ;
        TDirectoryListBox *DirectoryListBox1 ;
        TToolBar *ToolBar1;
        TToolButton *ToolButton1;
        TButton *Button1;
        void __fastcall FormCreate(TObject *Sender);            /* Create crosshair layer; navigate to Symbols dir */
        void __fastcall FormResize(TObject *Sender);            /* Redraw symbol at new size */
        void __fastcall DirectoryListBox1Change(TObject *Sender); /* Sync FileListBox to selected directory */
        void __fastcall FileListClick(TObject *Sender);         /* Redraw symbol on CGM file selection */
        void __fastcall Button1Click(TObject *Sender);          /* Rotate symbol by 90 degrees */

private:	// User declarations
    TGIS_Shape  *shp  ;
    void drawSymbol() ;

public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
