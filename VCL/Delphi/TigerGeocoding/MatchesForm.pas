//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide Geocoding using name standarization
}
unit MatchesForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Contnrs,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  GisTypes;

type
  TFormMatches = class(TForm)
    memMatches: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowMatches ( const _resolvedAddresses  : TGIS_ObjectList ;
                            const _resolvedAddresses2 : TGIS_ObjectList ) ;
  end;

var
  FormMatches: TFormMatches;

implementation

{$R *.DFM}


  procedure TFormMatches.ShowMatches ( const _resolvedAddresses  : TGIS_ObjectList ;
                                       const _resolvedAddresses2 : TGIS_ObjectList ) ;
  var
    i, j    : Integer  ;
    strings : TStrings ;
  begin
    memMatches.Clear ;
    if Assigned ( _resolvedAddresses ) then
      for i := 0 to _resolvedAddresses.Count-1 do begin
        if i <> 0 then
          memMatches.Lines.Add ( '------------------------' );
        strings := TStrings( _resolvedAddresses[i] ) ;
        for j := 0 to strings.Count-1 do
          memMatches.Lines.Add ( strings.Strings[j] );
      end ;
    if Assigned ( _resolvedAddresses2 ) then
      for i := 0 to _resolvedAddresses2.Count-1 do begin
        if i = 0 then
          memMatches.Lines.Add ( '========================' )
        else
          memMatches.Lines.Add ( '------------------------' );
        strings := TStrings( _resolvedAddresses2[i] ) ;
        for j := 0 to strings.Count-1 do
          memMatches.Lines.Add ( strings.Strings[j] );
      end ;
  end;
end.
