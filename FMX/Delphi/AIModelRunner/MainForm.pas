//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Sample app for running Python-driven AI Models on TatukGIS Viewer/Layer.

  PREREQUISITES:
  1. Install a working Python 3.x environment on your system (tested using Python 3.9).
  2. Install the Python4Delphi package in RAD Studio.
  3. Add "GIS_PYTHON4DELPHI" to Conditional Defines in Project Options.

  HOW TO RUN:
  Compile and run. Test the pipeline using the built-in Real-ESRGAN model.
  To run custom models (.onnx, .pt), provide the model file, required Python
  packages, and a Python wrapper script.

  TUTORIAL:
  See https://docs.tatukgis.com/DK11/guides:runningaimodels
}

unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.IOUtils, System.Math, System.Threading, System.Generics.Collections,
  GisAIPythonManager,
  GisAIPythonWorker,
  GisAIModelRealEsrgan,
  GisAIModelMMRotate,
  GisAIModelCustom,
  GisAIModelOutput,
  GisAllLayers,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisLayer,
  GisLayerPixel,
  GisLayerVector,
  GisImageExporter,
  GisRtl,
  GisInterfaces,
  GisRegistredLayers,
  GisFunctions,
  CustomModelForm,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Objects,
  FMX.StdCtrls, FMX.GisControlLegend, FMX.GisViewerWnd, FMX.GisViewerBmp, FMX.ListBox;

type
  TGIS_AIModelDoneProc = reference to procedure(const Err: string);
  TRunTarget = (rtLayer, rtViewer);

  TAIModelRunnerForm = class(TForm)
    RunModelButton: TButton;
    Memo1: TMemo;
    GIS: TGIS_ViewerWnd;
    ToolBarDown: TToolBar;
    btnSelect: TButton;
    btnViewDragMode: TButton;
    btnViewZoomMode: TButton;
    btnZoomEx: TButton;
    btnViewFullExtent: TButton;
    AddModelButton: TButton;
    rbRunLayer: TRadioButton;
    rbRunViewer: TRadioButton;
    GIS_Legend: TGIS_ControlLegend;
    ModelComboBox: TComboBox;
    RealEsrgan: TListBoxItem;
    MMRotate: TListBoxItem;
    OpenButton: TButton;
    ResetButton: TButton;
    dlgFileOpen: TOpenDialog;

    // Form Lifecycle
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // UI Handlers - Navigation
    procedure actViewDragModeExecute(Sender: TObject);
    procedure actViewSelectModeExecute(Sender: TObject);
    procedure actViewZoomModeExecute(Sender: TObject);
    procedure actViewFullExtentExecute(Sender: TObject);
    procedure btnZoomExClick(Sender: TObject);

    // UI Handlers - Actions
    procedure RunModelButtonClick(Sender: TObject);
    procedure AddModelButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);

  public
    // Core Logic - Async Runners
    procedure RunRealEsrganModelAsync(layerPix: TGIS_LayerPixel; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc = nil); overload;
    procedure RunRealEsrganModelAsync(viewer: IGIS_Viewer; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc = nil); overload;

    procedure RunMMRotateModelAsync(layerPix: TGIS_LayerPixel; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc = nil); overload;
    procedure RunMMRotateModelAsync(viewer: IGIS_Viewer; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc = nil); overload;

    procedure RunCustomModelAsync(layerPix: TGIS_LayerPixel; const Model: TGIS_AIModelCustom; const OnDone: TGIS_AIModelDoneProc = nil); overload;
    procedure RunCustomModelAsync(viewer: IGIS_Viewer; const Model: TGIS_AIModelCustom; const OnDone: TGIS_AIModelDoneProc = nil); overload;

    // Helpers / UI State
    procedure InitBusyUI;
    procedure ShowBusy(const Msg: string = '');
    procedure HideBusy;

  private
    FBusyOverlay: TRectangle;
    FSpinner: TAniIndicator;
    FBusyCount: Integer;
    ModelDictionary: TDictionary<string, TGIS_AIModelCustom>;

    function GetSelectedRunTarget: TRunTarget;
  end;

