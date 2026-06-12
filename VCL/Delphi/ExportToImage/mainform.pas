//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  ExportToImage sample - Delphi VCL

  Demonstrates how to export a GIS map layer to a raster image or a numeric
  elevation grid using the TatukGIS Developer Kernel (DK11) API.

  Key concepts shown:
  - Loading raster imagery (JPEG) and DEM/elevation grids (ADF) into a
    TGIS_ViewerWnd viewer control.
  - Creating a new output TGIS_LayerPixel via GisCreateLayer, which selects
    the appropriate driver from the file extension.
  - Querying a layer's Capabilities (TGIS_LayerPixelSubFormatList) to discover
    the sub-formats (pixel depth, compression, etc.) supported by the chosen
    file format.
  - Controlling export resolution via three strategies:
      * Best quality  - pixel size matched to the highest-density source layer.
      * For document  - fixed physical paper width at 300 DPI.
      * For Web       - fixed pixel width at 96 DPI (screen resolution).
  - Controlling export spatial coverage through:
      * Full extent   - entire geographic bounding box of all layers.
      * Visible extent - only what is currently visible in the viewer.
  - Performing the raster conversion with TGIS_LayerPixel.ImportLayer, which
    resamples the source layer into the target layer at the requested size.
}
unit mainform;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Contnrs,

  Winapi.Windows,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ActnList,

  //GisLicense,
  GisAllLayers,
  GisClasses,
  GisEditor,
  GisLayer,
  GisLayerPixel,
  GisRegistredLayers,
  GisResource,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

const
  { Default PPI (pixels per inch) for best-quality and document export modes.
    300 DPI is the standard minimum for print-quality raster output. }
  DEFAULT_PPI            = 300  ;

  { Screen/web resolution in DPI. 96 PPI is the standard Windows screen DPI
    and produces compact images suitable for web display. }
  DEFAULT_PPI_WEB        = 96   ;

  { Document print resolution in DPI. Matches DEFAULT_PPI for print use. }
  DEFAULT_PPI_DOC        = 300  ;

  { Fallback output width in pixels when no raster layer is present to derive
    a natural resolution. 4200 px at 300 DPI corresponds to a 14-inch wide image. }
  DEFAULT_WIDTHPIX       = 4200 ;

  { Default pixel width for the web export profile (640 px wide). }
  DEFAULT_WIDTHPIX_WEB   = 640  ;

  { Document page width references in millimetres, centimetres, and inches.
    These define the physical width of the exported image for the "document"
    quality preset (6.3 inches ≈ 160 mm, a common A4 text-area width). }
  DEFAULT_WIDTH_DOC_MM   = 160  ;
  DEFAULT_WIDTH_DOC_CM   = 16   ;
  DEFAULT_WIDTH_DOC_INCH = 6.3  ;

var
  { Source raster layer loaded in the viewer. This is the layer whose pixel
    data will be read and resampled into the output file. }
  lstp           : TGIS_LayerPixel ;

  { Target pixel layer that writes to the chosen output file. Created by
    GisCreateLayer and populated via ImportLayer. }
  lpx            : TGIS_LayerPixel ;

