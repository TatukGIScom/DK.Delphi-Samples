//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to add layer to the map.
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
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GISRegistredLayers.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisLayerVectorUDF.hpp"
#include "GisTypesUI.hpp"


//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TImageList *ImageList1;
	TStatusBar *StatusBar1;
	TToolBar *ToolBar1;
	TToolButton *btnFullExtent;
	TToolButton *ToolButton2;
	TToolButton *btnZoom;
	TToolButton *btnDrag;
	TToolButton *ToolButton1;
	TCheckBox *chkInMemory;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall chkInMemoryClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);

private:	// User declarations
	TGIS_BufferedFileStream *FUDF    ;
	String FUDFLine   ;
	TGIS_Tokenizer *tkn       ;
    Integer currUID   ;

	void __fastcall createUDFLayer() ;
	TGIS_Shape * __fastcall  createShape ()  ;
public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
	void __fastcall GetShapeGeometry(
		TObject * _sender,
		__int64 _uid,
    		Boolean _inMemory,
		Integer _cursor,
		TGIS_Shape * &_shp
	) ;	
	void __fastcall GetLayerExtent(
	  	TObject * _sender,
		TGIS_Extent  &_extent
	) ;
	void __fastcall GetShapeField(	
			TObject * _sender,
			String _field,
			__int64 _uid,
			Integer _cursor,
			Variant &_value
	) ;
	void __fastcall LayerMoveFirst(	
			TObject * _sender,
			int _cursor,
			const TGIS_Extent &_extent,
			String _query,
			TGIS_Shape * _shape,
			String _de9i,
			Boolean _skipDeleted
	) ;
	void __fastcall LayerEof(	
			TObject * _sender,
			Integer _cursor,
			Boolean & _eof
	) ;
	void __fastcall LayerMoveNext( 
			TObject * _sender,
			Integer _cursor
	) ;
	void __fastcall LayerGetStructure(
			TObject * _sender
	) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
