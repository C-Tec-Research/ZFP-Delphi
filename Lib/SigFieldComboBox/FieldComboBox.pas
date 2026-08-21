unit FieldComboBox;

{
  This dropdown list becomes visible whenever the Startfield character
  is typed. To only allow predefined fields, make this a drop down list.

  Tries to appear at caret pos, but checks its width against MainForm
  component of application.

  If the enter key is pressed, checks to see if the caret is after a '<'
  and if so makes the drop down visible.

  Esc aborts field insert.

  Auto inserts termination character.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Windows;

type
  TOnInsertField = procedure( var NewText : string ) of object; // blank NewText to abort insertion

  TFieldComboBox = class(TComboBox)
  private
    { Private declarations }
    fMemoField: TMemo;
    fStartField: char;
    fEndField: char;
    fMemoKeyPressEvent : tKeyPressEvent;
    fOnInsertField: tOnInsertField;
    fVarString: string;
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
    procedure SetMemoField(const Value: TMemo);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    { Protected declarations }
    procedure KeyPress(var Key: Char); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

    procedure Fire; // causes a manual appearence rather than one triggered
                    // by the start char. SelStart should be immediately after
                    // the Start Character, and SelLength should be the length
                    // to and including the terminating char if any. That is
                    // the selection should exclude the start character but
                    // include the termination character
    function SkipField : boolean; // skips past the end of the urrent or next field
  published
    { Published declarations }
    property MemoField : TMemo
             read fMemoField
             write SetMemoField;
    property Visible
             default FALSE;
    property StartField : char
             read fStartField
             write fStartField
             default '<';
    property EndField : char
             read fEndField
             write fEndField
             default '>';
    property OnInsertField : tOnInsertField
             read fOnInsertField
             write fOnInsertField;
    property VarString : string
             read fVarString
             write fVarString;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TFieldComboBox]);
end;
{$ENDIF}

{ TFieldComboBox }

procedure TFieldComboBox.CMExit(var Message: TCMExit);
var
  iText : string;
  iVarOffset, iVarLen : integer;
  iSelStart : integer;
begin
  inherited;
  Visible := FALSE;
  iText := self.Text;
  if iText <> '' then
  begin
    if assigned( fOnInsertField ) then
    begin
      fOnInsertField( iText );
    end;
    if iText <> '' then
    begin
      iVarLen := Length( fVarString );
      if iVarLen > 0 then
      begin
        iVarOffset := Pos( fVarString, iText );
      end
      else
      begin
        iVarOffset := 0;
      end;
      iSelStart := fMemoField.SelStart;
      fMemoField.SelText := iText + fEndField;
      if iVarOffset > 0 then
      begin
        fMemoField.SelStart := iSelStart + iVarOffset - 1;
        fMemoField.SelLength := iVarLen;
      end;
    end;
  end;
  fMemoField.SetFocus;
end;

constructor TFieldComboBox.Create(AOwner: TComponent);
begin
  inherited;
  Visible := FALSE;
  fStartField := '<';
  fEndField := '>';
  fVarString := '$';
end;

procedure TFieldComboBox.Fire;
var
  iCaretPos : TPoint;
  iDesiredLeft, iMaxLeft : integer;
begin
  Text := fMemoField.SelText;
  Visible := TRUE;
  SetFocus;
  // try to position ourselves
  iCaretPos := fMemoField.CaretPos;
  iMaxLeft := Parent.ClientWidth - Width;     // This is as far right as we can go
  iDesiredLeft := fMemoField.Left + (fMemoField.Width - fMemoField.ClientWidth) + Canvas.TextWidth( Copy( fMemoField.Text, 1, iCaretPos.X ) + StartField ) + fMemoField.ClientRect.Left + ClientRect.Left; // approximate but good enough
  if iMaxLeft < iDesiredLeft then
  begin
    Left := iMaxLeft;
  end
  else
  begin
    Left := iDesiredLeft;
  end;
  Top := iCaretPos.Y + fMemoField.Top;
end;

procedure TFieldComboBox.KeyPress(var Key: Char);
begin
  if Key = #13 then
  begin
    Visible := FALSE;
    Key := #0;
    //fMemoField.SelText := self.Text + '>';
  end
  else if Key = #27 then
  begin
    // esc
    Text := '';
    Visible := FALSE;
  end
  else if Key = fEndField then
  begin
    Visible := FALSE;
    Key := #0;
  end;
  inherited;

end;

procedure TFieldComboBox.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if assigned( fMemoKeyPressEvent ) then
  begin
    fMemoKeyPressEvent( Sender, Key );
  end;
  if Key = fStartField then
  begin
    Fire;
  end
  else if Key = #9 then // tab, if not intercepted   IMPORTANT needs 'WantsTabs' set to true for this to work
  begin
    // don't pass back - we don't really want tabs
    SkipField;
    Key := #0;
  end;
end;

procedure TFieldComboBox.SetMemoField(const Value: TMemo);
begin
  if not (csDesigning in ComponentState) then
  begin
    if assigned( fMemoField ) then
    begin
      fMemoField.OnKeyPress := fMemoKeyPressEvent;
      fMemoKeyPressEvent := nil;
    end;
  end;
  fMemoField := Value;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( fMemoField ) then
    begin
      fMemoKeyPressEvent := fMemoField.OnKeyPress;
      fMemoField.OnKeyPress := MemoKeyPress;
      if Parent <> fMemoField.Parent then
      begin
        Parent := fMemoField.Parent;
      end;
      BringToFront;
    end;
  end;
end;

function TFieldComboBox.SkipField : boolean;
var
  iSelStart : integer;
begin
  iSelStart := fMemoField.SelStart;
  iSelStart := PosEx( fEndField, fMemoField.Text, iSelStart + 1 );
  if iSelStart > 0 then
  begin
    with fMemoField do
    begin
      SelStart := iSelStart;
      SelLength := 0;
    end;
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

end.