var
  AIModelRunnerForm: TAIModelRunnerForm;
  PythonWorker: TGIS_AIPythonWorker;

implementation

{$R *.fmx}

//=============================================================================
// Form Lifecycle
//=============================================================================

procedure TAIModelRunnerForm.FormCreate(Sender: TObject);
begin
  InitBusyUI;
  PythonWorker := PythonWorkerDefault;
  ModelDictionary := TDictionary<string, TGIS_AIModelCustom>.Create;
  ModelComboBox.ItemIndex := 0;
  dlgFileOpen.Filter := GisSupportedFiles( [ TGIS_FileType.All ] , false);
  //GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + 'World\VisibleEarth\world_8km.jpg');

  // GisSamplesDataDirDownload('AI.1') call downloads AI models onto your PC.
  // Around ~200mb. It may take a while...
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Images\marina.tiff');
end;

procedure TAIModelRunnerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PythonWorker.Shutdown();
end;

//=============================================================================
// UI Handlers - Navigation
//=============================================================================

procedure TAIModelRunnerForm.actViewDragModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag;
  btnViewDragMode.IsPressed := True;
end;

procedure TAIModelRunnerForm.actViewSelectModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select;
  btnSelect.IsPressed := True;
end;

procedure TAIModelRunnerForm.actViewZoomModeExecute(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;
  btnViewZoomMode.IsPressed := True;
end;

procedure TAIModelRunnerForm.actViewFullExtentExecute(Sender: TObject);
begin
  GIS.FullExtent;
  btnViewFullExtent.IsPressed := True;
end;

procedure TAIModelRunnerForm.btnZoomExClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.ZoomEx;
  btnZoomEx.IsPressed := True;
end;

//=============================================================================
// UI Handlers - Actions
//=============================================================================

procedure TAIModelRunnerForm.RunModelButtonClick(Sender: TObject);
var
  BusyMessage: string;
  SuccessMessage: string;
  ModelPath: string;
  CustomModel: TGIS_AIModelCustom;
  OnDoneProc: TGIS_AIModelDoneProc;
  Target: TRunTarget;
  TargetLayerPixel: TGIS_LayerPixel;
begin
  Target := GetSelectedRunTarget;
  TargetLayerPixel := GIS.Items[0] as TGIS_LayerPixel;

  if GIS_Legend.GIS_Layer <> nil then
  begin
    if GIS_Legend.GIS_Layer is TGIS_LayerPixel then
    begin
      TargetLayerPixel := GIS_Legend.GIS_Layer as TGIS_LayerPixel;
    end;
  end;


  ShowBusy(BusyMessage);

  OnDoneProc := procedure(const Err: string)
  begin
    if Err <> '' then
      Memo1.Lines.Add(Err)
    else
      Memo1.Lines.Add(SuccessMessage);
    GIS.InvalidateWholeMap;
    HideBusy;
  end;

  if ModelComboBox.Items[ModelComboBox.ItemIndex] = 'RealEsrgan (Upscale)' then
  begin
    Memo1.Lines.Add('Upscaling using Real Esrgan on current extent...');
    SuccessMessage := 'Real Esrgan finished successfully. Layer added to viewer.';
    ModelPath := TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Models\Real-ESRGAN\Model\Real-ESRGAN-x4.onnx';

    if Target = rtLayer then
      RunRealEsrganModelAsync(TargetLayerPixel, ModelPath, OnDoneProc)
    else
      RunRealEsrganModelAsync(GIS, ModelPath, OnDoneProc);
  end
  else if ModelComboBox.Items[ModelComboBox.ItemIndex] = 'MMRotate (Object Detection)' then
  begin
    Memo1.Lines.Add('Detecting objects using MMRotate on current extent...');
    SuccessMessage := 'MMRotate finished successfully. Layer added to viewer.';
    ModelPath := TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Models\MMRotate\Model\oriented_rcnn_r50_fpn_1x_dota_le90-6d2b2ce0.pth';

    if Target = rtLayer then
      RunMMRotateModelAsync(TargetLayerPixel, ModelPath, OnDoneProc)
    else
      RunMMRotateModelAsync(GIS, ModelPath, OnDoneProc);
  end
  else
  begin
    Memo1.Lines.Add('Running custom model on current extent...');
    SuccessMessage := 'Custom model finished successfully.';

    if not ModelDictionary.TryGetValue(ModelComboBox.Items[ModelComboBox.ItemIndex], CustomModel) then
    begin
      Memo1.Lines.Add('Custom model not found: ' + ModelComboBox.Items[ModelComboBox.ItemIndex]);
      Exit;
    end;

    if Target = rtLayer then
      RunCustomModelAsync(TargetLayerPixel, CustomModel, OnDoneProc)
    else
      RunCustomModelAsync(GIS, CustomModel, OnDoneProc);
  end;
end;

procedure TAIModelRunnerForm.AddModelButtonClick(Sender: TObject);
var
  ModelCustom: TGIS_AIModelCustom;
begin
  if ShowCustomModelDialog(Self, PythonWorkerDefault.Python, ModelCustom) and Assigned(ModelCustom) then
  begin
    ModelDictionary.Add(ModelCustom.ModelName, ModelCustom);
    ModelComboBox.Items.Add(ModelCustom.ModelName);
  end;
end;

procedure TAIModelRunnerForm.OpenButtonClick(Sender: TObject);
begin
  if not dlgFileOpen.Execute then exit ;

  GIS.Open( dlgFileOpen.FileName ) ;
end;

procedure TAIModelRunnerForm.ResetButtonClick(Sender: TObject);
begin
  GIS.Close;
  //GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + 'World\VisibleEarth\world_8km.jpg');
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Images\marina.tiff');
end;

//=============================================================================
// Core Logic - Async Runners
//=============================================================================

procedure TAIModelRunnerForm.RunRealEsrganModelAsync(layerPix: TGIS_LayerPixel; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Model  : TGIS_AIModelRealEsrgan;
      OutLyr : TGIS_LayerPixel;
      Err    : string;
    begin
      OutLyr := nil;
      Model := TGIS_AIModelRealEsrgan.Create(PM, ModelPath);

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        try
          Model.InstallModules;
        except
          on E: Exception do Err := 'Real-ESRGAN install error: ' + E.Message;
        end;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Module installation done.');
        end);

        if Err = '' then
        begin
          if Model.ModelPath.Trim.IsEmpty then
            Err := 'Real-ESRGAN model path is not specified.'
          else if not FileExists(Model.ModelPath) then
            Err := 'Real-ESRGAN model not found: ' + Model.ModelPath
          else
          try
            OutLyr := Model.UpscaleExtent(layerPix, Ext);
          except
            on E: Exception do Err := 'Real-ESRGAN error: ' + E.Message;
          end;
        end;
      finally
        Model.Free;
      end;

      TThread.Queue(nil,
        procedure
        begin
          try
            if (Err = '') and (OutLyr <> nil) then
            begin
              if GIS.Get(OutLyr.Name) <> nil then
                OutLyr.Name := 'RealEsrgan_' + OutLyr.Name;
              GIS.Add(OutLyr);
            end
            else
              OutLyr.Free;
          finally
            if Assigned(OnDone) then OnDone(Err);
          end;
        end);
    end);
