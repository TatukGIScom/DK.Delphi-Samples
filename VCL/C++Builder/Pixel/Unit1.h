//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  Pixel - demonstrates how to open and display raster (pixel) layers using
//  different rendering modes provided by TatukGIS.
//
//  The sample loads a pre-built .ttkproject file that contains a raster layer
//  and lets the user switch between rendering profiles via a combo box:
//    - Normal, Normal with histogram, Grayscale, Transparent,
//      Colorize, Inversion, Inversion by RGB.
//
//  Key TatukGIS API concepts shown here:
//    - TGIS_ViewerWnd  : the main map viewer control
//    - GisSamplesDataDirDownload() : resolves the sample-data root path
//    - GIS->Open()     : opens a project or raster file into the viewer
//    - GIS->FullExtent(): zooms to fit all loaded layers
//    - TGIS_ViewerMode : Zoom (rubber-band) or Drag (pan) interaction mode
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* Main form for the Pixel sample application.
   Demonstrates loading and displaying a raster pixel layer through
   various rendering project configurations. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;          // Toolbar housing navigation buttons
        TGIS_ViewerWnd *GIS ;         // TatukGIS map viewer control
        TStatusBar *StatusBar1 ;      // Status bar at the bottom
        TComboBox *ComboProject ;     // Drop-down for selecting a rendering project
        TToolButton *btnFullExtent ;  // Zoom to full extent of all loaded layers
        TToolButton *btnZoom ;        // Switch to rubber-band zoom mode
        TToolButton *btnDrag ;        // Switch to pan/drag mode
        TToolButton *ToolButton4 ;    // Toolbar separator
        TToolButton *ToolButton5 ;    // Toolbar separator
        TImageList *ImageList1 ;      // Icons used by the toolbar buttons

        // Called once when the form is first created; selects the first project
        void __fastcall FormCreate(TObject *Sender);
        // Zooms the view to fit all loaded layers
        void __fastcall btnFullExtentClick(TObject *Sender);
        // Opens the project selected in the combo box
        void __fastcall ComboProjectChange(TObject *Sender);
        // Switches the viewer to rubber-band zoom interaction mode
        void __fastcall btnZoomClick(TObject *Sender);
        // Switches the viewer to pan/drag interaction mode
        void __fastcall btnDragClick(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
