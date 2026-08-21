unit SigFileClipboard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  //ClipBrd,
  SigFile,
  SigParse,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFormSigFileClipboard = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    MemoClipboard: TMemo;
    BitBtnDone: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    procedure CopyToClipBoard( const SigProperty : tSigBaseProperty );
    procedure PasteFromClipBoard( const SigProperty : tSigBaseProperty );
    function CanPasteFromClipBoard( const SigProperty : tSigBaseProperty; var SigValue : string ) : boolean;
  end;

var
  FormSigFileClipboard: TFormSigFileClipboard;

implementation

{$R *.dfm}

{ TFormSigFileClipboard }

procedure TFormSigFileClipboard.PasteFromClipBoard(
  const SigProperty: tSigBaseProperty);
var
  SigValue : string;
  iLine : integer;
begin
  if CanPasteFromClipboard( SigProperty, SigValue ) then
  begin
    SigProperty.Clear;
    SigProperty.Value := SigValue;
    if MemoClipboard.Lines.Count > 1 then
    begin
      iLine := 1;
      SigProperty.Load( MemoClipBoard.Lines, iLine );
    end;
  end
  else
  begin
    if MemoClipboard.Text = '' then
    begin
      Raise Exception.Create( 'Clipboard is empty' );
    end
    else
    begin
      Raise Exception.Create( 'Cannot Paste this item here' );
    end;
  end;
end;

function TFormSigFileClipboard.CanPasteFromClipBoard(
  const SigProperty : tSigBaseProperty; var SigValue : string): boolean;
var
  SigProp : string;
  SigIndex : string;
  SigComment : string;
begin
  MemoClipboard.PasteFromClipboard;
  if MemoClipboard.Lines.Count = 0 then
  begin
    Result := FALSE;
    exit;
  end;
  if SigNETParse ( MemoClipboard.Lines[ 0 ], SigProp,
         SigIndex, SigValue, SigComment) then
  begin
    Result := SigProperty.IsMe( SigProp, SigIndex );
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TFormSigFileClipboard.CopyToClipBoard(const SigProperty: tSigBaseProperty);
begin
  SigProperty.Save( MemoClipboard.Lines );
  MemoClipboard.CopyToClipboard;
end;

function TFormSigFileClipboard.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

end.
