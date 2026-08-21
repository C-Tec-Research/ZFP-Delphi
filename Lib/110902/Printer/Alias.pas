unit Alias;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DBTables, ShlObj, ComCtrls;

type
  TAliasForm = class(TForm)
    Panel1: TPanel;
    AliasList: TListBox;
    SelectBut: TButton;
    AddBut: TButton;
    CancelBut: TButton;
    Splitter1: TSplitter;
    ParamMemo: TMemo;
    UpdateBut: TButton;
    StatusBar1: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure SelectButClick(Sender: TObject);
    procedure AliasListClick(Sender: TObject);
    procedure AddButClick(Sender: TObject);
    procedure CancelButClick(Sender: TObject);
    procedure ParamMemoChange(Sender: TObject);
    procedure UpdateButClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CurAlias   : string;
  end;

var
  AliasForm: TAliasForm;

implementation

{$R *.DFM}

procedure TAliasForm.FormShow(Sender: TObject);
begin
   SelectBut.Enabled := False;
   Session.GetAliasNames(AliasList.Items);
   
   AliasList.ItemIndex := AliasList.Items.IndexOf(CurAlias);
   AliasListClick(nil);
end;

procedure TAliasForm.SelectButClick(Sender: TObject);
begin
   CurAlias := AliasList.Items[AliasList.ItemIndex];
   ModalResult := mrOk;
end;

procedure TAliasForm.AliasListClick(Sender: TObject);
var
   i : integer;
begin
   i := AliasList.ItemIndex;
   SelectBut.Enabled := i<>-1;

   if i<>-1 then begin
      Session.GetAliasParams(AliasList.Items[i], ParamMemo.Lines);
   end else
      ParamMemo.Lines.Text := '';
   UpdateBut.Enabled := False;
end;

procedure TAliasForm.AddButClick(Sender: TObject);
var
   bi       : TBrowseInfo;
   pidl     : PItemIDList;
   buf      : array[0..MAX_PATH] of char;
   rc       : boolean;
   NewName  : string;
begin
   NewName := 'New Alias';
   rc := InputQuery('Alias Name', 'Enter a New Name', NewName);
   if not rc then exit;

   FillChar(bi, sizeof(bi), 0);
   bi.lpszTitle := 'Select a directory for the new Database Alias';
   pidl := SHBrowseForFolder(bi);
   if pidl=nil then exit;

   rc := SHGetPathFromIDList(pidl, buf);
   Assert(rc, 'Unable to get Path!');

   Session.AddStandardAlias(NewName, buf, 'PARADOX');
   Session.SaveConfigFile;
   CurAlias := NewName;
   FormShow(nil);
end;

procedure TAliasForm.CancelButClick(Sender: TObject);
begin
   Close;
end;

procedure TAliasForm.ParamMemoChange(Sender: TObject);
begin
   if AliasList.ItemIndex<>-1 then
      UpdateBut.Enabled := True;
end;

procedure TAliasForm.UpdateButClick(Sender: TObject);
var
   i : integer;
begin
   i := AliasList.ItemIndex;
   Assert(i<>-1);

   Session.ModifyAlias(AliasList.Items[i], ParamMemo.Lines);
   Session.SaveConfigFile;
   UpdateBut.Enabled := False;
end;

end.
