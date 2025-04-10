//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  SQLWizard Sample.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "formLayerSQL.h"
#define LAYERSQL_NATIVE            0
#define LAYERSQL_OPENGISBLOB       1
#define LAYERSQL_OPENGISBLOB2      2
#define LAYERSQL_GEOMEDIA          3
#define LAYERSQL_POSTGIS           4
#define LAYERSQL_PERSONALGDB       5
#define LAYERSQL_SDEBINARY         6
#define LAYERSQL_PIXELSTORE2       7
#define LAYERSQL_KATMAI            8
#define LAYERSQL_ORACLESPATIAL     9
#define LAYERSQL_SDERASTER         10
#define LAYERSQL_ORACLEGEORASTER   11
#define LAYERSQL_SPATIALWARE       12
#define LAYERSQL_DB2GSE            13
#define LAYERSQL_IFXSDB            14
#define LAYERSQL_FGDB              15
#define LAYERSQL_ORACLESPATIALPC   16
#define LAYERSQL_ORACLESPATIALTIN  17
#define LAYERSQL_GEOMEDIA_MSSQL    18
#define LAYERSQL_GEOMEDIA_SDO      19
#define LAYERSQL_ANYWHERE_SPATIAL  20
#define LAYERSQL_OGR               21

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmLayerSQL *frmLayerSQL;
//---------------------------------------------------------------------------
__fastcall TfrmLayerSQL::TfrmLayerSQL(TComponent* Owner)
    : TForm(Owner)
{
}


