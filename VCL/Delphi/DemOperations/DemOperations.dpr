//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide basic dem operations.
}
program DemOperations;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R DemOperations.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
