unit Proplist;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, PropEdit, SigParse;

type
  PSigProperty = ^TSigProperty;
  TSigProperty = record
                 SigProperty, SigValue,SigComment : string;
end;

type
  TSigPropertyList = class(TList)
  private
    { Private declarations }
    function PropertyIndex( const PropertyName : string ) :
             LongInt;
    procedure fWriteCaption( const NewCaption : string );
    function  fReadCaption : string;
    procedure fWritePropertyTitle
              ( const NewTitle : string );
    function  fReadPropertyTitle : string ;
    procedure fWriteValueTitle
              ( const NewTitle : string );
    function  fReadValueTitle : string ;
    function  fGetSigProperty( Index : integer ) : TSigProperty;
    procedure fSetSigProperty( Index : integer; Value : TSigProperty );

  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure AddProperty( const PropertyName : string;
              const PropertyValue : string;
              const PropertyComment : string);
    function GetProperty( const PropertyName : string ;
             var PropertyValue : string;
             var PropertyComment : string ) : boolean;
    function RemoveProperty( const PropertyName : string) :
             boolean;
    procedure Edit;

    property Caption : string
             read fReadCaption
             write fWriteCaption;

    property PropertyTitle : string
             read fReadPropertyTitle
             write fWritePropertyTitle;

    property ValueTitle : string
             read fReadValueTitle
             write fWriteValueTitle;

    property SigProperty[ Index : integer ] : TSigProperty
             read fGetSigProperty
             write fSetSigProperty;
  end;

implementation

function TSigPropertyList.PropertyIndex( const PropertyName : string ) :
             LongInt;
var
  Temp : PSigProperty;
begin
  for Result := 0 to Count - 1 do
  begin
    { do an item by item non-case sensitive compare }
    if Items[ Result ] <> nil then
    begin
      Temp := PSigProperty(Items[ Result ]);
      if CompareText( PropertyName, Temp^.SigProperty ) =
         0 then Exit;
    end;
  end;
  Result := -1;
end;

procedure TSigPropertyList.AddProperty( const PropertyName : string;
              const PropertyValue : string;
              const PropertyComment : string );
var
  i : integer;
  ToAdd : PSigProperty;
  ToCheck : PSigProperty;
begin
  {Make Sure it does not exist }
  i := PropertyIndex( PropertyName );
  { if it does, just change value }
  if i >= 0 then
  begin
    ToAdd := PSigProperty(Items[ i ]);
    ToAdd^.SigValue := PropertyValue;
  end
  else
  begin
    { Add entry }
    New( ToAdd );
    ToAdd^.SigProperty := PropertyName;
    ToAdd^.SigValue := PropertyValue;
    ToAdd^.SigComment := PropertyComment;
    i := Add( ToAdd );
    {sort - bubble is good enough here}
    while i > 0 do
    begin
      ToAdd := PSigProperty(Items[ i ]);
      ToCheck := PSigProperty(Items[ i-1 ]);
      if CompareText( ToAdd^.SigProperty,
                    ToCheck^.SigProperty ) < 0 then
      begin
        { need to swap }
        Exchange( i, i-1 );
        Dec( i );
      end
      else
      begin
        { terminate test }
        i := 0;
      end;
    end;
  end;
end;

function TSigPropertyList.GetProperty( const PropertyName : string ;
             var PropertyValue : string;
             var PropertyComment : string ) : boolean;
var
  i : integer;
  ToCheck : PSigProperty;
begin
  i := PropertyIndex( PropertyName);
  if i < 0 then {invalid property }
    Result := False
  else
  begin
    { update value }
    ToCheck := PSigProperty(Items[ i ]);
    PropertyValue := ToCheck^.SigProperty;
    PropertyComment := ToCheck^.SigComment;
    Result := True;
  end;
end;

function TSigPropertyList.RemoveProperty( const PropertyName : string) :
             boolean;
var
  i: Integer;
begin
  i := PropertyIndex( PropertyName);
  if i < 0 then {invalid property }
    Result := False
  else
  begin
    { destroy property }
    Dispose( Items[ i ] );
    { delete value }
    Delete( i );
    Pack;
    Result := True;
  end;
end;

procedure TSigPropertyList.Edit;
var
  i : Integer;
  ToCheck : PSigProperty;
  SigProperty : string;
begin
  with DlgPropertyEditor do
  begin
    { clear current }
    for i:=1 to 255 do
    begin
      StringGridProperties.Cells[ 0, i ] := '';
      StringGridProperties.Cells[ 1, i ] := '';
      StringGridProperties.Cells[ 2, i ] := '';
    end;
    { Display Values }
    for i := 1 to Count do
    begin
      ToCheck := PSigProperty(Items[ i - 1 ]);
      if ToCheck = nil then
      begin
        StringGridProperties.Cells[ 0, i ] := '';
        StringGridProperties.Cells[ 1, i ] := '';
        StringGridProperties.Cells[ 2, i ] := '';
      end
      else
      begin
        StringGridProperties.Cells[ 0, i ] := ToCheck^.SigProperty;
        StringGridProperties.Cells[ 1, i ] := ToCheck^.SigValue;
        StringGridProperties.Cells[ 2, i ] := ToCheck^.SigComment;
      end;
    end;
    ShowModal;
    if ModalResult = mrOK then
    begin
      for i := 0 to Count - 1 do
        if Items[i] <> nil then
          Dispose( Items[ i ] );

      Clear;
      for i := 1 to StringGridProperties.RowCount do
      begin
        SigProperty := StripSpace( StringGridProperties.Cells[ 0, i ]);
        { ignore blank entries }
        if SigProperty <> '' then
        begin
          AddProperty( SigProperty,
                       StringGridProperties.Cells[ 1, i ],
                       StringGridProperties.Cells[ 2, i ]);
        end;
      end;
    end;
  end;
end;

procedure TSigPropertyList.fWriteCaption( const NewCaption : string );
begin
  DlgPropertyEditor.Caption := NewCaption;
end;

function  TSigPropertyList.fReadCaption : string;
begin
  Result := DlgPropertyEditor.Caption;
end;

procedure TSigPropertyList.fWritePropertyTitle
          ( const NewTitle : string );
begin
  DlgPropertyEditor.StringGridProperties.Cells[ 0, 0 ] := NewTitle;
end;

function  TSigPropertyList.fReadPropertyTitle : string ;
begin
  Result := DlgPropertyEditor.StringGridProperties.Cells[ 0, 0 ];
end;

procedure TSigPropertyList.fWriteValueTitle
          ( const NewTitle : string );
begin
  DlgPropertyEditor.StringGridProperties.Cells[ 1, 0 ] := NewTitle;
end;

function  TSigPropertyList.fReadValueTitle : string ;
begin
  Result := DlgPropertyEditor.StringGridProperties.Cells[ 1, 0 ];
end;

function  TSigPropertyList.fGetSigProperty( Index : integer ) : TSigProperty;
begin
    Result := TSigProperty( Items[ Index] ^);
end;

procedure TSigPropertyList.fSetSigProperty( Index : integer; Value : TSigProperty );
var
  ToAdd : PSigProperty;
begin
  ToAdd := PSigProperty(Items[ Index ]);
  ToAdd^.SigProperty := Value.SigProperty;
  ToAdd^.SigValue := Value.SigValue;
end;

end.