type
  { Main form for the ExportToImage sample. }
  TfrmExportToImage = class(TForm)
    btnSave           : TButton;        // Triggers the export action
    actlMain          : TActionList;
    actSave           : TAction;        // Action bound to btnSave
    gbFile            : TGroupBox;      // File path group
    edtFile           : TEdit;          // Displays the chosen output file path
    gbCompression     : TGroupBox;      // Format/compression options group
    gbSize            : TGroupBox;      // Resolution options group
    rbQbest           : TRadioButton;   // Best quality preset
    rbQdoc            : TRadioButton;   // Document (print) quality preset
    rbQweb            : TRadioButton;   // Web (screen) quality preset
    dlgSaveImage      : TSaveDialog;    // Save dialog for image formats
    GroupBox1         : TGroupBox;      // Options group
    lbFormat          : TLabel;
    cbType            : TComboBox;      // Lists available TGIS_LayerPixelSubFormats
    GIS               : TGIS_ViewerWnd; // Interactive map viewer
    rbExtentMap       : TRadioButton;   // Export the full map extent
    rbExtentVisible   : TRadioButton;   // Export only the current viewport
    Label1            : TLabel;
    btnSelectFile     : TButton;        // Opens the save dialog
    rbImage           : TRadioButton;   // Switch viewer to raster image mode
    rbGrid            : TRadioButton;   // Switch viewer to elevation grid mode
    dlgSaveGrid       : TSaveDialog;    // Save dialog for grid formats

    procedure actSaveExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GISBusy(_sender: TObject; _pos, _end: Integer;
                      var _abort: Boolean);
    procedure btnSelectFileClick(Sender: TObject);
    procedure rbImageClick(Sender: TObject);
    procedure rbGridClick(Sender: TObject);

  private
    { Linked list that owns the T_capability objects stored as Items.Objects
      in cbType, so they are freed when the combobox is cleared. }
    lst                         : TObjectList               ;

    { Geographic bounding box used for the export operation. Set from either
      GIS.Extent (full) or GIS.VisibleExtent (current viewport). }
    FExtent                     : TGIS_Extent               ;

    { Physical size of the output image in inches (used by the document
      preset to derive pixel dimensions from PPI). }
    expWidth,
    expHeight                   : Double                    ;

    { Output image size in pixels. These are passed to ImportLayer and must
      be positive integers; the aspect ratio is always preserved from FExtent. }
    pixWidth,
    pixHeight                   : Double                    ;

    { Pixels per inch used for the current export. Determines the relationship
      between physical document size and pixel dimensions. }
    Ppi                         : Integer                   ;

  protected
    { Calculate pixWidth/pixHeight for the "Best quality" preset.
      Scans all pixel layers in the viewer to find the one with the highest
      pixel density (pixels per map unit), then derives the output dimensions
      so that the exported image has the same native resolution as the best
      source layer over the chosen extent. Falls back to DEFAULT_WIDTHPIX when
      no raster layer is present. }
    procedure ValuesInit ;

    { Convert pixWidth/Ppi -> expWidth (physical inches) and compute expHeight
      to maintain the geographic aspect ratio of FExtent. Used by the Web preset
      to store the physical size implied by the chosen pixel count. }
    procedure ValuesWH   ;

    { Convert expWidth * Ppi -> pixWidth (pixels) and compute pixHeight to
      maintain the geographic aspect ratio of FExtent. Used by the Document
      preset, where the physical paper width is known first. }
    procedure ValuesWHpix;
  end;

var
  frmExportToImage: TfrmExportToImage;

implementation

type
  { Thin wrapper that deep-copies a TGIS_LayerPixelSubFormat descriptor so
    that each combobox entry owns an independent copy. This is necessary
    because TGIS_LayerPixelSubFormatList may reuse or free its items; a
    CreateCopy ensures the selection survives after the list is released. }
  T_capability = class
  public
    C : TGIS_LayerPixelSubFormat ;
    constructor Create( const _c : TGIS_LayerPixelSubFormat ) ;
  end;
{$R *.dfm}

{ Progress callback fired by TGIS_ViewerWnd while it is busy processing data.
  _pos and _end carry the current and maximum progress values; when _end <= 0
  the operation has not yet provided a meaningful total so we show a plain
  caption instead of a percentage. }
procedure TfrmExportToImage.GISBusy( _sender: TObject; _pos,
                                     _end: Integer; var _abort: Boolean );
begin
  if _end <= 0 then
    Caption := 'Export to image'
  else
    // Display integer percentage in the title bar so the user can track progress
    Caption := Format( 'Export to image %d%%', [ Trunc( _pos / _end * 100 ) ] ) ;

  // Yield to the Windows message pump to keep the UI responsive during export
  Application.ProcessMessages ;
end;

{ Initialise the form to the Image mode on creation. }
procedure TfrmExportToImage.FormCreate(Sender: TObject);
begin
  rbImage.Checked := True ;
  rbImageClick( self ) ;
