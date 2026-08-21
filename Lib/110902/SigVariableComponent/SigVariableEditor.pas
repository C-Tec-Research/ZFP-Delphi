unit SigVariableEditor;

{
  This is a chameleon editor that can take the form of several editors
}

interface

uses
  SysUtils,
  Classes,
  Controls,
  StdCtrls,
  Graphics,
  Mask,
  Contnrs,
  SigSpinEdit;

type
  tSigVariableEditorStyle = ( vesNone, vesMaskEdit, vesSpinEdit, vesComboBox );  // use Sig variants where appropriate!

type
  TSigVariableEditors = class;

  TSigVariableEditor = class(TComponent)
  private
    fEditor: tWinControl;
    fLabel : tLabel;
    fItemsList: tStringList;
    fTop: integer;
    fLeft: integer;
    fWidth: integer;
    fHeight: integer;
    fVisible: boolean;
    fDoubleBuffered: boolean;
    fParentDoubleBuffered: boolean;
    fEditorStyle: tSigVariableEditorStyle;
    fParent: tWinControl;
    fEnabled: boolean;
    fEditorList: TSigVariableEditors;
    fLabelText: string;
    fUserObject: tObject;
    fOnChange: tNotifyEvent;
    fText: string;
    procedure OnEditorChange( Sender : tObject );
    procedure SetItemsList(const Value: tStringList);
    function GetComboBox: tComboBox;
    procedure SetTop(const Value: integer);
    function GetTop: integer;
    procedure SetLeft(const Value: integer);
    function GetLeft: integer;
    procedure SetWidth(const Value: integer);
    function GetWidth: integer;
    procedure SetHeight(const Value: integer);
    function GetHeight: integer;
    procedure SetVisible(const Value: boolean);
    function GetVisible: boolean;
    function GetBrush: tBrush;
    procedure SetDoubleBuffered(const Value: boolean);
    function GetDoubleBuffered: boolean;
    function GetMouseInClient: boolean;
    procedure SetParentDoubleBuffered(const Value: boolean);
    procedure SetEditorStyle(const Value: tSigVariableEditorStyle);
    procedure SetParent(const Value: tWinControl);
    procedure SetEnabled(const Value: boolean);
    procedure SetLabelText(const Value: string);
    procedure SetOnChange(const Value: tNotifyEvent);
    function GetEditorLeft: integer;
    function GetTextLeft: integer;
    function GetEditorWidth: integer;
    function GetTextWidth: integer;
    procedure SetText(const Value: string);
    function GetMaskEdit: tMaskEdit;
    function GetSpinEdit: tSigSpinEdit;
    { Private declarations }
  protected
    { Protected declarations }
    //property ComboBox : tComboBox
    //         read GetComboBox;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Brush : tBrush
             read GetBrush;
    property MouseInClient : boolean
             read GetMouseInClient;

    property EditorLeft : integer
             read GetEditorLeft;
    property TextLeft : integer
             read GetTextLeft;
    property EditorWidth : integer
             read GetEditorWidth;
    property TextWidth : integer
             read GetTextWidth;

    property EditorAsComboBox : tComboBox
             read GetComboBox;
    property EditorAsMaskEdit : tMaskEdit
             read GetMaskEdit;
    property EditorAsSpinEdit : tSigSpinEdit
             read GetSpinEdit;

    property EditorList : TSigVariableEditors
             read fEditorList
             write fEditorList;

    property UserObject : tObject
             read fUserObject
             write fUserObject;
  published
    { Published declarations }
    property ItemsList : tStringList
             read fItemsList
             write SetItemsList;

    property Top : integer
             read GetTop
             write SetTop;
    property Left : integer
             read GetLeft
             write SetLeft;
    property Width : integer
             read GetWidth
             write SetWidth
             default 121;
    property Height : integer
             read GetHeight
             write SetHeight
             default 21;
    property Visible : boolean
             read GetVisible
             write SetVisible
             default TRUE;

    property Text : string
             read fText
             write SetText;

    property DoubleBuffered : boolean
             read GetDoubleBuffered
             write SetDoubleBuffered
             default FALSE;
    property EditorStyle : tSigVariableEditorStyle
             read fEditorStyle
             write SetEditorStyle
             default vesNone;
    property Enabled : boolean
             read fEnabled
             write SetEnabled;
    property LabelText : string
             read fLabelText
             write SetLabelText;
    property Parent : tWinControl
             read fParent
             write SetParent;
    property ParentDoubleBuffered : boolean
             read fParentDoubleBuffered
             write SetParentDoubleBuffered
             default TRUE;

    property OnChange : tNotifyEvent
             read fOnChange
             write SetOnChange;
  end;

  TSigVariableEditors = class( tComponentList )
  private
    function GetItem(const i: integer): TSigVariableEditor;
  public
    constructor Create; reintroduce;

    function Add( NewVal : TSigVariableEditor ) : integer; reintroduce;

    property Item[ const i : integer ] : TSigVariableEditor
             read GetItem;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigVariableEditor]);
