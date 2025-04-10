//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to support different projections
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
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,

  //GisLicense,
  GisCsBase,
  GisCsProjections,
  GisCsFactory,
  GisCsSystems,
  GisEditor,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    cbxSrcProjection: TComboBox;
    GIS: TGIS_ViewerWnd;
    procedure FormCreate(Sender: TObject);
    procedure cbxSrcProjectionChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}


procedure TfrmMain.FormCreate(Sender: TObject);
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
      if CSProjList[i].IsStandard then
        lst.Add( CSProjList[i].WKT ) ;
    end ;
    for i:=0 to lst.Count - 1 do
      cbxSrcProjection.Items.AddObject( lst[i], lst.Objects[i] ) ;
    cbxSrcProjection.ItemIndex := 0 ;
  finally
    lst.Free ;
  end ;

  cbxSrcProjectionChange( Self ) ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Projects\world.ttkproject' ) ;
  cbxSrcProjectionChange( Self ) ;
end;



procedure TfrmMain.cbxSrcProjectionChange(Sender: TObject);
var
  sproj : String ;
  ocs   : TGIS_CSCoordinateSystem ;
  ogcs  : TGIS_CSGeographicCoordinateSystem ;
  ounit : TGIS_CSUnits ;
  oproj : TGIS_CSProjAbstract ;
begin
  sproj := cbxSrcProjection.Items[cbxSrcProjection.ItemIndex] ;

  ogcs := CSGeographicCoordinateSystemList.ByEPSG( 4030 ) ;
  ounit := CSUnitsList.ByWKT( 'METER' ) ;
  oproj := CSProjList.ByWKT( sproj ) ;


  ocs := TGIS_CSProjectedCoordinateSystem.Create(
           -1, 'Test',
           ogcs.EPSG, ounit.EPSG, oproj.EPSG,
           CSProjectedCoordinateSystemList.DefaultParams(oproj.EPSG)
         );

  GIS.Lock ;
  try
    try
      GIS.CS := ocs ;
      GIS.FullExtent ;
    except
      // we are aware of problems upon switching
      // between two incompatible systems
    end;
  finally
    GIS.Unlock ;
  end;
end;

end.
