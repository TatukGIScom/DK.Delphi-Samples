program BimViewer;

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {frmMain},
  BimModel in 'BimModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

