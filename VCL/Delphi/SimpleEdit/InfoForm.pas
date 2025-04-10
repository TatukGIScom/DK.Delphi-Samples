//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide editing functionality.
}
unit InfoForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,

  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.Grids,
  Vcl.ExtCtrls,

  GisLayerVector,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes;

type
  TfrmInfo = class(TForm)
    GISAttributes: TGIS_ControlAttributes;

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
  GISAttributes.ShowShape( _shp ) ;
end ;

end.



