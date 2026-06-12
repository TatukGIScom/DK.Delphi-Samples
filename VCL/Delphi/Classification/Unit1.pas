//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Classification sample — demonstrates thematic data classification of vector
  and raster (pixel) layers using the TatukGIS TGIS_ClassificationAbstract API.

  Key concepts shown:
    - Loading a layer with TGIS_ViewerWnd.Open
    - Creating a classifier with TGIS_ClassificationFactory.CreateClassifier,
      which returns the appropriate subclass for the layer type
      (TGIS_ClassificationVector or TGIS_ClassificationPixel)
    - Setting the classification target field (numeric attribute or band index)
    - Choosing a classification method from TGIS_ClassificationMethod:
        DefinedInterval, EqualInterval, GeometricalInterval, Manual,
        NaturalBreaks, KMeans, KMeansSpatial, Quantile, Quartile,
        StandardDeviation, StandardDeviationWithCentral, Unique
    - Controlling the visual output via:
        StartColor / EndColor — color gradient endpoints
        NumClasses            — number of class breaks (auto for some methods)
        Interval              — interval size (DefinedInterval / StdDev methods)
        ColorRamp / ColorRampName — named palette from GisColorRampList
        ColorRamp.DefaultColorMapMode — Continuous or Discrete color mapping
        ColorRamp.DefaultReverse      — reverse the ramp direction
    - Vector-specific properties via TGIS_ClassificationVector:
        RenderType — Color, Size, OutlineWidth, or OutlineColor
        StartSize / EndSize — symbol size range for the Size render type
        ClassIdField — optional field to store the class ID per feature
    - Managing layer statistics:
        ForceStatisticsCalculation — auto-calculate or prompt the user
        classifier.MustCalculateStatistics — check whether stats are needed
        layer.Statistics.Calculate — explicit statistics computation
    - Adding the classification result to the TGIS_ControlLegend
    - Refreshing the map with GIS.InvalidateWholeMap

  The sample opens the California Counties shapefile from the TatukGIS sample
  dataset by default but allows the user to open any supported file.
}

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ToolWin,
  Vcl.ComCtrls,

  VCL.GisControlLegend,    // TGIS_ControlLegend — interactive layer legend panel
  VCL.GisViewerWnd,        // TGIS_ViewerWnd — VCL map viewer control
  VCL.GisFramework,        // Framework helpers
  System.Math,
  System.UITypes,

  GisClasses,              // Base GIS class hierarchy
  GisClassification,       // TGIS_ClassificationAbstract, TGIS_ClassificationFactory,
                           // TGIS_ClassificationVector, TGIS_ClassificationMethod,
                           // TGIS_ClassificationRenderType
  GisLayer,                // TGIS_Layer base class
  GisLayerVector,          // TGIS_LayerVector — vector layer with field access
  GisLayerPixel,           // TGIS_LayerPixel — raster/pixel layer
  GisRegistredLayers,      // Registered layer drivers
  GisResource,             // Resource helpers
  GisRtl,                  // Run-time library helpers (FreeObject, DotStrToFloat)
  GisTypes,                // Core types (TGIS_FieldType, TGIS_ShapeType, …)
  GisTypesUI,              // UI types (TGIS_ColorMapMode, color ramp support)
  GisUtils,                // TGIS_Utils, GisColorRampList, TGIS_ColorRampNames

  VCL.GisControlColor;     // Color picker helper control

// ---------------------------------------------------------------------------
// Classification method display strings (used in cmbMethods)
// ---------------------------------------------------------------------------
const
  GIS_CLASSIFY_METHOD_DI  : String = 'Defined Interval' ;         // Fixed-width interval classes
  GIS_CLASSIFY_METHOD_EI  : String = 'Equal Interval';             // Equal data-range interval
  GIS_CLASSIFY_METHOD_GI  : String = 'Geometrical Interval' ;      // Geometrically progressing breaks
  GIS_CLASSIFY_METHOD_MN  : String = 'Manual' ;                    // User-specified break values
  GIS_CLASSIFY_METHOD_NB  : String = 'Natural Breaks' ;            // Jenks natural breaks
  GIS_CLASSIFY_METHOD_KM  : String = 'K-Means' ;                   // K-means clustering
  GIS_CLASSIFY_METHOD_KMS : String = 'K-Means Spatial' ;           // Spatially aware K-means
  GIS_CLASSIFY_METHOD_QN  : String = 'Quantile' ;                  // Equal-count quantile classes
  GIS_CLASSIFY_METHOD_QR  : String = 'Quartile' ;                  // Four quartile classes
  GIS_CLASSIFY_METHOD_SD  : String = 'Standard Deviation' ;        // Std-dev symmetric classes
  GIS_CLASSIFY_METHOD_SDC : String = 'Standard Deviation with Central'; // Std-dev with centre class
  GIS_CLASSIFY_METHOD_UNQ : String = 'Unique' ;                    // One class per unique value

