//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  TopologyLayer — demonstrates topology editing and management in a GIS layer (Delphi/VCL).

  What the sample shows:
    - Loading and managing topologically structured data (line and polygon topology)
    - Creating topology structures from existing feature layers
    - Creating and deleting features within topology constraints
    - Editing topology elements while maintaining integrity
    - Adding elements to existing topology features
    - Automatic and manual fixing of topology import errors
    - Undo/Redo operations during topology editing
    - Rollback of topology changes
    - Integration with attribute viewer and layer legend
    - Toolbar controls for different editing modes (zoom, drag, select, edit)
    - Progress tracking during topology operations

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main map viewer control
    TGIS_TopoTool               - topology operations manager
    TGIS_Layer                  - base layer class
    TGIS_Shape                  - topology shape objects
    TGIS_ControlAttributes      - attribute display control
    TGIS_ControlLegend          - layer legend control
    TGIS_ViewerMode             - editing modes (Select, Edit, Drag, Zoom)
    OnBusyEvent                 - progress tracking callback
}
unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, VCL.GisControlLegend,
  VCL.GisViewerWnd,
  GisTopoTool, GisAllLayers,
  VCL.GisControlAttributes, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin,
  GisLayer, GisLicense, Vcl.StdCtrls;

type
  TfrmTopology = class(TForm)
    GIS: TGIS_ViewerWnd;
    mnuMain: TMainMenu;
    menuFile: TMenuItem;
    menuTopology: TMenuItem;
    menuTopoSettings: TMenuItem;
    menuTopoSeparatorLayer1: TMenuItem;
    menuTopoCreateTopology: TMenuItem;
    menuTopoCreateFeatureLayer: TMenuItem;
    menuTopoDeleteFeatureLayer: TMenuItem;
    menuTopoSeparatorFeature1: TMenuItem;
    menuTopoCreateFeature: TMenuItem;
    menuTopoDeleteFeature: TMenuItem;
    menuTopoAddElementsToFeature: TMenuItem;
    menuTopoDeleteFeatureElement: TMenuItem;
    menuTopoSeparatorFix1: TMenuItem;
    menuTopoAutoFixImportErrors: TMenuItem;
    menuTopoManualFixImportErrors: TMenuItem;
    menuOpenLineTopoSample: TMenuItem;
    menuOpen: TMenuItem;
    N1: TMenuItem;
    menuSave: TMenuItem;
    menuClose: TMenuItem;
    N2: TMenuItem;
    menuExit: TMenuItem;
    menuAdd: TMenuItem;
    dlgFileOpen: TFileOpenDialog;
    menuTopoRollback: TMenuItem;
    pnlGIS: TPanel;
    gisAttributes: TGIS_ControlAttributes;
    gisLegend: TGIS_ControlLegend;
    lstImage: TImageList;
    toolbar: TToolBar;
    btnFullExtent: TToolButton;
    btnZoom: TToolButton;
    btnDragMode: TToolButton;
    btnSelectMode: TToolButton;
    btnEditMode: TToolButton;
    btnRedo: TToolButton;
    btnUndo: TToolButton;
    btnDelete: TToolButton;
    btnRevertShape: TToolButton;
    btnAddShape: TToolButton;
    menuOpenTopoPolygonSample: TMenuItem;
    N3: TMenuItem;
    menuSelectAll: TMenuItem;
    menuDeselectAll: TMenuItem;
    Panel1: TPanel;
    btnCancel: TButton;
    lblProgress: TLabel;
    progressbar: TProgressBar;
    menuSelectVisible: TMenuItem;
    procedure menuOpenClick(Sender: TObject);
    procedure menuAddClick(Sender: TObject);
    procedure menuExitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure menuCloseClick(Sender: TObject);
    procedure menuTopoSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure menuTopoRollbackClick(Sender: TObject);
    procedure menuTopoCreateTopologyClick(Sender: TObject);
    procedure menuTopoCreateFeatureLayerClick(Sender: TObject);
    procedure menuTopoDeleteFeatureLayerClick(Sender: TObject);
    procedure menuTopoCreateFeatureClick(Sender: TObject);
    procedure menuTopoDeleteFeatureClick(Sender: TObject);
    procedure menuTopoAddElementsToFeatureClick(Sender: TObject);
    procedure menuTopoDeleteFeatureElementClick(Sender: TObject);
    procedure menuTopoAutoFixImportErrorsClick(Sender: TObject);
    procedure menuTopoManualFixImportErrorsClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragModeClick(Sender: TObject);
    procedure btnSelectModeClick(Sender: TObject);
    procedure btnEditModeClick(Sender: TObject);
    procedure btnRedoClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure menuSaveClick(Sender: TObject);
    procedure btnRevertShapeClick(Sender: TObject);
    procedure btnAddShapeClick(Sender: TObject);
    procedure menuOpenLineTopoSampleClick(Sender: TObject);
    procedure menuOpenTopoPolygonSampleClick(Sender: TObject);
    procedure menuSelectAllClick(Sender: TObject);
    procedure menuDeselectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GISBusyEvent(_sender: TObject; _pos, _end: Integer;
      var _abort: Boolean);
    procedure btnCancelClick(Sender: TObject);
    procedure menuSelectVisibleClick(Sender: TObject);
  private
    { Private declarations }
    abort     : Boolean ;
    fTopoTool : TGIS_TopoTool ;
    editLayer : TGIS_Layer ;

    function endEdit : Boolean ;
    procedure trySave ;
  public
    { Public declarations }
  end;

