unit UnitSigFileBindings;

{
  uses live bindings to bind a SigFile property to a component property

  To avoid confusion a new object for TSigBaseObject 'OnNotify' is used to
  trigger notifications when data changes.

  The component name and SigFile Name properties are used as the binding
  object names.

  We are trying to do this without Live Bindings now.
}

interface

uses
  {
  System.Bindings.Expression,
  System.Bindings.Helper,
  }
  System.Contnrs,
  System.Classes,
  System.SysUtils,
  SigFile,
  PendingActions,
  SigGeneralGrid,
  SigVariableEditorList,
  SigVariableEditor,
  SigSpinEdit,
  VCL.Controls,
  VCL.StdCtrls,
  VCL.ComCtrls,
  VCL.Mask;

type

{
  tSigFileAssociation = class
  private
    fAssociationObject: tObject;
    fAssociationName: string;
    fBindingAssociation: TBindingAssociation;
  protected
  public
    constructor Create( const pAssociationObject : tObject; const pAssociationName : string );
    property AssociationObject : tObject
             read fAssociationObject;
    property AssociationName : string
             read fAssociationName;
    property BindingAssociation : TBindingAssociation
             read fBindingAssociation;
  end;

  tSigFileAssociationList = class( tObjectList )
  private
    function GetAssociationName(const pObject: tObject): string;
    function GetAssociation(const pObject: tObject): TBindingAssociation;
    function GetAssociationItem(const pObject: tObject): tSigFileAssociation;
  protected
  public
    property AssociationItem[ const pObject : tObject ] : tSigFileAssociation
             read GetAssociationItem;
    property AssociationName[ const pObject : tObject ] : string
             read GetAssociationName;
    property Association[ const pObject : tObject ] : TBindingAssociation
             read GetAssociation;
  end;
}

  tSigFileBindingObjectList = class;

  tSigBaseBindingObject = class
  private
    fOwner: tSigFileBindingObjectList;
  public
    constructor Create( const pOwner : tSigFileBindingObjectList ); reintroduce;
    property Owner : tSigFileBindingObjectList
             read fOwner;
  end;

  tSigActiveChildComponent = class( tSigBaseBindingObject )
  {
    This associates an action with a callback and a tSigCompoundProperty
    Some fixed actions and components are associated with descendants of this property
  }
  private
    fSigFileObject: tSigCompoundProperty;
    fCallback: tSigOnActiveChildChange;
  protected
  public
    constructor Create( const pOwner : tSigFileBindingObjectList;
                        const pSigFileObject : tSigCompoundProperty;
                        const pCallback : tSigOnActiveChildChange ); reintroduce;

    property SigFileObject : tSigCompoundProperty
             read fSigFileObject
             write fSigFileObject;
    property Callback : tSigOnActiveChildChange
             read fCallback;

    procedure OnActiveChildChange(  const Sender : tSigCompoundProperty; const pNewChild : integer ); virtual;

  end;

  tSigActiveChildComponentShow = class( tSigActiveChildComponent )
  {
    Sets visible property of child to visible if active child <> -1;
    Hides child on destruction
  }
  private
    fComponent: tControl;
  protected
  public
    constructor Create( const pOwner : tSigFileBindingObjectList;
                        const pSigFileObject : tSigCompoundProperty;
                        const pComponent : tControl ); reintroduce;
    destructor Destroy; override;

    property Component : tControl
             read fComponent;

    procedure OnActiveChildChange(  const Sender : tSigCompoundProperty; const pNewChild : integer ); override;
  end;

  tSigBaseBindingStringList = class( tSigBaseBindingObject )
  {
    This ties a string list to a set of objects. The list itself will be tied
    to an array or list type sigfile object. The individual lines will be taken
    from a property of the children of such an array, usually 'Name'.
  }
  private
    fSigFileObject: tSigCompoundProperty;
    fList: tStrings;
    fChildProperty: string;
  public
    constructor Create( pOwner : tSigFileBindingObjectList;
                        const pSigFileObject : tSigCompoundProperty;
                        const pChildProperty : string;
                        const pList : tStrings );
    property SigFileObject : tSigCompoundProperty
             read fSigFileObject;
    property List : tStrings
             read fList;
    property ChildProperty : string
             read fChildProperty;

    procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty ); virtual;
    procedure OnMaxChange( const Sender : tSigBaseProperty; const NewVal : integer ); virtual;
    procedure SetupList; virtual;
  end;

  tSigBindingStringListComponent = class( tSigBaseBindingStringList )
  {
    this is a descendant of string list where the active child is linked
    to a component property, e.g. TabIndex or ItemIndex. This is determined
    in descendants. The constructor is bigger (more parms) than any real one.
  }
  private
    fComponent: tComponent;
  public
    constructor Create( pOwner : tSigFileBindingObjectList;
                        const pSigFileObject : tSigCompoundProperty;
                        const pChildProperty : string;
                        const pComponent : tComponent;
                        const pList : tStrings );

    procedure OnActiveChildChange(  const Sender : tSigCompoundProperty; const pNewChild : integer ); virtual; abstract;
    procedure OnComponentChange( Sender : tObject ); virtual; abstract; // called by components on change

    property Component : tComponent
             read fComponent;
  end;

  tSigBindingTabControl = class( tSigBindingStringListComponent )
  private
    function GetComponent: tTabControl;
  public
    constructor Create( pOwner : tSigFileBindingObjectList;
                        const pSigFileObject : tSigCompoundProperty;
                        const pChildProperty : string;
                        const pComponent : tTabControl );

    procedure OnActiveChildChange(  const Sender : tSigCompoundProperty; const pNewChild : integer ); override;
    procedure OnComponentChange( Sender : tObject ); override; // called by components on change

    property Component : tTabControl
             read GetComponent;
  end;

  tSigFileBindingObject = class( tSigBaseBindingObject )       // do not use this class directly! only use SigFileBindingObjectList
  private
    fSigFileObject: tSigBaseProperty;
    fComponent: tComponent;
  protected
    procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty ); virtual; abstract;
    procedure OnComponentChange( Sender : tObject ); virtual; abstract; // called by components on change
  public
    constructor Create( const pOwner : tSigFileBindingObjectList; const pSigfileObject : tSigBaseProperty; const pComponent : tComponent );
    property SigFileObject : tSigBaseProperty
             read fSigFileObject;
    property Component : tComponent
             read fComponent;
  end;

  tSigFileGridBindingColumn = class
  private
    fID: string;
    fCol: integer;
    { A column for a tSigFileGridBindingObject
      Binds a column to a subtype
      }
  public
    constructor Create( const pCol : integer; const pID : string );

    property Col : integer
             read fCol;
    property ID : string
             read fID;
  end;

  tSigFileGridBindingObject = class( tObjectList )
  private
    { This associates a grid at two levels with with with tSigFile objects.
      The whole grid is associated with a tSigPropertyList. Each row
      associates with a child in that list, which in turn must be a
      tSigCompoundProperty. The columns are then associated with
      Members of that property.
      Editing a row changes the active child, so Row is associated with
      ActiveChild.
      Similarly RowCount is (indirectly) associated with the Max property.
      Note that unlike Active Child, Max affects Rowcount, but not vice-versa
      We dont actually use the live bindings engine for this}
    fOwner: tSigFileBindingObjectList;
    fSigFileObject: tSigCompoundProperty;
    fComponent: TSigGeneralGrid;
    //fToFileObjectBinding : tBindingExpression;
    //fFromFileObjectBinding : tBindingExpression;
    //fUpdating : boolean;
    fSelectionCol: integer;
    fSelectedRow: integer;
    fValidChild: tSigBaseProperty;
    procedure OnRowChange( const pSender : tObject; const pNewRow : integer );
    procedure OnActiveChildChange(  const Sender : tSigCompoundProperty; const pNewChild : integer );
    procedure OnMaxChange( const Sender : tSigBaseProperty; const NewVal : integer );
    procedure OnCellEditChange( const Sender : tObject; const pCol, pRow : integer; const pValue : string );
    procedure OnCellEditClick( Sender: TObject; pCol, pRow: Integer; var CanSelect: Boolean );
    function GetCol(const pCol: integer): tSigFileGridBindingColumn;
    procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty );
    procedure BuildRow( const pRow : integer );
    procedure SetSelectedRow(const Value: integer);
  public
    constructor Create( const pOwner : tSigFileBindingObjectList; const pSigfileObject : tSigCompoundProperty;
                const pComponent : TSigGeneralGrid );

    function AddColumn( pCol : integer; pName : string ) : integer;
    function FindColumn( pCol : integer ) : integer;

    property Owner : tSigFileBindingObjectList
             read fOwner;
    property SigFileObject : tSigCompoundProperty
             read fSigFileObject;
    property Component : TSigGeneralGrid
             read fComponent;

    function ColName( const pCol : integer ) : string;
    property Col[ const pCol : integer ] : tSigFileGridBindingColumn
             read GetCol;

    property SelectionCol : integer
             read fSelectionCol
             write fSelectionCol;
    property SelectedRow : integer
             read fSelectedRow
             write SetSelectedRow;

    property ValidChild : tSigBaseProperty
             read fValidChild;  // NOT owned by us!
  end;

  tSigEditBindingObject = class( tSigFileBindingObject )
  private
    //function GetComponent: tCustomEdit;
  protected
    procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty ); override;
    procedure OnComponentChange( Sender : tObject ); override; // called by components on change
  public
    constructor Create( const pOwner : tSigFileBindingObjectList; const pSigfileObject : tSigBaseProperty; const pComponent : tComponent );
    //property Component : tCustomEdit
             //read GetComponent;
  end;

  tSigFileVariableEditorList = class;

  tSigFileVariableEditorLine = class  // do not use directly. Intended for use with tSigFileVariableEditorList
  private
    fOwner: tSigFileVariableEditorList;
    fEditor: tSigVariableEditor;
    fSigProperty: tSigBaseProperty;
    fCallBack: tNotifyEvent;
  protected
  public
    constructor Create( const pOwner : tSigFileVariableEditorList;
                        const pEditor : tSigVariableEditor;
                        const pSigProperty : tSigBaseProperty ); reintroduce; overload;
    constructor Create( const pOwner : tSigFileVariableEditorList;
                        const pEditor : tSigVariableEditor;
                        const pCallBack : tNotifyEvent ); reintroduce; overload;

    property Owner : tSigFileVariableEditorList
             read fOwner;
    property Editor : tSigVariableEditor
             read fEditor;
    property SigProperty : tSigBaseProperty
             read fSigProperty;
    property CallBack : tNotifyEvent
             read fCallBack;
  end;

  tSigFileVariableEditorList = class( tObjectList )
  private
    fComponent: TSigVariableEditorList;
    fSigFileObject: tSigCompoundProperty;
    fOwner: tSigFileBindingObjectList;
    function GetLine(const i: integer): tSigFileVariableEditorLine;
  protected
  public
    constructor Create( const pOwner : tSigFileBindingObjectList; const pSigfileObject : tSigCompoundProperty;
                const pComponent : TSigVariableEditorList ); reintroduce;

    property Owner : tSigFileBindingObjectList
             read fOwner;
    property SigFileObject : tSigCompoundProperty
             read fSigFileObject;
    property Component : TSigVariableEditorList
             read fComponent;

    property Line[ const i : integer ] : tSigFileVariableEditorLine
             read GetLine;

    function AddRow( pName : string; pEditorStyle : tSigVariableEditorStyle; pCaption : string ) : integer; overload;
    function AddRow( pEditorStyle : tSigVariableEditorStyle; pCaption, pButtonText : string; pCallBack : tNotifyEvent ) : integer; overload;
    procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty );
    procedure OnComponentChange( Sender : tObject ); // called by components on change
  end;

  tSigCellEditChangePendingObject = class
  private
    fCol: integer;
    fValue: string;
    fRow: integer;
    fObject: tObject;
  public
    constructor Create( const pObject : tObject; const pCol, pRow : integer; const pValue : string );
    property Sender : tObject
             read fObject;
    property Row : integer
             read fRow;
    property Col : integer
             read fCol;
    property Value : string
             read fValue;
  end;

  tSigPendingRowChangeObject = class
  private
    fRow: integer;
    fObject: tObject;
  public
    constructor Create( const pObject : tObject; const pRow : integer );
    property Sender : tObject
             read fObject;
    property Row : integer
             read fRow;
  end;

  tSigFileBindingObjectList = class( tObjectList )
  private
    fUpdating: boolean;
    //fAssociationList: tSigFileAssociationList;
  protected
    fPendingActionList : tSigPendingActionList;
    procedure PendingNotifyAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingMaxChangeAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingRowChangeAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingChangeChildAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingCellEditChangeAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingComponentChangeAction( const pObject : tObject; var pNewDelay : integer );
    procedure PendingRemoveAction( const pObject : tObject; var pNewDelay : integer );
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    function Add( const pSigfileObject : tSigBaseProperty; const pComponent : tComponent ) : integer; reintroduce; overload;
    function Add( const pSigfileObject : tSigCompoundProperty; const pComponent : TSigGeneralGrid ) : integer; reintroduce; overload;
    function Add( const pSigfileObject : tSigCompoundProperty; const pName : string; const pList : TStrings ) : integer; reintroduce; overload;
    function Add( const pSigfileObject : tSigCompoundProperty; const pName : string; const pComponent : TComponent ) : integer; reintroduce; overload;
    function Add( const pSigfileObject : tSigCompoundProperty; const pAction : tSigOnActiveChildChange ) : integer; reintroduce; overload;
    function Add( const pSigfileObject : tSigCompoundProperty; const pComponent : tSigVariableEditorList ) : integer; reintroduce; overload;

    function AddColumn( pChild : integer; pCol : integer; pName : string ) : integer;
    procedure SetSelectionColumn( pChild : integer; pCol : integer );

    function AddRow( const pChild : integer; const pName : string;
                     const pEditorStyle : tSigVariableEditorStyle;
                     const pCaption : string ) : integer; overload;
    function AddRow( const pChild : integer; const pEditorStyle : tSigVariableEditorStyle;
                     const pCaption, pButtonText : string;
                     const pCallBack : tNotifyEvent ) : integer; overload;

    procedure Remove( const pSigfileObject : tSigBaseProperty ); reintroduce; overload; // removes all links to this property (usually because it has been destroyed
    procedure Remove( const pComponent : tComponent ); reintroduce; overload;
    procedure Remove( const pList : tStrings ); reintroduce; overload;

    function Find( const pComponent : tComponent ) : integer; reintroduce; overload;
    property Updating : boolean
             read fUpdating;

    procedure Clear; override;

    {
    property AssociationList : tSigFileAssociationList
             read fAssociationList;
    }

    //================== Notifications =======================//

    procedure ComponentChange( Sender : tObject ); // called by components on change
    procedure Notify( const pChangedObject : tSigBaseProperty ); reintroduce;
    procedure DelayedNotify( const pChangedObject : tSigBaseProperty );
    procedure OnRowChange( const pSender : tObject; const pNewRow : integer );
    procedure OnMaxChange( const Sender : tSigBaseProperty; const NewVal : integer );
    procedure OnCellEditChange( const Sender : tObject; const pCol, pRow : integer; const pValue : string );
    procedure OnCellEditClick( Sender: TObject; pCol, pRow: Integer; var CanSelect: Boolean );
    procedure OnActiveChildChange( const Sender : tSigCompoundProperty; const pNewChild : integer );
    //procedure OnSigFileObjectChange( const pChangedObject : tSigBaseProperty );
  end;

