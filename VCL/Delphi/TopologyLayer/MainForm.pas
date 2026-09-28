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
    - Undo/Redo operations during topology editing (also with Ctrl+Z / Ctrl+Y)
    - Snapping to chosen layers and snap type when adding or editing shapes
    - Adding sequences of nodes and edges (Ctrl+click continues from the last edge)
    - Rollback of topology changes
    - Integration with attribute viewer and layer legend
    - Toolbar controls for different editing modes (zoom, drag, select, edit)
    - Zooming with the mouse wheel
    - Progress tracking during topology operations

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main map viewer control
    TGIS_TopoTool               - topology operations manager
    TGIS_Layer                  - base layer class
    TGIS_Shape                  - topology shape objects
    TGIS_ControlAttributes      - attribute display control
    TGIS_ControlLegend          - layer legend control
    TGIS_ViewerMode             - editing modes (Select, Edit, Drag, Zoom)
    TGIS_EditorSnapType         - snapping targets (vertex, edge, midpoint, ...)
    OnBusyEvent                 - progress tracking callback
}
unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, VCL.GisControlLegend,
  VCL.GisViewerWnd, VCL.AllPvl,
  GisTopoTool, GisAllLayers,
  VCL.GisControlAttributes, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin,
  GisLayer, GisLicense, GisTypes, Vcl.StdCtrls;

const
  // posted to open the snap layer list again after a layer was (un)checked
  WM_REOPEN_SNAP_LAYERS = WM_USER + 1 ;

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
    sepEdit: TToolButton;
    sepAdd: TToolButton;
    lblSnapLayer: TLabel;
    btnSnapLayers: TButton;
    btnSnapType: TToolButton;
    pmSnapLayers: TPopupMenu;
    pmSnapType: TPopupMenu;
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
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure GISMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure GISLayerDeleteEvent(_sender: TObject; _layer: TGIS_Layer);
    procedure GISProjectCloseEvent(Sender: TObject);
    procedure GISModeChangeEvent(Sender: TObject);
    procedure gisLegendLayerSelectEvent(_sender: TObject; _layer: TGIS_Layer);
    procedure pmSnapLayersPopup(Sender: TObject);
    procedure btnSnapLayersClick(Sender: TObject);
  private
    { Private declarations }
    abort     : Boolean ;
    fTopoTool : TGIS_TopoTool ;
    // layer to which new shapes are added while the Add Shape mode is on
    // (set by the Add Shape button); nil otherwise
    editLayer : TGIS_Layer ;

    function endEdit : Boolean ;
    procedure trySave ;
  private
    // Edit and Add Shape modes, snapping
    snapLayerNames : TStringList ; // names of the layers checked in the snap layer list

    procedure initEditingToolbar ;
    procedure updateModeButtons ;
    procedure stopAdding ;
    function  finishAdding : Boolean ;
    procedure cancelEdit ;
    procedure addShape( const _ptg : TGIS_Point ) ;
    procedure finishShape ;
    procedure fillSnapLayers ;
    procedure applySnapLayers ;
    procedure setSnapType( const _index : Integer ) ;
    procedure snapLayerItemClick( Sender : TObject ) ;
    procedure snapTypeItemClick( Sender : TObject ) ;
    procedure WMReopenSnapLayers( var _msg : TMessage ) ; message WM_REOPEN_SNAP_LAYERS ;
  public
    { Public declarations }
  end;

var
  frmTopology: TfrmTopology;

implementation

{$R *.dfm}

uses
  System.Math,
  GisClasses,
  GisInterfaces,
  GisLayerVector,
  GisRegistredLayers,
  GisResource,
  GisRtl,
  GisUtils;

{ btnAddShapeClick
  Turns the Add Shape mode on for the layer selected in the legend. The mode
  stays on, so that shapes (e.g. a sequence of nodes or edges) can be added one
  after another, until another mode is chosen or the button is pressed again. }
procedure TfrmTopology.btnAddShapeClick(Sender: TObject);
begin
  // pressed again - leave the Add Shape mode
  if assigned( editLayer ) then begin
    btnSelectModeClick( Self ) ;
    exit ;
  end ;

  if endEdit then begin
    if assigned( gisLegend.GIS_Layer ) then begin
      editLayer := gisLegend.GIS_Layer ;
      GIS.Mode  := TGIS_ViewerMode.Edit ;
    end
    else
      MessageDlg( 'Select the layer for the new shape in the legend first.',
                  mtInformation, [mbOK], 0 ) ;
  end ;

  // the toolbar toggles the clicked button itself - show the actual mode
  updateModeButtons ;
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
  if finishAdding then
    GIS.Mode := TGIS_ViewerMode.Drag ;

  // the toolbar toggles the clicked button itself - show the actual mode
  updateModeButtons ;
