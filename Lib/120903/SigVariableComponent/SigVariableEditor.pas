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
  SigSpinEdit,
  SigImage,
  Buttons,
  Forms;

type
  tSigVariableEditorStyle = ( vesNone, vesMaskEdit, vesSpinEdit, vesComboBox, vesCheckbox,
                              vesButton, vesImage );  // use Sig variants where appropriate!

type
  TSigVariableEditors = class;

  TSigVariableEditor = class(TComponent)
  private
    fEditor: tControl;
    fLabel : tLabel;
    //fItemsList: tStringList;
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
    fEditorWidth : integer;
    fImageList: tImageList;
    fOnLabelClick: tNotifyEvent;
    procedure OnEditorChange( Sender : tObject );
    procedure SelfOnLabelClick( Sender : tObject );
    //procedure SetItemsList(const Value: tStringList);
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
    function GetFont: tFont;
    function GetCheckBox: tCheckbox;
    function GetButton: tButton;
    function GetImage: tSigImage;
    procedure SetImageList(const Value: tImageList);
    function GetLabelFont: tFont;
    function GetText: string;
    { Private declarations }
  protected
    { Protected declarations }
    //property ComboBox : tComboBox
    //         read GetComboBox;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Invalidate;

    property Brush : tBrush
             read GetBrush;
    property Font : tFont
             read GetFont;
    property LabelFont : tFont
             read GetLabelFont;

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
    property EditorAsCheckBox : tCheckbox
             read GetCheckBox;
    property EditorAsButton : tButton
             read GetButton;
    property EditorAsImage : tSigImage
             read GetImage;

    property EditorList : TSigVariableEditors
             read fEditorList
             write fEditorList;

    property UserObject : tObject
             read fUserObject
             write fUserObject;
  published
    { Published declarations }

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
    property FixedEditorWidth : integer   // if non-zero makes editor widths fixed
             read fEditorWidth
             write fEditorWidth
             default 0;


    property Text : string
             read GetText
             write SetText;
    property ImageList : tImageList
             read fImageList
             write SetImageList;

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
    property OnLabelClick : tNotifyEvent
             read fOnLabelClick
             write fOnLabelClick;
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
  else if fEditor is tWinControl then
  begin
    Result := (fEditor as tWinControl).Brush;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetButton: tButton;
begin
  if not assigned( fEditor ) then
  begin
    Result := nil;
  end
  else if fEditor is tButton then
  begin
    Result := fEditor as tButton;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetCheckBox: tCheckbox;
begin
  if fEditor is tCheckBox then
  begin
    Result := fEditor as tCheckBox;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetComboBox: tComboBox;
begin
  try
    if fEditor is tComboBox then
    begin
      Result := fEditor as tComboBox;
    end
    else
    begin
      Result := nil;
    end;
  except
    Result := nil;
  end;
end;

function TSigVariableEditor.GetDoubleBuffered: boolean;
begin
  if assigned( fEditor ) then
  begin
    if fEditor is tWinControl then
    begin
      fDoubleBuffered := (fEditor as tWinControl).DoubleBuffered;
    end;
  end;
  Result := fDoubleBuffered;
end;

function TSigVariableEditor.GetEditorLeft: integer;
begin
  Result := Width - EditorWidth;
end;

function TSigVariableEditor.GetEditorWidth: integer;
begin
  if fEditorWidth = 0 then
  begin
    Result := Width div 2;
  end
  else
  begin
    Result := fEditorWidth;
  end;
end;

function TSigVariableEditor.GetFont: tFont;
begin
  case EditorStyle of
    vesNone:     Result := nil;
    vesMaskEdit: Result := EditorAsMaskEdit.Font;
    vesSpinEdit: Result := EditorAsSpinEdit.Font;
    vesComboBox: Result := EditorAsComboBox.Font;
    vesCheckBox: Result := EditorAsCheckBox.Font;
    vesButton  : Result := EditorAsButton.Font;
    vesImage   : Result := nil;
    else         Result := nil;
  end;
end;

function TSigVariableEditor.GetHeight: integer;
begin
  Result := fHeight;
end;

function TSigVariableEditor.GetImage: tSigImage;
begin
  if fEditor is tSigImage then
  begin
    Result := fEditor as tSigImage;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigVariableEditor.GetLabelFont: tFont;
begin
  if assigned( fLabel ) then
  begin
    Result := fLabel.Font;
  end
  else
  begin
    Result := nil;
  end;
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
    if fEditor is tWinControl then
    begin
      Result := (fEditor as tWinControl).MouseInClient;
    end
    else
    begin
      Result := FALSE;
    end
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

function TSigVariableEditor.GetText: string;
begin
  case EditorStyle of
    vesNone:     Result := fText;
    vesMaskEdit: Result := EditorAsMaskEdit.Text;
    vesSpinEdit: Result := EditorAsSpinEdit.Text;
    vesComboBox: Result := EditorAsComboBox.Text;
    vesCheckbox: Result := fText;
    vesButton:   Result := fText;
    vesImage:    Result := fText;
  end;
