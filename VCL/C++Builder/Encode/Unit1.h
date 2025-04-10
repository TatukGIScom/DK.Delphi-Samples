//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to encode SHP Layer
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------


#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS;
        TToolBar *ToolBar1;
        TButton *btnCloseAll;
        TButton *btnOpenBase;
        TButton *btnEncode;
        TButton *btnOpenEncoded;
        TStatusBar *StatusBar1;
        void __fastcall btnCloseAllClick(TObject *Sender);
        void __fastcall btnOpenBaseClick(TObject *Sender);
        void __fastcall btnEncodeClick(TObject *Sender);
        void __fastcall btnOpenEncodedClick(TObject *Sender);
private:	// User declarations
        void __fastcall doRead( TObject * _sender, int _pos, void *_buffer, int _count ) ;
	void __fastcall doWrite( TObject * _sender, int _pos, void *_buffer, int _count ) ; ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