end;

procedure TAIModelRunnerForm.RunRealEsrganModelAsync(viewer: IGIS_Viewer; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Model  : TGIS_AIModelRealEsrgan;
      OutLyr : TGIS_LayerPixel;
      Err    : string;
    begin
      OutLyr := nil;
      Model := TGIS_AIModelRealEsrgan.Create(PM, ModelPath);

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        try
          Model.InstallModules;
        except
          on E: Exception do Err := 'Real-ESRGAN install error: ' + E.Message;
        end;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Module installation done.');
        end);

        if Err = '' then
        begin
          if Model.ModelPath.Trim.IsEmpty then
            Err := 'Real-ESRGAN model path is not specified.'
          else if not FileExists(Model.ModelPath) then
            Err := 'Real-ESRGAN model not found: ' + Model.ModelPath
          else
          try
            OutLyr := Model.UpscaleExtent(viewer, Ext);
          except
            on E: Exception do Err := 'Real-ESRGAN error: ' + E.Message;
          end;
        end;
      finally
        Model.Free;
      end;

      TThread.Queue(nil,
        procedure
        begin
          try
            if (Err = '') and (OutLyr <> nil) then
            begin
              if GIS.Get(OutLyr.Name) <> nil then
                OutLyr.Name := 'RealEsrgan_' + OutLyr.Name;
              GIS.Add(OutLyr);
            end
            else
              OutLyr.Free;
          finally
            if Assigned(OnDone) then OnDone(Err);
          end;
        end);
    end);