type
  { TfrmClassification — main form for the Classification sample.

    The panel on the left (pnlClassification) contains all classification
    controls.  The map viewer (GIS) and the legend (GIS_Legend) occupy the
    remaining space. }
  TfrmClassification = class(TForm)
    GIS: TGIS_ViewerWnd;                     // Map viewer control
    GIS_Legend: TGIS_ControlLegend;          // Interactive layer legend
    pnlClassification: TPanel;               // Left-hand classification controls panel
    cmbFields: TComboBox;                    // Numeric field / band selector
    cmbMethods: TComboBox;                   // Classification method selector
    lblField: TLabel;
    lblMethod: TLabel;
    lblClasses: TLabel;
    cmbClasses: TComboBox;                   // Number of classes (1–9)
    cmbRenderType: TComboBox;                // Render type: Color, Size, etc.
    lblRender: TLabel;
    pnlParamsBasic: TPanel;                  // Panel: basic color/size params
    lblStartColor: TLabel;
    pnlStartColor: TPanel;                   // Color swatch for start color
    lblEndColor: TLabel;
    pnlEndColor: TPanel;                     // Color swatch for end color
    lblInterval: TLabel;
    edtInterval: TEdit;                      // Interval value (DefinedInterval method)
    cmbStdInterval: TComboBox;               // Std-dev interval fraction selector
    lblStartSize: TLabel;
    edtStartSize: TEdit;                     // Min symbol size (Size render type)
    lblEndSize: TLabel;
    edtEndSize: TEdit;                       // Max symbol size (Size render type)
    dlgColor: TColorDialog;                  // System color-picker dialog
    cbxLegend: TCheckBox;                    // Toggle classification result in legend
    edtClassIdField: TEdit;                  // Optional field name to store class IDs
    Label1: TLabel;
    btnOpen: TButton;                        // Open a different layer file
    dlgFileOpen: TOpenDialog;               // File-open dialog
    edtManualBreaks: TEdit;                  // Comma-separated manual break values
    btnAddManualBreak: TButton;              // Apply manual breaks
    lblManual: TLabel;
    cbxForceStatisticsCalculation: TCheckBox; // Auto-calculate statistics before classifying
    pnlParamsColorRamp: TPanel;              // Panel: color ramp controls
    cbxColorRampName: TCheckBox;             // Use ColorRampName instead of ColorRamp object
    cbxColorRamp: TCheckBox;                 // Enable color ramp override
    cmbColorRamps: TComboBox;                // Named color ramp selector
    Label2: TLabel;
    cmbColormapMode: TComboBox;              // Continuous vs. Discrete color mapping
    cbxReverse: TCheckBox;                   // Reverse the ramp color order
    procedure cmbFieldsChange(Sender: TObject);
    procedure cmbMethodsChange(Sender: TObject);
    procedure cmbClassesChange(Sender: TObject);
    procedure cmbRenderTypeChange(Sender: TObject);
    procedure cmbStdIntervalChange(Sender: TObject);
    procedure pnlStartColorClick(Sender: TObject);
    procedure pnlEndColorClick(Sender: TObject);
    procedure validateEdit( Sender : TObject ) ;
    procedure btnOpenClick(Sender: TObject);
    procedure cbxLegendClick(Sender: TObject);
    procedure cbxColorRampClick(Sender: TObject);
    procedure cmbColorRampsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddManualBreakClick(Sender: TObject);
    procedure cbxForceStatisticsCalculationClick(Sender: TObject);
    procedure cbxReverseClick(Sender: TObject);
    procedure cmbColormapModeChange(Sender: TObject);
  private
    { Private declarations }
    procedure fillCmbFields ;
    procedure fillCmbColorRamps ;
    procedure doClassify(Sender: TObject) ;
    function  getLayer : TGIS_Layer ;
    procedure setColorRampControls( const _enable : Boolean ) ;
  public
    { Public declarations }
  end;

var
  frmClassification: TfrmClassification;

implementation

uses
  GisAllLayers,    // Registers all built-in layer drivers
  GisFunctions ;   // Utility functions (GisSupportedFiles, etc.)

