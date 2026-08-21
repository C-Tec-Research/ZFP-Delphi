unit UnitBasicButtonProps;

interface

uses
  SysUtils,
  Windows,
  Messages,
  Classes,
  Graphics,
  Controls,
  StdCtrls,
  ExtCtrls,
  Forms,
  Spin;

type
  TFormBasicButtonProps = class(TForm)
    ButtonOK: TButton;
    Button2: TButton;
    Button3: TButton;
    LabelTop: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpinEditTop: TSpinEdit;
    SpinEditLeft: TSpinEdit;
    SpinEditHeight: TSpinEdit;
    SpinEditWidth: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure SpinEditTopChange(Sender: TObject);
    procedure SpinEditLeftChange(Sender: TObject);
    procedure SpinEditHeightChange(Sender: TObject);
    procedure SpinEditWidthChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    public
//      BoundsWidth  : integer;
//      BoundsHeight : integer;
    private
      SaveTop, SaveLeft, SaveWidth, SaveHeight : integer;
  end;

var
  FormBasicButtonProps: TFormBasicButtonProps;

implementation

{$R *.DFM}

uses
  DSMButton;

procedure TFormBasicButtonProps.FormShow(Sender: TObject);
begin
//  with Owner do
//  begin
//    BoundsWidth := ClientWidth;
//    BoundsHeight := ClientHeight;
//  end;
  SaveTop := ActiveButton.Top;
  SaveLeft := ActiveButton.Left;
  SaveWidth := ActiveButton.Width;
  SaveHeight := ActiveButton.Height;
  SpinEditTop.Value := SaveTop;
  SpinEditLeft.Value := SaveLeft;
  SpinEditWidth.Value := SaveWidth;
  SpinEditHeight.Value := SaveHeight;
  ButtonOK.Enabled := FALSE;
end;

procedure TFormBasicButtonProps.SpinEditTopChange(Sender: TObject);
begin
  // set bounds
//  SpinEditHeight.MaxValue := BoundsHeight - SpinEditTop.Value;
  ButtonOK.Enabled := TRUE;
  ActiveButton.Top := SpinEditTop.Value;
end;

procedure TFormBasicButtonProps.SpinEditLeftChange(Sender: TObject);
begin
  // set bounds
//  SpinEditWidth.MaxValue := BoundsWidth - SpinEditLeft.Value;
  ButtonOK.Enabled := TRUE;
  ActiveButton.Left := SpinEditLeft.Value;
end;

procedure TFormBasicButtonProps.SpinEditHeightChange(Sender: TObject);
begin
  // set bounds
//  SpinEditTop.MaxValue := BoundsHeight - SpinEditHeight.Value;
  ButtonOK.Enabled := TRUE;
  ActiveButton.Height := SpinEditHeight.Value;
end;

procedure TFormBasicButtonProps.SpinEditWidthChange(Sender: TObject);
begin
  // set bounds
//  SpinEditLeft.MaxValue := BoundsWidth - SpinEditWidth.Value;
  ButtonOK.Enabled := TRUE;
  ActiveButton.Width := SpinEditWidth.Value;
end;

procedure TFormBasicButtonProps.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // Restore values
//  with Parent do
//  begin
    ActiveButton.Top := SaveTop;
    ActiveButton.Left := SaveLeft;
    ActiveButton.Width := SaveWidth;
    ActiveButton.Height := SaveHeight;
//  end;
end;

end.