end;

{ TSigVariableEditorSigNET }

constructor TSigVariableEditor.Create(AOwner: TComponent);
begin
  inherited;

  Width := 121;
  Height := 21;

  Visible := TRUE;
  fParentDoubleBuffered := TRUE;

end;

destructor TSigVariableEditor.Destroy;
begin

  if assigned( EditorList ) then
  begin
    EditorList.Remove( self );
  end;

  inherited;
end;

function TSigVariableEditor.GetBrush: tBrush;
begin
  if not assigned( fEditor ) then
  begin
    result := nil;
  end
  else if assigned( fEditor ) then
  begin
    Result := fEditor.Brush;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetComboBox: tComboBox;
begin
  if fEditor is tComboBox then
  begin
    Result := fEditor as tComboBox;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetDoubleBuffered: boolean;
begin
  if assigned( fEditor ) then
  begin
    fDoubleBuffered := fEditor.DoubleBuffered;
  end;
  Result := fDoubleBuffered;
end;

function TSigVariableEditor.GetEditorLeft: integer;
begin
  Result := Width div 2;
end;

function TSigVariableEditor.GetEditorWidth: integer;
begin
  Result := Width div 2;
end;

function TSigVariableEditor.GetHeight: integer;
begin
  Result := fHeight;
end;

function TSigVariableEditor.GetLeft: integer;
begin
  Result := fLeft;
end;

function TSigVariableEditor.GetMaskEdit: tMaskEdit;
begin
  if not assigned( fEditor ) then
  begin
    Result := nil;
  end
  else if fEditor is tMaskEdit then
  begin
    Result := fEditor as tMaskEdit;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetMouseInClient: boolean;
begin
  if assigned( fEditor ) then
  begin
    Result := fEditor.MouseInClient;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TSigVariableEditor.GetSpinEdit: tSigSpinEdit;
begin
  if not assigned( fEditor ) then
  begin
    Result := nil;
  end
  else if fEditor is tSigSpinEdit then
  begin
    Result := fEditor as tSigSpinEdit;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetTextLeft: integer;
begin
  Result := Left;
end;

function TSigVariableEditor.GetTextWidth: integer;
begin
  Result := Width div 2;
end;

function TSigVariableEditor.GetTop: integer;
begin
  Result := fTop;
end;

function TSigVariableEditor.GetVisible: boolean;
begin
  Result := fVisible;
end;

function TSigVariableEditor.GetWidth: integer;
begin
  Result := fWidth;
end;

procedure TSigVariableEditor.OnEditorChange(Sender: tObject);
begin
  if assigned( fEditor ) then
  begin
    if fEditor is tMaskEdit then
    begin
      fText := (fEditor as tMaskEdit).Text;
    end
    else if fEditor is tComboBox then
    begin
      fText := (fEditor as tComboBox).Text;
    end
    else if fEditor is tSigSpinEdit then
    begin
      fText := (fEditor as tSigSpinEdit).Text;
    end
  end;
  if assigned( fOnChange ) then
  begin
    fOnChange( self );
  end;
end;

procedure TSigVariableEditor.SetDoubleBuffered(const Value: boolean);
begin
  fDoubleBuffered := Value;
  if assigned( fEditor ) then
  begin
    fEditor.DoubleBuffered := Value;
  end;
end;

procedure TSigVariableEditor.SetEditorStyle(
  const Value: tSigVariableEditorStyle);
