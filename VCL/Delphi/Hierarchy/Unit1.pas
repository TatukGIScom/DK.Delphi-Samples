//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Hierarchy sample — demonstrates layer organization and grouping using TGIS_Hierarchy.

  What the sample shows:
    - Creating a hierarchical layer structure (nested groups of layers) on a map
    - Organizing related layers (e.g., Poland/Waters/Lakes, Poland/Areas/city)
    - Using CreateGroup() to create named logical groups for layer organization
    - Using AddLayer() and DeleteLayer() to manage layer group membership
    - Creating nested groups with multi-level hierarchies via CreateGroup chains
    - Using MoveGroup() to reparent groups within the hierarchy tree
    - Using Groups() accessor to retrieve groups by name for further operations
    - Displaying the hierarchy in a legend control via TGIS_ControlLegendMode.Groups
    - Loading layers from .ttkproject file with pre-configured hierarchy
    - Interactive legend showing grouped layer structure

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_Hierarchy              - layer grouping and organization system
    TGIS_Hierarchy.CreateGroup() - creates a named group container
    TGIS_Hierarchy.AddLayer()    - adds layer to a group
    TGIS_Hierarchy.DeleteLayer() - removes layer from a group
    TGIS_Hierarchy.MoveGroup()   - reparents a group to another group
    TGIS_Hierarchy.Groups()      - accessor to retrieve groups by name
    TGIS_ControlLegend           - legend panel (Groups mode for hierarchy view)
    TGIS_ControlLegendMode       - display modes (Layers vs. Groups)
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

  //GisLicense,
  GisAllLayers,
  GisTypes,
  GisEditor,
  GisSymbol,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisLegend,

  Vcl.GisControlLegend,
  Vcl.GisViewerWnd;

type
  { Hierarchy sample — demonstrates layer organization and grouping using TGIS_Hierarchy.
    Creates a hierarchical layer structure (nested groups of layers) on a map, organizing related
    layers (e.g., Poland/Waters/Lakes, Poland/Areas/city). Supports group creation, layer assignment,
    group nesting, and parsing hierarchy from INI format strings. Displays the hierarchy in a legend control. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    GIS: TGIS_ViewerWnd;
    GIS_ControlLegend: TGIS_ControlLegend;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses GisInterfaces, GisConfig ;

procedure TForm1.Button1Click(Sender: TObject);
var
  group : IGIS_HierarchyGroup ;
  i     : Integer ;
  list  : TStrings ;
begin
  GIS.Close ;
  GIS_ControlLegend.Mode := TGIS_ControlLegendMode.Groups ;
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject', False ) ;

  GIS.Hierarchy.ClearGroups ;

  group := GIS.Hierarchy.CreateGroup( 'My group' ) ;

  for i := 0 to GIS.Items.Count div 2 - 1 do
    group.AddLayer(TGIS_LayerAbstract(GIS.Items.Items[i]) ) ;

  for i := 0 to GIS.Items.Count div 2 - 1 do
    group.DeleteLayer(TGIS_LayerAbstract(GIS.Items.Items[i]) ) ;

  group := GIS.Hierarchy.CreateGroup( 'Root' ) ;
  group.CreateGroup( 'Leaf' ) ;

  GIS.Hierarchy.Groups['Leaf'].CreateGroup('node').AddLayer( GIS.Get( 'city1') ) ;

  GIS.Hierarchy.MoveGroup( 'Root', 'My group' ) ;

  group := GIS.Hierarchy.CreateGroup('Poland') ;
  group := group.CreateGroup('Waters') ;
  group.AddLayer( GIS.Get( 'Lakes') ) ;
  group.AddLayer( GIS.Get( 'Rivers') ) ;

  group := GIS.Hierarchy.Groups['Poland'].CreateGroup('Areas') ;
  group.AddLayer( GIS.Get( 'city') ) ;
  group.AddLayer( GIS.Get( 'Country area') ) ;

  GIS.Hierarchy.AddOtherLayers ;

  list := TStringList.Create ;
  try
    list.Add( 'Poland\Waters=Lakes;Rivers' ) ;
    list.Add( 'Poland\Areas=city;Country area' ) ;

    GIS.Hierarchy.ClearGroups ;
    GIS.Hierarchy.ParseHierarchy( list, TGIS_ConfigFormat.Ini ) ;
  finally
    list.Free ;
  end;
  GIS.Unlock;
  GIS_ControlLegend.Update ;
  GIS.FullExtent ;
end;

end.