TStrings * __fastcall TfrmLayerSQL::prepareConnectString(const String _txt){

  TGIS_Tokenizer * tkn  ;
  TStrings *Result ;

  tkn = new TGIS_Tokenizer() ;
  try{
	tkn->ExecuteEx( _txt ) ;
	Result = new TStringList() ;
	Result->AddStrings( tkn->Result ) ;
	return Result ;
  }
  __finally{
    delete tkn ;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmLayerSQL::rbADOClick(TObject *Sender)
{
  if( rbADO->Checked ){
    lbPath->Visible = false ;
    btnPath->Visible = false ;
    lbConnectionStr->Visible = true ;
    btnBuild->Visible = true ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::rbFileGDBClick(TObject *Sender)
{
  if ( rbFileGDB->Checked ) {
    lbPath->Visible = true ;
    btnPath->Visible = true ;
    lbConnectionStr->Visible = false ;
    OpenDialog1->FilterIndex = 2 ;
	btnBuild->Visible = false ;
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_INI_LAYERSQL_FILEGDB ) ;
    cbDialectsChange( this ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::rbOGRClick(TObject *Sender)
{
  if( rbOGR->Checked ){
    lbPath->Visible = true ;
    btnPath->Visible = true ;
    lbConnectionStr->Visible = false ;
    OpenDialog1->FilterIndex = 3 ;
    btnBuild->Visible = false ;
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_INI_LAYERSQL_OGR ) ;
    cbDialectsChange( this ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::rbSQLiteClick(TObject *Sender)
{
if( rbSQLite->Checked ){
    lbPath->Visible = true ;
    btnPath->Visible = true ;
    lbConnectionStr->Visible = false ;
    btnBuild->Visible = false ;
    OpenDialog1->FilterIndex = 1 ;
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_SQLITE ) ;
    cbDialectsChange( this ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::treeLayersClick(TObject *Sender)
{
  TGIS_Layer *ll ;
  int i  ;

  if ( ( treeLayers->Selected != NULL ) && ( treeLayers->Selected->Level > 0 ) )
  {
    btnAddLayer->Enabled = true ;
    btnSaveFile->Enabled = true ;

    ll = getLayer( treeLayers->Selected->Text, int( treeLayers->Selected->Data ) ) ;
    try{
      memAdditional->Clear() ;
      if( ll->InheritsFrom( __classid( TGIS_LayerVectorSqlAbstract ))){
        for( i=0 ; i<=( (TGIS_LayerVectorSqlAbstract *)(ll))->SQLParametersEx->Count-1; i++ )
          memAdditional->Lines->Add(
              (( TGIS_LayerVectorSqlAbstract *)(ll))->SQLParametersEx[i].ToString() // + "="
          );
      }else if ( ll->InheritsFrom( __classid( TGIS_LayerPixelSqlAbstract ) ) ) {
        for ( i = 0 ; i <=( (TGIS_LayerPixelSqlAbstract *)(ll))->SQLParametersEx->Count-1 ; i++ )
          memAdditional->Lines->Add(
              ( ( TGIS_LayerPixelSqlAbstract *) (ll) )->SQLParametersEx[i].ToString() //+ "="
          ) ;
      }
    }__finally{
      delete ll ;
    }

    StatusBar1->SimpleText = "Selected layer : " + treeLayers->Selected->Text ;
  }
  else{
    btnAddLayer->Enabled = false ;
    btnSaveFile->Enabled = false ;
    StatusBar1->SimpleText = "" ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::fillTree( const String _name,
										TGIS_LayerInfoList *_ls,
										const int _type
									   )
{
  int i, m ;
  TTreeNode *tr;
  TTreeNode *tc;

  treeLayers->Items->BeginUpdate();
  try {
    tr = treeLayers->Items->AddNode( NULL, NULL, _name, NULL, naAdd ) ;
	tr->ImageIndex = ImgListObjectTypes->Count -1;
	tr->SelectedIndex = ImgListObjectTypes->Count -1;
	_ls->Sort() ;

	for( i = 0 ; i<= _ls->Count - 1 ; i++ ){
      tc = treeLayers->Items->AddChild( tr, (_ls->Items[ i ])->Name  );
      m  = int( _ls->Items[ i ]->ShapeType);
      if( m == - 1 ){
        m = ImgListObjectTypes->Count -1 ;
      }
      tc->ImageIndex = m ;
      tc->SelectedIndex = m ;
      tc->Data = ( TObject *)( _type ) ;
    }
    tr->Expanded = true ;
  }__finally{
    treeLayers->Items->EndUpdate();
  }
}


String __fastcall TfrmLayerSQL::prepareADONETCS(){
  TGIS_Tokenizer *tkn ;
  int i ;
  String Result ;

  tkn = new TGIS_Tokenizer ;
  try{
    tkn->Execute( cbConnStr->Text, L";", 1 ) ;
    Result = "" ;
    for( i = 0 ; i <= tkn->Result->Count - 1; i++ ){
      if ( ( tkn->Result->Names[i] == "Integrated Security"  ) ||
         ( tkn->Result->Names[i] == "Persist Security Info") ||
         ( tkn->Result->Names[i] == "User ID"              ) ||
         ( tkn->Result->Names[i] == "Initial Catalog"      ) ||
         ( tkn->Result->Names[i] == "Password"             ) ||
         ( tkn->Result->Names[i] == "Data Source"         ) ){

        Result = Result + tkn->Result[i].ToString() + ";" ;
      }
    }

    Result = Result + "MultipleActiveResultSets=True";
  }
  __finally{
    delete tkn ;
  }
  return Result ;
}

TStrings * __fastcall TfrmLayerSQL::prepareOCI(){

  TStrings * str ;
  TStrings * Result ;
  String s ;

  Result = new TStringList() ;
  str = prepareConnectString( cbConnStr->Text ) ;
  try{

    Result->Add( s.sprintf( L"%s=%s",GIS_INI_LAYERSQL_USER, str->Values["User ID"].c_str() ) );
    Result->Add( s.sprintf( L"%s=%s", GIS_INI_LAYERSQL_PASSWORD, str->Values["Password"].c_str() ) );
    Result->Add( s.sprintf( L"%s=%s", GIS_INI_LAYERSQL_DATABASE, str->Values["Data Source" ].c_str() ));
    return Result ;
  }
  __finally{
    delete str ;
  }
};

String __fastcall TfrmLayerSQL::getSQLPath(
                          const String _storage,
                          const String _name,
                          const bool _isRaster,
                          const bool _isOci,
                          const bool _isAdoNet
                         )
{
  int r ;
  TStrings *str ;
  String cs ;
  String cn ;
  String tmp ;
  String Result ;

  if( _isOci ){
    str = prepareConnectString( cbConnStr->Text ) ;

    Result =  tmp.sprintf( L"[%s]\n" , GIS_INI_LAYER_HEADER ) +
              tmp.sprintf( L"%s=%s\n", GIS_INI_LAYERSQL_STORAGE, _storage.c_str() ) +
              tmp.sprintf( L"%s=%s\n",  GIS_INI_LAYERSQL_DIALECT, cbDialects->Text.c_str() ) +
              tmp.sprintf( L"%s=%s\n",  "USER_NAME", str->Values["User ID"].c_str()  ) +
              tmp.sprintf( L"%s=%s\n",  "PASSWORD",  str->Values["Password"].c_str()  ) +
              tmp.sprintf( L"%s=%s\n",  "DATABASE",  str->Values["Data Source"].c_str() ) +
              tmp.sprintf( L"%s=%s\n", GIS_INI_LAYERSQL_LAYER, _name.c_str() ) ;
    delete str;
  }
  else{
    if (_isAdoNet)
      cs = prepareADONETCS();
    else if( rbFileGDB->Checked )
      cs = cbConnStr->Text;
    else
      cs = cbConnStr->Text ;

    if( rbSQLite->Checked )
      cn =  GIS_INI_LAYERSQL_CONNECTOR_SQLITE ;
    else if( _isAdoNet)
      cn = GIS_INI_LAYERSQL_CONNECTOR_ADONET ;
    else if ( ( rbFileGDB->Checked ) || ( rbOGR->Checked ) )
      cn = GIS_INI_PATH;
    else
      cn = GIS_INI_LAYERSQL_CONNECTOR_ADO ;

    tmp.sprintf( L"[%s]\n" , GIS_INI_LAYER_HEADER );
	tmp.sprintf( L"%s=%s\n", (tmp + GIS_INI_LAYERSQL_STORAGE).c_str(), _storage.c_str() );
	tmp.sprintf( L"%s=%s\n", (tmp + cn).c_str(), cs.c_str() );
	tmp.sprintf( L"%s=%s\n", (tmp + GIS_INI_LAYERSQL_DIALECT).c_str(), cbDialects->Text.c_str() );
	tmp.sprintf( L"%s=%s\n", (tmp + GIS_INI_LAYERSQL_LAYER).c_str(), _name.c_str() ) ;
    Result = tmp ;
  }

  for( r = 0 ; r <= memAdditional->Lines->Count - 1 ; r++ ){
    Result = Result + tmp.sprintf( L"\n%s=%s\n", memAdditional->Lines->Names[ r ].c_str(),
                                            memAdditional->Lines->ValueFromIndex[ r ].c_str() ) ;
  }
  if ( _isRaster )
    Result = Result + GIS_TTKPS_EXT ;
  else
    Result = Result + GIS_TTKLS_EXT ;

  return Result ;
}

TGIS_Layer * __fastcall TfrmLayerSQL::getLayer( const String _name, const int _type ){
  TGIS_Layer *Result ;

  switch( _type ){
    case LAYERSQL_NATIVE :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_NATIVE     , _name ) ) ;
      break ;
    case LAYERSQL_OPENGISBLOB     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB, _name ) ) ;
      break ;
    case LAYERSQL_OPENGISBLOB2     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB2, _name ) ) ;
      break ;
    case LAYERSQL_GEOMEDIA        :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIA   , _name ) ) ;
      break ;
    case LAYERSQL_POSTGIS         :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_POSTGIS    , _name ) ) ;
      break ;
    case LAYERSQL_PERSONALGDB     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_PERSONALGDB, _name ) ) ;
      break ;
    case LAYERSQL_SDEBINARY       :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SDEBINARY  , _name ) ) ;
      break ;
    case LAYERSQL_PIXELSTORE2     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_PIXELSTORE2, _name, True ) ) ;
      break ;
    case LAYERSQL_KATMAI          :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_KATMAI     , _name, False, False, True ) ) ;
      break ;
    case LAYERSQL_ORACLESPATIAL   :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL, _name, False, True ) ) ;
      break ;
    case LAYERSQL_SDERASTER       :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SDERASTER, _name, True ) ) ;
      break ;
    case LAYERSQL_ORACLEGEORASTER :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLEGEORASTER, _name, True, True ) ) ;
      break ;
    case LAYERSQL_SPATIALWARE     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_SPATIALWARE, _name ) ) ;
      break ;
    case LAYERSQL_DB2GSE     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_DB2GSE, _name ) ) ;
      break ;
    case LAYERSQL_IFXSDB     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_IFXSDB, _name ) ) ;
      break ;
    case LAYERSQL_FGDB     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_FILEGDB, _name ) ) ;
      break ;
    case LAYERSQL_ORACLESPATIALPC     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_PC, _name, False, True ) ) ;
      break ;
    case LAYERSQL_ORACLESPATIALTIN     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN, _name, False, True ) ) ;
      break ;
    case LAYERSQL_GEOMEDIA_MSSQL        :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL, _name, False, False, True ) ) ;
      break ;
    case LAYERSQL_GEOMEDIA_SDO        :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL, _name, False, True ) ) ;
      break ;
    case LAYERSQL_ANYWHERE_SPATIAL     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_ANYWHERESPATIAL, _name ) ) ;
      break ;
    case LAYERSQL_OGR     :
      Result = GisCreateLayer( _name, getSQLPath( GIS_INI_LAYERSQL_OGR, _name ) ) ;
      break ;
    default :
      Result = NULL ;
      break ;
  }
  return Result ;
}

