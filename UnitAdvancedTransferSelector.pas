unit UnitAdvancedTransferSelector;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls,
  Vcl.Buttons,
  UnitFiles,
  UnitPCCfgFile;

type
  TFormAdvancedTransferSelector = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PanelNodes: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    CheckListBoxAMNodes: TCheckListBox;
    CheckListBoxAMFileSets: TCheckListBox;
    MemoAdvancedTransferUsage: TMemo;
    SpeedButtonSendToPanels: TSpeedButton;
    SpeedButtonRetrieveData: TSpeedButton;
    BitBtnCancel: TBitBtn;
    procedure FormResize(Sender: TObject);
    procedure SpeedButtonSendToPanelsClick(Sender: TObject);
    procedure SpeedButtonRetrieveDataClick(Sender: TObject);
  private
    { Private declarations }
    function BuildNodes( pFile : tZFPFile ) : boolean;
    function BuildFiles( pFile : tXFP4PgmCfg ) : boolean;
  public
    { Public declarations }
    function Execute( pFile : tZFPFile; pCfgFile : tXFP4PgmCfg ) : tModalResult;
  end;

var
  FormAdvancedTransferSelector: TFormAdvancedTransferSelector;

const
  mrSend = 255;
  mrRcv = 254;

implementation

{$R *.dfm}

function TFormAdvancedTransferSelector.BuildFiles( pFile : tXFP4PgmCfg ): boolean;
var
  i: integer;
begin
  CheckListBoxAMFileSets.Clear;
  with pFile.UserTransferObjects do
  begin
    for i := 0 to Max do
    begin
      CheckListBoxAMFileSets.AddItem( AdvancedTransfer[ i ].Name, AdvancedTransfer[ i ] );
    end;
  end;
  Result := CheckListBoxAMFileSets.Count > 0;
end;

function TFormAdvancedTransferSelector.BuildNodes( pFile : tZFPFile ): boolean;
var
  i: integer;
begin
  CheckListBoxAMNodes.Clear;
  with pFile.NodeList do
  begin
    for i := 0 to Max do
    begin
      CheckListBoxAMNodes.AddItem( Node[ i ].Name1.Value, Node[ i ] );
    end;
  end;
  Result := CheckListBoxAMNodes.Count > 0;
end;

function TFormAdvancedTransferSelector.Execute( pFile : tZFPFile; pCfgFile : tXFP4PgmCfg ): tModalResult;
begin
  if BuildNodes( pFile ) and BuildFiles( pCfgFile ) then
  begin
    Result := ShowModal;
  end
  else
  begin
    Result := mrCancel;
  end;
end;

procedure TFormAdvancedTransferSelector.FormResize(Sender: TObject);
begin
  PanelNodes.Width := ClientWidth div 2;
end;

procedure TFormAdvancedTransferSelector.SpeedButtonRetrieveDataClick(
  Sender: TObject);
begin
  FormAdvancedTransferSelector.ModalResult := mrRcv;
end;

procedure TFormAdvancedTransferSelector.SpeedButtonSendToPanelsClick(
  Sender: TObject);
begin
  FormAdvancedTransferSelector.ModalResult := mrSend;
end;

end.
