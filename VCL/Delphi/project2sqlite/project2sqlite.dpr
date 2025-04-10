//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to convert a project layers into sqlite equivalent.
}
{$APPTYPE CONSOLE}
program project2sqlite;

uses
  System.Classes,
  System.Contnrs,
  System.SysUtils,

  Winapi.Activex,

  Vcl.Graphics,

  //GisLicense,
  GisConfigIni,
  GisConfigXml,
  GisConfig,
  GisFunctions,
  GisInternals,
  GisLayerPixel,
  GisLayerPixelStoreSqlite,
  GisLayerPixelSql,
  GisLayerSqlSqlite,
  GisLayerVector,
  GisLayerVectorSql,
  GisRegistredLayers,
  GisResource,
  GisRtl,
  GisLogger,
  GisTypes,
  GisUtils,
  GisViewer,
  GisInterfaces,
  Vcl.GisViewerBMP;

const
  TTKLS = '[TatukGIS Layer]\nStorage=Native\nDialect=SQLITE\n'+
          'Layer=%s\nSqlite=%s\nENGINEOPTIONS=16\n' +
          GIS_TTKLS_EXT ;

var
  bmp   : TBitmap ;
  vwr   : TGIS_ViewerBMP ;
  lp    : TGIS_LayerPixel ;
  lv    : TGIS_LayerVector ;
  lsv   : TGIS_LayerVectorSqlAbstract ;
  i,p   : Integer ;
  path  : String ;
  sprj  : String ;
  dbf   : String ;
  prj   : TGIS_Config ;
  lst   : TStringList ;
  lsts  : TStringList ;
  embed : Boolean ;
begin
  CoInitialize( nil ) ;

  TGIS_Logger.Active := False ;

  writeln( 'TatukGIS Samples - Project->Sqlite converter.' ) ;
  if ParamCount < 2 then begin
    writeln( 'Converts vector layers of a project into sqlite database.' ) ;
    writeln( 'Usage : ' ) ;
    writeln( '  project2sqlite InputProject OutputProject [db embedded|ttkls] ' ) ;
    writeln( 'Parameters:' ) ;
    writeln( '  InputProject OutputProject - paths to project files (must have the same extension)' ) ;
    writeln( 'Optional parameters:' ) ;
    writeln( '  db - path to sqlite database' ) ;
    writeln( '  embedded|ttkls - use embedded path to database in project or create ttkls' ) ;
    exit ;
  end ;

  bmp := TBitmap.Create ;
  bmp.Width  := 128 ;
  bmp.Height := 128 ;

  vwr := TGIS_ViewerBMP.Create( bmp ) ;
  try
    try
      vwr.Open( ParamStr(1) ) ;
      writeln(' Opening project file: ' + ParamStr(1) + ' ('+ IntToStr(vwr.Items.Count)+ ' layers)' ) ;
      sprj := ParamStr(2) ;
      path := GetFilePath( sprj ) ;
      if not DirectoryExists( path ) then begin
        writeln( Format( '### ERROR: Directory %s not found', [path] )) ;
        exit ;
      end;

      prj  := TGIS_ConfigFactory.CreateConfig( nil, sprj ) ;

      lst := TStringList.Create ;
      if Assigned( vwr.ProjectFile ) then
        TGIS_Config(vwr.ProjectFile).GetStrings( lst );

      if prj.ConfigFormat = TGIS_ConfigFormat.Ini then
        TGIS_ConfigProjectIni(prj).IniObj.SetStrings( lst )
      else begin
        TGIS_ConfigProjectXml(prj).ClearActiveSection ;
        TGIS_ConfigProjectXml(prj).IniObj.SetStrings( lst ) ;
      end ;

      lst.Clear ;
      lsts := TStringList.Create ;

      dbf := ParamStr(3) ;
      if IsStringEmpty( dbf ) then
        dbf := 'Layers.sqlite' ;

      embed := ParamStr(4) <> 'ttkls' ;

      SetCurrentDir( path ) ;
      writeln('  Importing layers :' ) ;
      for i := 0 to vwr.Items.Count-1 do begin
        if vwr.Items[i] is TGIS_LayerVector then begin
          lv := TGIS_LayerVector( vwr.Items[i] ) ;
          write('  -> ' + lv.Name + '...' ) ;

          p := lst.IndexOf( lv.Path ) ;
          if p >=0 then begin
            prj.SetLayer(lv);
            if prj.ConfigFormat = TGIS_ConfigFormat.Ini then
              prj.WriteString( GIS_INI_PATH, lsts[p], '' )
            else begin
              TGIS_ConfigProjectXml(prj).IniObj.SetLayer( lv.Name ) ;
              TGIS_ConfigProjectXml(prj).IniObj.WriteAttribute( GIS_INI_PATH, lsts[p] ) ;
            end ;
          end
          else begin
            lsv := TGIS_LayerSqlSqlite.Create ;
            try
              lsv.Name := lv.Name ;
              lsv.CS := lv.CS ;
              if embed then
                lsv.Path := Format(
                              TTKLS,
                              [TGIS_Utils.GisCanonicalSQLName(lv.Name),
                               GetPathRelative( path, GetPathDirSep( path ) +
                                                dbf
                                               ) ]
                             )
              else
                lsv.Path := GetPathDirSep( path ) +
                            GetFileNameNoExt( lv.Path ) + GIS_TTKLS_EXT ;

              lsv.SQLParameter[ 'PRAGMA synchronous'  ] := 'OFF' ;
              lsv.SQLParameter[ 'PRAGMA journal_mode' ] := 'OFF' ;
              lsv.ImportLayer( lv, lv.Extent, TGIS_ShapeType.Unknown, '', False ) ;

              prj.SetLayer(lv);
              if prj.ConfigFormat = TGIS_ConfigFormat.Ini then
                prj.WriteString( GIS_INI_PATH, lsv.Path, '' )
              else begin
                TGIS_ConfigProjectXml(prj).IniObj.SetLayer( lv.Name ) ;
                TGIS_ConfigProjectXml(prj).IniObj.WriteAttribute( GIS_INI_PATH, lsv.Path ) ;
              end ;

              lst.Add( lv.Path ) ;
              lsts.Add( lsv.Path ) ;
            finally
              lsv.Free ;
            end ;
          end ;
          writeln('ok!' ) ;

        end
        else if  vwr.Items[i] is TGIS_LayerPixel then begin
          lp := TGIS_LayerPixel( vwr.Items[i] ) ;
          write('  -> ' + lp.Name + '...' ) ;
          // TODO - make ImportLayer for pixelstore
          writeln('skipped!' ) ;
        end ;

      end ;

      writeln(' Saving new project: ' + sprj ) ;
      prj.Save ;
      prj.Free ;
      FreeObject( lst ) ;
      FreeObject( lsts ) ;
    finally
      bmp.Free ;
      vwr.Free ;
    end ;
  except
    on E : Exception do
      writeln( E.Message ) ;
  end ;

end.
