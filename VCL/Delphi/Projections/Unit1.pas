//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Projections Sample
  ==================
  Demonstrates how TatukGIS DK supports on-the-fly coordinate reprojection for
  map display.

  Key concepts covered:
    - TGIS_CSProjList        : the global registry of all known map projections
                               (Mercator, Lambert, Albers, UTM, etc.)
    - TGIS_CSProjectedCoordinateSystem : a coordinate system built at runtime
                               by combining a geographic datum, a linear unit
                               and a projection method
    - TGIS_CSGeographicCoordinateSystem (EPSG 4030): the WGS 84 unscaled
                               geographic datum used as the base datum for the
                               on-the-fly construction in this sample
    - GIS.CS property        : assigning a new coordinate system to the viewer
                               triggers immediate on-the-fly reprojection of
                               every loaded layer without reloading source data
    - GIS.FullExtent         : zooms to the combined extent of all layers,
                               recalculated in the new coordinate system

  Workflow:
    1. FormCreate populates a combo box with the names (WKT strings) of every
       "standard" projection in the TatukGIS projection catalogue.
    2. When the user selects a projection, cbxSrcProjectionChange constructs a
       temporary TGIS_CSProjectedCoordinateSystem with WGS 84 + metres + the
       chosen projection and assigns it to the viewer.
    3. The viewer reprojects the world map layer on the fly; no source data is
       modified or reloaded.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,

  //GisLicense,
  GisCsBase,          // Base CS types: TGIS_CSCoordinateSystem, TGIS_CSUnits, etc.
  GisCsProjections,   // Projection catalogue: TGIS_CSProjList, TGIS_CSProjAbstract
  GisCsFactory,       // CS factory helpers: CSProjectedCoordinateSystemList, etc.
  GisCsSystems,       // Geographic CRS registry: CSGeographicCoordinateSystemList
  GisEditor,
  GisLayerVector,
  GisTypesUI,
  GisUtils,           // TGIS_Utils: GisSamplesDataDirDownload and global list accessors
  GisViewer,

  Vcl.GisViewerWnd;   // TGIS_ViewerWnd: the visual map viewer control

type
  { Main application form for the Projections sample.
    Shows a world map that is immediately reprojected whenever the user
    picks a different projection method from the combo box. }
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    /// <summary>Drop-down list of available projection names (WKT strings).</summary>
    cbxSrcProjection: TComboBox;
    /// <summary>The TatukGIS map viewer control that renders layers.</summary>
    GIS: TGIS_ViewerWnd;
    procedure FormCreate(Sender: TObject);
    procedure cbxSrcProjectionChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}


// -----------------------------------------------------------------------------
//  FormCreate
// -----------------------------------------------------------------------------
// Called once when the main form is first created.
//
// Responsibilities:
//   1. Build a sorted list of "standard" projection names from the global
//      TatukGIS projection catalogue (CSProjList).  "Standard" projections are
//      those that are well-known and fully parameterised — filtering them avoids
//      showing partial or experimental entries in the UI.
//   2. Populate the combo box with those names (stored as WKT identifiers).
//   3. Open the bundled world map project file.
//   4. Apply the initially-selected projection so the viewer starts in a defined
//      coordinate system rather than the raw geographic CRS of the source data.
// -----------------------------------------------------------------------------
procedure TfrmMain.FormCreate(Sender: TObject);
var
  i   : Integer ;
  lst : TStringList ;
begin
  // Use a temporary sorted string list so the combo box entries appear in
  // alphabetical order regardless of the order they are stored in CSProjList.
  lst := TStringList.Create ;
  lst.Sorted := True ;
  try
    lst.Clear ;
    for i := 0 to CsProjList.Count - 1 do
    begin
      // IsStandard filters out non-standard / experimental entries;
      // WKT returns the Well-Known Text identifier string used as a
      // human-readable name and also as the lookup key later.
      if CSProjList[i].IsStandard then
        lst.Add( CSProjList[i].WKT ) ;
    end ;

    // Transfer the sorted entries into the combo box.
    for i := 0 to lst.Count - 1 do
      cbxSrcProjection.Items.AddObject( lst[i], lst.Objects[i] ) ;

    cbxSrcProjection.ItemIndex := 0 ;
  finally
    lst.Free ;
  end ;

  // Apply the first projection before opening the project so the CS is set
  // before any layer data is first rendered.
  cbxSrcProjectionChange( Self ) ;

  // Open the bundled world map project. The path is resolved via
  // GisSamplesDataDirDownload which points to the TatukGIS sample data folder.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Projects\world.ttkproject' ) ;

  // Re-apply the projection after loading to ensure the viewer CS and the
  // FullExtent zoom level are consistent with the loaded data.
  cbxSrcProjectionChange( Self ) ;
