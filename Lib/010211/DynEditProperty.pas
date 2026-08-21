unit DynEditProperty;

{ Handles DynEditProperty type }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TDynEditProperty = class(TObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iName, iValue, iComment : string;
  public
    { Public declarations }
    constructor Create( Name, Value : string ); virtual;
    procedure Save( var F : TextFile );

    property Name : string
             read iName;
    property Value : string
             read iValue
             write iValue;
    property Comment : string
             read iComment
             write iComment;

  published
    { Published declarations }
end;

type TDynEditList = class( TList )
  protected
    iIndent, iIndentUnit : integer;
  public
    procedure WriteIndent( var F : TextFile );
end;

type
  TDynEditPropertyList = class(TDynEditList)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function fGetPropertyItem( index : integer ) : TDynEditProperty;
    procedure fSetPropertyValue( index, Value : string );
    function fGetPropertyValue( index : string ) : string;
  public
    { Public declarations }
    constructor Create; virtual;
    procedure Save( var F : TextFile; Indent, IndentUnit : integer );
    property DynEditPropertyItem[ index : integer ] : TDynEditProperty
             read fGetPropertyItem;
    property DynEditProperty[ index : string ] : string
             read fGetPropertyValue
             write fSetPropertyValue;
  published
    { Published declarations }
end;

implementation

constructor TDynEditProperty.Create( Name, Value : string );
begin
  iName := Name;
  iValue := Value;
end;

procedure TDynEditProperty.Save( var F : TextFile );
begin
  WriteLn( F, iName + ' = ' + iValue );
end;

function TDynEditPropertyList.fGetPropertyItem( index : integer ) : TDynEditProperty;
begin
  result := Items[ index ];
end;

constructor TDynEditPropertyList.Create;
begin
  inherited Create;
end;

procedure TDynEditPropertyList.Save( var F : TextFile; Indent, IndentUnit : integer );
var
  i : integer;
begin
  iIndent := Indent;
  iIndentUnit := IndentUnit;
  for i:= 0 to Count - 1 do
  begin
    WriteIndent( F );
    WriteLn( F, DynEditPropertyItem[ i ].Name + ' = ' + DynEditPropertyItem[ i ].Value);
  end;
end;

procedure TDynEditPropertyList.fSetPropertyValue( index, Value : string );
var
  i : integer;
begin
  { this can both create and amend a property. Useful for allowing
    a user to add their own custom properties not used by the
    application as well as simplifying application usage }
  for i := 0 to Count - 1 do
  begin
    if CompareText( DynEditPropertyItem[ i ].Name, index ) = 0 then
    begin
      DynEditPropertyItem[ i ].Value := Value;
      Exit;
    end;
  end;
  { if we get here, entry does not exist }
  Add( TDynEditProperty.Create( index, Value ));
end;

function TDynEditPropertyList.fGetPropertyValue( index : string ) : string;
var
  i : integer;
begin
  { finds the value of property with given name. If it cannot find a
    name, edits empty string }
  Result := '';
  for i := 0 to Count - 1 do
  begin
    if CompareText( DynEditPropertyItem[ i ].Name, index ) = 0 then
    begin
      Result := DynEditPropertyItem[ i ].Value;
      Exit;
    end;
  end;
  { if we get here, entry does not exist }
end;

procedure TDynEditList.WriteIndent( var F : TextFile  );
var
  i : integer;
begin
  for i := 1 to iIndent * iIndentUnit do
  begin
    Write( F, ' ');
  end;
end;


end.
