//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// ExportToImage sample - C++Builder VCL
//
// Demonstrates how to export a GIS map layer to a raster image or a numeric
// elevation grid using the TatukGIS Developer Kernel API.
//
// Key concepts shown:
//   - Loading raster imagery (JPEG) and DEM/elevation grids (ADF) into a
//     TGIS_ViewerWnd VCL control.
//   - Creating a new output TGIS_LayerPixel via GisCreateLayer, which selects
//     the appropriate driver from the file extension.
//   - Querying lpx->Capabilities (TGIS_LayerPixelSubFormatList) to discover the
//     sub-formats (pixel depth, compression, etc.) supported by the target format.
//   - Controlling export resolution via three strategies:
//       * Best quality  - pixel size matched to the highest-density source layer.
//       * For document  - fixed physical paper width at 300 DPI.
//       * For Web       - fixed pixel width (640 px) at 96 DPI.
//   - Controlling export spatial coverage through full or visible extent.
//   - Performing the raster conversion with TGIS_LayerPixel::ImportLayer, which
//     resamples the source layer into the target at the requested pixel size.
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ActnList.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <stdio.h>
#include "GisAllLayers.hpp"
#include "GisClasses.hpp"
#include "GisEditor.hpp"
#include "GisLayer.hpp"
#include "GisLayerPixel.hpp"
#include "GisRegistredLayers.hpp"
#include "GisResource.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include <System.Actions.hpp>

// C++ does not have a built-in round() that returns int in all older compilers;
// this macro adds 0.5 before truncating to implement positive-value rounding.
#define round(a) int((a)+0.5)

// --- Resolution / dimension constants ---

//! Default PPI for best-quality and document export modes.
//! 300 DPI is the standard minimum for print-quality raster output.
#define  DEFAULT_PPI              300

//! Screen/web resolution in DPI. 96 PPI is the standard Windows screen DPI
//! and produces compact images suitable for web display.
#define  DEFAULT_PPI_WEB          96

//! Document print resolution in DPI.
#define  DEFAULT_PPI_DOC         300

//! Fallback output width in pixels when no raster layer is present to derive
//! a natural resolution. 4200 px at 300 DPI = 14-inch wide image.
#define  DEFAULT_WIDTHPIX        4200

//! Default pixel width for the web export profile (640 px wide).
#define  DEFAULT_WIDTHPIX_WEB    640

//! Document page-width references (160 mm / 16 cm / 6.3 in = typical A4 text area).
#define  DEFAULT_WIDTH_DOC_MM    160
#define  DEFAULT_WIDTH_DOC_CM    16
#define  DEFAULT_WIDTH_DOC_INCH  6.3

// Unit selector constants (reserved for potential future use)
#define  UNITS_MM    0
#define  UNITS_CM    1
#define  UNITS_INCH  2

//---------------------------------------------------------------------------
/**
 * Thin wrapper that deep-copies a TGIS_LayerPixelSubFormat descriptor.
 *
 * Each entry in the cbType combobox corresponds to one T_capability instance
 * stored via AddItem. The deep copy (via CreateCopy()) ensures the descriptor
 * remains valid even after the originating TGIS_LayerPixelSubFormatList is
 * released or reused by the DK runtime.
 */
class T_capability {
  public:
    /** The wrapped sub-format descriptor (pixel depth, compression, etc.). */
    TGIS_LayerPixelSubFormat C ;

    /** Constructs a T_capability by deep-copying the given sub-format. */
    T_capability( TGIS_LayerPixelSubFormat _c ) ;
};

T_capability::T_capability( TGIS_LayerPixelSubFormat _c ){
    C = _c.CreateCopy();
}

