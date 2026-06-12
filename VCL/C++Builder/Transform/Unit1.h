//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Transform sample - Polynomial georeferencing of a raster image.
// C++Builder / VCL edition.
//
// This header declares TForm1 which demonstrates how to georeference
// (rectify) an unregistered raster image using TGIS_TransformPolynomial.
//
// Key concepts:
//   TGIS_TransformPolynomial
//     Fits a polynomial warp from pixel (source) to real-world (target)
//     coordinates using ground-control points (GCPs).  Polynomial order:
//       First (affine):    translation, rotation, scale, shear.  Min 3 GCPs.
//       Second:            gentle curvature.  Min 6 GCPs.
//       Third:             stronger distortions.  Min 10 GCPs.
//
//   TGIS_LayerPixel->Transform
//     Attaching a transform causes the DK to warp the image on-the-fly at
//     render time without modifying the source file.
//
//   GIS_TRN_EXT  (".trn")
//     Sidecar file extension used by the DK to persist transform GCP data.
//
// Data: Samples\Rectify\satellite.jpg  (an unrectified aerial/satellite image)
//
// Check project\options\directories in case of any problems during compilation.
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"     // TGIS_ViewerWnd - the visual map viewer
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include "GisTypes.hpp"             // TGIS_Point and core geometry types
#include "GisUtils.hpp"             // TGIS_Utils helpers (GisPoint, GisSamplesDataDirDownload)
#include "GisFunctions.hpp"         // GisPoint constructor helper
#include "GisLayerVector.hpp"       // TGIS_LayerVector (pulled in transitively)
#include "GisGeometryFactory.hpp"   // Geometry factory helpers
#include "GISLayerPixel.hpp"        // TGIS_LayerPixel - raster layer with transform support
#include "GisResource.hpp"          // GIS_TRN_EXT constant (".trn" sidecar extension)
#include "GisTransform.hpp"         // TGIS_TransformPolynomial and TGIS_PolynomialOrder
#include "GisTypesUI.hpp"           // UI colour/style types
#include "GisViewer.hpp"            // TGIS_ViewerMode enum

//---------------------------------------------------------------------------
/* Main form for the Transform sample.
   Demonstrates polynomial georeferencing of a raster image using
   TGIS_TransformPolynomial and TGIS_LayerPixel.Transform. */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TGIS_ViewerWnd *GIS;      // Main map viewer control
    TStatusBar *StatusBar1;   // Status bar showing cursor map coordinates
    TPanel *pnl1;             // Left panel holding action buttons
    TButton *btnTransform;    // Apply 4-GCP first-order polynomial transform
    TButton *btnCut;          // Apply transform with CuttingPolygon mask
    TButton *btnSave;         // Save transform to .trn sidecar file
    TButton *btnLoad;         // Load transform from .trn sidecar file

    void __fastcall btnCutClick(TObject *Sender);
    void __fastcall btnLoadClick(TObject *Sender);
    void __fastcall btnSaveClick(TObject *Sender);
    void __fastcall btnTransformClick(TObject *Sender);
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);

private:    // User declarations
public:     // User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
