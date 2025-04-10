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

procedure TfrmReclassification.chkNodataClick(Sender: TObject);
begin
  if chkNodata.Checked then
    lblNoData.Caption := 'Cell values outside the defined ranges will be filled with NODATA value.'
  else
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

procedure TfrmReclassification.OpenSampleForUseAltitudeZones;
var lp : TGIS_LayerPixel;
begin
  // this variable will be used in "TGIS_Reclassification.Generate" method
  useAltitudeMapZones := True;

  GIS.Lock;
  try
    GIS.Open(TPath.Combine(
      TGIS_Utils.GisSamplesDataDirDownload,
      'Samples\3D\elevation.grd'
    ));

    // generate altitude map zones
    lp := TGIS_LayerPixel(GIS.Items[0]);
    ApplyNaturalBreaksStyle(lp, 'Geology');

  finally
    GIS.Unlock;
  end;
end;

procedure TfrmReclassification.OpenSampleForReclassTable;
var lp : TGIS_LayerPixel;
begin
  useAltitudeMapZones := False;

  GIS.Lock;
  try
    GIS.Open(TPath.Combine(
      TGIS_Utils.GisSamplesDataDirDownload,
      'World\Countries\Luxembourg\CLC2018_CLC2018_V2018_20_Luxembourg.tif'
    ));

    // apply Unique style classification
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
  lp := TGIS_LayerPixel(GIS.Items[0]);

  // Remove a layer from GIS if exist
  name := lp.Name + ' (reclass)';
  if GIS.Get(name) <> nil then
    GIS.Delete(name) ;

  // Prepare the destination layer
  lp_reclass := TGIS_LayerPixel.Create;
  lp_reclass.Name := name;
  lp_reclass.Build(True, lp.CS, lp.Extent, lp.BitWidth, lp.BitHeight);

  reclassifier := TGIS_Reclassification.Create;
  try
    reclassifier.BusyEvent := doBusyEvent;

    // Collect reclass definitions
    for row := 1 to sgrdReclassTable.RowCount-1 do begin
      startValStr := sgrdReclassTable.Cells[0, row];
      endValStr := sgrdReclassTable.Cells[1, row];
      newValStr := sgrdReclassTable.Cells[2, row];

      if startValStr.IsEmpty then
        Continue;

      startExist := TryStrToFloat(startValStr, startVal);
      endExist := TryStrToFloat(endValStr, endVal);
      newExist := TryStrToFloat(newValStr, newVal);

      // Assign a new value for the existing nodata
      if MatchText(startValStr, ['nd', 'nodata', 'no-data']) and newExist then
        reclassifier.ReclassNoDataValue := newVal

      // Simple value-to-value reclassification
      else if endValStr.IsEmpty or SameValue(startVal, endVal) and startExist and newExist then
        reclassifier.AddReclassValue(startVal, newVal)

      // Assgin a new value for a value within the range
      else if startExist and endExist and newExist then
        reclassifier.AddReclassRange(startVal, endVal, newVal);
    end;

    // Assign NoData for unclassified cells if True, or leave existing values if False
    reclassifier.UseNoDataForMissingValues := chkNodata.Checked;

    // Run the reclassification tool
    reclassifier.Generate(lp, lp.Extent, lp_reclass, useAltitudeMapZones);
  finally
    FreeObject(reclassifier);
  end;

  if not useAltitudeMapZones then
    applyUniqueStyle(lp_reclass, 'UniqueDeep');

  lp_reclass.Params.Pixel.GridShadow := False ;
  lp_reclass.Params.Pixel.Antialias := False ;

  GIS.Add(lp_reclass);
  GIS.InvalidateWholeMap;
end;

procedure TfrmReclassification.btnUseAltitudeZonesClick(Sender: TObject);
begin
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

  OpenSampleForUseAltitudeZones;
end;

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
