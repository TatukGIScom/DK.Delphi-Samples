program GridToVector;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmGridToVector};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmGridToVector, frmGridToVector);
  Application.Run;
end.

