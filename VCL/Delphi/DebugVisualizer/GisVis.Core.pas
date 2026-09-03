//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  GisVis.Core — utility functions for debugger shape visualization (Delphi/VCL).

  What the unit provides:
    - Shape statistics record (TGisVisShapeStats) for metadata and geometry properties
    - WKT (Well-Known Text) parsing and geometry reconstruction from text format
    - Quote character stripping from debugger expressions
    - Text truncation utilities for display in UI
    - In-memory layer factory for visualization
    - Shape building from WKT geometry strings
    - Statistics computation (extent, area, length) from shapes

  Key functions:
    GisVisStripQuotes           - remove enclosing single quotes from strings
    GisVisWktGeometryType       - extract geometry type from WKT string
    GisVisTruncate              - truncate text to max length with ellipsis
    GisVisCreateMemoryLayer     - factory for in-memory vector layer
    GisVisBuildShapeFromWKT     - reconstruct shape object from WKT text
    GisVisComputeStats          - extract geometric and topological statistics
}
unit GisVis.Core ;

interface

uses
  System.SysUtils, System.Classes,
  GisLayerVector, GisTypes ;

type
  TGisVisShapeStats = record
    Uid  : Int64 ;
    ShapeClassName : String ;
    GeometryType : String ;
    NumParts : Integer ;
    NumPoints : Integer ;
    XMin, YMin, XMax, YMax : Double ;
    HasExtent : Boolean ;
    Area : Double ;
    HasArea : Boolean ;
    Length : Double ;
    HasLength : Boolean ;
    WKT : String ;
  end ;

  function GisVisStripQuotes( const S : String ) : String ;
  function GisVisWktGeometryType( const AWKT : String ) : String ;
  function GisVisTruncate( const S : String ; AMax : Integer ) : String ;
  function GisVisCreateMemoryLayer : TGIS_LayerVector ;
  function GisVisBuildShapeFromWKT( const Index  : Integer ; const AWKT : String ;
    ALayer : TGIS_LayerVector ; out AShape : TGIS_Shape ; out error : String ) : Boolean ;
  function GisVisComputeStats( AShape : TGIS_Shape ; const AWKT : String ) : TGisVisShapeStats ;

implementation

uses
  GisGeometryFactory  ;

  function GisVisStripQuotes(
    const S : String
  ) : String ;
  var
    LInner : String ;
  begin
    Result := S ;
    if ( Length( Result ) >= 2 ) and ( Result[1] = '''' ) and ( Result[Length( Result )] = '''' ) then
    begin
      LInner := Copy( Result, 2, Length( Result ) - 2 ) ;
      Result := StringReplace( LInner, '''''', '''', [rfReplaceAll] ) ;
    end ;
  end ;

  function GisVisWktGeometryType(
    const AWKT : String
  ) : String ;
  var
    LWkt : String ;
    LParenPos, I : Integer ;
    LKeyword : String ;
  begin
    Result := '' ;
    LWkt := Trim( AWKT ) ;
    if LWkt = '' then
      Exit ;
    LParenPos := Pos( '(', LWkt ) ;
    if LParenPos <= 1 then
      Exit ;
    LKeyword := Trim( Copy( LWkt, 1, LParenPos - 1 ) ) ;

    I := Pos( ' ', LKeyword ) ;
    if I > 0 then
      LKeyword := Copy( LKeyword, 1, I - 1 ) ;
    if LKeyword = '' then
      Exit ;
    Result := UpperCase( Copy( LKeyword, 1, 1 ) ) + LowerCase( Copy( LKeyword, 2, MaxInt ) ) ;
  end ;

  function GisVisTruncate(
    const S : String ; AMax : Integer
  ) : String ;
  begin
    if Length( S ) <= AMax then
      Result := S
    else
      Result := Copy( S, 1, AMax ) + '...' ;
  end ;

  function GisVisCreateMemoryLayer : TGIS_LayerVector ;
  begin
    Result := TGIS_LayerVector.Create ;
    Result.Name := 'GisVisPreview' ;
  end ;

  function GisVisBuildShapeFromWKT(
    const Index : Integer ; const AWKT : String ; ALayer : TGIS_LayerVector ;
    out AShape : TGIS_Shape ; out error : String
  ) : Boolean ;
  var
    LTemplate : TGIS_Shape ;
  begin
    Result := False ;
    AShape := nil ;
    error := '' ;
    if ( AWKT = '' ) or ( ALayer = nil ) then
      Exit ;
    try
      ALayer.RevertAll ;

      LTemplate := nil  ;
      case Index of
        0  : LTemplate := TGIS_GeometryFactory.GisCreateShapeFromWKT( AWKT ) ;
        1  : LTemplate := TGIS_GeometryFactory.GisCreateShapeFromJSON( AWKT ) ;
        2  : LTemplate := TGIS_GeometryFactory.GisCreateShapeFromGML( AWKT ) ;
      end ;
      if assigned( LTemplate ) then begin
        try
          AShape := ALayer.AddShape(  LTemplate, False  )  ;
        finally
          LTemplate.Free ;
        end ;
      end ;

      Result := Assigned( AShape ) ;
    except
      on E : Exception do begin
        AShape := nil ;
        Result := False ;
        error := E.Message ;
      end ;
    end ;
  end ;

  function GisVisComputeStats(
    AShape : TGIS_Shape ; const AWKT : String
  ) : TGisVisShapeStats ;
  var
    LParts : Integer ;
    LExtent : TGIS_Extent ;
  begin
    FillChar( Result, SizeOf( Result ), 0 ) ;
    Result.WKT := AWKT ;
    Result.GeometryType := GisVisWktGeometryType( AWKT ) ;

    if AShape = nil then
      Exit ;

    Result.Uid := AShape.UID ;
    Result.ShapeClassName := AShape.ClassName ;

    try
      LParts := AShape.GetNumParts ;
      Result.NumParts := LParts ;
      Result.NumPoints := AShape.GetNumPoints ;
    except
    end ;

    try
      LExtent := AShape.Extent ;
      Result.XMin := LExtent.XMin ;
      Result.YMin := LExtent.YMin ;
      Result.XMax := LExtent.XMax ;
      Result.YMax := LExtent.YMax ;
      Result.HasExtent := True ;
    except
      Result.HasExtent := False ;
    end ;

    try
      Result.Area := AShape.Area ;
      Result.HasArea := True ;
    except
      Result.HasArea := False ;
    end ;

    try
      Result.Length := AShape.Length ;
      Result.HasLength := True ;
    except
      Result.HasLength := False ;
    end ;
  end ;

end.
