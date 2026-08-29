program WindEngine;

uses
  Vcl.Forms,
  WindEngineUnit in 'WindEngineUnit.pas',
  Unit1 in 'Unit1.pas' {FormMain},
  GisLayerWind in 'GisLayerWind.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