var
  SigFileBindingObjectList : tSigFileBindingObjectList;

implementation


{ tSigFileBindingObectList }

function tSigFileBindingObjectList.Add(const pSigfileObject: tSigBaseProperty;
  const pComponent: tComponent ): integer;
begin
  Remove( pComponent );
  if pComponent is tCustomEdit then
  begin
    Result := inherited Add( tSigEditBindingObject.Create( self, pSigFileObject, pComponent ));
  end
  else
  begin
    raise Exception.Create('Unhandled Component type - Binding Error 010');
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.Add(
  const pSigfileObject: tSigCompoundProperty;
  const pComponent: TSigGeneralGrid): integer;
begin
  Result := Find( pComponent );
  if Result < 0 then
  begin
    Result := inherited Add( tSigFileGridBindingObject.Create( self, pSigFileObject, pComponent ));
  end
  else if Items[ Result ] is tSigFileGridBindingObject then
  begin
    with Items[ Result ] as tSigFileGridBindingObject do
    begin
      if SigFileObject <> pSigFileObject then
      begin
        inherited Delete( Result );
        Pack;
        Result := inherited Add( tSigFileGridBindingObject.Create( self, pSigFileObject, pComponent ));
      end;
      // else nothing to do
    end;
  end
  else
  begin
    inherited Delete( Result );
    Pack;
    Result := inherited Add( tSigFileGridBindingObject.Create( self, pSigFileObject, pComponent ));
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.Add(
  const pSigfileObject: tSigCompoundProperty; const pName: string;
  const pList: TStrings): integer;