end;

procedure TAIModelRunnerForm.RunMMRotateModelAsync(layerPix: TGIS_LayerPixel; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Model   : TGIS_AIModelMMRotate;
      OutLyrs : TGIS_LayerVectorArray;
      Err     : string;
    begin
      OutLyrs := nil;
      Model := TGIS_AIModelMMRotate.Create(PM, ModelPath, TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Models\MMRotate\Configs\oriented_rcnn_r50_fpn_fp16_1x_dota_le90.py');

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        try
          Model.InstallModules;
        except
          on E: Exception do Err := 'MMRotate install error: ' + E.Message;
        end;

        TThread.Queue(nil,
          procedure
          begin
            Memo1.Lines.Add('Module installation done.');
          end);

        if Err = '' then
        begin
          if Model.ModelPath.Trim.IsEmpty then
            Err := 'MMRotate model path is not specified.'
          else if not FileExists(Model.ModelPath) then
            Err := 'MMRotate model not found: ' + Model.ModelPath
          else
          try
            OutLyrs := Model.DetectAndDraw(layerPix, Ext);
          except
            on E: Exception do Err := 'MMRotate error: ' + E.Message;
          end;
        end;
      finally
        Model.Free;
      end;

      TThread.Queue( nil,
        procedure
        var
          I : Integer ;
        begin
          try
            if Err = '' then
            begin
              for I := 0 to High( OutLyrs ) do
              begin
                if OutLyrs[I] = nil then
                  Continue ;

                if GIS.Get( OutLyrs[I].Name ) <> nil then
                  OutLyrs[I].Name := 'MMRotate_' + OutLyrs[I].Name ;

                GIS.Add( OutLyrs[I] ) ;
              end ;
            end
            else
            begin
              for I := 0 to High( OutLyrs ) do
                OutLyrs[I].Free ;
            end ;
          finally
            if Assigned( OnDone ) then
              OnDone( Err ) ;
          end ;
        end ) ;
    end);
end;

procedure TAIModelRunnerForm.RunMMRotateModelAsync(viewer: IGIS_Viewer; const ModelPath: string; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Model   : TGIS_AIModelMMRotate;
      OutLyrs : TGIS_LayerVectorArray;
      Err     : string;
    begin
      OutLyrs := nil;
      Model := TGIS_AIModelMMRotate.Create(PM, ModelPath, TGIS_Utils.GisSamplesDataDirDownload('AI.1') + 'Samples\AI\Models\MMRotate\Configs\oriented_rcnn_r50_fpn_fp16_1x_dota_le90.py');

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        try
          Model.InstallModules;
        except
          on E: Exception do Err := 'MMRotate install error: ' + E.Message;
        end;

        TThread.Queue(nil,
          procedure
          begin
            Memo1.Lines.Add('Module installation done.');
          end);

        if Err = '' then
        begin
          if Model.ModelPath.Trim.IsEmpty then
            Err := 'MMRotate model path is not specified.'
          else if not FileExists(Model.ModelPath) then
            Err := 'MMRotate model not found: ' + Model.ModelPath
          else
          try
            OutLyrs := Model.DetectAndDraw(viewer, Ext);
          except
            on E: Exception do Err := 'MMRotate error: ' + E.Message;
          end;
        end;
      finally
        Model.Free;
      end;

      TThread.Queue( nil,
        procedure
        var
          I : Integer ;
        begin
          try
            if Err = '' then
            begin
              for I := 0 to High( OutLyrs ) do
              begin
                if OutLyrs[I] = nil then
                  Continue ;

                if GIS.Get( OutLyrs[I].Name ) <> nil then
                  OutLyrs[I].Name := 'MMRotate_' + OutLyrs[I].Name ;

                GIS.Add( OutLyrs[I] ) ;
              end ;
            end
            else
            begin
              for I := 0 to High( OutLyrs ) do
                OutLyrs[I].Free ;
            end ;
          finally
            if Assigned( OnDone ) then
              OnDone( Err ) ;
          end ;
        end ) ;
    end);
end;

procedure TAIModelRunnerForm.RunCustomModelAsync(layerPix: TGIS_LayerPixel; const Model: TGIS_AIModelCustom; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Err     : string;
      Aligned : TGIS_Extent;
      Dx, Dy  : Double;
      InTmp   : string;
    begin
      if not Assigned(Model) then
        Exit;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        Model.InstallModules;
      except
        on E: Exception do
          Err := 'Custom Model install error: ' + E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Module installation done.');
        end);

      if Err = '' then
      begin
        if Model.ModelPath.Trim.IsEmpty then
          Err := 'Custom model path is not specified.'
        else if not FileExists(Model.ModelPath) then
          Err := 'Custom model not found: ' + Model.ModelPath
        else
        try
          InTmp := TGIS_ImageExporter.ExportToImage(layerPix, Ext, Aligned);
          Model.Run(InTmp);
        except
          on E: Exception do
            Err := 'Custom Model error: ' + E.Message;
        end;
      end;

      TThread.Queue(nil,
        procedure
        var
          detectionLayers: TGIS_LayerVectorArray;
          layers: TGIS_LayerAbstractList;
          DetectionItem: TGIS_LayerVector;
          LayerItem: TGIS_LayerAbstract;
        begin
          try
            if Err = '' then
            begin
              TGIS_ImageExporter.GetPixelSize(layerPix, Dx, Dy);

              detectionLayers := Model.LastResult.GetDetectionLayers(Aligned, Dx, Dy);
              if Assigned(detectionLayers) then
              begin
                for DetectionItem in detectionLayers do
                begin
                  GIS.Add(DetectionItem);
                end;
              end;

              layers := Model.LastResult.GetLayers();
              for LayerItem in layers do
              begin
                if LayerItem is TGIS_LayerVector then
                  (LayerItem as TGIS_LayerVector).Extent := Aligned
                else if LayerItem is TGIS_LayerPixel then
                  (LayerItem as TGIS_LayerPixel).Extent := Aligned;

                GIS.Add(LayerItem);
              end;
            end;
          finally
            if Assigned(OnDone) then
              OnDone(Err);
          end;
        end);
    end);
