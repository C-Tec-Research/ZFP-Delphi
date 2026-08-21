unit SigVariableEditorList;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Forms,
  SigVariableEditor;

type
  TSigVariableEditorList = class(TScrollBox)
  private
    fSigVariableEditors : TSigVariableEditors;
    fDefaultEditorStyle: tSigVariableEditorStyle;
    fTopMargin: integer;
    fAutoPlaceComponents: boolean;
    fLeftMargin: integer;
    fComponentSpacing: integer;
    function GetEditor(const i: integer): TSigVariableEditor;
    procedure SetDefaultEditorStyle(const Value: tSigVariableEditorStyle);
    procedure SetTopMargin(const Value: integer);
    procedure SetAutoPlaceComponents(const Value: boolean);
    procedure SetLeftMargin(const Value: integer);
    procedure SetComponentSpacing(const Value: integer);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Add( pStyle : tSigVariableEditorStyle ) : TSigVariableEditor;
    procedure Clear;
    procedure Remove( Value : TSigVariableEditor );

    property Editor[ const i : integer ] : TSigVariableEditor
             read GetEditor;


  published
    { Published declarations }
    property AutoPlaceComponents : boolean
             read fAutoPlaceComponents
             write SetAutoPlaceComponents
             default TRUE;
    property DefaultEditorStyle : tSigVariableEditorStyle
             read fDefaultEditorStyle
             write SetDefaultEditorStyle
             default vesMaskEdit;
    property LeftMargin : integer
             read fLeftMargin
             write SetLeftMargin
             default 21;
    property TopMargin : integer
             read fTopMargin
             write SetTopMargin
             default 21;
    property ComponentSpacing : integer
             read fComponentSpacing
             write SetComponentSpacing
             default 42;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigVariableEditorList]);
end;

{ TSigVariableEditorList }

function TSigVariableEditorList.Add(
  pStyle: tSigVariableEditorStyle): TSigVariableEditor;
var
  iIndex : integer;
begin
  Result := TSigVariableEditor.Create( self );
  Result.EditorStyle := pStyle;
  Result.Parent := self;
  Result.Left := LeftMargin;
  Result.Width := self.Width - 2 * LeftMargin;
  iIndex := fSigVariableEditors.Add( Result );
  if iIndex = 0 then
  begin
    Result.Top := TopMargin;
  end
  else
  begin
    Result.Top := Editor[ iIndex - 1 ].Top + ComponentSpacing;
  end;
end;

procedure TSigVariableEditorList.Clear;
begin
  while fSigVariableEditors.Count > 0 do
  begin
    fSigVariableEditors.Last.Free;
  end;
end;

constructor TSigVariableEditorList.Create(AOwner: TComponent);
begin
  inherited;
  fSigVariableEditors := TSigVariableEditors.Create;
  fDefaultEditorStyle := vesMaskEdit;
  fTopMargin := 21;
  fLeftMargin := 21;
  fComponentSpacing := 42;
  fAutoPlaceComponents := TRUE;
end;

destructor TSigVariableEditorList.Destroy;
begin
  fSigVariableEditors.Free;
  inherited;
end;

function TSigVariableEditorList.GetEditor(const i: integer): TSigVariableEditor;
begin
  Result := fSigVariableEditors.Item[ i ];
end;

procedure TSigVariableEditorList.Remove(Value: TSigVariableEditor);
begin
  Value.Free;
end;

procedure TSigVariableEditorList.SetAutoPlaceComponents(const Value: boolean);
begin
  fAutoPlaceComponents := Value;
end;

procedure TSigVariableEditorList.SetComponentSpacing(const Value: integer);
begin
  fComponentSpacing := Value;
end;

procedure TSigVariableEditorList.SetDefaultEditorStyle(
  const Value: tSigVariableEditorStyle);
begin
  fDefaultEditorStyle := Value;
end;

procedure TSigVariableEditorList.SetLeftMargin(const Value: integer);
begin
  fLeftMargin := Value;
end;

procedure TSigVariableEditorList.SetTopMargin(const Value: integer);
begin
  fTopMargin := Value;
end;

end.
