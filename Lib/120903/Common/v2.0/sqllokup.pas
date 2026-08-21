unit Sqllokup;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, DBTables;

type
  TSQLLookUpMode = ( luManual,
                     luOnFirstDropDown,
                     luOnEveryDropDown );

type
  TSQLLookUp = class(TComboBox)
  private
    { Private declarations }
    iDropListQuery : TQuery;
    iSecondaryQuery : TQuery;
    iSecondarySQLStatement : TStrings;

    iOnChange : TNotifyEvent; {Passed On}
    iOnDropDown : TNotifyEvent; {Passed On}

    iSQLLookUpMode : TSQLLookUpMode;

    iDropDownHasBeenCreated : Boolean;

    procedure pCreateDropDown;

    procedure pNewOnChange( Sender: TObject);
    procedure pNewOnDropDown( Sender: TObject );

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    property OnChange
             read iOnChange
             write iOnChange;
    property OnDropDown : TNotifyEvent {Passed On}
             read iOnDropDown
             write iOnDropDown;
    procedure ForceRefresh;
  published
    { Published declarations }
    property DropListQuery : TQuery
             read iDropListQuery
             write iDropListQuery;
    property SecondaryQuery : TQuery
             read iSecondaryQuery
             write iSecondaryQuery;
    property SecondarySQLStatement : TStrings
             read iSecondarySQLStatement
             write iSecondarySQLStatement;
    property Style
             default csDropDownList;
    property SQLLookUpMode : TSQLLookUpMode
             read iSQLLookUpMode
             write iSQLLookUpMode
             default luOnFirstDropDown;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSQLLookUp]);
end;

constructor TSQLLookUp.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  Style := csDropDownList;
  SQLLookUpMode := luOnFirstDropDown;
  { No list box yet created }
  iDropDownHasBeenCreated := False;
  { take over the inherited events }
  inherited OnChange := pNewOnChange;
  inherited OnDropDown := pNewOnDropDown;
end;

procedure TSQLLookUp.pNewOnChange( Sender: TObject);
begin
  { Apply the users OnChange function, if any.
    Normally this will be used to change the
    value of SecondarySQL statement}
  if Assigned( iOnChange ) then iOnChange( Sender );
  { Check that a secondary SQL is defined...}
  if Assigned( iSecondaryQuery ) then with iSecondaryQuery do
  begin
    { Check that a string has been set up }
    if SecondarySQLStatement.count > 0 then
    begin
      { Close }
      Active := False;
      { Assign }
      SQL.Assign( SecondarySQLStatement );
      { attempt to open }
      Active := True;
    end;
  end;
end;

procedure TSQLLookUp.pNewOnDropDown( Sender: TObject );
begin
  if Assigned( iOnDropDown ) then iOnDropDown( Sender );
  if (SQLLookUpMode = luOnEveryDropDown)
     or ((SQLLookUpMode = luOnFirstDropDown)
     and not iDropDownHasBeenCreated) then pCreateDropDown;
end;

procedure TSQLLookUp.pCreateDropDown;
begin
  if Assigned( iDropListQuery ) then with iDropListQuery do
  begin
    { Close the SQL to cancel current query }
    Active := False;
    { Execute the query }
    Active := True;
    { Empty the list box }
    Items.Clear;
    { Go to start of file }
    First;
    while not EOF do
    begin
      { Add first field entry to list box }
      Items.Add( Fields[0].Text );
      { Go to next record }
      Next;
    end;
    iDropDownHasBeenCreated := TRUE;
  end;
end;

procedure TSQLLookUp.ForceRefresh;
begin
  iDropDownHasBeenCreated := TRUE;
end;

end.
