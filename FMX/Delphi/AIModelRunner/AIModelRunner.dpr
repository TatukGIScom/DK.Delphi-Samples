program AIModelRunner;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {AISampleForm},
  CustomModelForm in 'CustomModelForm.pas' {CustomAIModelForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAIModelRunnerForm, AIModelRunnerForm);
  Application.CreateForm(TCustomAIModelForm, CustomAIModelForm);
  Application.Run;
end.