end;

{ btnEditModeClick
  Switches to edit mode for interactive geometry editing. }
procedure TfrmTopology.btnEditModeClick(Sender: TObject);
begin
  if finishAdding then
    GIS.Mode := TGIS_ViewerMode.Edit ;

  // the toolbar toggles the clicked button itself - show the actual mode
  updateModeButtons ;
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
  if endEdit then begin
    stopAdding ;
    GIS.Mode := TGIS_ViewerMode.Select ;
  end ;

  // the toolbar toggles the clicked button itself - show the actual mode
  updateModeButtons ;
end;

{ btnUndoClick
  Reverts the last shape edit operation. }
procedure TfrmTopology.btnUndoClick(Sender: TObject);
begin
  if GIS.Editor.CanUndo then
    GIS.Editor.Undo ;
end;

{ btnZoomClick
  Switches to zoom mode for interactive scale control. }
procedure TfrmTopology.btnZoomClick(Sender: TObject);
begin
  if finishAdding then
    GIS.Mode := TGIS_ViewerMode.Zoom ;

  // the toolbar toggles the clicked button itself - show the actual mode
  updateModeButtons ;
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

  initEditingToolbar ;
end;

{ FormDestroy
  Releases topology tool and associated resources when the form is closed. }
procedure TfrmTopology.FormDestroy(Sender: TObject);
begin
  FreeObject( fTopoTool ) ;
  FreeObject( snapLayerNames ) ;
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
  bar and percentage label. User can abort via the Cancel button (sets abort flag). }
procedure TfrmTopology.GISBusyEvent(
  _sender: TObject;
  _pos, _end: Integer;
  var _abort: Boolean);
var
  percent : Integer ;
begin
  if _pos <= 0 then
    abort := False ;

  // _pos and _end are -1 when processing ends
  percent := 0 ;
  if ( _pos > 0 ) and ( _end > 0 ) then
    percent := Min( MulDiv( _pos, 100, _end ), 100 ) ;

  progressbar.Position := percent ;
  lblProgress.Caption  := IntToStr( percent ) + '%' ;
  _abort := abort ;
end;

