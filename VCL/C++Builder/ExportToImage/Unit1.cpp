//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// ExportToImage sample - C++Builder VCL
//
// Implementation of TForm1 event handlers and export logic.
// See Unit1.h for class declarations and documentation.
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------

/** Default constructor required by the VCL framework. */
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

/** Truncation helper: removes the fractional part of d, preserving the sign.
 *  Used when computing integer percentage values for the progress caption. */
double __fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}

/**
 * Progress callback fired by TGIS_ViewerWnd while it is busy processing data.
 *
 * _pos and _end carry the current and maximum progress values. When _end <= 0
 * the operation has not yet provided a meaningful total, so the caption shows
 * a plain "Export to image" title instead of a percentage. Calling
 * Application->ProcessMessages() yields to the Windows message pump so the
 * form remains responsive during lengthy export operations.
 */
void __fastcall TForm1::GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
  AnsiString str ;

  if ( _end <= 0 )
    Caption = "Export to image" ;
  else
    // Display integer percentage in the title bar so the user can track progress
    Caption = str.sprintf( "Export to image %d%%", trunc( _pos / _end * 100.0 )  );

  Application->ProcessMessages() ;
}

//---------------------------------------------------------------------------
/** Returns the pixel format of the currently selected T_capability. */
TGIS_PixelFormat __fastcall TForm1::getExp_pixelformat()
{
  return current_obj->PixelFormat;
};

//---------------------------------------------------------------------------
/** Returns the sub-format index of the currently selected T_capability. */
int __fastcall TForm1::getExp_subformat()
{
  return int(current_obj->Subformat);
}

//---------------------------------------------------------------------------
/**
 * Initialise the form on creation: select Image mode and load the default
 * satellite layer.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  rbImage->Checked = True ;
  rbImageClick( this ) ;
}

//---------------------------------------------------------------------------

/**
 * Perform the raster export.
 *
 * Steps:
 * 1. Retrieve the chosen TGIS_LayerPixelSubFormat from cbType, or fall back
 *    to lpx->DefaultSubFormat if nothing is selected.
 * 2. Set FExtent from the user's extent choice (full map vs. visible viewport).
 * 3. Calculate pixWidth/pixHeight according to the selected quality preset.
 * 4. Call lpx->ImportLayer to resample the source layer into the output file.
 *
 * Note: the doc/web preset logic in this C++Builder version has rbQdoc and
 * rbQweb swapped relative to what their labels suggest; this mirrors the
 * original source and can be corrected independently.
 */
