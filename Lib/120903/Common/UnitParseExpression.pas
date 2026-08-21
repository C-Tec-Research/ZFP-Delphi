unit UnitParseExpression;

interface

uses
  System.AnsiStrings,
  System.SysUtils,
  Classes,
  UnitSigStrings;

type
  tCurrExp = ( ce_None, ce_Alphanum, ce_Op, ce_OpenBrace, ce_CloseBrace, ce_OpenSquareBrace,
               ce_CloseSquareBrace, ce_Quote );

type
  tParseExpressionType = ( pet_Empty, pet_BracketedExpression, pet_Name, pet_NonaryExpression, pet_UnaryExpression, pet_BinaryExpression );

  tParseExpression = class
  private
    fExpressionType: tParseExpressionType;
    fRightChild: tParseExpression;
    fExpression: string;
    fLeftChild: tParseExpression;
    fParent: tParseExpression;
    procedure CreateCommon( var pString : string );
    procedure UpdateCommon( var pString : string );
  public
    property ExpressionType : tParseExpressionType
             read fExpressionType;
    property Expression : string
             read fExpression;
    property LeftChild : tParseExpression
             read fLeftChild;
    property RightChild : tParseExpression
             read fRightChild;

    property Parent : tParseExpression
             read fParent;

    constructor Create( var pExpression : string; const pParent : tParseExpression = nil );

    procedure DemoteSelfToLeftChild;
    procedure PromoteRightChildToSelf;
    destructor Destroy; override;
  end;

procedure ParseExpression( const pExpression : string; pParsedList : tStrings );  overload // add to pParsed List so remember to clear before entry
function ParseExpression( var pExpression : string; var pResult : string ) : tCurrExp; overload;

implementation

function ParseExpression( var pExpression : string; var pResult : string ) : tCurrExp;
var
  i : integer;
