unit UnitProjectExportFile;

interface

uses
{$IFNDEF SIGDEBUG}
  ToolsAPI,
{$ENDIF}

  SigFile;

type
  tSigModule = class( tSigCompoundProperty )
  private
    fModuleType: tSigIntegerProperty;
    fName: tSigTextProperty;
    fFileName: tSigTextProperty;
    fDesignClass: tSigTextProperty;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property ModuleType : tSigIntegerProperty
             read fModuleType;
    property Name : tSigTextProperty
             read fName;
    property FileName : tSigTextProperty
             read fFileName;
    property DesignClass : tSigTextProperty
             read fDesignClass;

{$IFNDEF SIGDEBUG}
    procedure Assign( const pModule : IOTAModuleInfo ); reintroduce;
{$ENDIF}
  end;

  tSigModuleList = class( tSigObjectList )
  private
    function GetSigModule(const i: integer): tSigModule;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property Module[ const i : integer ] : tSigModule
             read GetSigModule;
  end;

type
  tProjectFile = class( tSigFileProperty )
  private
    fProjectName: tSigTextProperty;
    fModuleList: tSigModuleList;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property ProjectName : tSigTextProperty
             read fProjectName;
    property ModuleList : tSigModuleList
             read fModuleList;
{$IFNDEF SIGDEBUG}
    procedure Assign( const pProject : IOTAProject );
{$ENDIF}

  end;

implementation

{ tSigModule }

{$IFNDEF SIGDEBUG}
procedure tSigModule.Assign(const pModule: IOTAModuleInfo);
begin
  ModuleType.ValueAsInt := pModule.ModuleType;
  Name.Value := pModule.Name;
  FileName.Value := pModule.FileName;
  DesignClass.Value := pModule.DesignClass;

end;
{$ENDIF}

constructor tSigModule.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fModuleType  := tSigIntegerProperty.Create( 'Module Type', self );
  fName        := tSigTextProperty.Create( 'Name', self );
  fFileName    := tSigTextProperty.Create( 'File Name', self );
  fDesignClass := tSigTextProperty.Create( 'Design Class', self );

end;

{ tSigModuleList }

constructor tSigModuleList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigModule );

end;

function tSigModuleList.GetSigModule(const i: integer): tSigModule;
begin
  Result := Entry[ i ] as tSigModule;
end;

{ tProjectFile }

{$IFNDEF SIGDEBUG}
procedure tProjectFile.Assign(const pProject: IOTAProject);
var
  i, iModuleCount : integer;
begin
  Clear;
  if assigned( pProject ) then
  begin
    ProjectName.Value := pProject.FileName;
    iModuleCount := pProject.GetModuleCount;
    ModuleList.Max := iModuleCount - 1;
    for i := 0 to iModuleCount - 1 do
    begin
      ModuleList.Module[ i ].Assign( pProject.GetModule( i ));
    end;
  end;
end;
{$ENDIF}

constructor tProjectFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fProjectName := tSigTextProperty.Create( 'Project Name', self );
  fModuleList  := tSigModuleList.Create( 'Module List', self );

end;

end.
