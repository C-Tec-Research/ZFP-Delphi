unit SigSaveDialog;

interface

uses
  SysUtils,
  Classes,
  Dialogs,
  UnitFileNotSaved,
  Controls,
  SigRegistry;

type
  TOnSave = procedure (Sender : tObject; var pOK : boolean; const pFileName : string ) of object;
  TOnLoad = procedure (Sender : tObject; var pOK : boolean; const pFileName : string ) of object;
  TOnHistoryChange = procedure( Sender : tObject ) of object;

type
  TSigSaveDialog = class(TSaveDialog)
  private
    fDirty: boolean;
    fSigRegistry: tSigRegistry;
    fOnHistoryChange: tOnHistoryChange;
    fOpenDialog: TOpenDialog;
    fOnSave: TOnSave;
    fOnLoad: TOnLoad;
    fNotSavedCaption: string;
    fFormFileNotSaved: TFormFileNotSaved;
    fNotSavedLabel: string;
    f_Yes: string;
    f_No: string;
    f_Cancel: string;
    fFullFileName: string;
    function GetOpenDialog: TOpenDialog;
    procedure SetNotSavedCaption(const Value: string);
    procedure SetNotSavedLabel(const Value: string);
    procedure Set_Yes(const Value: string);
    procedure Set_No(const Value: string);
    procedure Set_Cancel(const Value: string);
    procedure SetFilterIndex(const Value: integer);
    { Private declarations }
  protected
    { Protected declarations }
    procedure SetFile( pFileName : string );
    property FormFileNotSaved : TFormFileNotSaved
             read fFormFileNotSaved;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    function SaveIfDirty : boolean; // returns TRUE if saved, or said not to save; false if not saved and Cancel pressed
    function Save( pFileName : string ) : boolean;  overload;
    function SaveAs( pFileName : string ) : boolean; overload;
    function Save : boolean;  overload;
    function SaveAs : boolean; overload;
    function Load( pFileName : string ) : boolean;  overload;
    function Load : boolean;  overload;
    property OpenDialog : TOpenDialog
             read GetOpenDialog;
    property Dirty : boolean
             read fDirty
             write fDirty
             default FALSE;
  published
    { Published declarations }
    property SigRegistry : tSigRegistry
             read fSigRegistry
             write fSigRegistry;
    property OnSave : TOnSave
             read fOnSave
             write fOnSave;
    property OnLoad : TOnLoad
             read fOnLoad
             write fOnLoad;
    property OnHistoryChange : tOnHistoryChange
             read fOnHistoryChange
             write fOnHistoryChange;
    property NotSavedCaption : string
             read fNotSavedCaption
             write SetNotSavedCaption;
    property NotSavedLabel : string
             read fNotSavedLabel
             write SetNotSavedLabel;
    property _Yes : string
             read f_Yes
             write Set_Yes;
    property _No : string
             read f_No
             write Set_No;
    property _Cancel : string
             read f_Cancel
             write Set_Cancel;
    property FullFileName : string
             read fFullFileName;
    property FilterIndex
             write SetFilterIndex;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigSaveDialog]);
end;

{ TSigSaveDialog }

function TSigSaveDialog.Save(pFileName: string): boolean;
begin
  if pFileName = '' then
  begin
    Result := SaveAs( pFileName );
  end
  else
  begin
    Result := TRUE;
    if Assigned( OnSave ) then
    begin
      OnSave( self, Result, pFileName );
    end;
    if Result then
    begin
      if assigned( SigRegistry) then
      begin
        SigRegistry.SetHistory( pFileName );
        if assigned( fOnHistoryChange ) then
        begin
          fOnHistoryChange( self );
        end;
      end;
    end;
  end;
end;

function TSigSaveDialog.SaveAs(pFileName: string): boolean;
begin
  SetFile( pFileName );
  Result := SaveAs;
end;

function TSigSaveDialog.SaveAs: boolean;
begin
  if Execute then
  begin
    Result := Save( FileName );
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TSigSaveDialog.SaveIfDirty: boolean;
begin
  if Dirty then
  begin
    while True do
    begin
      if not assigned( fFormFileNotSaved) then
      begin
        fFormFileNotSaved := TFormFileNotSaved.Create( self );
        SetNotSavedCaption( fNotSavedCaption );
        SetNotSavedLabel( fNotSavedLabel );
        Set_Yes( f_Yes );
        Set_No( f_No );
      end;
      case fFormFileNotSaved.ShowModal of
        mrYes:
        begin
          Result := Save;
          if Result then
          begin
            exit;
          end;
        end;
        mrNo:
        begin
          Result := TRUE;
          Dirty := FALSE;
          exit;
        end;
        mrCancel:
        begin
          Result := FALSE;
          exit;
        end;
      end;
    end;
  end
  else
  begin
    Result := TRUE;
  end;
