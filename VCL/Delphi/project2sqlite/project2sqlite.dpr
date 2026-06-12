//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  project2sqlite Utility - Console-based converter for migrating TatukGIS
  project layers from shapefiles to SQLite database storage.

  Key concepts illustrated:
    - Project migration: convert layers from one storage format to another
    - Shapefile to SQLite: efficient file format conversion
    - Database backend: centralize multiple layers in single database
    - Project file update: .ttkproject references new database layers
    - Batch conversion: process multiple project layers at once
    - Data preservation: no data loss, attributes and geometry preserved
    - Path configuration: embedded vs. relative paths in project

  Technical approach:
    - Load source .ttkproject with shapefile layers
    - For each vector layer:
      * Create corresponding SQLite table in database
      * Import shapefile records to SQLite via ImportLayer
      * Update project to reference SQLite layer (.ttkls file)
    - Save updated project configuration
    - Original shapefiles remain untouched

  Usage:
    project2sqlite <InputProject> <OutputProject> [dbpath] [embedded|ttkls]

  Parameters:
    - InputProject: source .ttkproject file with shapefile layers
    - OutputProject: destination .ttkproject file (same extension required)
    - dbpath: optional path to SQLite database (default: Layers.sqlite)
    - embedded|ttkls: use embedded path in project or create .ttkls file

  Workflow:
    1. Prepare source project with shapefile layers
    2. Run: project2sqlite input.ttkproject output.ttkproject
    3. Converter creates Layers.sqlite database
    4. Imports all vector layers to SQLite
    5. Saves new output.ttkproject referencing SQLite layers
    6. Output project ready for use immediately

  Benefits of SQLite Storage:
    - Single file per database (vs. multiple .shp/.dbf/.shx files)
    - Faster access: SQL queries vs. sequential shapefile scan
    - Smaller footprint: compression, no index files needed
    - Transactional: ACID compliance, atomic updates
    - Portable: SQLite included in most systems
    - No server required: embedded database, works offline

  SQLite Parameters:
    - PRAGMA synchronous: OFF (faster writes during import)
    - PRAGMA journal_mode: OFF (faster bulk insert)

  Raster Layers:
    - Currently skipped (TODO in code)
    - Only vector layers converted

  Configuration Output:
    - New project references layers as:
      * Embedded: path relative to project file
      * External .ttkls: separate SQL layer definitions
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