var
  frmTopology: TfrmTopology;

implementation

{$R *.dfm}

uses
  GisClasses,
  GisLayerVector,
  GisRegistredLayers,
  GisResource,
  GisRtl,
  GisUtils,
  GisTypes;

{ btnAddShapeClick
  Enters shape creation mode for the currently selected layer in the legend.
  Ends any active edit operation and enables edit mode. }
procedure TfrmTopology.btnAddShapeClick(Sender: TObject);
begin
  endEdit ;
  GIS.Mode  := TGIS_ViewerMode.Edit ;
  editLayer := gisLegend.GIS_Layer ;
end;

procedure TfrmTopology.btnCancelClick(Sender: TObject);
begin
  // === WORKFLOW: Abort Long-Running Operation ===
  abort := True ;
end;

{ btnDeleteClick
  Deletes the currently edited shape and returns to select mode. }
procedure TfrmTopology.btnDeleteClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape ;
  btnSelectModeClick( self ) ;
end;

{ btnDragModeClick
  Switches to pan/drag mode for interactive map panning. }
procedure TfrmTopology.btnDragModeClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{ btnEditModeClick
  Switches to edit mode for interactive geometry editing. }
procedure TfrmTopology.btnEditModeClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Edit ;
end;

{ btnFullExtentClick
  Fits the map viewport to show all loaded layers. }
procedure TfrmTopology.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ btnSelectModeClick
  Switches to shape selection mode after ending any active edit. }
procedure TfrmTopology.btnSelectModeClick(Sender: TObject);
begin
  if endEdit then
    GIS.Mode := TGIS_ViewerMode.Select ;
end;

{ btnUndoClick
  Reverts the last shape edit operation. }
procedure TfrmTopology.btnUndoClick(Sender: TObject);
begin
  GIS.Editor.Undo ;
end;

{ btnZoomClick
  Switches to zoom mode for interactive scale control. }
procedure TfrmTopology.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ endEdit
  Commits the current shape edit operation. Disables edit-related toolbar buttons
  (undo, redo, revert, delete) after edit ends. Returns false if the edit cannot
  be committed (validation error). }
function TfrmTopology.endEdit: Boolean;
begin
  Result := GIS.Editor.TryEndEdit ;
  if not Result then
    exit ;

  editLayer := nil ;

  btnUndo.Enabled  := False ;
  btnRedo.Enabled  := False ;
  btnRevertShape.Enabled  := False ;
  btnDelete.Enabled  := False ;
