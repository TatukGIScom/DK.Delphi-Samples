//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide template based printing
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
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisCsBase,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTemplatePrint,
  GisPrintBuilder,
  GisTypesUI,
  GisInternals,
  GisUtils,
  GisViewer,
  GisControlPrintPreviewSimple,

  Vcl.GisControlLegend,
  VCL.GisControlNorthArrow,
  Vcl.GisControlScale,

  Vcl.GisControlPrintPreview,
  Vcl.GisPrintManager,
  Vcl.GisPrintTemplateDesigner,
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
    ToolButton1: TToolButton;
    Splitter1: TSplitter;
    GIS_ControlLegend1: TGIS_ControlLegend;
    Button1: TButton;
    GIS_ControlScale1: TGIS_ControlScale;
    GIS_ControlPrintPreviewSimple1: TGIS_ControlPrintPreviewSimple;
    GIS_ControlNorthArrow1: TGIS_ControlNorthArrow;
    Button2: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GISAfterPaint(_sender, _canvas: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    template : TGIS_TemplatePrint ;
    manager  : TGIS_PrintManager ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  src_path : String ;
  tpl_path : String ;
begin
  // open a file
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;

  // copy template file to the current directory as .ttktemplate
  src_path := TGIS_Utils.GisSamplesDataDirDownload + 'Samples\PrintTemplate\printtemplate.tpl' ;
  tpl_path := GetCurrentDir + '\printtemplate.ttktemplate' ;
  TGIS_TemplatePrintBuilder.CopyTemplateFile( src_path, tpl_path, False ) ;

  // prepare template for printing
  template := TGIS_TemplatePrint.Create ;
  template.TemplatePath := tpl_path ;
  template.GIS_Viewer      [ 1 ] := GIS ;
  template.GIS_Legend      [ 1 ] := GIS_ControlLegend1     ;
  template.GIS_Scale       [ 1 ] := GIS_ControlScale1      ;
  template.GIS_NorthArrow  [ 1 ] := GIS_ControlNorthArrow1 ;
  template.GIS_ViewerExtent[ 1 ] := GIS.Extent             ;
  template.Text[1] := 'Title' ;
  template.Text[2] := 'Copyright' ;

  // prepare print manager
  manager := TGIS_PrintManager.Create ;
  manager.Template := template ;

  StatusBar1.Panels[2].Text := GetFileName( tpl_path ) ;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  manager.Free ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  // show full map
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // set zoom mode
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  // set drag mode
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  GIS_ControlPrintPreviewSimple1.Preview( manager ) ;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  workingFolder : String ;
  customPage    : String ;
  snap          : String ;
  frm : TGIS_ControlPrintTemplateDesignerForm ;
  res : Integer ;
begin
  //We generally recommend using the following static function to call the designer:
  //TGIS_ControlPrintTemplateDesignerForm.ShowPrintTemplateDesigner(template, workingFolder, customPage, snap);
  //
  //However, we present below an equivalent call.
  //This can be used as a pattern for classes inheriting from TGIS_ControlPrintTemplateDesignerForm.
  workingFolder := '' ;
  customPage := '' ;
  snap := '' ;

  frm := TGIS_ControlPrintTemplateDesignerForm.Create( nil, True ) ;
  try
    frm.Snap := snap ;
    res := frm.Execute( template, workingFolder, customPage ) ;
  finally
    frm.Free ;
  end ;

 StatusBar1.Panels[2].Text := GetFileName( template.TemplatePath ) ;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  dlg : TOpenDialog ;
  old : String ;
begin
  dlg := TOpenDialog.Create( Self ) ;
  try
    dlg.Filter := 'Print template|*.tpl;*.ttktemplate';
    dlg.FileName := '';
    dlg.InitialDir := GetCurrentDir ;
    if dlg.Execute then begin
      old := template.TemplatePath ;
      try
        template.TemplatePath := dlg.FileName ;
        StatusBar1.Panels[2].Text := GetFileName( template.TemplatePath ) ;
      except
        on e : Exception do
        begin
          ShowMessage( e.Message ) ;
          template.TemplatePath := old ;
        end ;
      end;
    end ;
  finally
    dlg.Free ;
  end;
end;

procedure TForm1.GISAfterPaint(_sender, _canvas: TObject);
begin
  StatusBar1.Panels[1].Text := GIS.ScaleAsText ;
end;

end.
