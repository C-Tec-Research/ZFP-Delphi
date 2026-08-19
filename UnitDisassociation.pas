unit UnitDisassociation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  UnitPCCfgFile;

type
  tDisassociationResult = ( drMoveToNewZone, drShowErrors, drAbort );

  TFormDissociation = class(TForm)
    MemoNotes: TMemo;
    Label1: TLabel;
    RadioGroupCorrection: TRadioGroup;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute( const pDisassociationType : string ) : tDisassociationResult;
  const
    cText1 = 'You are attempting to remove the association between a panel and a %s but there are devices on the panel that use this %s. This is not permitted.';
    cText2 = 'You may do one of the following:';
    cOptText1 = 'Move all devices in this zone on this panel to a different %s (recommended)';
    cOptText2 = 'Show Errors';
    cOptText3 = 'Abort';
  end;

var
  FormDissociation: TFormDissociation;

implementation

{$R *.dfm}

{ TFormDissociation }

function TFormDissociation.Execute( const pDisassociationType : string ): tDisassociationResult;
var
  iString : string;
begin
  // set up the components
  iString := XFP4PgmCfg.Translate( cText1 );
  MemoNotes.Text := Format( iString, [pDisassociationType, pDisassociationType] );   // 2 occurrences in string
  with MemoNotes.Lines do
  begin
    Add('');
    Add(XFP4PgmCfg.Translate( cText2 ));
  end;
  with RadioGroupCorrection.Items do
  begin
    Clear;
    iString := XFP4PgmCfg.Translate( cOptText1 );
    Add( Format( iString, [pDisassociationType] ));
    Add( XFP4PgmCfg.Translate( cOptText2 ));
    Add( XFP4PgmCfg.Translate( cOptText3 ));
  end;
  RadioGroupCorrection.ItemIndex := 0;

  if ShowModal = mrOK then
  begin
    Result := tDisassociationResult( RadioGroupCorrection.ItemIndex );
  end
  else
  begin
    Result := drAbort;
  end;
end;

end.
