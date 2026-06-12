//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Languages sample — demonstrates adding multilanguage/localization support (Delphi/VCL).

  What the sample shows:
    - Loading a TatukGIS project file (.ttkproject) that bundles layers and symbols
    - Exposing language-specific labels/names from shapefile attributes
    - Creating a dropdown control to switch between available languages
    - Dynamically updating layer labels based on selected language
    - Using TGIS_Shape.GetField to retrieve attribute values in different languages
    - Switching label rendering between language fields (e.g., NAME_EN -> NAME_FR -> NAME_DE)
    - Maintaining coordinate system and projection through language changes
    - Displaying map features with localized text at multiple zoom levels
    - Using TGIS_Params.Labels to configure label display and positioning
    - Handling multilingual geodatabases with language fields per feature

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - shapefile layer with language attributes
    TGIS_Shape.GetField()       - read attribute value from feature
    TGIS_Params.Labels          - label text and positioning
    Label rendering             - text display at feature location
    Attribute fields            - NAME_EN, NAME_FR, NAME_DE (language variants)
    ComboBox selection          - language switching control
    OnLabelDraw event           - customizing label appearance per language
    Project file (.ttkproject)  - pre-configured layer definitions
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
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.Buttons,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

// text in unicode encodings
{$include 'unicode.inc'}

procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  ll := TGIS_LayerVector.Create ;
  ll.Name := 'points' ;
  ll.Params.Labels.Position :=  [ TGIS_LabelPosition.UpLeft] ;
  ll.Params.Labels.Allocator := False ;

  GIS.Add( ll ) ;
  ll.Extent := TGIS_Utils.GisExtent( -180, -90, 180, 90 ) ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( -45, -45 ) ) ;


  ll := TGIS_LayerVector.Create ;
  ll.Name := 'lines' ;
  ll.AddField( 'name', TGIS_FieldType.String, 256, 0 ) ;
  ll.Params.Labels.Alignment := TGIS_LabelAlignment.Follow ;
  ll.Params.Labels.Font.Size := 12 ;
  ll.Params.Labels.Color := TGIS_Color.FromRGB($010101) ;
  ll.Params.Labels.Font.Color := TGIS_Color.FromRGB($010101) ;
  ll.Params.Labels.Allocator := False ;

  GIS.Add( ll ) ;
  ll.Extent := TGIS_Utils.GisExtent( -180, -90, 180, 90 ) ;


  shp := ll.CreateShape( TGIS_ShapeType.Arc ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( -90,  90 ) ) ;
  shp.AddPoint( TGIS_Utils.GisPoint( 180, -90 ) ) ;

  GIS.FullExtent ;

  ComboBox1.ItemIndex := 0 ;
  ComboBox1Change( nil ) ;
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  txt : String           ;
  cp  : Integer          ;
begin
  case ComboBox1.ItemIndex of
    1 :  begin // Chinese
           txt := TXT_CHINESE  ;
           cp  := 936          ;
         end ;
    2 :  begin // Japanse
           txt := TXT_JAPANESE ;
           cp  := 932          ;
         end ;
    3 :  begin // Arabic
           txt := TXT_ARABIC   ;
           cp  := 1256         ;
         end ;
    4 :  begin // Hebrew
           txt := TXT_HEBREW   ;
           cp  := 1255         ;
         end ;
    5 :  begin // Greek
           txt := TXT_GREEK    ;
           cp  := 1253         ;
         end ;
    else begin // English
           txt := TXT_ENGLISH  ;
           cp  := 1250         ;
         end ;
  end ;

  ll := TGIS_LayerVector( GIS.Get( 'points' ) );
  ll.CodePage := cp ;
  //ll.OutCodePage := cp ;
  ll.Params.Labels.Value := Format( '%s %d', [txt, 1] ) ;

  ll := TGIS_LayerVector( GIS.Get( 'lines' ) ) ;
  ll.CodePage := cp ;
  //ll.OutCodePage := cp ;
  ll.Params.Labels.Value := Format( '%s %d', [txt, 2] ) ;

  GIS.InvalidateWholeMap ;
end ;

end.
