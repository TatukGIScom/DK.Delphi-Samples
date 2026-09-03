program TopologyLayer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmTopology},
  GisLayerTopoSql in '..\..\..\..\..\..\Src\Layers\Topological\GisLayerTopoSql.pas',
  GisLayerTopoSqlNative in '..\..\..\..\..\..\Src\Layers\Topological\GisLayerTopoSqlNative.pas',
  GisLayerTopoSqlNativeSqlite in '..\..\..\..\..\..\Src\Layers\Topological\GisLayerTopoSqlNativeSqlite.pas',
  GisTopoBuilder in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoBuilder.pas',
  GisTopoEditUtils in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoEditUtils.pas',
  GisTopoRules in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoRules.pas',
  GisTopoSettings in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoSettings.pas',
  GisTopoStore in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoStore.pas',
  GisTopoStoreNative in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoStoreNative.pas',
  GisTopoTool in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoTool.pas',
  GisTopoTypes in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoTypes.pas',
  GisTopoUtils in '..\..\..\..\..\..\Src\Layers\Topological\GisTopoUtils.pas',
  PVL.GisTopoAddElementsToFeatureWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoAddElementsToFeatureWizard.pas',
  PVL.GisTopoAutoFixImportErrorsWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoAutoFixImportErrorsWizard.pas',
  PVL.GisTopoCreateFeatureLayerForm in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoCreateFeatureLayerForm.pas',
  PVL.GisTopoCreateFeatureWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoCreateFeatureWizard.pas',
  PVL.GisTopoCreateTopologyWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoCreateTopologyWizard.pas',
  PVL.GisTopoDeleteFeatureElementWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoDeleteFeatureElementWizard.pas',
  PVL.GisTopoDeleteFeatureWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoDeleteFeatureWizard.pas',
  PVL.GisTopoManualFixImportErrorsWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoManualFixImportErrorsWizard.pas',
  PVL.GisTopoModalWizard in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoModalWizard.pas',
  PVL.GisTopoSettingsForm in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoSettingsForm.pas',
  PVL.GisTopoToolbar in '..\..\..\..\..\..\Src\Platform\PVL\Topology\PVL.GisTopoToolbar.pas',
  GisLayerTopoSqlPgis in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisLayerTopoSqlPgis.pas',
  GisLayerTopoSqlPgisLibpq in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisLayerTopoSqlPgisLibpq.pas',
  GisLayerTopoSqlSdo in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisLayerTopoSqlSdo.pas',
  GisLayerTopoSqlSdoOci in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisLayerTopoSqlSdoOci.pas',
  GisTopoStorePgis in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisTopoStorePgis.pas',
  GisTopoStoreSdo in '..\..\..\..\..\..\Src\Layers\Enterprise.Topological\GisTopoStoreSdo.pas',
  GisEditorTopo in '..\..\..\..\..\..\Src\Advanced\GisEditorTopo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTopology, frmTopology);
  Application.Run;
end.