/**
 * Main VCL form for the ExportToImage sample.
 *
 * Lets the user choose between a satellite image and an elevation grid,
 * pick an output file and sub-format, select resolution and extent options,
 * then export the raster data to disk.
 */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TButton           *btnSave           ;   // Triggers the export action
    TActionList       *actlMain          ;
    TAction           *actSave           ;   // Action bound to btnSave
    TGroupBox         *gbFile            ;   // File path group
    TEdit             *edtFile           ;   // Displays the chosen output file path
    TGroupBox         *gbCompression     ;   // Format/compression options group
    TGroupBox         *gbSize            ;   // Resolution options group
    TRadioButton      *rbQbest           ;   // Best quality preset
    TRadioButton      *rbQdoc            ;   // Document (print) quality preset
    TRadioButton      *rbQweb            ;   // Web (screen) quality preset
    TGroupBox         *GroupBox1         ;   // Options group
    TLabel            *lbFormat          ;
    TComboBox         *cbType            ;   // Lists available TGIS_LayerPixelSubFormats
    TGIS_ViewerWnd    *GIS               ;   // Interactive map viewer
    TRadioButton      *rbExtentMap       ;   // Export the full map extent
    TRadioButton      *rbExtentVisible   ;   // Export only the current viewport
    TLabel            *Label1            ;
    TButton           *btnSelectFile     ;   // Opens the save dialog
    TRadioButton      *rbImage           ;   // Switch viewer to raster image mode
    TRadioButton      *rbGrid            ;   // Switch viewer to elevation grid mode
    TSaveDialog       *dlgSaveGrid       ;   // Save dialog for grid formats
    TSaveDialog       *dlgSaveImage      ;   // Save dialog for image formats

    // VCL event handlers
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
    void __fastcall rbImageClick(TObject *Sender);
    void __fastcall rbGridClick(TObject *Sender);
    void __fastcall btnSelectFileClick(TObject *Sender);
    void __fastcall actSaveExecute(TObject *Sender);

    /** Progress callback fired while the viewer is busy.
     *  Updates the caption with a percentage so the user can track long exports. */
    void __fastcall GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);

private:
    /** Pointer to the currently selected T_capability in cbType (used for
     *  reading PixelFormat and Subformat during export). */
    TGIS_LayerPixelSubFormat *current_obj ;

    /** Owner list for the T_capability objects; freed on form close
     *  to avoid memory leaks from the combobox Items.Objects. */
    TObjectList              *lst ;

    /** Geographic bounding box used for the export operation. Set from either
     *  GIS->Extent (full) or GIS->VisibleExtent (current viewport). */
    TGIS_Extent               FExtent ;

    bool                      FExtentAuto ;

    /** Pixels per inch for the current export mode. */
    int                       ppi;

    /** Output image dimensions in pixels. Passed to ImportLayer.
     *  Aspect ratio is always derived from the geographic extent. */
    double                    pixWidth;
    double                    pixHeight;

    /** Physical output size in inches (used by the document preset to
     *  derive pixel dimensions from PPI). */
    int                       expWidth;
    int                       expHeight;

    // --- Private helper accessors ---
    String   __fastcall getExp_path() ;
    int      __fastcall getExp_width() ;
    int      __fastcall getExp_height();
    unsigned __fastcall getExp_quality();
    TGIS_PixelFormat __fastcall getExp_pixelformat();
    int      __fastcall getExp_subformat();
    int      __fastcall getExp_ppi() ;

    /** Truncation helper used when computing progress percentages. */
    double   __fastcall trunc(double d) ;
    Extended __fastcall ImageSizeCalculate() ;

    /** Calculate pixWidth/pixHeight for the "Best quality" preset.
     *  Finds the layer with the highest pixel density and scales the output
     *  to match it. Falls back to DEFAULT_WIDTHPIX when no raster layer exists. */
    void __fastcall ValuesInit();

    /** Convert pixWidth/ppi -> expWidth (physical inches) and compute expHeight
     *  to maintain the geographic aspect ratio of FExtent. */
    void __fastcall ValuesWH();

    /** Convert expWidth * ppi -> pixWidth (pixels) and compute pixHeight to
     *  maintain the geographic aspect ratio of FExtent. */
    void __fastcall ValuesWHpix();

public:
    __fastcall TForm1(TComponent* Owner);

    /** Source pixel layer loaded in the viewer; resampled into lpx during export. */
    TGIS_LayerPixel   *lstp ;

    /** Target pixel layer that writes to the chosen output file.
     *  Created by GisCreateLayer and populated via ImportLayer. */
    TGIS_LayerPixel   *lpx  ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

