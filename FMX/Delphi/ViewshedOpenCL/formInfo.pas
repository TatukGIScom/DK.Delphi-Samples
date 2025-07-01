//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to implement a real-time viewshed running on OpenCL.
  Info form.
}
unit formInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls;

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

{$R *.fmx}


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