end;

procedure TfrmTopology.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True ;

  if GIS.IsEmpty then
    exit ;
end;

{ FormCreate
  Initializes the topology editor application. Sets up the topology tool with
  connections to the map viewer, layer legend, and attribute inspector.
  Configures the viewer for unrestricted panning. }
procedure TfrmTopology.FormCreate(Sender: TObject);
begin
  fTopoTool := TGIS_TopoTool.Create( Self, GIS, gisLegend, gisAttributes ) ;

  gis.RestrictedDrag := False ;
end;

{ FormDestroy
  Releases topology tool and associated resources when the form is closed. }
procedure TfrmTopology.FormDestroy(Sender: TObject);
begin
  FreeObject( fTopoTool ) ;
end;

{ FormShow
  Populates all topology menu captions with localized resource strings.
  Called before the form becomes visible to ensure proper language display. }
procedure TfrmTopology.FormShow(Sender: TObject);
begin
  menuTopology.Caption := _rsrc( GIS_RS_TOPO_MENU_TOPOLOGY ) ;
  menuTopoRollback.Caption := _rsrc( GIS_RS_TOPO_MENU_ROLLBACK ) ;
  menuTopoSettings.Caption := _rsrc( GIS_RS_TOPO_MENU_SETTINGS ) ;
  menuTopoCreateTopology.Caption := _rsrc( GIS_RS_TOPO_MENU_CREATE_TOPO ) ;
  menuTopoCreateFeatureLayer.Caption := _rsrc( GIS_RS_TOPO_MENU_CREATE_FEATURE_LAYER ) ;
  menuTopoDeleteFeatureLayer.Caption := _rsrc( GIS_RS_TOPO_MENU_DELETE_FEATURE_LAYER ) ;
  menuTopoCreateFeature.Caption := _rsrc( GIS_RS_TOPO_MENU_CREATE_FEATURES ) ;
  menuTopoDeleteFeature.Caption := _rsrc( GIS_RS_TOPO_MENU_DELETE_FEATURES ) ;
  menuTopoAddElementsToFeature.Caption := _rsrc( GIS_RS_TOPO_MENU_ADD_ELEMENTS ) ;
  menuTopoDeleteFeatureElement.Caption := _rsrc( GIS_RS_TOPO_MENU_DELETE_ELEMENT ) ;
  menuTopoAutoFixImportErrors.Caption := _rsrc( GIS_RS_TOPO_MENU_AUTO_FIX ) ;
  menuTopoManualFixImportErrors.Caption := _rsrc( GIS_RS_TOPO_MENU_MANUAL_FIX ) ;
end;

{ GISBusyEvent
  Progress callback during long-running topology operations. Updates the progress
  bar and position label. User can abort via the Cancel button (sets abort flag). }
procedure TfrmTopology.GISBusyEvent(
  _sender: TObject;
  _pos, _end: Integer;
  var _abort: Boolean);
begin
  lblProgress.Caption := _pos.ToString ;

  if _pos <= 0 then begin
    abort := False ;
    progressbar.Min := 0 ;
  end ;

  progressbar.Position := _pos ;
  progressbar.Max := _end ;
  _abort := abort ;
end;

{ GISMouseUp
  Map click handler for both shape selection (SELECT mode) and geometry editing
  (EDIT mode). Right-click switches to SELECT mode. Ctrl-click toggles shape selection.

  Algorithm:
    1. Reject empty maps; right-click switches to select mode.
    2. Convert screen click position to map coordinates and hit-test for shape.
    3. In SELECT mode: Ctrl toggles selection; single-click selects one shape
       and shows its attributes.
    4. In EDIT mode: Click creates new shape in active edit layer, or clicks
       existing shape to edit its geometry. Enables undo/redo buttons. }
procedure TfrmTopology.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp : TGIS_Shape ;
  ptg : TGIS_Point ;
  endEditRequired: Boolean;