void __fastcall TForm1::actSaveExecute(TObject *Sender)
{
  TGIS_LayerPixelSubFormat c;

  Application->ProcessMessages() ;

  // Resolve the output sub-format (pixel depth, compression, etc.)
  if ( cbType->ItemIndex >= 0 )
  {
    c = ( ( T_capability *)(cbType->Items->Objects[cbType->ItemIndex]) )->C ;
  }
  else
  {
    c = lpx->DefaultSubFormat ;  // Use the format's natural default
  }

  // Determine the geographic area to export
  if (rbExtentMap->Checked)
  {
    FExtent = GIS->Extent;          // Full bounding box of all loaded layers
  }
  else
  {
    FExtent = GIS->VisibleExtent;   // Current viewport in map coordinates
  }

  // --- Resolution strategy ---
  if (rbQbest->Checked)
  {
    // Match native pixel density of the highest-resolution source layer
    ValuesInit();
  }
  else if (rbQdoc->Checked)
  {
    // Web preset: fixed pixel width (640 px), 96 DPI
    ppi      = DEFAULT_PPI_WEB;
    pixWidth = DEFAULT_WIDTHPIX_WEB;

    if (!((FExtent.XMax - FExtent.XMin) == 0))
    {
      // Height derived from geographic aspect ratio of the chosen extent
      pixHeight = (FExtent.YMax - FExtent.YMin) /
                  (FExtent.XMax - FExtent.XMin) * pixWidth;
    }
    else
    {
      pixHeight = 2;
      pixHeight = 2;
    }
    // Derive physical dimensions from pixel count / DPI
    ValuesWH();
  }
  else if (rbQweb->Checked)
  {
    // Document preset: fixed physical width (6.3 inches), 300 DPI
    ppi      = DEFAULT_PPI_DOC;
    expWidth = DEFAULT_WIDTH_DOC_INCH;
    if ((FExtent.XMax - FExtent.XMin) == 0)
    {
      // Aspect ratio preserved from the geographic extent
      expHeight = (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth;
    }
    else
    {
      expWidth  = 2;
      expHeight = 2;
    }
    // Convert physical inches * DPI -> pixel dimensions
    ValuesWHpix();
  }

  // ImportLayer resamples lstp (source) into lpx (output file):
  //   lstp         - source TGIS_LayerPixel to read pixel data from
  //   lstp->Extent - full geographic coverage of the source
  //   lstp->CS     - coordinate system, ensuring correct spatial referencing
  //   pixWidth/pixHeight - output raster dimensions in pixels (rounded)
  //   c            - sub-format descriptor (bit depth, compression, etc.)
  lpx->ImportLayer( lstp, lstp->Extent, lstp->CS,
                    round( pixWidth  ),
                    round( pixHeight ),
                    c
                   ) ;
  ShowMessage("File exported!");
}

//---------------------------------------------------------------------------
/**
 * Open the file save dialog, create the output pixel layer via GisCreateLayer,
 * and populate the cbType combobox with the sub-formats supported by the
 * chosen file format.
 *
 * GisCreateLayer inspects the file extension to select the correct
 * TGIS_LayerPixel subclass (JPEG driver, PNG driver, FLT grid, etc.) and
 * returns an empty layer ready to receive raster data via ImportLayer.
 */
void __fastcall TForm1::btnSelectFileClick(TObject *Sender)
{
  TGIS_LayerPixelSubFormatList *clst ;
  TGIS_LayerPixelSubFormat     c     ;
  TObject *obj ;
  T_capability *cap ;

  // Show the appropriate save dialog based on the current data-type selection
  if (rbImage->Checked)
  {
    if ( !dlgSaveImage->Execute() )
    {
      return ;
    }

    edtFile->Text = dlgSaveImage->FileName;
    edtFile->Hint = dlgSaveImage->FileName;
  }
  else
  {
    if ( !dlgSaveGrid->Execute() )
    {
      return ;
    }

    edtFile->Text = dlgSaveGrid->FileName;
    edtFile->Hint = dlgSaveGrid->FileName;
  }
  cbType->Clear();

  try{
    // GIS->Items->Items[0] is the primary (bottom-most) layer in the viewer
    lstp = ( TGIS_LayerPixel *) (GIS->Items->Items[0]) ;

    // GisCreateLayer selects the driver from the extension and returns an
    // empty TGIS_LayerPixel that will write to the specified output path.
    if (rbImage->Checked)
    {
      lpx = ( TGIS_LayerPixel * )(GisCreateLayer( ExtractFileName( dlgSaveImage->FileName ),
                          dlgSaveImage->FileName ) ) ;
    }
    else
    {
        lpx = ( TGIS_LayerPixel * )( GisCreateLayer( ExtractFileName( dlgSaveGrid->FileName ),
                                dlgSaveGrid->FileName ) ) ;
    }

    // Capabilities lists all valid TGIS_LayerPixelSubFormat options for this format.
    // Each T_capability stores a deep copy so the entry remains valid after the
    // list is released.
    clst = lpx->Capabilities ;
    for( int i=0; i<clst->Count; i++)
    {
      c   = clst->Items[i];
      cap = new T_capability(c);  // Deep copy; owned via combobox Items->Objects
      cbType->AddItem( c.ToString(),
                       (TObject *)(cap)  ) ;
    }

    cbType->ItemIndex = 0 ;

    // Enable export controls now that a valid destination and layer exist
    btnSave->Enabled        = true;
    rbQbest->Enabled        = true;
    rbQdoc->Enabled         = true;
    rbQweb->Enabled         = true;
    rbExtentMap->Enabled    = true;
    rbExtentVisible->Enabled = true;
    cbType->Enabled         = true;

    rbExtentMap->Checked = true ;
    rbQbest->Checked     = true ;
  }
  catch ( const Exception& e ) {
    ShowMessage( e.Message ) ;
  }
}

//---------------------------------------------------------------------------
/**
 * Release T_capability objects stored in cbType->Items->Objects and free
 * the owner list to prevent memory leaks when the form is closed.
 */
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  cbType->Clear();
  FreeObjectNotNil( lst ) ;
}

//---------------------------------------------------------------------------
/**
 * Calculates the optimal output pixel dimensions for the "Best quality" preset.
 *
 * Scans all pixel layers in the viewer to find the one with the highest pixel
 * density (BitWidth / geographic extent width). The export pixel width is then
 * scaled so the chosen export extent is rendered at that same native density,
 * preserving the maximum detail available in the source data. Falls back to
 * DEFAULT_WIDTHPIX (4200 px) when no raster layer is loaded.
 */