begin
  Remove( pList );
  Result := inherited Add( tSigBaseBindingStringList.Create( self, pSigFileObject, pName, pList ));
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.Add(
  const pSigfileObject: tSigCompoundProperty; const pName: string;
  const pComponent: TComponent): integer;
begin
  if pComponent is tTabControl then
  begin
    Remove( pComponent );
    Result := inherited Add( tSigBindingTabControl.Create( self, pSigFileObject, pName, pComponent as tTabControl ));
  end
  else
  begin
    raise Exception.Create('Component type not supported');
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;


function tSigFileBindingObjectList.Add(const pSigfileObject: tSigCompoundProperty;
  const pAction: tSigOnActiveChildChange): integer;
var
  iItem : tObject;
begin
  for Result := 0 to Count - 1 do
  begin
    iItem := Items[ Result ];
    if iItem is tSigActiveChildComponent then
    begin
      with iItem as tSigActiveChildComponent do
      begin
        if SigFileObject = pSigFileObject then
        begin
          if @fCallback = @pAction then
          begin
            // already there!
            exit;
          end;
        end;
      end;
    end;
  end;
  // else
  Result := inherited Add( tSigActiveChildComponent.Create( self, pSigFileObject, pAction ));
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.Add(
  const pSigfileObject: tSigCompoundProperty;
  const pComponent: tSigVariableEditorList): integer;
begin
  Remove( pComponent );
  Result := inherited Add( tSigFileVariableEditorList.Create( self, pSigFileObject, pComponent as TSigVariableEditorList ));
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.AddColumn(pChild, pCol: integer;
  pName: string): integer;
var
  iChild : tObject;
begin
  Result := -1;
  if (pChild < Count) and (pChild >= 0) then
  begin
    iChild := Items[ pChild ];
    if iChild is tSigFileGridBindingObject then
    begin
      with iChild as tSigFileGridBindingObject do
      begin
        Result := AddColumn( pCol, pName );
      end;
    end
    else
    begin
      raise Exception.Create('Internal Binding Error 005');
    end;
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.AddRow(const pChild: integer;
  const pEditorStyle: tSigVariableEditorStyle; const pCaption, pButtonText : string;
  const pCallBack: tNotifyEvent): integer;
var
  iChild : tObject;
begin
  Result := -1;
  if (pChild < Count) and (pChild >= 0) then
  begin
    iChild := Items[ pChild ];
    if iChild is tSigFileVariableEditorList then
    begin
      with iChild as tSigFileVariableEditorList do
      begin
        Result := AddRow( pEditorStyle, pCaption, pButtonText, pCallBack );
      end;
    end
    else
    begin
      raise Exception.Create('Internal Binding Error 007');
    end;
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

function tSigFileBindingObjectList.AddRow( const pChild: integer; const pName: string;
  const pEditorStyle: tSigVariableEditorStyle; const pCaption : string): integer;
var
  iChild : tObject;
begin
  Result := -1;
  if (pChild < Count) and (pChild >= 0) then
  begin
    iChild := Items[ pChild ];
    if iChild is tSigFileVariableEditorList then
    begin
      with iChild as tSigFileVariableEditorList do
      begin
        Result := AddRow( pName, pEditorStyle, pCaption );
      end;
    end
    else
    begin
      raise Exception.Create('Internal Binding Error 006');
    end;
  end;
  if not fUpdating then
  begin
    while fPendingActionList.ExecuteTick do;
  end;
end;

procedure tSigFileBindingObjectList.Clear;
begin
  inherited;
  fUpdating := FALSE; // safety first
end;

constructor tSigFileBindingObjectList.Create;
begin
  inherited Create( TRUE );

  fPendingActionList := tSigPendingActionList.Create;

end;

procedure tSigFileBindingObjectList.DelayedNotify(
  const pChangedObject: tSigBaseProperty);
begin
  fPendingActionList.Add( PendingNotifyAction, pChangedObject );
end;

destructor tSigFileBindingObjectList.Destroy;
begin
  fPendingActionList.Free;
  inherited;
end;

function tSigFileBindingObjectList.Find(
  const pComponent: tComponent): integer;
var
  iItem : tObject;
begin
  for Result := 0 to Count - 1 do
  begin
    iItem := Items[ Result ];
    if iItem is tSigFileGridBindingObject then
    begin
      with iItem as tSigFileGridBindingObject do
      begin
        if pComponent = Component then
        begin
          exit;
        end;
      end;
    end
    else if iItem is tSigFileBindingObject then
    begin
      with iItem as tSigFileBindingObject do
      begin
        if pComponent = Component then
        begin
          exit;
        end;
      end;
    end
    else if iItem is tSigBindingStringListComponent then
    begin
      with iItem as tSigBindingStringListComponent do
      begin
        if pComponent = Component then
        begin
          exit;
        end;
      end;
    end

  end;
  // else
  Result := -1;
end;