end;

procedure TAIModelRunnerForm.RunCustomModelAsync(viewer: IGIS_Viewer; const Model: TGIS_AIModelCustom; const OnDone: TGIS_AIModelDoneProc);
var
  Ext: TGIS_Extent;
begin
  Ext := GIS.VisibleExtent;

  PythonWorkerDefault.Enqueue(
    procedure(const PM: TGIS_AIPythonManager)
    var
      Err     : string;
      Dx, Dy  : Double;
      InTmp   : string;
    begin
      if not Assigned(Model) then
        Exit;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Installing modules...');
        end);

      try
        Model.InstallModules;
      except
        on E: Exception do
          Err := 'Custom Model install error: ' + E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          Memo1.Lines.Add('Module installation done.');
        end);

      if Err = '' then
      begin
        if Model.ModelPath.Trim.IsEmpty then
          Err := 'Custom model path is not specified.'
        else if not FileExists(Model.ModelPath) then
          Err := 'Custom model not found: ' + Model.ModelPath
        else
        try
          InTmp := TGIS_ImageExporter.ExportToImage(viewer, Ext, '', '.png');
          try
            Model.Run(InTmp);
          finally
            if FileExists(InTmp) then
              TFile.Delete(InTmp);
          end;
        except
          on E: Exception do
            Err := 'Custom Model error: ' + E.Message;
        end;
      end;

      TThread.Queue(nil,
        procedure
        var
          detectionLayers: TGIS_LayerVectorArray;
          layers: TGIS_LayerAbstractList;
          DetectionItem: TGIS_LayerVector;
          LayerItem: TGIS_LayerAbstract;
        begin
          try
            if Err = '' then
            begin
              TGIS_ImageExporter.GetPixelSize(viewer, Dx, Dy);

              detectionLayers := Model.LastResult.GetDetectionLayers(Ext, Dx, Dy);
              if Assigned(detectionLayers) then
              begin
                for DetectionItem in detectionLayers do
                begin
                  GIS.Add(DetectionItem);
                end;
              end;

              layers := Model.LastResult.GetLayers();
              for LayerItem in layers do
              begin
                if LayerItem is TGIS_LayerVector then
                  (LayerItem as TGIS_LayerVector).Extent := Ext
                else if LayerItem is TGIS_LayerPixel then
                  (LayerItem as TGIS_LayerPixel).Extent := Ext;

                GIS.Add(LayerItem);
              end;
            end;
          finally
            if Assigned(OnDone) then
              OnDone(Err);
          end;
        end);
    end);
