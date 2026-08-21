unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

{
  To Do

  Project change History
}
{
  Notes on setting up project.
  1. Make sure that you set the 'Include version Information in project' checkbox
     in the Version Info page of the project options dialog
  2. Set the version number. This will display on the screen
  3. Set the 'InternalName' field to be what should be displayed at the top of the screen
  4. Set the 'LegalCopyright' field to something like (c) SigNET (AC) Ltd, 2010
  5. Set 'FileDescription' to give a brief description of the application, e.g. 'Edits Remote WCTL'

  MAKE SURE IT LOOKS RIGHT (i.e. none of the fields are too big.
}

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function FindResourceString( const ResourceStream : TResourceStream; const pResource : string ) : string;
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

function TAboutBox.FindResourceString( const ResourceStream : TResourceStream; const pResource: string): string;
var
  NextChar : WideChar;
  i, iMatchLen : integer;
begin
  iMatchLen := 1;
  Result := '';
  ResourceStream.Seek( 0,soFromBeginning );
  for i := 1 to ResourceStream.size do
  begin
    ResourceStream.Read( NextChar, 2 );
    if Nextchar = pResource[ iMatchLen ] then
    begin
      if iMatchLen = Length( pResource ) then
      begin
        ResourceStream.Read( NextChar, 2 );
        while NextChar = WideChar(0) do
          ResourceStream.Read( NextChar, 2 );
        while NextChar <> WideChar(0) do
        begin
          Result := Result + NextChar;
          ResourceStream.Read( NextChar, 2 );
        end;
      end
      else
      begin
        iMatchLen := iMatchLen + 1;
      end;
    end
    else
    begin
      iMatchLen := 1;
    end;
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
var
  ResourceStream : TResourceStream;
  iAppName : string;

begin
  { update version info }
  ResourceStream := TResourceStream.CreateFromID( HInstance, 1, RT_VERSION );
  ProductName.Caption := FindResourceString( ResourceStream, 'InternalName' );
  Version.Caption := 'Version: ' + FindResourceString( ResourceStream, 'FileVersion' );
  Copyright.Caption := FindResourceString( ResourceStream, 'LegalCopyright' );
  Comments.Caption := FindResourceString( ResourceStream, 'FileDescription' );
  ProgramIcon.Picture.Assign( Application.Icon );
  ResourceStream.Free;

  iAppName := ParamStr( 0 );
  Caption := 'About ' + ExtractFileName( iAppName );

end;

end.

