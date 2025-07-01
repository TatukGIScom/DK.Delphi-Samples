//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Convert OSM to other formats : SHP, SQL Native
}
program ConvertOSM;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
