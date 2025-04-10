//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to create format converter
}
{$APPTYPE CONSOLE}
program any2any;

uses
  System.SysUtils,
  System.Classes,

  Winapi.Activex,

  Vcl.Graphics,

  //GisLicense,
  GisAllLayers,
  GisTypes,
  GisFunctions,
  GisViewer,
  GisLayerVector,
  GisUtils,
  GisRegistredLayers,
  GisTypesUI ;

var
  lm         : TGIS_LayerVector ;
  ll         : TGIS_LayerVector ;
  shape_type : TGIS_ShapeType ;

begin
  CoInitialize( nil );
  writeln( 'TatukGIS Samples - ANY->ANY converter ( Vector files only )' ) ;
  if ParamCount <> 3 then begin
    writeln( 'Usage: ANY2ANY source_file destination_file shape_type' ) ;
    writeln( 'Where shape_type:' ) ;
    writeln( ' A - Arc'         ) ;
    writeln( ' G - polyGon'     ) ;
    writeln( ' P - Point'       ) ;
    writeln( ' M - Multipoint'  ) ;
    exit ;
  end ;

  try
    lm := nil ;
    ll := nil ;
    try
      lm  := TGIS_LayerVector( TGIS_Utils.GisCreateLayer( '', ParamStr(1) ) ) ;
      if not Assigned( lm ) then begin
        writeln( Format( '### ERROR: File %s not found', [ParamStr(1)] ) ) ;
        exit ;
      end ;

      lm.Open ;

      case ParamStr(3)[1] of
        'A' : shape_type := TGIS_ShapeType.Arc        ;
        'G' : shape_type := TGIS_ShapeType.Polygon    ;
        'P' : shape_type := TGIS_ShapeType.Point      ;
        'M' : shape_type := TGIS_ShapeType.MultiPoint ;
      else
        shape_type := TGIS_ShapeType.Unknown ;
      end ;

      ll := TGIS_LayerVector( TGIS_Utils.GisCreateLayer( '', ParamStr(2) ) ) ;

      if not Assigned( ll ) then begin
        writeln( Format( '### ERROR: File %s not found', [ParamStr(2)] ) ) ;
        exit ;
      end ;
      ll.ImportLayer( lm,
                      lm.Extent,
                      shape_type,
                      '',
                      False
                    ) ;

    finally
      ll.Free ;
      lm.Free ;
    end ;
  except
    on E : Exception do
      writeln( E.Message ) ;
  end ;
end.
