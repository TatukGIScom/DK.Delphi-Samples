﻿//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform Geocoding & Routing.
}

program Geocoding;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
