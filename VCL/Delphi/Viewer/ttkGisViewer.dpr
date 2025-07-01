//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to prepare small coverage previewer.
  Main window.
}
program ttkGisViewer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  ExportForm in 'ExportForm.pas' {frmExportLayer},
  InfoForm in 'InfoForm.pas' {frmInfo},
  SearchForm in 'SearchForm.pas' {FSearch},
  EditForm in 'EditForm.pas' {fEdit};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TatukGIS CoverageViewer';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmExportLayer, frmExportLayer);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.CreateForm(TFSearch, FSearch);
  Application.CreateForm(TfEdit, fEdit);
  Application.Run;
end.
