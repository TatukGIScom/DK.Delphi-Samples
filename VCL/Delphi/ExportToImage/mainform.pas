//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  Export to image window
}
unit mainform;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Contnrs,

  Winapi.Windows,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ActnList,

  //GisLicense,
  GisAllLayers,
  GisClasses,
  GisEditor,
  GisLayer,
  GisLayerPixel,
  GisRegistredLayers,
  GisResource,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

const
  { Defaults quality settings }
  DEFAULT_PPI            = 300  ;
  DEFAULT_PPI_WEB        = 96   ;
  DEFAULT_PPI_DOC        = 300  ;
  DEFAULT_WIDTHPIX       = 4200 ;
  DEFAULT_WIDTHPIX_WEB   = 640  ;
  DEFAULT_WIDTH_DOC_MM   = 160  ;
  DEFAULT_WIDTH_DOC_CM   = 16   ;
  DEFAULT_WIDTH_DOC_INCH = 6.3  ;
var
  lstp           : TGIS_LayerPixel ;
  lpx            : TGIS_LayerPixel ;
type
  { Export to image form window
  }
  TfrmExportToImage = class(TForm)
    btnSave           : TButton;
    actlMain          : TActionList;
    actSave           : TAction;
    gbFile            : TGroupBox;
    edtFile           : TEdit;
    gbCompression     : TGroupBox;
    gbSize            : TGroupBox;
    rbQbest           : TRadioButton;
    rbQdoc            : TRadioButton;
    rbQweb            : TRadioButton;
    dlgSaveImage      : TSaveDialog;
    GroupBox1         : TGroupBox;
    lbFormat          : TLabel;
    cbType            : TComboBox;
    GIS               : TGIS_ViewerWnd;
    rbExtentMap       : TRadioButton;
    rbExtentVisible   : TRadioButton;
    Label1            : TLabel;
    btnSelectFile     : TButton;
    rbImage           : TRadioButton;
    rbGrid            : TRadioButton;
    dlgSaveGrid       : TSaveDialog;

    procedure actSaveExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GISBusy(_sender: TObject; _pos, _end: Integer;
                      var _abort: Boolean);
    procedure btnSelectFileClick(Sender: TObject);
    procedure rbImageClick(Sender: TObject);
    procedure rbGridClick(Sender: TObject);

  private // Private declarations
    lst                         : TObjectList               ;
    FExtent                     : TGIS_Extent               ;
    expWidth,
    expHeight,
    pixWidth,
    pixHeight                   : Double                    ;
    Ppi                         : Integer                   ;
  protected
    { Initial values : the same as Best }
    procedure ValuesInit ;
    { Recalculate Width and Height in units }
    procedure ValuesWH   ;
    { Recalculate Width and Height in pixels }
    procedure ValuesWHpix;
  end;

var
  frmExportToImage: TfrmExportToImage;

implementation

type
  T_capability = class
  public
    C : TGIS_LayerPixelSubFormat ;
    constructor Create( const _c : TGIS_LayerPixelSubFormat ) ;
  end;
{$R *.dfm}

procedure TfrmExportToImage.GISBusy( _sender: TObject; _pos,
                                     _end: Integer; var _abort: Boolean );
begin
  // show busy state
  if _end <= 0 then
    Caption := 'Export to image'
  else
    Caption := Format( 'Export to image %d%%', [ Trunc( _pos / _end * 100 ) ] ) ;

  Application.ProcessMessages ;
end;

{ Create form event handler }
procedure TfrmExportToImage.FormCreate(Sender: TObject);
begin
  rbImage.Checked := True ;
  rbImageClick( self ) ;
end;

{ Export to image method.  }
procedure TfrmExportToImage.actSaveExecute(Sender: TObject);
var
  c : TGIS_LayerPixelSubFormat ;
begin
  Application.ProcessMessages ;
  if cbType.ItemIndex >= 0 then
    c := T_capability(cbType.Items.Objects[cbType.ItemIndex]).C
  else
    c := lpx.DefaultSubFormat ;
  if rbExtentMap.Checked then
    FExtent := GIS.Extent
  else
    FExtent := GIS.VisibleExtent;

  if rbQbest.Checked then begin
    ValuesInit;
  end
  else
  if rbQdoc.Checked then begin
    Ppi := DEFAULT_PPI_DOC;
    expWidth := DEFAULT_WIDTH_DOC_INCH;

    if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
        expHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth
    end
    else
    begin
        expHeight := 2;
        expHeight := 2;
    end;
    ValuesWHpix;
  end
  else
  if rbQweb.Checked then begin
    Ppi := DEFAULT_PPI_WEB;
    pixWidth := DEFAULT_WIDTHPIX_WEB;
    if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
        pixHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * pixWidth;
    end
    else
    begin
        pixWidth := 2;
        pixHeight := 2;
    end;

    ValuesWH;
  end;

  lpx.ImportLayer( lstp, lstp.Extent, lstp.CS,
                   Round(( pixWidth )),
                   Round(( pixHeight )),
                   c
                  ) ;
  ShowMessage('File exported!');
end;


procedure TfrmExportToImage.btnSelectFileClick(Sender: TObject);
var
  clst           : TGIS_LayerPixelSubFormatList ;
  c              : TGIS_LayerPixelSubFormat     ;