{$R *.dfm}

const
  // Render type display strings (used in cmbRenderType)
  RENDER_TYPE_SIZE           = 'Size / Width' ;   // Vary symbol size by class
  RENDER_TYPE_COLOR          = 'Color' ;           // Vary fill color by class
  RENDER_TYPE_OUTLINE_WIDTH  = 'Outline width' ;   // Vary outline width by class
  RENDER_TYPE_OUTLINE_COLOR  = 'Outline color' ;   // Vary outline color by class

  // Standard deviation interval fraction display strings
  STD_INTERVAL_ONE           = '1 STDEV' ;
  STD_INTERVAL_ONE_HALF      = '1/2 STDEV' ;
  STD_INTERVAL_ONE_THIRD     = '1/3 STDEV' ;
  STD_INTERVAL_ONE_QUARTER   = '1/4 STDEV' ;

{ TfrmClassification.FormShow
  Populates the file-open dialog filter, then loads the default sample layer
  (California Counties shapefile) and fills the field and color-ramp combo
  boxes.

  GisSupportedFiles returns a filter string for all registered layer formats.
  fillCmbFields populates cmbFields with the layer's numeric attributes and
  any built-in virtual fields (GIS_UID, GIS_AREA, etc.).
  fillCmbColorRamps populates cmbColorRamps from the global GisColorRampList. }
procedure TfrmClassification.FormShow(Sender: TObject);
begin
  // Build the file-open dialog filter from all registered TatukGIS formats
  dlgFileOpen.Filter := GisSupportedFiles( [TGIS_FileType.All] , false);

  // Open the default sample layer (California county polygons)
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
    'World\Countries\USA\States\California\Counties.shp'
  ) ;

  fillCmbFields ;      // Populate the field picker from the loaded layer
  fillCmbColorRamps ;  // Populate the color ramp picker from GisColorRampList
end;

{ TfrmClassification.btnAddManualBreakClick
  Triggers a re-classification using the current manual break values entered
  in edtManualBreaks.  The actual parsing and application of breaks is done
  inside doClassify. }
procedure TfrmClassification.btnAddManualBreakClick(Sender: TObject);
begin
  doClassify( Sender ) ;
end;

{ TfrmClassification.btnOpenClick
  Allows the user to open a different file for classification.
  After opening, refreshes the field list and color-ramp list to match the
  new layer. }
procedure TfrmClassification.btnOpenClick(Sender: TObject);
var
  path : String ;
begin
  if not dlgFileOpen.Execute then
    exit ;

  path := dlgFileOpen.FileName ;

  GIS.Open( path ) ;

  fillCmbFields ;      // Re-populate fields for the newly opened layer
  fillCmbColorRamps ;  // Re-populate color ramps (ramp list is global)
end;

{ TfrmClassification.fillCmbFields
  Populates cmbFields with all numeric field names from the current layer.

  For vector layers (TGIS_LayerVector):
    - Always includes virtual fields: GIS_UID, GIS_AREA, GIS_LENGTH,
      GIS_CENTROID_X, GIS_CENTROID_Y (computed on-the-fly by the engine)
    - Adds attribute fields of type Number or Float from the layer schema

  For pixel/raster layers (TGIS_LayerPixel):
    - Adds one entry per band (band index as string), since bands are the
      "fields" to classify raster data on.

  The first item is selected by default. }
procedure TfrmClassification.fillCmbFields ;
var
  lyr   : TGIS_Layer ;
  lv    : TGIS_LayerVector ;
  lp    : TGIS_LayerPixel ;
  field : TGIS_FieldInfo ;
  i     : Integer;
begin
  cmbFields.Items.BeginUpdate ;
  cmbFields.Items.Clear ;

  lyr := TGIS_Layer( getLayer ) ;
  if lyr is TGIS_LayerVector then begin
    lv := TGIS_LayerVector ( getLayer ) ;

    // Virtual fields always available for vector layers (computed by the engine)
    cmbFields.Items.Add('GIS_UID');        // Unique feature identifier
    cmbFields.Items.Add('GIS_AREA');       // Feature area (polygon layers)
    cmbFields.Items.Add('GIS_LENGTH');     // Feature perimeter / line length
    cmbFields.Items.Add('GIS_CENTROID_X'); // Centroid X coordinate
    cmbFields.Items.Add('GIS_CENTROID_Y'); // Centroid Y coordinate

    // Add numeric attribute fields from the layer's schema
    for field in lv.Fields do begin
      case field.FieldType of
        TGIS_FieldType.Number,
        TGIS_FieldType.Float : cmbFields.Items.Add( field.Name ) ;
      end ;
    end ;
  end
  else if lyr is TGIS_LayerPixel then begin
    // For raster layers, each band index acts as a classifiable "field"
    lp := TGIS_LayerPixel ( getLayer ) ;
    for i := 1 to lp.BandsCount do
      cmbFields.Items.Add( i.ToString ) ;
  end ;

  cmbFields.ItemIndex := 0 ;
  cmbFields.Items.EndUpdate ;