end;

function TSigVariableEditor.GetTextLeft: integer;
begin
  Result := Left;
end;

function TSigVariableEditor.GetTextWidth: integer;
begin
  Result := Width - EditorWidth;
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

procedure TSigVariableEditor.Invalidate;
begin
  if assigned( fEditor ) then
  begin
    fEditor.Invalidate;
  end;
  if assigned( fLabel ) then
  begin
    fLabel.Invalidate;
  end;
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
    else if fEditor is tCheckBox then
    begin
      if (fEditor as tCheckbox).Checked then
      begin
        fText := 'TRUE';
      end
      else
      begin
        fText := 'FALSE';
      end;
    end
    else if fEditor is tSigImage then
    begin
      fText := IntToStr( EditorAsImage.ImageIndex );
    end;
    if assigned( fOnChange ) then
    begin
      fOnChange( self );
    end;
  end;
end;

procedure TSigVariableEditor.SelfOnLabelClick(Sender: tObject);
begin
  if assigned( fOnLabelClick ) then
  begin
    fOnLabelClick( self );
  end;
end;

procedure TSigVariableEditor.SetDoubleBuffered(const Value: boolean);
begin
  fDoubleBuffered := Value;
  if assigned( fEditor ) then
  begin
    if fEditor is tWinControl then
    begin
      (fEditor as tWinControl).DoubleBuffered := Value;
    end;
  end;
end;

procedure TSigVariableEditor.SetEditorStyle(
  const Value: tSigVariableEditorStyle);
var
  iTop : integer;
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
      vesCheckBox:
      begin
        fEditor := tCheckBox.Create( self );
        (fEditor as tCheckBox).OnClick := OnEditorChange;
      end;
      vesButton:
      begin
        fEditor := tButton.Create( self );
        (fEditor as tButton).OnClick := OnEditorChange;
      end;
      vesImage:
      begin
        fEditor := tSigImage.Create( self );
        EditorAsImage.Transparent := FALSE;
        EditorAsImage.OnClick := OnEditorChange;
        EditorAsImage.ImageList := fImageList
      end;
    end;
    if assigned( fEditor ) then
    begin
      fEditor.Parent := self.Parent;
      iTop := (self.Parent as tScrollBox).VertScrollBar.ScrollPos;
      fEditor.Top := fTop + iTop;
      fEditor.Left := EditorLeft;
      fEditor.Width := EditorWidth;
      fEditor.Height := fHeight;
      fEditor.Visible := fVisible;
      if fEditor is tWinControl then
      begin
        (fEditor as tWinControl).DoubleBuffered := fDoubleBuffered;
        (fEditor as tWinControl).ParentDoubleBuffered := fParentDoubleBuffered;
      end;
      SetText( fText );
      if assigned( fLabel ) then
      begin
        fLabel.Visible := fVisible;
        fLabel.Top := Top + iTop + ((fHeight - fLabel.Height) div 2 );
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

procedure TSigVariableEditor.SetImageList(const Value: tImageList);
begin
  fImageList := Value;
  if fEditor is tSigImage then
  begin
    EditorAsImage.ImageList := Value;
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
    fLabel.OnClick := SelfOnLabelClick;
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
    if fEditor is tWinControl then
    begin
      (fEditor as tWinControl).ParentDoubleBuffered := Value;
    end;
  end;
end;

procedure TSigVariableEditor.SetText(const Value: string);
begin
  fText := Value;
  case EditorStyle of
    vesNone:;
    vesMaskEdit:
    begin
      EditorAsMaskEdit.Text := Value;
    end;
    vesSpinEdit:
    begin
      if Value <> '' then
      begin
        EditorAsSpinEdit.Text := Value;
      end;
    end;
    vesComboBox:
    begin
      EditorAsComboBox.Text := Value; // may not work for dropdowns
    end;
    vesCheckbox:
    begin
      if SameText( Value, 'TRUE') then
      begin
        EditorAsCheckBox.Checked := TRUE;
      end
      else if SameText( Value, 'FALSE') then
      begin
        EditorAsCheckBox.Checked := FALSE;
      end
    end;
    vesButton:;
    vesImage:
    begin
      try
        if Value = '' then
        begin
          EditorAsImage.ImageIndex := 0;
        end
        else
        begin
          EditorAsImage.ImageIndex := StrToInt( Value );
        end;
      except

      end;
    end;
  end;
end;

procedure TSigVariableEditor.SetTop(const Value: integer);
var
  iTop : integer;
begin
  fTop := Value;
  if assigned( self.Parent ) then
  begin
    iTop := (self.Parent as tScrollBox).VertScrollBar.ScrollPos;
    if assigned( fEditor ) then
    begin
      fEditor.Top := Value + iTop;
    end;
    if assigned( fLabel ) then
    begin
      fLabel.Top := Top + iTop + ((fHeight - fLabel.Height) div 2 );
    end;
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
