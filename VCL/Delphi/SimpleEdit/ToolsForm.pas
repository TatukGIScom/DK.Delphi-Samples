//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide editing functionality.
}
unit ToolsForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,

  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.Grids,
  Vcl.ExtCtrls,

  GisLayerVector,
  GisUtils,
  GisViewer,
  GisEditorTools,
  Vcl.GisControlAttributes, Vcl.Samples.Spin;

type
  TfrmEditorTools = class(TForm)
    pnlLockedParams: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edtAngle: TEdit;
    edtDistance: TEdit;
    cbRelativeAngle: TCheckBox;
    cbEditingTool: TComboBox;
    Label3: TLabel;
    cbTracing: TCheckBox;
    cbPolarTracking: TCheckBox;
    sePolarIncAngle: TSpinEdit;
    lblStep: TLabel;
    procedure cbEditingToolChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtDistanceChange(Sender: TObject);
    procedure edtAngleChange(Sender: TObject);
    procedure cbRelativeAngleClick(Sender: TObject);
    procedure cbTracingClick(Sender: TObject);
    procedure cbPolarTrackingClick(Sender: TObject);

  private
    FEditorToolChange : TNotifyEvent ;
  public
    { Public declarations }
    EditingTool : TGIS_EditorToolAbstract ;
    procedure NotifyAction( const _prompt : String ) ;
    procedure NotifyChange ;
  published
    property OnEditorToolChange : TNotifyEvent read FEditorToolChange write FEditorToolChange ;
  end;

var
  frmEditorTools: TfrmEditorTools;

implementation

uses
  GisTypes ;

{$R *.DFM}

procedure TfrmEditorTools.cbEditingToolChange(Sender: TObject);
begin
  case cbEditingTool.ItemIndex of
    0 : EditingTool := nil ;
    1 : EditingTool := TGIS_EditorToolLine.Create ;
    2 : EditingTool := TGIS_EditorToolRectangle.Create ;
    3 : EditingTool := TGIS_EditorToolRectangle90.Create ;
    4 : EditingTool := TGIS_EditorToolCircle.Create ;
    5 : EditingTool := TGIS_EditorToolCircle3P.Create ;
    6 : begin
          EditingTool := TGIS_EditorToolArc.Create ;
          TGIS_EditorToolArc(EditingTool).Mode := TGIS_EditorToolArcMode.AmStartEndSecond ;
        end;
    7 : EditingTool := TGIS_EditorToolEllipse.Create ;
  end;

  if assigned( FEditorToolChange ) then begin
    if assigned( EditingTool ) then begin
      EditingTool.LockedParams.Distance      := StrToFloatDef(edtDistance.Text, GIS_MAX_DOUBLE) ;
      EditingTool.LockedParams.Angle         := StrToFloatDef(edtAngle.Text, GIS_MAX_DOUBLE) ;
      EditingTool.LockedParams.RelativeAngle := cbRelativeAngle.Checked ;
    end;
    FEditorToolChange( Sender ) ;
  end;
end;

procedure TfrmEditorTools.cbPolarTrackingClick(Sender: TObject);
begin
  if assigned( FEditorToolChange ) then
    FEditorToolChange( Sender ) ;
end;

procedure TfrmEditorTools.cbRelativeAngleClick(Sender: TObject);
begin
  if assigned( EditingTool ) then
    EditingTool.LockedParams.RelativeAngle := cbRelativeAngle.Checked ;
end;

procedure TfrmEditorTools.cbTracingClick(Sender: TObject);
begin
  if assigned( FEditorToolChange ) then
    FEditorToolChange( Sender ) ;
end;

procedure TfrmEditorTools.edtAngleChange(Sender: TObject);
begin
  if assigned( EditingTool ) then
    EditingTool.LockedParams.Angle := StrToFloatDef(edtAngle.Text, GIS_MAX_DOUBLE) ;
end;

procedure TfrmEditorTools.edtDistanceChange(Sender: TObject);
begin
  if assigned( EditingTool ) then
    EditingTool.LockedParams.Distance := StrToFloatDef(edtDistance.Text, GIS_MAX_DOUBLE) ;
end;

procedure TfrmEditorTools.FormCreate(Sender: TObject);
begin
  EditingTool := nil ;
end;

procedure TfrmEditorTools.NotifyAction(const _prompt: String);
begin
  lblStep.Caption := _prompt ;
end;

procedure TfrmEditorTools.NotifyChange;
begin
  edtDistance.Text := '' ;
  edtAngle.Text := '' ;
  cbRelativeAngle.Checked := False ;
  lblStep.Caption := '' ;
end;

end.



