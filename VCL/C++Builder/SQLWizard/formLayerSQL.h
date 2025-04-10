//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  SQLWizard Sample.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef formLayerSQLH
#define formLayerSQLH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ImgList.hpp>
#include "FileCtrl.hpp"
#include "Data.Win.AdoConEd.hpp"
#include "WinApi.ShellAPI.hpp"
#include "WinApi.ShlObj.hpp"
#include "Shlobj.h"
#include "GisLayerVectorSql.hpp"
#include "GisLayerPixelSql.hpp"
#include "GislayerFGDB.hpp"
#include "GisLayerOGR.hpp"
#include "GisInternals.hpp"
#include "GisResource.hpp"
#include "GisConfig.hpp"
#include "GisFunctions.hpp"
#include "GisClasses.hpp"
#include "GisRegistredLayers.hpp"
#include "GisRtl.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
class TfrmLayerSQL : public TForm
{
  __published: // IDE-managed Components
    TLabel* lbConnectionStr;
    TButton* btnBuild;
    TLabel* lbDialect;
    TComboBox* cbDialects;
    TTreeView* treeLayers;
    TImageList* ImgListObjectTypes;
    TGroupBox* GroupBox1;
    TGroupBox* GroupBox2;
    TSaveDialog* SaveDialog1;
    TButton* btnSaveFile;
    TButton* btnAddLayer;
    TButton* btnCancel;
    TButton* btnHelp;
    TComboBox* cbStorage;
    TLabel* Label4;
    TButton* btnConnect;
    TLabel* Label3;
    TMemo* memAdditional;
    TStatusBar* StatusBar1;
    TComboBox* cbConnStr;
    TRadioButton* rbADO;
    TRadioButton* rbSQLite;
    TLabel* lbPath;
    TButton* btnPath;
    TOpenDialog* OpenDialog1;
    TRadioButton* rbFileGDB;
    TRadioButton* rbOGR;
    void __fastcall rbADOClick(TObject* Sender);
    void __fastcall rbFileGDBClick(TObject* Sender);
    void __fastcall rbOGRClick(TObject* Sender);
    void __fastcall rbSQLiteClick(TObject* Sender);
    void __fastcall treeLayersClick(TObject* Sender);
    void __fastcall btnAddLayerClick(TObject* Sender);
    void __fastcall btnBuildClick(TObject* Sender);
    void __fastcall btnCancelClick(TObject* Sender);
    void __fastcall btnConnectClick(TObject* Sender);
    void __fastcall btnPathClick(TObject* Sender);
    void __fastcall btnSaveFileClick(TObject* Sender);
    void __fastcall cbConnStrChange(TObject* Sender);
    void __fastcall cbConnStrKeyPress(TObject* Sender, System::WideChar &Key);
    void __fastcall cbDialectsChange(TObject* Sender);
    void __fastcall FormCreate(TObject* Sender);
    void __fastcall FormKeyDown(TObject* Sender, WORD &Key, TShiftState Shift);
  private: // User declarations
    TStrings* __fastcall prepareConnectString(const String _txt);
    String __fastcall prepareADONETCS();
    TStrings* __fastcall prepareOCI();
    String __fastcall getSQLPath(const String _storage, const String _name,
        const bool _isRaster = false, const bool _isOci = false,
        const bool _isAdoNet = false);
    void __fastcall fillTree(
        const String _name, TGIS_LayerInfoList* _ls, const int _type);
    void __fastcall addNewLayer(const String _name, const int _type);
    TGIS_Layer* __fastcall getLayer(const String _name, const int _type);
    String __fastcall BrowseDialog();
    bool __fastcall canUseStorage(const AnsiString _type);
    bool __fastcall canUseDialect(const String _type);
  public: // User declarations
    __fastcall TfrmLayerSQL(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmLayerSQL* frmLayerSQL;
//---------------------------------------------------------------------------
#endif

