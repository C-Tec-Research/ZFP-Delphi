unit UnitLogFiles;

// used for both the stand-alone logger and the normal tools

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Grids,
  //SigNETStringGrid,
  SigNET.TStringGrid,
  SigPanel;

type
  TFrameLogFiles = class(TFrame)
    Panel2: TPanel;
    TabControlLogs: TTabControl;
    SigPanelLog: TSigPanel;
    MemoLog: TMemo;
    StringGridLog: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
