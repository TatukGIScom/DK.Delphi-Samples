// =============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
// =============================================================================
{
  How to prepare small coverage previewer.
  Search form.
}
unit SearchForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  GisTypes,
  GisClasses,
  GisLayer;

type
  TFSearch = class(TForm)
    cbLayer: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    cbField: TComboBox;
    eValue: TEdit;
    btnSearch: TSpeedButton;
    Label3: TLabel;
    cbOperation: TComboBox;
    Label4: TLabel;
    rgExtent: TRadioGroup;
    stsBar: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cbLayerChange(Sender: TObject);
    procedure eValueKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSearch: TFSearch;

implementation

uses
  MainForm,
  GisLayerVector,
  GisLayerPixel,
  GisUtils,
  GisViewer;

{$R *.DFM}

procedure TFSearch.FormShow(Sender: TObject);
var
  i, j: Integer;
  ll: TGIS_Layer;
  lv: TGIS_LayerVector;
begin
  If frmMain.GIS.IsEmpty then
    exit;
  cbLayer.Items.Clear;
  cbField.Items.Clear;
  btnSearch.Enabled := false;
  cbOperation.ItemIndex := 0;

  // find all layers and make a list
  for i := 0 to frmMain.GIS.Items.Count - 1 do
  begin
    ll := TGIS_LayerVector(frmMain.GIS.Items[i]);
    if ll is TGIS_LayerVector then
      cbLayer.Items.Add(ll.Name);
  end;

  if cbLayer.Items.Count > 0 then
  begin
    cbLayer.ItemIndex := 0;

    // for first layer get fields names
    lv := TGIS_LayerVector(frmMain.GIS.Items[cbLayer.ItemIndex]);
    for j := 0 to lv.Fields.Count - 1 do
    begin
      if lv.FieldInfo(j).Deleted then
        continue;
      cbField.Items.Add(lv.FieldInfo(j).Name);
    end;

    cbField.ItemIndex := 0;
    btnSearch.Enabled := True;
    stsBar.Panels[1].Text := cbLayer.Items[cbLayer.ItemIndex];
  end
  else
  begin
    stsBar.Panels[1].Text := 'There is no vector layer in the Viewer';
  end;
end;

procedure TFSearch.btnSearchClick(Sender: TObject);
var
  shp: TGIS_Shape;
  ll: TGIS_LayerVector;
  ex: TGIS_Extent;
  sql: String;
  fld: TGIS_FieldInfo;
begin
  // get selected layer
  ll := TGIS_LayerVector(frmMain.GIS.Items[cbLayer.ItemIndex]);

  // check if assigned, has proper type and searching value is not empty
  if (not Assigned(ll)) or (TGIS_Layer(ll) is TGIS_LayerPixel) or
    (eValue.Text = '') then
    exit;

  // check the extent
  if rgExtent.ItemIndex = 0 then
    ex := frmMain.GIS.VisibleExtent
  else
    ex := TGIS_Utils.GisWholeWorld;

  // calculate the condition similar to SQL where clause
  fld := ll.FieldInfo(ll.FindField(cbField.Items[cbField.ItemIndex]));
  if fld = nil then
    exit;
  if fld.FieldType = TGIS_FieldType.String then
  begin
    sql := cbField.Items[cbField.ItemIndex] + cbOperation.Items
      [cbOperation.ItemIndex] + QuotedStr(eValue.Text)
  end
  else
  begin
    sql := cbField.Items[cbField.ItemIndex] + cbOperation.Items
      [cbOperation.ItemIndex] + eValue.Text;
  end;
  // let's find any shapes meeting the criteria and flash them
  shp := ll.FindFirst(ex, sql);
  while Assigned(shp) do
  begin
    shp.Flash;
    Application.ProcessMessages;
    shp := ll.FindNext;
  end;

  frmMain.GIS.InvalidateWholeMap;
end;

procedure TFSearch.FormHide(Sender: TObject);
begin
  frmMain.GIS.RevertAll;
  frmMain.GIS.FullExtent;
end;

procedure TFSearch.cbLayerChange(Sender: TObject);
var
  j: Integer;
  name: String;
  lv: TGIS_LayerVector;
begin
  // if layer changed, reload fields names
  cbField.Items.Clear;

  name := cbLayer.Items[cbLayer.ItemIndex];
  lv := TGIS_LayerVector(frmMain.GIS.Get(name));

  for j := 0 to lv.Fields.Count - 1 do
  begin
    if lv.FieldInfo(j).Deleted then
      continue;
    cbField.Items.Add(lv.FieldInfo(j).NewName);
  end;

  if cbField.Items.Count > 0 then
    cbField.ItemIndex := 0;
  stsBar.Panels[1].Text := name;
end;

procedure TFSearch.eValueKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btnSearchClick(self);
end;

end.