procedure tSigFileBindingObjectList.Notify(
  const pChangedObject: tSigBaseProperty);
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add( PendingNotifyAction, pChangedObject );
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            OnSigFileObjectChange( pChangedObject );
          end;
        end
        else if iItem is tSigFileVariableEditorList then
        begin
          with iItem as tSigFileVariableEditorList do
          begin
            OnSigFileObjectChange( pChangedObject );
          end;
        end
        else if iItem is tSigFileBindingObject then
        begin
          with iItem as tSigFileBindingObject do
          begin
            OnSigFileObjectChange( pChangedObject );
          end;
        end
        else if iItem is tSigBaseBindingStringList then
        begin
          with iItem as tSigBaseBindingStringList do
          begin
            OnSigFileObjectChange( pChangedObject );
          end;
        end;
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.OnActiveChildChange(
  const Sender: tSigCompoundProperty; const pNewChild: integer);
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add(PendingChangeChildAction, Sender );
    // We do not store the pNewChild Value because there may be several changes in
    // succession, which will be merged. We will use the current value later
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            OnActiveChildChange( Sender, pNewChild );
          end;
        end
        else if iItem is tSigBindingStringListComponent then
        begin
          with iItem as tSigBindingStringListComponent do
          begin
            OnActiveChildChange( Sender, pNewChild );
          end;
        end
        else if iItem is tSigActiveChildComponent then
        begin
          with iItem as tSigActiveChildComponent do
          begin
            OnActiveChildChange( Sender, pNewChild );
          end;
        end
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.OnCellEditChange(const Sender: tObject;
  const pCol, pRow: integer; const pValue: string);
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add(PendingCellEditChangeAction, tSigCellEditChangePendingObject.Create( Sender, pCol, pRow, pValue ) );
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            OnCellEditChange( Sender, pCol, pRow, pValue );
          end;
        end
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.OnCellEditClick(Sender: TObject; pCol, pRow: Integer;
  var CanSelect: Boolean);
var
  i: Integer;
  iItem : tObject;
begin
  // cannot postpone this one!
  for i := 0 to Count - 1 do
  begin
    iItem := Items[ i ];
    if iItem is tSigFileGridBindingObject then
    begin
      with iItem as tSigFileGridBindingObject do
      begin
        OnCellEditClick( Sender, pCol, pRow, CanSelect );
      end;
    end
  end;
end;

procedure tSigFileBindingObjectList.OnMaxChange(const Sender: tSigBaseProperty;
  const NewVal: integer);
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add( PendingMaxChangeAction, Sender );
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            OnMaxChange( Sender, NewVal );
          end;
        end
        {
        else if iItem is tSigFileBindingObject then
        begin
          with iItem as tSigFileBindingObject do
          begin
            continue;
            // Different notifications are used for non-Grid objects
          end;
        end
        }
        else if iItem is tSigBaseBindingStringList then
        begin
          with iItem as tSigBaseBindingStringList do
          begin
            OnMaxChange( Sender, NewVal );
          end;
        end
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.OnRowChange(const pSender: tObject;
  const pNewRow: integer);
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add( PendingRowChangeAction, tSigPendingRowChangeObject.Create( pSender, pNewRow ) );
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            OnRowChange( pSender, pNewRow );
          end;
        end;
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.PendingCellEditChangeAction(
  const pObject: tObject; var pNewDelay: integer);
begin
  if pObject is tSigCellEditChangePendingObject then
  begin
    try
      with pObject as tSigCellEditChangePendingObject do
      begin
        OnCellEditChange( pObject, Col, Row, Value );
      end;
    finally
      pObject.Free;
    end;
  end;
end;

procedure tSigFileBindingObjectList.PendingChangeChildAction(
  const pObject: tObject; var pNewDelay: integer);
var
  iObject : tSigCompoundProperty;
begin
  iObject := pObject as tSigCompoundProperty;
  OnActiveChildChange( iObject, iObject.ActiveChild );
end;

procedure tSigFileBindingObjectList.PendingComponentChangeAction(
  const pObject: tObject; var pNewDelay: integer);
begin
  ComponentChange( pObject );
end;

procedure tSigFileBindingObjectList.PendingMaxChangeAction(
  const pObject: tObject; var pNewDelay: integer);
var
  iObject : tSigCompoundProperty;
begin
  iObject := pObject as tSigCompoundProperty;
  OnMaxChange( iObject, iObject.Max );
end;

procedure tSigFileBindingObjectList.PendingNotifyAction(const pObject: tObject;
  var pNewDelay: integer);
begin
  Notify( pObject as tSigBaseProperty );
end;

procedure tSigFileBindingObjectList.PendingRemoveAction(const pObject: tObject;
  var pNewDelay: integer);
begin
  inherited Remove( pObject );
  {
  if pObject is tSigBaseProperty then
  begin
    Remove( pObject as tSigBaseProperty );
  end
  else if pObject is tComponent then
  begin
    Remove( pObject as tComponent );
  end
  else if pObject is tStrings then
  begin
    Remove( pObject as tStrings );
  end
  else
  begin
    raise Exception.Create('Unable to remove object');
  end;
  }
end;

procedure tSigFileBindingObjectList.PendingRowChangeAction(
  const pObject: tObject; var pNewDelay: integer);
var
  iObject : tSigPendingRowChangeObject;
begin
  if pObject is tSigPendingRowChangeObject then
  begin
    iObject := pObject as tSigPendingRowChangeObject;
    try
      OnRowChange( iObject.Sender, iObject.Row );
    finally
      //iObject.Free;
    end;
  end;

end;

procedure tSigFileBindingObjectList.ComponentChange( Sender : tObject );
var
  i: Integer;
  iItem : tObject;
begin
  if Updating then
  begin
    fPendingActionList.Add( PendingComponentChangeAction, Sender );
  end
  else
  begin
    fUpdating := TRUE;
    try
      for i := 0 to Count - 1 do
      begin
        iItem := Items[ i ];
        if iItem is tSigFileBindingObject then
        begin
          with iItem as tSigFileBindingObject do
          begin
            OnComponentChange( Sender );
          end;
        end
        else if iItem is tSigBindingStringListComponent then
        begin
          with iItem as tSigBindingStringListComponent do
          begin
            OnComponentChange( Sender );
          end;
        end
        else if iItem is tSigFileVariableEditorList then
        begin
          with iItem as tSigFileVariableEditorList do
          begin
            OnComponentChange( Sender );
          end;
        end
      end;
    finally
      fUpdating := FALSE;
      while fPendingActionList.ExecuteTick do;
    end;
  end;
end;

procedure tSigFileBindingObjectList.Remove(const pList: tStrings);
var
  i: Integer;
  iItem : tObject;
  iCanDelete : boolean;
  iPackRqd : boolean;
begin
  iPackRqd := FALSE;
  for i := Count - 1 downto 0 do
  begin
    iItem := Items[ i ];
    iCanDelete := FALSE;
    if iItem is tSigBaseBindingStringList then
    begin
      with iItem as tSigBaseBindingStringList do
      begin
        if pList = List then
        begin
          //inherited Delete( i );
          iCanDelete := TRUE;
        end;
      end;
    end;
    if iCanDelete then
    begin
      if fUpdating then
      begin
        fPendingActionList.Add( PendingRemoveAction, iItem );
      end
      else
      begin
        fUpdating := TRUE;
        try
          inherited Delete( i );
          iPackRqd := TRUE;
        finally
          fUpdating := FALSE;
          while fPendingActionList.ExecuteTick do;
        end;
      end;
    end;
  end;
  if iPackRqd then
  begin
    Pack;
  end;
end;

