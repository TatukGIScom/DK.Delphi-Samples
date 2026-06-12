//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  DynamicAggregation sample — demonstrates TGIS_DynamicAggregatorFactory for real-time point
  clustering on a GIS layer.

  Loads a TatukGIS project (Aggregation.ttkproject) containing a "cities" point layer.  A left
  panel offers three controls: Aggregation method (Off or a factory-registered name), Radius, and
  Threshold.  Changing any control calls changeAggregation which installs or removes the selected
  TGIS_DynamicAggregator on the layer via TGIS_DynamicAggregatorFactory.CreateInstance.
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

{ Resets the default radius for the chosen method, then applies the new aggregator. }
procedure TForm1.cbxMethodChange(Sender: TObject);
begin
  readDefaultValues ;
  changeAggregation;
end;

{ Re-applies the aggregator with the newly selected radius. }
procedure TForm1.cbxRadiusChange(Sender: TObject);
begin
  changeAggregation;
end;

{ Re-applies the aggregator with the newly selected threshold. }
procedure TForm1.cbxThreshholdChange(Sender: TObject);
begin
  changeAggregation;
end;

{ Installs or removes the selected TGIS_DynamicAggregator on the "cities" layer,
  applies the current Radius and Threshold, and redraws the map. }
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

{ Sets a sensible default radius when the method changes: index 0 (5 pt) for ShapeReduction,
  index 3 (40 pt) for all other methods. }
procedure TForm1.readDefaultValues;
begin
  if cbxMethod.Items[cbxMethod.ItemIndex].Equals('ShapeReduction') then
    cbxRadius.ItemIndex := 0
  else
    cbxRadius.ItemIndex := 3 ;

end;

{ Opens the project, populates the method combo with all registered aggregator names, and
  sets initial selections with Radius and Threshold disabled. }
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
