//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide basic Client-Server solution(Client side)
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <IdBaseComponent.hpp>
#include <IdComponent.hpp>
#include <IdTCPClient.hpp>
#include <IdTCPConnection.hpp>
#include <Vcl.ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TLabel *Label2;
	TEdit *edtHost;
	TLabel *Label3;
	TEdit *edtPort;
	TButton *btnConnect;
	TButton *btnDisconnect;
	TComboBox *cboCommands;
	TLabel *Label4;
	TButton *btnSendCommand;
	TIdTCPClient *IdTCPClient;
	TMemo *memMessages;
	TImage *Image1;
	void __fastcall btnDisconnectClick(TObject *Sender);
	void __fastcall btnConnectClick(TObject *Sender);
	void __fastcall btnSendCommandClick(TObject *Sender);
	void __fastcall IdTCPClientDisconnected(TObject *Sender);
	void __fastcall IdTCPClientConnected(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	void __fastcall LockControls( bool ALock );
	void __fastcall UpdateStatus() ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
