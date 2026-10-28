{$IFNDEF FMX_SIGSAVEDIALOG}
unit SigSaveDialog;
{$ENDIF}

interface

uses
  SysUtils,
  Classes,
{$IFDEF FMX_SIGSAVEDIALOG}
  FMX.Dialogs,
  FMX.UnitFileNotSaved,
  FMX.Controls,
  System.UITypes,
  System.IniFiles;
{$ELSE}
  Dialogs,
  UnitFileNotSaved,
  Controls,
  SigRegistry; // no sigregistry in Firemonkey
{$ENDIF}

type
  TOnSave = procedure (Sender : TObject; var pOK : boolean; const pFileName : string ) of object;
  TOnLoad = procedure (Sender : TObject; var pOK : boolean; const pFileName : string ) of object;
  TOnHistoryChange = procedure( Sender : TObject ) of object;

type
  TSigSaveDialog = class(TSaveDialog)
  private
    fDirty: boolean;
{$IFDEF FMX_SIGSAVEDIALOG}
    fSigINIFile: tINIFile;
{$ELSE}
    fSigRegistry: tSigRegistry;
{$ENDIF}
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
    function GetHistory(const i: integer): string;
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

    procedure SetHistory( const pNewVal : string );
    property History[ const i : integer ] : string
             read GetHistory;
  published
    { Published declarations }
{$IFDEF FMX_SIGSAVEDIALOG}
    property SigINIFile : tINIFile
             read fSigINIFile
             write fSigINIFile;
{$ELSE}
    property SigRegistry : tSigRegistry
             read fSigRegistry
             write fSigRegistry;
{$ENDIF}
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

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TSigSaveDialog]);
end;
{$ENDIF}

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
      SetHistory( pFileName );
      Dirty := FALSE;
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

procedure TSigSaveDialog.SetHistory(const pNewVal: string);
{$IFDEF FMX_SIGSAVEDIALOG}
var
  i : integer;
  iOldFileName : string;
  iNewFileName : string;
{$ELSE}
{$ENDIF}
begin
{$IFDEF FMX_SIGSAVEDIALOG}
  if assigned( fSigINIFile ) then
  begin
    iNewFileName := pNewVal;
    with fSigINIFile do
    begin
      for i := 0 to 9 do
      begin
        iOldFileName := ReadString( 'History', IntToStr( i ), '' );
        if iOldFileName = pNewVal then
        begin
          // done
          exit;
        end
        else
        begin
          WriteString( 'History', IntToStr( i ), iNewFileName );
          iNewFileName := iOldFileName;
        end;
      end;
    end;
    if assigned( fOnHistoryChange ) then
    begin
      fOnHistoryChange( self );
    end;
  end;
{$ELSE}
  if assigned( SigRegistry) then
  begin
    SigRegistry.SetHistory( pNewVal );
    if assigned( fOnHistoryChange ) then
    begin
      fOnHistoryChange( self );
    end;
  end;
{$ENDIF}
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
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.LabelNotSavedWarning.Text := 'The file has not been save. Save Now?'
{$ELSE}
      FormFileNotSaved.LabelNotSavedWarning.Caption := 'The file has not been save. Save Now?'
{$ENDIF}
    end
    else
    begin
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.LabelNotSavedWarning.Text := Value;
{$ELSE}
      FormFileNotSaved.LabelNotSavedWarning.Caption := Value;
{$ENDIF}
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
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonCancel.Text := 'Cancel'
{$ELSE}
      FormFileNotSaved.BitBtnCancel.Caption := 'Cancel'
{$ENDIF}
    end
    else
    begin
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonNo.Text := Value;
{$ELSE}
      FormFileNotSaved.BitBtnNo.Caption := Value;
{$ENDIF}
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
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonNo.Text := 'No';
{$ELSE}
      FormFileNotSaved.BitBtnNo.Caption := '&No';
{$ENDIF}
    end
    else
    begin
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonNo.Text := Value;
{$ELSE}
      FormFileNotSaved.BitBtnNo.Caption := Value;
{$ENDIF}
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
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonYes.Text := 'Yes';
{$ELSE}
      FormFileNotSaved.BitBtnYes.Caption := '&Yes';
{$ENDIF}
    end
    else
    begin
{$IFDEF FMX_SIGSAVEDIALOG}
      FormFileNotSaved.ButtonYes.Text := Value;
{$ELSE}
      FormFileNotSaved.BitBtnYes.Caption := Value;
{$ENDIF}
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
    SetHistory( pFileName );
    Dirty := FALSE;
  end;
  SetFile( pFileName ); // don't change filename until after it is used!
end;

function TSigSaveDialog.GetHistory(const i: integer): string;
begin
{$IFDEF FMX_SIGSAVEDIALOG}
  if assigned( fSigINIFile ) then
  begin
    Result := fSigINIFile.ReadString( 'History', IntToStr( i ), '' );
  end
  else
  begin
    Result := '';
  end;
{$ELSE}
  if assigned( fSigRegistry ) then
  begin
    Result := fSigRegistry.History[ i ];
  end
  else
  begin
    Result := '';
  end;
{$ENDIF}
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
