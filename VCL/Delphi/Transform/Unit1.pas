//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Transform sample - Polynomial georeferencing of a raster image.

  This sample demonstrates how to georeference (rectify) an unregistered
  raster image using the TatukGIS DK polynomial transform API:

  Key concepts:
    TGIS_TransformPolynomial
      A polynomial spatial transform that maps pixel (source) coordinates to
      real-world (target) coordinates using a set of ground-control points
      (GCPs).  The polynomial order determines the complexity of the warp:
        - First (linear/affine): handles translation, rotation, scale, and
          shear.  Requires at least 3 non-collinear GCPs.
        - Second (quadratic): corrects gentle curvature.  Requires >= 6 GCPs.
        - Third (cubic): corrects stronger distortions.  Requires >= 10 GCPs.

    TGIS_LayerPixel.Transform
      Attaching a transform to a raster layer causes the DK to warp the image
      on-the-fly when it is rendered, without modifying the source file.

    TGIS_TransformPolynomial.CuttingPolygon
      An optional WKT polygon (in source / pixel coordinates) that masks the
      visible area of the raster to a region of interest.

  Workflow demonstrated:
    1. btnTransformClick  - Define 4 corner GCPs, fit a first-order polynomial,
                            assign a CRS (EPSG 102748), and display the result.
    2. btnCutClick        - Same GCPs but with a CuttingPolygon that masks
                            the image to a non-rectangular region of interest.
    3. btnSaveClick       - Persist the current transform definition to a
                            sidecar file (satellite.jpg.trn).
    4. btnLoadClick       - Reload a previously saved transform and re-apply it.

  Data: Samples\Rectify\satellite.jpg  (an unrectified aerial/satellite image)
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,            // TGIS_Point and core geometry types
  GisUtils,            // TGIS_Utils helpers (GisSamplesDataDirDownload, GisPoint)
  GisFunctions,        // GisPoint constructor helper
  GisLayerVector,      // TGIS_LayerVector (not used directly here but pulled in)
  GisGeometryFactory,  // Geometry factory helpers
  GISLayerPixel,       // TGIS_LayerPixel - raster layer that supports transforms
  GisResource,         // GIS_TRN_EXT constant (sidecar file extension ".trn")
  GisTransform,        // TGIS_TransformPolynomial and TGIS_PolynomialOrder
  GisTypesUI,          // UI colour/style types
  GisViewer,           // TGIS_ViewerMode enum

  Vcl.GisViewerWnd;    // TGIS_ViewerWnd - the visual map viewer control

