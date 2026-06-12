//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// ShapeOperations sample - Interactive affine transformation of vector shapes.
// C++Builder / VCL edition.
//
// This header declares TForm1 which implements interactive rotate, scale, and
// translate operations on individual vector shapes using TGIS_Shape::Transform.
//
// The form uses a page-control (pgc1) to switch between three modes:
//   Page 0 - Rotate: horizontal mouse movement drives rotation angle.
//   Page 1 - Scale:  ratio of current to previous screen position per axis.
//   Page 2 - Move:   map-coordinate delta between consecutive mouse events.
//
// A two-layer approach is used:
//   1. The original shapefile layer holds the real data.
//   2. edtLayer (TGIS_LayerVector, CachedPaint=false) renders a live preview
//      of the shape being edited without touching the source layer.
// On commit (second mouse-up) CopyGeometry writes the final geometry back.
//
// Data: Samples\3D\buildings.shp
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
#include "VCL.GisViewerWnd.hpp"  // TGIS_ViewerWnd - the main map viewer control
#include <Vcl.ComCtrls.hpp>
#include "GisTypes.hpp"          // TGIS_Point, TGIS_Shape, core types
#include "GisLayerSHP.hpp"       // SHP file layer support
#include "GisLayerVector.hpp"    // In-memory vector layer (used as edit overlay)
#include "GisViewer.hpp"         // TGIS_ViewerMode enum
#include "GisTypesUI.hpp"        // TGIS_Color, TGIS_BrushStyle
#include "GisUtils.hpp"          // Helper utilities (GisSamplesDataDirDownload, etc.)
#include "Vcl.GisViewerWnd.hpp"
#include <System.Math.hpp>       // Cos, Sin, DegToRad
#include "GisFunctions.hpp"      // GisPoint3DFrom2D helper
#include "GisRtl.hpp"            // RTL support utilities

//---------------------------------------------------------------------------
/* Main form for the ShapeOperations sample.
   Demonstrates interactive rotate, scale, and translate operations on
   individual vector shapes using TGIS_Shape.Transform with an affine matrix. */
class TForm1 : public TForm
{
__published:    // IDE-managed Components
    TGIS_ViewerWnd *GIS ;    // Main map viewer control
    TPageControl *pgc1 ;     // Tab control to switch between Rotate/Scale/Move
    TTabSheet *ts1 ;         // Page 0: Rotate
    TTabSheet *ts2 ;         // Page 1: Scale
    TTabSheet *ts3 ;         // Page 2: Move
    TLabel *lblSelected ;    // Status/hint label

    void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X, int Y);
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
    void __fastcall GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
    void __fastcall GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled);
    void __fastcall pgc1Changing(TObject *Sender, bool &AllowChange);

private:    // User declarations

    // Flag that enables transform dragging; toggled by first mouse-up (select)
    // and cleared by second mouse-up (commit).
    bool handleMouseMove ;

    // Map-coordinate position from the previous mouse event (translation delta).
    TGIS_Point prevPtg ;

    // Screen-pixel coordinates from the previous mouse event (rotation/scale).
    int prevX ;
    int prevY ;

    // In-memory overlay layer that shows the shape being dragged without
    // modifying the underlying shapefile until the user commits.
    TGIS_LayerVector *edtLayer ;

    // The original shape obtained via MakeEditable; CopyGeometry writes back
    // the final geometry here on commit.
    TGIS_Shape *curShape ;

    // Working copy of curShape placed in edtLayer; receives all transforms.
    TGIS_Shape *edtShape ;

public:     // User declarations
    __fastcall TForm1(TComponent* Owner);

    // Translates the shape by (x_value, y_value) in map coordinates.
    void __fastcall TranslateSelectedShape(TGIS_Shape *shape, double x_value, double y_value);

    // Scales the shape by (x_value, y_value) factors, pivoting at its centroid.
    void __fastcall ScaleSelectedShape(TGIS_Shape *shape, double x_value, double y_value);

    // Rotates the shape by angle (radians) around its centroid.
    void __fastcall RotateSelectedShape(TGIS_Shape *shape, double angle) ;

    // Core 3x3 affine matrix transform; all three helpers delegate here.
    void __fastcall TransformSelectedShape(
                TGIS_Shape *shape,
                double xx,   // matrix [0,0]: x-to-x factor
                double yx,   // matrix [1,0]: x-to-y factor
                double xy,   // matrix [0,1]: y-to-x factor
                double yy,   // matrix [1,1]: y-to-y factor
                double dx,   // translation along X
                double dy    // translation along Y
    );

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