end;



// -----------------------------------------------------------------------------
//  cbxSrcProjectionChange
// -----------------------------------------------------------------------------
// Called whenever the user selects a different projection in the combo box.
//
// This procedure demonstrates the core pattern for on-the-fly reprojection:
//   1. Resolve the projection method by looking up the WKT name in CSProjList.
//   2. Construct a full TGIS_CSProjectedCoordinateSystem by combining:
//        - A geographic CRS (datum)   : WGS 84 unscaled, EPSG 4030
//        - A linear unit              : Metre, looked up by WKT name
//        - A projection method        : the user-selected entry from CSProjList
//        - Default parameters         : CSProjectedCoordinateSystemList.DefaultParams
//          returns sensible central-meridian / standard-parallel values for the
//          chosen projection so the map renders without manual parameter tuning.
//   3. Assign the constructed CS to GIS.CS.  The viewer immediately reprojects
//      all loaded layers; no source data is reloaded or modified.
//   4. Call GIS.FullExtent to re-zoom to the world extent in the new CRS.
//
// The Lock/Unlock pair prevents the viewer from repainting between the CS
// assignment and the FullExtent call, avoiding a brief visual artefact.
// The inner try/except is intentional: some projection pairs are mathematically
// incompatible at the global extent and will throw; the viewer is left in its
// last valid state when this happens.
// -----------------------------------------------------------------------------
procedure TfrmMain.cbxSrcProjectionChange(Sender: TObject);
var
  sproj : String ;
  ocs   : TGIS_CSCoordinateSystem ;
  ogcs  : TGIS_CSGeographicCoordinateSystem ;
  ounit : TGIS_CSUnits ;
  oproj : TGIS_CSProjAbstract ;
begin
  // Retrieve the WKT name of the projection chosen by the user.
  sproj := cbxSrcProjection.Items[cbxSrcProjection.ItemIndex] ;

  // Look up the base geographic CRS.
  // EPSG 4030 = WGS 84 (unscaled) — a datum independent of any projection,
  // suitable as the geographic base for any projected CRS.
  ogcs := CSGeographicCoordinateSystemList.ByEPSG( 4030 ) ;

  // Metres are the standard linear unit for most projected coordinate systems.
  ounit := CSUnitsList.ByWKT( 'METER' ) ;

  // Resolve the chosen projection method from the global catalogue.
  oproj := CSProjList.ByWKT( sproj ) ;

  // Construct a projected coordinate system dynamically.
  // EPSG = -1 signals a user-defined (non-registered) CRS.
  // 'Test' is a temporary display name.
  // DefaultParams supplies reasonable default values (e.g. central meridian = 0)
  // for the selected projection so the map renders correctly without extra input.
  ocs := TGIS_CSProjectedCoordinateSystem.Create(
           -1, 'Test',
           ogcs.EPSG, ounit.EPSG, oproj.EPSG,
           CSProjectedCoordinateSystemList.DefaultParams(oproj.EPSG)
         );

  // Lock the viewer to batch the CS change and extent reset into a single
  // repaint, preventing flicker and partial redraws.
  GIS.Lock ;
  try
    try
      // Assigning GIS.CS triggers on-the-fly reprojection of all loaded layers.
      // The viewer transforms coordinates from each layer's native CRS to this
      // new display CRS without touching the underlying source data.
      GIS.CS := ocs ;

      // Zoom to the full extent of all layers expressed in the new CRS.
      GIS.FullExtent ;
    except
      // Some projection methods cannot represent the global (-180..180) extent
      // that the world map layer spans (e.g. polar-centric projections).
      // Silently ignore the exception to leave the viewer in its last valid state.
    end;
  finally
    GIS.Unlock ;
  end;
end;

end.
