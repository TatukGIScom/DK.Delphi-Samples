//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide basic Client-Server solution (Client side).
  Based on Indy demo
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient;

type
  TForm1 = class(TForm)
    Label2: TLabel;
    edtHost: TEdit;
    Label3: TLabel;
    edtPort: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    cboCommands: TComboBox;
    Label4: TLabel;
    btnSendCommand: TButton;
    IdTCPClient: TIdTCPClient;
    memMessages: TMemo;
    Image1: TImage;
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnSendCommandClick(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure IdTCPClientConnected(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LockControls(ALock:Boolean);
    procedure UpdateStatus ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.UpdateStatus ;
begin
  try
    if IdTCPClient.Connected then
    begin
      btnConnect.Enabled    := False ;
      btnDisconnect.Enabled := True  ;
    end
    else
    begin
      btnConnect.Enabled    := True  ;
      btnDisconnect.Enabled := False ;
    end ;
  except
    btnConnect.Enabled    := True  ;
    btnDisconnect.Enabled := False ;
  end;
end ;


procedure TForm1.LockControls(ALock: Boolean);
var
  i : Integer;
begin
  for i := 0 to ComponentCount-1 do
    if TControl(Components[i]).Tag = 99 then
       TControl(Components[i]).Enabled := ALock;
end;

procedure TForm1.btnDisconnectClick(Sender: TObject);
begin
  if IdTCPClient.Connected then
  begin
    try
      IdTCPClient.Disconnect; // we can disconnect from either the server or the client side
    except on E : Exception do
      ShowMessage(E.Message);
    end;
  end;
  UpdateStatus ;
end;

procedure TForm1.btnConnectClick(Sender: TObject);
begin
  memMessages.Lines.Clear;

  with IdTCPClient do
  begin
    Host := edtHost.Text;
    Port := StrToint(edtPort.Text);
    try
      Connect;
    except
      on E : Exception do
      begin
        LockControls(True);
        ShowMessage(E.Message);
      end;
    end;
  end;
  UpdateStatus ;
end;

procedure TForm1.btnSendCommandClick(Sender: TObject);
var
  LCommand : String;
  strm : TMemoryStream ;
  cnt  : Integer ;
  bmp : TBitmap ;
begin
  LCommand := cboCommands.Text;

  strm := TMemoryStream.Create ;
  try
    try
      IdTCPClient.IOHandler.WriteLn(LCommand);
      cnt := IdTCPClient.IOHandler.ReadLongInt ;
      IdTCPClient.IOHandler.ReadStream( strm, cnt );
      strm.Position := 0 ;

      bmp := TBitmap.Create ;
      bmp.LoadFromStream( strm ) ;
      Image1.Width  := bmp.Width  ;
      Image1.Height := bmp.Height ;
      Image1.Canvas.FillRect( Image1.Canvas.ClipRect );
      Image1.Canvas.Draw( 0, 0, bmp );

    except
      on E : Exception do
      begin
        LockControls(True);
        ShowMessage(E.Message);
      end;
    end;

  finally
    strm.Free ;
  end ;

  UpdateStatus ;
end;

procedure TForm1.IdTCPClientDisconnected(Sender: TObject);
begin
  memMessages.Lines.Add('Disconnected from remote server');
  LockControls(false);
  UpdateStatus ;
end;

procedure TForm1.IdTCPClientConnected(Sender: TObject);
var
  str : String;
begin
  str := IdTCPClient.IOHandler.ReadLn;
  memMessages.Lines.Add('Connected to remote server');
  memMessages.Lines.Add('Server said -> ' + str);
  LockControls(true);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if cboCommands.Items.Count > 0 then
  begin
    cboCommands.ItemIndex := 0;
    cboCommands.Text := cboCommands.Items.Strings[cboCommands.ItemIndex];
  end;
end;

end.
