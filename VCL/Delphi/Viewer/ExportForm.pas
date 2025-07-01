//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to prepare small coverage previewer.
  Export window.
}
unit ExportForm;

interface

uses
  System.Classes,

  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,

  GisCsSystems;

type
  TfrmExportLayer = class(TForm)
    grpSelectExtent: TRadioGroup;
    cmbLayersList: TComboBox;
    cmbShapeType: TComboBox;
    btnCancel: TButton;
    btnOK: TButton;
    lblTitle: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtQuery: TEdit;
    btnCS: TButton;
    edCS: TEdit;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnCSClick(Sender: TObject);
    procedure cmbLayersListChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    cs : TGIS_CSCoordinateSystem ;
  end;

var
  frmExportLayer: TfrmExportLayer;

implementation

uses
  MainForm,
  GisTypes,
  GisLayer,
  GisLayerVector,
  GisUtils,
  GisViewer,

  Vcl.GisControlCsSystem;

{$R *.DFM}


procedure TfrmExportLayer.btnCSClick(Sender: TObject);
var
  dlg : TGIS_ControlCSSystem ;
  he  : TGIS_HelpEvent ;
begin
  dlg := TGIS_ControlCSSystem.Create( Self );
  try
    he := nil ;
    if dlg.Execute( cs, he ) = mrOk then
    begin
      cs := dlg.CS ;
      edCS.Text := cs.WKT ;
    end ;
  finally
    dlg.Free ;
  end;
end;

procedure TfrmExportLayer.cmbLayersListChange(Sender: TObject);
begin
 CS := TGIS_Layer( frmMain.GIS.Get( cmbLayersList.Text ) ).CS ;
 edCS.Text := cs.WKT ;
end;

procedure TfrmExportLayer.FormShow(Sender: TObject);
var
  i : Integer ;
  ll : TGIS_Layer ;
begin
  cmbLayersList.Items.Clear ;
  // add all layers of TGIS_LayerVector type to the list
  for i:= frmMain.GIS.Items.Count - 1 downto 0 do
  begin
    ll := TGIS_Layer( frmMain.GIS.Items[i] ) ;

    // only vectors
    if ll is TGIS_LayerVector then
      cmbLayersList.Items.Add( ll.Name ) ;
  end ;

  cmbLayersList.ItemIndex   := 0 ;
  cmbShapeType.ItemIndex    := 0 ;
  grpSelectExtent.ItemIndex := 0 ;

  if Assigned( TGIS_Layer( frmMain.GIS.Get( cmbLayersList.Text ) ) ) then
  begin
    CS := TGIS_Layer( frmMain.GIS.Get( cmbLayersList.Text ) ).CS ;
    edCS.Text := cs.WKT;
  end;
end;

end.