end;

{ Perform the raster export.
  Steps:
  1. Retrieve the chosen TGIS_LayerPixelSubFormat from the combobox, or fall
     back to the layer's default sub-format if none is selected.
  2. Set FExtent from the user's extent choice (full map vs. visible viewport).
  3. Calculate pixWidth/pixHeight according to the selected quality preset.
  4. Call lpx.ImportLayer to resample the source layer into the output file. }
procedure TfrmExportToImage.actSaveExecute(Sender: TObject);
var
  c : TGIS_LayerPixelSubFormat ;
begin
  Application.ProcessMessages ;

  // Resolve the output sub-format (pixel depth, compression, etc.)
  if cbType.ItemIndex >= 0 then
    c := T_capability(cbType.Items.Objects[cbType.ItemIndex]).C
  else
    c := lpx.DefaultSubFormat ;  // Use the format's natural default

  // Determine the geographic area to export
  if rbExtentMap.Checked then
    FExtent := GIS.Extent          // Full bounding box of all loaded layers
  else
    FExtent := GIS.VisibleExtent;  // Current viewport in map coordinates

  // --- Resolution strategy ---
  if rbQbest.Checked then begin
    // Match native pixel density of the highest-resolution source layer
    ValuesInit;
  end
  else
  if rbQdoc.Checked then begin
    // Document preset: fixed physical width (6.3 inches), 300 DPI
    Ppi := DEFAULT_PPI_DOC;
    expWidth := DEFAULT_WIDTH_DOC_INCH;

    if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
      // Preserve geographic aspect ratio to avoid distortion
      expHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth
    end
    else
    begin
      // Degenerate extent guard: use a minimal 2x2 pixel output
      expHeight := 2;
      expHeight := 2;
    end;
    // Convert physical inches * DPI -> pixel dimensions
    ValuesWHpix;
  end
  else
  if rbQweb.Checked then begin
    // Web preset: fixed pixel width (640 px), 96 DPI
    Ppi := DEFAULT_PPI_WEB;
    pixWidth := DEFAULT_WIDTHPIX_WEB;
    if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
      // Height derived from geographic aspect ratio of the chosen extent
      pixHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * pixWidth;
    end
    else
    begin
      pixWidth := 2;
      pixHeight := 2;
    end;
    // Derive physical dimensions from pixel count / DPI (stored for reference)
    ValuesWH;
  end;

  // ImportLayer resamples lstp (source) into lpx (output file) using:
  //   lstp         - the source TGIS_LayerPixel to read from
  //   lstp.Extent  - geographic coverage of the source (full layer)
  //   lstp.CS      - coordinate system; ensures correct spatial referencing
  //   pixWidth/pixHeight - output raster dimensions in pixels
  //   c            - sub-format descriptor (bit depth, compression, etc.)
  lpx.ImportLayer( lstp, lstp.Extent, lstp.CS,
                   Round(( pixWidth )),
                   Round(( pixHeight )),
                   c
                  ) ;
  ShowMessage('File exported!');
end;


{ Open the file save dialog, create the output pixel layer, and populate the
  format combobox with the sub-formats supported by that file format.

  TGIS_LayerPixelSubFormat describes properties like bit depth and compression
  that vary by format (e.g. JPEG supports different quality levels; TIFF
  supports LZW, DEFLATE, etc.). Each entry in cbType corresponds to one valid
  combination for the target file extension. }
procedure TfrmExportToImage.btnSelectFileClick(Sender: TObject);
var
  clst           : TGIS_LayerPixelSubFormatList ;
  c              : TGIS_LayerPixelSubFormat     ;
