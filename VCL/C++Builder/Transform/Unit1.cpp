//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Transform sample - Polynomial georeferencing of a raster image.
// C++Builder / VCL edition.
//
// This sample demonstrates how to georeference (rectify) an unregistered
// raster image using the TatukGIS DK polynomial transform API:
//
//   TGIS_TransformPolynomial
//     Maps pixel (source) coordinates to real-world (target) coordinates
//     using ground-control points (GCPs) and a fitted polynomial.
//     First order = affine: translation, rotation, scale, shear.  Min 3 GCPs.
//
//   TGIS_LayerPixel->Transform
//     Attaching a transform causes the DK to warp the image on-the-fly at
//     render time without modifying the source file.
//
//   CuttingPolygon
//     A WKT polygon in source/pixel coordinates that masks the visible area
//     of the raster to a region of interest.
//
// Workflow:
//   btnTransformClick - 4-GCP first-order polynomial + CRS (EPSG 102748).
//   btnCutClick       - Same GCPs + CuttingPolygon masking the image.
//   btnSaveClick      - Save current transform to a ".trn" sidecar file.
//   btnLoadClick      - Reload a previously saved transform sidecar.
//
// Data: Samples\Rectify\satellite.jpg  (an unrectified aerial/satellite image)
//
// Check project\options\directories in case of any problems during compilation.
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
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

/*
 * btnCutClick
 * -----------
 * Applies a first-order polynomial transform with four corner GCPs and then
 * restricts the visible area to a WKT polygon defined in pixel (source)
 * coordinates.  The CuttingPolygon masks out the rest of the image at render
 * time — useful when only a sub-region of the scan is accurate or of interest.
 *
 * Note: the CRS is not set here so coordinates remain in the warped target
 * space without a named projection.  RecalcExtent/FullExtent update the view.
 */
void __fastcall TForm1::btnCutClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn  ;
  TGIS_LayerPixel *lp  ;

  // Access the first (and only) layer, which is the satellite image
  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  // Create a new polynomial transform object
  trn = new TGIS_TransformPolynomial ;

  // Add four corner ground-control points (GCPs).
  // Each GCP maps a source pixel coordinate to a target real-world coordinate.
  // Source: image pixel convention (Y negative = image bottom).
  // Target: State Plane CRS (EPSG 102748), units in feet.
  trn->AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,     // GCP index
                True   // enabled
               ) ;
  trn->AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn->AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 244759.524147727 ),
                2,
                True
               ) ;
  trn->AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;

  // WKT polygon in SOURCE (pixel) coordinates that masks the visible region.
  // Pixels outside this polygon are not rendered after the warp is applied.
  trn->CuttingPolygon = "POLYGON((421.508902077151 -320.017804154303,"
                        "518.161721068249 -223.364985163205,"
                        "688.725519287834 -210.572700296736,"
                        "864.974777448071 -254.635014836795,"
                        "896.244807121662 -335.652818991098,"
                        "894.823442136499 -453.626112759644,"
                        "823.755192878338 -615.661721068249,"
                        "516.740356083086 -607.13353115727,"
                        "371.761127596439 -533.222551928783,"
                        "340.491097922849 -456.46884272997,"
                        "421.508902077151 -320.017804154303))" ;

  // Fit the polynomial (First = affine: translation, rotation, scale, shear)
  trn->Prepare( TGIS_PolynomialOrder::First ) ;

  // Assign the transform to the layer and activate on-the-fly warping
  lp->Transform = trn ;
  lp->Transform->Active = true ;

  // Recompute the layer extent and zoom to show the masked result
  GIS->RecalcExtent() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/*
 * btnLoadClick
 * ------------
 * Loads a previously saved polynomial transform from a ".trn" sidecar file
 * and re-applies it to the raster layer.
 *
 * The sidecar convention is "<image_path>.trn" (GIS_TRN_EXT).  This allows
 * a georeferencing solution to be saved once and reloaded without re-entering
 * all GCPs.  LoadFromFile populates the transform with the saved GCPs and
 * fitted polynomial coefficients.
 */