procedure tSigFileBindingObjectList.Remove( const pSigfileObject: tSigBaseProperty );
var
  i: Integer;
  iItem : tObject;
  iCanDelete : boolean;
  iPackRqd : boolean;
begin
  //if Updating then
  //begin
  //  fPendingActionList.Add( PendingRemoveAction, pSigfileObject );
  //end
  //else
  //begin
    //fUpdating := TRUE;
    //try
      iPackRqd := FALSE;
      for i := Count - 1 downto 0 do
      begin
        iItem := Items[ i ];
        iCanDelete := FALSE;
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            if pSigfileObject = SigFileObject then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end
        else if iItem is tSigFileBindingObject then
        begin
          with iItem as tSigFileBindingObject do
          begin
            if pSigfileObject = SigFileObject then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end;
        if iCanDelete then
        begin
          if fUpdating then
          begin
            fPendingActionList.Add( PendingRemoveAction, iItem );
          end
          else
          begin
            fUpdating := TRUE;
            try
              inherited Delete( i );
              iPackRqd := TRUE;
            finally
              fUpdating := FALSE;
              while fPendingActionList.ExecuteTick do;
            end;
          end;
        end;
      end;
      if iPackRqd then
      begin
        Pack;
      end;
    //finally
      //fUpdating := FALSE;
      //while fPendingActionList.ExecuteTick do;
    //end;
  //end;
end;

procedure tSigFileBindingObjectList.Remove( const pComponent: tComponent );
var
  i: Integer;
  iItem : tObject;
  iCanDelete : boolean;
  iPackRqd : boolean;
begin
  //if Updating then
  //begin
    //fPendingActionList.Add( PendingRemoveAction, pComponent );
  //end
  //else
  //begin
    //fUpdating := TRUE;
    //try
      iPackRqd := FALSE;
      for i := Count - 1 downto 0 do
      begin
        iItem := Items[ i ];
        iCanDelete := FALSE;
        if iItem is tSigFileGridBindingObject then
        begin
          with iItem as tSigFileGridBindingObject do
          begin
            if pComponent = Component then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end
        else if iItem is tSigFileVariableEditorList then
        begin
          with iItem as tSigFileVariableEditorList do
          begin
            if pComponent = Component then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end
        else if iItem is tSigFileBindingObject then
        begin
          with iItem as tSigFileBindingObject do
          begin
            if pComponent = Component then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end
        else if iItem is tSigBindingStringListComponent then
        begin
          with iItem as tSigBindingStringListComponent do
          begin
            if pComponent = Component then
            begin
              //inherited Delete( i );
              iCanDelete := TRUE;
            end;
          end;
        end;
        if iCanDelete then
        begin
          if fUpdating then
          begin
            fPendingActionList.Add( PendingRemoveAction, iItem );
          end
          else
          begin
            fUpdating := TRUE;
            try
              inherited Delete( i );
              iPackRqd := TRUE;
            finally
              fUpdating := FALSE;
              while fPendingActionList.ExecuteTick do;
            end;
          end;
        end;
      end;
      if iPackRqd then
      begin
        Pack;
      end;
    //finally
      //fUpdating := FALSE;
      //while fPendingActionList.ExecuteTick do;
    //end;
  //end;
end;

procedure tSigFileBindingObjectList.SetSelectionColumn(pChild,
  pCol: integer);
var
  iChild : tObject;
begin
  if (pChild < Count) and (pChild >= 0) then
  begin
    iChild := Items[ pChild ];
    if iChild is tSigFileGridBindingObject then
    begin
      with iChild as tSigFileGridBindingObject do
      begin
        SelectionCol := pCol;
      end;
    end
    else
    begin
      raise Exception.Create('Internal Binding Error 011');
    end;
  end;
end;

{ tSigFileBindingObject }

constructor tSigFileBindingObject.Create(const pOwner : tSigFileBindingObjectList; const pSigfileObject: tSigBaseProperty;
  const pComponent: tComponent);
begin
  inherited Create( pOwner );

  fSigFileObject := pSigFileObject;
  if not assigned( fSigFileObject.OnNotify ) then
  begin
    fSigFileObject.OnNotify := fOwner.Notify;
  end;
  fComponent := pComponent;

end;

{ tSigFileGridBindingObject }

function tSigFileGridBindingObject.AddColumn(pCol: integer;
  pName: string): integer;
var
  i : integer;
  icChild : tSigCompoundProperty;
  iChild : tSigBaseProperty;
begin
  Result := FindColumn( pCol );
  if Result < 0 then
  begin
    Result := inherited Add( tSigFileGridBindingColumn.Create( pCol, pName));
  end
  else
  begin
    if Col[ Result ].ID <> pName then
    begin
      Col[ Result ].fID := pName;
    end;
  end;
  // now build the column cells
  if assigned( fComponent ) then
  begin
    with fComponent do
    begin
      for i := fComponent.FixedRows to RowCount - 1 do
      begin
        iChild := fSigFileObject.Entry[ i - fComponent.FixedRows ];
        if assigned( iChild ) then
        begin
          icChild := iChild as tSigCompoundProperty;
          iChild := icChild.Children.FindChild( pName );
          if assigned( iChild ) then
          begin
            if iChild is tSigBooleanProperty then
            begin
              with iChild as tSigBooleanProperty do
              begin
                if ValueAsBool then
                begin
                  Cell[ pCol, i ] := '1';
                end
                else
                begin
                  Cell[ pCol, i ] := '0';
                end;
              end;
            end
            else
            begin
              Cell[ pCol, i ] := iChild.Value;
            end;
          end
          else
          begin
            Cell[ pCol, i ] := '';
          end;
        end
        else
        begin
          Cell[ pCol, i ] := '';
        end;
      end;
    end;
  end;
end;

procedure tSigFileGridBindingObject.BuildRow(const pRow: integer);
var
  i, iCol : integer;
  icRow : tSigCompoundProperty;
  iChild : tSigBaseProperty;
  iName : string;
  iNewActiveChild : integer;
begin
  if assigned( fComponent ) then
  begin
    if pRow >= fComponent.FixedRows then
    begin
      // build the row
      iNewActiveChild := pRow - fComponent.FixedRows;
      icRow := fSigFileObject.Entry[ iNewActiveChild ] as tSigCompoundProperty;
      if assigned( icRow ) then
      begin
        for i := 0 to Count - 1 do
        begin
          iName := Col[ i ].ID;
          iChild := icRow.Children.FindChild( iName );
          if assigned( iChild ) then
          begin
            iCol := Col[ i ].Col;
            if iChild is tSigBooleanProperty then
            begin
              with iChild as tSigBooleanProperty do
              begin
                if ValueAsBool then
                begin
                  fComponent.Cell[ iCol, pRow ] := '1';
                end
                else
                begin
                  fComponent.Cell[ iCol, pRow ] := '0';
                end;
              end;
            end
            else
            begin
              fComponent.Cell[ iCol, pRow ] := iChild.Value;
            end;
          end;

        end;
      end
      else
      begin
        for i := 0 to fComponent.ColCount - 1 do
        begin
          fComponent.Cell[ i, pRow ] := '';
        end;
      end;
    end;
  end;
end;

function tSigFileGridBindingObject.ColName(const pCol: integer): string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Col[ i ].Col = pCol then
    begin
      Result := Col[ i ].ID;
      exit;
    end;
  end;
end;

