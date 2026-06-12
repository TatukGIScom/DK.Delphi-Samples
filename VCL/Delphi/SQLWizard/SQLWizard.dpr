program SQLWizard;

uses
  Vcl.Forms,
  formLayerSQL in 'formLayerSQL.pas' {frmLayerSQL},
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmLayerSQL, frmLayerSQL);
  Application.Run;
end.

