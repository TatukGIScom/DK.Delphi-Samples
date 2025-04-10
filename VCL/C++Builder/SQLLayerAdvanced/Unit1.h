//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide SQL Layer advanced support.
//  Edit gistest.ttkls to provied your database access
//  You can use *.ttkls as any other layer (for example open in editor)
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp> 
#include <Vcl.ToolWin.hpp>
#include "Vcl.Graphics.hpp"
#include "Vcl.Controls.hpp"
#include "Vcl.Forms.hpp"
#include "Vcl.Dialogs.hpp"
#include "Vcl.ComCtrls.hpp"
#include "Vcl.Buttons.hpp"
#include "Vcl.StdCtrls.hpp"
#include "Vcl.ExtCtrls.hpp"
#include "Vcl.ImgList.hpp"
#include "GisInternals.hpp"
#include "GisTypesUI.hpp"
#include "GisLayerVectorSql.hpp"
#include "GisLayerSqlSqlite.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "Vcl.GisControlLegend.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *ToolButton2;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TPanel *Panel1;
	TButton *btnBuildLayer ;
	TButton *btnAttachTraceLog;
	TButton *btnLogging;
	TButton *btnOpenProject;
	TMemo *mmoLog;
	TButton *btnReadStyles;
	TComboBox *cbbStyles;
	TButton *btnApplyStyle;
	TButton *btnReadProjects;
	TComboBox *cbbProjects;
	TButton *btnGetProject;
	TButton *btnWriteStyles;
	TButton *btnWriteProject;
	TGIS_ControlLegend *GIS_ControlLegend1;
	TButton *btnWriteLayers;
	TGroupBox *grp1;
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnOpenProjectClick(TObject *Sender);
	void __fastcall btnWriteProjectClick(TObject *Sender);
	void __fastcall btnWriteStylesClick(TObject *Sender);
	void __fastcall btnReadStylesClick(TObject *Sender);
	void __fastcall btnLoggingClick(TObject *Sender);
	void __fastcall btnWriteLayersClick(TObject *Sender);
	void __fastcall btnApplyStyleClick(TObject *Sender);
	void __fastcall btnReadProjectsClick(TObject *Sender);
	void __fastcall btnGetProjectClick(TObject *Sender);
	void __fastcall btnAttachTraceLogClick(TObject *Sender);
	void __fastcall btnBuildLayerClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
private:	// User declarations
  String __fastcall getGISTESTPath( const bool _useLogging ) ;
  String currDir ;

public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	void __fastcall traceLog( const String S ) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