end;

{ TfrmClassification.fillCmbColorRamps
  Populates cmbColorRamps from the global GisColorRampList registry.
  GisColorRampList contains all built-in and any user-registered named color
  ramps.  The well-known 'GreenBlue' ramp is pre-selected.
  A 'None' entry is appended so the user can disable the color ramp override. }
procedure TfrmClassification.fillCmbColorRamps ;
var
  i : Integer ;
  ramp_name : String ;
begin
  cmbColorRamps.Items.BeginUpdate ;
  cmbColorRamps.Clear ;

  for i := 0 to GisColorRampList.Count - 1 do begin
    ramp_name := GisColorRampList.Items[i].Name ;

    cmbColorRamps.Items.Add( ramp_name ) ;

    // Pre-select GreenBlue as the default ramp
    if ramp_name = 'GreenBlue' then
      cmbColorRamps.ItemIndex := i ;

  end ;

  // Allow the user to disable the color ramp (use Start/End color instead)
  cmbColorRamps.Items.Add( 'None' ) ;
  cmbColorRamps.Items.EndUpdate ;
end;


{ TfrmClassification.getLayer
  Returns the first layer in the viewer's layer collection, or nil if no
  layers have been loaded.  Classification always operates on layer index 0. }
function TfrmClassification.getLayer : TGIS_Layer ;
begin
  Result := nil ;
  if GIS.Items.Count <= 0 then
    exit ;

  Result := TGIS_Layer( GIS.Items[0] ) ;
end;

{ TfrmClassification.validateEdit
  Validates the text in an edit control and triggers re-classification when
  the value is a valid floating-point number.

  Called by edtInterval, edtStartSize, and edtEndSize OnChange handlers.
  Only fires doClassify when the current method and render type make the
  edited field meaningful to avoid classifying with partial input. }
procedure TfrmClassification.validateEdit( Sender : TObject ) ;
var
  d : Double ;
begin
  if ( SameStr( cmbMethods.Text, GIS_CLASSIFY_METHOD_DI ) or
       SameStr( cmbRenderType.Text, RENDER_TYPE_SIZE ) or
       SameStr( cmbRenderType.Text, RENDER_TYPE_OUTLINE_WIDTH ) ) and
     TryStrToFloat( TEdit( Sender ).Text, d )
  then
    doClassify( Sender ) ;
end;

{ TfrmClassification.pnlEndColorClick
  Opens the system color dialog and applies the chosen color as the
  classification end color (deepest-value class color in the gradient). }
procedure TfrmClassification.pnlEndColorClick(Sender: TObject);
begin
  if not dlgColor.Execute then exit ;
  pnlEndColor.Color := dlgColor.Color ;

  doClassify( Sender ) ;
end;

{ TfrmClassification.pnlStartColorClick
  Opens the system color dialog and applies the chosen color as the
  classification start color (lowest-value class color in the gradient). }
procedure TfrmClassification.pnlStartColorClick(Sender: TObject);
begin
  if not dlgColor.Execute then
    exit ;
  pnlStartColor.Color := dlgColor.Color ;

  doClassify( Sender ) ;
end;

{ TfrmClassification.setColorRampControls
  Enables or disables all color-ramp-related controls (name checkbox, ramp
  picker, colormap mode, and reverse toggle) as a unit.
  Called when the "Use Color Ramp" checkbox is toggled. }
procedure TfrmClassification.setColorRampControls( const _enable : Boolean ) ;
begin
  cbxColorRampName.Enabled := _enable ;
  cmbColorRamps.Enabled := _enable ;
  cmbColormapMode.Enabled := _enable ;
  cbxReverse.Enabled := _enable ;
end;

{ Simple event-to-classify forwarders — each control change re-runs the
  full classification pipeline through doClassify. }

procedure TfrmClassification.cmbFieldsChange(Sender: TObject);
begin
  doClassify( Sender ) ;  // Re-classify when the target field changes
end;

