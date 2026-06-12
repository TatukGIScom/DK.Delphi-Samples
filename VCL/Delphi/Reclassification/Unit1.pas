{
  Reclassification Sample — Demonstrates pixel value reclassification and
  statistical classification methods for raster layers.

  Key concepts illustrated:
    - Reclassification: mapping input pixel value ranges to new output values
      using a lookup table (if value is between X and Y, output Z)
    - Automatic classification methods:
      * Unique: one color per unique pixel value
      * Natural Breaks (Jenks algorithm): optimal grouping into classes
    - NODATA value handling: optionally treat undefined/missing values
    - Color ramp selection for classified visualization
    - Building new output raster layers from classification results
    - Progress tracking during reclassification computation

  User workflow:
    1. Choose data source:
       - "Use Reclassification Table" (land cover classification)
       - "Use Altitude Zones" (DEM elevation classification)
    2. For table method: enter value ranges and output values
       Example: pixels 1-5 → output 100, pixels 6-10 → output 200
    3. Click "Reclassify" to generate the new classified raster
    4. Optional: enable NODATA checkbox to treat missing values separately

  Data sources:
    - Corine Land Cover 2018 (Luxembourg) - TIFF raster
    - Digital Elevation Model (DEM) - grid file with elevation values

  API classes used:
    - TGIS_Reclassification: engine that remaps pixel values
    - TGIS_ClassificationPixel: performs Unique/NaturalBreaks classification
    - TGIS_LayerPixel: raster layer for inputs and outputs
}
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, VCL.GisViewerWnd,
  Vcl.StdCtrls, VCL.GisControlLegend, Vcl.ComCtrls,
  GisLayerPixel;

type
  TfrmReclassification = class(TForm)
    GIS: TGIS_ViewerWnd;
    GISLegend: TGIS_ControlLegend;
    progress: TProgressBar;
    grpbReclassification: TGroupBox;
    sgrdReclassTable: TStringGrid;
    chkNodata: TCheckBox;
    lblNoData: TLabel;
    btnReclassify: TButton;
    btnUseTable: TButton;
    btnUseAltitudeZones: TButton;
    lblReclassTable: TLabel;
    lblAltitudeZones: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnReclassifyClick(Sender: TObject);
    procedure chkNodataClick(Sender: TObject);
    procedure btnUseTableClick(Sender: TObject);
    procedure btnUseAltitudeZonesClick(Sender: TObject);
  private
    useAltitudeMapZones: Boolean;
    procedure doBusyEvent(_sender: TObject; _pos, _end: Integer; var _abort  : Boolean);
    procedure ApplyUniqueStyle(const _lp: TGIS_LayerPixel; const _colorRampName: string);
    procedure ApplyNaturalBreaksStyle(const _lp: TGIS_LayerPixel; const _colorRampName: string);
    procedure OpenSampleForReclassTable;
    procedure OpenSampleForUseAltitudeZones;
  end;

var
  frmReclassification: TfrmReclassification;

implementation

{$R *.dfm}

uses
  System.Generics.Collections,
  System.IOUtils,
  System.Math,
  System.StrUtils,

  //GisLicense,
  GisClasses,
  GisLayerVector,
  GisVectorization,
  GisFunctions,
  GisClassification,
  GisRtl,
  GisTypes,
  GisTypesUI,
  GisUtils;

{
  chkNodataClick
  Updates the label to show NODATA handling behavior when checkbox changes.
  NODATA: undefined/missing pixel values that fall outside classification ranges.
}
procedure TfrmReclassification.chkNodataClick(Sender: TObject);
begin
  { Show different message based on NODATA handling mode }
  if chkNodata.Checked then
    { NODATA mode: undefined pixels are filled with NODATA marker }
    lblNoData.Caption := 'Cell values outside the defined ranges will be filled with NODATA value.'
  else
    { Original mode: undefined pixels keep their original value }
    lblNoData.Caption := 'Cell values outside the defined ranges will be filled with original value.'
end;

procedure TfrmReclassification.doBusyEvent(
        _sender : TObject ;
        _pos    : Integer ;
        _end    : Integer ;
  var   _abort  : Boolean
) ;
begin
  case _pos of
    0: begin
      progress.Min := 0;
      progress.Max := 100;
      progress.Position := 0;
    end;
    -1: progress.Position := 0;
    else progress.Position := _pos;
  end;

  Application.ProcessMessages;
end;

