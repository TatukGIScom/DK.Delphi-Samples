program ViewshedOpenCL;

uses
  System.StartUpCopy,
  FMX.Forms,
  formMain in 'formMain.pas' {frmMain},
  formInfo in 'formInfo.pas' {frmInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.Run;
end.