begin
  if fEditorStyle <> Value then
  begin
    if assigned( fLabel ) then
    begin
      fLabel.Visible := FALSE;
    end;
    fEditorStyle := Value;
    FreeAndNil( fEditor );
    case fEditorStyle of
      vesNone:
      begin
      end;
      vesMaskEdit:
      begin
        fEditor := tMaskEdit.Create( self );
        (fEditor as tMaskEdit).OnChange := OnEditorChange;
      end;
      vesSpinEdit:
      begin
        fEditor := tSigSpinEdit.Create( self );
        (fEditor as tSigSpinEdit).OnChange := OnEditorChange;
      end;
      vesComboBox:
      begin
        fEditor := tComboBox.Create( self );
        (fEditor as tComboBox).OnChange := OnEditorChange;
      end;
    end;
    if assigned( fEditor ) then
    begin
      fEditor.Parent := self.Parent;
      fEditor.Top := fTop;
      fEditor.Left := EditorLeft;
      fEditor.Width := EditorWidth;
      fEditor.Height := fHeight;
      fEditor.Visible := fVisible;
      fEditor.DoubleBuffered := fDoubleBuffered;
      fEditor.ParentDoubleBuffered := fParentDoubleBuffered;
      if assigned( fLabel ) then
      begin
        fLabel.Visible := fVisible;
        fLabel.Top := Top + ((fHeight - fLabel.Height) div 2 );
        fLabel.Left := TextLeft;
        fLabel.Width := TextWidth;
      end;
    end;
  end;
end;

procedure TSigVariableEditor.SetEnabled(const Value: boolean);
begin
  fEnabled := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Enabled := Value;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Enabled := Value;
  end;
end;

procedure TSigVariableEditor.SetHeight(const Value: integer);
begin
  fHeight := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Height := Value;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Top := Top + ((fHeight - fLabel.Height) div 2 );
  end;
end;

procedure TSigVariableEditor.SetItemsList(const Value: tStringList);
begin
  fItemsList := Value;
  if fItemsList.Count > 0 then
  begin
    if assigned( EditorAsComboBox ) then
    begin
      EditorAsComboBox.Items.Assign( fItemsList );
    end;
  end;
end;

procedure TSigVariableEditor.SetLabelText(const Value: string);
begin
  fLabelText := Value;
  if not assigned( fLabel ) then
  begin
    fLabel := tLabel.Create( self );
    fLabel.Parent := Parent;
    fLabel.Top := Top + ((fHeight - fLabel.Height) div 2 );
    fLabel.Left := TextLeft;
  end;
  fLabel.Caption := Value;
end;

procedure TSigVariableEditor.SetLeft(const Value: integer);
begin
  fLeft := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Left := EditorLeft;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Left := TextLeft;
  end;
end;

procedure TSigVariableEditor.SetOnChange(const Value: tNotifyEvent);
begin
  fOnChange := Value;
end;

procedure TSigVariableEditor.SetParent(const Value: tWinControl);
begin
  fParent := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Parent := Value;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Parent := Value;
  end;
end;

procedure TSigVariableEditor.SetParentDoubleBuffered(
  const Value: boolean);
begin
  fParentDoubleBuffered := Value;
  if assigned( fEditor ) then
  begin
    fEditor.ParentDoubleBuffered := Value;
  end;
end;

procedure TSigVariableEditor.SetText(const Value: string);
begin
  fText := Value;
end;

procedure TSigVariableEditor.SetTop(const Value: integer);
begin
  fTop := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Top := Value;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Top := Top + ((fHeight - fLabel.Height) div 2 );
  end;
end;

procedure TSigVariableEditor.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Visible := Value;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Visible := Value;
  end;
end;

procedure TSigVariableEditor.SetWidth(const Value: integer);
begin
  fWidth := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Left := EditorLeft;
    fEditor.Width := EditorWidth;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Width := TextWidth;
  end;
end;

{ TSigVariableEditors }

function TSigVariableEditors.Add(NewVal: TSigVariableEditor): integer;
begin
  Result := inherited Add( NewVal );
  NewVal.EditorList := self;
end;

constructor TSigVariableEditors.Create;
begin
  inherited Create( FALSE );
end;

function TSigVariableEditors.GetItem(const i: integer): TSigVariableEditor;
begin
  result := items[ i ] as TSigVariableEditor;
end;

end.