end;

procedure TSigSaveDialog.SetFile(pFileName: string);
var
  iInitDir : string;
  iInitFile : string;
begin
  fFullFileName := pFileName;
  iInitDir := ExtractFilePath( pFileName );
  iInitFile := ExtractFileName( pFileName );
  fOpenDialog.FileName := iInitFile;
  FileName := iInitFile;
  if iInitDir <> '' then
  begin
    fOpenDialog.InitialDir := iInitDir;
    InitialDir := iInitDir;
  end;
end;

procedure TSigSaveDialog.SetFilterIndex(const Value: integer);
begin
  inherited FilterIndex := Value;
  fOpenDialog.FilterIndex := Value;
end;

procedure TSigSaveDialog.SetNotSavedCaption(const Value: string);
begin
  fNotSavedCaption := Value;
  if assigned( fFormFileNotSaved ) then
  begin
    if Value = '' then
    begin
      FormFileNotSaved.Caption := 'File Not Saved'
    end
    else
    begin
      FormFileNotSaved.Caption := Value;
    end;
  end;
end;

procedure TSigSaveDialog.SetNotSavedLabel(const Value: string);
begin
  fNotSavedLabel := Value;
  if assigned( fFormFileNotSaved ) then
  begin
    if Value = '' then
    begin
      FormFileNotSaved.LabelNotSavedWarning.Caption := 'The file has not been save. Save Now?'
    end
    else
    begin
      FormFileNotSaved.LabelNotSavedWarning.Caption := Value;
    end;
  end;
end;

procedure TSigSaveDialog.Set_Cancel(const Value: string);
begin
  f_Cancel := Value;
  if assigned( fFormFileNotSaved ) then
  begin
    if Value = '' then
    begin
      FormFileNotSaved.BitBtnCancel.Caption := 'Cancel'
    end
    else
    begin
      FormFileNotSaved.BitBtnNo.Caption := Value;
    end;
  end;
end;

procedure TSigSaveDialog.Set_No(const Value: string);
begin
  f_No := Value;
  if assigned( fFormFileNotSaved ) then
  begin
    if Value = '' then
    begin
      FormFileNotSaved.BitBtnNo.Caption := '&No'
    end
    else
    begin
      FormFileNotSaved.BitBtnNo.Caption := Value;
    end;
  end;
end;

procedure TSigSaveDialog.Set_Yes(const Value: string);
begin
  f_Yes := Value;
  if assigned( fFormFileNotSaved ) then
  begin
    if Value = '' then
    begin
      FormFileNotSaved.BitBtnYes.Caption := '&Yes'
    end
    else
    begin
      FormFileNotSaved.BitBtnYes.Caption := Value;
    end;
  end;
end;

constructor TSigSaveDialog.Create(AOwner: TComponent);
begin
  inherited;
  fOpenDialog := TOpenDialog.Create( self );
end;

function TSigSaveDialog.Load(pFileName: string): boolean;
begin
  Result := TRUE;
  if Assigned( OnLoad ) then
  begin
    OnLoad( self, Result, pFileName );
  end;
  if Result then
  begin
    if assigned( SigRegistry) then
    begin
      SigRegistry.SetHistory( pFileName );
      if assigned( fOnHistoryChange ) then
      begin
        fOnHistoryChange( self );
      end;
    end;
  end;
  SetFile( pFileName ); // don't change filename until after it is used!
end;

function TSigSaveDialog.GetOpenDialog: TOpenDialog;
begin
  Result := fOpenDialog;
  // copy values
  Result.DefaultExt := DefaultExt;
  Result.Filter := Filter;
end;

function TSigSaveDialog.Load: boolean;
begin
  Result := SaveIfDirty;
  if Result then
  begin
    Result := OpenDialog.Execute;
  end;
  if Result then
  begin
    Load( fOpenDialog.FileName );
  end;
end;

function TSigSaveDialog.Save: boolean;
begin
  Result := Save( FullFileName );
end;

end.
