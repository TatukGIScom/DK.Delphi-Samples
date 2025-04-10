//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to use field rules.
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  GisLayerVector,

  Vcl.GisControlAttributes,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS_ControlAttributes1: TGIS_ControlAttributes;
    btnAddAlias: TButton;
    btnAddCheck: TButton;
    btnAddList: TButton;
    btnAddField: TButton;
    btnAddValidate: TButton;
    btnAddDefault: TButton;
    btnSaveRules: TButton;
    btn2: TButton;
    procedure btnAddFieldClick(Sender: TObject);
    procedure btnAddAliasClick(Sender: TObject);
    procedure btnAddCheckClick(Sender: TObject);
    procedure btnAddListClick(Sender: TObject);
    procedure btnAddDefaultClick(Sender: TObject);
    procedure btnAddValidateClick(Sender: TObject);
    procedure btnSaveRulesClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    lv  : TGIS_LayerVector ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  //GisLicense,
  GisRtl,
  GisFieldRules,
  GisTypes,
  GisResource,
  GisFunctions,
  GisClasses ;

{$R *.DFM}

const
  EMAIL_REGEX = '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+';

procedure TForm1.btnAddValidateClick(Sender: TObject);
var
  r   : TGIS_FieldRule ;
  fld : TGIS_FieldInfo ;
  shp : TGIS_Shape ;
begin
  if lv.FindField('email') = -1 then begin
    lv.AddField( 'email', TGIS_FieldType.String, 1, 0 ) ;
    GIS_ControlAttributes1.Invalidate ;
  end;

  fld := lv.FieldInfo(1) ;
  r := TGIS_FieldRule.Create ;
  r.ValueChecks.Checks.Add(
    TGIS_FieldValueCheck.Create( TGIS_FieldValueCheckMode.AfterEdit,
                                 TGIS_FieldValueCheckFormula.Regex,
                                 EMAIL_REGEX,
                                 'Invalid email'
                                )
  ) ;
  FreeObjectNotNil( fld.Rules ) ;
  fld.Rules := r ;

  shp := lv.GetShape(1) ;
  shp.SetField( 'email', 'xyz@gmail.com' ) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnSaveRulesClick(Sender: TObject);
begin
  TGIS_FieldRulesOperations.SaveFldx( 'myrules' + GIS_FLDX_EXT, lv ) ;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  lv := TGIS_LayerVector.Create ;
  lv.Name := 'test_rules' ;
  lv.Open ;

  lv.AddField( 'name', TGIS_FieldType.String, 1, 0 ) ;

  shp := lv.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( GisPoint( 20, 20 ) );
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  TGIS_FieldRulesOperations.ParseFldx( 'myrules' + GIS_FLDX_EXT, lv ) ;

  shp := lv.GetShape(1) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnAddAliasClick(Sender: TObject);
var
  r   : TGIS_FieldRule ;
  fld : TGIS_FieldInfo ;
  shp : TGIS_Shape ;
begin
  fld := lv.FieldInfo(0) ;
  r := TGIS_FieldRule.Create ;
  r.ValueAliases.Aliases.Add( TGIS_FieldValueAlias.Create( 'Tommy', 'Tom' ) ) ;

  FreeObjectNotNil( fld.Rules ) ;
  fld.Rules := r ;

  shp := lv.GetShape(1) ;
  shp.SetField( 'name', 'Tom' ) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnAddCheckClick(Sender: TObject);
var
  r   : TGIS_FieldRule ;
  fld : TGIS_FieldInfo ;
  shp : TGIS_Shape ;
begin
  fld := lv.FieldInfo(0) ;
  r := TGIS_FieldRule.Create ;
  r.ValueChecks.Checks.Add(
    TGIS_FieldValueCheck.Create( TGIS_FieldValueCheckMode.AfterEdit,
                                 TGIS_FieldValueCheckFormula.Required,
                                 '',
                                 'Cannot be null'
                                )
  ) ;
  FreeObjectNotNil( fld.Rules ) ;
  fld.Rules := r ;

  shp := lv.GetShape(1) ;
  shp.SetField( 'name', '' ) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnAddDefaultClick(Sender: TObject);
var
  r   : TGIS_FieldRule ;
  fld : TGIS_FieldInfo ;
  shp : TGIS_Shape ;
begin
  fld := lv.FieldInfo(0) ;
  r := TGIS_FieldRule.Create ;
  r.Values.DefaultValue := 'Diana' ;

  FreeObjectNotNil( fld.Rules ) ;
  fld.Rules := r ;

  shp := lv.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( GisPoint( 30, 20 ) );
  shp.SetFieldsDefaulRuleValue ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnAddFieldClick(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  shp := lv.GetShape(1) ;
  shp.SetField( 'name', 'Tom' ) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

procedure TForm1.btnAddListClick(Sender: TObject);
var
  r   : TGIS_FieldRule ;
  fld : TGIS_FieldInfo ;
  shp : TGIS_Shape ;
begin
  fld := lv.FieldInfo(0) ;
  r := TGIS_FieldRule.Create ;
  r.Values.Mode := TGIS_FieldValuesMode.SelectList ;
  r.Values.Items.Add( 'Ala'  ) ;
  r.Values.Items.Add( 'Tom'  ) ;
  r.Values.Items.Add( 'Boby' ) ;

  FreeObjectNotNil( fld.Rules ) ;
  fld.Rules := r ;

  shp := lv.GetShape(1) ;
  shp.SetField( 'name', 'Tom' ) ;

  GIS_ControlAttributes1.ShowShape( shp ) ;
end;

end.
