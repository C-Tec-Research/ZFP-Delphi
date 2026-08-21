unit UnitPasteSpecial;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Samples.Spin, SigSpinEdit, Vcl.ExtCtrls;

type
  tOnSelectLimit = procedure( var pText : string; var pObject : tObject ) of Object;

type
  TFormPasteSpecial = class(TForm)
    CheckBoxAutoIncInput: TCheckBox;
    CheckBoxAutoIncOutput: TCheckBox;
    RadioGroupRepeat: TRadioGroup;
    SigSpinEditFixedTimes: TSigSpinEdit;
    BitBtnObject: TBitBtn;
    BitBtnOK: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtnObjectClick(Sender: TObject);
    procedure CheckBoxAutoIncInputClick(Sender: TObject);
    procedure SigSpinEditFixedTimesChange(Sender: TObject);
  private
    fObject: tObject;
    fOnSelectLimit: tOnSelectLimit;
    fSelectText: string;
    fDefaultSelectText: string;
    fSelectingObject : boolean;
    fEnableInputInc: boolean;
    fEnableOutputInc: boolean;
    procedure SetEnableInputInc(const Value: boolean);
    procedure SetEnableOutputInc(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    property OnSelectLimit : tOnSelectLimit
             read fOnSelectLimit
             write fOnSelectLimit;
    property SelectObject : tObject
             read fObject;
    property SelectText : string
             read fSelectText;
    property DefaultSelectText : string
             read fDefaultSelectText
             write fDefaultSelectText;
    property EnableInputInc : boolean
             read fEnableInputInc
             write SetEnableInputInc;
    property EnableOutputInc : boolean
             read fEnableOutputInc
             write SetEnableOutputInc;
  end;

var
  FormPasteSpecial: TFormPasteSpecial;

implementation

{$R *.dfm}

{ TFormPasteSpecial }

procedure TFormPasteSpecial.BitBtnObjectClick(Sender: TObject);
begin
  if not fSelectingObject then
  begin
    fSelectingObject := TRUE;
    try
      if assigned( fOnSelectLimit ) then
      begin
        if RadioGroupRepeat.ItemIndex <> 2 then
        begin
          RadioGroupRepeat.ItemIndex := 2;
        end;
        fOnSelectLimit( fSelectText, fObject );
        if assigned( fObject ) then
        begin
          BitBtnObject.Caption := fSelectText;
        end
        else
        begin
          fSelectText := DefaultSelectText;
          BitBtnObject.Caption := DefaultSelectText;
        end;
      end;
    finally
      fSelectingObject := FALSE;
    end;
  end;
end;

procedure TFormPasteSpecial.CheckBoxAutoIncInputClick(Sender: TObject);
var
  iEnabled : boolean;
begin
  iEnabled := TRUE;
  if not CheckBoxAutoIncInput.Checked then
  begin
    if not CheckBoxAutoIncOutput.Checked then
    begin
      // if neither checkbox checked option must be option zero
      iEnabled := FALSE;
    end;
  end;
  if not iEnabled then
  begin
    RadioGroupRepeat.ItemIndex := 0;
    RadioGroupRepeat.Enabled := FALSE;
    BitBtnObject.Enabled := FALSE;
  end;
end;

function TFormPasteSpecial.Execute: boolean;
begin
  CheckBoxAutoIncInput.Checked := EnableInputInc;
  CheckBoxAutoIncOutput.Checked := EnableOutputInc;
  fSelectText := DefaultSelectText;
  BitBtnObject.Caption := DefaultSelectText;
  RadioGroupRepeat.ItemIndex := 0;
  SigSpinEditFixedTimes.Value := 1;
  Result := ShowModal = mrOK;
end;

procedure TFormPasteSpecial.FormCreate(Sender: TObject);
begin
  fDefaultSelectText := BitBtnObject.Caption;
end;

procedure TFormPasteSpecial.SetEnableInputInc(const Value: boolean);
begin
  fEnableInputInc := Value;
  CheckBoxAutoIncInput.Enabled := Value;
end;

procedure TFormPasteSpecial.SetEnableOutputInc(const Value: boolean);
begin
  fEnableOutputInc := Value;
  CheckBoxAutoIncOutput.Enabled := Value;
end;

procedure TFormPasteSpecial.SigSpinEditFixedTimesChange(Sender: TObject);
begin
  RadioGroupRepeat.ItemIndex := 0;
end;

end.
