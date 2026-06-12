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