void __fastcall TfrmLayerSQL::addNewLayer( const String _name, const int _type )
{
TGIS_Layer *ll  ;

  ll = getLayer( _name, _type ) ;
  if ( ll != NULL){
    try{
      ll->Open() ;
      Form1->GIS->Add( ll ) ;
    }
    catch(Exception& e){
      delete ll ;
      ShowMessage( e.Message ) ;
    }
  }
}
void __fastcall TfrmLayerSQL::btnAddLayerClick(TObject *Sender)
{
  TTreeNode *tr ;

  tr = treeLayers->Items->GetFirstNode() ;
  while ( tr != NULL ){
    if( tr->Level > 0 ){
      if ( tr->Selected )
        addNewLayer( tr->Text, int( tr->Data ) );
    }

    tr = tr->GetNext() ;
  }
  if ( Form1->GIS->Items->Count == 1 ){
    Form1->GIS->FullExtent();
  }
  else{
    Form1->GIS->InvalidateWholeMap() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::btnBuildClick(TObject *Sender)
{
  cbConnStr->Text =  PromptDataSource( (unsigned int)(Handle), cbConnStr->Text);

  if ( Pos( "SQLOLEDB", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_MSSQL );
  else if ( Pos( "SQLNCLI", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_MSSQL );
  else if ( Pos( "MSDAORA", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_ORACLE );
  else if ( Pos( "ORACLE", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_ORACLE );
  else if ( Pos( "POSTGRES", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_POSTGRESQL );
  else if ( Pos( "ACE", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_MSJET );
  else if ( Pos( "JET", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_MSJET );
  else if ( Pos( "MS ACCESS", UpperCase(cbConnStr->Text) ) >= 1 )
    cbDialects->ItemIndex = cbDialects->Items->IndexOf( GIS_SQL_DIALECT_NAME_MSJET ) ;

  cbDialectsChange( this );
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::btnCancelClick(TObject *Sender)
{
  Close() ;
}
//---------------------------------------------------------------------------

bool __fastcall TfrmLayerSQL::canUseStorage( const AnsiString _type ){
  bool Result = true ;

  if( ( cbStorage->Text == "" ) || ( cbStorage->Text == "*" ) ) return Result;

  Result = ( cbStorage->Text.UpperCase() ) == ( _type.UpperCase() );
  return Result ;
}

bool __fastcall TfrmLayerSQL::canUseDialect( const String _type ){
  bool Result ;

  Result = ( cbDialects->Text.UpperCase() ) == _type.UpperCase() ;
  return Result ;
}

void __fastcall TfrmLayerSQL::btnConnectClick(TObject *Sender)
{
  TGIS_LayerInfoList *ls ;
  TGIS_LayerVectorSqlAbstract *lv ;
  TGIS_LayerPixelSqlAbstract *lp ;
  String lname ;
  TGIS_LayerFGDB *lf ;
  TGIS_LayerOGR *lo ;

  if ( ( cbConnStr->Text == "" ) || ( cbDialects->Text == "" ) ){
    ShowMessage( "Fill database parameters first." ) ;
    return ;
  }

  lname = "test";
  treeLayers->Items->Clear();
  memAdditional->Lines->Clear() ;

  if ( canUseStorage( GIS_INI_LAYERSQL_NATIVE ) ){
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_NATIVE, lname ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Native",
                    ls,
                    LAYERSQL_NATIVE );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if ( canUseStorage( GIS_INI_LAYERSQL_OPENGISBLOB ) ){
    // OpenGIS
    lv =( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB, lname ) )
          ) ;
    if( lv != NULL) {
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "OpenGIS", ls, LAYERSQL_OPENGISBLOB );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }
  else if( canUseStorage( GIS_INI_LAYERSQL_OPENGISBLOB2  ) ){
    // OpenGIS
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_OPENGISBLOB2, lname ) )
          ) ;
    if ( lv != NULL){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "OpenGIS", ls, LAYERSQL_OPENGISBLOB2 );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_PIXELSTORE2 ) ){
    // PixelStore 2
    lp = ( TGIS_LayerPixelSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_PIXELSTORE2, lname, true ) )
          ) ;
    if ( lp != NULL ){
      try{
        ls = lp->GetAvailableLayers() ;
        try{
          fillTree( "PixelStore", ls, LAYERSQL_PIXELSTORE2 );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lp;
      }
    }
  }

  if ( ( canUseStorage( GIS_INI_LAYERSQL_GEOMEDIA ) ) &&
     ( canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL  ) ) ||
     ( canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) ) ||
     ( canUseDialect( GIS_SQL_DIALECT_NAME_MSJET  ) ) )
     {
    // Geomedia
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIA, lname ) )
          ) ;
    if ( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Geomedia", ls, LAYERSQL_GEOMEDIA );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( ( canUseStorage( GIS_INI_LAYERSQL_PERSONALGDB ) ) &&
     ( canUseDialect( GIS_SQL_DIALECT_NAME_MSJET ) ) )
  {
    // Personal GDB
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_PERSONALGDB, lname ) )
          ) ;
    if( lv != NULL )
    {
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Personal GDB", ls, LAYERSQL_PERSONALGDB );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }__finally{
        delete lv;
      }
    }
  }

  if ( ( canUseStorage( GIS_INI_LAYERSQL_POSTGIS ) )  &&
     ( canUseDialect( GIS_SQL_DIALECT_NAME_POSTGRESQL ) ) )
  {
    // PostGIS
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_POSTGIS, lname ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "PostGIS", ls, LAYERSQL_POSTGIS );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( (canUseStorage( GIS_INI_LAYERSQL_SDEBINARY ) ||
      canUseStorage( GIS_INI_LAYERSQL_SDEOGCWKB )) &&
     (canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL  ) ||
      canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE )) ) {
    // SDE
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SDEBINARY, lname ) )
          ) ;
    if ( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "ArcSDE Vector", ls, LAYERSQL_SDEBINARY );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_SDERASTER ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) )
  {
    lp = ( TGIS_LayerPixelSqlAbstract *) (
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SDERASTER, lname, true ) )
          ) ;
    if ( lp != NULL ){
      try {
        ls = lp->GetAvailableLayers() ;
        try{
          fillTree( "ArcSDE Raster", ls, LAYERSQL_SDERASTER );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lp ;
      }
    }
  }

  if ( canUseStorage( GIS_INI_LAYERSQL_KATMAI ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) )
  {
    // MsSqlSpatial
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_KATMAI, lname, false, false, true ) )
          ) ;
    if ( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "MsSql Spatial", ls, LAYERSQL_KATMAI );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_SPATIALWARE ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) )
  {
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_SPATIALWARE, lname ) )
          ) ;
    if ( lv != NULL ){
      try
      {
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "SpatialWare", ls, LAYERSQL_SPATIALWARE );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if ( canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) )
  {
    // Oracle Spatial
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL, lname, false, true ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Oracle Spatial", ls, LAYERSQL_ORACLESPATIAL );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_ORACLEGEORASTER ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) )
  {
    // Oracle Georaster
    lp = ( TGIS_LayerPixelSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLEGEORASTER, lname, True, True ) )
          ) ;
    if ( lp != NULL ){
      try{
        ls = lp->GetAvailableLayers() ;
        try{
          fillTree( "Oracle Georaster", ls, LAYERSQL_ORACLEGEORASTER );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lp;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_DB2GSE ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_DB2 ) ){
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_DB2GSE, lname ) )
          ) ;
    if ( lv != NULL){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "DB2 Spatial Extender", ls, LAYERSQL_DB2GSE );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if ( canUseStorage( GIS_INI_LAYERSQL_IFXSDB ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_INFORMIX ) ){
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_IFXSDB, lname ) )
          ) ;
    if( lv != NULL){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "IFX Spatial Data Blade", ls, LAYERSQL_IFXSDB );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_FILEGDB ) &&
     canUseDialect( GIS_INI_LAYERSQL_FILEGDB ) ) {
    lf = new TGIS_LayerFGDB();
    try{
      lf->Path = cbConnStr->Text ;
      ls = lf->GetAvailableLayers() ;
      try{
        fillTree( GIS_INI_LAYERSQL_FILEGDB, ls, LAYERSQL_FGDB );
      }
      __finally{
        FreeObjectNotNil( ls );
      }
    }
    __finally{
      delete lf;
    }
  }


  if( canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL_PC ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ) )
  {
    // Oracle Spatial
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_PC, lname, False, True ) )
          ) ;
    if( lv != NULL){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Oracle Spatial PC", ls, LAYERSQL_ORACLESPATIALPC );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ))
  {
    // Oracle Spatial
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN, lname, False, True ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Oracle Spatial TIN", ls, LAYERSQL_ORACLESPATIALTIN );
        }__finally{
          FreeObjectNotNil( ls );
        }
      }__finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL ) &&
   canUseDialect( GIS_SQL_DIALECT_NAME_MSSQL ) )
   {
    lv =( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL, lname, False, False, True ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Geomedia MsSpatial", ls, LAYERSQL_GEOMEDIA_MSSQL );
        }__finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_ORACLE ))
  {
    // Oracle Spatial
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL, lname, False, True ) )
          ) ;
    if ( lv != NULL){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
          fillTree( "Geomedia Oracle Spatial", ls, LAYERSQL_GEOMEDIA_SDO );
        }__finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_ANYWHERESPATIAL ) &&
     canUseDialect( GIS_SQL_DIALECT_NAME_SYBASE ) )

  {
    lv = ( TGIS_LayerVectorSqlAbstract *)(
            GisCreateLayer( lname, getSQLPath( GIS_INI_LAYERSQL_ANYWHERESPATIAL, lname ) )
          ) ;
    if( lv != NULL ){
      try{
        ls = lv->GetAvailableLayers() ;
        try{
		  fillTree( "Anywhere Spatial", ls, LAYERSQL_ANYWHERE_SPATIAL );
        }
        __finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lv;
      }
    }
  }

  if( canUseStorage( GIS_INI_LAYERSQL_OGR ) &&
     canUseDialect( GIS_INI_LAYERSQL_OGR ) )
  {
    lo = new TGIS_LayerOGR() ;
      try{
        lo->Path = cbConnStr->Text ;
        ls = lo->GetAvailableLayers() ;
        try{
		  fillTree( GIS_INI_LAYERSQL_OGR, ls, LAYERSQL_OGR );
        }__finally{
          FreeObjectNotNil( ls );
        }
      }
      __finally{
        delete lo;
      }
  }


}
//---------------------------------------------------------------------------

