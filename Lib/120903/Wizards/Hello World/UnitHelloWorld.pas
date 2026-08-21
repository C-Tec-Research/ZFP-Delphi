unit UnitHelloWorld;

interface

uses
  Windows,
  Dialogs,
  ExptIntf;

type
  tHelloWorldExpert = class( TIExpert )
  private
  public
    { Expert UI strings }
    function GetName: string; override; stdcall;
    function GetAuthor: string; override; stdcall;
    function GetComment: string; override; stdcall;
    function GetPage: string; override; stdcall;
{$IFDEF MSWINDOWS}
    function GetGlyph: HICON; override; stdcall;
{$ENDIF}
{$IFDEF LINUX}
    function GetGlyph: Cardinal; override; stdcall;
{$ENDIF}
    function GetStyle: TExpertStyle; override; stdcall;
    function GetState: TExpertState; override; stdcall;
    function GetIDString: string; override; stdcall;
    function GetMenuText: string; override; stdcall;

    { Launch the Expert }
    procedure Execute; override; stdcall;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterLibraryExpert( tHelloWorldExpert.Create );
end;

{ tHelloWorldExpert }

procedure tHelloWorldExpert.Execute;
begin
  inherited;
  MessageDlg('Hello World', mtWarning, [mbOK], 0 );
end;

function tHelloWorldExpert.GetAuthor: string;
begin
  Result := 'SigNET (AC) Ltd.';
end;

function tHelloWorldExpert.GetComment: string;
begin
  Result := 'Ubiquetous Hello World Wizard!';
end;

function tHelloWorldExpert.GetGlyph: HICON;
begin
  Result := 0;
end;

function tHelloWorldExpert.GetIDString: string;
begin
  Result := 'SigNET.HelloWorld';
end;

function tHelloWorldExpert.GetMenuText: string;
begin
  Result := 'Hello &World';
end;

function tHelloWorldExpert.GetName: string;
begin
  Result := 'Hello World';
end;

function tHelloWorldExpert.GetPage: string;
begin
  Result := '';
end;

function tHelloWorldExpert.GetState: TExpertState;
begin
  Result := [esEnabled];
end;

function tHelloWorldExpert.GetStyle: tExpertStyle;
begin
  Result := esStandard;
end;

end.
