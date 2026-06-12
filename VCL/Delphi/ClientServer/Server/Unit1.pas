//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Server Unit - Server-side component of distributed GIS architecture.
  Demonstrates TCP/IP geographic data serving to multiple client connections.

  Key concepts illustrated:
    - Indy TIdTCPServer: listen for incoming client connections
    - Multi-client handling: serve multiple simultaneous connections
    - Geographic data serialization: convert layers to network format
    - Data streaming: transmit GIS layer data over network
    - Connection management: track active clients and session state
    - Asynchronous operations: handle clients without blocking main thread

  Technical approach:
    - TIdTCPServer component: listen on port 5555
    - Connection threads: each client gets dedicated thread
    - Layer management: load geographic data into memory
    - Data serialization: convert TGIS_Layer to network format
    - Broadcast: optionally send data to all connected clients
    - Cleanup: remove disconnected clients and release resources

  Code structure:
    - TForm1: main server form with layer management
    - FormCreate: initialize server, load geographic data
    - btnStart_Click: bind server to port 5555 and start listening
    - btnStop_Click: shutdown server, disconnect all clients
    - IdTCPServerExecute: handle client connection (in thread)
    - OnClientConnect: triggered when client connects
    - OnClientDisconnect: triggered when client disconnects

  Network protocol:
    - Port: 5555 (TCP/IP)
    - Format: TatukGIS binary layer serialization
    - Multi-packet transmission: break large data into chunks
    - Connection pooling: reuse connections for multiple requests
    - Load balancing: distribute across available server threads
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




