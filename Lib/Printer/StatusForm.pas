unit StatusForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TStatForm = class(TForm)
    StatusBar1: TStatusBar;
  private
    { Private declarations }
    function  GetStat(index: integer): string;
    procedure SetStat(index: integer; s: string);
  public
    { Public declarations }
    property Stat[index:integer]:string read GetStat write SetStat;
  end;

var
  StatForm: TStatForm;

implementation

{$R *.DFM}

function TStatForm.GetStat(index: integer): string;
begin
   Result := StatusBar1.Panels[index].Text;
end;

procedure TStatForm.SetStat(index: integer; s: string);
begin
   StatusBar1.Panels[index].Text := s;
   StatusBar1.Update;
end;

end.
