//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  SQLLayer Sample - C++Builder VCL (header)
//  ==========================================
//  Declares the main form class for the SQLLayer sample.
//
//  An SQL layer (*.ttkls file) is a virtual layer definition that describes
//  how to retrieve spatial data from a relational database using a SQL query.
//  The .ttkls file contains the connection string, the SQL statement and field
//  mappings, and can be opened exactly like any other layer format supported
//  by TatukGIS DK.
//
//  Key concepts shown:
//    - Opening a .ttkls project file with TGIS_ViewerWnd->Open
//    - Fitting the view to the full data extent with FullExtent
//    - Switching the viewer between Zoom and Drag interaction modes
//
//  To adapt this sample to your own database, edit gistest.ttkls to supply
//  your connection string and SQL query.
//
//  Check project\options\directories in case of any problems during compilation
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
#include "VCL.GisControlLegend.hpp"  // Legend control (not used here but part of the DK UI set)
#include "GisViewer.hpp"              // Base TatukGIS viewer class
#include "VCL.GisViewerWnd.hpp"       // VCL windowed map viewer component
#include "GisTypesUI.hpp"             // UI types: TGIS_ViewerMode, TGIS_Color, etc.

#include "GisUtils.hpp"               // Utility helpers: GisSamplesDataDirDownload, etc.
#include "GisAllLayers.hpp"           // Registers all layer drivers (SHP, raster, SQL, …)
//---------------------------------------------------------------------------

/* Main form for the SQLLayer sample.
   Demonstrates advanced SQL database layer operations and styling. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;         // Toolbar hosting the navigation buttons
        TGIS_ViewerWnd *GIS ;        // TatukGIS map viewer — renders the SQL layer
        TStatusBar *StatusBar1 ;     // Status bar at the bottom of the window
        TImageList *ImageList1 ;     // Icon images used by the toolbar buttons
        TToolButton *btnFullExtent ; // Button: zoom to full data extent
        TToolButton *ToolButton2 ;   // Toolbar separator
        TToolButton *btnZoom ;       // Button: activate zoom interaction mode
        TToolButton *btnDrag ;       // Button: activate pan/drag interaction mode

        /// <summary>Opens the SQL layer project and zooms to full extent.</summary>
        void __fastcall FormCreate(TObject *Sender);
        /// <summary>Zooms the map to the full data extent.</summary>
        void __fastcall btnFullExtentClick(TObject *Sender);
        /// <summary>Activates rubber-band zoom interaction mode.</summary>
        void __fastcall btnZoomClick(TObject *Sender);
        /// <summary>Activates pan/drag interaction mode.</summary>
        void __fastcall btnDragClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

