//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  TemplatePrint Sample — Demonstrates template-based map printing using pre-defined
  print layouts with configurable map elements, legends, scale bars, and text.

  Key concepts illustrated:
    - Print templates: pre-designed layouts for map printing (.tpl/.ttktemplate)
    - Template binding: linking map controls (viewer, legend, scale, north arrow)
      to template placeholders
    - Print preview: visual preview before sending to printer
    - Template editing: modifying template layout with built-in designer
    - Template loading: loading different print templates at runtime
    - Print element configuration: title, copyright, map extent, legend style

  User workflow:
    1. Load a map project and default print template
    2. Click "Preview" to see how the map will print
    3. Click "Edit Template" to customize the template layout:
       - Move/resize map, legend, scale, north arrow
       - Adjust text fields
       - Configure page settings
    4. Click "Load Template" to switch to a different pre-designed template
    5. Use Zoom/Drag buttons to navigate the map

  Print template features:
    - TGIS_TemplatePrint: orchestrates template and print output
    - Template placeholder elements:
      * Map viewer region (with zoom/pan to specific extent)
      * Legend (layer styles and classes)
      * Scale bar (metric/imperial units)
      * North arrow (orientation indicator)
      * Text fields (title, copyright, custom labels)
    - Print manager: prepares document for printer output

  Data: Poland administrative boundaries (.ttkproject)

  Template workflow:
    1. Designer creates .tpl file with layout elements
    2. Sample loads template from Samples\PrintTemplate\printtemplate.tpl
    3. Binds GIS viewer, legend, scale, north arrow to template
    4. Sets text content (title, copyright)
    5. Preview shows composed layout
    6. Print sends to physical printer
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

{ FormClose
  Cleanup when form closes: releases the print manager and template resources. }
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { Free the print manager (which also manages the template) }
  manager.Free ;
end;

{ btnFullExtentClick
  Zooms the viewer to show all loaded map layers at full extent. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  { Fit the viewport to show all geographic data }
  GIS.FullExtent ;
end;

{ btnZoomClick
  Switches the viewer to Zoom mode: left-click+drag to zoom in, right-click to zoom out. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  { Set viewer interaction mode to Zoom (rubber-band rectangle zoom) }
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ btnDragClick
  Switches the viewer to Drag mode: click+drag to pan the map. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  { Set viewer interaction mode to Drag (pan/move the map) }
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{
  Button1Click (Preview)
  Displays print preview showing how the map will appear when printed
  using the current template and map extent.
}
procedure TForm1.Button1Click(Sender: TObject);
begin
  { Show the print preview dialog with the configured template and map }
  GIS_ControlPrintPreviewSimple1.Preview( manager ) ;
end;

{
  Button2Click (Edit Template)
  Opens the print template designer dialog allowing user to:
    - Move/resize map region, legend, scale bar, north arrow
    - Adjust text fields (title, copyright, labels)
    - Configure page setup and margins
    - Save template modifications

  The designer directly modifies the template object, so changes persist
  in the template used for previewing and printing.
}
procedure TForm1.Button2Click(Sender: TObject);
var
  workingFolder : String ;
  customPage    : String ;
  snap          : String ;
  frm : TGIS_ControlPrintTemplateDesignerForm ;
  res : Integer ;
begin
  { Template designer working directories (empty = use defaults) }
  workingFolder := '' ;  { Working folder for template resources }
  customPage := '' ;     { Custom page size definition }
  snap := '' ;           { Snap-to-grid settings }

  { Create and launch the template designer dialog.
    The designer allows visual editing of all template elements. }
  frm := TGIS_ControlPrintTemplateDesignerForm.Create( nil, True ) ;
  try
    { Configure the designer snap-to-grid behavior }
    frm.Snap := snap ;

    { Execute the designer: let user modify the template interactively.
      Returns result code indicating OK/Cancel.
      The template object is modified in-place by the designer. }
    res := frm.Execute( template, workingFolder, customPage ) ;
  finally
    { Release the designer form }
    frm.Free ;
  end ;

  { Update status bar to show the current template filename }
  StatusBar1.Panels[2].Text := GetFileName( template.TemplatePath ) ;
end;

{
  Button3Click (Load Template)
  Opens a file dialog to select a different print template (.tpl or .ttktemplate).
  Switches the active template to the selected file.
  If template loading fails, reverts to the previous template.
}
procedure TForm1.Button3Click(Sender: TObject);
var
  dlg : TOpenDialog ;
  old : String ;
begin
  { Create and configure the file open dialog }
  dlg := TOpenDialog.Create( Self ) ;
  try
    { Set filter to show only print template files }
    dlg.Filter := 'Print template|*.tpl;*.ttktemplate';
    dlg.FileName := '';
    dlg.InitialDir := GetCurrentDir ;

    { If user selects a file, load it as the new template }
    if dlg.Execute then begin
      { Save the current template path in case we need to revert }
      old := template.TemplatePath ;
      try
        { Switch to the selected template file }
        template.TemplatePath := dlg.FileName ;
        { Update status bar with the new template name }
        StatusBar1.Panels[2].Text := GetFileName( template.TemplatePath ) ;
      except
        { If template loading fails, revert to the previous template and show error }
        on e : Exception do
        begin
          ShowMessage( e.Message ) ;
          { Restore the old template path }
          template.TemplatePath := old ;
        end ;
      end;
    end ;
  finally
    dlg.Free ;
  end;
end;

{
  GISAfterPaint
  Updates the status bar with the current map scale after every paint/draw event.
  Provides real-time feedback on map scale as user zooms/pans.
}
procedure TForm1.GISAfterPaint(_sender, _canvas: TObject);
begin
  { Display the current map scale in the status bar (e.g., "1:50000") }
  StatusBar1.Panels[1].Text := GIS.ScaleAsText ;
end;

end.