constructor tSigFileGridBindingObject.Create(
  const pOwner: tSigFileBindingObjectList;
  const pSigfileObject: tSigCompoundProperty; const pComponent: TSigGeneralGrid);
begin
  inherited Create( TRUE );

  fOwner := pOwner;

  fSigFileObject := pSigFileObject;
  with fSigFileObject do
  begin
    if not assigned( OnNotify ) then
    begin
      OnNotify := fOwner.Notify;
    end;
  end;

  fComponent := pComponent;


  if not assigned( fComponent.OnRowSelectionChange ) then
  begin
    fComponent.OnRowSelectionChange := fOwner.OnRowChange;
  end;

  if not assigned( fSigFileObject.OnActiveChildChange ) then
  begin
    fSigFileObject.OnActiveChildChange := fOwner.OnActiveChildChange;
  end;

  if not assigned( fSigFileObject.OnMaxChange ) then
  begin
    fSigFileObject.OnMaxChange := fOwner.OnMaxChange;
  end;
  fComponent.RowCount := fSigFileObject.Max + fComponent.FixedRows + 2; // including blank row

  if not assigned( fComponent.OnCellEditChange ) then
  begin
    fComponent.OnCellEditChange := fOwner.OnCellEditChange;
  end;
  if not assigned( fComponent.OnSelectCell ) then
  begin
    fComponent.OnSelectCell := fOwner.OnCellEditClick;
  end;
  //if not assigned( fSigFileObject.OnChange ) then
  //begin
  //  fSigFileObject.OnChange := fOwner.OnSigFileObjectChange;
  //end;

  if fSigFileObject is tSigObjectList then
  begin
    with fSigFileObject as tSigObjectList do
    begin
      fValidChild := ChildArray;
    end;
  end
  else
  begin
    fValidChild := fSigFileObject;
  end;
  fSelectionCol := -1;
  fSelectedRow := -1;
end;

function tSigFileGridBindingObject.FindColumn(pCol: integer): integer;
begin
  for Result := 0 to Count - 1 do
  begin
    with Col[ Result ] do
    begin
      if Col = pCol then
      begin
        exit;
      end;
    end;
  end;
  // else
  Result := -1;
end;

function tSigFileGridBindingObject.GetCol(
  const pCol: integer): tSigFileGridBindingColumn;
begin
  if pCol in [ 0..Count-1 ] then
  begin
    Result := Items[ pCol ] as tSigFileGridBindingColumn;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure tSigFileGridBindingObject.OnActiveChildChange( const Sender : tSigCompoundProperty;
  const pNewChild: integer);
begin
  if Sender = fSigFileObject then
  //if Sender = fValidChild then
  begin
    if pNewChild >= 0 then
    begin
      fComponent.RowBeingEdited := fSigFileObject.ActiveChild + fComponent.FixedRows;
      SelectedRow := fComponent.RowBeingEdited;
    end;
  end;
end;

procedure tSigFileGridBindingObject.OnCellEditChange( const Sender : tObject; const pCol, pRow: integer;
  const pValue: string);
var
  icChild : tSigCompoundProperty;
  iChild : tSigBaseProperty;
  iChildName : string;
begin
  // the base object is known - it is fSigFileObject. From this we can calculate the child from
  // the row property...
  if Sender = fComponent then
  begin
    //if not fUpdating then
    //begin
      //fUpdating := TRUE;
      //try
        iChildName := ColName( pCol );
        if iChildName <> '' then
        begin
          iChild := fSigFileObject.Entry[ pRow - fComponent.FixedRows ];
          if assigned( iChild ) then
          begin
            if iChild is tSigCompoundProperty then
            begin
              icChild := iChild as tSigCompoundProperty;
              iChild := icChild.Children.FindChild( iChildName );
              if assigned( iChild ) then
              begin
                if iChild is tSigBooleanProperty then
                begin
                  with iChild as tSigBooleanProperty do
                  begin
                    if pValue = '1' then
                    begin
                      ValueAsBool := TRUE;
                    end
                    else
                    begin
                      ValueAsBool := FALSE;
                    end;
                  end;
                end
                else
                begin
                  iChild.Value := pValue;
                end;
              end;
            end;
          end;
        end;
      //finally
        //fUpdating := FALSE;
      //end;
    //end;
  end;
end;

procedure tSigFileGridBindingObject.OnCellEditClick(Sender: TObject; pCol, pRow: Integer; var CanSelect: Boolean);
var
  icChild : tSigCompoundProperty;
  iChild : tSigBaseProperty;
  iChildName : string;
begin
  // the base object is known - it is fSigFileObject. From this we can calculate the child from
  // the row property...
  if Sender = fComponent then
  begin
    //if not fUpdating then
    //begin
      //fUpdating := TRUE;
      //try
    if pRow >= fComponent.FixedRows then
    begin
      if pCol = SelectionCol then
      begin
        fSigFileObject.ActiveChild := pRow - fComponent.FixedRows;
      end
      else
      begin
        iChildName := ColName( pCol );
        if iChildName <> '' then
        begin
          iChild := fSigFileObject.Entry[ pRow - fComponent.FixedRows ];
          if assigned( iChild ) then
          begin
            if iChild is tSigCompoundProperty then
            begin
              icChild := iChild as tSigCompoundProperty;
              iChild := icChild.Children.FindChild( iChildName );
              if assigned( iChild ) then
              begin
                if iChild is tSigBooleanProperty then
                begin
                  with iChild as tSigBooleanProperty do
                  begin
                    if ValueAsBool then
                    begin
                      ValueAsBool := FALSE;    // toggle
                      //fComponent.Cell[ pCol, pRow ] := '0';
                    end
                    else
                    begin
                      ValueAsBool := TRUE;
                      //fComponent.Cell[ pCol, pRow ] := '1';
                    end;
                  end;
                  CanSelect := FALSE;
                  fSigFileObject.ActiveChild := pRow - fComponent.FixedRows;
                end;
              end;
            end;
          end
          else
          begin
            // new child
            fSigFileObject.Max := pRow - fComponent.FixedRows;
          end;
        end;
      end;
    end;
      //finally
        //fUpdating := FALSE;
      //end;
    //end;
  end;
end;

procedure tSigFileGridBindingObject.OnMaxChange( const Sender : tSigBaseProperty; const NewVal: integer);
var
  i, iOldRowCount : Integer;
begin
  if Sender = ValidChild then
  begin
    iOldRowCount := fComponent.RowCount;
    fComponent.RowCount := NewVal + fComponent.FixedRows + 2; // including blank row
    for i := iOldRowCount - 1 to fComponent.RowCount - 1 do
    begin
      BuildRow( i );
    end;
    //BuildRow( fComponent.RowCount - 1 ); // blank row
  end;
end;

procedure tSigFileGridBindingObject.OnRowChange(const pSender: tObject;
  const pNewRow: integer);
var
  iNewActiveChild : integer;
  //i : integer;
  //icRow : tSigCompoundProperty;
  //iChild : tSigBaseProperty;
  //iName : string;
begin
  //if pSender = fSigFileObject then
  if pSender = fComponent then
  begin
    if pNewRow >= fComponent.FixedRows then
    begin
      iNewActiveChild := pNewRow - fComponent.FixedRows;
      if iNewActiveChild > fSigFileObject.Max then
      begin
        fSigFileObject.Max := iNewActiveChild;
        fComponent.RowCount := iNewActiveChild + fComponent.FixedRows + 2; // including blank row
        BuildRow( pNewRow );
      end
      else
      begin
        fSigFileObject.ActiveChild := iNewActiveChild;
      end;
      SelectedRow := fComponent.RowBeingEdited;
    end;
  end;