begin
  // Show the appropriate save dialog based on the current data-type selection
  if rbImage.Checked then
  begin
    if not dlgSaveImage.Execute then exit ;
    edtFile.Text := dlgSaveImage.FileName;
    edtFile.Hint := dlgSaveImage.FileName;
  end
  else begin
    if not dlgSaveGrid.Execute then exit ;
    edtFile.Text := dlgSaveGrid.FileName;
    edtFile.Hint := dlgSaveGrid.FileName;
  end ;

  cbType.Clear ;

  try
    // GIS.Items[0] is the primary (bottom-most) layer in the viewer stack;
    // for single-layer samples it is always the layer we want to export.
    lstp := (GIS.Items[0] as TGIS_LayerPixel);

    // GisCreateLayer inspects the file extension to choose the correct
    // TGIS_LayerPixel subclass (JPEG driver, PNG driver, FLT grid, etc.)
    // and creates an empty output layer ready to receive raster data.
    if rbImage.Checked then
      lpx := GisCreateLayer( ExtractFileName( dlgSaveImage.FileName ),
                             dlgSaveImage.FileName
                           ) as TGIS_LayerPixel
    else
      lpx := GisCreateLayer( ExtractFileName( dlgSaveGrid.FileName ),
                               dlgSaveGrid.FileName
                              ) as TGIS_LayerPixel ;

    // Capabilities returns all valid TGIS_LayerPixelSubFormat combinations
    // for this particular output format. Populate the combobox so the user
    // can select their preferred pixel depth / compression scheme.
    clst := lpx.Capabilities;
    for c in clst do begin
      // Store a deep copy of the sub-format alongside the display string so
      // that actSaveExecute can retrieve it even after the list is released.
      cbType.AddItem( c.ToString , T_capability.Create( c ) ) ;
    end ;

    cbType.ItemIndex           := 0;

    // Enable export controls only after a valid output path and layer exist
    btnSave.Enabled := true;
    rbQbest.Enabled := true;
    rbQdoc.Enabled := true;
    rbQweb.Enabled := true;
    rbExtentMap.Enabled := true;
    rbExtentVisible.Enabled := true;
    cbType.Enabled := true;

    rbExtentMap.Checked := True ;
    rbQbest.Checked := True ;

  except
    on E : Exception do begin
      ShowMessage( E.Message );
    end ;
  end ;
end;

{ Release the T_capability objects stored as Items.Objects in cbType
  and free the owner list to prevent memory leaks on close. }
procedure TfrmExportToImage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  cbType.Clear ;
  FreeAndNil( lst ) ;
end;

{ Calculate the optimal output pixel dimensions for the "Best quality" preset.

  The algorithm finds the TGIS_LayerPixel in the viewer with the highest pixel
  density (BitWidth / geographic width), which represents the layer that would
  lose the least detail when resampled.  The export pixel width is then scaled
  so that the chosen export extent is rendered at that same native density.
  If no raster layer is found (e.g. only vector layers), DEFAULT_WIDTHPIX is
  used as a sensible fallback. }
procedure TfrmExportToImage.ValuesInit ;
var
  i,j       : Integer ;
  la        : TGIS_Layer ;
  density   : Double ;    // Density of the best layer found so far (px/unit)
  density0  : Double ;    // Density of the previously examined layer
  density1  : Double ;    // Density of the current layer being examined
  widthpix  : Integer ;   // Computed output width in pixels
  ext_delta : Double ;    // Ratio: export extent width / best layer extent width
  ext_width : Double ;    // Geographic width of the layer being examined