{ TfrmClassification.cmbMethodsChange
  Handles changes to the classification method combo box.
  Shows/hides the interval edit, std-dev interval combo, number-of-classes
  combo, and manual-breaks input depending on which method was selected, then
  calls doClassify to apply the new method immediately.

  Some methods have a fixed class count determined by the data (DefinedInterval,
  Quartile, StandardDeviation variants) so the classes combo is hidden for them. }
procedure TfrmClassification.cmbMethodsChange(Sender: TObject);
var
  f      : Single ;
  method : String ;

  { Helper — show/hide the interval text edit }
  procedure setInterval( val : Boolean ) ;
  begin
    edtInterval.Visible := val ;
    lblInterval.Visible := val ;
  end;
  procedure showInterval ; begin setInterval( True ) ; end;
  procedure hideInterval ; begin setInterval( False ) ; end;

  { Helper — show/hide the standard-deviation interval combo }
  procedure setStdDev( val : Boolean ) ;
  begin
    cmbStdInterval.Visible := val ;
    lblInterval.Visible  := val ;
  end;
  procedure showStdDev ; begin setStdDev( True ) ; end;
  procedure hideStdDev ; begin setStdDev( False ) ; end;

  { Helper — show/hide the number-of-classes combo }
  procedure setClasses( val : Boolean ) ;
  begin
    cmbClasses.Visible := val ;
    lblClasses.Visible  := val ;
  end;
  procedure showClasses ; begin setClasses( True ) ; end;
  procedure hideClasses ; begin setClasses( False ) ; end;

  { Helper — show/hide the manual break entry controls }
  procedure setManual( val : Boolean ) ;
  begin
    edtManualBreaks.Visible := val ;
    lblManual.Visible  := val ;
    btnAddManualBreak.Visible := val ;
  end;
  procedure showManual ; begin setManual( True ) ; end;
  procedure hideManual ; begin setManual( False ) ; end;

begin
  // Reset interval text if it is not a valid number
  if not TryStrToFloat( edtInterval.Text, f ) then
    edtInterval.Text := '100' ;

  // Reset ramp/mode defaults each time the method changes
  cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf(TGIS_ColorRampNames.GreenBlue) ;
  cmbColormapMode.ItemIndex := cmbColormapMode.Items.IndexOf( GIS_COLORMAPMODE_CONTINUOUS ) ;

  method := cmbMethods.Items[cmbMethods.ItemIndex] ;

  if cmbMethods.ItemIndex = 0 then begin
    // "Select ..." placeholder — hide all optional controls
    hideInterval ;
    hideStdDev ;
    hideClasses ;
    hideManual ;
  end
  else if method = GIS_CLASSIFY_METHOD_DI then begin
    // Defined Interval: user specifies the interval width, class count is auto
    hideStdDev ;
    hideClasses ;
    hideManual ;
    showInterval ;
  end
  else if method = GIS_CLASSIFY_METHOD_MN then begin
    // Manual: user types comma-separated break values
    hideInterval ;
    hideStdDev ;
    hideClasses ;
    showManual ;
  end
  else if method = GIS_CLASSIFY_METHOD_QR then begin
    // Quartile: always produces 4 classes — hide class count and interval
    hideInterval ;
    hideStdDev ;
    hideClasses ;
    hideManual ;
    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.BrownGreen) ;
  end
  else if ( method = GIS_CLASSIFY_METHOD_SD ) or
          ( method = GIS_CLASSIFY_METHOD_SDC ) then
  begin
    // Standard deviation variants: interval is a fraction of one std dev
    hideInterval ;
    hideClasses ;
    hideManual ;
    showStdDev ;
    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.BrownGreen ) ;
  end
  else if method = GIS_CLASSIFY_METHOD_UNQ then
  begin
    // Unique: one class per distinct value — force discrete color mapping
    hideInterval ;
    hideClasses ;
    hideStdDev ;
    hideManual ;
    cmbColorRamps.ItemIndex := cmbColorRamps.Items.IndexOf( TGIS_ColorRampNames.Unique ) ;
    cmbColormapMode.ItemIndex := cmbColormapMode.Items.IndexOf( GIS_COLORMAPMODE_DISCRETE ) ;
    cbxColorRamp.Checked := True ;
  end
  else begin
    // All other methods (EqualInterval, NaturalBreaks, KMeans, Quantile, etc.)
    // allow the user to specify the number of classes
    hideInterval ;
    hideStdDev ;
    hideManual ;
    showClasses ;
  end ;

  doClassify( Sender ) ;
end;

