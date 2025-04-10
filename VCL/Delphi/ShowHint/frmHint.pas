//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  Hints properties window
}
unit frmHint;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  GisLayer ;

type
  TfrmHints = class(TForm)
    gbSelectData: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    chkShow: TCheckBox;
    cbLayers: TComboBox;
    lbFields: TListBox;
    paColor: TPanel;
    lbColor: TLabel;
    dlgColor: TColorDialog;
    procedure FormShow(Sender: TObject);
    procedure paColorClick(Sender: TObject);
    procedure cbLayersChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHints: TfrmHints;

implementation

uses
  Unit1, GisViewer, GisLayerVector, GisLayerPixel, GisUtils;

{$R *.DFM}


procedure TfrmHints.FormShow(Sender: TObject);
var
  i   : Integer;
  ll  : TGIS_Layer ;
begin
  chkShow.Checked := frmMain.hintDisplay;
  paColor.Color   := frmMain.hintColor;

  cbLayers.Items.Clear;

  // get layers fom map
  for i:=0 to frmMain.GIS.Items.Count-1 do begin
    ll := TGIS_Layer(frmMain.GIS.Items[i]) ;
    if ll is TGIS_LayerVector then cbLayers.Items.Add(ll.Name);
  end;
  if cbLayers.Items.Count <= 0 then exit;
  cbLayers.ItemIndex:=0;
  cbLayersChange(self);
end;

procedure TfrmHints.paColorClick(Sender: TObject);
begin
  if not dlgColor.Execute then exit;

  paColor.Color := dlgColor.Color;
end;

procedure TfrmHints.cbLayersChange(Sender: TObject);
var
  j   : Integer;
  lv  : TGIS_LayerVector ;
begin
  lbFields.Items.Clear;

  //get fields for selected layer
  lv := TGIS_LayerVector( frmMain.GIS.Items[cbLayers.ItemIndex] );
  for j:=0 to lv.Fields.Count - 1 do
  begin
    if lv.FieldInfo(j).Deleted then continue;
    lbFields.Items.Add( lv.FieldInfo(j).NewName );
  end;

  for j:=0 to lbFields.Items.Count - 1 do
  begin
    if AnsiCompareText( lbFields.Items[j], frmMain.hintField) = 0 then
      lbFields.ItemIndex := j;
  end;

  if lbFields.ItemIndex < 0 then lbFields.ItemIndex := 0;
end;

end.
