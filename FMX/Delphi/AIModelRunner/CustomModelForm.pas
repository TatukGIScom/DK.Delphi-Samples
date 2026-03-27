//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
unit CustomModelForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.IOUtils,
  GisAIModelCustom,
  GisAIPythonManager,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TCustomAIModelForm = class(TForm)
    CancelButton: TButton;
    ChooseModelButton: TButton;
    ChooseScriptButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ModelPathMemo: TMemo;
    OkButton: TButton;
    RequiredModulesMemo: TMemo;
    ScriptPathMemo: TMemo;
    ModelNameMemo: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure ChooseModelButtonClick(Sender: TObject);
    procedure ChooseScriptButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  end;

var
  CustomAIModelForm: TCustomAIModelForm;

function ShowCustomModelDialog(AOwner: TComponent; PM: TGIS_AIPythonManager; out AModel: TGIS_AIModelCustom): Boolean;

implementation

{$R *.fmx}

procedure TCustomAIModelForm.FormCreate(Sender: TObject);
begin
  OkButton.Enabled := False;
end;

procedure TCustomAIModelForm.ChooseModelButtonClick(Sender: TObject);
var
  Dlg        : TOpenDialog;
  LInitialDir: string;
begin
  OkButton.Enabled := False;

  LInitialDir := ExtractFilePath(ParamStr(0));

  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Title      := 'Select AI model';
    Dlg.Filter     := 'AI Models (*.onnx;*.pt)|*.onnx;*.pt|All files (*.*)|*.*';
    Dlg.DefaultExt := '';
    Dlg.InitialDir := LInitialDir;

    if Dlg.Execute then
    begin
      if FileExists(Dlg.FileName) then
      begin
        ModelPathMemo.Text := Dlg.FileName;
        if not ScriptPathMemo.Text.IsEmpty then
          OkButton.Enabled := True;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TCustomAIModelForm.ChooseScriptButtonClick(Sender: TObject);
var
  Dlg        : TOpenDialog;
  LInitialDir: string;
begin
  OkButton.Enabled := False;

  LInitialDir := ExtractFilePath(ParamStr(0));

  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Title      := 'Select script (*.py)';
    Dlg.Filter     := 'Python script (*.py)|*.py';
    Dlg.DefaultExt := 'py';
    Dlg.InitialDir := LInitialDir;

    if Dlg.Execute then
    begin
      if FileExists(Dlg.FileName) and SameText(ExtractFileExt(Dlg.FileName), '.py') then
      begin
        ScriptPathMemo.Text := Dlg.FileName;
        if not ModelPathMemo.Text.IsEmpty then
          OkButton.Enabled := True;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TCustomAIModelForm.OkButtonClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCustomAIModelForm.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

// Helper function that wraps the dialog lifecycle
function ShowCustomModelDialog(AOwner: TComponent; PM: TGIS_AIPythonManager; out AModel: TGIS_AIModelCustom): Boolean;
var
  Dlg: TCustomAIModelForm;
  stringArray: array of string;
  I: Integer;
begin
  Result := False;
  AModel := nil;

  Dlg := TCustomAIModelForm.Create(AOwner);
  try
    if Dlg.ShowModal = mrOk then
    begin
      // Transfer ownership of model to caller
      SetLength(stringArray, Dlg.RequiredModulesMemo.Lines.Count);
      for I := 0 to Dlg.RequiredModulesMemo.Lines.Count - 1 do
        stringArray[I] := Dlg.RequiredModulesMemo.Lines[I].Trim([' ', ';', ',']);

      AModel := TGIS_AIModelCustom.Create(
        Dlg.ModelNameMemo.Text,
        PM,
        Dlg.ModelPathMemo.Text,
        TFile.ReadAllText(Dlg.ScriptPathMemo.Text),
        stringArray
      );
      Result := True;
    end;
  finally
    Dlg.Free;
  end;
end;

end.
