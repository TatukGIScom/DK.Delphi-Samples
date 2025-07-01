//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide WMTS Layer support.
}
unit formWMTS;

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
  Vcl.Tabs,
  Vcl.ComCtrls,
  Vcl.Menus,

  GisFunctions,
  GisTypes,
  GisClasses;


type
  TfrmWMTS = class(TForm)
    lbl5: TLabel;
    cbLayers: TComboBox;
    btn19: TButton;
    lbl4: TLabel;
    cbServers: TComboBox;
    btn18: TButton;
    cbInvertAxis: TCheckBox;
    procedure btn18Click(Sender: TObject);
    procedure btn19Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    tkn   : TGIS_Tokenizer ;
  public
    { Public declarations }
  end;

var
  frmWMTS: TfrmWMTS;

implementation

uses
  Winapi.ShellApi,

  formMain,

  GisLayerWMTS,
  GisCsSystems,
  GisCsFactory,
  GisResource,
  GisRtl;

{$R *.dfm}

procedure TfrmWMTS.btn18Click(Sender: TObject);
var
  wmts : TGIS_LayerWMTS ;
  lst  : TGIS_LayerInfoList ;
  li   : TGIS_LayerInfo ;
begin
  wmts := TGIS_LayerWMTS.Create ;
  try
    wmts.Path := cbServers.Text ;
    try
      lst := nil ;
      lst := wmts.GetAvailableLayers ;
      cbLayers.Items.Clear ;
      for li in lst do
        cbLayers.Items.Add( li.Name ) ;
      if cbLayers.Items.Count > 0 then
        cbLayers.ItemIndex := 0 ;
    finally
      FreeObject( lst ) ;
    end;
  finally
    wmts.Free ;
  end;
end;

procedure TfrmWMTS.btn19Click(Sender: TObject);
var
  wmts  : TGIS_LayerWMTS ;
  layer : TGIS_Strings ; //TArray<String> ;
  str   : String ;
begin
  wmts := TGIS_LayerWMTS.Create ;
  tkn  := TGIS_Tokenizer.Create ;
  try
    str := cbLayers.Text ;
    tkn.Execute(str, [';']) ;
    layer := tkn.Result ;
    wmts.Path := '[TatukGIS Layer]\n' +
                  'Storage=WMTS\n' +
                  'Layer=' + layer[0] + '\n' +
                  'Url='+cbServers.Text+'\n' +
                  'TileMatrixSet='+layer[2]+'\n' +
                  'ImageFormat='+layer[1]+'\n' +
                  'InvertAxis='+BoolToStr(cbInvertAxis.Checked, True)+'\n' ;

    frmMain.GIS.Add( wmts ) ;
    if frmMain.GIS.Items.Count = 1 then
      frmMain.GIS.FullExtent
    else
      frmMain.GIS.InvalidateWholeMap ;
  except
    wmts.Free ;
  end;

end;

procedure TfrmWMTS.FormDestroy(Sender: TObject);
begin
  tkn.Free ;
end;

end.
