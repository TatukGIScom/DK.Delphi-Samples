//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide editing functionality.
}

program SimpleEdit;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  ToolsForm in 'ToolsForm.pas' {frmEditorTools},
  InfoForm in 'InfoForm.pas' {frmInfo};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'SimpleEdit - Sopot';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmEditorTools, frmEditorTools);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.Run;
end.
