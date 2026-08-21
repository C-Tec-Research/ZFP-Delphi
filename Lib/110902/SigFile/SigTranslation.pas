unit SigTranslation;

interface

uses
  SigFile,
  SysUtils,
  Classes,
  ErrorList,
  Controls,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  Buttons,
  Forms,
  Windows;

type
  TSigTranslation = class( tSigCompoundProperty )
     // a specialised 'array' where the indexes are English words or phrases
     // and the 'value' is the translated value.
     // If an element is called with an unknown value, the same value
     // (i.e. no translation) is returned.
     // This is case sensitive.
  private
    procedure TranslateLabel(iControl: tLabel);
    procedure TranslateTabSheet(iControl: tTabSheet);
    procedure TranslateForm(iControl: tForm);
    procedure TranslatePanel(iControl: tPanel);
    procedure TranslateButton(iControl: tButton);
    procedure TranslateBitBtn(iControl: tBitBtn);
  public
    function Translate(const s: string): string;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    class function ClassType : string; override;
    property Entry[ const s : string ] : string
             read Translate; default;
    procedure Add( const pEnglish, pTranslation : string );
    function CreateChild( const pPropertyText : string; const pIndexText : string;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; override;
    function Delete( const pEnglish : string ) : boolean; reintroduce;
    procedure Sort;
    procedure TranslateWinComponent( iControl : tComponent ); // translates regular windows components
    class function ChildMustExist : boolean; override;
  end;

implementation

function SortCompare(pItem1, pItem2: pointer ): Integer;
var
  Item1, Item2: tSigSimpleProperty;
begin
  Item1 := tSigSimpleProperty( pItem1 );
  Item2 := tSigSimpleProperty( pItem2 );
  Result := AnsiCompareStr( Item1.Index, Item2.Index );
end;

{ TSigTranslation }

procedure TSigTranslation.Add(const pEnglish, pTranslation: string);
var
  i: Integer;
  iItem : tSigSimpleProperty;
begin
  with Children do
  begin
    for i := 0 to Count - 1 do
    begin
      if Item[ i ].Index = pEnglish then
      begin
        raise exception.Create( 'Duplicate Translation Entry' );
      end;
    end;
    iItem := tSigSimpleProperty.Create( 'Item', pEnglish, self ); // this implicitely adds to self
    iItem.Value := pTranslation;
  end;
end;

class function TSigTranslation.ChildMustExist: boolean;
begin
  Result := FALSE;
end;

class function TSigTranslation.ClassType: string;
begin
  Result := 'Translator'
end;

constructor TSigTranslation.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

end;

function TSigTranslation.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
begin
  if SameText( pPropertyText, 'Item') then
  begin
    Result := tSigSimpleProperty.Create( 'Item', pIndexText, self );
    Result.Value := pValue;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigTranslation.Delete(const pEnglish: string): boolean;
var
  i: Integer;
begin
  with Children do
  begin
    for i := 0 to Count - 1 do
    begin
      if Item[ i ].Index = pEnglish then
      begin
        Delete( i );
        Result := TRUE;
        exit;
      end;
    end;
  end;
  // not found
  Result := FALSE;
end;

procedure TSigTranslation.Sort;
begin
  Children.Sort( SortCompare );
  IsDirty := TRUE;
end;

function TSigTranslation.Translate(const s: string): string;
var
  i: Integer;
begin
  if s<> '' then
  begin
    with Children do
    begin
      for i := 0 to Count - 1 do
      begin
        if Item[ i ].Index = s then
        begin
          Result := Item[ i ].Value;
          if Result = '' then
          begin
            Result := s;
          end;
          exit;
        end;
      end;
    end;
    // else
    Add( s, '' );
  end;
  Result := s;
end;

procedure TSigTranslation.TranslateWinComponent(iControl: tComponent);
var
  i: Integer;
begin
  if iControl is TButton then
  begin
    TranslateButton( iControl as tButton );
  end
  else if iControl is TBitBtn then
  begin
    TranslateBitBtn( iControl as tBitBtn );
  end
  else if iControl is TLabel then
  begin
    TranslateLabel( iControl as tLabel );
  end
  else if iControl is TForm then
  begin
    TranslateForm( iControl as tForm );
  end
  else if iControl is TPanel then
  begin
    TranslatePanel( iControl as tPanel );
  end
  else if iControl is TTabSheet then
  begin
    TranslateTabSheet( iControl as tTabSheet );
  end;

  if iControl is TWinControl then
  begin
    with iControl as TWinControl do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        TranslateWinComponent( Components[ i ] );
      end;
    end;
  end;
end;

procedure TSigTranslation.TranslateLabel(iControl: tLabel);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

procedure TSigTranslation.TranslateButton(iControl: tButton);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

procedure TSigTranslation.TranslateBitBtn(iControl: tBitBtn);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

procedure TSigTranslation.TranslateTabSheet(iControl: tTabSheet);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

procedure TSigTranslation.TranslateForm(iControl: tForm);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

procedure TSigTranslation.TranslatePanel(iControl: tPanel);
begin
  iControl.Caption := Translate( iControl.Caption );
end;

end.