{ TfrmClassification.cmbRenderTypeChange
  Validates the selected render type against the layer's geometry type.
  Size / Width rendering is not meaningful for polygon layers (a polygon has
  no single "size" to vary), so it is disallowed and the user is warned.
  Layer params are reset via ParamsList.ClearAndSetDefaults so any previous
  classification styling is cleared before the new type is applied. }
procedure TfrmClassification.cmbRenderTypeChange(Sender: TObject);
var
  ll : TGIS_Layer ;
begin
  ll := getLayer ;
  if ll is TGIS_LayerVector then begin
    // Clear any per-feature rendering parameters set by a previous classification
    ll.ParamsList.ClearAndSetDefaults ;
    if ( TGIS_LayerVector( ll ).DefaultShapeType = TGIS_ShapeType.Polygon ) and
       ( cmbRenderType.Items[cmbRenderType.ItemIndex] = RENDER_TYPE_SIZE ) then begin
      // Size rendering is not valid for polygon features
      messagedlg( 'Method not allowed for polygons.', mtWarning, [mbOK], 0 ) ;
      cmbRenderType.ItemIndex := 1 ; // Fall back to Color
    end ;
  end ;
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cmbStdIntervalChange(Sender: TObject);
begin
  doClassify( Sender ) ;  // Re-classify with the new std-dev interval fraction
end;

procedure TfrmClassification.cbxColorRampClick(Sender: TObject);
begin
  // Enable/disable ramp sub-controls to match the checkbox state
  setColorRampControls( cbxColorRamp.Checked ) ;
  doClassify( Sender ) ;
end;

procedure TfrmClassification.cbxForceStatisticsCalculationClick(Sender: TObject);
begin
  doClassify( Sender ) ;  // Re-classify; statistics handling may now change
end;

procedure TfrmClassification.cbxLegendClick(Sender: TObject);
begin
  doClassify( Sender ) ;  // Toggle whether classification is shown in the legend
end;

procedure TfrmClassification.cbxReverseClick(Sender: TObject);
begin
  doClassify( Sender ) ;  // Reverse the color ramp order
end;

procedure TfrmClassification.cmbClassesChange(Sender: TObject);
begin
  doClassify( Sender ) ;  // Re-classify with the new class count
end;

procedure TfrmClassification.cmbColormapModeChange(Sender: TObject);
begin
  doClassify( Sender ) ;  // Switch between Continuous and Discrete color mapping
end;

procedure TfrmClassification.cmbColorRampsChange(Sender: TObject);
begin
  doClassify( Sender ) ;  // Apply the newly selected color ramp
end;

{ TfrmClassification.doClassify
  Core classification routine — called whenever any classification parameter
  changes.  Assembles a fully configured TGIS_ClassificationAbstract (or its
  TGIS_ClassificationVector subclass) and calls Classify to apply the result
  to the layer's rendering parameters.

  Workflow:
    1. Validate that a method has been selected and a layer is loaded.
    2. Optionally add a ClassIdField to the vector layer to store class IDs.
    3. Create a classifier via TGIS_ClassificationFactory.CreateClassifier.
    4. Configure common properties: Target, NumClasses, StartColor, EndColor,
       ShowLegend, Method, Interval, manual break points, ColorRamp.
    5. Configure vector-only properties: StartSize, EndSize, ClassIdField,
       RenderType.
    6. Handle statistics: either force automatic calculation or prompt the user.
    7. Call classifier.Classify to write rendering parameters to the layer.
    8. Call GIS.InvalidateWholeMap to repaint with the new classification. }
procedure TfrmClassification.doClassify(Sender: TObject) ;
var
  lyr              : TGIS_Layer ;
  lv               : TGIS_LayerVector ;
  method           : String ;
  render_type      : String ;
  std_interval     : String ;
  class_id_field   : String ;
  create_field     : Boolean ;
  classifier       : TGIS_ClassificationAbstract ;
  classifier_vec   : TGIS_ClassificationVector ;
  class_breaks_arr : TArray< String > ;
  class_break_str  : String ;
  class_break_val  : Double ;
  colormap_mode    : TGIS_ColorMapMode ;
  ramp_name        : String ;