end;

procedure tSigFileGridBindingObject.OnSigFileObjectChange(
  const pChangedObject: tSigBaseProperty);
var
  i: Integer;
  iName : string;
  icRow : tSigCompoundProperty;
  iChild : tSigBaseProperty;
  iRow, iCol : integer;
begin
  //if not fUpdating then
  //begin
    //fUpdating := TRUE;
    //try
      // we want to see if object is column entry for us, i.e. that object
      // is our Object's grandchild, or, equivalently, the grandparent is
      // our object.
      icRow := pChangedObject.Owner;
      if not assigned( icRow ) then
      begin
        exit;
      end;
      //if icRow.Owner <> fSigFileObject then
      if icRow.Owner <> fValidChild then
      begin
        exit;
      end;
      // OK, so it is to do with us. Now find the row
      iRow := -1;
      for i := 0 to Count - 1 do
      begin
        iChild := fSigFileObject.Entry[ i ];
        if iChild = icRow then
        begin
          iRow := i;
          break;
        end;
      end;
      if iRow = -1 then
      begin
        exit;
      end
      else
      begin
        inc( iRow, fComponent.FixedRows ); // change relative to absolute
      end;
      for i := 0 to Count - 1 do
      begin
        iName := Col[ i ].ID;
        iChild := icRow.Children.FindChild( iName );
        if iChild = pChangedObject then
        begin
          iCol := Col[ i ].Col;
          if iChild is tSigBooleanProperty then
          begin
            with iChild as tSigBooleanProperty do
            begin
              if ValueAsBool then
              begin
                fComponent.Cell[ iCol, iRow ] := '1';
              end
              else
              begin
                fComponent.Cell[ iCol, iRow ] := '0';
              end;
            end;
          end
          else
          begin
            fComponent.Cell[ iCol, iRow ] := iChild.Value;
          end;
        end;
      end;
    //finally
      //fUpdating := FALSE;
    //end;
  //end;
end;

procedure tSigFileGridBindingObject.SetSelectedRow(const Value: integer);
begin
  if assigned( fComponent ) then
  begin
    if SelectionCol >= 0 then
    begin
      if SelectedRow >= fComponent.FixedRows then
      begin
        fComponent.Cell[ SelectionCol, SelectedRow ] := '0';
      end;
    end;
  end;
  fSelectedRow := Value;
  if assigned( fComponent ) then
  begin
    if SelectionCol >= 0 then
    begin
      if SelectedRow >= fComponent.FixedRows then
      begin
        fComponent.Cell[ SelectionCol, SelectedRow ] := '1';
      end;
    end;
  end;
end;

{ tSigFileGridBindingColumn }

constructor tSigFileGridBindingColumn.Create(const pCol: integer;
  const pID: string);
begin
  inherited Create;
  fCol := pCol;
  fID := pID;
end;

{ tSigEditBindingObject }

constructor tSigEditBindingObject.Create(
  const pOwner: tSigFileBindingObjectList;
  const pSigfileObject: tSigBaseProperty; const pComponent: tComponent);
begin
  inherited;

  if fComponent is tEdit then
  begin
    with fComponent as tEdit do
    begin
      OnChange := self.Owner.ComponentChange;
    end;
  end
  else if fComponent is tMaskEdit then
  begin
    with fComponent as tMaskEdit do
    begin
      OnChange := self.Owner.ComponentChange;
    end;
  end
  else if fComponent is tSigSpinEdit then
  begin
    with fComponent as tSigSpinEdit do
    begin
      OnChange := self.Owner.ComponentChange;
    end;
  end;
  // we may be inside a change, so put update of editor on stack
  Owner.DelayedNotify( fSigfileObject );
end;

{
function tSigEditBindingObject.GetComponent: tCustomEdit;
begin
  Result := fComponent as tCustomEdit;
end;
}

procedure tSigEditBindingObject.OnComponentChange( Sender : tObject );
begin
  if Sender = fComponent then
  begin
    with fComponent as tCustomEdit do
    begin
      fSigFileObject.Value := Text;
    end;
  end;
end;

procedure tSigEditBindingObject.OnSigFileObjectChange(
  const pChangedObject: tSigBaseProperty);
begin
  if pChangedObject = fSigFileObject then
  begin
    with fComponent as tCustomEdit do
    begin
      Text := fSigFileObject.Value;
    end;
  end;
end;

{ tSigBaseBindingObject }

constructor tSigBaseBindingObject.Create(
  const pOwner: tSigFileBindingObjectList);
begin
  inherited Create;
  fOwner := pOwner;
end;

{ tSigCellEditChangePendingObject }

constructor tSigCellEditChangePendingObject.Create(const pObject: tObject;
  const pCol, pRow: integer; const pValue: string);
begin
  inherited Create;
  fObject := pObject;
  fCol := pCol;
  fRow := pRow;
  fValue := pValue;
end;

{ tSigPendingRowChangeObject }

constructor tSigPendingRowChangeObject.Create(const pObject: tObject;
  const pRow: integer);
begin
  inherited Create;
  fObject := pObject;
  fRow := pRow;
end;

{ tSigBaseBindingStringList }

constructor tSigBaseBindingStringList.Create(pOwner: tSigFileBindingObjectList;
  const pSigFileObject: tSigCompoundProperty;
  const pChildProperty : string;
  const pList: tStrings);
begin
  inherited Create( pOwner );

  fSigFileObject := pSigFileObject;
  fList := pList;
  fChildProperty := pChildProperty;

  if not assigned( fSigFileObject.OnMaxChange ) then
  begin
    fSigFileObject.OnMaxChange := fOwner.OnMaxChange;
  end;
  if not assigned( fSigFileObject.OnNotify ) then
  begin
    fSigFileObject.OnNotify := fOwner.Notify;
  end;

  SetupList;

end;

procedure tSigBaseBindingStringList.OnMaxChange(const Sender: tSigBaseProperty;
  const NewVal: integer);
begin
  if Sender = fSigFileObject then
  begin
    SetupList;
  end;
end;

procedure tSigBaseBindingStringList.OnSigFileObjectChange(
  const pChangedObject: tSigBaseProperty);
var
  i: Integer;
begin
  if (pChangedObject.Owner = fSigFileObject) or (pChangedObject.Owner.Owner = fSigFileObject) then
  begin
    for i := 0 to fList.Count - 1 do
    begin
      if fList.Objects[ i ] = pChangedObject then
      begin
        fList.Strings[ i ] := pChangedObject.Value;
        exit;
      end;
    end;
  end;
end;

procedure tSigBaseBindingStringList.SetupList;
var
  i: Integer;
  iChild : tSigCompoundProperty;
  iChildValue : tSigBaseProperty;
begin
  fList.Clear;
  for i := 0 to fSigFileObject.Max do
  begin
    iChild := fSigFileObject.Entry[ i ] as tSigCompoundProperty;
    iChildValue := iChild.Children.FindChild( fChildProperty );
    fList.AddObject( iChildValue.Value, iChildValue );
  end;
end;

{ tSigBindingStringListComponent }

constructor tSigBindingStringListComponent.Create(
  pOwner: tSigFileBindingObjectList; const pSigFileObject: tSigCompoundProperty;
  const pChildProperty: string; const pComponent: tComponent;
  const pList: tStrings);
