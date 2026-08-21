unit DataForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, Db, Buttons, ExtCtrls, AppendNavigator;

type
  TGenericDataForm = class(TForm)
    DataSource1: TDataSource;
    BottomPanel: TPanel;
    OKBut: TBitBtn;
    DBNavigator1: TAppendNavigator;
    CancelBut: TBitBtn;
    procedure OKButClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelButClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  protected
    function   IsEditState(State: TDataSetState): boolean;
  public
    { Public declarations }
  end;

var
  GenericDataForm: TGenericDataForm;

implementation

//uses DataMod;

{$R *.DFM}

function TGenericDataForm.IsEditState(State: TDataSetState): boolean;
begin
   Result := (State = dsEdit) or (State = dsInsert);
end;


procedure TGenericDataForm.OKButClick(Sender: TObject);
begin
   if DataSource1.DataSet<>nil then
      if IsEditState(DataSource1.DataSet.State) then
         DataSource1.DataSet.Post;
   ModalResult := mrOK;
end;

procedure TGenericDataForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   rc : integer;
begin
   if DataSource1.DataSet = nil then exit;
   
   if IsEditState(DataSource1.DataSet.State) then begin
      rc := MessageDlg('Current record has been modified, save changes?',
         mtWarning, mbYesNoCancel, 0);
      if rc = mrCancel then begin
         CanClose := False;
         exit;
      end;
      if rc = mrYes then begin
         DataSource1.DataSet.Post;
      end;
      if rc = mrNo then begin
         DataSource1.DataSet.Cancel;
      end;
   end;
end;

procedure TGenericDataForm.CancelButClick(Sender: TObject);
begin
   if DataSource1.DataSet<>nil then
      if IsEditState(DataSource1.DataSet.State) then
         DataSource1.DataSet.Cancel;
   ModalResult := mrCancel;
end;

procedure TGenericDataForm.FormShow(Sender: TObject);
begin
   DataSource1.Enabled := True;
end;

procedure TGenericDataForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   DataSource1.Enabled := False;
end;

procedure TGenericDataForm.FormCreate(Sender: TObject);
begin
   DataSource1.Enabled := False;
end;

end.