begin
  if rbImage.Checked then
  begin
    if not dlgSaveImage.Execute then exit ;
    edtFile.Text := dlgSaveImage.FileName;
    edtFile.Hint := dlgSaveImage.FileName;
  end
  else begin
    if not dlgSaveGrid.Execute then exit ;
    edtFile.Text := dlgSaveGrid.FileName;
    edtFile.Hint := dlgSaveGrid.FileName;
  end ;

  cbType.Clear ;

  try
    lstp := (GIS.Items[0] as TGIS_LayerPixel);
    if rbImage.Checked then
      lpx := GisCreateLayer( ExtractFileName( dlgSaveImage.FileName ),
                             dlgSaveImage.FileName
                           ) as TGIS_LayerPixel
    else
      lpx := GisCreateLayer( ExtractFileName( dlgSaveGrid.FileName ),
                               dlgSaveGrid.FileName
                              ) as TGIS_LayerPixel ;
    clst := lpx.Capabilities;
    for c in clst do begin
      cbType.AddItem( c.ToString , T_capability.Create( c ) ) ;
    end ;

    cbType.ItemIndex           := 0;

    btnSave.Enabled := true;
    rbQbest.Enabled := true;
    rbQdoc.Enabled := true;
    rbQweb.Enabled := true;
    rbExtentMap.Enabled := true;
    rbExtentVisible.Enabled := true;
    cbType.Enabled := true;

    rbExtentMap.Checked := True ;
    rbQbest.Checked := True ;

  except
    on E : Exception do begin
      ShowMessage( E.Message );
    end ;
  end ;
end;

{ Standard FormClose event
  @desc clear items of image types list }
procedure TfrmExportToImage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  cbType.Clear ;
  FreeAndNil( lst ) ;
end;

{ Init values }
procedure TfrmExportToImage.ValuesInit ;
var
  i,j       : Integer ;
  la        : TGIS_Layer ;
  density   : Double ;
  density0  : Double ;
  density1  : Double ;
  widthpix  : Integer ;
  ext_delta : Double ;
  ext_width : Double ;
begin
  density0 := 0 ;
  density  := density0 ;
  Ppi := DEFAULT_PPI ;
  j := 0 ;
  for i:= GIS.Items.Count - 1 downto 0 do begin
      la := TGIS_Layer( GIS.Items[ i ] ) ;

      if la is TGIS_LayerPixel then begin
         ext_width := la.Extent.XMax - la.Extent.XMin ;

         density1 := TGIS_LayerPixel( la ).BitWidth / ext_width ;
         if density1 > density0 then begin
            density := density1 ;
            j := i ;
         end ;
         density0 := density1 ;
      end ;

  end ;

  if density = 0 then begin
    widthpix := 4200
  end
  else
  begin
         la := TGIS_Layer( GIS.Items[ j ] ) ;
         ext_width := la.Extent.XMax - la.Extent.XMin ;
         ext_delta := ( FExtent.XMax - FExtent.XMin ) / ext_width ;

         widthpix :=  Round ( ext_delta *
                              TGIS_LayerPixel( GIS.Items[ j ] ).BitWidth ) ;
  end ;

  pixWidth := widthpix  ;

  if ( ( FExtent.XMax - FExtent.XMin ) <> 0 ) then begin
    pixHeight :=  ( FExtent.YMax - FExtent.YMin ) /
                                   (   FExtent.XMax - FExtent.XMin ) *
                                       pixWidth
  end
  else
  begin
    pixWidth  := 2 ;
    pixHeight := 2 ;
  end ;
end ;

{ Recalculate Width and Height in units }
procedure TfrmExportToImage.ValuesWH   ;
begin
  expWidth := PixWidth / Ppi;

  if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
      expHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth;
  end
  else
  begin
      expWidth := 2;
      expHeight := 2;
  end;
end ;

{ Recalculate Width and Height in pixels }
procedure TfrmExportToImage.ValuesWHpix;
begin
  PixWidth := expWidth * Ppi;

  if not ((FExtent.XMax - FExtent.XMin) = 0) then begin
      PixHeight := (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * PixWidth;
  end
  else
  begin
      PixWidth  := 2;
      PixHeight := 2;
  end;
end;

procedure TfrmExportToImage.rbGridClick(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\San Bernardino\NED\hdr.adf' );
  edtFile.Text := '';
  cbType.Clear;
  btnSave.Enabled := false;
  rbQbest.Enabled := false;
  rbQdoc.Enabled := false;
  rbQweb.Enabled := false;
  rbExtentMap.Enabled := false;
  rbExtentVisible.Enabled := false;
  cbType.Enabled := false;
end;

procedure TfrmExportToImage.rbImageClick(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg' );
  edtFile.Text := '';
  cbType.Clear;
  btnSave.Enabled := false;
  rbQbest.Enabled := false;
  rbQdoc.Enabled := false;
  rbQweb.Enabled := false;
  rbExtentMap.Enabled := false;
  rbExtentVisible.Enabled := false;
  cbType.Enabled := false;
end;

constructor T_capability.Create(
  const _c : TGIS_LayerPixelSubFormat
) ;
begin
  inherited Create;

  C := _c.CreateCopy ;
end;


end.
