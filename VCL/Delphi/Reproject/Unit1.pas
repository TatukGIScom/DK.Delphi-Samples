//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to reproject the file.
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
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisCsBase,
  GisCsProjections,
  GisCsFactory,
  GisCsSystems,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    Button1: TButton;
    ToolButton1: TToolButton;
    dlgSave: TSaveDialog;
    ToolButton3: TToolButton;
    cbxSrcProjection: TComboBox;
    procedure Button2Click(Sender: TObject);
    procedure cbxSrcProjectionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  i : Integer ;
  lst : TStringList ;
begin
  lst := TStringList.Create ;
  lst.Sorted := True ;
  try
    lst.Clear ;
    for i:=0 to CsProjList.Count -1 do
    begin
      // UTM is a bit to restrictive to show whole country
      lst.Add( CSProjList[i].WKT ) ;
    end ;
    for i:=0 to lst.Count - 1 do
      cbxSrcProjection.Items.AddObject( lst[i], lst.Objects[i] ) ;
    cbxSrcProjection.ItemIndex := 0 ;
  finally
    lst.Free ;
  end ;

  cbxSrcProjectionChange( Self ) ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\country.shp' ) ;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lv : TGIS_LayerVector ;
  lo : TGIS_LayerVector ;
begin
  if GIS.IsEmpty then exit ;

  if not dlgSave.Execute then exit ;

  lv := TGIS_LayerVector( GIS.Items[0] );

  lo := TGIS_LayerSHP.Create ;
  lo.Path := dlgSave.FileName;
  lo.CS := GIS.CS ;
  try
    lo.ImportLayer( lv,  TGIS_Utils.GisWholeWorld,
                    TGIS_ShapeType.Unknown, '', False

                  ) ;
  finally
    lo.Free ;
  end ;
end;

procedure TForm1.cbxSrcProjectionChange(Sender: TObject);
var
  sproj : String ;
  ocs   : TGIS_CSCoordinateSystem ;
  ogcs  : TGIS_CSGeographicCoordinateSystem ;
  ounit : TGIS_CSUnits ;
  oproj : TGIS_CSProjAbstract ;
begin
  sproj := cbxSrcProjection.Items[cbxSrcProjection.ItemIndex] ;
  ogcs := CSGeographicCoordinateSystemList.ByEPSG( 4030 ) ;
  ounit := CSUnitsList.ByWKT( 'METER') ;
  oproj := CSProjList.ByWKT( sproj ) ;

  ocs := TGIS_CSProjectedCoordinateSystem.Create(
           -1, 'Test',
           ogcs.EPSG, ounit.EPSG, oproj.EPSG,
           CSProjectedCoordinateSystemList.DefaultParams( oproj.EPSG )
         );

  GIS.Lock ;
  try
    try
      GIS.CS := ocs ;
      GIS.FullExtent ;
    except
      GIS.CS := nil
    end;
  finally
    GIS.Unlock ;
  end;
end;


end.

