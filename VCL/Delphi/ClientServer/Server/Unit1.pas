//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide basic Client-Server solution (Server side)
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
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.CheckLst,

  IdBaseComponent,
  IdComponent,
  IdContext,
  IdCustomTCPServer,
  IdTCPServer,

  //GisLicense,
  GisUtils,
  GisTypes,

  Vcl.GisViewerBMP;

type
  TForm1 = class(TForm)
    IdTCPServer: TIdTCPServer;
    memMessages: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdTCPServerConnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
    fServerRunning : Boolean;
    oGis : TGIS_ViewerBMP ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}



procedure TForm1.FormDestroy(Sender: TObject);
begin
  //FreeObject( oGIS ) ;
  oGIS.Free
end;

procedure TForm1.IdTCPServerConnect(AContext: TIdContext);
begin
  memMessages.Lines.Add( 'Client connected' ) ;
  AContext.Connection.IoHandler.WriteLn('Welcome to TatukGIS ClientServer demo');
end;

procedure TForm1.IdTCPServerExecute(AContext: TIdContext);
var
  cmd  : String;
  strm : TMemoryStream ;
begin
  strm := TMemoryStream.Create ;
  try
    cmd := AContext.Connection.IoHandler.ReadLn;
    cmd := uppercase(cmd);
    if cmd = 'ZOOMIN' then
    begin
      oGIS.ZoomIn ;
      oGIS.Draw ;
      TBitmap(oGIS.Bitmap).SaveToStream( strm );
      AContext.Connection.IoHandler.Write( Integer(strm.Size) ) ;
      AContext.Connection.IoHandler.Write( strm ) ;
      memMessages.Lines.Add( 'ZOOMIN' ) ;
    end
    else if cmd = 'ZOOMOUT' then
    begin
      oGIS.ZoomOut ;
      oGIS.Draw ;
      TBitmap(oGIS.Bitmap).SaveToStream( strm );
      AContext.Connection.IoHandler.Write( Integer(strm.Size) ) ;
      AContext.Connection.IoHandler.Write( strm ) ;
      memMessages.Lines.Add( 'ZOOMOUT' ) ;
    end
    else if cmd = 'QUIT' then
    begin
      AContext.Connection.Disconnect;
      memMessages.Lines.Add( 'QUIT' ) ;
    end
    else begin // just draw
      oGIS.Draw ;
      TBitmap(oGIS.Bitmap).SaveToStream( strm );
      AContext.Connection.IoHandler.Write( Integer(strm.Size) ) ;
      AContext.Connection.IoHandler.Write( strm ) ;
      memMessages.Lines.Add( 'DRAW' ) ;
    end ;
  finally
    strm.Free ;
  end ;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  oGis := TGIS_ViewerBMP.Create ;
  oGis.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  oGis.RestrictedDrag := False ;
end;

end.

procedure TForm1.IdTCPServerExecute(AThread: TIdPeerThread);
begin
end;

procedure TForm1.IdTCPServerConnect(AThread: TIdPeerThread);
begin
  memMessages.Lines.Add( 'Client connected' ) ;
  AThread.Connection.WriteLn('Welcome to TatukGIS ClientServer demo');
end;