void __fastcall TForm1::btnLoadClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn ;
  TGIS_LayerPixel *lp  ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  // Create a new transform and populate it from the sidecar file
  trn = new TGIS_TransformPolynomial ;
  trn->LoadFromFile( "satellite.jpg"
                     GIS_TRN_EXT ) ;  // C++ adjacent string literal concatenation

  // Assign to the layer and activate on-the-fly warping
  lp->Transform = trn ;
  lp->Transform->Active = true ;

  GIS->RecalcExtent() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/*
 * btnSaveClick
 * ------------
 * Saves the current polynomial transform to a ".trn" sidecar file.
 *
 * The sidecar stores all GCPs and polynomial coefficients so the
 * georeferencing can be reloaded later without re-entering data.
 * This is a no-op if no transform has been assigned to the layer yet.
 */
void __fastcall TForm1::btnSaveClick(TObject *Sender)
{
  TGIS_LayerPixel *lp ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  // Guard: only save if a transform has been assigned to the layer
  if ( lp->Transform != NULL){
    lp->Transform->SaveToFile( "satellite.jpg"
                               GIS_TRN_EXT ) ;  // C++ adjacent string literal
  }
}
//---------------------------------------------------------------------------

/*
 * btnTransformClick
 * -----------------
 * Applies a full polynomial georeference to the satellite image:
 *   1. Creates TGIS_TransformPolynomial with four corner GCPs.
 *   2. Fits a first-order (affine) polynomial to the GCPs.
 *   3. Assigns the transform to the raster layer and activates warping.
 *   4. Sets the layer CRS to EPSG 102748 (NAD83 / Washington South -
 *      State Plane, US survey feet) so it aligns with other datasets.
 *   5. Recomputes the layer extent in the new CRS and zooms to fit.
 *
 * After this step the image is correctly georeferenced and can be overlaid
 * with other layers in the same CRS.
 */
void __fastcall TForm1::btnTransformClick(TObject *Sender)
{
  TGIS_TransformPolynomial *trn ;
  TGIS_LayerPixel *lp ;

  lp = (TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;

  trn = new TGIS_TransformPolynomial ;

  // Four corner GCPs: source pixel -> target real-world coordinates.
  // Source uses image convention (Y negative = image bottom of scan).
  // Target is in State Plane feet (EPSG 102748).
  trn->AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                true
               ) ;
  trn->AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                true
               ) ;
  trn->AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 245859.524147727 ),
                2,
                true
               ) ;
  trn->AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                true
               ) ;

  // Fit the polynomial (First = affine: handles translation, rotation, scale, shear)
  trn->Prepare( TGIS_PolynomialOrder::First ) ;

  // Assign the transform to the layer and activate on-the-fly warping
  lp->Transform = trn ;
  lp->Transform->Active = true ;

  // Declare the CRS so the viewer knows the real-world coordinate space.
  // EPSG 102748 = NAD83 / Washington South (State Plane, US survey feet).
  lp->SetCSByEPSG( 102748 ) ;

  // Recompute extent in the new CRS and zoom to show the whole image
  GIS->RecalcExtent() ;
  GIS->FullExtent() ;

}
//---------------------------------------------------------------------------

/*
 * FormCreate
 * ----------
 * Opens the unrectified satellite image from the standard sample data folder.
 * No transform is applied at startup; the user clicks buttons to georeference.
 */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // GisSamplesDataDirDownload resolves the shared sample data folder
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "\\Samples\\Rectify\\satellite.jpg" ) ;
}
//---------------------------------------------------------------------------

/*
 * GISMouseMove
 * ------------
 * Converts the current mouse screen position to map coordinates and displays
 * them in the status bar.  This lets the user read off real-world coordinates
 * as they move the mouse over the georeferenced image.
 */
void __fastcall TForm1::GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y)

{
  TGIS_Point ptg ;
  String str ;

  if( GIS->IsEmpty ) return ;

  // Convert screen pixel to map coordinate using the current view transformation
  ptg = GIS->ScreenToMap( Point(X,Y) ) ;

  // Display coordinates to 4 decimal places in the status bar
  StatusBar1->SimpleText = str.sprintf( L"X : %.4f | Y : %.4f", ptg.X, ptg.Y ) ;
}
//---------------------------------------------------------------------------