String __fastcall TfrmLayerSQL::BrowseDialog(){

  String Result ;
  String sdir ;
  bool bexecuted ;
  TFileOpenDialog *dlg ;

  sdir = "c:\\" ;
  Result = "" ;
  bexecuted = false ;

  int winver ;
  #if (__CODEGEARC__ >= 0x0740)
	winver = Win32MajorVersion() ;
  #else
	winver = Win32MajorVersion ;
  #endif
  
  if( winver >= 6 ){
    dlg = new TFileOpenDialog(NULL);
    try{
      dlg->Options << fdoPickFolders << fdoPathMustExist << fdoForceFileSystem ;
      dlg->DefaultFolder = sdir;
      if( dlg->Execute() ){
        bexecuted = true ;
        sdir = dlg->FileName;
      }
    }__finally{
      delete dlg ;
    }
  }
  else{
    if( SelectDirectory( "", ExtractFileDrive(sdir), sdir, TSelectDirExtOpts()<<sdNewUI ) ){
      bexecuted = true ;
    }
  }
  if( bexecuted ){
     Result = sdir ;
  }
  return Result ;
}

void __fastcall TfrmLayerSQL::btnPathClick(TObject *Sender)
{
  String path ;

  if( rbFileGDB->Checked ){
    path = BrowseDialog() ;

    if( path != "" ){
      cbConnStr->Text = path ;
    }
  }
  else{
    if( !OpenDialog1->Execute() ) {
      return ;
    }

    cbConnStr->Text = OpenDialog1->FileName ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::btnSaveFileClick(TObject *Sender)
{
  String layername ;
  String ttklspath ;
  String storage   ;
  TGIS_Config  *ini ;
  int p ;
  TStrings *str ;
  int lt ;
  bool isttkps ;

  if( ( treeLayers->Selected == NULL) || ( treeLayers->Selected->Level == 0 ) )
  {
    ShowMessage( "Select a layer from the list first." ) ;
    return ;
  }

  lt = int( treeLayers->Selected->Data ) ;
  isttkps = ( ( lt = LAYERSQL_PIXELSTORE2 ) || ( lt = LAYERSQL_SDERASTER ) ||
             ( lt = LAYERSQL_ORACLEGEORASTER ) );

  if( isttkps ){
    SaveDialog1->FilterIndex = 2 ;
  }
  else{
    SaveDialog1->FilterIndex = 1 ;
  }

  if( SaveDialog1->Execute() ){

    ttklspath = SaveDialog1->FileName ;

    layername = treeLayers->Selected->Text ;

    switch( lt ) {
      case LAYERSQL_NATIVE           : storage = GIS_INI_LAYERSQL_NATIVE ;
      case LAYERSQL_OPENGISBLOB      : storage = GIS_INI_LAYERSQL_OPENGISBLOB ;
      case LAYERSQL_OPENGISBLOB2     : storage = GIS_INI_LAYERSQL_OPENGISBLOB2 ;
      case LAYERSQL_GEOMEDIA         : storage = GIS_INI_LAYERSQL_GEOMEDIA ;
      case LAYERSQL_POSTGIS          : storage = GIS_INI_LAYERSQL_POSTGIS ;
      case LAYERSQL_PERSONALGDB      : storage = GIS_INI_LAYERSQL_PERSONALGDB ;
      case LAYERSQL_SDEBINARY        : storage = GIS_INI_LAYERSQL_SDEBINARY ;
      case LAYERSQL_PIXELSTORE2      : storage = GIS_INI_LAYERSQL_PIXELSTORE2 ;
      case LAYERSQL_KATMAI           : storage = GIS_INI_LAYERSQL_KATMAI ;
      case LAYERSQL_ORACLESPATIAL    : storage = GIS_INI_LAYERSQL_ORACLESPATIAL ;
      case LAYERSQL_SDERASTER        : storage = GIS_INI_LAYERSQL_SDERASTER ;
      case LAYERSQL_ORACLEGEORASTER  : storage = GIS_INI_LAYERSQL_ORACLEGEORASTER ;
      case LAYERSQL_SPATIALWARE      : storage = GIS_INI_LAYERSQL_SPATIALWARE ;
      case LAYERSQL_DB2GSE           : storage = GIS_INI_LAYERSQL_DB2GSE ;
      case LAYERSQL_IFXSDB           : storage = GIS_INI_LAYERSQL_IFXSDB ;
      case LAYERSQL_FGDB             : storage = GIS_INI_LAYERSQL_FILEGDB ;
      case LAYERSQL_OGR              : storage = GIS_INI_LAYERSQL_OGR ;
      case LAYERSQL_ORACLESPATIALPC  : storage = GIS_INI_LAYERSQL_ORACLESPATIAL_PC ;
      case LAYERSQL_ORACLESPATIALTIN : storage = GIS_INI_LAYERSQL_ORACLESPATIAL_TIN ;
      case LAYERSQL_ANYWHERE_SPATIAL : storage = GIS_INI_LAYERSQL_ANYWHERESPATIAL ;
      default                        :  storage = GIS_INI_LAYERSQL_NATIVE ;
    }

    ini = TGIS_ConfigFactory::CreateConfig( NULL, ttklspath ) ;
    try{
      ini->Section = GIS_INI_LAYER_HEADER ;
      ini->WriteString( GIS_INI_LAYERSQL_STORAGE,
                       storage,
                       ""
                     ) ;
      ini->WriteString( GIS_INI_LAYERSQL_LAYER,
                       layername,
                       ""
                     ) ;
      ini->WriteString( GIS_INI_LAYERSQL_DIALECT,
                       cbDialects->Text,
                       ""
                     ) ;
      if( storage == GIS_INI_LAYERSQL_KATMAI ){
        ini->WriteString( ini->Section, GIS_INI_LAYERSQL_CONNECTOR_ADONET,
                                 prepareADONETCS()
                               );
      }
      else if( storage == GIS_INI_LAYERSQL_ORACLESPATIAL ){
        str = prepareOCI() ;
        try{
          for( p = 0 ; p<= str->Count - 1 ; p ++){
            ini->WriteString( str->Names[ p ], str->ValueFromIndex[ p ], "" ) ;
          }
        }
        __finally{
          delete str ;
        }
      }
      else{
        if( rbSQLite->Checked ){
          ini->WriteString( ini->Section, GIS_INI_LAYERSQL_CONNECTOR_SQLITE,
                                  GetPathRelative( GetFilePath( ttklspath ),
                                                   cbConnStr->Text
                                                  )
                                );
        }
        else if(( rbFileGDB->Checked ) || ( rbOGR->Checked ))
        {
          ini->WriteString( ini->Section, GIS_INI_PATH,
                                  GetPathRelative( GetFilePath( ttklspath ),
                                                   cbConnStr->Text
                                                  )
                                );
        }
        else{
          ini->WriteString( ini->Section, GIS_INI_LAYERSQL_CONNECTOR_ADO,
                                  cbConnStr->Text
                                ) ;
        }
      }

      for( p = 0 ; p <= memAdditional->Lines->Count - 1; p++ ){
        ini->WriteString( memAdditional->Lines->Names[ p ],
                         memAdditional->Lines->ValueFromIndex[ p ], "" ) ;
      }
    }
    __finally{
      ini->Save() ;
      delete ini ;
    }
  }
}

//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::cbConnStrChange(TObject *Sender)
{
  int i ;

  i = cbConnStr->ItemIndex ;

  if (i < 0) return ;

  cbConnStr->Hint = cbConnStr->Items[ cbConnStr->ItemIndex ].ToString() ;
}

//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::cbConnStrKeyPress(TObject *Sender, System::WideChar &Key)
{

  if( ( ( Key >= 'a' ) && ( Key <= 'z' ) ) || ( ( Key>='0' ) && ( Key<='9' ) ) )  {
    cbConnStr->Hint = "" ;
  }

}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::cbDialectsChange(TObject *Sender)
{
 cbStorage->Items->Clear() ;

  if( cbDialects->Text == GIS_SQL_DIALECT_NAME_FGDB ){
    cbStorage->Items->Add( GIS_INI_LAYERSQL_FILEGDB );
  }
  else if( cbDialects->Text == GIS_INI_LAYERSQL_OGR ){
    cbStorage->Items->Add( GIS_INI_LAYERSQL_OGR );
  }
  else{
    cbStorage->Items->Add( "*"                                ) ;
    cbStorage->Items->Add( GIS_INI_LAYERSQL_NATIVE            ) ;
    cbStorage->Items->Add( GIS_INI_LAYERSQL_OPENGISBLOB       ) ;
    cbStorage->Items->Add( GIS_INI_LAYERSQL_OPENGISBLOB2      ) ;
    cbStorage->Items->Add( GIS_INI_LAYERSQL_PIXELSTORE2       ) ;

    if( cbDialects->Text == GIS_SQL_DIALECT_NAME_ORACLE )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLEGEORASTER     ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL       ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL_PC    ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN   ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_SDEBINARY           ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_SDERASTER           ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_POSTGRESQL ){
      cbStorage->Items->Add( GIS_INI_LAYERSQL_POSTGIS             ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_MSSQL )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIA            ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL   ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_KATMAI              ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_SDEBINARY           ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_SDERASTER           ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_SPATIALWARE         ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_DB2 )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_DB2GSE              ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_INFORMIX )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_IFXSDB              ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_SYBASE )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_ANYWHERESPATIAL     ) ;
    }
    else if( cbDialects->Text == GIS_SQL_DIALECT_NAME_MSJET )
    {
      cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIA            ) ;
      cbStorage->Items->Add( GIS_INI_LAYERSQL_PERSONALGDB         ) ;
    }
  }

  cbStorage->ItemIndex = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::FormCreate(TObject *Sender)
{
  cbDialects->Items->Clear();
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_ADVANTAGE    ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_BLACKFISHSQL ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_DB2          ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_FGDB         ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_INFORMIX     ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_INTERBASE    ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_MSJET        ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_MSSQL        ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_MYSQL        ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_NEXUSDB      ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_ORACLE       ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_POSTGRESQL   ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_SAPDB        ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_SQLITE       ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_SYBASE       ) ;
  cbDialects->Items->Add( GIS_SQL_DIALECT_NAME_INTERSYSTEMS ) ;
  cbDialects->Items->Add( GIS_INI_LAYERSQL_OGR              ) ;

  cbStorage->Items->Clear() ;
  cbStorage->Items->Add( "*"                                    ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_ANYWHERESPATIAL       ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_DB2GSE                ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_FILEGDB               ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIA              ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIAMSSPATIAL     ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_GEOMEDIAORACLESPATIAL ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_IFXSDB                ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_KATMAI                ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_NATIVE                ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_OPENGISBLOB           ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_OPENGISBLOB2          ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLEGEORASTER       ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL         ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL_PC      ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_ORACLESPATIAL_TIN     ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_PERSONALGDB           ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_PIXELSTORE2           ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_POSTGIS               ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_SDEBINARY             ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_SDERASTER             ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_SPATIALWARE           ) ;
  cbStorage->Items->Add( GIS_INI_LAYERSQL_OGR                   ) ;

  cbStorage->ItemIndex = 0 ;

  cbConnStr->Text    = "" ;

  memAdditional->Clear() ;
  treeLayers->Items->Clear() ;

  btnAddLayer->Enabled = false ;
  btnSaveFile->Enabled = false ;


  if( cbConnStr->Items->Count > 0 ) {
    cbConnStr->ItemIndex = 0 ;
    cbConnStrChange( this ) ;
  }
}

//---------------------------------------------------------------------------

void __fastcall TfrmLayerSQL::FormKeyDown(TObject *Sender, WORD &Key, TShiftState Shift)
{
  if( Key == VK_ESCAPE ){
     ModalResult = mrCancel ;
  }
}
//---------------------------------------------------------------------------

