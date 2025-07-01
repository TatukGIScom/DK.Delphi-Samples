//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to use Field Rules.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlAttributes"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnAddValidateClick(TObject *Sender)
{
  TGIS_FieldRule *r    ;
  TGIS_FieldInfo *fld  ;
  TGIS_Shape     *shp  ;

  if ( lv->FindField("email") == -1 ){
    lv->AddField( "email", TGIS_FieldType::String, 1, 0 ) ;
  }
  fld = lv->FieldInfo(1) ;
  r = new TGIS_FieldRule ;
  r->ValueChecks->Checks->Add(
    new TGIS_FieldValueCheck( TGIS_FieldValueCheckMode::AfterEdit,
                                 TGIS_FieldValueCheckFormula::Regex,
                                 EMAIL_REGEX,
                                 "Invalid email"
                                )
  ) ;
  FreeObjectNotNil( fld->Rules ) ;
  fld->Rules = r ;

  shp = lv->GetShape(1) ;
  shp->SetField( "email", "xyz@gmail.com" ) ;

  GIS_ControlAttributes1->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnSaveRulesClick(TObject *Sender)
{
  AnsiString str ;

  str = "myrules" ;
  TGIS_FieldRulesOperations::SaveFldx( str + GIS_FLDX_EXT, lv ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_Shape *shp  ;

  lv = new TGIS_LayerVector ;
  lv->Name = "test_rules" ;
  lv->Open() ;

  lv->AddField( "name", TGIS_FieldType::String, 1, 0 ) ;

  shp = lv->CreateShape( TGIS_ShapeType::Point ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( 20, 20 ) );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete lv ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btn2Click(TObject *Sender)
{
  TGIS_Shape *shp ;
  String str ;

  str = "myrules" ;

  TGIS_FieldRulesOperations::ParseFldx( ( str + GIS_FLDX_EXT ),
               lv ) ;

  shp = lv->GetShape(1) ;

  GIS_ControlAttributes1->ShowShape( shp );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddAliasClick(TObject *Sender)
{
  TGIS_FieldRule *r   ;
  TGIS_FieldInfo *fld  ;
  TGIS_Shape *shp  ;

  fld = lv->FieldInfo(0) ;
  r = new TGIS_FieldRule ;
  r->ValueAliases->Aliases->Add( new TGIS_FieldValueAlias( "Tommy", "Tom" ) ) ;

  FreeObjectNotNil( fld->Rules ) ;
  fld->Rules = r ;

  shp = lv->GetShape(1) ;
  shp->SetField( "name", "Tom" ) ;

  GIS_ControlAttributes1->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddCheckClick(TObject *Sender)
{
  TGIS_FieldRule *r ;
  TGIS_FieldInfo *fld ;
  TGIS_Shape *shp  ;

  fld = lv->FieldInfo(0) ;
  r = new TGIS_FieldRule ;
  r->ValueChecks->Checks->Add(
    new TGIS_FieldValueCheck( TGIS_FieldValueCheckMode::AfterEdit,
                                 TGIS_FieldValueCheckFormula::Required,
                                 "",
                                 "Cannot be null"
                                )
  ) ;
  FreeObjectNotNil( fld->Rules ) ;
  fld->Rules = r ;

  shp = lv->GetShape(1) ;
  shp->SetField( "name", "" ) ;

  GIS_ControlAttributes1->ShowShape( shp ) ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddDefaultClick(TObject *Sender)
{
  TGIS_FieldRule *r    ;
  TGIS_FieldInfo *fld  ;
  TGIS_Shape *shp ;

  fld = lv->FieldInfo(0) ;
  r = new TGIS_FieldRule ;
  r->Values->DefaultValue = "Diana" ;

  FreeObjectNotNil( fld->Rules ) ;
  fld->Rules = r ;

  shp = lv->CreateShape( TGIS_ShapeType::Point ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( 30, 20 ) );
  shp->SetFieldsDefaulRuleValue() ;

  GIS_ControlAttributes1->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddFieldClick(TObject *Sender)
{
  TGIS_Shape *shp ;

  shp = lv->GetShape(1) ;
  shp->SetField( "name", "Tom" ) ;

  GIS_ControlAttributes1->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddListClick(TObject *Sender)
{
  TGIS_FieldRule *r   ;
  TGIS_FieldInfo *fld  ;
  TGIS_Shape *shp  ;

  fld = lv->FieldInfo(0) ;
  r = new TGIS_FieldRule;
  r->Values->Mode = TGIS_FieldValuesMode::SelectList ;
  r->Values->Items->Add( "Ala"  ) ;
  r->Values->Items->Add( "Tom"  ) ;
  r->Values->Items->Add( "Boby" ) ;

  FreeObjectNotNil( fld->Rules ) ;
  fld->Rules = r ;

  shp = lv->GetShape(1) ;
  shp->SetField( "name", "Tom" ) ;

  GIS_ControlAttributes1->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

