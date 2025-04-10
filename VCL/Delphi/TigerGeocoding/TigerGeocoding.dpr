//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide Geocoding using name standarization
}
program TigerGeocoding;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  HelpForm in 'HelpForm.pas' {FormHelp},
  InfoForm in 'InfoForm.pas' {FormInfo},
  MatchesForm in 'MatchesForm.pas' {FormMatches};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormHelp, FormHelp);
  Application.CreateForm(TFormInfo, FormInfo);
  Application.CreateForm(TFormMatches, FormMatches);
  Application.Run;
end.