begin
  Result := ce_None;
  pResult := '';
  pExpression := Trim( pExpression );
  i := 0;
  while i < Length( pExpression ) do
  begin
    inc( i );
    case pExpression[ i ] of
      ' ':
      begin
        pResult := Trim( Copy( pExpression, 1, i-1 ));
        pExpression := Trim( Copy( pExpression, i + 1, Length( pExpression )));
        exit;
      end;
      '(':
      begin
        if i > 1 then
        begin
          pResult := Trim( Copy( pExpression, 1, i-1 ));
          pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
        end
        else
        begin
          Result := ce_OpenBrace;
          pResult := Copy( pExpression, 1, 1 );
          pExpression := Trim( Copy( pExpression, 2, Length( pExpression )));
        end;
        exit;
      end;
      ')':
      begin
        if i > 1 then
        begin
          pResult := Trim( Copy( pExpression, 1, i-1 ));
          pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
          exit;
        end
        else
        begin
          Result := ce_CloseBrace;
          pResult := Copy( pExpression, 1, 1 );
          pExpression := Trim( Copy( pExpression, 2, Length( pExpression )));
        end;
        exit;
      end;
      '[':
      begin
        if i > 1 then
        begin
          pResult := Trim( Copy( pExpression, 1, i-1 ));
          pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
        end
        else
        begin
          Result := ce_OpenSquareBrace;
          pResult := Copy( pExpression, 1, 1 );
          pExpression := Trim( Copy( pExpression, 2, Length( pExpression )));
        end;
        exit;
      end;
      ']':
      begin
        if i > 1 then
        begin
          pResult := Trim( Copy( pExpression, 1, i-1 ));
          pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
        end
        else
        begin
          Result := ce_CloseSquareBrace;
          pResult := Copy( pExpression, 1, 1 );
          pExpression := Trim( Copy( pExpression, 2, Length( pExpression )));
        end;
        exit;
      end;
      '''', '"':
      begin
        if i > 1 then
        begin
          pResult := Trim( Copy( pExpression, 1, i-1 ));
          pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
        end
        else
        begin
          Result := ce_Quote;
          pResult := Copy( pExpression, 1, 1 );
          pExpression := Trim( Copy( pExpression, 2, Length( pExpression )));
        end;
        exit;
      end;
      '>', '<', '=', '+', '-', ',', '*', '/':
      begin
        case Result of
          ce_None:
          begin
            Result := ce_Op;
          end;
          ce_Alphanum:
          begin
            pResult := Trim( Copy( pExpression, 1, i-1 ));
            pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
            exit;
          end;
          ce_Op:
          begin
            // continue
          end;
        end;
      end;
      else
      begin
        // treat as name
        case Result of
          ce_None:
          begin
            Result := ce_AlphaNum;
          end;
          ce_Alphanum:
          begin
            // continue
          end;
          ce_Op:
          begin
            pResult := Trim( Copy( pExpression, 1, i-1 ));
            pExpression := Trim( Copy( pExpression, i, Length( pExpression )));
            exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure ParseExpression( const pExpression : string; pParsedList : tStrings );  // add to pParsed List so remember to clear before entry
var
  iString, iResult : string;
begin
  iString := Trim( pExpression );
  while iString <> '' do
  begin
    ParseExpression( iString, iResult );
    pParsedList.Add( iResult );
  end;
end;

{ tParseExpression }

constructor tParseExpression.Create(var pExpression: string;
  const pParent: tParseExpression);
begin
  inherited Create;
  fParent := pParent;
  CreateCommon( pExpression );
end;

procedure tParseExpression.CreateCommon( var pString : string );
var
  iString, iString1 : string;
begin
  case ParseExpression( pString, iString ) of
    ce_None:
    begin
      fExpressionType :=  pet_Empty;
    end;
    ce_Alphanum:
    begin
      fExpressionType := pet_Name;
      fExpression := iString;
      // done ?
      UpdateCommon( pString );
    end;
    ce_OpenBrace:
    begin
      fExpressionType := pet_BracketedExpression;
      fExpression := iString;
      fLeftChild := tParseExpression.Create( pString, self );
      if pString = '' then
      begin
        raise Exception.Create('Missing Parentheses' );
      end;
      if ParseExpression( pString, iString ) <> ce_CloseBrace then
      begin
        raise Exception.Create('Unbalanced Parenthesed');
      end;
      // else done ?
      if (not assigned( Parent )) or (fParent.fExpressionType <> pet_NonaryExpression) then
      begin
        UpdateCommon( pString );
      end;
    end;
    ce_OpenSquareBrace:
    begin
      fExpressionType := pet_BracketedExpression;
      fExpression := iString;
      fLeftChild := tParseExpression.Create( pString, self );
      if pString = '' then
      begin
        raise Exception.Create('Missing Parentheses' );
      end;
      if ParseExpression( pString, iString ) <> ce_CloseSquareBrace then
      begin
        raise Exception.Create('Unbalanced Parenthesed');
      end;
      // else done ?
      if (not assigned( Parent )) or (Parent.fExpressionType <> pet_NonaryExpression) then
      begin
        UpdateCommon( pString );
      end;
    end;
    ce_Quote,
    ce_Op,
    ce_CloseSquareBrace,
    ce_CloseBrace:
    begin
      raise Exception.Create('Syntax Error');
    end;
  end;
end;

procedure tParseExpression.DemoteSelfToLeftChild;
var
  iNewChild : tParseExpression;
  iString : string;
begin
  iString := '';
  iNewChild := tParseExpression.Create( iString, self );
  if assigned( fLeftChild ) then
  begin
    fLeftChild.fParent := iNewChild;
    iNewChild.fLeftChild := fLeftChild;
  end;
  iNewChild.fExpressionType := fExpressionType;
  iNewChild.fExpression := fExpression;
  if assigned( fRightChild ) then
  begin
    fRightChild.fParent := iNewChild;
    iNewChild.fRightChild := fRightChild;
  end;
  fExpression := '';
  fLeftChild := iNewChild;
  fRightChild := nil;
end;

destructor tParseExpression.Destroy;
begin
  fLeftChild.Free;
  fRightChild.Free;
  inherited;
end;

procedure tParseExpression.PromoteRightChildToSelf;
var
  iTemp : tParseExpression;
begin
{
     Changes
         op1
        /  \
       a   op2
          /  \
         b    c

     To
         op2
        /  \
       op1  c
      /  \
     a    b

  Note that this changes the meaning of the tree and is used to readjust
  ambiguous trees. In this case it changes the equivalent of
  a op1 (b op2 c) to
  (a op 1) op2 c
}

  iTemp := fRightChild.fLeftChild; // b
  if assigned( fParent ) then
  begin
    if fParent.fLeftChild = self then
    begin
      fParent.fLeftChild := fRightChild;
    end
    else if fParent.RightChild = self then
    begin
      fParent.fRightChild := fRightChild;
    end;
  end;
  fRightChild.fParent := self.fParent;
  self.fParent := fRightChild;
  fRightChild.fLeftChild := self;
  self.fRightChild := iTemp;
  self.fRightChild.fParent := self;
end;

procedure tParseExpression.UpdateCommon(var pString: string);
var
  iString, iString1 : string;
begin
  iString1 := pString;
  case ParseExpression( iString1, iString ) of
    ce_CloseBrace,
    ce_CloseSquareBrace,
    ce_None: ; // done
    ce_Alphanum, ce_Op:
    begin
      DemoteSelfToLeftChild;
      fExpressionType := pet_BinaryExpression;
      ParseExpression( pString, iString ); // update pString!
      fExpression := iString;
      fRightChild := tParseExpression.Create( pString, self );
      iString1 := pString;
      case ParseExpression( iString1, iString ) of
        ce_CloseBrace,
        ce_CloseSquareBrace,
        ce_None: ; // done
        else
        begin
          UpdateCommon( pString );
        end;
      end;
    end;
    ce_OpenBrace, ce_OpenSquareBrace:
    begin
      // become a nonary operator
      DemoteSelfToLeftChild;
      fExpressionType := pet_NonaryExpression;
      fExpression := '';
      fRightChild := tParseExpression.Create( pString, self);
      UpdateCommon( pString );
    end;
    ce_Quote:
    begin
      raise Exception.Create('Syntax Error');
    end;
  end;
end;

end.
