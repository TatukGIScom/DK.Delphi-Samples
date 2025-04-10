//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to implement a real-time viewshed running on OpenCL.
  Info form.
}
unit formInfo;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls ;

type
  TfrmInfo = class(TForm)
    btnClose: TButton;
    mmInfo: TMemo;
  public
    function Execute (  const _title : String ;
                        const _info  : String
                     ) : Integer ;
  end;

var
  frmInfo: TfrmInfo;

implementation

{$R *.dfm}

function TfrmInfo.Execute(
  const _title : String ;
  const _info  : String
) : Integer ;
begin
  Self.Caption := _title ;
  mmInfo.Text  := _info ;

  Result := Self.ShowModal ;
end ;

end.
