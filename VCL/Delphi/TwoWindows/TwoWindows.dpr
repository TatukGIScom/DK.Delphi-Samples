// This source code is a part of TatukGIS Developer Kernel.
{
  How to support synchronized, two-windows display.
}

program TwoWindows;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