end;

//=============================================================================
// Helpers / UI State
//=============================================================================

procedure TAIModelRunnerForm.InitBusyUI;
begin
  FBusyOverlay := TRectangle.Create(Self);
  FBusyOverlay.Parent := GIS;
  FBusyOverlay.Align := TAlignLayout.Contents;
  FBusyOverlay.Fill.Color := $66000000;
  FBusyOverlay.HitTest := True;
  FBusyOverlay.Visible := False;

  FSpinner := TAniIndicator.Create(FBusyOverlay);
  FSpinner.Parent := FBusyOverlay;
  FSpinner.Align := TAlignLayout.Center;
  FSpinner.Enabled := False;
end;

procedure TAIModelRunnerForm.ShowBusy(const Msg: string = '');
begin
  Inc(FBusyCount);
  if FBusyCount = 1 then
  begin
    if Assigned(FSpinner) then FSpinner.Enabled := True;
    if Assigned(FBusyOverlay) then FBusyOverlay.Visible := True;
    if Msg <> '' then Memo1.Lines.Add(Msg);
    RunModelButton.Enabled := False;
    ModelComboBox.Enabled := False;
    AddModelButton.Enabled := False;
  end;
end;

procedure TAIModelRunnerForm.HideBusy;
begin
  if FBusyCount > 0 then Dec(FBusyCount);
  if FBusyCount = 0 then
  begin
    if Assigned(FSpinner) then FSpinner.Enabled := False;
    if Assigned(FBusyOverlay) then FBusyOverlay.Visible := False;
    RunModelButton.Enabled := True;
    ModelComboBox.Enabled := True;
    AddModelButton.Enabled := True;
  end;
end;

function TAIModelRunnerForm.GetSelectedRunTarget: TRunTarget;
begin
  if Assigned(rbRunViewer) and rbRunViewer.IsChecked then
    Result := rtViewer
  else
    Result := rtLayer;
end;

end.