void __fastcall TForm1::ValuesInit() {

  int i, j              ;
  TGIS_Layer *la        ;
  TGIS_LayerPixel *lp   ;
  double density        ;   // Pixel density (px/map-unit) of the best layer found
  double density0       ;   // Density of the previously examined layer
  double density1       ;   // Density of the current layer being examined
  int widthpix          ;   // Computed output width in pixels
  double ext_delta      ;   // Ratio: export extent width / best-layer extent width
  double ext_width      ;   // Geographic width of the layer under examination

  density0 = 0 ;
  density  = density0 ;
  ppi = DEFAULT_PPI;
  j = 0 ;

  // Iterate from the top layer downwards; keep the highest-density raster layer
  for ( i = GIS->Items->Count - 1 ; i>=0 ; i-- ) {
      la = ( TGIS_Layer * )( GIS->Items->Items[ i ] ) ;

      if ( la->InheritsFrom( __classid(TGIS_LayerPixel) ) ) {
         ext_width = la->Extent.XMax - la->Extent.XMin ;

         // BitWidth is the layer's native pixel width over its full extent;
         // dividing by geographic width gives pixels per map unit.
         density1 = ( ( TGIS_LayerPixel *)( la ))->BitWidth / ext_width ;
         if ( density1 > density0 ){
            density = density1 ;
            j = i ;              // Remember the index of the highest-density layer
         }
         density0 = density1 ;
      }
  }

  if ( density == 0 ) {
    // No raster layers found; use the predefined fallback pixel width
    widthpix = 4200 ;
  }
  else {
    la = ( TGIS_Layer *) ( GIS->Items->Items[ j ] ) ;
    ext_width = la->Extent.XMax - la->Extent.XMin ;

    // ext_delta is the fraction of the best layer's extent covered by FExtent.
    // Multiplying by BitWidth gives source pixels in that region, which is the
    // ideal export width to preserve native resolution without upscaling.
    ext_delta = ( FExtent.XMax - FExtent.XMin ) / ext_width ;

    lp = ( TGIS_LayerPixel *)( GIS->Items->Items[ j ] );
    widthpix = round ( ext_delta * lp->BitWidth ) ;
  }

  pixWidth = widthpix ;

  // Preserve geographic aspect ratio so the exported image is not distorted
  if ( ( FExtent.XMax - FExtent.XMin ) != 0 ){
    pixHeight = ( FExtent.YMax - FExtent.YMin ) /
                ( FExtent.XMax - FExtent.XMin ) * pixWidth;
  }
  else{
    // Zero-width extent guard: produce a minimal valid raster
    pixWidth  = 2 ;
    pixHeight = 2 ;
  }
}

/**
 * Converts pixel dimensions to physical (inch) dimensions and preserves the
 * geographic aspect ratio.
 *
 * expWidth  = pixWidth / ppi  (inches wide at the chosen DPI setting)
 * expHeight = expWidth * (geographic height / geographic width)
 */
void __fastcall TForm1::ValuesWH()
{
  expWidth = pixWidth / ppi;

  if (!((FExtent.XMax - FExtent.XMin) == 0))
  {
    expHeight = (FExtent.YMax - FExtent.YMin)/
                (FExtent.XMax - FExtent.XMin) * expWidth;
  }
  else
  {
    expWidth  = 2;
    expHeight = 2;
  }
}

//---------------------------------------------------------------------------
/**
 * Converts physical (inch) dimensions to pixel dimensions and preserves the
 * geographic aspect ratio.
 *
 * pixWidth  = expWidth * ppi  (pixels wide given physical width and DPI)
 * pixHeight = pixWidth * (geographic height / geographic width)
 */
void __fastcall TForm1::ValuesWHpix()
{
  pixWidth = expWidth * ppi;

  if (!((FExtent.XMax - FExtent.XMin) == 0))
  {
    pixHeight = (FExtent.YMax - FExtent.YMin)/
                (FExtent.XMax - FExtent.XMin) * pixWidth;
  }
  else
  {
    pixWidth  = 2;
    pixHeight = 2;
  }
}

//---------------------------------------------------------------------------
/**
 * Switches the viewer to a DEM elevation grid (ADF format) and resets all
 * export controls to their disabled / empty state.
 *
 * The hdr.adf is an ESRI Arc/Info Binary Grid header; DK opens the entire
 * dataset by pointing at that file. Grid export supports formats such as
 * Arc/Info FLT, ASCII GRD, and TatukGIS PixelStore (TTKPS).
 */
void __fastcall TForm1::rbGridClick(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\hdr.adf");
  edtFile->Text = "";
  cbType->Clear();
  // Disable all export controls until a valid destination file is chosen
  btnSave->Enabled         = false;
  rbQbest->Enabled         = false;
  rbQdoc->Enabled          = false;
  rbQweb->Enabled          = false;
  rbExtentMap->Enabled     = false;
  rbExtentVisible->Enabled = false;
  cbType->Enabled          = false;
}

//---------------------------------------------------------------------------
/**
 * Switches the viewer to the sample satellite image (world_8km.jpg) and
 * resets all export controls to their disabled / empty state.
 *
 * The world_8km.jpg is a global RGB mosaic at approximately 8 km per pixel,
 * demonstrating image-format export (JPEG, PNG, TIFF, BMP, TTKPS).
 */
void __fastcall TForm1::rbImageClick(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\VisibleEarth\\world_8km.jpg" );
  edtFile->Text = "";
  cbType->Clear();
  btnSave->Enabled         = false;
  rbQbest->Enabled         = false;
  rbQdoc->Enabled          = false;
  rbQweb->Enabled          = false;
  rbExtentMap->Enabled     = false;
  rbExtentVisible->Enabled = false;
  cbType->Enabled          = false;
}