{
  OpenSampleForUseAltitudeZones
  Loads the DEM (elevation grid) and applies Natural Breaks classification.
  Creates altitude zones that group elevation values into optimal elevation bands.
}
procedure TfrmReclassification.OpenSampleForUseAltitudeZones;
var lp : TGIS_LayerPixel;
begin
  { Set mode flag to indicate altitude zone classification (not table-based) }
  useAltitudeMapZones := True;

  GIS.Lock;
  try
    { Load the Digital Elevation Model (elevation.grd) - a grid of terrain heights }
    GIS.Open(TPath.Combine(
      TGIS_Utils.GisSamplesDataDirDownload,
      'Samples\3D\elevation.grd'
    ));

    { Apply Natural Breaks (Jenks) classification for optimal elevation grouping.
      This algorithm identifies natural groupings in the data and creates classes
      that minimize within-class variance. Each class represents an altitude zone. }
    lp := TGIS_LayerPixel(GIS.Items[0]);
    ApplyNaturalBreaksStyle(lp, 'Geology');

  finally
    GIS.Unlock;
  end;
end;

{
  OpenSampleForReclassTable
  Loads the Corine Land Cover raster and applies Unique classification.
  Sets up the sample for user-defined reclassification using the lookup table.
}
procedure TfrmReclassification.OpenSampleForReclassTable;
var lp : TGIS_LayerPixel;
begin
  { Set mode flag to indicate table-based reclassification (not altitude zones) }
  useAltitudeMapZones := False;

  GIS.Lock;
  try
    { Load the Corine Land Cover 2018 raster for Luxembourg (TIFF format) }
    GIS.Open(TPath.Combine(
      TGIS_Utils.GisSamplesDataDirDownload,
      'World\Countries\Luxembourg\CLC2018_CLC2018_V2018_20_Luxembourg.tif'
    ));

    { Apply Unique classification: one color per unique land cover class }
    lp := TGIS_LayerPixel(GIS.Items[0]);
    ApplyUniqueStyle(lp, 'UniquePastel');

  finally
    GIS.Unlock;
  end;
end;

procedure TfrmReclassification.ApplyUniqueStyle(const _lp: TGIS_LayerPixel; const _colorRampName: string);
var classifier : TGIS_ClassificationPixel;
begin
  classifier := TGIS_ClassificationPixel.Create(_lp);
  try
    classifier.Method := TGIS_ClassificationMethod.Unique;
    classifier.ColorRampName := _colorRampName ;

    classifier.Classify;
  finally
    classifier.Free;
  end;
end;

procedure TfrmReclassification.ApplyNaturalBreaksStyle(const _lp: TGIS_LayerPixel; const _colorRampName: string);
var classifier : TGIS_ClassificationPixel;
begin
  classifier := TGIS_ClassificationPixel.Create(_lp);
  try
    classifier.Method := TGIS_ClassificationMethod.NaturalBreaks;
    classifier.ColorRampName := _colorRampName;

    classifier.Classify;
  finally
    classifier.Free;
  end;
end;

{
  btnReclassifyClick
  Performs the reclassification operation based on lookup table entries.
  Reads value ranges and mappings from the grid, creates a new reclassified raster,
  and displays it in the viewer.

  Algorithm:
    1. Get the source raster layer
    2. Read reclassification rules from the grid:
       - Single value to single value: exact matches
       - Range to value: all pixels within min-max get new value
       - NODATA handling: special values for undefined pixels
    3. Create output raster with same extent/resolution as input
    4. Apply TGIS_Reclassification engine to generate new pixel values
    5. Apply color styling and add result to viewer
}
procedure TfrmReclassification.btnReclassifyClick(Sender: TObject);
var
  lp, lp_reclass                    : TGIS_LayerPixel;
  name                              : string;
  reclassifier                      : TGIS_Reclassification;
  startValStr, endValStr, newValStr : string;
  startVal, endVal, newVal          : Single;
  startExist, endExist, newExist    : Boolean;
  row                               : Integer;