begin
  inherited Create( pOwner, pSigFileObject, pChildProperty, pList );

  fComponent := pComponent;
  //if not assigned( fSigFileObject.OnChange ) then
  //begin
  //  fSigFileObject.OnChange := fOwner.OnSigFileObjectChange;
  //end;
end;

{ tSigBindingTabSheet }

constructor tSigBindingTabControl.Create(pOwner: tSigFileBindingObjectList;
  const pSigFileObject: tSigCompoundProperty; const pChildProperty: string;
  const pComponent: tTabControl);
begin
  inherited Create( pOwner, pSigFileObject, pChildProperty, pComponent, pComponent.Tabs );

  with Component do
  begin
    OnChange := self.Owner.ComponentChange;
  end;
end;

function tSigBindingTabControl.GetComponent: tTabControl;
begin
  result := fComponent as tTabControl;
end;

procedure tSigBindingTabControl.OnActiveChildChange(
  const Sender: tSigCompoundProperty; const pNewChild: integer);
begin
  if Sender = SigFileObject then
  begin
    if Component.TabIndex <> pNewChild then
    begin
      Component.TabIndex := pNewChild;
    end
    else
    begin
      Component.OnChange( Component ); // force a change action anyway
    end;
  end;
end;

procedure tSigBindingTabControl.OnComponentChange( Sender : tObject );
begin
  if Sender = fComponent then
  begin
    fSigFileObject.ActiveChild := Component.TabIndex;
  end;
end;

{ tSigActiveChildComponent }

constructor tSigActiveChildComponent.Create(
  const pOwner: tSigFileBindingObjectList;
  const pSigFileObject: tSigCompoundProperty;
  const pCallback: tSigOnActiveChildChange);
begin
  inherited Create( pOwner );
  fSigFileObject := pSigFileObject;
  fCallback := pCallback;

  if not assigned( fSigFileObject.OnActiveChildChange ) then
  begin
    fSigFileObject.OnActiveChildChange := fOwner.OnActiveChildChange
  end;
end;


procedure tSigActiveChildComponent.OnActiveChildChange(
  const Sender: tSigCompoundProperty; const pNewChild: integer);
begin
  if Sender = SigFileObject then
  begin
    if assigned( fCallback ) then
    begin
      fCallback( Sender, pNewChild );
    end;
  end;
end;

{ tSigActiveChildComponentShow }

constructor tSigActiveChildComponentShow.Create(
  const pOwner: tSigFileBindingObjectList;
  const pSigFileObject: tSigCompoundProperty; const pComponent: tControl);
begin
  inherited Create( pOwner, pSigFileObject, nil );

  fComponent := pComponent;
end;

destructor tSigActiveChildComponentShow.Destroy;
begin
  if assigned( fComponent ) then
  begin
    try
      fComponent.Visible := FALSE;
    except

    end;
  end;
  inherited;
end;

procedure tSigActiveChildComponentShow.OnActiveChildChange(
  const Sender: tSigCompoundProperty; const pNewChild: integer);
begin
  inherited;

  fComponent.Visible := pNewChild > 0;
end;

{ tSigFileVariableEditorList }

function tSigFileVariableEditorList.AddRow(pName: string;
  pEditorStyle: tSigVariableEditorStyle; pCaption: string): integer;
var
  iEditor : tSigVariableEditor;
  iProperty : tSigBaseProperty;
begin
  // our count property is the actual editor
  iEditor := fComponent.Editor[ Count ];
  if assigned( iEditor ) then
  begin
    if iEditor.EditorStyle <> pEditorStyle then
    begin
      iEditor.EditorStyle := pEditorStyle;
    end;
  end
  else
  begin
    iEditor := fComponent.Add( pEditorStyle );
  end;
  iEditor.LabelText := pCaption;
  iProperty := fSigFileObject.Children.FindChild( pName );
  if not assigned( iEditor.OnChange ) then
  begin
    iEditor.OnChange := Owner.ComponentChange;
  end;
  Result := Add( tSigFileVariableEditorLine.Create( self, iEditor, iProperty ));
  // we may be inside a change, so put update of editor on stack
  Owner.DelayedNotify( iProperty );
end;

function tSigFileVariableEditorList.AddRow(
  pEditorStyle: tSigVariableEditorStyle; pCaption, pButtonText : string;
  pCallBack: tNotifyEvent): integer;
var
  iEditor : tSigVariableEditor;
begin
  // our count property is the actual editor
  iEditor := fComponent.Editor[ Count ];
  if assigned( iEditor ) then
  begin
    if iEditor.EditorStyle <> pEditorStyle then
    begin
      iEditor.EditorStyle := pEditorStyle;
    end;
  end
  else
  begin
    iEditor := fComponent.Add( pEditorStyle );
  end;
  iEditor.LabelText := pCaption;
  if not assigned( iEditor.OnChange ) then
  begin
    iEditor.OnChange := Owner.ComponentChange;
  end;
  iEditor.Text := pButtonText;
  Result := Add( tSigFileVariableEditorLine.Create( self, iEditor, pCallBack ));
end;

constructor tSigFileVariableEditorList.Create(
  const pOwner: tSigFileBindingObjectList;
  const pSigfileObject: tSigCompoundProperty;
  const pComponent: TSigVariableEditorList);
begin
  inherited Create( TRUE );

  fOwner := pOwner;
  fSigFileObject := pSigFileObject;
  fComponent := pComponent;

  // we do not clear the component because in general the component is not reused for different object types
  // This can, of course be done externally if requied when adding this object

  if not assigned( fSigFileObject.OnNotify ) then
  begin
    fSigFileObject.OnNotify := Owner.Notify;
  end;
end;

function tSigFileVariableEditorList.GetLine(
  const i: integer): tSigFileVariableEditorLine;
begin
  Result := Items[ i ] as tSigFileVariableEditorLine;
end;

procedure tSigFileVariableEditorList.OnComponentChange(Sender: tObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    with Line[ i ] do
    begin
      if Editor = Sender then
      begin
        if assigned( SigProperty ) then
        begin
          SigProperty.Value := Editor.Text;
        end
        else if assigned( fCallBack ) then
        begin
          fCallBack( Sender );
        end;
        exit;
      end;
    end;
  end;
end;

procedure tSigFileVariableEditorList.OnSigFileObjectChange(
  const pChangedObject: tSigBaseProperty);
var
  i: Integer;
begin
  if pChangedObject.Owner = fSigFileObject then
  begin
    for i := 0 to Count - 1 do
    begin
      if Line[ i ].SigProperty = pChangedObject then
      begin
        Line[ i ].Editor.Text := pChangedObject.Value;
      end;
    end;
  end;
end;

{ tSigFileVariableEditorLine }

constructor tSigFileVariableEditorLine.Create(
  const pOwner: tSigFileVariableEditorList; const pEditor: tSigVariableEditor;
  const pSigProperty : tSigBaseProperty);
begin
  inherited Create;
  fOwner := pOwner;
  fEditor := pEditor;
  fSigProperty := pSigProperty;
end;

constructor tSigFileVariableEditorLine.Create(
  const pOwner: tSigFileVariableEditorList; const pEditor: tSigVariableEditor;
  const pCallBack: tNotifyEvent);
begin
  inherited Create;
  fOwner := pOwner;
  fEditor := pEditor;
  fCallBack := pCallBack;
end;

initialization
  SigFileBindingObjectList := tSigFileBindingObjectList.Create;

finalization
  SigFileBindingObjectList.Free;

end.
