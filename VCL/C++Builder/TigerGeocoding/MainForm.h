//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
#include <Grids.hpp>
#include <Menus.hpp>
#include <ToolWin.hpp>
#include <Clipbrd.hpp>
#include <DB.hpp>
#include "MatchesForm.h"
#include "InfoForm.h"
#include "HelpForm.h"
#include "VCL.GisControlScale.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisGeocoding.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS;
        TButton *btnFindFirst;
        TButton *btnFindAll ;
        TButton *btnHelp ;
        TButton *btnMatches ;
        TProgressBar *ProgressBar1;
        TGIS_ControlScale *GIS_ControlScale1;
        TEdit *edtAddress;
        TStringGrid *sgrdMemo;
        TPopupMenu *popupMenu1;
        TPopupMenu *popupMenu2;
        TOpenDialog *OpenDialog1;
        TCheckBox *chkExtended;
        TToolBar *ToolBar1;
        TPanel *Panel2;
        TGroupBox *gbxFind;

        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormDestroy(TObject *Sender);
        void __fastcall sgrdMemoContextPopup(TObject *Sender,
          TPoint &MousePos, bool &Handled);
        void __fastcall sgrdMemoDblClick(TObject *Sender);
        void __fastcall sgrdMemoSelectCell(TObject *Sender, int ACol,
          int ARow, bool &CanSelect);
        void __fastcall btnOpenDefaultClick(TObject *Sender);
        void __fastcall btnOpenClick(TObject *Sender);
        void __fastcall btnHelpClick(TObject *Sender);
        void __fastcall btnFindFirstClick(TObject *Sender);
        void __fastcall btnFindAllClick(TObject *Sender);
        void __fastcall btnMatchesClick(TObject *Sender);
        void __fastcall mnuCopyClick(TObject *Sender);
        void __fastcall mnuCopyvalueClick(TObject *Sender);
        void __fastcall sgrdMemoClick(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
private:	// User declarations
    TGIS_LayerVector *layerSrc     ;
    TGIS_LayerVector *layerResult  ;
    TGIS_Geocoding   *geoObj       ;
    TStrings         *infoFields   ;
    TStrings         *fieldNames   ;
    Integer           selectedRow  ;
    Integer           popupMenuRow ;
    Integer           state        ;
    bool              doAbort      ;
    bool              fShown       ;
    void showInfo     () ;
    void hideInfo     () ;
    int parse         ( bool _findFirst     ,
                        bool _extendedScope
                      ) ;
    void findAddress  ( bool _findFirst     ,
                        bool _extendedScope
                      );
    String getResultInfo( const String _query ) ;
	void openCoverage  ( const String _path )  ;
	void _fastcall OnBusy(TObject * _sender, int _pos,
          const int _end, bool &_abort);
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
