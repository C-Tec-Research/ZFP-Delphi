unit UnitNodeChangeProblems;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.TypInfo,
  UnitFiles,
  UnitPCCfgFile;

type
  tNodeTypeIncompatibility = ( nti_Has_Populated_Normal_Loops, nti_Has_A_Bus_Devices,
                               nti_Max_Devices_of_this_type_aready_fitted );
  tNodeTypeIncompatibilities = set of tNodeTypeIncompatibility;


type
  TFormNodeChangeProblems = class(TForm)
    Panel1: TPanel;
    BitBtnProceedAnyway: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBoxIgnoreSimilarProblems: TCheckBox;
    Panel2: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    EditAddress: TEdit;
    Label2: TLabel;
    EditCurrentType: TEdit;
    ImageNodeCurrentIcon: TImage;
    Image1: TImage;
    EditNewType: TEdit;
    Label3: TLabel;
    LabelFollowingProblemsDetected: TLabel;
    MemoProblemsDetected: TMemo;
    LabelFollowingProblemDetected: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fIgnoredNodeTypeIncompatibilities: tNodeTypeIncompatibilities;
    fTypeInfo : pTypeInfo;
    fTypeData : pTypeData;
  public
    { Public declarations }
    property IgnoredNodeTypeIncompatibilities : tNodeTypeIncompatibilities
             read fIgnoredNodeTypeIncompatibilities
             write fIgnoredNodeTypeIncompatibilities;

    function CanChangeNodeType( const pFrom : tZFPNode ; pToType : tNodalType ) : tNodeTypeIncompatibilities;
             // Returns [] if no incompatibility or incompatibility ignored
    procedure ClearIgnoredIncompatibilities;
    procedure IgnoreIncompatibility( pIncompatibility : tNodeTypeIncompatibility );
    function IgnoringIncompatibilty( pIncompatibility : tNodeTypeIncompatibility ) : boolean;

    function Execute( pNode : tZFPNode; pNewType : tNodalType ) : boolean;
  end;

var
  FormNodeChangeProblems: TFormNodeChangeProblems;

implementation

{$R *.dfm}

{ TFormNodeChangeProblems }

function TFormNodeChangeProblems.CanChangeNodeType(const pFrom: tZFPNode;
  pToType: tNodalType): tNodeTypeIncompatibilities;
var
  i, iMax: Integer;
begin
  Result := [];
  // Returns [] if no incompatibility or incompatibility ignored
  if pFrom.NodalType = pToType then
  begin
    exit; // no further checking required
  end;
  with pFrom.LoopList do
  begin
    for i := 0 to Max do
    begin
      case Loop[ i ].LoopType of
        ltSystem:
        begin
          // always OK at moment, although we may check fixed devices later
        end;
        ltA_Bus{, ltA_Bus_Subdevices}:
        begin
          if not IgnoringIncompatibilty( nti_Has_A_Bus_Devices ) then
          begin
            if Loop[ i ].Max > 0 then
            begin
              // A-Bus is populated
              if not pToType.ShowA_Bus.ValueAsBool then
              begin
                Result := Result + [nti_Has_A_Bus_Devices];
              end;
            end;
          end;
        end;
        ltNormal:
        begin
          if not IgnoringIncompatibilty( nti_Has_Populated_Normal_Loops ) then
          begin
            if Loop[ i ].Max > 0 then
            begin
              iMax := pToType.MaxLoops.ValueAsInt;
               if not Loop[ i ].LoopAddress.ValueAsInt in [1..iMax] then
               begin
                 Result := Result + [nti_Has_Populated_Normal_Loops];
               end;
            end;
          end;
        end;
      end;
    end;
  end;
  with pFrom.OwnerList do
  begin
    if NodeCountOfType( pToType ) >= MaxNodeCountOfType( pToType ) then
    begin
      Result := Result + [nti_Max_Devices_of_this_type_aready_fitted];
    end;
  end;
end;

procedure TFormNodeChangeProblems.ClearIgnoredIncompatibilities;
begin
  fIgnoredNodeTypeIncompatibilities := [];
end;

function TFormNodeChangeProblems.Execute(pNode: tZFPNode;
  pNewType: tNodalType): boolean;
var
  iIncompatibilities : tNodeTypeIncompatibilities;
  i : tNodeTypeIncompatibility;
  iVal : string;
  iPos : integer;
begin
  iIncompatibilities := CanChangeNodeType( pNode, pNewType );
  if iIncompatibilities = [] then
  begin
    Result := TRUE;
    exit;
  end;
  // else
  with MemoProblemsDetected.Lines do
  begin
    Clear;
    for i in iIncompatibilities do
    begin
      iVal := GetEnumName( fTypeInfo, Ord( i ) );
      iPos := Pos( '_', iVal );
      iVal := Copy( iVal, iPos + 1, Length( iVal ));
      iPos := Pos( '_', iVal );
      while iPos > 0 do
      begin
        iVal[ iPos ] := ' ';
        iPos := Pos( '_', iVal );
      end;
      iVal := XFP4PgmCfg.Translate( iVal );
      Add( iVal );
    end;
    LabelFollowingProblemDetected.Visible := Count = 1;
    LabelFollowingProblemsDetected.Visible := not LabelFollowingProblemDetected.Visible
  end;
  EditAddress.Text := IntToStr( pNode.ID );
  EditCurrentType.Text := pNode.NodalType.TypeDescription.Value;
  EditNewType.Text := pNewType.TypeDescription.Value;
  // to do ImageNodeCurrentIcon.Picture
  CheckBoxIgnoreSimilarProblems.Checked := FALSE;
  if nti_Max_Devices_of_this_type_aready_fitted in iIncompatibilities then
  begin
    BitBtnProceedAnyway.Enabled := FALSE;
    CheckBoxIgnoreSimilarProblems.Enabled := FALSE;
  end
  else
  begin
    BitBtnProceedAnyway.Enabled := TRUE;
    CheckBoxIgnoreSimilarProblems.Enabled := TRUE;
  end;
  if ShowModal = mrOK then
  begin
    Result := TRUE;
    if CheckBoxIgnoreSimilarProblems.Checked then
    begin
      fIgnoredNodeTypeIncompatibilities := fIgnoredNodeTypeIncompatibilities + iIncompatibilities;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TFormNodeChangeProblems.FormCreate(Sender: TObject);
begin
  fTypeInfo := TypeInfo( tNodeTypeIncompatibilities );
  fTypeData := GetTypeData( fTypeInfo );
  LabelFollowingProblemDetected.Top := LabelFollowingProblemsDetected.Top;
end;

procedure TFormNodeChangeProblems.IgnoreIncompatibility(
  pIncompatibility: tNodeTypeIncompatibility);
begin
  fIgnoredNodeTypeIncompatibilities := fIgnoredNodeTypeIncompatibilities + [pIncompatibility];
end;

function TFormNodeChangeProblems.IgnoringIncompatibilty(
  pIncompatibility: tNodeTypeIncompatibility): boolean;
begin
  Result := pIncompatibility in fIgnoredNodeTypeIncompatibilities;
end;

end.