begin
  if GIS.IsEmpty then
    exit;

  if Button = mbRight then begin
    btnSelectModeClick( Self ) ;
    exit ;
  end ;

  ptg := GIS.ScreenToMap(Point(X, Y)) ;
  shp := TGIS_Shape(GIS.Locate(ptg, 5 / GIS.Zoom));

  if GIS.Mode = TGIS_ViewerMode.Select then
  begin
    if not Assigned(shp) then
      exit;

    if ssCtrl in Shift then begin
      shp.IsSelected := not shp.IsSelected;
      gisAttributes.ShowSelected(shp.Layer ) ;
    end
    else begin
      shp.Layer.DeselectAll ;
      shp.IsSelected := not shp.IsSelected;
      gisAttributes.ShowShape(shp) ;
    end ;

    gisLegend.GIS_Layer := shp.Layer;
  end

  else if GIS.Mode = TGIS_ViewerMode.Edit then
  begin
    if assigned( GIS.Editor.CurrentShape ) then
      exit;

    if assigned( editLayer ) then begin
      // Create a new shape in edit layer
      if not GIS.Editor.TryCreateShape(
        gisLegend.GIS_Layer,
        ptg,
        TGIS_ShapeType.Unknown,
        endEditRequired) or endEditRequired then
      begin
        btnSelectModeClick( Self ) ;
      end;
    end
    else begin
      // Edit existing shape geometry
      if not GIS.Editor.TryEditShape( shp, 0, ptg ) then
        exit ;

      btnRedo.Enabled    := True ;
      btnUndo.Enabled  := True ;
      btnRevertShape.Enabled  := True ;
      btnDelete.Enabled := True ;
    end;

    editLayer :=  nil ;

    GIS.InvalidateEditor(True);
  end;
end;

{ menuAddClick
  Adds a new layer to the topology project. Opens file dialog, creates the layer
  object, configures it, and updates the map extent and legend.

  Algorithm:
    1. Open file dialog to select a layer file.
    2. Create layer object using factory function GisCreateLayer.
    3. Load configuration from saved .ttkgp file if available.
    4. Add layer to viewer; zoom to full extent if first layer, else just refresh.
    5. Update legend to show new layer. }
procedure TfrmTopology.menuAddClick(Sender: TObject);
var
  layer : TGIS_Layer ;
  filename : string ;
begin
  if not dlgFileOpen.Execute then
    exit ;
  filename := dlgFileOpen.FileName ;

  try
    layer := GisCreateLayer( ExtractFileName( filename ), filename ) ;
    if Assigned( layer ) then
    begin
      layer.ReadConfig ;
      GIS.Add( layer ) ;
    end;
  except on E: Exception do
    ShowMessage( 'Cannot add the file:'+#10#13+
                 filename +#10#13+
                 E.Message ) ;
  end ;

  if GIS.Items.Count = 1 then
    GIS.FullExtent
  else
    GIS.InvalidateWholeMap;

  gisLegend.GIS_Layer := layer ;
end;

procedure TfrmTopology.menuCloseClick(Sender: TObject);
var
  canClose : Boolean ;
begin
  trySave ;
  GIS.Close ;
end;

procedure TfrmTopology.menuDeselectAllClick(Sender: TObject);
begin
  if GIS.IsEmpty or not assigned( gisLegend.GIS_Layer ) then
    exit ;

  TGIS_LayerVector( gisLegend.GIS_Layer ).DeselectAll ;
end;

procedure TfrmTopology.menuExitClick(Sender: TObject);
var
  canClose : Boolean ;
begin
  TrySave ;

  FormCloseQuery( Sender, canClose ) ;
  if canClose then
    Self.Close ;
end;

procedure TfrmTopology.menuOpenClick(Sender: TObject);
begin
  if not dlgFileOpen.Execute then
    exit ;

  GIS.Close ;
  try
    GIS.Open( dlgFileOpen.FileName ) ;
  except on E: Exception do
    ShowMessage( 'Cannot open the file:'+#10#13+
                  dlgFileOpen.FileName +#10#13+
                  E.Message);
  end;
end;