begin
  { Get the source raster layer from the viewer }
  lp := TGIS_LayerPixel(GIS.Items[0]);

  { Remove any previously created reclassification result }
  name := lp.Name + ' (reclass)';
  if GIS.Get(name) <> nil then
    GIS.Delete(name) ;

  { Create the output raster with same properties as the source }
  lp_reclass := TGIS_LayerPixel.Create;
  lp_reclass.Name := name;
  lp_reclass.Build(True, lp.CS, lp.Extent, lp.BitWidth, lp.BitHeight);

  { Create the reclassification engine }
  reclassifier := TGIS_Reclassification.Create;
  try
    { Hook progress tracking to update progress bar }
    reclassifier.BusyEvent := doBusyEvent;

    { Read reclassification rules from the lookup table grid }
    for row := 1 to sgrdReclassTable.RowCount-1 do begin
      { Read the three columns: start value, end value, new value }
      startValStr := sgrdReclassTable.Cells[0, row];
      endValStr := sgrdReclassTable.Cells[1, row];
      newValStr := sgrdReclassTable.Cells[2, row];

      { Skip empty rows }
      if startValStr.IsEmpty then
        Continue;

      { Try to parse numeric values from the grid cells }
      startExist := TryStrToFloat(startValStr, startVal);
      endExist := TryStrToFloat(endValStr, endVal);
      newExist := TryStrToFloat(newValStr, newVal);

      { Handle special NODATA mapping: if start value is "nd" or "nodata", assign new value }
      if MatchText(startValStr, ['nd', 'nodata', 'no-data']) and newExist then
        reclassifier.ReclassNoDataValue := newVal

      { Single value reclassification: if end value is empty or equals start value }
      else if endValStr.IsEmpty or SameValue(startVal, endVal) and startExist and newExist then
        reclassifier.AddReclassValue(startVal, newVal)

      { Range reclassification: map all values between start and end to new value }
      else if startExist and endExist and newExist then
        reclassifier.AddReclassRange(startVal, endVal, newVal);
    end;

    { Configure NODATA handling for pixels outside defined ranges }
    reclassifier.UseNoDataForMissingValues := chkNodata.Checked;

    { Execute the reclassification algorithm on the source raster }
    reclassifier.Generate(lp, lp.Extent, lp_reclass, useAltitudeMapZones);
  finally
    FreeObject(reclassifier);
  end;

  { Apply Unique color classification to the result (if not using altitude zones) }
  if not useAltitudeMapZones then
    applyUniqueStyle(lp_reclass, 'UniqueDeep');

  { Configure display parameters: no shadows or antialiasing for crisp class boundaries }
  lp_reclass.Params.Pixel.GridShadow := False ;
  lp_reclass.Params.Pixel.Antialias := False ;

  { Add the reclassified result layer to the viewer }
  GIS.Add(lp_reclass);

  { Redraw the map to display the new result }
  GIS.InvalidateWholeMap;
end;

{
  btnUseAltitudeZonesClick
  Switches to the "Altitude Zones" mode: loads a DEM and applies
  Natural Breaks (Jenks) classification based on elevation ranges.
}
procedure TfrmReclassification.btnUseAltitudeZonesClick(Sender: TObject);
begin
  { Hide the reclassification table UI and show altitude zones instead }
  {$IF CompilerVersion >= 35.0}
  grpbReclassification.LockDrawing;
  try
  {$ENDIF}
    lblReclassTable.Visible := False;
    sgrdReclassTable.Visible := False;
    lblAltitudeZones.Visible := True;
  {$IF CompilerVersion >= 35.0}
  finally
    grpbReclassification.UnlockDrawing;
  end;
  {$ENDIF}

  { Load and classify the DEM sample data by elevation ranges }
  OpenSampleForUseAltitudeZones;
end;

{
  btnUseTableClick
  Switches to the "Reclassification Table" mode: loads a land cover raster
  and allows user-defined reclassification using the lookup table grid.
}
procedure TfrmReclassification.btnUseTableClick(Sender: TObject);
begin
  {$IF CompilerVersion >= 35.0}
  grpbReclassification.LockDrawing;
  try
  {$ENDIF}
    lblAltitudeZones.Visible := False;
    sgrdReclassTable.Visible := True;
    lblReclassTable.Visible := True;
  {$IF CompilerVersion >= 35.0}
  finally
    grpbReclassification.UnlockDrawing;
  end;
  {$ENDIF}

  OpenSampleForReclassTable;
end;

procedure TfrmReclassification.FormShow(Sender: TObject);
var i : Integer;
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;

  // Set header
  sgrdReclassTable.Cells[0, 0] := 'Start';
  sgrdReclassTable.Cells[1, 0] := 'End';
  sgrdReclassTable.Cells[2, 0] := ' New';

  // Set reclass table
  for i := 1 to 4 do begin
    sgrdReclassTable.Cells[0, i] := (100*i).ToString;
    sgrdReclassTable.Cells[1, i] := (100*(i+1)).ToString;
    sgrdReclassTable.Cells[2, i] := i.ToString;
  end;

  sgrdReclassTable.Cells[0, 5] := '311';
  sgrdReclassTable.Cells[1, 5] := '';
  sgrdReclassTable.Cells[2, 5] := '6';

  sgrdReclassTable.Cells[0, 6] := 'nodata';
  sgrdReclassTable.Cells[1, 6] := '';
  sgrdReclassTable.Cells[2, 6] := '999';

  // open image to reclassify
  OpenSampleForReclassTable;
end;

end.
