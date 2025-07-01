//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Generates a Voronoi diagram/Delaunay triangulation.
}
program Triangulation;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
