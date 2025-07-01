//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide Geocoding using name standardization
}
unit InfoForm;

interface

uses
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Grids;

type
  TFormInfo = class(TForm)
    sgrdInfo: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormInfo: TFormInfo;

implementation

uses MainForm;

{$R *.DFM}

procedure TFormInfo.FormShow(Sender: TObject);
begin
  Form1.sgrdMemo.Hint := '';
end;

procedure TFormInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.sgrdMemo.Hint := 'Double click for info';
end;

//==================================== END =====================================
end.