begin
  // Only proceed if the user has actually selected a method
  if cmbMethods.ItemIndex <= 0 then exit ;

  create_field := False ;
  lyr := TGIS_Layer( getLayer ) ;
  if not assigned( lyr ) then
    exit ;

  if lyr is TGIS_LayerVector then begin
    lv := TGIS_LayerVector( lyr ) ;

    // If a class ID field name is provided, add it to the layer's schema
    // (if it does not already exist) to store the class index per feature.
    class_id_field := edtClassIdField.Text ;
    create_field := ( length( class_id_field ) > 0 ) ;
    if create_field and ( lv.FindField( class_id_field ) < 0 ) then
      lv.AddField( class_id_field, TGIS_FieldType.Number, 3, 0 ) ;
  end
  else if not ( lyr is TGIS_LayerPixel ) then begin
    messagedlg(
      Format( 'Layer ''%s'' is not supported.', [TGIS_LayerPixel( lyr ).Name] ),
      mtWarning, [mbOK], 0
    ) ;
    exit ;
  end ;

  // TGIS_ClassificationFactory.CreateClassifier inspects the layer type and
  // returns either TGIS_ClassificationVector or TGIS_ClassificationPixel.
  classifier := TGIS_ClassificationFactory.CreateClassifier( lyr ) ;
  try
    // --- Common properties ---

    // Target: the attribute field name (vector) or band index (pixel) to classify
    classifier.Target := cmbFields.Items[ cmbFields.ItemIndex ] ;

    { NumClasses is automatically calculated (ignored) for methods that
      determine their own class count: DefinedInterval, Quartile,
      StandardDeviation, StandardDeviationWithCentral. }
    classifier.NumClasses := cmbClasses.ItemIndex + 1 ;

    // Color gradient: StartColor = lowest value, EndColor = highest value
    // TGIS_Color.FromBGR converts a Windows COLORREF (BGR order) to TGIS_Color.
    classifier.StartColor := TGIS_Color.FromBGR( pnlStartColor.Color ) ;
    classifier.EndColor := TGIS_Color.FromBGR( pnlEndColor.Color ) ;

    // ShowLegend: whether to populate the layer's legend with class entries
    classifier.ShowLegend := cbxLegend.Checked ;

    // --- Classification method ---
    method := cmbMethods.Items[cmbMethods.ItemIndex] ;
    if method = GIS_CLASSIFY_METHOD_DI then
      classifier.Method := TGIS_ClassificationMethod.DefinedInterval
    else if method = GIS_CLASSIFY_METHOD_EI then
      classifier.Method := TGIS_ClassificationMethod.EqualInterval
    else if method = GIS_CLASSIFY_METHOD_GI then
      classifier.Method := TGIS_ClassificationMethod.GeometricalInterval
    else if method = GIS_CLASSIFY_METHOD_KM then
      classifier.Method := TGIS_ClassificationMethod.KMeans
    else if method = GIS_CLASSIFY_METHOD_KMS then
      classifier.Method := TGIS_ClassificationMethod.KMeansSpatial
    else if method = GIS_CLASSIFY_METHOD_MN then
      classifier.Method := TGIS_ClassificationMethod.Manual
    else if method = GIS_CLASSIFY_METHOD_NB then
      classifier.Method := TGIS_ClassificationMethod.NaturalBreaks
    else if method = GIS_CLASSIFY_METHOD_QN then
      classifier.Method := TGIS_ClassificationMethod.Quantile
    else if method = GIS_CLASSIFY_METHOD_QR then
      classifier.Method := TGIS_ClassificationMethod.Quartile
    else if method = GIS_CLASSIFY_METHOD_SD then
      classifier.Method := TGIS_ClassificationMethod.StandardDeviation
    else if method = GIS_CLASSIFY_METHOD_SDC then
      classifier.Method := TGIS_ClassificationMethod.StandardDeviationWithCentral
    else if method = GIS_CLASSIFY_METHOD_UNQ then
      classifier.Method := TGIS_ClassificationMethod.Unique
    else
      classifier.Method := TGIS_ClassificationMethod.NaturalBreaks ;

    // --- Interval ---
    // For DefinedInterval: the fixed class width.
    // For StandardDeviation methods: overridden below with a fraction.
    classifier.Interval := DotStrToFloat( edtInterval.Text ) ;
    if ( method = GIS_CLASSIFY_METHOD_SD ) or
       ( method = GIS_CLASSIFY_METHOD_SDC ) then
    begin
      // Standard deviation: Interval is a fraction of one standard deviation
      std_interval := cmbStdInterval.Items[cmbStdInterval.ItemIndex] ;
      if std_interval = STD_INTERVAL_ONE then
        classifier.Interval := 1
      else if std_interval = STD_INTERVAL_ONE_HALF then
        classifier.Interval := 1/2
      else if std_interval = STD_INTERVAL_ONE_THIRD then
        classifier.Interval := 1/3
      else if std_interval = STD_INTERVAL_ONE_QUARTER then
        classifier.Interval := 1/4
      else
        classifier.Interval := 1;
    end ;

    // --- Manual class breaks ---
    // Parse a comma/semicolon/slash-delimited list of break values and add
    // each one to the classifier via AddClassBreak.
    class_breaks_arr := string(edtManualBreaks.Text).Split( [',', ';', '/'] ) ;
    for class_break_str in class_breaks_arr do
    begin
      try
        class_break_val := DotStrToFloat(class_break_str) ;
      except
        continue;  // Skip values that cannot be parsed as numbers
      end;
      classifier.AddClassBreak(class_break_val) ;
    end;

    // --- Color ramp ---
    // A color ramp overrides the simple StartColor/EndColor gradient with a
    // named multi-color palette.  The ramp can be assigned either by object
    // reference (ColorRamp) or by its registered name (ColorRampName); the
    // latter is useful when serialising classification settings to a project.
    if cbxColorRamp.Checked and ( cmbColorRamps.Text <> 'None' ) then begin
      // Determine whether to render colors as a smooth gradient or as distinct
      // per-class color blocks
      if cmbColormapMode.Items[cmbColormapMode.ItemIndex] = GIS_COLORMAPMODE_CONTINUOUS then
        colormap_mode := TGIS_ColorMapMode.Continuous
      else
        colormap_mode := TGIS_ColorMapMode.Discrete ;

      ramp_name := cmbColorRamps.Items[cmbColorRamps.ItemIndex] ;
      if cbxColorRampName.Checked then
        // Assign by name — the engine resolves the ramp at render time
        classifier.ColorRampName := ramp_name
      else
        // Assign the live ramp object from the global registry
        classifier.ColorRamp := GisColorRampList.ByName( ramp_name ) ;

      classifier.ColorRamp.DefaultColorMapMode := colormap_mode ;
      classifier.ColorRamp.DefaultReverse := cbxReverse.Checked ;
    end
    else begin
      classifier.ColorRamp := nil ;  // Use plain StartColor/EndColor gradient
    end ;

    // --- Vector-only parameters ---
    if classifier is TGIS_ClassificationVector then begin
      classifier_vec := TGIS_ClassificationVector( classifier ) ;
      classifier_vec.StartSize := StrToInt( edtStartSize.Text ) ;  // Min symbol size
      classifier_vec.EndSize := StrToInt( edtEndSize.Text ) ;      // Max symbol size
      classifier_vec.ClassIdField := class_id_field ;               // Field to store class IDs

      // Render type: how the classification is visualised for each class
      render_type := cmbRenderType.Items[cmbRenderType.ItemIndex] ;
      if render_type = RENDER_TYPE_SIZE then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Size
      else if render_type = RENDER_TYPE_COLOR then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Color
      else if render_type = RENDER_TYPE_OUTLINE_WIDTH then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.OutlineWidth
      else if render_type = RENDER_TYPE_OUTLINE_COLOR then
        classifier_vec.RenderType := TGIS_ClassificationRenderType.OutlineColor
      else
        classifier_vec.RenderType := TGIS_ClassificationRenderType.Color ;
    end ;

    { --- Statistics management ---
      Classification algorithms (NaturalBreaks, KMeans, etc.) require layer
      statistics (min, max, mean, std dev) to be calculated first.

      ForceStatisticsCalculation = True  (default):
        The classifier automatically re-calculates statistics before each run,
        ensuring they are always up to date at the cost of extra computation.

      ForceStatisticsCalculation = False:
        The classifier checks MustCalculateStatistics; if statistics are
        missing or stale, this code prompts the user whether to recalculate. }
    classifier.ForceStatisticsCalculation := cbxForceStatisticsCalculation.Checked ;
    if (not classifier.ForceStatisticsCalculation) and classifier.MustCalculateStatistics then begin
      if messagedlg('Statistics need to be calculated.', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
        lyr.Statistics.Calculate ;  // Compute statistics now
      end
      else begin
        lyr.Statistics.ResetModified ;  // Discard the stale-statistics flag
        exit ;
      end ;
    end ;

    // Run the classification; if a ClassIdField was requested and the layer
    // is a vector layer, persist the class IDs to the data source.
    if classifier.Classify and create_field and assigned( lv ) then
      lv.SaveData ;
  finally
    FreeObject( classifier ) ;  // Free the temporary classifier object
  end ;

  // Repaint the viewer so the new classification colours are rendered
  GIS.InvalidateWholeMap ;
end;

end.