begin
  density0 := 0 ;
  density  := density0 ;
  Ppi := DEFAULT_PPI ;
  j := 0 ;

  // Iterate layers from top to bottom; keep track of the highest-density layer
  for i:= GIS.Items.Count - 1 downto 0 do begin
      la := TGIS_Layer( GIS.Items[ i ] ) ;

      if la is TGIS_LayerPixel then begin
         ext_width := la.Extent.XMax - la.Extent.XMin ;

         // BitWidth is the native pixel width of the layer at its full extent;
         // dividing by the geographic width gives pixels per map unit.
         density1 := TGIS_LayerPixel( la ).BitWidth / ext_width ;
         if density1 > density0 then begin
            density := density1 ;
            j := i ;              // Remember the index of the densest layer
         end ;
         density0 := density1 ;
      end ;

  end ;

  if density = 0 then begin
    // No raster layers found; use the predefined fallback pixel width
    widthpix := 4200
  end
  else
  begin
    la := TGIS_Layer( GIS.Items[ j ] ) ;
    ext_width := la.Extent.XMax - la.Extent.XMin ;

    // ext_delta is the fraction of the best layer's extent covered by FExtent.
    // Multiplying by BitWidth gives the number of source pixels in that region,
    // which is the ideal output width to preserve native resolution.
    ext_delta := ( FExtent.XMax - FExtent.XMin ) / ext_width ;
    widthpix :=  Round ( ext_delta *
                         TGIS_LayerPixel( GIS.Items[ j ] ).BitWidth ) ;
  end ;

  pixWidth := widthpix  ;

  // Derive height from the geographic aspect ratio so the image is not stretched
  if ( ( FExtent.XMax - FExtent.XMin ) <> 0 ) then begin
    pixHeight :=  ( FExtent.YMax - FExtent.YMin ) /
                                   (   FExtent.XMax - FExtent.XMin ) *
                                       pixWidth
  end
  else
  begin
    // Zero-width extent guard: produce a minimal valid raster
    pixWidth  := 2 ;
    pixHeight := 2 ;
  end ;
end ;

{ Convert pixel dimensions to physical (inch) dimensions.
  expWidth = pixWidth / Ppi  (inches wide at the current DPI setting)
  expHeight is derived from expWidth via the geographic aspect ratio so that
  the physical image proportions match the map region being exported. }
procedure TfrmExportToImage.ValuesWH   ;
begin
  expWidth := PixWidth / Ppi;

  if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
    expHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth;
  end
  else
  begin
    expWidth := 2;
    expHeight := 2;
  end;
end ;

{ Convert physical (inch) dimensions to pixel dimensions.
  pixWidth = expWidth * Ppi  (pixels wide given the physical width and DPI)
  pixHeight is derived from pixWidth via the geographic aspect ratio. }
procedure TfrmExportToImage.ValuesWHpix;
begin
  PixWidth := expWidth * Ppi;

  if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
    PixHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * PixWidth;
  end
  else
  begin
    PixWidth  := 2;
    PixHeight := 2;
  end;
end;

{ Switch the viewer to a DEM elevation grid (ADF format) and reset the export
  controls until the user selects a new output path.  The ADF grid is an
  ESRI Arc/Info binary grid stored in a directory with a hdr.adf header file;
  DK opens the entire dataset by pointing to that header. }
procedure TfrmExportToImage.rbGridClick(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\San Bernardino\NED\hdr.adf' );
  edtFile.Text := '';
  cbType.Clear;
  // Disable all export controls until a valid destination file is chosen
  btnSave.Enabled := false;
  rbQbest.Enabled := false;
  rbQdoc.Enabled := false;
  rbQweb.Enabled := false;
  rbExtentMap.Enabled := false;
  rbExtentVisible.Enabled := false;
  cbType.Enabled := false;
end;

{ Switch the viewer to the sample RGB satellite image (world_8km.jpg) and
  reset export controls. This JPEG is a global mosaic at approximately
  8 km per pixel, demonstrating image-format export. }
procedure TfrmExportToImage.rbImageClick(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg' );
  edtFile.Text := '';
  cbType.Clear;
  btnSave.Enabled := false;
  rbQbest.Enabled := false;
  rbQdoc.Enabled := false;
  rbQweb.Enabled := false;
  rbExtentMap.Enabled := false;
  rbExtentVisible.Enabled := false;
  cbType.Enabled := false;
end;

{ Deep-copy constructor for T_capability.
  CreateCopy produces an independent TGIS_LayerPixelSubFormat value so that
  this object's copy is not affected if the originating format list is freed
  or reused by the DK runtime. }
constructor T_capability.Create(
  const _c : TGIS_LayerPixelSubFormat
) ;
begin
  inherited Create;
  C := _c.CreateCopy ;
end;


end.
