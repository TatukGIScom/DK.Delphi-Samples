unit BimModel ;

interface

uses
  System.Classes,
  System.Generics.Collections ,
  GisTypes;

type
  PropertyInfo = record
  public
    Name  : String ;
    Value : String ;
  end ;

  ElementPropertySet = record
  public
    SetName    : String ;
    Properties : TArray<PropertyInfo> ;
  end ;

  Element = class
  public
    Id           : Integer ;
    Name         : String ;
    IfcType      : String ;
    Guid         : String ;
    PropertySets : TArray<ElementPropertySet> ;
    Elements     : TArray<Element> ;
    Extent       : TGIS_Extent3D ;
  public
    destructor Destroy ; override ;
  end ;

  TModelBuilder = class
  public
    Project : Element ;
  public
    constructor Create ;
    destructor Destroy ; override ;

    procedure Load( const _path : String  ) ; overload ;
    procedure Load( const _stm  : TStream ) ; overload ;
    procedure Reset ;
  end ;

implementation

uses
  IOUtils,
  SysUtils,
  GisInternals,
  {$IF CompilerVersion >= 35.0}
  JSON.Serializers,
  {$ENDIF}
  JSON ;

{ TModelBuilder }

constructor TModelBuilder.Create ;
begin
  inherited ;
  Project := nil ;
end ;

destructor TModelBuilder.Destroy ;
begin
  if assigned(Project) then
    Project.Free ;

  inherited ;
end ;

procedure TModelBuilder.Load( const _stm : TStream ) ;
{$IF CompilerVersion >= 35.0}
var
  rdr : TJsonSerializer ;
  jsonReader : TStreamReader ;
{$ENDIF}
begin
  if not assigned( _stm ) then exit ;
  _stm.Position := 0 ;

  {$IF CompilerVersion >= 35.0}
  rdr := TJsonSerializer.Create ;
  jsonReader := TStreamReader.Create( _stm ) ;
  try
    Project := rdr.Deserialize<Element>(jsonReader) ;
  finally
    jsonReader.Free ;
    rdr.Free ;
  end ;
  {$ENDIF}
end ;

procedure TModelBuilder.Load( const _path : String ) ;
var
{$IF CompilerVersion >= 35.0}
  rdr : TJsonSerializer ;
  JSON : String ;
{$ENDIF}
  path : String ;
begin
  path := GetPathNoExt(_path) + '.json' ;
  if SafeFileExists(path) then begin
  {$IF CompilerVersion >= 35.0}
    JSON := TFile.ReadAllText(path, TEncoding.UTF8) ;
    rdr := TJsonSerializer.Create ;
    try
      Project := rdr.Deserialize<Element>(JSON) ;
    finally
      rdr.Free ;
    end ;
  {$ENDIF}
  end ;
end ;

procedure TModelBuilder.Reset ;
begin
  if assigned(Project) then begin
    Project.Free ;
    Project := nil ;
  end ;
end ;

{ Element }

destructor Element.Destroy ;
var
  elm : Element ;
begin
  for elm in Elements do
    elm.Free ;
  inherited ;
end ;

end.
