//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to add layers to the map.
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
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  GisTypes,
  GisEditor,
  GisLayerSHP,
  //GisLicense,
  GisUtils,
  GisTypesUI,
  GisViewer,
  GisAggregator,
  GisLayerVector,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    pMenu: TPanel;
    lblMethod: TLabel;
    cbxMethod: TComboBox;
    lblRadius: TLabel;
    lblThreshhold: TLabel;
    cbxRadius: TComboBox;
    cbxThreshhold: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cbxMethodChange(Sender: TObject);
    procedure cbxRadiusChange(Sender: TObject);
    procedure cbxThreshholdChange(Sender: TObject);
    procedure changeAggregation;
    procedure readDefaultValues;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  GisRegistredLayers ;

procedure TForm1.cbxMethodChange(Sender: TObject);
begin
  readDefaultValues ;
  changeAggregation;
end;

procedure TForm1.cbxRadiusChange(Sender: TObject);
begin
  changeAggregation;
end;

procedure TForm1.cbxThreshholdChange(Sender: TObject);
begin
  changeAggregation;
end;

procedure TForm1.changeAggregation;
var
  dyn_agg_name : String;
  lv : TGIS_LayerVector;
begin
  dyn_agg_name := cbxMethod.Items[cbxMethod.ItemIndex];
  lv := GIS.Get('cities') as TGIS_LayerVector ;
  lv.Transparency := 70;

  if dyn_agg_name.Equals('Off') then begin
    cbxThreshhold.Enabled := False ;
    cbxRadius.Enabled := False ;
    lv.DynamicAggregator := nil ;
  end else begin
    cbxThreshhold.Enabled := True ;
    cbxRadius.Enabled := True ;
    lv.DynamicAggregator := TGIS_DynamicAggregatorFactory.CreateInstance( dyn_agg_name, lv ) ;
    lv.DynamicAggregator.Threshold := StrToInt( cbxThreshhold.Items[cbxThreshhold.ItemIndex] ) ;
    lv.DynamicAggregator.RadiusAsText := 'SIZE: ' + cbxRadius.Items[cbxRadius.ItemIndex];
  end;

  GIS.InvalidateWholeMap;
end;

procedure TForm1.readDefaultValues;
begin
  if cbxMethod.Items[cbxMethod.ItemIndex].Equals('ShapeReduction') then
    cbxRadius.ItemIndex := 0
  else
    cbxRadius.ItemIndex := 3 ;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '/Samples/Aggregation/Aggregation.ttkproject');
  cbxMethod.Items.Add('Off');
  cbxMethod.Items.AddStrings(TGIS_DynamicAggregatorFactory.Names);
  cbxMethod.ItemIndex := 0 ;
  cbxRadius.ItemIndex := 3 ;
  cbxThreshhold.ItemIndex := 1;
  cbxRadius.Enabled := False ;
  cbxThreshhold.Enabled := False ;
end;

end.
