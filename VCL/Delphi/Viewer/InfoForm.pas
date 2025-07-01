//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to prepare small coverage previewer.
  Information window.
}
unit InfoForm;

interface

uses
  System.SysUtils,
  System.Classes,

  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.Grids,
  Vcl.ExtCtrls,

  GisUtils,
  GisViewer,
  GisLayerVector,

  Vcl.GisControlAttributes;

type
  TfrmInfo = class(TForm)
    GIS_ControlAttributes: TGIS_ControlAttributes;
  private
    { Private declarations }
    shpObj : TGIS_Shape ;
  public
    { Public declarations }
    procedure ShowInfo( const _shp : TGIS_Shape ) ;
  end;

var
  frmInfo: TfrmInfo;

implementation

{$R *.DFM}


procedure TfrmInfo.ShowInfo( const _shp : TGIS_Shape ) ;
begin
  // if not found, show nothing
  if _shp = nil then
  begin
    shpObj   := nil ;
    Caption := 'Shape: nil' ;
  end
  else begin
    Caption := Format( 'Shape: %d', [_shp.Uid ] )  ;
    // display all attributes for selected shape
    GIS_ControlAttributes.ShowShape(_shp);
    Show ;
  end ;
end ;

end.



