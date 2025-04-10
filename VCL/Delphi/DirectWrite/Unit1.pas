//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to write SHP Layer.
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

  GisTypesUI,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Toolbar1: TToolBar;
    btnImportLayer: TButton;
    btnMergeLayer: TButton;
    btnDirectMerge: TButton;
    btnBuild: TButton;
    btnDirectWrite: TButton;
    procedure btnImportLayerClick(Sender: TObject);
    procedure btnDirectMergeClick(Sender: TObject);
    procedure btnBuildClick(Sender: TObject);
    procedure btnMergeLayerClick(Sender: TObject);
    procedure btnDirectWriteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    number  : Integer ;
    exist   : Boolean ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  //GisLicense,
  GisTypes,
  GisUtils,
  GisLayerSHP,
  GisLayerVector,
  GisGeometryFactory,
  GisRtl ;

procedure TForm1.btnImportLayerClick(Sender: TObject);
var
  ll  : TGIS_LayerSHP ;
  lv  : TGIS_LayerSHP ;
  shp : TGIS_Shape ;
begin
  GIS.Close ;

  btnMergeLayer.Enabled := true;

  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\cities.shp' ;
  GIS.Add( ll ) ;

  shp := TGIS_GeometryFactory.GisCreateShapeFromWKT(
    'POLYGON((7.86 56.39,31.37 56.39,31.37 39.48,7.86 39.48,7.868 56.39))'
  ) ;

  lv := TGIS_LayerSHP.Create ;
  lv.Path := 'Shapes'+ IntToStr( number ) + '\imported.shp' ;
  lv.CS := ll.CS ;
  lv.ImportLayerEx( ll, ll.Extent, TGIS_ShapeType.Unknown, '',
                    shp, TGIS_Utils.GIS_RELATE_CONTAINS, False
                  ) ;
  FreeObject( shp ) ;
  GIS.Add( lv ) ;
  lv.Params.Marker.Color := TGIS_Color.Green ;
  GIS.FullExtent ;
  GIS.VisibleExtent := lv.Extent ;
  GIS.InvalidateWholeMap ;

end;

procedure TForm1.btnMergeLayerClick(Sender: TObject);
var
  ll  : TGIS_LayerSHP ;
  lv  : TGIS_LayerSHP ;
  shp : TGIS_Shape ;
begin
  GIS.Close ;

  btnDirectWrite.Enabled := true;

  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\cities.shp' ;
  GIS.Add( ll ) ;

  shp := TGIS_GeometryFactory.GisCreateShapeFromWKT(
    'POLYGON((7.86 56.39,31.37 56.39,31.37 39.48,7.86 39.48,7.868 56.39))'
  ) ;

  lv := TGIS_LayerSHP.Create ;
  lv.Path := 'Shapes'+ IntToStr( number ) + '\imported.shp' ;
  lv.CS := ll.CS ;
  lv.MergeLayerEx( ll, ll.Extent, TGIS_ShapeType.Unknown, '',
                    shp, TGIS_Utils.GIS_RELATE_DISJOINT, False, False
                  ) ;
  FreeObject( shp ) ;
  GIS.Add( lv ) ;
  lv.Params.Marker.Color := TGIS_Color.Green ;
  GIS.FullExtent ;

  GIS.InvalidateWholeMap ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  number := 0;
  exist := true;

  while exist do begin
    if DirectoryExists('Shapes'+ IntToStr( number ) ) then begin
      inc(number);
    end else
      exist := false;
  end;

  CreateDir('Shapes'+ IntToStr( number ) )
end;

procedure TForm1.btnDirectMergeClick(Sender: TObject);
var
  lv   : TGIS_LayerSHP ;
  ll   : TGIS_LayerVector ;
  shp  : TGIS_Shape ;
  drm  : TGIS_LayerVectorMergeHelper ;
begin
  GIS.Close ;

  btnDirectMerge.Enabled := false ;
  btnMergeLayer.Enabled := false ;
  btnImportLayer.Enabled := false ;
  btnDirectWrite.Enabled := false ;

  ll := TGIS_LayerSHP.Create ;
  try
    ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\cities.shp' ;
    ll.Open ;

    lv := TGIS_LayerSHP.Create ;
    try
      lv.ImportStructure( ll ) ;
      lv.CS := ll.CS ;
      try
        lv.Build( 'Shapes'+ IntToStr( number ) + '\merge_helper.shp', ll.Extent,
                   TGIS_ShapeType.Point, TGIS_DimensionType.XY
                );
      except

      end;

      drm := TGIS_LayerVectorMergeHelper.Create( lv, 500 ) ;
      try
        for shp in ll.Loop do begin
          drm.AddShape( shp ) ;
          drm.Commit ;
        end ;
      finally
        FreeObject( drm ) ;
      end ;
    finally
      GIS.Add( lv ) ;
      GIS.FullExtent ;
    end;
  finally
    FreeObject( ll ) ;
  end ;
end;

procedure TForm1.btnDirectWriteClick(Sender: TObject);
var
  lv   : TGIS_LayerSHP ;
  ll   : TGIS_LayerVector ;
  shp  : TGIS_Shape ;
  drh  : TGIS_LayerVectorDirectWriteHelper ;
begin
  GIS.Close ;

  btnDirectMerge.Enabled := true;

  ll := TGIS_LayerSHP.Create ;
  try
    ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\cities.shp' ;
    ll.Open ;

    lv := TGIS_LayerSHP.Create ;
    try
      lv.ImportStructure( ll ) ;
      lv.CS := ll.CS ;

      drh := TGIS_LayerVectorDirectWriteHelper.Create( lv ) ;
      try
        drh.Build( 'Shapes'+ IntToStr( number ) + '\direct_write.shp', ll.Extent,
                   TGIS_ShapeType.Point, TGIS_DimensionType.XY
                  );
        for shp in ll.Loop do begin
          drh.AddShape( shp ) ;
        end ;
        drh.Close ;
      finally
        FreeObject( drh ) ;
      end ;
    finally
      GIS.Add( lv ) ;
      GIS.FullExtent ;
    end;
  finally
    FreeObject( ll ) ;
  end ;
end;

procedure TForm1.btnBuildClick(Sender: TObject);
var
  lv  : TGIS_LayerSHP ;
  ll  : TGIS_LayerSHP ;
  shp : TGIS_Shape ;
begin
  GIS.Close ;

  btnImportLayer.Enabled := true;

  lv := TGIS_LayerSHP.Create ;
  if DirectoryExists('Shapes'+ IntToStr( number ) ) then begin
    inc(number);
    CreateDir('Shapes'+ IntToStr( number ) ) ;
  end;
  try
    lv.Build( ('Shapes'+ IntToStr( number ) + '\build.shp'),
              TGIS_Utils.GisExtent( -180, -90, 180, 90 ),
              TGIS_ShapeType.Point,
              TGIS_DimensionType.XY
             ) ;
    lv.Open ;

    ll := TGIS_LayerSHP.Create ;
    try
      ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\cities.shp' ;
      ll.Open ;

      lv.ImportStructure( ll ) ;
      lv.CS := ll.CS ;
      for shp in ll.Loop do
        lv.AddShape( shp, True ) ;
    finally
      FreeObject( ll ) ;
    end;
    lv.SaveData ;
  except

  end;

  GIS.Add(lv) ;
  GIS.FullExtent ;
  GIS.InvalidateWholeMap ;

end;

end.