{ GISMouseUp
  Map click handler for both shape selection (SELECT mode) and geometry editing
  (EDIT mode). Right-click finishes the added shape in the Add Shape mode and
  switches to SELECT mode otherwise. Ctrl-click toggles shape selection.

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
begin
  if GIS.IsEmpty then
    exit;

  if Button = mbRight then begin
    // finish the added shape, but stay in the Add Shape mode
    if assigned( editLayer ) then
      finishShape
    else
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

    if assigned( editLayer ) then
      // Create a new shape in the layer chosen with the Add Shape button
      addShape( ptg )
    else begin
      // Edit existing shape geometry
      if not GIS.Editor.TryEditShape( shp, 0, ptg ) then
        exit ;

      btnRedo.Enabled    := True ;
      btnUndo.Enabled  := True ;
      btnRevertShape.Enabled  := True ;
      btnDelete.Enabled := True ;
    end;

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
  if GIS.Editor.CanRedo then
    GIS.Editor.Redo ;
end;

{ btnRevertShapeClick
  Reverts the current shape to its original state, discarding all edits. }
procedure TfrmTopology.btnRevertShapeClick(Sender: TObject);
begin
  GIS.Editor.RevertShape ;
  btnSelectModeClick( Self ) ;
end;

//=============================================================================
// Edit and Add Shape modes
// Mode buttons, the Add Shape mode kept on for sequences of shapes,
// Ctrl+Z / Ctrl+Y, mouse wheel zoom and ending the edit when the
// project, a layer or the legend selection changes
//=============================================================================

const
  // text of the snap layer list when no layer is checked
  NO_SNAPPING = 'No snapping' ;

  // index of the first snap type picture in lstImage, in the order of SNAP_TYPES
  SNAP_TYPE_IMAGE = 10 ;

  // snap types offered in the snap type list, in the order of its items
  SNAP_TYPES : array[ 0..5 ] of TGIS_EditorSnapType = (
    TGIS_EditorSnapType.Point,
    TGIS_EditorSnapType.Line,
    TGIS_EditorSnapType.PointOverLine,
    TGIS_EditorSnapType.EndPoint,
    TGIS_EditorSnapType.Midpoint,
    TGIS_EditorSnapType.Perpendicular
  ) ;

  // descriptions of the snap types, in the order of SNAP_TYPES; the part
  // before ' - ' is the name shown in the snap type list
  SNAP_TYPE_HINTS : array[ 0..5 ] of String = (
    'Vertex - snap to the nearest vertex of a shape',
    'Edge - snap to the nearest point on a line segment or polygon edge',
    'Vertex or edge - snap to a vertex if one is near, otherwise to an edge',
    'End point - snap to the first or last vertex of a line or polygon',
    'Midpoint - snap to the middle of a line segment or polygon edge',
    'Perpendicular - snap to the point of an edge that makes a right angle with the previous segment'
  ) ;

{ initEditingToolbar
  Sets up the editing toolbar (snap type and snap layer lists, mode buttons).
  Called when the form is created. }
procedure TfrmTopology.initEditingToolbar;
var
  i    : Integer ;
  item : TMenuItem ;
begin
  snapLayerNames := TStringList.Create ;

  // snap types are shown as pictures; menus show no item hints, so the snap
  // type list shows the names next to the pictures
  for i := Low( SNAP_TYPES ) to High( SNAP_TYPES ) do begin
    item := TMenuItem.Create( pmSnapType ) ;
    item.Caption    := Copy( SNAP_TYPE_HINTS[i], 1,
                             Pos( ' - ', SNAP_TYPE_HINTS[i] ) - 1 ) ;
    item.ImageIndex := SNAP_TYPE_IMAGE + i ;
    item.Tag        := i ;
    item.OnClick    := snapTypeItemClick ;
    pmSnapType.Items.Add( item ) ;
  end ;
  setSnapType( 0 ) ;

  // snapping is off until some snap layers are checked
  applySnapLayers ;

  updateModeButtons ;
end;

{ updateModeButtons
  Presses the toolbar button of the current viewer mode. In the Add Shape mode,
  the Add Shape button is pressed instead of the Edit Mode one. }
procedure TfrmTopology.updateModeButtons;
begin
  btnZoom.Down       := GIS.Mode = TGIS_ViewerMode.Zoom ;
  btnDragMode.Down   := GIS.Mode = TGIS_ViewerMode.Drag ;
  btnSelectMode.Down := GIS.Mode = TGIS_ViewerMode.Select ;
  btnEditMode.Down   := ( GIS.Mode = TGIS_ViewerMode.Edit ) and
                        not assigned( editLayer ) ;
  btnAddShape.Down   := assigned( editLayer ) ;
end;

{ stopAdding
  Turns the Add Shape mode off. }
procedure TfrmTopology.stopAdding;
begin
  editLayer := nil ;
  updateModeButtons ;
end;

{ finishAdding
  Leaves the Add Shape mode, finishing the shape being added. Returns false if
  the shape cannot be finished (validation error). }
function TfrmTopology.finishAdding: Boolean;
begin
  Result := True ;
  if not assigned( editLayer ) then
    exit ;

  Result := endEdit ;
  if Result then
    stopAdding ;
end;

{ cancelEdit
  Cancels the current shape edit (discarding its changes) and a pending
  "Add Shape" operation, then switches the viewer to select mode. }
procedure TfrmTopology.cancelEdit;
begin
  if GIS.Editor.InEdit then
    GIS.Editor.RevertShape ;

  endEdit ;
  stopAdding ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

{ addShape
  Starts a new shape in the Add Shape mode layer at the clicked point. }
procedure TfrmTopology.addShape( const _ptg : TGIS_Point ) ;
var
  end_edit_required : Boolean ;
begin
  if not GIS.Editor.TryCreateShape( editLayer,
                                    _ptg,
                                    TGIS_ShapeType.Unknown,
                                    end_edit_required ) then begin
    // the layer does not accept new shapes
    btnSelectModeClick( Self ) ;
    exit ;
  end ;

  if end_edit_required then begin
    // e.g. a topology node - finished at once, ready for the next one
    endEdit ;
    exit ;
  end ;

  btnUndo.Enabled := True ;
  btnRedo.Enabled := True ;
end;

{ finishShape
  Finishes the shape being added and keeps the Add Shape mode on for the next
  one. }
procedure TfrmTopology.finishShape;
begin
  if GIS.Editor.InEdit then
    endEdit ;
end;

{ FormShortCut
  Handles Ctrl+Z (undo) and Ctrl+Y (redo) while a shape is being edited or
  added. The map viewer does not take the keyboard focus, so the shortcuts are
  processed on the form level. }
procedure TfrmTopology.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  key : TShortCut ;
begin
  // leave the shortcuts to edit boxes, e.g. when editing attributes
  if ( not GIS.Editor.InEdit ) or ( ActiveControl is TCustomEdit ) then
    exit ;

  key := ShortCut( Msg.CharCode, KeyDataToShiftState( Msg.KeyData ) ) ;

  if key = ShortCut( Ord( 'Z' ), [ssCtrl] ) then begin
    btnUndoClick( Self ) ;
    Handled := True ;
  end
  else if key = ShortCut( Ord( 'Y' ), [ssCtrl] ) then begin
    btnRedoClick( Self ) ;
    Handled := True ;
  end ;
end;

{ GISModeChangeEvent
  Keeps the mode buttons in sync with the viewer mode, which can also be
  changed by the topology tool (e.g. rollback switches to select mode). }
procedure TfrmTopology.GISModeChangeEvent(Sender: TObject);
begin
  if csDestroying in ComponentState then
    exit ;

  updateModeButtons ;
end;

{ GISProjectCloseEvent
  Called when the current project is closed, also when another project is
  opened. Cancels any shape edit or pending "Add Shape" operation while the
  project layers still exist - otherwise the editor would keep working on the
  released layers and crash on the next map click or end of editing. }
procedure TfrmTopology.GISProjectCloseEvent(Sender: TObject);
begin
  if csDestroying in ComponentState then
    exit ;

  cancelEdit ;

  // the snap layers belong to the closed project
  snapLayerNames.Clear ;
  applySnapLayers ;
end;

{ GISLayerDeleteEvent
  Removes a layer which is being deleted from the snap layers, so that the
  editor does not keep snapping to a released layer. }
procedure TfrmTopology.GISLayerDeleteEvent(_sender: TObject; _layer: TGIS_Layer);
var
  i : Integer ;
begin
  if csDestroying in ComponentState then
    exit ;

  // the layer of the added or edited shape is going away (e.g. deleted by
  // a topology tool) - stop working on it before it is released
  if ( _layer = editLayer ) or
     ( GIS.Editor.InEdit and ( GIS.Editor.Layer = _layer ) ) then
    cancelEdit ;

  i := snapLayerNames.IndexOf( _layer.Name ) ;
  if i >= 0 then begin
    snapLayerNames.Delete( i ) ;
    applySnapLayers ;
  end ;
end;

{ gisLegendLayerSelectEvent
  Selecting another layer in the legend finishes the shape being edited or
  added and switches the Edit or Add Shape mode to select mode, so that shapes
  are not added to a layer which is no longer selected. }
procedure TfrmTopology.gisLegendLayerSelectEvent(_sender: TObject;
  _layer: TGIS_Layer);
var
  layer : TGIS_LayerAbstract ;
begin
  if ( not assigned( editLayer ) ) and ( GIS.Mode <> TGIS_ViewerMode.Edit ) then
    exit ;

  // layer of the added or edited shape
  layer := nil ;
  if assigned( editLayer ) then
    layer := editLayer
  else if GIS.Editor.InEdit then
    layer := GIS.Editor.Layer ;

  // the same layer selected again
  if assigned( layer ) and ( _layer = layer ) then
    exit ;

  btnSelectModeClick( Self ) ;
end;

{ GISMouseWheel
  Zooms the map in (wheel rolled forward) or out (wheel rolled back), keeping
  the point under the cursor in place. Works in every mode, also while a shape
  is being edited or added. }
procedure TfrmTopology.GISMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
begin
  if GIS.IsEmpty then
    exit ;

  // MousePos is in screen coordinates
  pt := GIS.ScreenToClient( MousePos ) ;

  // 1.25x per wheel notch (WheelDelta is 120 per notch, less on smooth wheels)
  GIS.ZoomBy( Power( 1.25, WheelDelta / 120 ), pt.X, pt.Y ) ;
  Handled := True ;
end;

//=============================================================================
// Snapping
// Snap to layers (checked in a list) and snap type (chosen by picture)
//=============================================================================

{ fillSnapLayers
  Fills the snap layer list with the vector layers of the current project,
  keeping the checked ones. }
procedure TfrmTopology.fillSnapLayers;
var
  i     : Integer ;
  layer : TGIS_Layer ;
  item  : TMenuItem ;
begin
  pmSnapLayers.Items.Clear ;

  for i := 0 to GIS.Items.Count - 1 do begin
    layer := TGIS_Layer( GIS.Items[i] ) ;

    // skip helper layers, e.g. the ones of the topology tool
    if ( not ( layer is TGIS_LayerVector ) ) or layer.HideFromLegend then
      continue ;

    item := TMenuItem.Create( pmSnapLayers ) ;
    // the caption shows '&' as an accelerator, so the name is kept in Hint
    item.Caption   := StringReplace( layer.Name, '&', '&&', [rfReplaceAll] ) ;
    item.Hint      := layer.Name ;
    item.AutoCheck := True ;
    item.Checked   := snapLayerNames.IndexOf( layer.Name ) >= 0 ;
    item.OnClick   := snapLayerItemClick ;
    pmSnapLayers.Items.Add( item ) ;
  end ;

  if pmSnapLayers.Items.Count = 0 then begin
    item := TMenuItem.Create( pmSnapLayers ) ;
    item.Caption := 'No vector layers' ;
    item.Enabled := False ;
    pmSnapLayers.Items.Add( item ) ;
  end ;
end;

{ applySnapLayers
  Applies the checked snap layers to the editor. With no layer checked snapping
  is turned off. The layer of the edited shape is added to the snap layers by
  the editor itself when editing starts. }
procedure TfrmTopology.applySnapLayers;
var
  i : Integer ;
begin
  GIS.Editor.ClearSnapLayers ;
  GIS.Editor.BlockSnapping := snapLayerNames.Count = 0 ;

  for i := 0 to snapLayerNames.Count - 1 do
    GIS.Editor.AddSnapLayer( GIS.Get( snapLayerNames[i] ) ) ;

  if snapLayerNames.Count = 0 then
    btnSnapLayers.Caption := NO_SNAPPING
  else
    btnSnapLayers.Caption := String.Join( ', ', snapLayerNames.ToStringArray ) ;
end;

{ btnSnapLayersClick
  Opens the snap layer list below the button (its arrow opens the list by
  itself). }
procedure TfrmTopology.btnSnapLayersClick(Sender: TObject);
var
  pt : TPoint ;
begin
  pt := btnSnapLayers.ClientToScreen( Point( 0, btnSnapLayers.Height ) ) ;
  pmSnapLayers.Popup( pt.X, pt.Y ) ;
end;

{ pmSnapLayersPopup
  Refreshes the snap layer list, as layers may come and go with projects and
  topology operations. }
procedure TfrmTopology.pmSnapLayersPopup(Sender: TObject);
begin
  fillSnapLayers ;
end;

{ snapLayerItemClick
  Adds or removes the layer of the clicked item from the snap layers. }
procedure TfrmTopology.snapLayerItemClick( Sender : TObject ) ;
var
  item : TMenuItem ;
  i    : Integer ;
begin
  item := TMenuItem( Sender ) ;

  if item.Checked then
    snapLayerNames.Add( item.Hint )
  else begin
    i := snapLayerNames.IndexOf( item.Hint ) ;
    if i >= 0 then
      snapLayerNames.Delete( i ) ;
  end ;

  applySnapLayers ;

  // a menu closes on click - open the list again, so that more layers can be
  // checked
  PostMessage( Handle, WM_REOPEN_SNAP_LAYERS, 0, 0 ) ;
end;

{ WMReopenSnapLayers
  Opens the snap layer list again after a layer was (un)checked. }
procedure TfrmTopology.WMReopenSnapLayers( var _msg : TMessage ) ;
begin
  btnSnapLayersClick( Self ) ;
end;

{ snapTypeItemClick
  Applies the snap type of the clicked picture. }
procedure TfrmTopology.snapTypeItemClick( Sender : TObject ) ;
begin
  setSnapType( TMenuItem( Sender ).Tag ) ;
end;

{ setSnapType
  Applies the snap type to the editor and shows its picture on the toolbar. }
procedure TfrmTopology.setSnapType( const _index : Integer ) ;
var
  i : Integer ;
begin
  GIS.Editor.SnapType    := SNAP_TYPES[_index] ;
  btnSnapType.ImageIndex := SNAP_TYPE_IMAGE + _index ;
  btnSnapType.Hint       := 'Snap type: ' + SNAP_TYPE_HINTS[_index] ;

  for i := 0 to pmSnapType.Items.Count - 1 do
    pmSnapType.Items[i].Checked := i = _index ;
end;

end.