procedure TfrmTopology.menuSaveClick(Sender: TObject);
begin
  TrySave ;
end;

procedure TfrmTopology.menuSelectAllClick(Sender: TObject);
var
  lv : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  lv := TGIS_LayerVector( gisLegend.GIS_Layer ) ;
  if not Assigned( lv ) then
    exit ;

  GIS.Lock ;
  try
    for shp in lv.Loop do begin
      if not shp.IsHidden then
         shp.IsSelected := True ;
    end ;
  finally
    GIS.Unlock ;
  end ;
end;

procedure TfrmTopology.menuSelectVisibleClick(Sender: TObject);
var
  lv : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  lv := TGIS_LayerVector( gisLegend.GIS_Layer ) ;
  if not Assigned( lv ) then
    exit ;

  for shp in lv.Loop( GIS.VisibleExtent ) do begin
    if not shp.IsHidden then
       shp.IsSelected := True ;
  end ;
end;

procedure TfrmTopology.menuTopoAddElementsToFeatureClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.AddElementsToTopoFeature ) ;
end;

procedure TfrmTopology.menuTopoAutoFixImportErrorsClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.AutoFixTopoImportErrors ) ;
end;

procedure TfrmTopology.menuTopoCreateFeatureClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.CreateTopoFeature ) ;
end;

procedure TfrmTopology.menuTopoCreateFeatureLayerClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.CreateFeatureLayer ) ;
end;

procedure TfrmTopology.menuTopoCreateTopologyClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.CreateTopology ) ;
end;

procedure TfrmTopology.menuTopoDeleteFeatureClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.DeleteTopoFeature ) ;
end;

procedure TfrmTopology.menuTopoDeleteFeatureElementClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.DeleteTopoFeatureElement ) ;
end;

procedure TfrmTopology.menuTopoDeleteFeatureLayerClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.DeleteFeatureLayer ) ;
end;

procedure TfrmTopology.menuTopoManualFixImportErrorsClick(Sender: TObject);
begin
  fTopoTool.RunTool( TGIS_TopoTools.ManualFixTopoImportErrors ) ;
end;

procedure TfrmTopology.menuOpenLineTopoSampleClick(Sender: TObject);
var
  samples : string ;
  line_topo_path : string ;
begin
  samples := TGIS_Utils.GisSamplesDataDirDownload('TopologyLayer.1') ;
  line_topo_path := samples + '\Samples\TopologyLayer\LINETOPOLOGY\OIL.ttkproject' ;
  GIS.Open( line_topo_path ) ;
end;

procedure TfrmTopology.menuOpenTopoPolygonSampleClick(Sender: TObject);
var
  samples : string ;
  polygon_topo_path : string ;
begin
  samples := TGIS_Utils.GisSamplesDataDirDownload('TopologyLayer.1') ;
  polygon_topo_path := samples + '\Samples\TopologyLayer\POLYGONTOPOLOGY\CLC.ttkproject' ;
  GIS.Open( polygon_topo_path ) ;
end;

procedure TfrmTopology.menuTopoRollbackClick(Sender: TObject);
begin
  fTopoTool.Rollback ;
end;

procedure TfrmTopology.menuTopoSettingsClick(Sender: TObject);
begin
  fTopoTool.OpenSettingsForm ;
end;

procedure TfrmTopology.trySave;
begin
  if not GIS.MustSave then
    exit ;

  if MessageDlg('Save changes?', mtConfirmation, [mbNo, mbYes], 0, mbYes) = mrYes then
    GIS.SaveAll ;
end;

{ btnRedoClick
  Restores the last undone shape edit operation. }
procedure TfrmTopology.btnRedoClick(Sender: TObject);
begin
  GIS.Editor.Redo ;
end;

{ btnRevertShapeClick
  Reverts the current shape to its original state, discarding all edits. }
procedure TfrmTopology.btnRevertShapeClick(Sender: TObject);
begin
  GIS.Editor.RevertShape ;
  btnSelectModeClick( Self ) ;
end;

end.
