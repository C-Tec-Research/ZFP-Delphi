unit UnitTemporaryIndexes;

{
  This creates temporary memory based indexes accordind to selection crtiteria
  to perform the equivalent of an SQL memory table. For efficiency these
  are creted based on index files rather than data files.

  The index file has lots of comparitive properties, so where possible
  we use those.
}

interface

uses
  SigDBRawDB,
  SigBTree,
  System.SysUtils,
  System.Generics.Collections;

type
  TIndexEntry = class
  private
    fIndexField: integer;
    fDescending: boolean;
  public
    constructor Create( const pIndexField : integer; const pDescending : boolean = FALSE );
    property FieldIndex : integer
             read fIndexField
             write fIndexField;
    property Descending : boolean
             read fDescending;
  end;

  TIndexCriteria = class( TObjectList< TIndexEntry > )
  public
  end;

  TMemoryIndex< TIndexFile : TSigDBIndexFile > = class;

  TMemoryIndexNode< TIndexFile : TSigDBIndexFile > = class( TSigBTreeNodeMemory )
  private
    fOwner: TMemoryIndex<TIndexFile>;
    fRecNo: TSigDBRecPointer;
  public
    constructor Create( const pOwner : TMemoryIndex< TIndexFile >; const pRecNo : TSigDBRecPointer );
    function LessThan( const SigTreeNode : tSigBTreeNode ) : boolean; override;
    property RecNo : TSigDBRecPointer
             read fRecNo;
    property Owner : TMemoryIndex< TIndexFile >
             read fOwner;
 end;

  TMemoryIndex< TIndexFile : TSigDBIndexFile > = class
  private
    fIndexFile : TIndexFile;
    fIndexCriteria : TIndexCriteria;
    fRoot: TSigDBTreeRoot;
  protected
    function FirstValid( var pCurr : TSigDBIndex ): TSigDBRecPointer; virtual; abstract; // descendant creates optimised version
    function NextValid( var pCurr : TSigDBIndex ) : TSigDBRecPointer; virtual; abstract; // descendant creates optimised version
  public
    constructor Create( const pIndexFile : TIndexFile ); virtual;
    destructor Destroy; override;

    property IndexCriteria : TIndexCriteria
             read fIndexCriteria;
    property Root : TSigDBTreeRoot
             read fRoot;
    property IndexFile : TIndexFile
             read fIndexFile;


    procedure Rebuild;
  end;


implementation

{ TMemoryIndex<TIndexFile, TSelection> }

constructor TMemoryIndex<TIndexFile>.Create(
  const pIndexFile: TIndexFile );
begin
  inherited Create;
  fIndexFile := pIndexFile;
  fIndexCriteria := TIndexCriteria.Create;
  fRoot := TSigDBTreeRoot.Create;
end;

destructor TMemoryIndex<TIndexFile>.destroy;
begin
  fRoot.Free;
  fIndexCriteria.Free;
  inherited;
end;

procedure TMemoryIndex<TIndexFile>.Rebuild;
var
  iCurr : TSigDBIndex;
  iRec : TSigDBRecPointer;
begin
  Root.Clear;
  iRec := FirstValid( iCurr );
  while iRec <> 0 do
  begin
    Root.Add( TMemoryIndexNode<TIndexFile>.Create(Self, iRec ) );
    iRec := NextValid( iCurr );
  end;
end;

{ TMemoryIndexNode<TIndexFile> }

constructor TMemoryIndexNode<TIndexFile>.Create(
  const pOwner: TMemoryIndex<TIndexFile>; const pRecNo: TSigDBRecPointer);
begin
  inherited Create;

  fOwner := pOwner;
  fRecNo := pRecNo;
end;

function TMemoryIndexNode<TIndexFile>.LessThan(
  const SigTreeNode: tSigBTreeNode): boolean;
var
  iNode : TMemoryIndexNode<TIndexFile>;
  iDataFile : tSigDBFileBase;
  iIndexCriteria : TIndexCriteria;
  iIndexEntry : TIndexEntry;
begin
  iNode := SigTreeNode as TMemoryIndexNode<TIndexFile>;
  iDataFile := Owner.IndexFile.DataFile;
  iIndexCriteria := Owner.IndexCriteria;
  Result := FALSE; // implied equal
  for iIndexEntry  in iIndexCriteria do
  begin
    case iDataFile.CompareField( iIndexEntry.fIndexField, self.fRecNo, iNode.fRecNo ) of
      crLT:
      begin
        Result := not iIndexEntry.Descending;
        exit;
      end;
      crGT:
      begin
        Result := iIndexEntry.Descending;
        exit;
      end;
    end;
  end;
end;


{ TIndexEntry }

constructor TIndexEntry.Create(const pIndexField: integer; const pDescending : boolean );
begin
  inherited Create;
  fIndexField := pIndexField;
  fDescending := pDescending;
end;

end.
