//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  SQLWizard sample — demonstrates SQL layer creation via an interactive wizard (Delphi/VCL).

  What the sample shows:
    - Launching an interactive SQL layer wizard dialog
    - Specifying database connection parameters and type
    - Selecting spatial tables from the database
    - Choosing geometry and attribute columns
    - Configuring spatial reference systems
    - Setting up layer filtering and field mapping
    - Creating new SQL layer (.ttkls) definitions interactively
    - Testing database connections before saving
    - Applying the newly created layer to the viewer
    - Managing multiple SQL layers in the project
    - Saving layer definitions for future reuse
    - Browsing available databases and tables
    - Handling various SQL database backends

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerSqlAdo            - ADO-based SQL layer creation
    TGIS_LayerSqlSqlite         - SQLite layer creation
    TGIS_LayerSqlPostGis        - PostGIS layer creation
    SQL Wizard dialog           - step-by-step layer configuration UI
    Database connection         - server, port, user, password parameters
    Table selection             - choosing source spatial table
    Geometry column selection   - identifying the shape column
    Spatial reference system    - setting EPSG code or well-known text
    Layer configuration         - .ttkls file format creation
    Database schema browsing    - discovery of available tables
    TGIS_Utils.GisCreateLayer   - factory method for layer instantiation
}

unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisAllLayers,
  GisEditor,
  GisLayer,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    ToolButton2: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    btnSqlWizard: TToolButton;
    btn1: TToolButton;
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnSqlWizardClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  formLayerSql ;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnSqlWizardClick(Sender: TObject);
begin
  frmLayerSQL.Show ;
  frmLayerSQL.Left := self.Left + self.Width ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