type
  { Main form for the Transform sample.
    Demonstrates polynomial georeferencing of a raster image using
    TGIS_TransformPolynomial and TGIS_LayerPixel.Transform. }
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;        // Main map viewer control
    StatusBar1: TStatusBar;     // Status bar showing cursor map coordinates
    pnl1: TPanel;               // Left panel holding action buttons
    btnTransform: TButton;      // Apply 4-GCP first-order polynomial transform
    btnCut: TButton;            // Apply transform with CuttingPolygon mask
    btnSave: TButton;           // Save current transform to .trn sidecar file
    btnLoad: TButton;           // Load transform from .trn sidecar file
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure btnTransformClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{
  btnCutClick
  -----------
  Applies a first-order polynomial transform with four corner GCPs and then
  restricts the visible area of the raster to a WKT polygon defined in
  source (pixel) coordinates.

  The CuttingPolygon property accepts a WKT geometry string in pixel space.
  This is useful when only a portion of a scan is accurate or of interest;
  the polygon masks out the rest of the image at render time.

  After applying the transform, RecalcExtent recomputes the layer's bounding
  box in the new coordinate space, and FullExtent zooms to show the whole layer.
}
procedure TForm1.btnCutClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  // Access the first (and only) layer, which is the satellite image
  lp := GIS.Items[0] as TGIS_LayerPixel;

  // Create a new polynomial transform object
  trn := TGIS_TransformPolynomial.Create() ;

  // Add four corner ground-control points (GCPs).
  // Each GCP maps a source pixel coordinate to a target real-world coordinate.
  // Parameters: source point, target point, GCP index, enable flag.
  // The source coordinates use the image convention where Y increases downward
  // (hence the negative Y values for the bottom of the image).
  trn.AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                True
               ) ;
  trn.AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 244759.524147727 ),
                2,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;

  // Define a polygon in pixel (source) coordinates that masks the visible
  // area.  Only pixels inside this polygon will be rendered after warping.
  trn.CuttingPolygon := 'POLYGON((421.508902077151 -320.017804154303,' +
                        '518.161721068249 -223.364985163205,' +
                        '688.725519287834 -210.572700296736,' +
                        '864.974777448071 -254.635014836795,' +
                        '896.244807121662 -335.652818991098,' +
                        '894.823442136499 -453.626112759644,' +
                        '823.755192878338 -615.661721068249,' +
                        '516.740356083086 -607.13353115727,' +
                        '371.761127596439 -533.222551928783,' +
                        '340.491097922849 -456.46884272997,' +
                        '421.508902077151 -320.017804154303))' ;

  // Fit the polynomial using the added GCPs (First = linear/affine order)
  trn.Prepare( TGIS_PolynomialOrder.First ) ;

  // Assign the transform to the layer and activate it
  lp.Transform := trn ;
  lp.Transform.Active := True ;

  // Recompute the layer extent in the new coordinate space and zoom to fit
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{
  btnLoadClick
  ------------
  Loads a previously saved polynomial transform from a sidecar file and
  re-applies it to the raster layer.

  The sidecar file convention is "<image_path>.trn" (GIS_TRN_EXT constant).
  This allows a georeferencing solution to be saved once and reloaded without
  re-entering all GCPs.
}
procedure TForm1.btnLoadClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;

  // Create a new transform and populate it from the sidecar file
  trn := TGIS_TransformPolynomial.Create() ;
  trn.LoadFromFile( 'satellite.jpg' + GIS_TRN_EXT ) ;

  // Assign to the layer and activate
  lp.Transform := trn ;
  lp.Transform.Active := True ;

  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{
  btnSaveClick
  ------------
  Saves the current polynomial transform to a sidecar file so it can be
  reloaded later without re-entering the GCPs.

  The transform is only saved if one has already been assigned; if the layer
  has no transform yet (the image was just opened without georeferencing),
  this is a no-op.
}
procedure TForm1.btnSaveClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;

  // Guard: only save if a transform has been assigned to the layer
  if assigned( lp.Transform ) then
    lp.Transform.SaveToFile( 'satellite.jpg' + GIS_TRN_EXT ) ;
end;

{
  btnTransformClick
  -----------------
  Applies a full polynomial georeference to the satellite image:
    1. Creates a TGIS_TransformPolynomial with four corner GCPs.
    2. Fits a first-order (affine) polynomial to the GCPs.
    3. Assigns the transform to the raster layer and activates it.
    4. Sets the layer's coordinate reference system to EPSG 102748
       (NAD83 / Washington South - State Plane, in US survey feet).
    5. Recomputes the layer extent and zooms to full extent.

  After this step the image is correctly georeferenced and can be overlaid
  with other layers in the same CRS.
}
procedure TForm1.btnTransformClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;

  trn := TGIS_TransformPolynomial.Create() ;

  // Four corner GCPs: source pixel coordinates -> target CRS coordinates.
  // The source uses image convention (Y negative, measured from top-left).
  // The target is in the State Plane CRS (EPSG 102748), units in feet.
  trn.AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                True
               ) ;
  trn.AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 245859.524147727 ),
                2,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;

  // Fit the polynomial (First order = affine, handles scale/rotation/shear)
  trn.Prepare( TGIS_PolynomialOrder.First ) ;

  // Assign the transform to the layer and activate warping
  lp.Transform := trn ;
  lp.Transform.Active := True ;

  // Declare the CRS of the target coordinates so other layers can align with it
  // EPSG 102748 = NAD83 / Washington South (State Plane, US survey feet)
  lp.SetCSByEPSG( 102748 ) ;

  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{
  FormCreate
  ----------
  Opens the unrectified satellite image from the standard sample data folder.
  No transform is applied at startup; the user clicks buttons to georeference.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Rectify\satellite.jpg' ) ;
end;

{
  GISMouseMove
  ------------
  Converts the current mouse screen position to map coordinates and displays
  them in the status bar.  This lets the user read off real-world coordinates
  as they move the mouse over the georeferenced image.
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;

  // Convert screen pixel to map coordinate using the current view transformation
  ptg := GIS.ScreenToMap( Point(X,Y) ) ;

  // Display coordinates to 4 decimal places in the status bar
  StatusBar1.SimpleText := Format( 'X : %.4f | Y : %.4f', [ptg.X, ptg.Y] ) ;
end;

end.
