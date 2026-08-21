unit FileNotSaved;

interface

uses
  SysUtils, Classes,
  UnitFileNotSaved;

type
  TFileNotSaved = class(TComponent)
  private
    function GetControl3D: boolean;
    procedure SetControl3D(const Value: boolean);
    function GetDefaultExt: string;
    procedure SetDefaultExt(const Value: string);
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    function GetFilter: string;
    procedure SetFilter(const Value: string);
    function GetFilterIndex: integer;
    procedure SetFilterIndex(const Value: integer);
    function GetHelpContext: integer;
    procedure SetHelpContext(const Value: integer);
    function GetInitialDir: string;
    procedure SetInitialDir(const Value: string);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    property Ctl3D : boolean
             read GetControl3D
             write SetControl3D;
    property DefaultExt : string
             read GetDefaultExt
             write SetDefaultExt;
    property FileName : string
             read GetFileName
             write SetFileName;
    property Filter : string
             read GetFilter
             write SetFilter;
    property FilterIndex : integer
             read GetFilterIndex
             write SetFilterIndex;
    property HelpContext : integer
             read GetHelpContext
             write SetHelpContext;
    property InitialDir : string
             read GetInitialDir
             write SetInitialDir;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TFileNotSaved]);
end;

{ TFileNotSaved }

function TFileNotSaved.GetControl3D: boolean;
begin
  Result := FormFileNotSaved.Ctl3D;
end;

function TFileNotSaved.GetDefaultExt: string;
begin
  Result := FormFileNotSaved.DefaultExt;
end;

function TFileNotSaved.GetFileName: string;
begin
  Result := FormFileNotSaved.FileName;
end;

function TFileNotSaved.GetFilter: string;
begin
  Result := FormFileNotSaved.Filter;
end;

function TFileNotSaved.GetFilterIndex: integer;
begin
  Result := FormFileNotSaved.FilterIndex;
end;

function TFileNotSaved.GetHelpContext: integer;
begin
  Result := FormFileNotSaved.HelpContext;
end;

function TFileNotSaved.GetInitialDir: string;
begin
  Result := FormFileNotSaved.InitialDir;
end;

procedure TFileNotSaved.SetControl3D(const Value: boolean);
begin
  FormFileNotSaved.Ctl3D := Value;
end;

procedure TFileNotSaved.SetDefaultExt(const Value: string);
begin
  FormFileNotSaved.DefaultExt := Value;
end;

procedure TFileNotSaved.SetFileName(const Value: string);
begin
  FormFileNotSaved.FileName := Value;
end;

procedure TFileNotSaved.SetFilter(const Value: string);
begin
  FormFileNotSaved.Filter := Value;
end;

procedure TFileNotSaved.SetFilterIndex(const Value: integer);
begin
  FormFileNotSaved.FilterIndex := Value;
end;

procedure TFileNotSaved.SetHelpContext(const Value: integer);
begin
  FormFileNotSaved.HelpContext := Value;
end;

procedure TFileNotSaved.SetInitialDir(const Value: string);
begin
  FormFileNotSaved.InitialDir := Value;
end;

end.
