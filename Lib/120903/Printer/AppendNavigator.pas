unit AppendNavigator;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, DB, DBCtrls, DBConsts;

type
   TAppendNavigator = class(TDBNavigator)
   protected
      procedure   NewButtonClick(Sender: TObject);
   public
      constructor Create(AOwner: TComponent); override;
      procedure   BtnClick(Index: TNavigateBtn);
   end;

procedure Register;

implementation


constructor TAppendNavigator.Create(AOwner: TComponent); 
var
   i : TNavigateBtn;
begin
   inherited;
   for i := Low(Buttons) to High(Buttons) do begin
      Buttons[i].OnClick := NewButtonClick;
   end;
end;

procedure TAppendNavigator.NewButtonClick(Sender: TObject);
begin
   BtnClick(TNavButton(Sender).Index);
end;

procedure TAppendNavigator.BtnClick(Index: TNavigateBtn);
begin
  if (DataSource <> nil) and (DataSource.State <> dsInactive) then
  begin
    if not (csDesigning in ComponentState) and Assigned(BeforeAction) then
      BeforeAction(Self, Index);
    with DataSource.DataSet do
    begin
      case Index of
        nbPrior: Prior;
        nbNext: Next;
        nbFirst: First;
        nbLast: Last;
        nbInsert: Append;     // MODIFICATION by Ben Ziegler (was Insert)
        nbEdit: Edit;
        nbCancel: Cancel;
        nbPost: Post;
        nbRefresh: Refresh;
        nbDelete:
          if not ConfirmDelete or
            (MessageDlg(SDeleteRecordQuestion, mtConfirmation,
            mbOKCancel, 0) <> idCancel) then Delete;
      end;
    end;
  end;
  if not (csDesigning in ComponentState) and Assigned(OnClick) then
    OnClick(Self, Index);
end;


procedure Register;
begin
  RegisterComponents('Samples', [TAppendNavigator]);
end;

end.
