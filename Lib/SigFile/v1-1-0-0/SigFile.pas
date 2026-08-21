{ $DEFINE FMX_SIGFILE}  // temporary to help editor!

{$IFNDEF VCL_SIGFILE}
{$IFNDEF FMX_SIGFILE}
unit SigFile;
{$ENDIF}
{$ENDIF}

{
  Change in 1.0.7.0 undoCreate responsibility now moved to 'tSigPropertyList'

  Method of use.

  A SigFile is a concept, not an object class. It is meant to store
  and retreive the construct of complex objects or collections of
  objects.

  If it is a single complex object, it will be decended from (or an instance of)
  tSigComplexObject. If it is a collection of objects it will be a descendant
  or instance (more likely instance) of tSigPropertyList created with a nil
  owner.

  You can attach your own objects to the Data element tSigBaseProperty for
  whatever purpose you wish. They are not accessed in this routine.

  For array objects, set ArrayElementCreationText in the constructor
  to allow children of the appropriate type to be created. In the element
  class it is a good idea to create a class function ObjectText so
  ArrayElementCreationText can be simply

    ArrayElementCreationText := MyChild.ClassType + ' ' + TQCapcode.ObjectText;

  --------------------------------------------------------------------

  Undo/Redo lists.

  These usually involve a user interface element, so must be carried out by the
  host program. However support for undo lists is included. To use these
  set up the OnUndo
  ableAction and OnRedoableAction for the top level
  entity. (Lower level entities are also allowed for independant undo and
  redo lists). Optionally OnPrepareUndoableAction and OnCompleteUndoableAction
  can be added to handle group actions.

  When an item is changed it calls the OnUndoableAction procedure passing itself,
  an action and undo string. If the action is ClearUndoList the the action is
  not reversible and the host must clear the undo and redo lists. Any other action
  can be saved to the undo list (which must be a LIFO list or stack - use a
  descendant of TObjectStack). To undo an action Call the Undo function, which
  calls the OnRedoableAction to maintain a redo list. Similarly a call to the Redo
  function would call OnUndoableAction to maintain a dual list.

  Most typically a program might have a tabbed display, so an UndoRedo object
  would have the tab reference, the SigObjectReference, the tSigFileUndoAction
  and the  pUndoString. So the host program, to issue an undo woulf call
  the SigObjectReference Undo function and force a recalculation of the visible
  tab (and probably change to that tab)

  Note - a generic Undo/Redo stack is provided in Lib\UndoRedo. This
  stores and restores a tag which a host can use as it wishes - often
  to change tabs as part of the undo/redo action

  An 'undo delete' is generally not supported. However, for arrays is
  is acheived by 'clearing' and object before deleting it and
  then reassigning the indexes. This means that an undo can create
  the object and reinsert it at the original location, then undoing
  the clear. This means that a block undo (see UndoRedo.pas) must
  be active for an undelete to work successfully delete.

  -----------------------------------------------------------------------

  Further extensions allow editor properties and support sending to and from a device
  and a record of whether the data has been sent to a device

  -----------------------------------------------------------------------

  tSigEnum<T> is a special enum class which utilises, and can populate a
  drop down list. <T> is the type of the typedef. It should contain an
  _ character that separates the prefix from the text. Further _ characters
  are converted to spaces.
}

interface

uses
  SigParse,
  SysUtils,
  Classes,
{$IFDEF VCL_SIGFILE}
  VCL.ErrorList,
{$ELSE}
{$IFDEF FMX_SIGFILE}
  FMX.ErrorList,
{$ELSE}
  ErrorList,
{$ENDIF}
{$ENDIF}
  Contnrs,
{$IFDEF FMX_SIGFILE}
  FMX.Common,
  FMX.Forms,
  FMX.Controls,
  FMX.Edit,
  FMX.ListBox,
  FMX.SigVariableEditor,
  FMX.Memo,
  FMX.SigSaveDialog,
  FMX.Menus,
{$ELSE}
  Common,
  Dialogs,
  Windows,
  Forms,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  Mask,
  VCL.Samples.Spin,
  Menus,
  SelectableEdit,
  HTMLHelpViewer,
  VCL.Controls,
  Graphics,
  CheckLst,
  Grids,
  Calendar,
  SigSpinEdit,
  SigGeneralGrid,
  SigSaveDialog,
  TimeSpinButton,
{$ENDIF}
  Math,
  //TypedObjectList,
  System.Generics.Collections,
  System.Types,
  TypInfo;


type
  tSigLoadAction = (laNone, laLoadingFromDevice, laComparingFromDevice );
  tSigFileUndoAction = ( undoClear, undoUnClear, undoClearUndoList, undoValue, undoChangeMax, undoAdd,
                         undoInsert2, undoDelete2, undoUndelete2, undoSelPos, undoSelLen,
                         undoChangeActiveChild, undoMove, undoSwap2, undoPointer,
                         undoSort, undoUnSort );
  tSigBaseProperty = class;
  tSigCompoundProperty = class;
  tSigBasePropertyClass = class of tSigBaseProperty;
  tSigFileProperty = class;
  tSigOnChange = procedure( const pChangedObject : tSigBaseProperty ) of object;
  tSigOnActiveChildChange = procedure( const Sender : tSigCompoundProperty; const pNewChild : integer ) of object;
  tSigOnBoolChange = procedure( const NewVal : boolean ) of object;
  tSigOnIntegerChange = procedure( const Sender : tSigBaseProperty; const NewVal : integer ) of object;
  tSigOnDirtyChange = procedure( const pChangedObject : tSigBaseProperty; const NewState : boolean ) of object;
  tSigOnUndoableAction = procedure( const pObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ) of object;
  tTranslateValue = function( const Value : string ) : string of object;
  tValueOnDeviceChecked = ( vod_SameAsEnabled, vod_FALSE, vod_TRUE );
  tSigBasePropertyList = class;
  tSigPropertyList = class;
  tOnGetBoolean = function( const pProperty : tSigBaseProperty ) : boolean of object;

  tOnSigLoadLine = procedure( const pLine, pLineCount : integer ) of object;

  TSigBaseProperty = class
  private
    fPropertyName: string;
    fIndexed: boolean;
    fIndex: string;
    fIsDirty: boolean;
    fValue: string;
    fValueOnDevice : string;
    fData: tObject;
    fSigOnChange: tSigOnChange;
    fOnDirtyChange: tSigOnDirtyChange;
    fOnUndoableAction: tSigOnUndoableAction;
    fOnRedoableAction: tSigOnUndoableAction;
    fOnTranslateValue: tTranslateValue;
    fOnPrepareUndoableAction: tSigOnUndoableAction;
    fOnCompleteUndoableAction: tSigOnUndoableAction;
    fEnabled: boolean;
    fLoadingFromDevice: tSigLoadAction;
    fLabel: tLabel;
    fOnEditorChange : tNotifyEvent;
    fOnEditorExit : tNotifyEvent;
    fValueOnDeviceChecked: tValueOnDeviceChecked;  // Whether value is compared with that on device, NOT whether it has been!
    fSaveWithFile: boolean;
    fLoadingFromFile: boolean;
    fVisible: boolean;
    fOnGetVisible: tOnGetBoolean;
    fOnLoadLine: tOnSigLoadLine;
    fUndoing : integer;
    fRedoing : integer;
    fOnNotify: tSigOnChange;
    fLoadingFromTemplate: boolean;
    fValueOnDeviceEditor: tEdit;
    fLoadable: boolean;
    fUpdateOnEditorChange: boolean;
    fUpdateOnEditorExit: boolean;
    procedure SetIndex(const pValue: string);
    function GetSentToDevice: boolean;
    procedure SetLabel(const Value: tLabel);
    function GetCreating: boolean;
    procedure SetSigOnChange(const Value: tSigOnChange);
    function GetOwnerFile: tSigFileProperty;
    function GetLoadingFromFile: boolean;
    procedure SetVisible(const Value: boolean);
    function GetUndoing: boolean;
    procedure SetUndoing(const Value: boolean);
    procedure CompleteUndoing; virtual;
    function GetRedoing: boolean;
    procedure SetRedoing(const Value: boolean);
    procedure CompleteRedoing; virtual;
    function GetLoadingFromTemplate: boolean;
    procedure SetValueOnDeviceEditor(const Value: tEdit);
    function GetExecutingAfterLoad: boolean;
  protected
    fOwner: tSigCompoundProperty;
    fCreating : boolean;
    fChanging : boolean; // a flag used by descendants where editor feedback is a problem, e.g. tMemoProperty
    fInterestedParties : tSigBasePropertyList; // list of people who need to know if we are changed or destroyed
    fDestroying : boolean;
    fUnDestroying : boolean;
    fExecutingAfterLoad : boolean;
    function GetStringListText: string; virtual;
    function GetLoadingFromDevice: tSigLoadAction; virtual;
    procedure SetValue(const pValue: string); virtual;
    function GetValue: string; virtual;
    procedure SetIsDirty(const Value: boolean); virtual;
    function GetReqData: string; virtual;
    function GetDataToSend: string; virtual;
    procedure SetDataToSend(const Value: string); virtual;
    procedure SetEnabled( const Value : boolean ); virtual;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; virtual;
    procedure SetData(const Value: tObject); virtual;
    property Creating : boolean
             read GetCreating
             write fCreating;
    procedure RemoveEditors; virtual;
    procedure ReinstateEditors; virtual;
    procedure OnInterestedPartyDestroy( const pParty : tSigBaseProperty ); virtual;
    procedure OnInterestedPartyReinstate( const pParty : tSigBaseProperty ); virtual;
    function OnInterestedPartyCanDestroy( const pParty : tSigBaseProperty ) : boolean; virtual;
    procedure RefreshEditor; overload; virtual;
    function GetVisible: boolean; virtual;
    procedure LoadLine( const pLine, pLineCount : integer );
    procedure OnUndo( const pObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ); virtual;
    procedure OnRedo( const pObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ); virtual;
    procedure Notify( const Sender : tSigBaseProperty );
    procedure ShowDeviceEditor; virtual;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); overload; virtual;
    constructor Create( pPropertyName : string; pIndex : string; pOwner : tSigCompoundProperty ); overload; virtual;
    //constructor Create( pPropertyName : string; pIndex : integer; pOwner : tSigCompoundProperty ); overload; virtual;
    destructor Destroy; override;

    procedure OnDestroy; virtual; // does the non-destructive bits of destroy
    procedure OnUnDestroy; virtual;

    procedure Assign( const pFrom : tSigBaseProperty; const AllowUndo : boolean ); virtual;

    function CanDestroy : boolean; virtual; // does not prevent destruction - just says if it is safe to destroy me

    procedure OnCompleteUndo; virtual;
    procedure OnCompleteRedo; virtual;

    procedure AfterConstruction; override;
    procedure Clear; virtual;
    procedure ExecutePrepareUndoableAction(const pChangedObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ) ; virtual;
    procedure ExecuteUndoableAction(const pChangedObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ) ; virtual;
    procedure ExecuteCompleteUndoableAction(const pChangedObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ) ; virtual;
    procedure ExecuteRedoableAction(const pChangedObject : tSigBaseProperty; const pUndoAction : tSigFileUndoAction; const pUndoString : string ) ; virtual;
    function IsMe( pName, pIndex : string ) : boolean;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; virtual;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; virtual;
    procedure AbortLoad( pFile : tStrings; var pLine : integer; pErrors : tErrorList = nil ); virtual;
    function MatchesDataOnDevice : boolean; virtual;

    procedure RemoveInterest; virtual;
    procedure ReinstateInterest; virtual;

    procedure AfterLoad; virtual;
    procedure DoAfterLoad; // calls Afterload

    function GetOwnerOfType( pType : tSigBasePropertyClass ) : tSigCompoundProperty;

    function Errors( pErrorList : tErrorList = nil ) : boolean; virtual;
    procedure CheckErrors( var pErrorCount, pWarningCount, pHintCount : integer; pErrors : tErrorList ); virtual;
    // more sophisticated error checking

    property AmUndoing : boolean
             read GetUndoing
             write SetUndoing;
    property AmRedoing : boolean
             read GetRedoing
             write SetRedoing;

    property Data : tObject // associated object, if any.
             read fData
             write SetData;
    property Indexed : boolean
             read fIndexed;
    property Index : string
             read fIndex
             write SetIndex;
    property IsDirty : boolean
             read fIsDirty
             write SetIsDirty;
    property Owner : tSigCompoundProperty
             read fOwner;
    property PropertyName : string
             read fPropertyName;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); overload; virtual;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function Save( pTreeNodes : tTreeNodes; pTreeNode : tTreeNode ) : tTreeNode; overload; virtual;
{$ENDIF}
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); virtual;
    property Value : string
             read GetValue
             write SetValue;
    property ValueOnDevice : string
             read fValueOnDevice;

    property OnChange : tSigOnChange
             read fSigOnChange
             write SetSigOnChange;
    property OnDirtyChange : tSigOnDirtyChange
             read fOnDirtyChange
             write fOnDirtyChange;
    property OnPrepareUndoableAction : tSigOnUndoableAction
             read fOnPrepareUndoableAction
             write fOnPrepareUndoableAction;
    property OnUndoableAction : tSigOnUndoableAction
             read fOnUndoableAction
             write fOnUndoableAction;
    property OnCompleteUndoableAction : tSigOnUndoableAction
             read fOnCompleteUndoableAction
             write fOnCompleteUndoableAction;
    property OnRedoableAction : tSigOnUndoableAction
             read fOnRedoableAction
             write fOnRedoableAction;
    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); virtual;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); virtual;
    property DataToSend : string   // for use with hardware that is transmitted to to create and interpret records seny
             read GetDataToSend
             write SetDataToSend;
    property SentToDevice : boolean
             read GetSentToDevice;
    property OnTranslateValue : tTranslateValue
             read fOnTranslateValue
             write fOnTranslateValue;
    function TranslateValue( Value : string ) : string;

    function Translate( const pVal : string ) : string; virtual;

    property Enabled : boolean
             read fEnabled
             write SetEnabled;
    property LoadingFromDevice : tSigLoadAction
             read GetLoadingFromDevice
             write fLoadingFromDevice;
    property Undoing : boolean
             read GetUndoing;
    property GUILabel : tLabel
             read fLabel
             write SetLabel;
    property ValueOnDeviceChecked : tValueOnDeviceChecked
             read fValueOnDeviceChecked
             write fValueOnDeviceChecked;
    property OwnerFile : tSigFileProperty
             read GetOwnerFile;

    property OnGetVisible : tOnGetBoolean
             read fOnGetVisible
             write fOnGetVisible;
    property OnLoadLine : tOnSigLoadLine
             read fOnLoadLine
             write fOnLoadLine;
    property Visible : boolean
             read GetVisible
             write SetVisible;
    property SaveWithFile : boolean
             read fSaveWithFile
             write fSaveWithFile;
    property Loadable : boolean
             read fLoadable
             write fLoadable;

    property LoadingFromFile : boolean
             read GetLoadingFromFile
             write fLoadingFromFile;
    property LoadingFromTemplate : boolean
             read GetLoadingFromTemplate
             write fLoadingFromTemplate;
    property ExecutingAfterLoad : boolean
             read GetExecutingAfterLoad;

    property StringListText : string
             read GetStringListText;
    function ObjectAffectsStringListText( const pChangedObject: tSigBaseProperty ) : boolean; virtual;

    class function ClassType : string; virtual; abstract;
    class function TerminationString : string; virtual;

    function PrintStructureString : string ; virtual; abstract;

    procedure RegisterInterest( pSigObject : tSigBaseProperty );
    procedure UnregisterInterest( pSigObject : tSigBaseProperty );

    procedure ListIfDirty( pStrings : tStrings; const pIndent : integer = 0 ); virtual;

    procedure StartLoadingFromDevice;
    procedure EndLoadingFromDevice;

    function IamActiveChild : boolean;

    property OnNotify : tSigOnChange
             read fOnNotify
             write fOnNotify;
    property ValueOnDeviceEditor : tEdit
             read fValueOnDeviceEditor
             write SetValueOnDeviceEditor;

    property UpdateOnEditorChange : boolean
             read fUpdateOnEditorChange
             write fUpdateOnEditorChange;
    property UpdateOnEditorExit : boolean
             read fUpdateOnEditorExit
             write fUpdateOnEditorExit;
  end;

  tSigBasePropertyList = class( TObjectList )
  {
    Introduces the basic properties for the fact that its children are all
    tSigBaseProperty entities, but none of the additional functionality
    for handling Undo/Redo
  }
  private
    function GetItem(const pIndex : integer): tSigBaseProperty;
  protected
  public
    property Item[ const pIndex : integer ] : tSigBaseProperty
             read GetItem;
             default;

  end;

  tSortedChild = class
  private
    fSorter: TListSortCompare;
    fList: tObjectList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    property Sorter : TListSortCompare
             read fSorter
             write fSorter;
    property List : tObjectList
             read fList;

    procedure Add( pObject : tObject );
  end;

  tSortedChildren = class( tObjectList )
  private
    fIndex: integer;
  public
    constructor Create; reintroduce;
    property CurrentIndex : integer
             read fIndex;
    function Undo : tSortedChild;
    function Redo : tSortedChild;
    function Next( pSorter : TListSortCompare ) : tSortedChild;
  end;

  tSigPropertyList = class( tSigBasePropertyList )
  private
    fDeletedChildren : TObjectList;
    fSortedChildren : tSortedChildren; // only has copy of objects - never owns them
    fOwner: tSigCompoundProperty;
    procedure SetDirty(const Value: boolean);
    function GetIsDirty: boolean;
    function GetUndoing: boolean;
  protected
    procedure RemoveEditors; virtual;
  public

    procedure CompleteUndoing;
    procedure CompleteRedoing;

    procedure AfterConstruction; override;
    constructor Create( pOwner : tSigCompoundProperty );reintroduce; virtual;
    destructor Destroy; override;

    procedure ClearUndoList( SendMessage : boolean = TRUE );
    procedure ClearRedoList;

    procedure Sort( pSorter : TListSortCompare ); reintroduce;
    procedure UnSort( const pCount : integer ) ; overload;
    procedure UnSort( const pCount : string ) ; overload;

    procedure Clear; override;
    procedure UnClear( const pCount : integer; const pUndoAction : tSigFileUndoAction ); overload;
    procedure UnClear( const pCount : string; const pUndoAction : tSigFileUndoAction ); overload;

    function Add( Value : tSigBaseProperty; const pUndoAction : tSigFileUndoAction ) : integer; reintroduce;
    //procedure UnAdd;

    procedure Insert(Index: Integer; AObject: TObject; const pUndoAction : tSigFileUndoAction); reintroduce;
    procedure UnInsert(Index: Integer; const pUndoAction : tSigFileUndoAction); overload;
    procedure UnInsert(Index: string; const pUndoAction : tSigFileUndoAction); overload;

    procedure Delete(Index: Integer; const pUndoAction : tSigFileUndoAction ); reintroduce; overload;
    procedure Delete(Index: string; const pUndoAction : tSigFileUndoAction); reintroduce; overload;
    procedure UnDelete(Index: Integer; const pUndoAction : tSigFileUndoAction); overload;
    procedure UnDelete(Index: string; const pUndoAction : tSigFileUndoAction); overload;

    function Remove(AObject: TObject): Integer; reintroduce;
    procedure Move(CurIndex, NewIndex: Integer); reintroduce; overload;
    procedure Move(pString : string); reintroduce; overload;
    procedure UnMove(pString : string);

    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string );

    procedure Swap( pIndex1, pIndex2 : integer ); overload;
    procedure Swap( pString : string ); overload; // Swap in symetric, so UnSwap <=> Swap

    procedure RemoveInterest;
    procedure ReinstateInterest;

    function Errors( pErrorList : tErrorList = nil ) : boolean;
    procedure CheckErrors( var pErrorCount, pWarningCount, pHintCount : integer; pErrors : tErrorList ); virtual;
      // more sophisticated error checking

    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); overload;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function Save( pTreeNodes : tTreeNodes; pTreeNode : tTreeNode ) : tTreeNode; overload;
{$ENDIF}
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 );
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; virtual;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; virtual;

    function CreateChild( const pPropertyText : string; const pIndexText : string = '';
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil ; pErrorLine : integer = 0; pErrorPos : integer = 0 ) : tSigBaseProperty; overload; virtual;
    {
    function CreateChild( const pPropertyText : string; const pIndex : integer;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil ; pErrorLine : integer = 0; pErrorPos : integer = 0 ) : tSigBaseProperty; overload; virtual;
    }
    function FindChild( const pPropertyText : string; const pIndexText : string = '';
                        const Iterate : boolean = FALSE ) : tSigBaseProperty; virtual;

    function ChildMustExist : boolean;

    procedure ListIfDirty( pStrings : tStrings; const pIndent : integer = 0 ); virtual;

    property IsDirty : boolean
             read GetIsDirty
             write SetDirty;
    property Owner : tSigCompoundProperty
             read fOwner;

    property Undoing : boolean
             read GetUndoing;
  end;

  tSigPointer = class;

  tCheckPointerValid = procedure ( const pPointer : tSigPointer; var pIsValid : boolean ) of object;

  tSigPointer = class( tSigBaseProperty )
  private
    fDestinationObject: tSigBaseProperty;
    fOnCheckPointerValid: tCheckPointerValid;
    procedure SetDestinationObject(const Value: tSigBaseProperty);
  protected
    fDestinationList: tSigPropertyList;
    procedure OnInterestedPartyDestroy( const pParty : tSigBaseProperty ); override;
    function OnInterestedPartyCanDestroy( const pParty : tSigBaseProperty ) : boolean; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty; pDestinationList : tSigPropertyList); reintroduce; overload; virtual;
    constructor Create( pPropertyName : string; pIndex : string; pOwner : tSigCompoundProperty; pDestinationList : tSigPropertyList ); reintroduce; overload; virtual;

    procedure RemoveInterest; override;
    procedure ReinstateInterest; override;

    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;

    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    function PrintStructureString : string ; override;
    procedure AfterLoad; override;

    property DestinationList : tSigPropertyList
             read fDestinationList;  // we do NOT own this list!
    property DestinationObject : tSigBaseProperty  // we do NOT own this
             read fDestinationObject
             write SetDestinationObject;

    class function ClassType : string; override;
    class function TerminationString : string; override;

    function IsCurrentlyValid : boolean;
    property OnCheckPointerValid : tCheckPointerValid
             read fOnCheckPointerValid
             write fOnCheckPointerValid;
  end;

  TSigPointer< T : class > = class( TSigPointer )
  private
    function GetTarget: T;
    procedure SetTarget(const Value: T);
  public
    property Target : T
             read GetTarget
             write SetTarget;
  end;

  tSigAdaptablePointer = class;

  tOnAdaptablePointerNotifyEvent = procedure( Sender : tSigAdaptablePointer );
  tOnAdaptablePointerGetList = function( Sender : tSigAdaptablePointer ) : tSigPropertyList;

  tSigAdaptablePointer = class( tSigPointer )
  // like a tSigPointer, but the Destination list is variable. To this end we add
  // on OnGetVariable list parameter which is used to dynamically get the list.
  // If this is not present, the classic method is used, but Destination List
  // can be assigned. We also provide an 'After Load' method that gives an opportunity to
  // set the Destination List
  private
    fOnAfterLoad: tOnAdaptablePointerNotifyEvent;
    fOnGetList: tOnAdaptablePointerGetList;
    function GetDestinationList: tSigPropertyList;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty; pDestinationList : tSigPropertyList = nil); reintroduce; overload; virtual;
    constructor Create( pPropertyName : string; pIndex : string; pOwner : tSigCompoundProperty; pDestinationList : tSigPropertyList = nil ); reintroduce; overload; virtual;

    procedure AfterLoad; override;

    property DestinationList : tSigPropertyList   // we do NOT own this
             read GetDestinationList
             write fDestinationList;

    property OnAfterLoad : tOnAdaptablePointerNotifyEvent
             read fOnAfterLoad
             write fOnAfterLoad;
    property OnGetList : tOnAdaptablePointerGetList
             read fOnGetList
             write fOnGetList;
  end;

  tSigSimpleProperty = class( tSigBaseProperty )
    // always of the form pName = value  or pName( index ) = value
  private
  protected
    fComment: string;
    function GetComment: string; virtual;
    // procedure pOnChange( Sender : tObject );
  public
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    class function ClassType : string; override;
    class function TerminationString : string; override;
    property Comment : string
             read GetComment
             write fComment;
    function PrintStructureString : string ; override;
  end;

  tSigTextProperty = class( tSigSimpleProperty )
    // almost identical to tSigSimpleProperty, but with editor property
    // The editor is a CustomEdit, so can be either a tEdit or tMaskEdit, or
    // indeed a tMemo
  private
    fEdit: tCustomEdit;
    fMaxLen: integer;
    fPasswordEdit: boolean;
    fNumericOnly: boolean;
    procedure SetEdit(const Value: tCustomEdit);
    procedure SetMaxLen(const Value: integer);
    procedure SetPasswordEdit(const Value: boolean);
    procedure SetNumericOnly(const Value: boolean);
  protected
    procedure SetEnabled( const Value : boolean ); override;
    procedure RefreshEditor; override;
    procedure fOnEditChange( Sender : tObject ); virtual;
    procedure fOnEditExit( Sender : tObject ); virtual;
  public
    procedure OnDestroy; override;
    property Editor : tCustomEdit
             read fEdit
             write SetEdit;
    property MaxLen : integer
             read fMaxLen
             write SetMaxLen;
    property PasswordEdit : boolean
             read fPasswordEdit
             write SetPasswordEdit;
    property NumericOnly : boolean
             read fNumericOnly
             write SetNumericOnly;
  end;

  tSigBooleanProperty = class( tSigSimpleProperty )
  private
    fEdit: tCheckBox;
    procedure fOnEditChange( Sender : tObject );
    procedure SetEdit(const Value: tCheckBox);
  protected
    function GetValueAsBool: boolean; virtual;
    procedure SetValueAsBool(const pValue: boolean); virtual;
    procedure SetEnabled( const Value : boolean ); override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
    procedure RefreshEditor; override;
  public
    procedure OnDestroy; override;
    procedure Clear; override;
    property ValueAsBool : boolean
             read GetValueAsBool
             write SetValueAsBool;

    property Editor : tCheckBox
             read fEdit
             write SetEdit;
  end;

  tSigBaseIntegerProperty = class( tSigSimpleProperty )
  private
    fMaxVal: integer;
    fMinVal: integer;
    function GetValueAsText: string;  // by default = Value; override ValueToText to change
    procedure SetValueAsText( const pValue : string );  // by default = Value; override ValueToText to change
  protected
    function GetValueAsInt: integer; virtual;
    procedure SetValueAsInt(const pValue: integer); virtual;
    function ValueToText( pValue : integer ) : string; virtual;
    function TextToValue( pValue : string ) : integer; virtual;
    procedure SetMaxVal(const Value: integer); virtual;
    procedure SetMinVal(const Value: integer); virtual;
    function GetMinVal: integer; virtual;
    function GetMaxVal: integer; virtual;
  public
    procedure Clear; override;
    property ValueAsInt : integer
             read GetValueAsInt
             write SetValueAsInt;
    property ValueAsText : string
             read GetValueAsText
             write SetValueAsText;
    property MinVal : integer
             read GetMinVal
             write SetMinVal;
    property MaxVal : integer
             read GetMaxVal
             write SetMaxVal;
  end;

  tSigPrice = class( tSigBaseIntegerProperty )
  private
    fDecimalPlaces: integer;
    procedure SetDecimalPlaces(const Value: integer);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property DecimalPlaces : integer
             read fDecimalPlaces
             write SetDecimalPlaces;
  end;

  tSigInt64 = class( tSigBaseIntegerProperty )
  private
    function GetValueAsInt64: int64;
    procedure SetValueAsInt64(const Value: int64);
  public
    property ValueAsInt : int64
             read GetValueAsInt64
             write SetValueAsInt64;
  end;

  tSigIntegerProperty = class( tSigBaseIntegerProperty )
  private
{$IFDEF FMX_SIGFILE}
    fSpinEdit: tSpinBox;
    procedure SetSpinEdit(const Value: tSpinBox);
{$ELSE}
    fSpinEdit: tSigSpinEdit;
    procedure SetSpinEdit(const Value: tSigSpinEdit);
{$ENDIF}
    procedure fOnEditChange( Sender : tObject );
  protected
    function GetComment: string; override;
    procedure SetMaxVal(const Value: integer); override;
    procedure SetMinVal(const Value: integer); override;
    procedure RefreshEditor; override;
    procedure SetValue(const pValue: string); override;
  public
    procedure Clear; override;
    procedure OnDestroy; override;
{$IFDEF FMX_SIGFILE}
    property Editor : tSpinBox
             read fSpinEdit
             write SetSpinEdit;
{$ELSE}
    property Editor : tSigSpinEdit
             read fSpinEdit
             write SetSpinEdit;
{$ENDIF}
    function MatchesDataOnDevice : boolean; override;
  end;

  tSigBaseEnumProperty = class( tSigBaseIntegerProperty )
  private
    fVisible : LongWord;
    function GetVisible(const Index: integer): boolean; reintroduce;
    procedure SetVisible(const Index: integer; const Value: boolean);
  protected
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
  public
    procedure Clear; override;
    property Visible[ const Index : integer ] : boolean
             read GetVisible
             write SetVisible;
    procedure SetAllVisible(const Value: boolean);
    function MapItemToValue( Item : integer ) : integer; virtual;
    function MapValueToItem( pValue : integer ) : integer; virtual;
  end;

  tSigEnumProperty = class( tSigBaseEnumProperty )
  private
    fComboBox: tComboBox;
  protected
    procedure SetComboBox(const Value: tComboBox); virtual;
    procedure fOnEditChange( Sender : tObject ); virtual;
    procedure SetMaxVal(const Value: integer); override;
    procedure SetMinVal(const Value: integer); override;
    procedure SetEnabled( const Value : boolean ); override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
  public
    procedure OnDestroy; override;
    property Editor : tComboBox
             read fComboBox
             write SetComboBox;
    procedure RefreshEditor; override;
    procedure AssignItemList( const pList : tStrings );
  end;

  tSigEnum<T> = class( tSigBaseEnumProperty )
  private
    fTypeInfo : pTypeInfo;
    fTypeData : pTypeData;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEdit : tSelectableEdit;
{$ENDIF}
    //fDefaultValue : integer;
    procedure SetComboBox(const Value: tComboBox);
    function GetComboBox: tComboBox;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function GetRadioGroup: tRadioGroup;
    procedure SetRadioGroup(const Value: tRadioGroup);
{$ENDIF}
  protected
    procedure RefreshEditor; override;
  protected
    function ValueToText( pValue : integer ) : string; override;
    function TextToValue( pValue : string ) : integer; override;
    function GetValueAsInt: integer; override;
    procedure SetValueAsInt(const pValue: integer); override;
    procedure fOnEditChange( Sender : tObject );
    procedure SetEnabled( const Value : boolean ); override;
    procedure SetMaxVal(const Value: integer); override;
    procedure SetMinVal(const Value: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure OnDestroy; override;
    procedure Clear; override;
    procedure AssignItemList( const pList : tStrings );
{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : tSelectableEdit
             read fEdit;
    property RadioGroup : tRadioGroup
             read GetRadioGroup
             write SetRadioGroup;
{$ENDIF}
    property ComboBox : tComboBox
             read GetComboBox
             write SetComboBox;
    function IsConsistent : boolean; // returns TRUE if value is legal (visible), false if not
    function StrToInt( pName : string ) : integer;
  end;

  tSigEnumSet<T> = class( tSigBaseEnumProperty )
  private
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEdit : tCheckListBox;
{$ENDIF}
    fTypeInfo : pTypeInfo;
    fTypeData : pTypeData;
    fInverted : word;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetEdit(const Value: tCheckListBox);
{$ENDIF}
    function GetChecked(const index: integer): boolean;
    procedure SetChecked(const index: integer; const Value: boolean);
    function GetInverted(const Index: integer): boolean;
    procedure SetInverted(const Index: integer; const Value: boolean);
  protected
    procedure fOnEditChange( Sender : tObject );
    procedure SetMaxVal(const Value: integer); override;
    procedure SetMinVal(const Value: integer); override;
    function ValueToText( pValue : integer ) : string; override;
    procedure RefreshEditor; override;
    procedure SetEnabled( const Value : boolean ); override;
  public
    procedure OnDestroy; override;
    procedure Clear; override;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : tCheckListBox
             read fEdit
             write SetEdit;
{$ENDIF}
    property Checked[ const index : integer ] : boolean
             read GetChecked
             write SetChecked;
    property Inverted[ const Index : integer ] : boolean
             read GetInverted
             write SetInverted;
  end;

  tSigDateTimeProperty = class( tSigSimpleProperty )
  private
  { Always stored in UK format }
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEditor: tCalendar;
    fOnEditorChange : tNotifyEvent;
    fOnTimeEditorChange : tNotifyEvent;
    fTimeEditor: TTimeSpinButton;
    fFormatSettings : tFormatSettings;
    procedure EditorChange( Sender : tObject );
    procedure TimeEditorChange( Sender : tObject );
{$ENDIF}
    function GetValueAsDateTime: TDateTime;
    procedure SetValueAsDateTime(const pValue: TDateTime);
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetEditor(const Value: tCalendar);
    procedure SetTimeEditor(const Value: TTimeSpinButton);
    function GetValueAsTime: tDateTime;
    procedure SetValueAsTime(const pValue: tDateTime);
  protected
    procedure RefreshEditor; override;
    procedure RemoveEditors; override;
{$ENDIF}
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure Clear; override;
    property ValueAsDateTime : TDateTime             // really a date only
             read GetValueAsDateTime
             write SetValueAsDateTime;
    property ValueAsDate : tDateTime                 // equivalent to ValueAsDateTime
             read GetValueAsDateTime
             write SetValueAsDateTime;
    property ValueAsTime : tDateTime                 // equivalent to ValueAsDateTime
             read GetValueAsTime
             write SetValueAsTime;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : tCalendar
             read fEditor
             write SetEditor;
    property TimeEditor : TTimeSpinButton
             read fTimeEditor
             write SetTimeEditor;
{$ENDIF}
  end;

  tOnArrayChildAddRemove = procedure ( pChild : tSigBaseProperty ) of object;
  tOnArrayChildDeleteUndelete = procedure ( pIndex : integer; pChild : tSigBaseProperty ) of object;
  tOnArrayChildMove = procedure( const pFrom, pTo : integer ) of object;
  tOnIndexChange = procedure( const pNewIndex : integer ) of object;

  tStringListControl = class
    // encapsulation of a control with a string list such as a TListBox or TTabControl
  private
    fControl: TWinControl;
    fOnIndexChange: tOnIndexChange;
    fIndex: integer;
    fChangesActiveChild: boolean;
    fOriginalChangeEvent : TNotifyEvent;
    fSavedText : string;
    function fStrings : TStrings;
    function GetCount: integer;
    procedure SetOnIndexChange(const Value: tOnIndexChange);
    procedure OnListBoxChange( Sender : TObject );
    procedure OnComboBoxChange( Sender : TObject );
    procedure OnTabControlChange( Sender : TObject );
    procedure SetIndex(const Value: integer);
    function GetStrings(const i: integer): string;
    procedure SetStrings(const i: integer; const Value: string);
    function GetIndex: integer;
  protected

  public
    constructor Create( const pWinControl : tWinControl; const pChangesActiveChild : boolean );

    property Control : TWinControl
             read fControl;

    property Count : integer
             read GetCount;

    property Strings[ const i : integer ] : string
             read GetStrings
             write SetStrings;

    property Index : integer
             read GetIndex
             write SetIndex;

    property OnIndexChange : tOnIndexChange
             read fOnIndexChange
             write SetOnIndexChange;

    property ChangesActiveChild : boolean
             read fChangesActiveChild;

    function AddString( const pString : string ) : integer;
    procedure ClearStrings;
    procedure RestoreSelection;

  end;

  tStringListControlList = class( TObjectList<tStringListControl> )
  private
    fCurrentOwner: tSigCompoundProperty;
    fIndex: integer;
    function GetControl(const i: integer): TWinControl;
    procedure SetCurrentOwner(const Value: tSigCompoundProperty);
    procedure OnIndexChange( const pNewIndex : integer );
    procedure SetIndex(const Value: integer);
    function GetMax: integer;
  protected
  public
    constructor Create; reintroduce;
    function RegisterControl( const pControl : TWinControl; const pChangesActiveChild : boolean ) : integer;
    procedure UnregisterControl( const pControl : TWinControl );

    property Control[ const i : integer ] : TWinControl
             read GetControl;
    property CurrentOwner : tSigCompoundProperty
             read fCurrentOwner
             write SetCurrentOwner;

    procedure ClearStrings;
    procedure AddString( const pString : string );
    procedure ChangeString( const pIndex : integer; const pString : string );

    property Index : integer
             read fIndex
             write SetIndex;
    property Max : integer
             read GetMax;
  end;

  TSigCompoundProperty = class( TSigBaseProperty )
  private
    fChildren: tSigPropertyList;
    //fDeletedChildren : tSigPropertyList;
    fChangedChild: tSigBaseProperty;
    fSaveActiveChild: boolean;
    fOnActiveChildChange: tSigOnActiveChildChange;
    fOnRemoveChild: tOnArrayChildAddRemove;
    fOnDelete: tOnArrayChildDeleteUndelete;
    fOnUnDelete: tOnArrayChildDeleteUndelete;
    fOnMoveChild: tOnArrayChildMove;
    fOnSwapChild: tOnArrayChildMove;
    fSaveMax: boolean;
    fChangingMax: boolean;
    fMax: integer;
    fOnMaxChange: tSigOnIntegerChange;
    function GetCount: integer;
    procedure SetActiveChildBase(const Value: integer);
    procedure SetOnMaxChange(const Value: tSigOnIntegerChange); virtual;
    function GetOnMaxChange: tSigOnIntegerChange; virtual;
    procedure CompleteUndoing; override;
    procedure CompleteRedoing; override;
  protected
    fStringListControlList: tStringListControlList;
    fActiveChild: integer;
    fPendingActiveChild : integer;
    fMaxChildren : integer; // 0 = no limit. Used to limit editors in descendants where required
    procedure SetMax(const Value: integer); virtual;
    function GetMax: integer; virtual;
    function GetEntry(const i: integer): tSigBaseProperty; virtual;
    procedure SetSaveMax(const Value: boolean); virtual;
    function GetActiveChild: integer; virtual;
    procedure SetActiveChild(const pValue: integer); virtual;
    procedure SetIsDirty(const Value: boolean); override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
    procedure SetEnabled( const Value : boolean ); override;
    procedure RemoveEditors; override;
    property SaveMax : boolean     // for benefit of descendants
             read fSaveMax
             write SetSaveMax;
    procedure SetChangingMax(const Value: boolean); virtual;
    function GetStringListControlList: tStringListControlList; virtual;
    procedure SetStringListControlList(const Value: tStringListControlList); virtual;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    destructor Destroy; override;

    procedure RemoveInterest; override;
    procedure ReinstateInterest; override;

    procedure Assign( const pFrom : tSigBaseProperty; const AllowUndo : boolean ); override;

    property Children : tSigPropertyList
             read fChildren;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function Save( pTreeNodes : tTreeNodes; pTreeNode : tTreeNode ) : tTreeNode; overload; override;
{$ENDIF}
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    procedure AbortLoad( pFile : tStrings; var pLine : integer; pErrors : tErrorList = nil ); override;
    class function ClassType : string; override;
    function CreateChild( const pPropertyText : string; const pIndexText : string = '';
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; overload; virtual;
    function CreateChild( const pPropertyText : string; const pIndex : integer;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; overload; virtual;
    property Count : integer
             read GetCount;
    property SaveActiveChild : boolean
             read fSaveActiveChild
             write fSaveActiveChild;
    procedure Clear; override;
    procedure SaveOthers( pSaveFile : tStrings; pIndent : integer = 0  ); virtual; // other, non-sig properties
    property ActiveChild : integer  // used externally generally to keep track of child that is currently visible
             read GetActiveChild
             write SetActiveChildBase;
    function ChangeActiveChild( const NewVal : tSigBaseProperty ) : boolean;
    property ChangedChild : tSigBaseProperty
             read fChangedChild;

    procedure Delete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); reintroduce; virtual;
    function CanDelete( const pIndex : integer ) : boolean; virtual;
    procedure UnDelete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); virtual;
    function Remove( pObject : tObject; const pUndoAction : tSigFileUndoAction ) : integer; reintroduce; virtual;
    procedure Move( const pFrom, pTo : integer ); virtual;
    procedure Swap( const pFrom, pTo : integer ); virtual;

    procedure ListIfDirty( pStrings : tStrings; const pIndent : integer = 0 ); override;

    property OnActiveChildChange : tSigOnActiveChildChange
             read fOnActiveChildChange
             write fOnActiveChildChange;

    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    function MatchesDataOnDevice : boolean; override;

    class function ChildMustExist : boolean; virtual;

    function PrintStructureString : string ; override;

    property OnRemoveChild : tOnArrayChildAddRemove
             read fOnRemoveChild
             write fOnRemoveChild;

    property OnDelete : tOnArrayChildDeleteUndelete
             read fOnDelete
             write fOnDelete;
    property OnUnDelete : tOnArrayChildDeleteUndelete
             read fOnUnDelete
             write fOnUnDelete;
    property OnMoveChild : tOnArrayChildMove
             read fOnMoveChild
             write fOnMoveChild;
    property OnSwapChild : tOnArrayChildMove
             read fOnSwapChild
             write fOnSwapChild;

    property Entry[ const i : integer ] : tSigBaseProperty
             read GetEntry;

    function ActiveChildObjectIs( const pObject : tSigBaseProperty ) : boolean; virtual;
    property ChangingMax : boolean
             read fChangingMax
             write SetChangingMax;
    property Max : integer  // no meaning for us but has meaning for children
             read GetMax
             write SetMax;
    property OnMaxChange :   tSigOnIntegerChange
             read GetOnMaxChange
             write SetOnMaxChange;

    property StringListControlList : tStringListControlList // we do not usually Own this directly
             read GetStringListControlList
             write SetStringListControlList;
  end;

  tSigArrayProperty = class( tSigCompoundProperty )
    // a specialised entity where all properties are of same type and indexed
    // adds special array-type features...
    // always needs to be inherited from to create correct child type
    // ArrayElementCreationText should be set to the value that Load would use
    // to load in the element, eg 'Object MyObject', or 'Array MyArray'

    // DO NOT CREATE CHILDREN OF A DIFFERENT TYPE!
  private
    fOnAddChild: tOnArrayChildAddRemove;
    fClearRemovesChildren: boolean;
    function GetItem(const i: integer): tSigBaseProperty;
  protected
    procedure SetMax(const Value: integer); override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    class function ClassType : string; override;
    procedure Clear; override;
    procedure UnDelete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); override;

    procedure RedisplayStringControlList;

    function AddNewChild : tSigBaseProperty; virtual;
    function InsertNewChild( const AtLoc : integer ) : tSigBaseProperty; virtual;
    property Entry[ const i : integer ] : tSigBaseProperty
             read GetItem;
    procedure SaveOthers( pSaveFile : tStrings; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); override;
    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    property OnAddChild : tOnArrayChildAddRemove
             read fOnAddChild
             write fOnAddChild;
    procedure Reindex;
    procedure Delete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); override;
    property ClearRemovesChildren : boolean
             read fClearRemovesChildren
             write fClearRemovesChildren;

    class function ChildMustExist : boolean; override;
  end;

  tSigStringArray = class( tSigArrayProperty )
  private
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEditor: tMemo;
{$ENDIF}
    function GetStringItem(const i: integer): string;
    procedure SetStringItem(const i: integer; const Value: string);
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetEditor(const Value: tMemo);
{$ENDIF}
  protected
  public
    property Item[ const i : integer ] : string
             read GetStringItem
             write SetStringItem; default;
    function CreateChild( const pPropertyText : string; const pIndexText : string;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; override;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : tMemo
             read fEditor
             write SetEditor;
{$ENDIF}
    procedure RefreshEditor; override;
  end;

  tSigIntegerArray = class( tSigArrayProperty )
  protected
    function GetIntegerItem(const i: integer): integer;
    procedure SetIntegerItem(const i, Value: integer); virtual;
  public
    property Item[ const i : integer ] : integer
             read GetIntegerItem
             write SetIntegerItem; Default;
    //function AddNewChild : tSigBaseProperty; override;
    function CreateChild( const pPropertyText : string; const pIndexText : string;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; override;
  end;

  tSigByteArray = class( tSigIntegerArray )
  private
    function GetByteItem(const i: integer): byte;
    procedure SetByteItem(const i: integer; const Value: byte);
  public
    property Item[ const i : integer ] : byte
             read GetByteItem
             write SetByteItem; Default;
  end;

  tSigBooleanArray = class( tSigArrayProperty )
  private
    function GetBooleanItem(const i: integer): boolean;
    function GetSigBooleanItem(const i: integer): tSigBooleanProperty;
    procedure SetBooleanItem(const i: integer; const Value: boolean);
  protected
    property SigBooleanItem[ const i : integer ] : tSigBooleanProperty
             read GetSigBooleanItem;
  public
    property Item[ const i : integer ] : boolean
             read GetBooleanItem
             write SetBooleanItem; Default;
    //function AddNewChild : tSigBaseProperty; override;
    function CreateChild( const pPropertyText : string; const pIndexText : string;
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; override;
  end;

  tSigObjectArray = class( tSigCompoundProperty )
  private
    fArrayClass: tSigBasePropertyClass;
    fOnAddChild: tOnArrayChildAddRemove;
    fClearRemovesChildren: boolean;
    fOnCountChange: tSigOnIntegerChange;
    fRecSelCol: integer;
    fMultiRecSelect: boolean;
    fOnChildSelRecCell: TSelectCellEvent;
    fAllowRecCreate: boolean;
    //fOnMoveChild: tOnArrayChildMove;
    //fOnSwapChild: tOnArrayChildMove;
    //fDisallowMaxLoad: boolean;
    function GetItem(const i: integer) : tSigBaseProperty;
{$IFDEF FMX_SIGFILE}
    procedure SetSpinEdit(const Value: tSpinBox);
    procedure SetCountSpinEdit(const Value: tSpinBox);
{$ELSE}
    procedure SetSpinEdit(const Value: tSpinEdit);
    procedure SetCountSpinEdit(const Value: tSpinEdit);
    procedure SetStringListControl(const Value: TWinControl);
{$ENDIF}
  protected
{$IFDEF FMX_SIGFILE}
    fSpinEdit: tSpinBox;
    fCountSpinEdit: tSpinBox;
{$ELSE}
    fSpinEdit: tSpinEdit;
    fCountSpinEdit: tSpinEdit;
    fRecEditor: tSigGeneralGrid;
    fStringListControl: TWinControl;
    fOnRecSelCell : TSelectCellEvent;
{$ENDIF}
    fOnCountEditorChange : tNotifyEvent;
    procedure SetMax(const Value: integer); override;
    procedure fOnEditChange( Sender : tObject ); virtual;
    procedure fOnCountEditChange( Sender : tObject ); virtual;
    function AddNewChild : tSigBaseProperty; virtual;  // do not use directly!
    function InsertNewChild( const AtLoc : integer ) : tSigBaseProperty; virtual;
    procedure SetEnabled( const Value : boolean ); override;
    procedure RefreshEditor; override;
    function GetActiveChild: integer; override;
    procedure SetActiveChild(const Value: integer); override;
    procedure RecSelCell( Sender : tObject; ACol, ARow : integer; var CanSelect : boolean );
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean ) ; override;
{$IFNDEF FMX_SIGFILE}
    procedure SetRecEditor(const Value: tSigGeneralGrid); virtual;
    procedure BuildRecLine( const pLine : integer; const pRec : tSigBaseProperty ); virtual;
    procedure BuildRecCell( const pCol, pRow : integer; const pRec : tSigBaseProperty ); virtual; // pRec guaranteed to exist
    procedure RebuildRecEditor; virtual;
    procedure RedisplayStringControlList; overload;
    procedure RedisplayStringControlList( const pItem : integer); overload;
{$ENDIF}
  public
    // an array of compound objects
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty;
                pArrayClass : tSigBasePropertyClass  ); overload; virtual;
    procedure OnDestroy; override;
    class function ClassType : string; override;
    procedure Clear; override;
    property Entry[ const i : integer ] : tSigBaseProperty
             read GetItem;
    function IndexOf( pObject : tSigBaseProperty ) : integer;
    procedure UnDelete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); override;

    procedure SaveOthers( pSaveFile : tStrings; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    property ArrayClass : tSigBasePropertyClass
             read fArrayClass;
    function CreateChild( const pPropertyText : string; const pIndexText : string = '';
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0  ) : tSigBaseProperty; override;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0 ); override;
    property OnAddChild : tOnArrayChildAddRemove
             read fOnAddChild
             write fOnAddChild;
    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Delete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); overload; override;
    procedure Delete( const pIndex : integer ); reintroduce; overload;
    procedure Reindex;
    property ClearRemovesChildren : boolean
             read fClearRemovesChildren
             write fClearRemovesChildren;
    function Add( NewVal : tSigBaseProperty ) : integer;
{$IFDEF FMX_SIGFILE}
    property MaxEditor : tSpinBox
             read fSpinEdit
             write SetSpinEdit;
    property CountEditor : tSpinBox
             read fCountSpinEdit
             write SetCountSpinEdit;
{$ELSE}
    property MaxEditor : tSpinEdit
             read fSpinEdit
             write SetSpinEdit;
    property CountEditor : tSpinEdit
             read fCountSpinEdit
             write SetCountSpinEdit;
    property RecEditor : tSigGeneralGrid  // generalised partial editor.
             read fRecEditor
             write SetRecEditor;
    property RecSelCol : integer  // default = 0. Set to -1 if selection not allowed
             read fRecSelCol
             write fRecSelCol;
    property MultiRecSelect : boolean  // default false. If true allows multiple lines
             read fMultiRecSelect      // to be selected
             write fMultiRecSelect;
    property OnChildSelRecCell : TSelectCellEvent
             read fOnChildSelRecCell
             write fOnChildSelRecCell;
    property AllowRecCreate : boolean
             read fAllowRecCreate
             write fAllowRecCreate;

    property StringListControl : TWinControl
             read fStringListControl
             write SetStringListControl;

    procedure ClearRecSel;             // clears current selections
    function RecCellCount : integer;

{$ENDIF}

    property OnCountChange :   tSigOnIntegerChange
             read fOnCountChange
             write fOnCountChange;

    class function ChildMustExist : boolean; override;

    function ActiveChildObjectIs( const pObject : tSigBaseProperty ) : boolean; override;

  end;

  tSigObjectArrayHidden = class( tSigObjectArray )
    // only for use with tSigObjectList!
  protected
    procedure SetActiveChild(const Value: integer); override;
    procedure BuildRecLine( const pLine : integer; const pRec : tSigBaseProperty ); override;
    procedure BuildRecCell( const pCol, pRow : integer; const pRec : tSigBaseProperty ); override; // pRec guaranteed to exist
  end;

  tSigObjectList = class( tSigCompoundProperty )
    // comparable to tObjectList which is like an
    // array with additional members
  private
    fChildArray: tSigObjectArrayHidden;
//    fArrayClass: tSigBasePropertyClass;
    function GetItem(const i: integer): tSigBaseProperty;
    function GetArrayClass: tSigBasePropertyClass;
{$IFDEF FMX_SIGFILE}
    procedure SetCountEditor(const Value: tSpinBox);
    function GetCountEditor: tSpinBox;
    function GetMaxEditor: tSpinBox;
    procedure SetMaxEditor(const Value: tSpinBox);
{$ELSE}
    procedure SetCountEditor(const Value: tSpinEdit);
    function GetCountEditor: tSpinEdit;
    function GetMaxEditor: tSpinEdit;
    procedure SetMaxEditor(const Value: tSpinEdit);
    function GetRecEditor : tSigGeneralGrid;
    function GetAllowRecCreate: boolean;
    procedure SetAllowRecCreate(const Value: boolean);
    function GetRecSelCol: integer;
    procedure SetRecSelCol(const Value: integer);
{$ENDIF}
  protected
    function GetEntry(const i: integer): tSigBaseProperty; override;
    procedure SetEnabled( const Value : boolean ); override;
    function GetMax: integer; override;
    procedure SetMax(const Value: integer); override;
    //property ChildArray : tSigObjectArray
    //         read fChildArray;
    procedure SetSaveMax(const Value: boolean); override;
    procedure SetActiveChild(const Value: integer); override;
    procedure SetOnMaxChange(const Value: tSigOnIntegerChange); override;
    function GetOnMaxChange: tSigOnIntegerChange; override;
{$IFNDEF FMX_SIGFILE}
    procedure SetRecEditor(const Value: tSigGeneralGrid); virtual;
    procedure BuildRecLine( const pLine : integer; const pRec : tSigBaseProperty ); virtual;
    procedure BuildRecCell( const pCol, pRow : integer; const pRec : tSigBaseProperty ); virtual; // pRec guaranteed to exist
    procedure RebuildRecEditor; virtual;
    procedure RedisplayStringControlList; overload;
    procedure RedisplayStringControlList( const i : integer ); overload;
    function GetStringListControlList: tStringListControlList; override;
    procedure SetStringListControlList(const Value: tStringListControlList); override;
{$ENDIF}
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty;
                pArrayClass : tSigBasePropertyClass  ); overload; virtual;
    constructor Create( pPropertyName : string; const pIndex : string; pOwner : tSigCompoundProperty;
                pArrayClass : tSigBasePropertyClass  ); overload; virtual;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    property ArrayClass : tSigBasePropertyClass
             read GetArrayClass;
    class function ClassType : string; override;
    procedure Clear; override;
    function AddNewChild : tSigBaseProperty; virtual;
    function InsertNewChild( const AtLoc : integer ) : tSigBaseProperty; virtual;
    procedure MoveChild( const pFrom, pTo : integer );
    procedure SwapChild( const pFrom, pTo : integer );

    property Entry[ const i : integer ] : tSigBaseProperty
             read GetItem;
    procedure SaveOthers( pSaveFile : tStrings; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    procedure Delete( const pIndex : integer; const pUndoAction : tSigFileUndoAction ); overload; override;
    procedure Delete( const pIndex : integer ); reintroduce; overload;

    property ChildArray : tSigObjectArrayHidden
             read fChildArray;
    // editors

{$IFDEF FMX_SIGFILE}
    property CountEditor : tSpinBox
             read GetCountEditor
             write SetCountEditor;
    property MaxEditor : tSpinBox
             read GetMaxEditor
             write SetMaxEditor;
{$ELSE}
    property CountEditor : tSpinEdit
             read GetCountEditor
             write SetCountEditor;
    property MaxEditor : tSpinEdit
             read GetMaxEditor
             write SetMaxEditor;
    property RecEditor : tSigGeneralGrid  // generalised partial editor.
             read GetRecEditor
             write SetRecEditor;
    property RecSelCol : integer  // default = 0. Set to -1 if selection not allowed
             read GetRecSelCol
             write SetRecSelCol;
{$ENDIF}

    property AllowRecCreate : boolean
             read GetAllowRecCreate
             write SetAllowRecCreate;

  end;

  tSigObjectList<T : class > = class( tSigObjectList )
  private
    function GetTypedItem(const i: integer): T;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    property Item[ const i : integer ] : T
             read GetTypedItem;
    function AddNewChild : T; reintroduce;
  end;

  tSigArrayViewEntry = class( tSigIntegerProperty )
  private
    fObject: tSigBaseProperty;
  protected
  public
    property SigObject : tSigBaseProperty  // we neither load nor save this
             read fObject
             write fObject;
  end;

  tSigArrayView = class( tSigObjectList )
  {
    an array view is a view based on an array. It is fundamentally
    different to an array in that it does not own its objects
    and only saves the indexes of elements of the array.
    Its owner must be a tSigArrayViewList whose owner in
    turn must be the array over which the view is based or the
    object list containing the array over which the array is based
    which the view is based. The members stored are maintained by the
    tSigObjectList, which must remove dead objects.

    There can be many views based upon an object list.

  }
  private
    function GetViewEntry(const i: integer): tSigArrayViewEntry;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure AssignIndex( pObject : tSigBaseProperty; pIndex : integer );
    procedure RemoveObjectReferences( pObject : tSigBaseProperty );

    property ViewEntry[ const i : integer ] : tSigArrayViewEntry
             read GetViewEntry;
  end;

  tSigArrayViewList = class( tSigObjectList )
  private
    function GetArrayView(const i: integer): tSigArrayView;
  public

    property ArrayView[ const i : integer ] : tSigArrayView
             read GetArrayView;

    procedure AssignIndex( pObject : tSigBaseProperty; pIndex : integer );
    procedure RemoveObjectReferences( pObject : tSigBaseProperty );

  end;

  tSigObjectListWithViews = class( tSigObjectList )
  private
    fViews: tSigArrayViewList;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty;
                pArrayClass : tSigBasePropertyClass  ); override;

    property Views : tSigArrayViewList
             read fViews;
  end;

  tSigRelativeFileProperty = class( tSigSimpleProperty ) // file name relative to parent file name
  private
    // Value is in absolute form so that Save As moves with file, keeping same value
    // but Saved as relative form (relative to the name of the owning file)
  protected
  public
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
  end;

  tSigRelativeFilePropertyList = class( tSigObjectList )
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
  end;

  tSigEnumMap = class( tSigCompoundProperty )
  private
    fEnum: tSigIntegerProperty;
    fEnumName: tSigTextProperty;
    fVisible: tSigBooleanProperty;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure Clear; override;
    property Enum : tSigIntegerProperty
             read fEnum;
    property EnumName : tSigTextProperty
             read fEnumName;
    property Visible : tSigBooleanProperty
             read fVisible;
  end;

  tSigEnumMapList = class( tSigObjectList )
  private
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEditor: tStringGrid;
    fImageListCheckBox: tImageList;
    fOnDrawCell : tDrawCellEvent;
    fOnSelectCell : tSelectCellEvent;
    fOnSetEditText : tSetEditEvent;
    fOnGetEditText : tGetEditEvent;
{$ENDIF}
    fVisibleColHeader: tSigTextProperty;
    fIDColHeader: tSigTextProperty;
    fNameColHeader: tSigTextProperty;
    procedure fOnChildChange( const pChangedObject : tSigBaseProperty );
    function GetMap(const i: integer): tSigEnumMap;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetEditor(const Value: tStringGrid);
    procedure SetImageListCheckBox(const Value: tImageList);
    procedure DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure SetEditText(Sender: TObject; ACol, ARow: Integer; const pValue: string);
    procedure OnGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
{$ENDIF}
  protected
    procedure selfOnMaxChange( const NewVal : integer ); virtual;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty;
                pArrayClass : tSigBasePropertyClass  ); override;
    procedure Clear; override;
    procedure RefreshEditor( const ForceRedraw : boolean ); overload;
    procedure RefreshEditor; overload; override;

    procedure BuildVisibleStrings( const pStrings : tStrings ); overload;
    function BuildVisibleStrings( const pStrings : tStrings; const MatchString : string ) : integer; overload;

    function MapWithText( const pText : string ) : tSigEnumMap;
    function MapWithValue( const pValue : integer ) : tSigEnumMap;

{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetupEditor;
{$ENDIF}
    procedure Sort; virtual; // sorts by ID

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;

{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : tStringGrid
             read fEditor
             write SetEditor;
    property ImageListCheckBox : tImageList
             read fImageListCheckBox
             write SetImageListCheckBox;

{$ENDIF}

    property VisibleColHeader : tSigTextProperty
             read fVisibleColHeader;
    property IDColHeader : tSigTextProperty
             read fIDColHeader;
    property NameColHeader : tSigTextProperty
             read fNameColHeader;
    property Map[ const i : integer ] : tSigEnumMap
             read GetMap;

  const
    cVisibleCol = 0;
    cIDCol      = 1;
    cNameCol    = 2;
  end;

  tSigMappedObject = class( tSigCompoundProperty )
    // like a mapped enum, but with child data
  private
    fMap : tSigEnumMapList;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEditor: tSelectableEdit;
    fEditorShowsHidden : boolean;
{$ENDIF}
    fChainedOnMapListChange : tSigOnChange;
    fOnChange : tNotifyEvent;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function GetEditor: TWinControl;
    function GetHiddenEditor: TWinControl;
    procedure SetEditor(const Value: TWinControl);
    procedure SetHiddenEditor(const Value: TWinControl);
{$ENDIF}
    function GetVisibleMap: boolean;
  protected
    procedure EditorChange(Sender: TObject);
    function GetValueAsInt: integer; virtual;
    procedure SetValueAsInt(const pValue: integer); virtual;
    function ValueToText( pValue : integer ) : string; virtual;
    procedure SetEnabled( const Value : boolean ); override;
    procedure OnMapListChange( const pChangedObject : tSigBaseProperty );
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty; pMap : tSigEnumMapList ); reintroduce; virtual;

    property ValueAsInt : integer
             read GetValueAsInt
             write SetValueAsInt;

{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : TWinControl
             read GetEditor
             write SetEditor;
    property HiddenEditor : TWinControl
             read GetHiddenEditor
             write SetHiddenEditor;
{$ENDIF}
    function MapItemToValue( Item : integer ) : integer; virtual;
    function MapValueToItem( pValue : integer ) : integer; virtual;
    procedure RefreshEditor; override;
    property VisibleMap : boolean  // visible if its mapped value is visible
             read GetVisibleMap;
  end;

  tSigMappedEnum = class( tSigBaseEnumProperty )
  private
    fMap : tSigEnumMapList;
    fChainedOnMapListChange : tSigOnChange;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fEditorShowsHidden : boolean;
    fEditor: tSelectableEdit;
    fOnChange : tNotifyEvent;
    procedure SetEditor(const Value: TWinControl);
    function GetEditor: TWinControl;
    function GetHiddenEditor: TWinControl;
    procedure SetHiddenEditor(const Value: TWinControl);
{$ENDIF}
    function GetVisibleMap: boolean;
  protected
    procedure EditorChange(Sender: TObject);
    procedure OnMapListChange( const pChangedObject : tSigBaseProperty );
    function GetValueAsInt: integer; override;
    function ValueToText( pValue : integer ) : string; override;
    function GetMinVal: integer; override;
    function GetMaxVal: integer; override;
    procedure SetEnabled( const Value : boolean ); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty; pMap : tSigEnumMapList ); reintroduce; virtual;
    procedure Clear; override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;

{$IFDEF FMX_SIGFILE}
{$ELSE}
    property Editor : TWinControl
             read GetEditor
             write SetEditor;
    property HiddenEditor : TWinControl
             read GetHiddenEditor
             write SetHiddenEditor;
{$ENDIF}
    function MapItemToValue( Item : integer ) : integer; override;
    function MapValueToItem( pValue : integer ) : integer; override;
    procedure RefreshEditor; override;
    property VisibleMap : boolean  // visible if its mapped value is visible
             read GetVisibleMap;
  end;

  tMemoProperty = class( tSigBaseProperty )
    // a specialised class to store multiline texts
  private
    function GetStrings(const i: integer): string;
    procedure SetStrings(const i: integer; const pValue: string);
    function GetLines: TStrings;
    procedure SetEdit(const Value: tMemo);
    procedure fOnEditChange( Sender : tObject );
  protected
    fStrings: tStringList;
    fEdit: tMemo;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    destructor Destroy; override;
    procedure OnDestroy; override;
//    property Strings : tStringList
//             read fstrings;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    procedure CopyToClipboard( pClipboard : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    function PasteFromClipboard( pClipboard : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    class function ClassType : string; override;
    procedure Clear; override;
    property Strings[ const i : integer ] : string
             read GetStrings
             write SetStrings; default;
    function Add( const pValue : string ) : integer;
    property Lines : TStrings
             read GetLines;
    procedure AssignFrom( pFrom : TStrings );
    procedure AssignTo( pTo : TStrings );
    procedure AddTo( pTo : TStrings );
    procedure Undo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    procedure Redo( const pUndoAction : tSigFileUndoAction; const pUndoString : string ); override;
    property Editor : tMemo
             read fEdit
             write SetEdit;
    function PrintStructureString : string ; override;
  end;

  tHijackSave = function( const pFileName : string; var pIncludeInHistory : boolean ) : boolean of object; // returns true if hijacked
  tHijackLoad = function( const pFileName : string; var pIncludeInHistory : boolean ) : boolean of object; // returns true if hijacked

  tSigFileProperty = class( tSigCompoundProperty )
  private
    fFileName: string;
    fOnSave : TOnSave;
    fOnLoad : TOnLoad;
    fOnNew: tNotifyEvent;
    fSigSaveDialog: TSigSaveDialog;
    fSource: tStrings;
    fErrorList: tErrorList;
    fShortFormat: boolean;
    fEdit : tForm;
    fBaseCaption: string;
    fFormSaveCanClose : tCloseQueryEvent;
    fSaveFormStateOnExit: boolean;
    fMainMenu: tMainMenu;
    fFileMenu : tMenuItem;
    fFileNew : tMenuItem;
    fFileLoad : tMenuItem;
    fFileSave : tMenuItem;
    fFileSaveAs : tMenuItem;
    fFileSaveAsTemplate : tMenuItem;
    fFilePrint : tMenuItem;
    fFilePrintPreview : tMenuItem;
    fFilePrinterSetup : tMenuItem;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fFileLine0 : tMenuItem;
    fFileLine1 : tMenuItem;
    fFileLine2 : tMenuItem;
{$ENDIF}
    fFileExit : tMenuItem;
    fFileHistory : array[ 0..9 ] of tMenuItem;
    fEditMenu : tMenuItem;
    fEditUndo : tMenuItem;
    fEditRedo : tMenuItem;
    fDeviceMenu : tMenuItem;
    fDeviceCompare : tMenuItem;
    fDeviceLoad : tMenuItem;
    fDeviceSave : tMenuItem;
    fHelpMenu : tMenuItem;
    fHelpContents : tMenuItem;
    fHelpContext : tMenuItem;
    fHelpContextID : integer;
    fHelpAbout : tMenuItem;
    fAboutForm: tForm;
    fOnUndoClick: tNotifyEvent;
    fOnRedoClick: tNotifyEvent;
    FOnCompareDevice: tNotifyEvent;
    FOnSaveToDevice: tNotifyEvent;
    FOnLoadFromDevice: tNotifyEvent;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fUndoRedoImageList: tImageList;
{$ENDIF}
    FUndoEnabled: boolean;
    FRedoEnabled: boolean;
    fContextHelpCaption: string;
    FOnPrinterSetup: tNotifyEvent;
    FOnPrint: tNotifyEvent;
    FOnPrintPreview: tNotifyEvent;
    fUsesEditMenu: boolean;
    fUsesUndoRedoMenu: boolean;
    fAfterLoadList : tObjectList;
    fDevLoadingCount : integer;
    fTemplateIndex: integer;
    fFileLoadFromTemplate: tMenuItem;
    fDefaultExtension: string;
    fTemplateExtension: string;
    fIsTemplate: boolean;
    fOnClearErrorList: tNotifyEvent;
    fTemplateFile: string;
    //fFirstTime : boolean;
    fHijackLoad: tHijackLoad;
    fHijackSave: tHijackSave;
    procedure fFileNewClick( Sender : tObject );
    procedure fFileLoadClick( Sender : tObject );
    procedure fFileLoadFromTemplateClick( Sender : tObject );
    procedure fFileSaveClick( Sender : tObject );
    procedure fFileSaveAsClick( Sender : tObject );
    procedure fFileSaveAsTemplateClick( Sender : tObject );
    procedure fFilePrintClick( Sender : tObject );
    procedure fFilePrintPreviewClick( Sender : tObject );
    procedure fFilePrinterSetupClick( Sender : tObject );
    procedure fFileExitClick( Sender : tObject );
    procedure fFileOnHistoryClick( Sender : tObject );
    procedure fEditUndoClick( Sender : tObject );
    procedure fEditRedoClick( Sender : tObject );
    procedure fDeviceCompareClick( Sender : tObject );
    procedure fDeviceLoadFromClick( Sender : tObject );
    procedure fDeviceSaveToClick( Sender : tObject );
    procedure fHelpContentsClick( Sender : tObject );
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure fHelpContextClick( Sender : tObject );
{$ENDIF}
    procedure fHelpAboutClick( Sender : tObject );
    procedure SigSaveDialogSave(Sender: tObject; var pOK: Boolean; const pFileName : string );
    procedure SetSigSaveDialog(const Value: TSigSaveDialog);
    procedure SetEdit(const Value: tForm);
    procedure fFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SetMainMenu(const Value: tMainMenu);
    function GetOnFileNewClick: tNotifyEvent;
    function GetOnFileLoadClick: tNotifyEvent;
    function GetOnFileSaveClick: tNotifyEvent;
    function GetOnFileSaveAsClick: tNotifyEvent;
    function GetOnFileExitClick: tNotifyEvent;
    function GetOnFileOnHistoryClick: tNotifyEvent;
    function GetOnEditUndoClick: tNotifyEvent;
    function GetOnEditRedoClick: tNotifyEvent;
    function GetOnHelpContentsClick: tNotifyEvent;
    function GetOnHelpAboutClick: tNotifyEvent;
    procedure SetOnCompareDevice(const Value: tNotifyEvent);
    procedure SetOnLoadFromDevice(const Value: tNotifyEvent);
    procedure SetOnSaveToDevice(const Value: tNotifyEvent);
    procedure SetAboutForm(const Value: tForm);
{$IFDEF FMX_SIGFILE}
{$ELSE}
    procedure SetUndoRedoImageList(const Value: tImageList);
{$ENDIF}
    procedure SetUndoEnabled(const Value: boolean);
    procedure SetRedoEnabled(const Value: boolean);
    procedure SetContextHelpCaption(const Value: string);
    procedure SetOnPrint(const Value: tNotifyEvent);
    procedure SetOnPrinterSetup(const Value: tNotifyEvent);
    procedure SetOnPrintPreview(const Value: tNotifyEvent);
    function GetMenuItemFileHistory(const i: integer): tMenuItem;
    function GetUsesUndoRedoMenu: boolean;
    procedure InsertFileMenu;
    procedure InsertEditMenu;
    procedure InsertDeviceMenu;
    procedure AddHelpMenu;
    procedure BuildFileMenuEntries( const pFileMenu : tMenuItem );
    procedure BuildEditMenuEntries( const pEditMenu : tMenuItem );
    procedure BuildHelpMenuEntries( const pHelpMenu : tMenuItem );
    procedure BuildDeviceMenuEntries( const pDeviceMenu : tMenuItem );
    procedure SetupPrinterMenu;
    procedure SetupHistory( Sender : tObject );
    procedure SetupHelp;
    procedure SetupEditMenu;
    procedure SetupDeviceMenu;
    function GetIsTemplate: boolean;
    function GetErrorList: tErrorList;
  protected
    procedure SigSaveDialogLoad(Sender: tObject; var pOK: Boolean; const pFileName : string ); virtual;
    procedure SetIsDirty(const Value: boolean); override;
    procedure SetCaption; virtual;
    function GetLoadingFromDevice: tSigLoadAction; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    destructor Destroy; override;
    procedure Clear; override;

    procedure ClearErrorList; virtual;
    procedure AddError( const pRow, pCol :integer; const pErrorText : string; pObject : tObject = nil ); overload; virtual;
    procedure AddError( const pSeverity : tErrorSeverity; const pRow, pCol :integer; const pErrorText : string; pObject : tObject = nil ); overload; virtual;

    function Load( const pFileName : string = ''; const pIndex : integer = 1) : boolean; reintroduce; virtual;
    function LoadFromTemplate( const pFileName : string = '') : boolean; virtual;
    function NewInternal : boolean;
    function New : boolean;
    function Save( pShortFormat : boolean = FALSE) : boolean; reintroduce; overload; virtual;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    function Save( pTreeNodes : tTreeNodes ) : tTreeNode; reintroduce; overload;
{$ENDIF}

    function SaveAs( const pFileName : string = ''; pShortFormat : boolean = FALSE) : boolean; virtual;
    function SaveAsTemplate( const pFileName : string = ''; pShortFormat : boolean = FALSE) : boolean;
    function SaveIfDirty( pShortFormat : boolean = FALSE) : boolean;

    procedure RegisterAfterLoadEntry( const pObject : tSigBaseProperty );
    procedure UnRegisterAfterLoadEntry( const pObject : tSigBaseProperty );

    property OnClearErrorList : tNotifyEvent
             read fOnClearErrorList
             write fOnClearErrorList;

    property OnNew : tNotifyEvent
             read fOnNew
             write fOnNew;

    property HijackLoad : tHijackLoad
             read fHijackLoad
             write fHijackLoad;
    property HijackSave : tHijackSave
             read fHijackSave
             write fHijackSave;
    property AboutForm : tForm
             read fAboutForm
             write SetAboutForm;
    property BaseCaption : string
             read fBaseCaption
             write fBaseCaption;
    property ContextHelpCaption : string
             read fContextHelpCaption
             write SetContextHelpCaption;
    property Editor : tForm
             read fEdit
             write SetEdit;
    property ErrorList : tErrorList
             read GetErrorList;
    property FileName : string
             read fFileName;
    property HelpContextID : integer
             read fHelpContextID
             write fHelpContextID;
    property MainMenu : tMainMenu
             read fMainMenu
             write SetMainMenu;
    property MenuItemFileNew : tMenuItem
             read fFileNew;
    property MenuItemFileLoad : tMenuItem
             read fFileLoad;
    property MenuItemFileLoadFromTemplate : tMenuItem
             read fFileLoadFromTemplate;
    property MenuItemFileHistory[ const i : integer ] : tMenuItem
             read GetMenuItemFileHistory;
    property OnCompareDevice : tNotifyEvent
             read FOnCompareDevice
             write SetOnCompareDevice;
    property OnEditRedoClick : tNotifyEvent
             read GetOnEditRedoClick;
    property OnEditUndoClick : tNotifyEvent
             read GetOnEditUndoClick;
    property OnFileExitClick : tNotifyEvent
             read GetOnFileExitClick;
    property OnFileLoadClick : tNotifyEvent
             read GetOnFileLoadClick;
    property OnFileNewClick : tNotifyEvent
             read GetOnFileNewClick;
    property OnFileOnHistoryClick : tNotifyEvent
             read GetOnFileOnHistoryClick;
    property OnFileSaveClick : tNotifyEvent
             read GetOnFileSaveClick;
    property OnFileSaveAsClick : tNotifyEvent
             read GetOnFileSaveAsClick;
    property OnHelpAboutClick : tNotifyEvent
             read GetOnHelpAboutClick;
    property OnHelpContentsClick : tNotifyEvent
             read GetOnHelpContentsClick;
    property OnLoad : tOnLoad
             read fOnLoad
             write fOnLoad;
    property OnLoadFromDevice : tNotifyEvent
             read FOnLoadFromDevice
             write SetOnLoadFromDevice;
    property OnPrint : tNotifyEvent
             read FOnPrint
             write SetOnPrint;
    property OnPrintPreview : tNotifyEvent
             read FOnPrintPreview
             write SetOnPrintPreview;
    property OnPrinterSetup : tNotifyEvent
             read FOnPrinterSetup
             write SetOnPrinterSetup;
    property OnRedoClick : tNotifyEvent
             read fOnRedoClick
             write fOnRedoClick;
    property OnSaveToDevice : tNotifyEvent
             read FOnSaveToDevice
             write SetOnSaveToDevice;
    property OnUndoClick : tNotifyEvent
             read fOnUndoClick
             write fOnUndoClick;
    property RedoEnabled : boolean
             read FRedoEnabled
             write SetRedoEnabled;
    property SaveFormStateOnExit : boolean // has no effect unless Editor, SigSaveDialog and SigSaveDialog.SigRegistry exist
             read fSaveFormStateOnExit
             write fSaveFormStateOnExit;
    property SaveDialog : TSigSaveDialog
             read fSigSaveDialog
             write SetSigSaveDialog;
    property ShortFormat : boolean
             read fShortFormat
             write fShortFormat;
    property Source : tStrings  // set this to make source file visible
             read fSource
             write fSource;
    property UndoEnabled : boolean
             read FUndoEnabled
             write SetUndoEnabled;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    property UndoRedoImageList : tImageList
             read fUndoRedoImageList
             write SetUndoRedoImageList;
{$ENDIF}
    property UsesEditMenu : boolean
             read fUsesEditMenu
             write fUsesEditMenu;
    property UsesUndoRedoMenu : boolean
             read GetUsesUndoRedoMenu
             write fUsesUndoRedoMenu;
    property TemplateIndex : integer  // zero implies templates not used
             read fTemplateIndex
             write fTemplateIndex;
    property DefaultExtension : string
             read fDefaultExtension
             write fDefaultExtension;
    property TemplateExtension : string
             read fTemplateExtension
             write fTemplateExtension;
    property IsTemplate : boolean
             read GetIsTemplate;

    property TemplateFile : string  // if not blank this is loaded whenever New is requested externally
             read fTemplateFile     // or File|New requested internally. To load a truly blank file
             write fTemplateFile;   // this must be blank or NewInternal called instead
                                    // This is not directly related to template options above. i.e.
                                    // setting them up so templates are not used does NOT invalidate
                                    // this property.

    function Translate( const pVal : string ) : string; override;

    class function ClassType : string; override;

    procedure ExecuteAfterLoadActions;

    procedure CheckErrors( var pErrorCount, pWarningCount, pHintCount : integer; pErrors : tErrorList ); override;

    procedure IncDevLoadingCount;
    procedure DecDevLoadingCount;
  end;

  tSigCfgFile = class( tSigFileProperty )
    // this is just like a SigFile, but automatically loads itself from a file with the same name and
    // in the same directory as the application, but with the extension cfg
    private
    public
      constructor Create; reintroduce; virtual;
      function Load( const pFileName : string = ''; const pIndex : integer = 1) : boolean; override;
  end;

var
  NO_CHILD_MUST_EXIST : boolean;

implementation

{ tSigBaseProperty }

constructor tSigBaseProperty.Create(pPropertyName: string; pOwner : tSigCompoundProperty );
begin
  inherited Create;
  Creating := TRUE;
  fPropertyName := Trim( pPropertyName );
  fIndexed := FALSE;
  fOwner := pOwner;
  if assigned( fOwner ) then
  begin
    fOwner.Children.Add( self, undoAdd );
  end;
  SaveWithFile := TRUE;
  fEnabled := TRUE;
  fInterestedParties := tSigBasePropertyList.Create( FALSE ); // not used for much
  //fInterestedParties.OwnsObjects := FALSE; // !!!
  fLoadable := TRUE;
  fUpdateOnEditorChange := TRUE; // default to existing way
end;

procedure tSigBaseProperty.AbortLoad(pFile: tStrings; var pLine: integer;
  pErrors: tErrorList);
begin
  // do nothing
end;

procedure tSigBaseProperty.AfterConstruction;
begin
  inherited;
  Clear;
  IsDirty := SaveWithFile;
  Creating := FALSE;
end;

procedure tSigBaseProperty.AfterLoad;
begin
  // by default does nothing
end;

procedure tSigBaseProperty.Assign(const pFrom: tSigBaseProperty;
  const AllowUndo: boolean);
begin
  if AllowUndo then
  begin
    Value := pFrom.Value;
  end
  else
  begin
    fValue := pFrom.Value;
  end;
end;

function tSigBaseProperty.CanDestroy: boolean;
var
  i : integer;
begin
  Result := TRUE;
  for i := 0 to fInterestedParties.Count - 1 do
  begin
    if assigned( fInterestedParties.Item[ i ] ) then
    begin
      if not fInterestedParties.Item[ i ].OnInterestedPartyCanDestroy( self ) then
      begin
        Result := FALSE;
      end;
    end;
  end;

end;

procedure tSigBaseProperty.CheckErrors(var pErrorCount, pWarningCount, pHintCount: integer;
  pErrors: tErrorList);
begin
  // no errors or warnings.
end;

procedure tSigBaseProperty.Clear;
begin
    Value := '';
end;

procedure tSigBaseProperty.CompleteRedoing;
begin
  // nothing to do
end;

procedure tSigBaseProperty.CompleteUndoing;
begin
  // nothing to do
end;

procedure tSigBaseProperty.CopyToClipBoard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
begin

end;

constructor tSigBaseProperty.Create(pPropertyName, pIndex: string; pOwner : tSigCompoundProperty );
begin
  Create( pPropertyName, pOwner );
  fIndex := pindex;
  findexed := TRUE;
end;

destructor tSigBaseProperty.Destroy;
begin
  fDestroying := TRUE;
  // notify interested parties of my imminent destruction
  OnDestroy;
  inherited;
end;

procedure tSigBaseProperty.DoAfterLoad;
begin
  fExecutingAfterLoad := TRUE;
  try
    AfterLoad;
  finally
    fExecutingAfterLoad := FALSE;
  end;
end;

procedure tSigBaseProperty.EndLoadingFromDevice;
begin
  OwnerFile.DecDevLoadingCount;
end;

function tSigBaseProperty.Errors(pErrorList: tErrorList): boolean;
begin
  Result := FALSE;
end;

procedure tSigBaseProperty.ExecuteCompleteUndoableAction(
  const pChangedObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if assigned( fOnCompleteUndoableAction ) then
  begin
    fOnCompleteUndoableAction( pChangedObject, pUndoAction, pUndoString );
  end;
  if assigned (Owner) then
  begin
    Owner.ExecuteCompleteUndoableAction( pChangedObject, pUndoAction, pUndoString );
  end;
end;

procedure tSigBaseProperty.ExecuteOnChange( const pChangedObject : tSigBaseProperty; const pUndoing, pRedoing : boolean );
begin
  if pUndoing then
  begin
    AmUndoing := TRUE;
  end;
  if pRedoing then
  begin
    AmRedoing := TRUE;
  end;
  try
    if assigned( fSigOnChange ) then
    begin
      fSigOnChange( pChangedObject );
    end;
    if assigned (Owner) then
    begin
      Owner.ExecuteOnChange( pChangedObject, pUndoing, pRedoing );
    end;
    //RefreshEditor;

  finally
    if pUndoing then
    begin
      AmUndoing := FALSE;
    end;
    if pRedoing then
    begin
      AmRedoing := FALSE;
    end;
  end;
end;

procedure tSigBaseProperty.ExecutePrepareUndoableAction(
  const pChangedObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if assigned( fOnPrepareUndoableAction ) then
  begin
    fOnPrepareUndoableAction( pChangedObject, pUndoAction, pUndoString );
  end;
  if assigned (Owner) then
  begin
    Owner.ExecutePrepareUndoableAction( pChangedObject, pUndoAction, pUndoString );
  end;
end;

procedure tSigBaseProperty.ExecuteRedoableAction(
  const pChangedObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if assigned( fOnRedoableAction ) then
  begin
    fOnRedoableAction( pChangedObject, pUndoAction, pUndoString );
  end
  else if assigned( Owner ) then
  begin
    Owner.ExecuteRedoableAction( pChangedObject, pUndoAction, pUndoString );
  end;
end;

procedure tSigBaseProperty.ExecuteUndoableAction(
  const pChangedObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if not LoadingFromFile then
  begin
    if assigned( fOnUndoableAction ) then
    begin
      fOnUndoableAction( pChangedObject, pUndoAction, pUndoString );
    end
    else if assigned( Owner ) then
    begin
      Owner.ExecuteUndoableAction( pChangedObject, pUndoAction, pUndoString );
    end;
  end;
end;

function tSigBaseProperty.GetCreating: boolean;
begin
  Result := fCreating;
  if not( Result ) then
  begin
    if assigned( fOwner ) then
    begin
      Result := fOwner.Creating;
    end;
  end;
end;

function tSigBaseProperty.GetDataToSend: string;
begin
  Result := ''; // by default does nothing
end;

function tSigBaseProperty.GetExecutingAfterLoad: boolean;
begin
  Result := fExecutingAfterLoad;
  if assigned( Owner ) and not Result then
  begin
    Result := Owner.ExecutingAfterLoad;
  end;
end;

function tSigBaseProperty.GetLoadingFromDevice: tSigLoadAction;
begin
  if assigned (Owner ) then
  begin
    Result := Owner.LoadingFromDevice;
  end
  else
  begin
    Result := fLoadingFromDevice;
  end;
end;

function tSigBaseProperty.GetLoadingFromFile: boolean;
begin
  if assigned (Owner ) then
  begin
    Result := Owner.LoadingFromFile;
  end
  else
  begin
    Result := fLoadingFromFile;
  end;
end;

function tSigBaseProperty.GetLoadingFromTemplate: boolean;
begin
  if assigned (Owner ) then
  begin
    Result := Owner.LoadingFromTemplate;
  end
  else
  begin
    Result := fLoadingFromTemplate;
  end;
end;

function tSigBaseProperty.GetOwnerFile: tSigFileProperty;
var
  iOwner : tSigCompoundProperty;
begin
  if self is tSigFileProperty then
  begin
    Result := self as tSigFileProperty;
    exit;
  end;
  iOwner := Owner;
  while assigned( iOwner ) do
  begin
    if iOwner is tSigFileProperty then
    begin
      Result := iOwner as tSigFileProperty;
      exit;
    end
    else
    begin
      iOwner := iOwner.Owner;
    end;
  end;
  // if we get here we have failed
  Result := nil;
end;

function tSigBaseProperty.GetOwnerOfType(
  pType: tSigBasePropertyClass): tSigCompoundProperty;
begin
  Result := Owner;
  while assigned( Result ) do
  begin
    if Result is pType then
    begin
      exit;
    end;
    // else
    Result := Result.Owner;
  end;
end;

function tSigBaseProperty.GetRedoing: boolean;
begin
  if assigned( fOwner ) then
  begin
    Result := fOwner.GetRedoing;
  end
  else
  begin
    Result := fRedoing > 0;
  end;
end;

function tSigBaseProperty.GetReqData: string;
begin
  Result := '';
end;

function tSigBaseProperty.GetSentToDevice: boolean;
begin
  Result := fValue = fValueOnDevice;
end;

function tSigBaseProperty.GetStringListText: string;
begin
  Result := Value;
end;

function tSigBaseProperty.GetUndoing: boolean;
begin
  if assigned( fOwner ) then
  begin
    Result := fOwner.GetUndoing;
  end
  else
  begin
    Result := fUndoing > 0;
  end;
end;

function tSigBaseProperty.GetValue: string;
begin
  Result := fValue;
end;

function tSigBaseProperty.GetVisible: boolean;
begin
  if assigned( fOnGetVisible ) then
  begin
    Result := fOnGetVisible( self );
  end
  else
  begin
    if assigned( Owner ) then
    begin
      Result := fVisible;
      if not Owner.Visible then
      begin
        Result := FALSE;
      end;
    end
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function tSigBaseProperty.IamActiveChild: boolean;
begin
  if assigned( Owner ) then
  begin
    Result := Owner.ActiveChildObjectIs( self );
  end
  else
  begin
    Result := FALSE;
  end;
end;

function tSigBaseProperty.IsMe(pName, pIndex: string): boolean;
begin
  Result := FALSE;
  if Indexed then
  begin
    if not SameText( fIndex, pIndex) then
    begin
      exit;
    end;
  end
  else
  begin
    if pIndex <> '' then
    begin
      exit;
    end;
  end;
  if SameText( fPropertyName, pName) then
  begin
    // alternate form to load for example, igy files.
    Result := TRUE;
  end
  else if SameText( pName, ClassType + ' ' + fPropertyName ) then
  begin
    Result := TRUE;
  end;

end;

procedure tSigBaseProperty.ListIfDirty(pStrings: tStrings;
  const pIndent: integer);
begin
  if IsDirty then
  begin
    pStrings.Add( StringOfChar(' ', pIndent) + PropertyName + '(' + Index + ') = ' + Value + ' // ' + ClassName );
    // debugging tool - no need to be too fancy
  end;
end;

function tSigBaseProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
begin
  Result := TRUE;
  LoadLine( pLine, pFile.Count );
  if not pAllowUndo then
  begin
    if assigned( Owner ) then
    begin
      Owner.Children.ClearUndoList;
    end;
  end;
  IsDirty := pIsDirty;
end;

procedure tSigBaseProperty.LoadLine(const pLine, pLineCount: integer);
begin
  if assigned( fOnLoadLine ) then
  begin
    fOnLoadLine( pLine, pLineCount );
  end
  else if assigned( Owner ) then
  begin
    Owner.LoadLine( pLine, pLineCount );
  end;
end;

function tSigBaseProperty.MatchesDataOnDevice: boolean;
begin
  case ValueOnDeviceChecked of
    vod_SameAsEnabled:
    begin
      if Enabled then
      begin
        result := fValue = fValueOnDevice;
      end
      else
      begin
        Result := TRUE;
      end;
    end;
    vod_FALSE:
    begin
      Result := TRUE;
    end;
    vod_TRUE:
    begin
      result := fValue = fValueOnDevice;
    end;
    else
    begin
      Result := fValue = fValueOnDevice;
    end;
  end;
end;

procedure tSigBaseProperty.Notify(const Sender: tSigBaseProperty);
begin
  if assigned( fOnNotify ) then
  begin
    fOnNotify( Sender );
  end
  else if assigned( fOwner ) then
  begin
    fOwner.Notify( Sender );
  end;
end;

function tSigBaseProperty.ObjectAffectsStringListText(
  const pChangedObject: tSigBaseProperty): boolean;
begin
  Result := pChangedObject = Self;
end;

procedure tSigBaseProperty.OnCompleteRedo;
begin
  if assigned( fOwner ) then
  begin
    fOwner.OnCompleteRedo;
  end;
end;

procedure tSigBaseProperty.OnCompleteUndo;
begin
  if assigned( fOwner ) then
  begin
    fOwner.OnCompleteUndo;
  end;
end;

procedure tSigBaseProperty.OnDestroy;
begin
  RemoveInterest;
end;

function tSigBaseProperty.OnInterestedPartyCanDestroy(
  const pParty: tSigBaseProperty): boolean;
begin
  Result := TRUE; // we are not really bothered...
end;

procedure tSigBaseProperty.OnInterestedPartyDestroy(
  const pParty: tSigBaseProperty);
begin
  // interested in nobody else!
end;

procedure tSigBaseProperty.OnInterestedPartyReinstate(
  const pParty: tSigBaseProperty);
begin
  //
end;

procedure tSigBaseProperty.OnRedo(const pObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  if assigned( fOwner ) then
  begin
    fOwner.OnRedo( pObject, pUndoAction, pUndoString );
  end;
end;

procedure tSigBaseProperty.OnUnDestroy;
begin
  ReinstateInterest;
end;

procedure tSigBaseProperty.OnUndo(const pObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  if assigned( fOwner ) then
  begin
    fOwner.OnUndo( pObject, pUndoAction, pUndoString );
  end;
end;

function tSigBaseProperty.PastefromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
begin
  Result := TRUE;
  IsDirty := FALSE;
end;

procedure tSigBaseProperty.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  case pUndoAction of
    undoValue:
    begin
      Value := pUndoString;
      OnRedo( self, pUndoAction, pUndoString );
    end;
  end;
end;

procedure tSigBaseProperty.RefreshEditor;
begin
  if assigned( fLabel ) then
  begin
    fLabel.Enabled := self.Enabled;
  end;
end;

procedure tSigBaseProperty.RegisterInterest(pSigObject: tSigBaseProperty);
var
  iIndex : integer;
begin
  iIndex := fInterestedParties.IndexOfItem( pSigObject, TList.TDirection.FromBeginning );
  if iIndex = -1 then
  begin
    fInterestedParties.Add( pSigObject );
  end;
end;

procedure tSigBaseProperty.ReinstateEditors;
begin
  // nothing to do here
end;

procedure tSigBaseProperty.ReinstateInterest;
var
  i : integer;
begin
  try
    for i := 0 to fInterestedParties.Count - 1 do
    begin
      fInterestedParties.Item[ i ].OnInterestedPartyReinstate( self );
    end;
    ReinstateEditors;
  except
    // editors may already have been destroyed
  end;
end;

procedure tSigBaseProperty.RemoveEditors;
begin
  // nothing to do here
end;

procedure tSigBaseProperty.RemoveInterest;
var
  i : integer;
begin
  // Remove ourselves from any pending transactions
  OwnerFile.UnRegisterAfterLoadEntry( self );
  try
    for i := fInterestedParties.Count - 1 downto 0 do
    begin
      if assigned( fInterestedParties.Item[ i ] ) then
      begin
        fInterestedParties.Item[ i ].OnInterestedPartyDestroy( self );
      end;
    end;
    RemoveEditors;
  except
    // editors may already have been destroyed
  end;
end;

procedure tSigBaseProperty.Save(pSaveFile: tStrings; pShortFormat : boolean; pIndent: integer);
begin
  IsDirty := FALSE;
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigBaseProperty.Save(pTreeNodes: tTreeNodes; pTreeNode: tTreeNode) : tTreeNode;
begin
  // no specific save
  Result := nil;
end;
{$ENDIF}

procedure tSigBaseProperty.SetData(const Value: tObject);
begin
  fData := Value;
end;

procedure tSigBaseProperty.SetDataToSend(const Value: string);
begin
  // by default does nothing
end;

procedure tSigBaseProperty.SetEnabled(const Value: boolean);
begin
  fEnabled := Value;
  RefreshEditor;
end;

procedure tSigBaseProperty.SetIndex(const pValue: string);
begin
  fIndex := pValue;
  fIndexed := pValue <> '';
end;

procedure tSigBaseProperty.SetIsDirty(const Value: boolean);
begin
  if fIsDirty <> Value then
  begin
    if Value and not SaveWithFile then
    begin
      exit; // cannot make a non saveable item dirty, or indeed its parents via itself or its children
    end;
    fIsDirty := Value;
    if Value then
    begin
      if assigned( Owner ) then
      begin
        Owner.IsDirty := Value;
      end;
    end;
    if assigned( fOnDirtyChange) then
    begin
      fOnDirtyChange( self, Value );
    end;
  end;
end;

procedure tSigBaseProperty.SetLabel(const Value: tLabel);
begin
  fLabel := Value;
  if assigned( fLabel ) then
  begin
    fLabel.Enabled := self.Enabled;
  end;
end;

procedure tSigBaseProperty.SetRedoing(const Value: boolean);
begin
  if assigned( fOwner ) then
  begin
    fOwner.SetRedoing( Value );
  end
  else if Value then
  begin
    inc( fRedoing );
  end
  else if fRedoing > 0 then
  begin
    if fRedoing = 1 then
    begin
      {
        This slightly ugly construct is necessary to ensure that we still
        redo rather than undo
      }
      CompleteRedoing;
    end;
    dec( fRedoing );
  end;
end;

procedure tSigBaseProperty.SetSigOnChange(const Value: tSigOnChange);
begin
  if @fSigOnChange <> @Value then
  begin
    fSigOnChange := Value;
    if assigned( fSigOnChange ) then
    begin
      fSigOnChange( self );
    end;
  end;
end;

procedure tSigBaseProperty.SetUndoing(const Value: boolean);
begin
  if assigned( fOwner ) then
  begin
    fOwner.SetUndoing( Value );
  end
  else if Value then
  begin
    inc( fUndoing );
  end
  else if fUndoing > 0 then
  begin
    if fUndoing = 1 then
    begin
      {
        This slightly ugly construct is necessary to ensure that we still
        undo rather than do or redo
      }
      CompleteUndoing;
    end;
    dec( fUndoing );
  end;
end;

procedure tSigBaseProperty.SetValue(const pValue: string);
var
  iLoadingFromDevice  : tSigLoadAction;
begin
  iLoadingFromDevice := LoadingFromDevice;
  case iLoadingFromDevice of
    laNone,
    laLoadingFromDevice:
    begin
      if fValue <> pValue then
      begin
        if AmUndoing then
        begin
          ExecuteRedoableAction( self, undoValue, fValue );
        end
        else if not (Creating or LoadingFromFile) then
        begin
          ExecutePrepareUndoableAction( self, undoValue, fValue );
          ExecuteUndoableAction( self, undoValue, fValue );
        end;
        fValue := pValue;
        if self.SaveWithFile then
        begin
          IsDirty := TRUE;
        end;
        RefreshEditor;
        ExecuteOnChange( self, AmUndoing, AmRedoing );
        if not (AmUndoing or Creating or LoadingFromFile) then
        begin
          ExecuteCompleteUndoableAction( self, undoValue, fValue );
        end;
        //if assigned( fOnNotify ) then
        //begin
        //  fOnNotify( self );
        //end;
        Notify( self );
      end;
    end;
    laComparingFromDevice:
    begin
      if fValueOnDevice <> pValue then
      begin
        fValueOnDevice := pValue;
        ShowDeviceEditor;
        ExecuteOnChange( self, AmUndoing, AmRedoing );
      end;
    end;
  end;
end;

procedure tSigBaseProperty.SetValueOnDeviceEditor(const Value: tEdit);
begin
  fValueOnDeviceEditor := Value;
  if assigned(fValueOnDeviceEditor) then
  begin
    fValueOnDeviceEditor.ReadOnly := TRUE;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fValueOnDeviceEditor.ParentColor := TRUE;
{$ENDIF}
    ShowDeviceEditor;
  end;
end;

procedure tSigBaseProperty.SetVisible(const Value: boolean);
begin
  if fVisible <> Value then
  begin
    fVisible := Value;
    RefreshEditor;
  end;
end;

procedure tSigBaseProperty.ShowDeviceEditor;
begin
  if assigned(fValueOnDeviceEditor) then
  begin
    fValueOnDeviceEditor.Text := ValueOnDevice;
  end;
end;

procedure tSigBaseProperty.StartLoadingFromDevice;
begin
  OwnerFile.IncDevLoadingCount;
end;

class function tSigBaseProperty.TerminationString: string;
begin
  Result := 'End ' + ClassType;
end;

function tSigBaseProperty.Translate(const pVal: string): string;
begin
  if assigned( OwnerFile ) then
  begin
    Result := OwnerFile.Translate( pVal );
  end
  else
  begin
    Result := pVal;
  end;
end;

function tSigBaseProperty.TranslateValue(Value: string): string;
begin
  if assigned( fOnTranslateValue ) then
  begin
    Result := fOnTranslateValue( Value );
  end
  else
  begin
    Result := Value;
  end;
end;

procedure tSigBaseProperty.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  AmUndoing := TRUE;
  try
    case pUndoAction of
      undoValue:
      begin
        Value := pUndoString;
      end;
    end;
    OnUndo( self, pUndoAction, pUndoString );
  finally
    AmUndoing := FALSE;
  end;
end;

procedure tSigBaseProperty.UnregisterInterest(pSigObject: tSigBaseProperty);
begin
  if not fDestroying then
  begin
    fInterestedParties.Remove( pSigObject );
  end;
end;

{ tSigSimpleProperty }

class function tSigSimpleProperty.ClassType: string;
begin
  Result := '';  // no prefix for simple properties
end;

procedure tSigSimpleProperty.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
begin
  if Indexed then
  begin
    if Comment <> '' then
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value + '// ' + Comment);
    end
    else
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value );
    end;
  end
  else
  begin
    if Comment <> '' then
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value + '// ' + Comment );
    end
    else
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value );
    end;
  end;
  inherited;
end;

function tSigSimpleProperty.GetComment: string;
begin
  Result := fComment;
end;

function tSigSimpleProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
begin
  Result := TRUE;
  IsDirty := pIsDirty;
  LoadLine( pLine, pFile.Count );
  // RefreshEditor;
  // nothing else to do
  exit;
end;

function tSigSimpleProperty.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
begin
  Result := TRUE;
  // nothing else to do
end;

function tSigSimpleProperty.PrintStructureString: string;
begin
  Result := PropertyName;
end;

procedure tSigSimpleProperty.Save(pSaveFile: tStrings; pShortFormat : boolean; pIndent : integer);
begin
  if SaveWithFile then
  begin
    if Indexed then
    begin
      if Comment <> '' then
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value + '// ' + Comment);
      end
      else
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value );
      end;
    end
    else
    begin
      if Comment <> '' then
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value + '// ' + Comment );
      end
      else
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value );
      end;
    end;
    inherited;
  end;
end;

class function tSigSimpleProperty.TerminationString: string;
begin
  // never a termination string
  Result := '';
end;

{ tSigPropertyList }

function tSigPropertyList.Add(Value: tSigBaseProperty; const pUndoAction : tSigFileUndoAction): integer;
begin
  Result := inherited Add( Value );
  if assigned( Owner ) then
  begin
    if Undoing then
    begin
      Owner.ExecuteRedoableAction( Owner, pUndoAction, IntToStr( Result ));
    end
    else
    begin
      Owner.ExecuteUndoableAction( Owner, pUndoAction, IntToStr( Result ));
    end;
  end;
end;

procedure tSigPropertyList.AfterConstruction;
begin
  inherited;
end;

procedure tSigPropertyList.CheckErrors(var pErrorCount, pWarningCount,
  pHintCount: integer; pErrors: tErrorList);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].CheckErrors( pErrorCount, pWarningCount, pHintCount, pErrors );
  end;
end;

function tSigPropertyList.ChildMustExist: boolean;
begin
  Result := fOwner.ChildMustExist;

end;

procedure tSigPropertyList.Clear;
var
  i: Integer;
begin
  if not assigned( fDeletedChildren ) then
  begin
    inherited;
  end
  else if not assigned( Owner ) then
  begin
    inherited;
    fDeletedChildren.Clear;
  end
  else if Owner.LoadingFromFile then
  begin
    inherited;
    fDeletedChildren.Clear;
  end
  else
  begin
    OwnsObjects := FALSE;
    if Undoing then
    begin
      Owner.ExecuteRedoableAction( Owner, undoClear, IntToStr( Count ));
    end
    else
    begin
      Owner.ExecuteUndoableAction( Owner, undoClear, IntToStr( Count ));
    end;
    for i := Count - 1 downto 0 do
    begin
      fDeletedChildren.Add( Items[ i ] );
    end;
    inherited;
    OwnsObjects := TRUE;
  end;
end;

procedure tSigPropertyList.ClearRedoList;
var
  i: Integer;
  iItem : tSigBaseProperty;
begin
  if assigned( fSortedChildren ) then fSortedChildren.Clear;
  for i := 0 to Count - 1 do
  begin
    iItem := Item[ i ];
    if iItem is tSigCompoundProperty then
    begin
      (iItem as tSigCompoundProperty).Children.ClearRedoList;
    end;
  end;
end;

procedure tSigPropertyList.ClearUndoList( SendMessage : boolean );
var
  i: Integer;
  iItem : tSigBaseProperty;
begin
  if Undoing then
  begin
    raise Exception.Create('Internal Error - 093');
  end
  else
  begin
    if assigned( fDeletedChildren ) then
    begin
      fDeletedChildren.Clear;
    end;
    if assigned( fSortedChildren ) then
    begin
      fSortedChildren.Clear;
    end;
    for i := 0 to Count - 1 do
    begin
      iItem := Item[ i ];
      if iItem is tSigCompoundProperty then
      begin
        (iItem as tSigCompoundProperty).Children.ClearUndoList( FALSE );
      end;
    end;
    if SendMessage then
    begin
      Owner.ExecuteUndoableAction( Owner, undoClearUndoList, '');
    end;
  end;
end;

procedure tSigPropertyList.CompleteRedoing;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].CompleteRedoing;
  end;
end;

procedure tSigPropertyList.CompleteUndoing;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].CompleteUndoing;
  end;
end;

procedure tSigPropertyList.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].CopyToClipboard( pClipboard, pShortFormat, pindent );
  end;
end;

constructor tSigPropertyList.Create( pOwner : tSigCompoundProperty );
begin
  inherited Create( TRUE );

  fDeletedChildren := TObjectList.Create( TRUE );
  fSortedChildren := tSortedChildren.Create;

  fOwner := pOwner;
end;

function tSigPropertyList.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
var
  iText, iText2 : string;
begin
  if assigned( fOwner ) then
  begin
    Result := fOwner.CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
    if assigned( Result ) then
    begin
      exit;
    end;
  end;
  iText := tSigCompoundProperty.ClassType + ' ';
  if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
  begin
    iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
    if pIndexText = '' then
    begin
      Result := tSigCompoundProperty.Create( iText2, fOwner);
    end
    else
    begin
      Result := tSigCompoundProperty.Create( iText2, pIndexText, fOwner);
    end;
  end
  else
  begin
    iText := tMemoProperty.ClassType + ' ';
    if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
    begin
      iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
      if pIndexText = '' then
      begin
        Result := tMemoProperty.Create( iText2, fOwner);
      end
      else
      begin
        Result := tMemoProperty.Create( iText2, pIndexText, fOwner);
      end;
    end
    else
    begin
      iText := tSigArrayProperty.ClassType + ' ';
      if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
      begin
        iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
        if pIndexText = '' then
        begin
          Result := tSigArrayProperty.Create( iText2, fOwner);
        end
        else
        begin
          Result := tSigArrayProperty.Create( iText2, pIndexText, fOwner);
        end;
      end
      else
      begin
        iText := tSigFileProperty.ClassType + ' ';
        if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
        begin
          iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
          if pIndexText = '' then
          begin
            Result := tSigFileProperty.Create( iText2, fOwner);
          end
          else
          begin
            Result := tSigFileProperty.Create( iText2, pIndexText, fOwner);
          end;
        end
        else
        begin
          iText := tSigObjectList.ClassType + ' ';
          if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
          begin
            iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
            if NO_CHILD_MUST_EXIST then
            begin
              if pIndexText = '' then
              begin
                Result := tSigObjectList.Create( iText2, fOwner, tSigCompoundProperty );
              end
              else
              begin
                Result := tSigObjectList.Create( iText2, pIndexText, fOwner, tSigCompoundProperty);
              end;
            end
            else
            begin
              if pIndexText = '' then
              begin
                Result := tSigObjectList.Create( iText2, fOwner);
              end
              else
              begin
                Result := tSigObjectList.Create( iText2, pIndexText, fOwner);
              end;
            end;
          end
          else
          begin
            iText := tSigObjectArray.ClassType + ' ';
            if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
            begin
              iText2 := Trim(Copy( pPropertyText, Length( iText ), Length( pPropertyText)));
              if pIndexText = '' then
              begin
                Result := tSigObjectArray.Create( iText2, fOwner);
              end
              else
              begin
                Result := tSigObjectArray.Create( iText2, pIndexText, fOwner);
              end;
            end
            else
            begin
              if pIndexText = '' then
              begin
                Result := tSigSimpleProperty.Create( pPropertyText, fOwner );
              end
              else
              begin
                Result := tSigSimpleProperty.Create( pPropertyText, pIndexText, fOwner );
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigPropertyList.Delete(Index: Integer; const pUndoAction : tSigFileUndoAction);
begin
  if not assigned( Owner ) then
  begin
    inherited Delete( Index );
  end
  else if assigned( fDeletedChildren ) then
  begin
    if Index < Count then          // debug
    begin
      OwnsObjects := FALSE;
      //Item[ Index ].RemoveInterest;
      Item[ Index ].OnDestroy;
      fDeletedChildren.Add( Item[ Index ] );
      inherited Delete( Index );
      OwnsObjects := TRUE;
      if Undoing then
      begin
        Owner.ExecuteRedoableAction( Owner, pUndoAction, IntToStr( Index ));
      end
      else
      begin
        Owner.ExecuteUndoableAction( Owner, pUndoAction, IntToStr( Index ));
      end;
    end
    else
    begin
      OwnsObjects := TRUE;
    end;
  end
  else
  begin
    inherited Delete( Index );
  end;
end;

procedure tSigPropertyList.Delete(Index: string; const pUndoAction : tSigFileUndoAction);
var
  iIndex : integer;
begin
  iIndex := StrToInt( Index );
  Delete( iIndex, pUndoAction );
end;

destructor tSigPropertyList.Destroy;
begin
  FreeAndNil( fDeletedChildren );
  FreeAndNil( fSortedChildren );
  inherited;
end;

function tSigPropertyList.Errors(pErrorList: tErrorList): boolean;
var
  i: Integer;
begin
  Result := FALSE;
  for i := 0 to Count - 1 do
  begin
    if Item[ i ].Errors( pErrorList ) then
    begin
      Result := TRUE;
    end;
    if not assigned( pErrorList ) then
    begin
      exit; // no point in continuing unless we are building an error list
    end;
  end;
end;

function tSigPropertyList.FindChild(const pPropertyText, pIndexText: string;
  const Iterate: boolean): tSigBaseProperty;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Item[i];
    if AnsiSameText( Result.PropertyName, pPropertyText) and AnsiSameText( Result.Index, pIndexText)  then
    begin
      exit;
    end
    else if Iterate then
    begin
      if Result is tSigCompoundProperty then
      begin
        with Result as tSigCompoundProperty do
        begin
          Result  := Children.FindChild( pPropertyText, pIndexText, Iterate );
          if assigned( Result ) then
          begin
            exit;
          end;
        end;
      end;
    end;
  end;
  // else
  Result := nil;
end;

function tSigPropertyList.GetIsDirty: boolean;
var
  i: Integer;
begin
  Result := FALSE;
  for i := 0 to Count - 1 do
  begin
    if Item[ i ].IsDirty then
    begin
      Result := TRUE;
      exit;
    end;
  end;
end;

function tSigPropertyList.GetUndoing: boolean;
begin
  Result := Owner.Undoing;
end;

procedure tSigPropertyList.Insert(Index: Integer; AObject: TObject; const pUndoAction : tSigFileUndoAction);
begin
  inherited Insert( Index, AObject );
  if assigned( Owner ) then
  begin
    if Undoing then
    begin
      Owner.ExecuteRedoableAction( Owner, pUndoAction, IntToStr( Index ));
    end
    else
    begin
      Owner.ExecuteUndoableAction( Owner, pUndoAction, IntToStr( Index ));
    end;
  end;
end;

procedure tSigPropertyList.ListIfDirty(pStrings: tStrings;
  const pIndent: integer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    // safety first
    if assigned( Item[ i ] ) then
    begin
      Item[ i ].ListIfDirty( pStrings, pIndent + 2 );
    end; // ignore dodgy ones!
  end;
end;

function tSigPropertyList.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
   pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iChild : tSigBaseProperty;
  iIgnoreChild : tSigBaseProperty;
  iLine, iTerminationString : string;
  i : integer;
begin
  Result := TRUE; // assume OK
  if assigned( fOwner ) then
  begin
    iTerminationString := fOwner.TerminationString;
  end
  else
  begin
    iTerminationString := ''; // to avoid compiler warning
  end;
  while pLine < pFile.Count do
  begin
    // analyse the line...
    iLine := Trim( pFile[ pLine ] );
    if iLine = '' then // ignore blank lines
    begin
      inc( pLine );
    end
    else if SigNETParse ( iLine, SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      inc( pLine );
      if assigned( fOwner ) then
      begin
        fOwner.LoadLine( pLine, pFile.Count );
        if SameText( SigProperty, iTerminationString) then
        begin
          // done
          exit;
        end;
      end;
      iChild := nil;
      iIgnoreChild := nil;
      for i := 0 to Count - 1 do
      begin
        if Item[ i ].IsMe( SigProperty, SigIndex ) then
        begin
          iChild := Item[ i ];
          break;
        end;
      end;
      if not assigned( iChild) then
      begin
        if ChildMustExist then
        begin
          Result := FALSE;
          iIgnoreChild := CreateChild( SigProperty, SigIndex, SigValue, SigComment, pErrors );
          if assigned( pErrors ) then
          begin
            if SigIndex = '' then
            begin
              pErrors.Add( pLine, 'Unexpected "' + SigProperty + '"' );
            end
            else
            begin
              pErrors.Add( pLine, 'Unexpected "' + SigProperty + '( ' + SigIndex + ' )"' );
            end;
          end;
        end
        else
        begin
          iChild := CreateChild( SigProperty, SigIndex, SigValue, SigComment, pErrors );
        end;
      end;
      if assigned( iChild ) then
      begin
        if iChild.Loadable then
        begin
          iChild.Value := SigValue;
        end;
        iChild.Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
      end
      else if assigned( iIgnoreChild ) then
      begin
        iIgnoreChild.Value := SigValue;
        iIgnoreChild.AbortLoad( pFile, pLine, pErrors );
        iIgnoreChild.SaveWithFile := FALSE;  // don't propogate errors with further save
      end;
    end
    else
    begin
      Result := FALSE;
      if assigned( pErrors ) then
      begin
        pErrors.Add( pLine, 'Syntax error');
      end;
      inc( pLine );
    end;
  end;
  // should not get here if owner exists
  if assigned( fOwner ) then
  begin
    Result := FALSE;
    if assigned( pErrors ) then
    begin
      pErrors.Add( es_Error, pLine, fOwner.OwnerFile.Translate( 'Unexpected end of file' ));
    end;
  end;
  IsDirty := FALSE;
end;

procedure tSigPropertyList.Move(pString: string);
var
  iFrom, iTo, iPos : integer;
begin
  iPos := Pos( ',', pString );
  iFrom := StrToInt( Copy( pString, 1, iPos - 1 ) );
  iTo := StrToInt( Copy( pString, iPos + 1, Length( pString )));
  Move( iFrom, iTo );
end;

procedure tSigPropertyList.Move(CurIndex, NewIndex: Integer);
var
  iMove : string;
begin
  if CurIndex <> NewIndex then
  begin
    inherited Move( CurIndex, NewIndex );
    if assigned( Owner ) then
    begin
      iMove := IntToStr( CurIndex ) + ',' + IntToStr( NewIndex );
      if assigned( Owner.OnMoveChild ) then
      begin
        Owner.OnMoveChild( CurIndex, NewIndex );
      end;
      if Undoing then
      begin
        Owner.ExecuteRedoableAction( Owner, undoMove, iMove );
      end
      else
      begin
        Owner.ExecuteUndoableAction( Owner, undoMove, iMove );
      end;
    end;
  end;
end;

function tSigPropertyList.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iChild : tSigBaseProperty;
  iIgnoreChild : tSigBaseProperty;
  iTerminationString : string;
  i : integer;
begin
  Result := TRUE; // assume OK
  if assigned( fOwner ) then
  begin
    iTerminationString := fOwner.TerminationString;
  end
  else
  begin
    iTerminationString := ''; // to avoid compiler warning
  end;
  while pLine < pClipboard.Count do
  begin
    // analyse the line...
    if SigNETParse ( pClipboard[ pLine ], SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      inc( pLine );
      if assigned( fOwner ) then
      begin
        if SameText( SigProperty, iTerminationString) then
        begin
          // done
          exit;
        end;
      end;
      iChild := nil;
      iIgnoreChild := nil;
      for i := 0 to Count - 1 do
      begin
        if Item[ i ].IsMe( SigProperty, SigIndex ) then
        begin
          iChild := Item[ i ];
          break;
        end;
      end;
      if not assigned( iChild) then
      begin
        if ChildMustExist then
        begin
          Result := FALSE;
          iIgnoreChild := CreateChild( SigProperty, SigIndex, SigValue, SigComment, pErrors );
          if assigned( pErrors ) then
          begin
            if SigIndex = '' then
            begin
              pErrors.Add( pLine, 'Unexpected "' + SigProperty + '"' );
            end
            else
            begin
              pErrors.Add( pLine, 'Unexpected "' + SigProperty + '( ' + SigIndex + ' )"' );
            end;
          end;
        end
        else
        begin
          iChild := CreateChild( SigProperty, SigIndex, SigValue, SigComment, pErrors );
        end;
      end;
      if assigned( iChild ) then
      begin
        iChild.Value := SigValue;
        iChild.PasteFromClipboard( pClipboard, pLine, pErrors );
      end
      else if assigned( iIgnoreChild ) then
      begin
        iIgnoreChild.Value := SigValue;
        iIgnoreChild.AbortLoad( pClipboard, pLine, pErrors );
        iIgnoreChild.SaveWithFile := FALSE;  // don't propogate errors with further save
      end;
    end
    else
    begin
      Result := FALSE;
      if assigned( pErrors ) then
      begin
        pErrors.Add( pLine, 'Syntax error');
      end;
      inc( pLine );
    end;
  end;
  // should not get here if owner exists
  if assigned( fOwner ) then
  begin
    Result := FALSE;
    if assigned( pErrors ) then
    begin
      pErrors.Add(  es_Error, pLine, fOwner.OwnerFile.Translate( 'Unexpected end of file' ));
    end;
  end;
  IsDirty := FALSE;
end;

procedure tSigPropertyList.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  case pUndoAction of
    undoClear:
    begin
      Clear;
    end;
    undoUnclear:
    begin
      UnClear( pUndoString, pUndoAction );
    end;
    undoAdd:
    begin
      UnDelete( pUndoString, pUndoAction );
    end;
    undoInsert2:
    begin
      UnDelete( pUndoString, pUndoAction );
    end;
    undoDelete2:
    begin
      Delete( pUndoString, pUndoAction );
    end;
    undoUndelete2:
    begin
      UnDelete( pUndoString, pUndoAction );
    end;
    undoMove:
    begin
      UnMove( pUndoString );
    end;
    undoSwap2:
    begin
      Swap( pUndoString );
    end;
    undoSort:
    begin
      UnSort( pUndoString );
    end;
    undoUnSort:
    begin
      Sort( nil );
    end;
  end;
end;

procedure tSigPropertyList.ReinstateInterest;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].ReinstateInterest;
  end;
end;

function tSigPropertyList.Remove(AObject: TObject): Integer;
begin
  Result := IndexOfItem( AObject, TList.TDirection.FromBeginning );
  if assigned( Owner ) then
  begin
    if Result = Owner.ActiveChild then
    begin
      Owner.ActiveChild := -1;
    end;
  end;
  if Result >= 0 then
  begin
    Delete( Result );
  end;
end;

procedure tSigPropertyList.RemoveEditors;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].RemoveEditors;
  end;
end;

procedure tSigPropertyList.RemoveInterest;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].RemoveInterest;
  end;
end;

procedure tSigPropertyList.Save(pSaveFile: tStrings; pShortFormat : boolean; pIndent: integer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    // safety first
    if assigned( Item[ i ] ) then
    begin
      Item[ i ].Save( pSaveFile, pShortFormat, pindent );
    end; // ignore dodgy ones!
  end;
  //inherited;
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigPropertyList.Save(pTreeNodes: tTreeNodes; pTreeNode: tTreeNode) : tTreeNode;
var
  i: Integer;
  iText : string;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    // safety first
    if assigned( Item[ i ] ) then
    begin
      with Item[ i ] do
      begin
        if SaveWithFile then
        begin
          iText := ClassType;
          if iText <> '' then
          begin
            iText := iText + ' ';
          end;
          iText := iText + PropertyName;
          if Indexed then
          begin
            iText := iText + '( ' + Index + ' )';
          end;
          if Value <> '' then
          begin
            iText := iText + ' = ' + Value;
          end;
          Result := pTreeNodes.AddChildObject( pTreeNode, iText, Item[ i ] );
          Save( pTreeNodes, Result );
        end;
      end;
    end; // ignore dodgy ones!
  end;
end;
{$ENDIF}

procedure tSigPropertyList.SetDirty(const Value: boolean);
var
  i: Integer;
  Item_i : tSigBaseProperty;
begin
  if not Value then
  begin
    for i := 0 to Count - 1 do
    begin
      Item_i := Item[ i ];
      if assigned( Item_i ) then
      begin
        Item_i.IsDirty := FALSE;
      end;
    end;
  end;
end;


procedure tSigPropertyList.Sort( pSorter : TListSortCompare );
var
  i : integer;
  iSortedChild : tSortedChild;
begin
    if Undoing then
    begin
      // in this case we get the sorter from sorted children because we are undoing a redo!
      iSortedChild := fSortedChildren.Undo;
      Owner.ExecuteRedoableAction( Owner, undoSort, IntToStr( Count ));
    end
    else
    begin
      // this is the more usual way
      iSortedChild := fSortedChildren.Next( pSorter );
      Owner.ExecuteUndoableAction( Owner, undoSort, IntToStr( Count ));
    end;
    for i := 0 to Count - 1 do
    begin
      iSortedChild.Add( Items[ i ] );
    end;
    inherited Sort( iSortedChild.Sorter );
end;

procedure tSigPropertyList.Swap(pString: string);
var
  iFrom, iTo, iPos : integer;
begin
  iPos := Pos( ',', pString );
  iFrom := StrToInt( Copy( pString, 1, iPos - 1 ) );
  iTo := StrToInt( Copy( pString, iPos + 1, Length( pString )));
  Swap( iFrom, iTo );
end;

procedure tSigPropertyList.Swap(pIndex1, pIndex2: integer);
var
  iMove : string;
  iTemp : tObject;
begin
  try
    if pIndex1 <> pIndex2 then
    begin
      if assigned( Owner ) then
      begin
        if assigned( Owner.OnSwapChild ) then
        begin
          Owner.OnSwapChild( pIndex1, pIndex2 );
        end;
        iMove := IntToStr( pIndex1 ) + ',' + IntToStr( pIndex2 );
        OwnsObjects := FALSE;
      end;
      iTemp := Items[ pIndex1 ];
      Items[ pIndex1 ] := Items[ pIndex2 ];
      Items[ pIndex2 ] := iTemp;
      if assigned( Owner ) then
      begin
        OwnsObjects := TRUE;
        if Undoing then
        begin
          Owner.ExecuteRedoableAction( Owner, undoSwap2, iMove );
        end
        else
        begin
          Owner.ExecuteUndoableAction( Owner, undoSwap2, iMove );
        end;
      end;
    end;
  except
    raise;
  end;
end;

procedure tSigPropertyList.UnDelete(Index: Integer; const pUndoAction : tSigFileUndoAction);
var
  iLastChild : integer;
begin
  try
    fDeletedChildren.OwnsObjects := FALSE;
    iLastChild := fDeletedChildren.Count - 1;
    if iLastChild >= 0 then              // debug
    begin
      Insert( Index, fDeletedChildren.Items[ iLastChild ], pUndoAction );
      //Item[ Index ].ReinstateInterest;
      Item[ Index ].OnUndestroy;
      fDeletedChildren.Delete( iLastChild );
      fDeletedChildren.OwnsObjects := TRUE;
    end
    else
    begin
      fDeletedChildren.OwnsObjects := TRUE;
    end;
  except
    raise;
  end;
end;

{
procedure tSigPropertyList.UnAdd;
begin
  try
    Delete( Count - 1, undoAdd );
  except
    raise;
  end;
end;
}

procedure tSigPropertyList.UnClear(const pCount: integer; const pUndoAction : tSigFileUndoAction);
var
  i, j : integer;
begin
  try
    fDeletedChildren.OwnsObjects := FALSE;
    j := fDeletedChildren.Count;
    for i := 1 to pCount do
    begin
      inherited Add( fDeletedChildren.Items[ j - i ] );
      fDeletedChildren.Delete( j - i );
    end;
    fDeletedChildren.OwnsObjects := TRUE;
    if assigned( Owner ) then
    begin
      if Undoing then
      begin
        Owner.ExecuteRedoableAction( Owner, undoUnClear, IntToStr( Count ));
      end
      else
      begin
        Owner.ExecuteUndoableAction( Owner, undoUnClear, IntToStr( Count ));
      end;
    end;
  except
    Raise;
  end;
end;

procedure tSigPropertyList.UnClear(const pCount: string; const pUndoAction : tSigFileUndoAction);
begin
  UnClear( StrToInt( pCount ), pUndoAction);
end;

procedure tSigPropertyList.UnDelete(Index: string; const pUndoAction : tSigFileUndoAction);
var
  iIndex : integer;
begin
  iIndex := StrToInt( Index );
  UnDelete( iIndex, pUndoAction );
end;

procedure tSigPropertyList.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  case pUndoAction of
    undoClear:
    begin
      UnClear( pUndoString, pUndoAction );
    end;
    undoUnclear:
    begin
      Clear;
    end;
    undoAdd:
    begin
      //UnAdd;
      Delete( pUndoString, pUndoAction );
    end;
    undoInsert2:
    begin
      UnInsert( pUndoString, pUndoAction );
    end;
    undoDelete2:
    begin
      Undelete( pUndoString, pUndoAction );
    end;
    undoUndelete2:
    begin
      Delete( pUndoString, pUndoAction );
    end;
    undoMove:
    begin
      UnMove( pUndoString );
    end;
    undoSwap2:
    begin
      Swap( pUndoString );
    end;
    undoSort:
    begin
      UnSort( pUndoString );
    end;
    undoUnSort:
    begin
      Sort( nil );
    end;
  end;
end;

procedure tSigPropertyList.UnInsert(Index: Integer; const pUndoAction : tSigFileUndoAction);
begin
  try
    Delete( Index, pUndoAction );
  except
    raise;
  end;
end;

procedure tSigPropertyList.UnInsert(Index: string; const pUndoAction : tSigFileUndoAction);
begin
  UnInsert( StrToInt( Index ), pUndoAction);
end;

procedure tSigPropertyList.UnMove(pString: string);
var
  iFrom, iTo, iPos : integer;
begin
  try
    iPos := Pos( ',', pString );
    iFrom := StrToInt( Copy( pString, 1, iPos - 1 ) );
    iTo := StrToInt( Copy( pString, iPos + 1, Length( pString )));
    Move( iTo, iFrom );
  except
    raise;
  end;
end;

procedure tSigPropertyList.UnSort(const pCount: integer);
var
  i : integer;
  iSortedChild : tSortedChild;
begin
  try
    if Undoing then
    begin
      iSortedChild := fSortedChildren.Undo;
      Owner.ExecuteRedoableAction( Owner, undoUnSort, IntToStr( Count ));
    end
    else
    begin
      iSortedChild := fSortedChildren.Redo;
      Owner.ExecuteUndoableAction( Owner, undoUnSort, IntToStr( Count ));
    end;
    OwnsObjects := FALSE;
    for i := 0 to pCount - 1 do
    begin
      Items[ i ] := iSortedChild.List.Items[ i ];
    end;
    OwnsObjects := TRUE;
  except
    OwnsObjects := TRUE;
    Raise;
  end;
end;

procedure tSigPropertyList.UnSort(const pCount: string);
begin
  Unsort( StrToInt( pCount ));
end;

{ tSigCompoundProperty }

procedure tSigCompoundProperty.AbortLoad(pFile: tStrings; var pLine: integer;
  pErrors: tErrorList);
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  AbortCount : integer;
Label
  Loop;
begin
  AbortCount := 0;
Loop:
  if pLine >= pFile.Count then
  begin
    if assigned( pErrors ) then
    begin
      pErrors.Add(  es_Error, pLine, OwnerFile.Translate( 'Unexpected end of file' ));
    end;
    exit;
  end;
  // analyse the line...
  if SigNETParse ( pFile[ pLine ], SigProperty,
         SigIndex, SigValue, SigComment) then
  begin
    inc( pLine );
    if SameText( SigProperty, TerminationString) then
    begin
      if AbortCount = 0 then
      begin
        exit;
      end
      else
      begin
        dec( AbortCount );
      end;
    end
    else if SameText( SigProperty, ClassType) then
    begin
      inc( AbortCount );
    end;
  end;
  goto Loop;
  IsDirty := FALSE;
end;

function tSigCompoundProperty.ActiveChildObjectIs(
  const pObject: tSigBaseProperty): boolean;
begin
  if ActiveChild >= 0 then
  begin
    Result := Entry[ ActiveChild ] = pObject;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure tSigCompoundProperty.Assign(const pFrom: tSigBaseProperty;
  const AllowUndo: boolean);
var
  i: Integer;
  iFrom : tSigCompoundProperty;
  iFromChild : tSigBaseProperty;
begin
  inherited;
  if pFrom is tSigCompoundProperty then
  begin
    iFrom := pFrom as tSigCompoundProperty;
    for i := 0 to Children.Count - 1 do
    begin
      iFromChild := iFrom.Children.FindChild( Children.Item[ i ].PropertyName );
      if assigned( iFromChild ) then
      begin
        Children.Item[ i ].Assign( iFromChild, AllowUndo );
      end;
    end;
  end;
end;

function tSigCompoundProperty.CanDelete(const pIndex: integer): boolean;
begin
  Result := fChildren.Item[ pIndex ].CanDestroy;
end;

function tSigCompoundProperty.ChangeActiveChild(
  const NewVal: tSigBaseProperty): boolean;
var
  i: Integer;
begin
  if assigned( NewVal ) then
  begin
    for i := 0 to fChildren.Count - 1 do
    begin
      if Children.Item[ i ] = NewVal then
      begin
        ActiveChild := i;
        Result := TRUE;
        exit;
      end;
    end;
    // else
    Result := FALSE;
  end
  else
  begin
    ActiveChild := -1;
    Result := TRUE;
  end;
end;

class function tSigCompoundProperty.ChildMustExist: boolean;
begin
  if NO_CHILD_MUST_EXIST then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := TRUE;
  end;
end;

class function tSigCompoundProperty.ClassType: string;
begin
  Result := 'Object';
end;

procedure tSigCompoundProperty.Clear;
var
  i: Integer;
begin
  try
    ActiveChild := -1;
    if assigned( Children ) and not Creating then
    begin
      for i := 0 to Children.Count - 1 do
      begin
        Children[ i ].Clear;
      end;
    end;
    inherited;
  finally
  end;
end;

procedure tSigCompoundProperty.CompleteRedoing;
begin
  inherited;
  if fActiveChild <> fPendingActiveChild then
  begin
    SetActiveChild( fPendingActiveChild );
  end;
  Children.CompleteRedoing;
end;

procedure tSigCompoundProperty.CompleteUndoing;
begin
  inherited;
  if fActiveChild <> fPendingActiveChild then
  begin
    SetActiveChild( fPendingActiveChild );
  end;
  Children.CompleteUndoing;
end;

procedure tSigCompoundProperty.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iLine : string;
begin
  // these have the form
  // object name [( index )] [= value ]
  // ...
  // end name
  if pShortFormat then
  begin
    iLine := StringOfChar( ' ', pIndent ) + PropertyName;
  end
  else
  begin
    iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
  end;
  if Indexed then
  begin
    iLine := iLine + '( ' + Index + ' )';
  end;
  if Value <> '' then
  begin
    iLine := iLine + ' = ' + Value;
  end;
  pClipboard.Add( iLine );
  SaveOthers( pClipboard, pIndent );
  Children.CopyToClipboard( pClipboard, pShortFormat, pIndent + 2 );
  pClipboard.Add( StringOfChar( ' ', pIndent) + TerminationString );
  inherited;
end;

constructor tSigCompoundProperty.Create(pPropertyName: string; pOwner : tSigCompoundProperty);
begin
  inherited;
  fChildren := tSigPropertyList.Create( self );
  //fDeletedChildren := tSigPropertyList.Create( self );
  fSaveActiveChild := TRUE;
  fActiveChild := -1;
  fPendingActiveChild := -1;
  fSaveMax := TRUE;
end;

function tSigCompoundProperty.CreateChild(const pPropertyText: string;
  const pIndex: integer; const pValue, pComment: string; pErrors: tErrorList;
  pErrorLine, pErrorPos: integer): tSigBaseProperty;
begin
  Result := nil;
end;

function tSigCompoundProperty.CreateChild(const pPropertyText, pIndexText,
  pValue, pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
begin
  Result := nil;
end;

procedure tSigCompoundProperty.Delete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  if assigned( fOnRemoveChild ) then
  begin
    fOnRemoveChild( Entry[ pIndex ] );
  end;
  if assigned( fOnDelete ) then
  begin
    fOnDelete( pIndex, Entry[ pIndex ] );
  end;
  Children.Delete( pIndex, pUndoAction );
  IsDirty := TRUE;
end;

procedure tSigCompoundProperty.UnDelete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  fChildren.UnDelete( pIndex, pUndoAction );
end;

destructor tSigCompoundProperty.Destroy;
begin
  fChildren.Free;
  //fDeletedChildren.Free;
  inherited;
end;

procedure tSigCompoundProperty.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing : boolean);
begin
  if pUndoing then
  begin
    AmUndoing := TRUE;
  end;
  if pRedoing then
  begin
    AmRedoing := TRUE;
  end;
  try
    fChangedChild := pChangedObject;
    inherited;
    fChangedChild := nil;
  finally
    if pUndoing then
    begin
      AmUndoing := FALSE;
    end;
    if pRedoing then
    begin
      AmRedoing := FALSE;
    end;
  end;
end;

function tSigCompoundProperty.GetActiveChild: integer;
begin
  Result := fActiveChild;
end;

function tSigCompoundProperty.GetCount: integer;
begin
  if assigned( Children ) then
  begin
    Result := Children.Count;
  end
  else
  begin
    Result := -1;
  end;
end;

function tSigCompoundProperty.GetEntry(const i: integer): tSigBaseProperty;
begin
  Result := Children.Item[ i ];
end;

function tSigCompoundProperty.GetMax: integer;
begin
  Result := fMax;
end;

function tSigCompoundProperty.GetOnMaxChange: tSigOnIntegerChange;
begin
  Result := fOnMaxChange;
end;

function tSigCompoundProperty.GetStringListControlList: tStringListControlList;
begin
  Result := fStringListControlList;
end;

procedure tSigCompoundProperty.ListIfDirty(pStrings: tStrings;
  const pIndent: integer);
begin
  inherited;
  Children.ListIfDirty( pStrings, pIndent );
end;

function tSigCompoundProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iActiveChild : integer;
Label
  Loop;
begin
  iActiveChild := ActiveChild;
Loop:
  if pLine >= pFile.Count then
  begin
    Result := FALSE;
    if assigned( pErrors ) then
    begin
      pErrors.Add(  es_Error, pLine, OwnerFile.Translate( 'Unexpected end of file' ));
    end;
    exit;
  end;
  // analyse the line...
  if SigNETParse ( pFile[ pLine ], SigProperty,
         SigIndex, SigValue, SigComment) then
  begin
    if SigProperty = '' then
    begin
      inc( pLine );
      goto Loop;
    end;
    if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      goto Loop;
    end;
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      // Meaningless line?
      goto Loop;
    end;
  end;
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
  if not Children.Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors ) then
  begin
    Result := FALSE;
  end;
  ActiveChild := iActiveChild;
  //RefreshEditor;
  IsDirty := pIsDirty;
end;

function tSigCompoundProperty.MatchesDataOnDevice: boolean;
var
  i: Integer;
  iCheckChildren : boolean;
begin
  Result := inherited MatchesDataOnDevice;
  case ValueOnDeviceChecked of
    vod_SameAsEnabled:
    begin
      iCheckChildren := Enabled and Result;
    end;
    vod_FALSE:
    begin
      iCheckChildren := FALSE;
    end;
    vod_TRUE:
    begin
      iCheckChildren := Result;
    end;
    else
    begin
     iCheckChildren := Result; // assume same as enabled
    end;
  end;
  if iCheckChildren then
  begin
    for i := 0 to fChildren.Count - 1 do
    begin
      if not fChildren.Item[ i ].MatchesDataOnDevice then
      begin
        Result := FALSE;
        exit;
      end;
    end;
  end;
end;

procedure tSigCompoundProperty.Move(const pFrom, pTo: integer);
begin
  Children.Move( pFrom, pTo );
  if assigned(fOnMoveChild ) then
  begin
    fOnMoveChild( pFrom, pTo );
  end;
end;

function tSigCompoundProperty.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iActiveChild : integer;
Label
  Loop;
begin
  iActiveChild := ActiveChild;
Loop:
  if pLine >= pClipboard.Count then
  begin
    Result := FALSE;
    if assigned( pErrors ) then
    begin
      pErrors.Add( es_Error, pLine, fOwner.OwnerFile.Translate( 'Unexpected end of file' ));
    end;
    exit;
  end;
  // analyse the line...
  if SigNETParse ( pClipboard[ pLine ], SigProperty,
         SigIndex, SigValue, SigComment) then
  begin
    if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      goto Loop;
    end;
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      // Meaningless line?
      goto Loop;
    end;
  end;
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );
  if not Children.PasteFromClipboard( pClipboard, pLine, pErrors ) then
  begin
    Result := FALSE;
  end;
  ActiveChild := iActiveChild;
end;

function tSigCompoundProperty.PrintStructureString: string;
begin
  Result := ClassType + ' ' + PropertyName;
end;

procedure tSigCompoundProperty.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  case pUndoAction of
    undoValue:
    begin
      inherited;
    end;
    undoChangeMax: ;
    undoAdd,
    undoMove,
    undoSwap2,
    undoInsert2:
    begin
      Children.Redo( pUndoAction, pUndoString );
    end;
    undoDelete2:
    begin
      i := StrToInt( pUndoString );
      Delete( i, pUndoAction );
    end;
    undoUndelete2:
    begin
      i := StrToInt( pUndoString );
      UnDelete( i, pUndoAction );
    end;
    undoSelPos: ;
    undoSelLen: ;
    undoChangeActiveChild:
    begin
      ActiveChild := StrToInt( pUndoString );
    end;
    undoPointer: ;
  end;
end;

procedure tSigCompoundProperty.ReinstateInterest;
begin
  inherited;
  Children.ReinstateInterest;
end;

function tSigCompoundProperty.Remove(pObject: tObject; const pUndoAction : tSigFileUndoAction): integer;
begin
  Result := Children.IndexOfItem( pObject, TList.TDirection.FromBeginning );
  if Result >= 0 then
  begin
    Delete( Result, pUndoAction );
  end;
end;

procedure tSigCompoundProperty.RemoveEditors;
begin
  Children.RemoveEditors;
  inherited;
end;

procedure tSigCompoundProperty.RemoveInterest;
begin
  inherited;
  Children.RemoveInterest;
end;

procedure tSigCompoundProperty.Save(pSaveFile: tStrings; pShortFormat : boolean; pIndent: integer);
var
  iLine : string;
begin
  if SaveWithFile then
  begin
    // these have the form
    // object name [( index )] [= value ]
    // ...
    // end name
    if pShortFormat then
    begin
      iLine := StringOfChar( ' ', pIndent ) + PropertyName;
    end
    else
    begin
      iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
    end;
    if Indexed then
    begin
      iLine := iLine + '( ' + Index + ' )';
    end;
    if Value <> '' then
    begin
      iLine := iLine + ' = ' + Value;
    end;
    pSaveFile.Add( iLine );
    SaveOthers( pSaveFile, pIndent );
    Children.Save( pSaveFile, pShortFormat, pIndent + 2 );
    pSaveFile.Add( StringOfChar( ' ', pIndent) + TerminationString );
    inherited;
  end;
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigCompoundProperty.Save(pTreeNodes: tTreeNodes;
  pTreeNode: tTreeNode): tTreeNode;
begin
  result := Children.Save( pTreeNodes, pTreeNode );
end;
{$ENDIF}

procedure tSigCompoundProperty.SaveOthers;
begin
  if SaveActiveChild then
  begin
    if fActiveChild <> -1 then
    begin
      pSaveFile.Add( StringOfChar( ' ', pIndent + 2 ) + 'Active Child = ' + IntToStr( fActiveChild ));
    end;
  end;
end;

procedure tSigCompoundProperty.SetActiveChild(const pValue: integer);
begin
  if pValue < Children.Count then
  begin
    fActiveChild := pValue;
  end
  else
  begin
    fActiveChild := Children.Count - 1; // recovery mechanism
  end;
  if assigned( fOnActiveChildChange ) then
  begin
    fOnActiveChildChange( self, fActiveChild );
  end;
  if assigned( StringListControlList ) then
  begin
    StringListControlList.Index := pValue;
  end;
  RefreshEditor;
end;

procedure tSigCompoundProperty.SetActiveChildBase(const Value: integer);
begin
  if fChangingMax or AmUndoing or AmRedoing then
  begin
    fPendingActiveChild := Value;
  end
  else if Value <> fActiveChild then
  begin
    SetActiveChild( Value );
    fPendingActiveChild := fActiveChild;
  end;
end;

procedure tSigCompoundProperty.SetChangingMax(const Value: boolean);
begin
  fChangingMax := Value;
  if not Value then
  begin
    if assigned( fOnMaxChange ) then
    begin
      try
        fOnMaxChange( self, fMax );
      except

      end;
    end;
    if fActiveChild <> fPendingActiveChild then
    begin
      SetActiveChild( fPendingActiveChild );
    end;

  end;
end;

procedure tSigCompoundProperty.SetEnabled(const Value: boolean);
var
  i: Integer;
begin
  if fEnabled <> Value then
  begin
    inherited;
    for i := 0 to Children.Count - 1 do
    begin
      Children[ i ].Enabled := Value;
    end;
  end;
end;

procedure tSigCompoundProperty.SetIsDirty(const Value: boolean);
begin
{
  if fIsDirty <> Value then
  begin
    inherited;
    if not Value then
    begin
      Children.IsDirty := Value;
    end;
  end;
}
  inherited;
  if not Value then
  begin
    Children.IsDirty := Value;
  end;
end;

procedure tSigCompoundProperty.SetMax(const Value: integer);
begin
  fMax := Value;
end;

procedure tSigCompoundProperty.SetOnMaxChange(const Value: tSigOnIntegerChange);
begin
  fOnMaxChange := Value;
end;

procedure tSigCompoundProperty.SetSaveMax(const Value: boolean);
begin
  fSaveMax := Value;
end;

procedure tSigCompoundProperty.SetStringListControlList(
  const Value: tStringListControlList);
begin
  fStringListControlList := Value;
end;

procedure tSigCompoundProperty.Swap(const pFrom, pTo: integer);
var
  iNewActiveChild : integer;
begin
  if ActiveChild = pFrom then
  begin
    iNewActiveChild := pTo;
    ActiveChild := -1;
  end
  else if ActiveChild = pTo then
  begin
    iNewActiveChild := pFrom;
    ActiveChild := -1;
  end
  else
  begin
    iNewActiveChild := -1;
  end;


  Children.Swap( pFrom, pTo );
  if iNewActiveChild <> -1 then
  begin
    ActiveChild := iNewActiveChild;
  end;
  if assigned( fOnSwapChild ) then
  begin
    fOnSwapChild( pFrom, pTo );
  end;
end;

procedure tSigCompoundProperty.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  AmUndoing := TRUE;
  try
  case pUndoAction of
    undoValue:
    begin
      inherited;
    end;
    undoChangeMax: ;
    undoAdd,
    undoMove,
    undoSwap2,
    undoInsert2:
    begin
      Children.Undo( pUndoAction, pUndoString );
    end;
    undoDelete2:
    begin
      i := StrToInt( pUndoString );
      UnDelete( i, pUndoAction );
    end;
    undoUndelete2:
    begin
      i := StrToInt( pUndoString );
      Delete( i, pUndoAction );
    end;
    undoSelPos: ;
    undoSelLen: ;
    undoChangeActiveChild:
    begin
      ActiveChild := StrToInt( pUndoString );
    end;
    undoPointer: ;
  end;
  finally
    AmUndoing := FALSE;
  end;
end;

{ tMemoProperty }

function tMemoProperty.Add(const pValue: string): integer;
begin
  ExecuteUndoableAction( self, undoValue, FStrings.Text);
  Result := FStrings.Add( pValue );
  if assigned( Editor ) then
  begin
    Editor.Lines.Text := fStrings.Text;
  end;
  IsDirty := TRUE;
end;

procedure tMemoProperty.AddTo(pTo: TStrings);
var
  i: Integer;
  iLine : string;
begin
  if fStrings.Count > 0 then
  begin
    for i := 0 to fStrings.Count - 1 do
    begin
      iLine := Trim( Strings[ i ]);
      if Length( iLine  ) > 0 then
      begin
        if iLine[ 1 ] = 't' then
        begin
          iLine[ 1 ] := 'T';
        end;
      end;
      pTo.Add( '  ' + iLine );
    end;
    pTo.Add( '' );
  end;
end;

procedure tMemoProperty.AssignFrom(pFrom: TStrings);
begin
  // need to add update function
  if pFrom.Text <> FStrings.Text then
  begin
    if Undoing then
    begin
      ExecuteRedoableAction( self, undoValue, FStrings.Text );
    end
    else if not (Creating or LoadingFromFile) then
    begin
      ExecutePrepareUndoableAction( self, undoValue, FStrings.Text );
      if assigned( fEdit ) then
      begin
        ExecuteUndoableAction( self, undoSelLen, IntToStr( fEdit.SelLength ));
        ExecuteUndoableAction( self, undoSelPos, IntToStr( fEdit.SelStart ));
      end;
      ExecuteUndoableAction( self, undoValue, FStrings.Text );
    end;

    fStrings.Text := pFrom.Text;

    IsDirty := TRUE;
    ExecuteOnChange( self, AmUndoing, AmRedoing );
    if not (AmUndoing or Creating or LoadingFromFile) then
    begin
      ExecuteCompleteUndoableAction( self, undoValue, FStrings.Text );
    end;
  end;
end;

procedure tMemoProperty.AssignTo(pTo: TStrings);
begin
  fChanging := TRUE;
  pTo.Assign( FStrings );
  //pTo.Clear;
  //xAddTo( pTo );
  fChanging := FALSE;
end;

class function tMemoProperty.ClassType: string;
begin
  Result := 'Memo';
end;

procedure tMemoProperty.Clear;
begin
  inherited;
  if assigned( FStrings ) then
  begin
    FStrings.Clear;
  end;
  if assigned( Editor ) then
  begin
    //Editor.Clear;
    Editor.Text := '';
  end;
  IsDirty := TRUE;
end;

procedure tMemoProperty.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iLine : string;
  i : integer;
begin
  { these have the form
    Memo name [( index )] [= value ]
     // line 1
     // Line 2
       ...
    end name
  }
  if pShortFormat then
  begin
    iLine := StringOfChar( ' ', pIndent ) + PropertyName;
  end
  else
  begin
    iLine := StringOfChar( ' ', pIndent ) + ClassType + ' '  + PropertyName;
  end;
  if Indexed then
  begin
    iLine := iLine + '( ' + Index + ' )';
  end;
  if Value <> '' then
  begin
    iLine := iLine + ' = ' + Value;
  end;
  pClipboard.Add( iLine );
  for i := 0 to FStrings.Count - 1 do
  begin
    pClipboard.Add( StringOfChar( ' ', pIndent + 2) + '// ' + Strings[ i ] );
  end;
  pClipboard.Add( StringOfChar( ' ', pIndent) + TerminationString );
  inherited;
end;

constructor tMemoProperty.Create(pPropertyName: string; pOwner : tSigCompoundProperty);
begin
  inherited;
  fStrings := tStringList.Create;

end;

destructor tMemoProperty.Destroy;
begin
  fStrings.Free;
  inherited;
end;

procedure tMemoProperty.OnDestroy;
begin
  if assigned( fEdit ) then
  begin
    // detaching - disable
    fEdit.Enabled := FALSE;
  end;
  inherited;
end;

procedure tMemoProperty.fOnEditChange(Sender: tObject);
begin
  if not fChanging then
  begin
    if assigned( fEdit ) then
    begin
      AssignFrom( fEdit.Lines );
      IsDirty := TRUE;
      if assigned( fOnEditorChange ) then
      begin
        fOnEditorChange( Sender );
      end;
    end;
  end;
end;

function tMemoProperty.GetLines: TStrings;
begin
  Result := fStrings;
end;

function tMemoProperty.GetStrings(const i: integer): string;
begin
  Result := fStrings[ i ];
end;

function tMemoProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
begin
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );

  fStrings.Clear;
  while pLine < pFile.Count do
  begin
    // analyse the line...
    if pFile[ pLine ] = '' then
    begin
      // ignore - only comment lines allowed
      inc( pLine );
    end
    else if SigNETParse ( pFile[ pLine ], SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      inc( pLine );
      if SameText( SigProperty, TerminationString) then
      begin
        // done
        if assigned( fEdit ) then
        begin
          AssignTo( fEdit.Lines );
        end;
        if assigned( fOnEditorChange ) then
        begin
          fOnEditorChange( self );
        end;
        exit;
      end;
      FStrings.Add( SigComment );
    end
    else
    begin
      Result := FALSE;
      if assigned( pErrors ) then
      begin
        pErrors.Add( pLine, 'Syntax error');
      end;
      inc( pLine );
    end;
  end;
  // should not get here
  Result := FALSE;
  if assigned( pErrors ) then
  begin
    pErrors.Add( es_Error, pLine, OwnerFile.Translate( 'Unexpected end of file' ));
  end;
end;

function tMemoProperty.PasteFromClipboard(pClipboard: tStrings; var pLine: integer;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
begin
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );

  fStrings.Clear;
  while pLine < pClipboard.Count do
  begin
    // analyse the line...
    if SigNETParse ( pClipboard[ pLine ], SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      inc( pLine );
      if SameText( SigProperty, TerminationString) then
      begin
        // done
        if assigned( fEdit ) then
        begin
          AssignTo( fEdit.Lines );
        end;
        if assigned( fOnEditorChange ) then
        begin
          fOnEditorChange( self );
        end;
        exit;
      end;
      FStrings.Add( SigComment );
    end
    else
    begin
      Result := FALSE;
      if assigned( pErrors ) then
      begin
        pErrors.Add( pLine, 'Syntax error');
      end;
      inc( pLine );
    end;
  end;
  // should not get here
  Result := FALSE;
  if assigned( pErrors ) then
  begin
    pErrors.Add( es_Error, pLine, OwnerFile.Translate( 'Unexpected end of file' ));
  end;
end;

function tMemoProperty.PrintStructureString: string;
begin
  Result := ClassType + ' ' + PropertyName;
end;

procedure tMemoProperty.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  case pUndoAction of
    undoValue:
    begin
      if assigned( fEdit ) then
      begin
        ExecuteUndoableAction( self, undoSelLen, IntToStr( fEdit.SelLength ));
        ExecuteUndoableAction( self, undoSelPos, IntToStr( fEdit.SelStart ));
        fEdit.Text := pUndoString;
      end
      else
      begin
        ExecuteUndoableAction( self, pUndoAction, FStrings.Text);
        FStrings.Text := pUndoString;
      end;
    end;
    undoSelPos:
    begin
      if assigned( fEdit ) then
      begin
        fEdit.SelStart := StrToInt( pUndoString );
      end;
    end;
    undoSelLen:
    begin
      if assigned( fEdit ) then
      begin
        fEdit.SelLength := StrToInt( pUndoString );
      end;
    end;
  end;
end;

procedure tMemoProperty.Save(pSaveFile: tStrings; pShortFormat : boolean; pIndent: integer);
var
  iLine : string;
  i : integer;
begin
  if SaveWithFile then
  begin
    { these have the form
      Memo name [( index )] [= value ]
       // line 1
       // Line 2
         ...
      end name
    }
    if pShortFormat then
    begin
      iLine := StringOfChar( ' ', pIndent ) + PropertyName;
    end
    else
    begin
      iLine := StringOfChar( ' ', pIndent ) + ClassType + ' '  + PropertyName;
    end;
    if Indexed then
    begin
      iLine := iLine + '( ' + Index + ' )';
    end;
    if Value <> '' then
    begin
      iLine := iLine + ' = ' + Value;
    end;
    pSaveFile.Add( iLine );
    for i := 0 to FStrings.Count - 1 do
    begin
      pSaveFile.Add( StringOfChar( ' ', pIndent + 2) + '// ' + Strings[ i ] );
    end;
    pSaveFile.Add( StringOfChar( ' ', pIndent) + TerminationString );
    inherited;
  end;
end;

procedure tMemoProperty.SetEdit(const Value: tMemo);
begin
  if assigned( fEdit ) then
  begin
    // detaching - disable
    fEdit.Enabled := FALSE;
    // if we hijacked OnChange, return it
    fEdit.OnChange := fOnEditorChange;
  end;
  fEdit := Value;
  if assigned( Value ) then
  begin
    AssignTo( fEdit.Lines );
    fOnEditorChange := fEdit.OnChange;
    fEdit.OnChange := fOnEditChange;
    fEdit.Enabled := TRUE;
  end;
end;

procedure tMemoProperty.SetStrings(const i: integer; const pValue: string);
begin
  if fStrings[ i ] <> pValue then
  begin
    ExecuteUndoableAction( self, undoValue, FStrings.Text);

    fStrings[ i ] := pValue;
    IsDirty := TRUE;
  end;
end;

procedure tMemoProperty.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  AmUndoing := TRUE;
  try
    case pUndoAction of
      undoValue:
      begin
        if assigned( fEdit ) then
        begin
          ExecuteRedoableAction( self, undoSelPos, IntToStr( fEdit.SelStart));
          ExecuteRedoableAction( self, undoSelLen, IntToStr( fEdit.SelLength));
          fEdit.Text := pUndoString;
        end
        else
        begin
          ExecuteRedoableAction( self, pUndoAction, FStrings.Text);
          FStrings.Text := pUndoString;
        end;
      end;
      undoSelPos:
      begin
        if assigned( fEdit ) then
        begin
          fEdit.SelStart := StrToInt( pUndoString );
        end;
      end;
      undoSelLen:
      begin
        if assigned( fEdit ) then
        begin
          fEdit.SelLength := StrToInt( pUndoString );
        end;
      end;
    end;
  finally
    AmUndoing := FALSE;
  end;
end;

{ tSigArrayProperty }

function tSigArrayProperty.AddNewChild : tSigBaseProperty;
begin
  Result := CreateChild( 'Item', IntToStr( Count ) );
  if assigned ( Result ) then
  begin
    fMax := Count - 1;
    ActiveChild := fMax;
    if assigned( fOnAddChild ) then
    begin
      fOnAddChild( Result );
    end;
  end
  else
  begin
    raise  exception.Create( 'Unable to create child' );
  end;
end;

class function tSigArrayProperty.ChildMustExist: boolean;
begin
  Result := FALSE;
end;

class function tSigArrayProperty.ClassType: string;
begin
  Result := 'Array';
end;

procedure tSigArrayProperty.Clear;
var
  i: Integer;
begin
  ActiveChild := -1;
  if Creating then
  begin
    // creating array

  end
  else
  begin
    // Genuine Clear!
    if ClearRemovesChildren then
    begin
      Max := -1;
    end
    else
    begin
      for i := 0 to Max do
      begin
        Children[ i ].Clear;
      end;
    end;
  end;
end;

procedure tSigArrayProperty.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iLine : string;
  i: Integer;
begin
  // these have the form
  // object name [( index )] [= value ]
  // ...
  // end name
  if pShortFormat then
  begin
    iLine := StringOfChar( ' ', pIndent ) + PropertyName;
  end
  else
  begin
    iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
  end;
  if Indexed then
  begin
    iLine := iLine + '( ' + Index + ' )';
  end;
  if Value <> '' then
  begin
    iLine := iLine + ' = ' + Value;
  end;
  pClipboard.Add( iLine );
  SaveOthers( pClipboard, pIndent );
  for i := 0 to Max do
  begin
    Children[ i ].CopyToClipboard( pClipboard, pShortFormat, pIndent + 2 );
  end;
  pClipboard.Add( StringOfChar( ' ', pIndent) + TerminationString );
end;

constructor tSigArrayProperty.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fActiveChild := -1;
  fMax := -1;
  SaveActiveChild := FALSE;
end;

procedure tSigArrayProperty.Delete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  inherited;
  Reindex;
end;

procedure tSigArrayProperty.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing: boolean);
var
  i: Integer;
begin
  inherited;
  if assigned( StringListControlList ) then
  begin
    for i := 0 to Max do
    begin
      if Entry[ i ].ObjectAffectsStringListText( pChangedObject ) then
      begin
        StringListControlList.ChangeString( i, pChangedObject.StringListText );
        break;
      end;
    end;
  end;
end;

function tSigArrayProperty.GetItem(const i: integer): tSigBaseProperty;
begin
  result := Children.Item[ i ];
end;

function tSigArrayProperty.InsertNewChild(
  const AtLoc: integer): tSigBaseProperty;
begin
  Result := CreateChild( 'Item', IntToStr( AtLoc ) );
  if assigned ( Result ) then
  begin
    fMax := Count - 1;
    ActiveChild := fMax;
    Reindex;
    if assigned( fOnAddChild ) then
    begin
      fOnAddChild( Result );
    end;
  end
  else
  begin
    raise  exception.Create( 'Unable to create child' );
  end;
end;

function tSigArrayProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iActiveChild : integer;
label
  Loop;
begin
  iActiveChild := -1;
Loop:
  if SigNETParse ( pFile[ pLine ], SigProperty, SigIndex, SigValue, SigComment) then
  begin
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      Max := StrToInt( SigValue );
      goto Loop;
    end
    else if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      goto Loop;
    end;
  end;
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
  ActiveChild := iActiveChild;
  RedisplayStringControlList;
end;

function tSigArrayProperty.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iActiveChild : integer;
label
  Loop;
begin

  iActiveChild := -1;
Loop:
  if SigNETParse ( pClipboard[ pLine ], SigProperty, SigIndex, SigValue, SigComment) then
  begin
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      Max := StrToInt( SigValue );
      goto Loop;
    end
    else if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      goto Loop;
    end;
  end;
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );
  ActiveChild := iActiveChild;
end;

procedure tSigArrayProperty.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  case pUndoAction of
    undoChangeMax,
    undoValue:
    begin
      inherited;
    end;
    undoMove,
    undoSwap2,
    undoAdd,
    undoInsert2,
    undoDelete2,
    undoUnDelete2:
    begin
      inherited;
      Reindex;
    end;
    undoChangeActiveChild:
    begin
      ActiveChild := StrToInt( pUndoString );
    end;
  end;
end;

procedure tSigArrayProperty.Reindex;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Entry[ i ].Index := IntToStr( i );
  end;
  ActiveChild := -1;
end;

procedure tSigArrayProperty.Save(pSaveFile: tStrings; pShortFormat: boolean;
  pIndent: integer);
var
  iLine : string;
  i: Integer;
begin
  if SaveWithFile then
  begin
    // these have the form
    // object name [( index )] [= value ]
    // ...
    // end name
    if pShortFormat then
    begin
      iLine := StringOfChar( ' ', pIndent ) + PropertyName;
    end
    else
    begin
      iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
    end;
    if Indexed then
    begin
      iLine := iLine + '( ' + Index + ' )';
    end;
    if Value <> '' then
    begin
      iLine := iLine + ' = ' + Value;
    end;
    pSaveFile.Add( iLine );
    SaveOthers( pSaveFile, pIndent );
    for i := 0 to Max do
    begin
      Children[ i ].Save( pSaveFile, pShortFormat, pIndent + 2 );
    end;
    pSaveFile.Add( StringOfChar( ' ', pIndent) + TerminationString );
    IsDirty := FALSE;
  end;
end;

procedure tSigArrayProperty.SaveOthers(pSaveFile: tStrings; pIndent: integer);
begin
  inherited;
  // fMax
  pSaveFile.Add( StringOfChar( ' ', pIndent + 2 ) + 'Max = ' + IntToStr( fMax ));
end;

procedure tSigArrayProperty.RedisplayStringControlList;
var
  i: Integer;
begin
  if assigned( StringListControlList ) then
  begin
    StringListControlList.ClearStrings;
    for i := 0 to Max do
    begin
      StringListControlList.AddString(  Entry[ i ].StringListText );
    end;
    StringListControlList.Index := ActiveChild;
  end;
end;

procedure tSigArrayProperty.SetMax(const Value: integer);
var
  i: Integer;
begin
  if fMax <> Value then
  begin
    for i := fMax downto Value + 1 do
    begin
      // removing - in reverse order!
      Delete( i, undoDelete2 );
    end;

    if Value >= 0 then
    begin
      while Count <= Value do
      begin
        AddNewChild;
      end;
    end;
    fMax := Value;
    RedisplayStringControlList;
    if ActiveChild > Max then
    begin
      ActiveChild := fMax;
    end;
    IsDirty := TRUE;

  end;
end;

procedure tSigArrayProperty.UnDelete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  inherited;
  fMax := Count - 1;
  if pIndex <= fMax then
  begin
    ActiveChild := pIndex;
  end;

end;

procedure tSigArrayProperty.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  AmUndoing := TRUE;
  try
    case pUndoAction of
      undoValue:
      begin
        inherited;
      end;
      undoAdd,
      undoMove,
      undoSwap2,
      undoDelete2,
      undoUndelete2,
      undoInsert2:
      begin
        inherited;
        Reindex;
      end;
      undoChangeMax: ;
      undoSelPos: ;
      undoSelLen: ;
      undoChangeActiveChild:
      begin
        ActiveChild := StrToInt( pUndoString );
      end;
      undoPointer: ;
    end;
  finally
    AmUndoing := FALSE;
  end;
end;

{ tSigFileProperty }

procedure tSigFileProperty.AddError(const pRow, pCol: integer;
  const pErrorText: string; pObject: tObject);
begin
  ErrorList.Add( pRow, pCol, pErrorText, pObject );
end;

procedure tSigFileProperty.AddError(const pSeverity: tErrorSeverity; const pRow,
  pCol: integer; const pErrorText: string; pObject: tObject);
begin
  ErrorList.Add( pSeverity, pRow, pCol, pErrorText, pObject );
end;

procedure tSigFileProperty.AddHelpMenu;
begin
  // added because it is always at the far right
  if assigned( fMainMenu ) then
  begin
    fHelpMenu := tMenuItem.Create( fMainMenu );
{$IFDEF FMX_SIGFILE}
    fHelpMenu.Text := TranslateValue( '&Help' );
    fMainMenu.AddObject( fHelpMenu );
{$ELSE}
    fHelpMenu.Caption := TranslateValue( '&Help' );
    fMainMenu.Items.Add( fHelpMenu );
{$ENDIF}
    BuildHelpMenuEntries( fHelpMenu );
  end
  else
  begin
    raise exception.Create('Cannot create Edit menu - Main Menu not defined');
  end;
end;

procedure tSigFileProperty.BuildDeviceMenuEntries(const pDeviceMenu: tMenuItem);
begin
  if assigned( pDeviceMenu ) then
  begin
    fDeviceCompare := tMenuItem.Create( pDeviceMenu );
    with fDeviceCompare do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Compare' );
{$ELSE}
      Caption := TranslateValue( '&Compare' );
{$ENDIF}
      OnClick := fDeviceCompareClick;
      if assigned( fOnCompareDevice ) then
      begin
        ShortCut := TextToShortcut( 'Shft+F2' );
      end;
    end;
{$IFDEF FMX_SIGFILE}
    pDeviceMenu.AddObject( fDeviceCompare );
{$ELSE}
    pDeviceMenu.Add( fDeviceCompare );
{$ENDIF}

    fDeviceLoad := tMenuItem.Create( pDeviceMenu );
    with fDeviceLoad do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Load from Device' );
{$ELSE}
      Caption := TranslateValue( '&Load from Device' );
{$ENDIF}
      OnClick := fDeviceLoadFromClick;
      if assigned( fOnLoadFromDevice ) then
      begin
        ShortCut := TextToShortcut( 'Shft+F3' );
      end;
    end;
{$IFDEF FMX_SIGFILE}
    pDeviceMenu.AddObject( fDeviceLoad );
{$ELSE}
    pDeviceMenu.Add( fDeviceLoad );
{$ENDIF}

    fDeviceSave := tMenuItem.Create( pDeviceMenu );
    with fDeviceSave do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Save to Device' );
{$ELSE}
      Caption := TranslateValue( '&Save to Device' );
{$ENDIF}
      OnClick := fDeviceSaveToClick;
      if assigned( fOnLoadFromDevice ) then
      begin
        ShortCut := TextToShortcut( 'Shft+F4' );
      end;
    end;
{$IFDEF FMX_SIGFILE}
    pDeviceMenu.AddObject( fDeviceSave );
{$ELSE}
    pDeviceMenu.Add( fDeviceSave );
{$ENDIF}

    SetupDeviceMenu();

  end
  else
  begin
    raise exception.Create('Cannot Build Edit menu elements - Edit Menu not defined');
  end;
end;

procedure tSigFileProperty.BuildEditMenuEntries(const pEditMenu: tMenuItem);
begin
  if assigned( pEditMenu ) then
  begin
    if fUsesUndoRedoMenu then
    begin
      fEditUndo := tMenuItem.Create( pEditMenu );
      with fEditUndo do
      begin
{$IFDEF FMX_SIGFILE}
        Text := TranslateValue( '&Undo' );
{$ELSE}
        Caption := TranslateValue( '&Undo' );
{$ENDIF}
        OnClick := fEditUndoClick;
        ShortCut := TextToShortcut( 'Alt+BkSp' );
      end;
{$IFDEF FMX_SIGFILE}
      pEditMenu.AddObject( fEditUndo );
{$ELSE}
      pEditMenu.Add( fEditUndo );
{$ENDIF}
      fEditRedo := tMenuItem.Create( pEditMenu );
      with fEditRedo do
      begin
{$IFDEF FMX_SIGFILE}
        Text := TranslateValue( '&Redo' );
{$ELSE}
        Caption := TranslateValue( '&Redo' );
{$ENDIF}
        OnClick := fEditRedoClick;
        ShortCut := TextToShortcut( 'Shift+Alt+BkSp' );
      end;
{$IFDEF FMX_SIGFILE}
    pEditMenu.AddObject( fEditRedo );
{$ELSE}
    pEditMenu.Add( fEditRedo );
{$ENDIF}
    end;
  end
  else
  begin
    raise exception.Create('Cannot Build Edit menu elements - Edit Menu not defined');
  end;
end;

procedure tSigFileProperty.BuildFileMenuEntries( const pFileMenu : tMenuItem );
var
  i : integer;
begin
  if assigned( pFileMenu ) then
  begin
    fFileNew := tMenuItem.Create( pFileMenu );
    with fFileNew do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&New' );
{$ELSE}
      Caption := TranslateValue( '&New' );
{$ENDIF}
      OnClick := fFileNewClick;
      ShortCut := TextToShortcut( 'Ctrl+N' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFileNew );
{$ELSE}
    pFileMenu.Add( fFileNew );
{$ENDIF}

    fFileLoad := tMenuItem.Create( pFileMenu );
    with fFileLoad do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Open' );
{$ELSE}
      Caption := TranslateValue( '&Open' );
{$ENDIF}
      OnClick := fFileLoadClick;
      ShortCut := TextToShortcut( 'Ctrl+O' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFileLoad );
{$ELSE}
    pFileMenu.Add( fFileLoad );
{$ENDIF}

    if fTemplateIndex > 0 then
    begin
      fFileLoadFromTemplate := tMenuItem.Create( pFileMenu );
      with fFileLoadFromTemplate do
      begin
{$IFDEF FMX_SIGFILE}
        Text := TranslateValue( 'Load &Template' );
{$ELSE}
        Caption := TranslateValue( 'Load &Template' );
{$ENDIF}
        OnClick := fFileLoadFromTemplateClick;
      end;
{$IFDEF FMX_SIGFILE}
      pFileMenu.AddObject( fFileLoadFromTemplate );
{$ELSE}
      pFileMenu.Add( fFileLoadFromTemplate );
{$ENDIF}
    end;

    fFileSave := tMenuItem.Create( pFileMenu );
    with fFileSave do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Save' );
{$ELSE}
      Caption := TranslateValue( '&Save' );
{$ENDIF}
      OnClick := fFileSaveClick;
      ShortCut := TextToShortcut( 'Ctrl+S' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFileSave );
{$ELSE}
    pFileMenu.Add( fFileSave );
{$ENDIF}

    fFileSaveAs := tMenuItem.Create( pFileMenu );
    with fFileSaveAs do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( 'Save &As' );
{$ELSE}
      Caption := TranslateValue( 'Save &As' );
{$ENDIF}
      OnClick := fFileSaveAsClick;
      //ShortCut := TextToShortcut( 'Alt+F5' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFileSaveAs );
{$ELSE}
    pFileMenu.Add( fFileSaveAs );
{$ENDIF}

    if fTemplateIndex > 0 then
    begin
      fFileSaveAsTemplate := tMenuItem.Create( pFileMenu );
      with fFileSaveAsTemplate do
      begin
{$IFDEF FMX_SIGFILE}
        Text := TranslateValue( 'Save As Template' );
{$ELSE}
        Caption := TranslateValue( 'Save As Template' );
{$ENDIF}
        OnClick := fFileSaveAsTemplateClick;
      end;
{$IFDEF FMX_SIGFILE}
      pFileMenu.AddObject( fFileSaveAsTemplate );
{$ELSE}
      pFileMenu.Add( fFileSaveAsTemplate );
{$ENDIF}
    end;

    fFilePrint := tMenuItem.Create( pFileMenu );
    with fFilePrint do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&Print...' );
{$ELSE}
      Caption := TranslateValue( '&Print...' );
{$ENDIF}
      OnClick := fFilePrintClick;
      ShortCut := TextToShortcut( 'Ctrl+P' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFilePrint );
{$ELSE}
    pFileMenu.Add( fFilePrint );
{$ENDIF}

    fFilePrintPreview := tMenuItem.Create( pFileMenu );
    with fFilePrintPreview do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( 'P&rint Preview' );
{$ELSE}
      Caption := TranslateValue( 'P&rint Preview' );
{$ENDIF}
      OnClick := fFilePrintPreviewClick;
      //ShortCut := TextToShortcut( 'Ctrl+P' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFilePrintPreview );
{$ELSE}
    pFileMenu.Add( fFilePrintPreview );
{$ENDIF}

    fFilePrinterSetup := tMenuItem.Create( pFileMenu );
    with fFilePrinterSetup do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( 'P&rinter Setup...' );
{$ELSE}
      Caption := TranslateValue( 'P&rinter Setup...' );
{$ENDIF}
      OnClick := fFilePrinterSetupClick;
      //ShortCut := TextToShortcut( 'Ctrl+P' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFilePrinterSetup );
{$ELSE}
    pFileMenu.Add( fFilePrinterSetup );
{$ENDIF}

{$IFDEF FMX_SIGFILE}
{$ELSE}
    i := pFileMenu.InsertNewLineBefore( fFilePrint );
    fFileLine0 := pFileMenu.Items[ i ];
{$ENDIF}

    SetupPrinterMenu();

    fFileExit := tMenuItem.Create( pFileMenu );
    with fFileExit do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( 'E&xit' );
{$ELSE}
      Caption := TranslateValue( 'E&xit' );
{$ENDIF}
      OnClick := fFileExitClick;
      ShortCut := TextToShortcut( 'Ctrl+Alt+F4' );
    end;
{$IFDEF FMX_SIGFILE}
    pFileMenu.AddObject( fFileExit );
{$ELSE}
    pFileMenu.Add( fFileExit );
{$ENDIF}

{$IFDEF FMX_SIGFILE}
{$ELSE}
    i := pFileMenu.InsertNewLineBefore( fFileExit );
    fFileLine1 := pFileMenu.Items[ i ];
{$ENDIF}

    for i := 0 to 9 do
    begin
      fFileHistory[ i ]  := tMenuItem.Create( pFileMenu );
      with fFileHistory[ i ] do
      begin
        Tag := i;
        OnClick := fFileOnHistoryClick;
      end;
{$IFDEF FMX_SIGFILE}
      pFileMenu.AddObject( fFileHistory[ i ]);
{$ELSE}
      pFileMenu.Add( fFileHistory[ i ]);
{$ENDIF}
    end;
    SetupHistory( self );

{$IFDEF FMX_SIGFILE}
{$ELSE}
    i := pFileMenu.InsertNewLineAfter( fFileExit );
    fFileLine2 := pFileMenu.Items[ i ];
{$ENDIF}


  end
  else
  begin
    raise exception.Create('Cannot Build File menu elements - File Menu not defined');
  end;
end;

procedure tSigFileProperty.BuildHelpMenuEntries(const pHelpMenu: tMenuItem);
begin
  if assigned( pHelpMenu ) then
  begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
    fHelpContents := tMenuItem.Create( pHelpMenu );
    with fHelpContents do
    begin
      Caption := TranslateValue( '&Contents' );
      OnClick := fHelpContentsClick;
      if Application.HelpFile = '' then
      begin
        if FileExists( ChangeFileExt( Application.ExeName, '.chm' )) then
        begin
          Application.HelpFile := ChangeFileExt( Application.ExeName, '.chm' );
        end;
      end;
      if Application.HelpFile <> '' then
      begin
        ShortCut := TextToShortcut( 'Shift+F1' );
        Visible := TRUE;
      end
      else
      begin
        Visible := FALSE;
      end;
    end;
    pHelpMenu.Add( fHelpContents );

    fHelpContext := tMenuItem.Create( pHelpMenu );
    with fHelpContext do
    begin
      ShortCut := TextToShortcut( 'F1' );
      OnClick := fHelpContextClick;
      Visible := FALSE;
    end;
    pHelpMenu.Add( fHelpContext );
{$ENDIF}

    fHelpAbout := tMenuItem.Create( pHelpMenu );
    with fHelpAbout do
    begin
{$IFDEF FMX_SIGFILE}
      Text := TranslateValue( '&About...' );
{$ELSE}
      Caption := TranslateValue( '&About...' );
{$ENDIF}
      OnClick := fHelpAboutClick;
    end;
{$IFDEF FMX_SIGFILE}
    pHelpMenu.AddObject( fHelpAbout );
{$ELSE}
    pHelpMenu.Add( fHelpAbout );
{$ENDIF}

    SetupHelp();
  end
  else
  begin
    raise exception.Create('Cannot Build Help menu elements - Help Menu not defined');
  end;
end;

procedure tSigFileProperty.CheckErrors(var pErrorCount, pWarningCount,
  pHintCount: integer; pErrors: tErrorList);
begin
  pErrors.Clear;
  pErrorCount := 0;
  pWarningCount := 0;
  pHintCount := 0;
  inherited;

end;

class function tSigFileProperty.ClassType: string;
begin
  Result := 'File';
end;

procedure tSigFileProperty.Clear;
begin
  inherited;

end;

procedure tSigFileProperty.ClearErrorList;
begin
  ErrorList.Clear;
  if assigned( fOnClearErrorList ) then
  begin
    fOnClearErrorList( self );
  end;
end;

constructor tSigFileProperty.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fUsesEditMenu := TRUE;
  fUsesUndoRedoMenu := TRUE;

end;

procedure tSigFileProperty.DecDevLoadingCount;
begin
  dec( fDevLoadingCount );
end;

destructor tSigFileProperty.Destroy;
begin
  fErrorList.Free;

  inherited;
end;

procedure tSigFileProperty.ExecuteAfterLoadActions;
var
  i : integer;
begin
  if assigned( fAfterLoadList ) then
  begin
    for i := 0 to fAfterLoadList.Count - 1 do
    begin
      with fAfterLoadList.Items[ i ] as tSigBaseProperty do
      begin
        DoAfterLoad;
      end;
    end;
    FreeAndNil( fAfterLoadList );
  end;
end;

procedure tSigFileProperty.fDeviceCompareClick(Sender: tObject);
begin
  if assigned( FOnCompareDevice ) then
  begin
    FOnCompareDevice( Sender );
  end;
end;

procedure tSigFileProperty.fDeviceLoadFromClick(Sender: tObject);
begin
  if assigned( FOnLoadFromDevice ) then
  begin
    FOnLoadFromDevice( Sender );
  end;
end;

procedure tSigFileProperty.fDeviceSaveToClick(Sender: tObject);
begin
  if assigned( FOnSaveToDevice ) then
  begin
    FOnSaveToDevice( Sender );
  end;
end;

procedure tSigFileProperty.fEditRedoClick(Sender: tObject);
begin
  if assigned( fonUndoClick ) then
  begin
    fOnRedoClick( Sender );
  end;
end;

procedure tSigFileProperty.fEditUndoClick(Sender: tObject);
begin
  if assigned( fonUndoClick ) then
  begin
    fOnUndoClick( Sender );
  end;
end;

procedure tSigFileProperty.fFileExitClick(Sender: tObject);
begin
  Application.MainForm.Close;
end;

procedure tSigFileProperty.fFileLoadClick(Sender: tObject);
begin
  Load();
end;

procedure tSigFileProperty.fFileLoadFromTemplateClick(Sender: tObject);
begin
  LoadFromTemplate();
end;

procedure tSigFileProperty.fFileNewClick(Sender: tObject);
begin
  New();

end;

procedure tSigFileProperty.fFileOnHistoryClick(Sender: tObject);
var
  iMenuItem : tComponent;
  iNewFile : string;
begin
  iMenuItem := Sender as tComponent;
  iNewFile := fSigSaveDialog.History[ iMenuItem.Tag ];
  //iNewFile := fSigSaveDialog.SigRegistry.History[ iMenuItem.Tag ];
  // for this to be entered, SigRegistry must be defined, so...
  if fSigSaveDialog.SaveIfDirty then
  begin
    fSigSaveDialog.Load( iNewFile );
    Children.ClearUndoList;
  end;
  IsDirty := FALSE;
end;

procedure tSigFileProperty.fFilePrintClick(Sender: tObject);
begin
  if assigned( fOnPrint ) then
  begin
    fOnPrint( Sender );
  end;
end;

procedure tSigFileProperty.fFilePrinterSetupClick(Sender: tObject);
begin
  if assigned( fOnPrinterSetup ) then
  begin
    fOnPrinterSetup( Sender );
  end;
end;

procedure tSigFileProperty.fFilePrintPreviewClick(Sender: tObject);
begin
  if assigned( fOnPrintPreview ) then
  begin
    fOnPrintPreview( Sender );
  end;
end;

procedure tSigFileProperty.fFileSaveAsClick(Sender: tObject);
begin
  SaveAs();
end;

procedure tSigFileProperty.fFileSaveAsTemplateClick(Sender: tObject);
begin
  SaveAsTemplate();
end;

procedure tSigFileProperty.fFileSaveClick(Sender: tObject);
begin
  Save();
end;

procedure tSigFileProperty.fFormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if assigned( fFormSaveCanClose ) then
  begin
    fFormSaveCanClose( Sender, CanClose );
  end;
  if CanClose then
  begin
    if assigned( fSigSaveDialog ) then
    begin
      CanClose := fSigSaveDialog.SaveIfDirty;
    end;
  end;
  if CanClose then
  begin
{$IFDEF FMX_SIGFILE}
  // for now autorestore only available in windows environment
{$ELSE}
    if SaveFormStateOnExit then
    begin
      if assigned( fSigSaveDialog) then
      begin
        if assigned( fSigSaveDialog.SigRegistry ) then
        begin
          fSigSaveDialog.SigRegistry.StoreMainWindowParms;
        end;
      end;
    end;
{$ENDIF}
  end;
end;

procedure tSigFileProperty.fHelpAboutClick(Sender: tObject);
begin
  if assigned( fAboutForm ) then
  begin
    fAboutForm.ShowModal;
  end;
end;

procedure tSigFileProperty.fHelpContentsClick(Sender: tObject);
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  Application.HelpShowTableOfContents;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigFileProperty.fHelpContextClick(Sender: tObject);
begin
  Application.HelpContext( fHelpContextID );
end;
{$ENDIF}

function tSigFileProperty.GetErrorList: tErrorList;
begin
  if not assigned( fErrorList ) then
  begin
    fErrorList := tErrorList.Create;
  end;
  Result := fErrorList;
end;

function tSigFileProperty.GetIsTemplate: boolean;
begin
  if fTemplateExtension = '' then
  begin
    Result := fIsTemplate;
  end
  else if SameText( ExtractFileExt( fFileName ), '.' + fTemplateExtension) then
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function tSigFileProperty.GetLoadingFromDevice: tSigLoadAction;
begin
  if fDevLoadingCount > 0 then
  begin
    Result := laLoadingFromDevice;
  end
  else
  begin
    Result := inherited;
  end;
end;

function tSigFileProperty.GetMenuItemFileHistory(const i: integer): tMenuItem;
begin
  Result := fFileHistory[ i ];
end;

function tSigFileProperty.GetOnEditRedoClick: tNotifyEvent;
begin
  Result := fEditRedoClick;
end;

function tSigFileProperty.GetOnEditUndoClick: tNotifyEvent;
begin
  Result := fEditUndoClick;
end;

function tSigFileProperty.GetOnFileExitClick: tNotifyEvent;
begin
  Result := fFileExitClick;
end;

function tSigFileProperty.GetOnFileLoadClick: tNotifyEvent;
begin
  Result := fFileLoadClick;
end;

function tSigFileProperty.GetOnFileNewClick: tNotifyEvent;
begin
  Result := fFileNewClick;
end;

function tSigFileProperty.GetOnFileOnHistoryClick: tNotifyEvent;
begin
  result := fFileOnHistoryClick;
end;

function tSigFileProperty.GetOnFileSaveAsClick: tNotifyEvent;
begin
  Result := fFileSaveAsClick;
end;

function tSigFileProperty.GetOnFileSaveClick: tNotifyEvent;
begin
  result := fFileSaveClick;
end;

function tSigFileProperty.GetOnHelpAboutClick: tNotifyEvent;
begin
  Result := fHelpAboutClick;
end;

function tSigFileProperty.GetOnHelpContentsClick: tNotifyEvent;
begin
  Result := fHelpContentsClick;
end;

function tSigFileProperty.GetUsesUndoRedoMenu: boolean;
begin
  Result := fUsesUndoRedoMenu and fUsesEditMenu;
end;

procedure tSigFileProperty.IncDevLoadingCount;
begin
  inc( fDevLoadingCount );
end;

procedure tSigFileProperty.InsertDeviceMenu;
begin
  if assigned( fMainMenu ) then
  begin
    fDeviceMenu := tMenuItem.Create( fMainMenu );
{$IFDEF FMX_SIGFILE}
    fDeviceMenu.Text := TranslateValue( '&Device' );
    fMainMenu.InsertObject( 2, fDeviceMenu );
{$ELSE}
    fDeviceMenu.Caption := TranslateValue( '&Device' );
    fMainMenu.Items.Insert( 2, fDeviceMenu );
{$ENDIF}
    BuildDeviceMenuEntries( fDeviceMenu );
  end
  else
  begin
    raise exception.Create('Cannot create Edit menu - Main Menu not defined');
  end;
end;

procedure tSigFileProperty.InsertEditMenu;
begin
  if assigned( fMainMenu ) then
  begin
    if fUsesEditMenu then
    begin
      fEditMenu := tMenuItem.Create( fMainMenu );
{$IFDEF FMX_SIGFILE}
      fEditMenu.Text := TranslateValue( '&Edit' );
      fMainMenu.InsertObject( 1, fEditMenu );
{$ELSE}
      fEditMenu.Caption := TranslateValue( '&Edit' );
      fMainMenu.Items.Insert( 1, fEditMenu );
{$ENDIF}
      BuildEditMenuEntries( fEditMenu );
    end;
  end
  else
  begin
    raise exception.Create('Cannot create Edit menu - Main Menu not defined');
  end;
end;

procedure tSigFileProperty.InsertFileMenu;
begin
  if assigned( fMainMenu ) then
  begin
    fFileMenu := tMenuItem.Create( fMainMenu );
{$IFDEF FMX_SIGFILE}
    fFileMenu.Text := TranslateValue( '&File' );
    fMainMenu.InsertObject( 0, fFileMenu );
{$ELSE}
    fFileMenu.Caption := TranslateValue( '&File' );
    fMainMenu.Items.Insert( 0, fFileMenu );
{$ENDIF}
    BuildFileMenuEntries( fFileMenu );
  end
  else
  begin
    raise exception.Create('Cannot create File menu - Main Menu not defined');
  end;
end;

function tSigFileProperty.Load( const pFileName : string; const pIndex : integer ) : boolean;
begin
  LoadingFromFile := TRUE;
  try
    if assigned( fSigSaveDialog ) then
    begin
      fSigSaveDialog.FilterIndex := pIndex;
      if pFileName = '' then
      begin
        Result := fSigSaveDialog.Load;
      end
      else
      begin
        Result := fSigSaveDialog.Load( pFileName );
      end;
      exit;
    end
    else
    begin
      Result := TRUE;
      SigSaveDialogLoad( self, Result, pFileName );
    end;

    ExecuteAfterLoadActions;

    if assigned( fOnLoad ) then
    begin
      fOnLoad( self, Result, fFileName );
    end;

    Children.ClearUndoList;
  finally
    LoadLine( 100, 100 );
    LoadingFromFile := FALSE;
    IsDirty := FALSE;
    fIsTemplate := FALSE; // only used if template extension not specified
  end;
end;

function tSigFileProperty.LoadFromTemplate( const pFileName : string ) : boolean;
begin
  LoadingFromFile := TRUE;
  LoadingFromTemplate := TRUE;
  try
    if assigned( fSigSaveDialog ) then
    begin
      fSigSaveDialog.FilterIndex := fTemplateIndex;
      if pFileName = '' then
      begin
        Result := fSigSaveDialog.Load;
      end
      else
      begin
        Result := fSigSaveDialog.Load( pFileName );
      end;
      exit;
    end
    else
    begin
      Result := TRUE;
      SigSaveDialogLoad( self, Result, pFileName );
    end;

    ExecuteAfterLoadActions;

    if assigned( fOnLoad ) then
    begin
      fOnLoad( self, Result, fFileName );
    end;

    Children.ClearUndoList;
  finally
    LoadLine( 100, 100 );
    LoadingFromFile := FALSE;
    LoadingFromTemplate := FALSE;
    IsDirty := FALSE;
    fFileName := '';
    fIsTemplate := TRUE; // only used if template extension not specified
    SetCaption;
  end;
end;

function tSigFileProperty.New: boolean;
begin
  //NewInternal();
  if fTemplateFile <> '' then
  begin
    if FileExists( fTemplateFile ) then
    begin
      Result := LoadFromTemplate( fTemplateFile );
    end
    else
    begin
      Result := NewInternal();
    end;
  end
  else
  begin
    Result := NewInternal();
  end;
end;

function tSigFileProperty.NewInternal : boolean;
begin
  Result := SaveIfDirty( ShortFormat );
  if Result then
  begin
    if assigned( fOnNew ) then
    begin
      fOnNew( self );
    end;
    Clear;
    fFileName := '';
    //SetCaption;
    Children.ClearUndoList();
    IsDirty := FALSE;
  end;
end;

procedure tSigFileProperty.RegisterAfterLoadEntry(const pObject : tSigBaseProperty);
begin
  if not assigned( fAfterLoadList ) then
  begin
    fAfterLoadList := tObjectList.Create( FALSE );
  end;
  fAfterLoadList.Add( pObject )
end;

function tSigFileProperty.Save( pShortFormat: boolean): boolean;
begin
  ShortFormat := pShortFormat;
  if IsTemplate then
  begin
    SaveAs(); // do not allow direct save of templates!
    exit;
  end
  else if assigned( fSigSaveDialog ) then
  begin
    fSigSaveDialog.FilterIndex := 1;
    Result := fSigSaveDialog.Save( FileName );
  end
  else
  begin
    Result := TRUE;
    SigSaveDialogSave( self, Result, FileName );
  end;
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigFileProperty.Save(pTreeNodes: tTreeNodes): tTreeNode;
var
  iText : string;
begin
  pTreeNodes.Clear;
  iText := ClassType + ' ' + PropertyName;
  if Index <> '' then
  begin
    iText := iText + '( ' + Index + ' )';
  end;
  if Value <> '' then
  begin
    iText := iText + ' = ' + Value;
  end;
  Result := pTreeNodes.AddChildObject( nil, iText, self );
  Result := inherited Save( pTreeNodes, Result );
end;
{$ENDIF}

function tSigFileProperty.SaveAs( const pFileName : string;pShortFormat: boolean): boolean;
begin
  ShortFormat := pShortFormat;
  if assigned( fSigSaveDialog ) then
  begin
    fSigSaveDialog.FilterIndex := 1;
    if DefaultExtension <> '' then
    begin
      fSigSaveDialog.DefaultExt := DefaultExtension;
    end;
    if pFileName = '' then
    begin
      Result := fSigSaveDialog.SaveAs( fFileName );
    end
    else
    begin
      Result := fSigSaveDialog.SaveAs( pFileName );
    end;
  end
  else
  begin
    if pFileName <> '' then
    begin
      fFileName := pFileName;
    end;
    SigSaveDialogSave( self, Result, fFileName );
  end;
end;

function tSigFileProperty.SaveAsTemplate( const pFileName : string;pShortFormat: boolean): boolean;
var
  iFileName : string;
begin
  ShortFormat := pShortFormat;
  if assigned( fSigSaveDialog ) then
  begin
    fSigSaveDialog.FilterIndex := fTemplateIndex;
    if TemplateExtension <> '' then
    begin
      fSigSaveDialog.DefaultExt := TemplateExtension;
    end;
    if pFileName = '' then
    begin
      Result := fSigSaveDialog.SaveAs( fFileName );
    end
    else
    begin
      iFileName := pFileName;
      if fTemplateExtension <> '' then
      begin
        iFileName := ChangeFileExt( pFileName, '.' + fTemplateExtension );
      end
      else
      begin
        iFileName := pFileName;
      end;
      Result := fSigSaveDialog.SaveAs( iFileName );
    end;
  end
  else
  begin
    if pFileName <> '' then
    begin
      if fTemplateExtension <> '' then
      begin
        fFileName := ChangeFileExt( pFileName, '.' + fTemplateExtension );
      end
      else
      begin
        fFileName := pFileName;
      end;
    end;
    SigSaveDialogSave( self, Result, fFileName );
  end;
end;

function tSigFileProperty.SaveIfDirty(pShortFormat: boolean): boolean;
begin
  Result := TRUE;
  if IsDirty then
  begin
    if assigned( fSigSaveDialog ) then
    begin
      Result := fSigSaveDialog.SaveIfDirty;
    end
    else
    begin
      Save( pShortFormat );
    end;
  end;
end;

procedure tSigFileProperty.SetAboutForm(const Value: tForm);
begin
  fAboutForm := Value;
  SetupHelp();
end;

procedure tSigFileProperty.SetCaption;
var
  iCaption : string;
begin
  if assigned( fEdit ) then
  begin
    iCaption := BaseCaption + ' - ';
    if fFileName = '' then
    begin
      iCaption := iCaption + '<' + TranslateValue( 'No Name' ) + '>';
    end
    else
    begin
      iCaption := iCaption + ExtractFileName( fFileName );
    end;
    if IsDirty then
    begin
      iCaption := iCaption + ' *';
    end;

    fEdit.Caption := iCaption;
  end;
end;

procedure tSigFileProperty.SetContextHelpCaption(const Value: string);
begin
  fContextHelpCaption := Value;
{$IFDEF FMX_SIGFILE}
  fHelpContext.Text := Value;
{$ELSE}
  fHelpContext.Caption := Value;
{$ENDIF}
  fHelpContext.Visible := Value <> '';
end;

procedure tSigFileProperty.SetEdit(const Value: tForm);
begin
  fEdit := Value;
  if assigned( fEdit ) then
  begin
    BaseCaption := Editor.Caption;
    fFormSaveCanClose := Editor.OnCloseQuery;
    Editor.OnCloseQuery := fFormCloseQuery;
  end;
  SetCaption();
end;

procedure tSigFileProperty.SetIsDirty(const Value: boolean);
begin
  inherited;
  if assigned( fSigSaveDialog) then
  begin
    fSigSaveDialog.Dirty := Value;
  end;
  SetCaption();
end;

procedure tSigFileProperty.SetMainMenu(const Value: tMainMenu);
begin
  fMainMenu := Value;
  InsertFileMenu();
  InsertEditMenu();
  InsertDeviceMenu();

  AddHelpMenu();
end;

procedure tSigFileProperty.SetOnCompareDevice(const Value: tNotifyEvent);
begin
  FOnCompareDevice := Value;
  if assigned( fDeviceCompare ) then
  begin
    if assigned( fOnCompareDevice ) then
    begin
      fDeviceCompare.ShortCut := TextToShortcut( 'Shft+F2' );
      SetupDeviceMenu();
    end;
  end;
end;

procedure tSigFileProperty.SetOnLoadFromDevice(const Value: tNotifyEvent);
begin
  FOnLoadFromDevice := Value;
  if assigned( fDeviceLoad ) then
  begin
    if assigned( fOnLoadFromDevice ) then
    begin
      fDeviceLoad.ShortCut := TextToShortcut( 'Shft+F3' );
      SetupDeviceMenu();
    end;
  end;
end;

procedure tSigFileProperty.SetOnPrint(const Value: tNotifyEvent);
begin
  FOnPrint := Value;
  SetupPrinterMenu();
end;

procedure tSigFileProperty.SetOnPrinterSetup(const Value: tNotifyEvent);
begin
  FOnPrinterSetup := Value;
  SetupPrinterMenu();
end;

procedure tSigFileProperty.SetOnPrintPreview(const Value: tNotifyEvent);
begin
  FOnPrintPreview := Value;
  SetupPrinterMenu();
end;

procedure tSigFileProperty.SetOnSaveToDevice(const Value: tNotifyEvent);
begin
  FOnSaveToDevice := Value;
  if assigned( fDeviceLoad ) then
  begin
    if assigned( fOnSaveToDevice ) then
    begin
      fDeviceSave.ShortCut := TextToShortcut( 'Shft+F2' );
      SetupDeviceMenu();
    end;
  end;
end;

procedure tSigFileProperty.SetRedoEnabled(const Value: boolean);
begin
  FRedoEnabled := Value;
  SetupEditMenu();
end;

procedure tSigFileProperty.SetSigSaveDialog(const Value: TSigSaveDialog);
begin
  fSigSaveDialog := Value;
  fOnSave := Value.OnSave;
  fSigSaveDialog.OnSave := SigSaveDialogSave;
  fSigSaveDialog.OnLoad := SigSaveDialogload;
  fSigSaveDialog.Dirty := IsDirty;
  fSigSaveDialog.OnHistoryChange := SetupHistory;
end;

procedure tSigFileProperty.SetUndoEnabled(const Value: boolean);
begin
  FUndoEnabled := Value;
  SetupEditMenu();
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigFileProperty.SetUndoRedoImageList(const Value: tImageList);
begin
  fUndoRedoImageList := Value;
  if assigned( fMainMenu ) then
  begin
    fMainMenu.Images := fUndoRedoImageList;
  end;
  SetupEditMenu();
end;
{$ENDIF}

procedure tSigFileProperty.SetupDeviceMenu;
begin
  fDeviceCompare.Visible := assigned( FOnCompareDevice );
  fDeviceLoad.Visible := assigned( FOnLoadFromDevice );
  fDeviceSave.Visible := assigned( FOnSaveToDevice );
  fDeviceMenu.Visible := fDeviceCompare.Visible or fDeviceLoad.Visible or fDeviceSave.Visible;
end;

procedure tSigFileProperty.SetupEditMenu;
begin
  if assigned( fEditMenu ) then
  begin
    fEditUndo.Enabled := fUndoEnabled;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    if assigned( fUndoRedoImageList ) then
    begin
      if fUndoEnabled then
      begin
        fEditUndo.ImageIndex := 0;
      end
      else
      begin
        fEditUndo.ImageIndex := 2;
      end;
    end;
{$ENDIF}
    fEditRedo.Enabled := fRedoEnabled;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    if assigned( fUndoRedoImageList ) then
    begin
      if fRedoEnabled then
      begin
        fEditRedo.ImageIndex := 1;
      end
      else
      begin
        fEditRedo.ImageIndex := 3;
      end;
    end;
{$ENDIF}
  end;
end;

procedure tSigFileProperty.SetupHelp;
begin
  if assigned( fHelpMenu ) then
  begin
    fHelpAbout.Visible := assigned( fAboutform );
    fHelpMenu.Visible := fHelpContents.Visible or fHelpAbout.Visible;
  end;
end;

procedure tSigFileProperty.SetupHistory( Sender : tObject );
var
  i : integer;
  iFileName : string;
begin
  if assigned( fFileMenu ) then
  begin
    if assigned( fSigSaveDialog ) then
    begin
{$IFDEF FMX_SIGFILE}
      if assigned( fSigSaveDialog.SigINIFile ) then
{$ELSE}
      if assigned( fSigSaveDialog.SigRegistry ) then
{$ENDIF}
      begin
        for i := 0 to 9 do
        begin
          iFileName := ExtractFileName(fSigSaveDialog.History[ i ]);
          with fFileHistory[ i ] do
          begin
{$IFDEF FMX_SIGFILE}
            Text := '&' + IntToStr( i ) + ': ' + iFileName;
{$ELSE}
            Caption := '&' + IntToStr( i ) + ': ' + iFileName;
{$ENDIF}
            Visible := iFileName <> '';
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigFileProperty.SetupPrinterMenu;
begin
  if assigned( fFileMenu ) then
  begin
    fFilePrint.Visible := assigned( fOnPrint );
    fFilePrintPreview.Visible := assigned( fOnPrintPreview );
    fFilePrinterSetup.Visible := assigned( fOnPrinterSetup );
  end;
end;

procedure tSigFileProperty.SigSaveDialogLoad(Sender: tObject; var pOK: Boolean; const pFileName : string);
var
  iTempSrc : boolean;
  pLine : integer;
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  i: integer;
begin

  if assigned( HijackLoad ) then
  begin
    if HijackLoad( pFileName, pOK ) then
    begin
      exit;
    end;
  end;

  LoadingFromFile := TRUE;
  iTempSrc := FALSE;
  try
    if assigned( ErrorList ) then
    begin
      ErrorList.Clear;
    end;

    NewInternal();

    if pFileName <> '' then
    begin
      fFileName := pFileName;
    end;

    if not assigned( fSource ) then
    begin
      fSource := tStringList.Create;
      iTempSrc := TRUE;
    end;
    pLine := 0;

    try
      fSource.LoadFromFile( fFileName );
    except
      fSource.Clear;
    end;

    // first line is read by self - should be File statement
    // analyse the line...
    if fSource.Count = 0 then
    begin
      // empty file
      pOK := FALSE;
      if assigned( ErrorList ) then
      begin
        ErrorList.Add( 0, 0, 'Empty File');
      end;
    end
    else
    begin
      if SigNETParse ( fSource[ pLine ], SigProperty,
               SigIndex, SigValue, SigComment) then
      begin
        if (PropertyName = '') and AnsiSameText( Copy(SigProperty,1 , Length(ClassType) + 1), ClassType + ' ') then
        begin
          // any file allowed
          fPropertyName := Copy( SigProperty, Length(ClassType) + 2 );
        end
        else if AnsiSameText( SigProperty, ClassType + ' ' + PropertyName ) then
        begin
          // OK
        end
        else if AnsiSameText( SigProperty, PropertyName ) then     // short form
        begin
          if assigned( ErrorList ) then
          begin
            ErrorList.Add( 0, 0, 'Warning - Short format. May not be backwards compatible');
          end;
        end
        else
        begin
          if assigned( ErrorList ) then
          begin
            ErrorList.Add( 0, 0, 'Error - wrong file');
            pOK := FALSE;
            exit;  // not a disaster that fSource is not freed - it will be there for next time.
          end;
        end;
      end
      else
      begin
        if assigned( ErrorList ) then
        begin
          ErrorList.Add( 0, 0, 'Syntax Error');
        end;
      end;

      inc( pLine );

      if not inherited Load( fSource, pLine, FALSE, FALSE, ErrorList ) then
      begin
        pOK := FALSE;
      end;

      if assigned( fAfterLoadList ) then
      begin
        for i := 0 to fAfterLoadList.Count - 1 do
        begin
          with fAfterLoadList.Items[ i ] as tSigBaseProperty do
          begin
            DoAfterLoad;
          end;
        end;
        FreeAndNil( fAfterLoadList );
      end;

      if assigned( fOnLoad ) then
      begin
        fOnLoad( Sender, pOK, fFileName );
      end;
    end;

  finally

    if LoadingFromTemplate then
    begin
      pOK := FALSE; // avoid saving template file to history
    end;

    if iTempSrc then
    begin
      FreeAndNil( fSource );
    end;
    LoadingFromFile := FALSE;
    IsDirty := FALSE;

  end;

end;

procedure tSigFileProperty.SigSaveDialogSave(Sender: tObject;
  var pOK: Boolean; const pFileName : string);
var
  iTempSrc : boolean;
begin
  if assigned( HijackSave ) then
  begin
    if HijackSave( pFileName, pOK ) then
    begin
      exit;
    end;
  end;

  if pFileName <> '' then
  begin
    fFileName := pFileName;
  end;

  iTempSrc := FALSE;
  if not assigned( fSource ) then
  begin
    fSource := tStringList.Create;
    iTempSrc := TRUE;
  end
  else
  begin
    fSource.Clear;
  end;

  if assigned( fOnSave ) then
  begin
    fOnSave( Sender, pOK, fFileName );
  end;

  inherited Save( fSource, ShortFormat );

  if fFileName <> '' then
  begin
    fSource.SaveToFile( fFileName );
  end;
  if iTempSrc then
  begin
    FreeAndNil( fSource );
  end;

  // SetupHistory();

end;

function tSigFileProperty.Translate(const pVal: string): string;
begin
  Result := pVal; // by default, no translation
end;

procedure tSigFileProperty.UnRegisterAfterLoadEntry(
  const pObject: tSigBaseProperty);
var
  i: Integer;
begin
  if assigned( fAfterLoadList ) then
  begin
    for i := fAfterloadList.Count - 1 downto 0 do
    begin
      if fAfterLoadList.Items[ i ] = pObject then
      begin
        fAfterloadList.Delete( i );
      end;
    end;
  end;
end;

{ tSigIntegerArray }

function tSigIntegerArray.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
begin
  if SameText( pPropertyText, 'Item') then
  begin
    Result := tSigIntegerProperty.Create( pPropertyText, pIndexText, self );
    if pValue <> '' then
    begin
      Result.Value := IntToStr( StrToInt( pValue ));
    end;
  end
  else
  begin
    Result := inherited CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
  end;
end;

function tSigIntegerArray.GetIntegerItem(const i: integer): integer;
begin
  Result := StrToInt( Entry[ i ].Value );
end;

procedure tSigIntegerArray.SetIntegerItem(const i, Value: integer);
begin
  Entry[ i ].Value := IntToStr( Value );
end;

{ tSigBooleanProperty }

procedure tSigBooleanProperty.Clear;
begin
  ValueAsBool := FALSE;
end;

procedure tSigBooleanProperty.OnDestroy;
begin
  if assigned( fEdit ) then
  begin
    fEdit.OnClick := fOnEditorChange;
  end;
  fOnEditorChange := nil;
  inherited;
end;

procedure tSigBooleanProperty.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing : boolean);
begin
  if pUndoing then
  begin
    AmUndoing := TRUE;
  end;
  if pRedoing then
  begin
    AmRedoing := TRUE;
  end;
  try
    inherited;
    if assigned( fEdit ) then
    begin
{$IFDEF FMX_SIGFILE}
      if fEdit.IsChecked <> ValueAsBool then
      begin
        fEdit.IsChecked := ValueAsBool;
      end;
{$ELSE}
      if fEdit.Checked <> ValueAsBool then
      begin
        fEdit.Checked := ValueAsBool;
      end;
{$ENDIF}
      if assigned( fOnEditorChange ) then
      begin
        fOnEditorChange( self );
      end;
    end;
  finally
    if pUndoing then
    begin
      AmUndoing := FALSE;
    end;
    if pRedoing then
    begin
      AmRedoing := FALSE;
    end;
  end;
end;

procedure tSigBooleanProperty.fOnEditChange(Sender: tObject);
begin
{$IFDEF FMX_SIGFILE}
  if fEdit.IsChecked <> ValueAsBool then
  begin
    ValueAsBool := fEdit.IsChecked;
  end;
{$ELSE}
  if fEdit.Checked <> ValueAsBool then
  begin
    ValueAsBool := fEdit.Checked;
  end;
{$ENDIF}
  if assigned( fOnEditorChange ) then
  begin
    fOnEditorChange( Sender );
  end;
end;

function tSigBooleanProperty.GetValueAsBool: boolean;
begin
  if Value = 'TRUE' then
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure tSigBooleanProperty.RefreshEditor;
begin
  inherited;
  if assigned( fEdit ) then
  begin
{$IFDEF FMX_SIGFILE}
    if fEdit.IsChecked <> ValueAsBool then
    begin
      fEdit.IsChecked := ValueAsBool;
      if assigned( fOnEditorChange ) then
      begin
        fOnEditorChange( Self );
      end;
    end;
{$ELSE}
    if fEdit.Checked <> ValueAsBool then
    begin
      fEdit.Checked := ValueAsBool;
      if assigned( fOnEditorChange ) then
      begin
        fOnEditorChange( Self );
      end;
    end;
{$ENDIF}
  end;
end;

procedure tSigBooleanProperty.SetEdit(const Value: tCheckBox);
begin
  if fEdit <> Value then
  begin
    if assigned( fEdit ) then
    begin
      fEdit.OnClick := fOnEditorChange;
    end;
    fEdit := Value;
    if assigned( fEdit ) then
    begin
      fOnEditorChange := fEdit.OnClick;
      fEdit.OnClick := fOnEditChange;
{$IFDEF FMX_SIGFILE}
      fEdit.IsChecked := ValueAsBool;
{$ELSE}
      fEdit.Checked := ValueAsBool;
{$ENDIF}
      fEdit.Enabled := Enabled;
    end;
  end;
end;

procedure tSigBooleanProperty.SetEnabled(const Value: boolean);
begin
  inherited;
  if assigned( fEdit ) then
  begin
    fEdit.Enabled := Enabled;
  end;
end;

procedure tSigBooleanProperty.SetValueAsBool(const pValue: boolean);
begin
  if pValue then
  begin
    Value := 'TRUE';
  end
  else
  begin
    Value := 'FALSE';
  end;
  if assigned( fEdit ) then
  begin
{$IFDEF FMX_SIGFILE}
    fEdit.IsChecked := ValueAsBool;
{$ELSE}
    fEdit.Checked := ValueAsBool;
{$ENDIF}
  end;
end;

{ tSigIntegerProperty }
procedure tSigIntegerProperty.Clear;
begin
  inherited;
  Visible := TRUE;
end;

procedure tSigIntegerProperty.OnDestroy;
begin
  // if we hijacked editor OnChange, return it
  if assigned( fSpinEdit ) then
  begin
    fSpinEdit.OnChange := fOnEditorChange;
  end;
  fOnEditorChange := nil;
  inherited;
end;

procedure tSigIntegerProperty.fOnEditChange(Sender: tObject);
begin
  if assigned( fSpinEdit ) then
  begin
{$IFNDEF FMX_SIGFILE}
    if fSpinEdit.IsValid then
    begin
{$ENDIF}
      if ValueAsInt <> fSpinEdit.Value then
      begin
        if assigned( fOnEditorChange ) then
        begin
          fOnEditorChange( Sender );
        end;
{$IFDEF FMX_SIGFILE}
        ValueAsInt := Round( fSpinEdit.Value );
{$ELSE}
        ValueAsInt := fSpinEdit.Value;
{$ENDIF}
      end;
{$IFNDEF FMX_SIGFILE}
    end;
{$ENDIF}
  end;
end;

function tSigIntegerProperty.GetComment: string;
begin
  if fComment <> '' then
  begin
    Result := fComment;
  end
  else if ValueAsText <> Value then
  begin
    Result := ValueAsText;
  end
  else
  begin
    Result := '';
  end;

end;

function tSigIntegerProperty.MatchesDataOnDevice: boolean;
begin
  try
    Result := StrToInt( fValueOnDevice ) = ValueAsInt;
  except
    Result := inherited;
  end;
end;

procedure tSigIntegerProperty.RefreshEditor;
begin
  inherited;
  if Assigned( fSpinEdit ) then
  begin
    fSpinEdit.Visible := fVisible;
    if fVisible then
    begin
      if fSpinEdit.Value <> ValueAsInt then
      begin
        fSpinEdit.Value := ValueAsInt;
      end;
      if fSpinEdit.Enabled <> self.Enabled then
      begin
        fSpinEdit.Enabled := self.Enabled;
{$IFDEF FMX_SIGFILE}
{$ELSE}
        fSpinEdit.EditorEnabled := self.Enabled;
        fSpinEdit.Button.Visible := self.Enabled;
        if self.Enabled then
        begin
          fSpinEdit.Color := clWindow;
        end
        else
        begin
          fSpinEdit.ParentColor := TRUE;
        end;
{$ENDIF}
      end;
    end;
  end;
end;

procedure tSigIntegerProperty.SetMaxVal(const Value: integer);
begin
  inherited;
  if assigned( fSpinEdit ) then
  begin
{$IFDEF FMX_SIGFILE}
    fSpinEdit.Max := Value;
{$ELSE}
    fSpinEdit.MaxValue := Value;
{$ENDIF}
  end;
end;

procedure tSigIntegerProperty.SetMinVal(const Value: integer);
begin
  inherited;
  if assigned( fSpinEdit ) then
  begin
{$IFDEF FMX_SIGFILE}
    fSpinEdit.Min := Value;
{$ELSE}
    fSpinEdit.MinValue := Value;
{$ENDIF}
  end;
end;

{$IFDEF FMX_SIGFILE}
procedure tSigIntegerProperty.SetSpinEdit(const Value: tSpinBox);
{$ELSE}
procedure tSigIntegerProperty.SetSpinEdit(const Value: tSigSpinEdit);
{$ENDIF}
begin
  if fSpinEdit <> Value then
  begin
    if assigned( fSpinEdit ) then
    begin
      // if we previously hijacked OnChange then return it
      fSpinEdit.OnChange := fOnEditorChange;
    end;
    fSpinEdit := Value;
    if assigned( fSpinEdit ) then
    begin
      fOnEditorChange := fSpinEdit.OnChange;
{$IFDEF FMX_SIGFILE}
      fSpinEdit.Max := MaxVal;
      fSpinEdit.Min := MinVal;
{$ELSE}
      fSpinEdit.MaxValue := MaxVal;
      fSpinEdit.MinValue := MinVal;
{$ENDIF}
      fSpinEdit.Value := ValueAsInt;
      fSpinEdit.OnChange := fOnEditChange;
      SetEnabled( Enabled );
    end
    else
    begin
      fOnEditorChange := nil;
    end;
  end;
end;

procedure tSigIntegerProperty.SetValue(const pValue: string);
begin
  inherited;
  if assigned( fSpinEdit ) then
  begin
    if fSpinEdit.Value <> ValueAsInt then
    begin
      fSpinEdit.Value := ValueAsInt;
    end;
  end;
end;

{ tSigBaseIntegerProperty }

procedure tSigBaseIntegerProperty.Clear;
begin
  ValueAsInt := 0;
end;

function tSigBaseIntegerProperty.GetMaxVal: integer;
begin
  Result := fMaxVal;
end;

function tSigBaseIntegerProperty.GetMinVal: integer;
begin
  Result := fMinVal;
end;

function tSigBaseIntegerProperty.GetValueAsInt: integer;
begin
  if Value = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( Value );
  end;
end;

function tSigBaseIntegerProperty.GetValueAsText: string;
begin
  Result := ValueToText( ValueAsInt );
end;

procedure tSigBaseIntegerProperty.SetMaxVal(const Value: integer);
begin
  fMaxVal := Value;
end;

procedure tSigBaseIntegerProperty.SetMinVal(const Value: integer);
begin
  fMinVal := Value;
end;

procedure tSigBaseIntegerProperty.SetValueAsInt(const pValue: integer);
begin
  Value := IntToStr( pValue );
end;

procedure tSigBaseIntegerProperty.SetValueAsText(const pValue: string );
begin
  ValueAsInt := TextToValue( pValue );
end;

function tSigBaseIntegerProperty.TextToValue(pValue: string): integer;
begin
  if pValue = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( pValue );
  end;
end;

function tSigBaseIntegerProperty.ValueToText(pValue: integer): string;
begin
  Result := IntToStr( pValue );
end;

{ tSigDateTimeProperty }

procedure tSigDateTimeProperty.Clear;
begin
  ValueAsDateTime := Now; // can be used as timestamp!
end;

constructor tSigDateTimeProperty.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fFormatSettings := tFormatSettings.Create( 'en-GB' );
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigDateTimeProperty.EditorChange(Sender: tObject);
begin
  if assigned( fEditor ) then
  begin
    if fEditor.CalendarDate <> ValueAsDateTime then
    begin
      ValueAsDateTime := fEditor.CalendarDate;
    end;
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( Sender );
    end;
  end;
end;
{$ENDIF}

function tSigDateTimeProperty.GetValueAsDateTime: TDateTime;
begin
  Result := StrToDate( Value, fFormatSettings );
end;

function tSigDateTimeProperty.GetValueAsTime: tDateTime;
begin
  Result := StrToTime( Value, fFormatSettings );
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigDateTimeProperty.RefreshEditor;
begin
  inherited;
  if assigned( fEditor ) then
  begin
    if fEditor.CalendarDate <> ValueAsDateTime then
    begin
      fEditor.CalendarDate := ValueAsDateTime;
    end;
  end;
end;

procedure tSigDateTimeProperty.RemoveEditors;
begin
  inherited;
  Editor := nil;
end;

procedure tSigDateTimeProperty.SetEditor(const Value: tCalendar);
begin
  // return any hijacked Events handlers
  if assigned( fEditor ) then
  begin
    fEditor.OnChange := fOnEditorChange;
  end;
  fEditor := Value;
  if assigned( fEditor ) then
  begin
    fOnEditorChange := fEditor.OnChange;
    fEditor.OnChange := EditorChange;
    fEditor.CalendarDate := ValueAsDateTime;
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( self );
    end;
  end;
end;
procedure tSigDateTimeProperty.SetTimeEditor(const Value: TTimeSpinButton);
begin
  // return any hijacked Events handlers
  if assigned( fTimeEditor ) then
  begin
    fTimeEditor.OnChange := fOnTimeEditorChange;
  end;
  fTimeEditor := Value;
  if assigned( fTimeEditor ) then
  begin
    fOnTimeEditorChange := fTimeEditor.OnChange;
    fTimeEditor.OnChange := TimeEditorChange;
    fTimeEditor.Value := fTimeEditor.DecodeText( self.Value ); // self needed here
    if assigned( fOnTimeEditorChange ) then
    begin
      fOnTimeEditorChange( self );
    end;
  end;
end;

procedure tSigDateTimeProperty.TimeEditorChange(Sender: tObject);
var
  iText : string;
begin
  if assigned( fTimeEditor ) then
  begin
    iText := fTimeEditor.EncodeText( tsbHH_MM_SS, fTimeEditor.Value );
    if iText <> Value then
    begin
      Value := iText;
    end;
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( Sender );
    end;
  end;
end;

{$ENDIF}

procedure tSigDateTimeProperty.SetValueAsDateTime(const pValue: TDateTime);
begin
  Value := DateToStr( pValue, fFormatSettings );
end;

procedure tSigDateTimeProperty.SetValueAsTime(const pValue: tDateTime);
begin
  Value := TimeToStr( pValue, fFormatSettings );
end;

{ tSigByteArray }

function tSigByteArray.GetByteItem(const i: integer): byte;
begin
  Result := byte( GetIntegerItem( i ));
end;

procedure tSigByteArray.SetByteItem(const i: integer; const Value: byte);
begin
  SetIntegerItem( i, Value );
end;

{ tSigBooleanArray }

function tSigBooleanArray.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
begin
  if SameText( pPropertyText, 'Item' ) then
  begin
    Result := tSigBooleanProperty.Create( 'Item', pIndexText, self);
    Result.Value := pValue;
  end
  else
  begin
    Result := inherited CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
  end;
end;

function tSigBooleanArray.GetBooleanItem(const i: integer): boolean;
begin
  Result := SigBooleanItem [ i ].ValueAsBool;
end;

function tSigBooleanArray.GetSigBooleanItem(
  const i: integer): tSigBooleanProperty;
begin
  Result := Entry [ i ] as tSigBooleanProperty;
end;

procedure tSigBooleanArray.SetBooleanItem(const i: integer;
  const Value: boolean);
begin
  SigBooleanItem [ i ].ValueAsBool := Value;
end;

{ tSigObjectList }

function tSigObjectList.AddNewChild: tSigBaseProperty;
begin
  Result := fChildArray.AddNewChild;
end;

procedure tSigObjectList.BuildRecCell(const pCol, pRow: integer;
  const pRec: tSigBaseProperty);
begin
  // nothing to add
end;

procedure tSigObjectList.BuildRecLine(const pLine: integer;
  const pRec: tSigBaseProperty);
begin
  // nothing to add
end;

class function tSigObjectList.ClassType: string;
begin
  Result := 'ObjectList';
end;

procedure tSigObjectList.Clear;
begin
  ActiveChild := -1;
  if assigned( fChildArray ) then
  begin
    fChildArray.Clear;
  end;
  inherited;
end;

constructor tSigObjectList.Create(pPropertyName: string; const pIndex: string;
  pOwner: tSigCompoundProperty; pArrayClass: tSigBasePropertyClass);
begin
  inherited Create( pPropertyName, pIndex, pOwner);
  fChildArray := tSigObjectArrayHidden.Create( pPropertyName, self, pArrayClass );
end;

constructor tSigObjectList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  // just to provide a path for virtual creation
  fSaveMax := TRUE;
end;

procedure tSigObjectList.Delete(const pIndex: integer);
begin
  Delete( pIndex, undoDelete2 );
end;

procedure tSigObjectList.Delete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  // No inherited here!
  fChildArray.Delete( pIndex, pUndoAction );
  if ActiveChild > Max then
  begin
    ActiveChild := Max;
  end;
end;

constructor tSigObjectList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pArrayClass : tSigBasePropertyClass);
begin
  inherited Create( pPropertyName, pOwner);
  fChildArray := tSigObjectArrayHidden.Create( pPropertyName, self, pArrayClass );
  fChildArray.ClearRemovesChildren := TRUE;
end;

function tSigObjectList.GetAllowRecCreate: boolean;
begin
  result := fChildArray.AllowRecCreate;
end;

function tSigObjectList.GetArrayClass: tSigBasePropertyClass;
begin
  Result := ChildArray.ArrayClass;
end;

{$IFDEF FMX_SIGFILE}
function tSigObjectList.GetCountEditor: tSpinBox;
{$ELSE}
function tSigObjectList.GetCountEditor: tSpinEdit;
{$ENDIF}
begin
  Result := ChildArray.CountEditor;
end;

function tSigObjectList.GetEntry(const i: integer): tSigBaseProperty;
begin
  Result := GetItem( i );
end;

function tSigObjectList.GetItem(const i: integer): tSigBaseProperty;
begin
  Result := fChildArray.Entry[ i ];
end;

function tSigObjectList.GetMax: integer;
begin
  Result := ChildArray.Max;
end;

{$IFDEF FMX_SIGFILE}
function tSigObjectList.GetMaxEditor: tSpinBox;
{$ELSE}
function tSigObjectList.GetMaxEditor: tSpinEdit;
{$ENDIF}
begin
  Result := ChildArray.MaxEditor;
end;

function tSigObjectList.GetOnMaxChange: tSigOnIntegerChange;
begin
  Result := fChildArray.fOnMaxChange;
end;

{$IFNDEF FMX_SIGFILE}
function tSigObjectList.GetRecEditor: tSigGeneralGrid;
begin
  Result := fChildArray.RecEditor;
end;

function tSigObjectList.GetRecSelCol: integer;
begin
  Result := fChildArray.RecSelCol;
end;

function tSigObjectList.GetStringListControlList: tStringListControlList;
begin
  Result := fChildArray.StringListControlList;
end;

{$ENDIF}

function tSigObjectList.InsertNewChild(const AtLoc: integer): tSigBaseProperty;
begin
  Result := fChildArray.InsertNewChild( AtLoc );
end;

function tSigObjectList.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iTSCount : integer;
  iStartString : string;
begin
  iTSCount := 0;
  iStartString := ClassType + ' ';
  while pLine < pFile.Count do
  begin
    // analyse the line...
    if SigNETParse ( pFile[ pLine ], SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      if not assigned( fChildArray ) then
      begin
        inc( pLine );
        if SameText( SigProperty, TerminationString) then  // skip to end
        begin
          if iTSCount = 0 then
          begin
            // done
            Result := FALSE;
            exit;
          end
          else
          begin
            dec( iTSCount );
          end;
        end
        else if SameText( Copy( SigProperty, 1, Length( iStartString )), iStartString ) then
        begin
          inc( iTSCount );
        end;
      end
      else if SameText(SigProperty, 'Max') then
      begin
        inc( pLine );
        if SaveMax then
        begin
          Max := StrToInt( SigValue );
        end;
      end
      else if SameText( Copy( SigProperty, 1, Length( fChildArray.ClassType )), fChildArray.ClassType ) then
      begin
        inc( PLine );
        fChildArray.Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
      end
      else
      begin
        break;
      end;
    end;
  end;
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
end;

procedure tSigObjectList.MoveChild(const pFrom, pTo: integer);
begin
  fChildArray.Move( pFrom, pTo );
end;

function tSigObjectList.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  iTSCount : integer;
  iStartString : string;
begin
  iTSCount := 0;
  iStartString := ClassType + ' ';
  while pLine < pClipboard.Count do
  begin
    // analyse the line...
    if SigNETParse ( pClipboard[ pLine ], SigProperty,
           SigIndex, SigValue, SigComment) then
    begin
      if not assigned( fChildArray ) then
      begin
        inc( pLine );
        if SameText( SigProperty, TerminationString) then  // skip to end
        begin
          if iTSCount = 0 then
          begin
            // done
            Result := FALSE;
            exit;
          end
          else
          begin
            dec( iTSCount );
          end;
        end
        else if SameText( Copy( SigProperty, 1, Length( iStartString )), iStartString ) then
        begin
          inc( iTSCount );
        end;
      end
      else if SameText(SigProperty, 'Max') then
      begin
        inc( pLine );
        Max := StrToInt( SigValue );
      end
      else if SameText( Copy( SigProperty, 1, Length( fChildArray.ClassType )), fChildArray.ClassType ) then
      begin
        inc( PLine );
        fChildArray.PasteFromClipboard( pClipboard, pLine, pErrors );
      end
      else
      begin
        break;
      end;
    end;
  end;
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );
end;

procedure tSigObjectList.RebuildRecEditor;
begin
  fChildArray.RebuildRecEditor;
end;

procedure tSigObjectList.RedisplayStringControlList(const i: integer);
begin
  fChildArray.RedisplayStringControlList( i );
end;

procedure tSigObjectList.RedisplayStringControlList;
begin
  fChildArray.RedisplayStringControlList;
end;

procedure tSigObjectList.SaveOthers(pSaveFile: tStrings; pIndent: integer);
begin
  inherited;

end;

procedure tSigObjectList.SetActiveChild(const Value: integer);
begin
  if Value <> fActiveChild then
  begin
    if Value <= Max then
    begin
      fActiveChild := Value;
    end
    else
    begin
      fActiveChild := Max; // recovery mechanism
    end;
    if assigned( fOnActiveChildChange ) then
    begin
      fOnActiveChildChange( self, fActiveChild );
    end;
    RefreshEditor;
  end;
end;

procedure tSigObjectList.SetAllowRecCreate(const Value: boolean);
begin
  fChildArray.AllowRecCreate := Value;
end;

{$IFDEF FMX_SIGFILE}
procedure tSigObjectList.SetCountEditor(const Value: tSpinBox);
{$ELSE}
procedure tSigObjectList.SetCountEditor(const Value: tSpinEdit);
{$ENDIF}
begin
  ChildArray.CountEditor := Value;
end;

procedure tSigObjectList.SetEnabled(const Value: boolean);
begin
  inherited;
end;

procedure tSigObjectList.SetMax(const Value: integer);
begin
  fChildArray.Max := Value;
  if assigned( fOnMaxChange ) then
  begin
    fOnMaxChange( self, Value );
  end;
  if ActiveChild > Max then
  begin
    ActiveChild := Max;
  end;
end;

{$IFDEF FMX_SIGFILE}
procedure tSigObjectList.SetMaxEditor(const Value: tSpinBox);
{$ELSE}
procedure tSigObjectList.SetMaxEditor(const Value: tSpinEdit);
{$ENDIF}
begin
  ChildArray.MaxEditor := Value;
end;

procedure tSigObjectList.SetOnMaxChange(const Value: tSigOnIntegerChange);
begin
  //inherited;
  fChildArray.fOnMaxChange := Value;
end;

{$IFNDEF FMX_SIGFILE}
procedure tSigObjectList.SetRecEditor(const Value: tSigGeneralGrid);
begin
  fChildArray.RecEditor := Value;
end;

procedure tSigObjectList.SetRecSelCol(const Value: integer);
begin
  fChildArray.RecSelCol := Value;
end;

{$ENDIF}

procedure tSigObjectList.SetSaveMax(const Value: boolean);
begin
  inherited;
  fChildArray.SaveMax := Value;
end;

procedure tSigObjectList.SetStringListControlList(
  const Value: tStringListControlList);
begin
  fChildArray.StringListControlList := Value;
end;

procedure tSigObjectList.SwapChild(const pFrom, pTo: integer);
begin
  fChildArray.Swap( pFrom, pTo );
end;

{ tSigObjectArray }

function tSigObjectArray.ActiveChildObjectIs(
  const pObject: tSigBaseProperty): boolean;
begin
  if ActiveChild = -1 then
  begin
    Result := IamActiveChild;
  end
  else
  begin
    Result := Entry[ ActiveChild ] = pObject ;
  end;
end;

function tSigObjectArray.Add(NewVal: tSigBaseProperty): integer;
begin
  if NewVal is fArrayClass then
  begin
    Result := Children.Add( NewVal, undoAdd );
    fMax := Result;
  end
  else
  begin
    raise exception.Create( 'Invalid Child type' );
  end;
end;

function tSigObjectArray.AddNewChild: tSigBaseProperty;
begin
  if assigned( fArrayClass ) then
  begin
    Result := fArrayClass.Create( 'Item', IntToStr( Count ), self );
    fMax := Count - 1;
    ActiveChild := fMax;
    if assigned( fOnAddChild ) then
    begin
      fOnAddChild( Result );
    end;
  end
  else if NO_CHILD_MUST_EXIST then
  begin
    Result := tSigCompoundProperty.Create( 'Item', IntToStr( Count ), self );
  end
  else
  begin
    raise Exception.Create('Attempting to create unspecified Child Type');
  end;
  IsDirty := TRUE;
end;

procedure tSigObjectArray.BuildRecCell(const pCol, pRow: integer;
  const pRec: tSigBaseProperty);
begin
  if assigned( fRecEditor ) then
  begin
    fRecEditor.Cell[ pCol, pRow ] := '';
    fRecEditor.CellObject[ pCol, pRow ] := pRec;    // Children will probably override both of these
  end;
end;

procedure tSigObjectArray.BuildRecLine(const pLine: integer;
  const pRec: tSigBaseProperty);
var
  i: Integer;
begin
  if assigned( fRecEditor ) then
  begin
    for i := 0 to fRecEditor.ColCount - 1 do
    begin
      if i <> fRecSelCol then
      begin
        if assigned( pRec ) then
        begin
          BuildRecCell( i, pLine, pRec );
        end
        else
        begin
          fRecEditor.Cell[ i, pLine ] := '';
          fRecEditor.CellObject[ i, pLine ] := nil;
        end;
      end
      else
      begin
        fRecEditor.Cell[ i, pLine ] := '0';
        fRecEditor.CellObject[ i, pLine ] := nil;
      end;
    end;
  end;
end;

class function tSigObjectArray.ChildMustExist: boolean;
begin
  Result := FALSE;
end;

class function tSigObjectArray.ClassType: string;
begin
  Result := 'ObjectArray';
end;

procedure tSigObjectArray.Clear;
var
  i: Integer;
begin
  ActiveChild := -1;
  if Count = -1 then
  begin
    fMax := -1;
  end
  else
  begin
    if ClearRemovesChildren then
    begin
      Max := -1;
    end
    else
    begin
      for i := 0 to Max do
      begin
        Children[ i ].Clear;
      end;
    end;
  end;
end;

procedure tSigObjectArray.ClearRecSel;
var
  i: Integer;
begin
  if assigned( fRecEditor ) then
  begin
    if fRecSelCol >= 0 then
    begin
      for i := fRecEditor.FixedRows to fRecEditor.RowCount + 1 do
      begin
        fRecEditor.Cell[ fRecSelCol, i ] := '0';
      end;
    end;
  end;
end;

procedure tSigObjectArray.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iLine : string;
  i: Integer;
begin
  // these have the form
  // object name [( index )] [= value ]
  // ...
  // end name
  if pShortFormat then
  begin
    iLine := StringOfChar( ' ', pIndent ) + PropertyName;
  end
  else
  begin
    iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
  end;
  if Indexed then
  begin
    iLine := iLine + '( ' + Index + ' )';
  end;
  if Value <> '' then
  begin
    iLine := iLine + ' = ' + Value;
  end;
  pClipboard.Add( iLine );
  SaveOthers( pClipboard, pIndent );
  for i := 0 to Max do
  begin
    Children[ i ].CopyToClipboard( pClipboard, pShortFormat, pIndent + 2 );
  end;
  pClipboard.Add( StringOfChar( ' ', pIndent) + TerminationString );
  IsDirty := FALSE;
end;

constructor tSigObjectArray.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pArrayClass: tSigBasePropertyClass);
begin
  inherited Create( pPropertyName, pOwner );
  fArrayClass := pArrayClass;
  fActiveChild := -1;
  fMax := -1;
end;

constructor tSigObjectArray.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  // just provide a path for virtual creation of ascendants
  fActiveChild := -1;
  fMax := -1;
end;

function tSigObjectArray.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
var
  iText, iIndexText : string;
begin
  if pIndexText = '' then
  begin
    iIndexText := IntToStr( fMax + 1 );
  end
  else
  begin
    iIndexText := pIndexText;
  end;
  if SameText( pPropertyText, 'Item') then
  begin
    if assigned( fArrayClass ) then
    begin
      Result := fArrayClass.Create( 'Item', iIndexText, self );
    end
    else if NO_CHILD_MUST_EXIST then
    begin
      Result := tSigSimpleProperty.Create( 'Item', iIndexText, self );
    end
    else
    begin
      raise Exception.Create('Attempting to create untyped child');
    end;
    Result.Value := pValue;
  end
  else if not assigned( fArrayClass ) then
  begin
    if NO_CHILD_MUST_EXIST then
    begin
      iText := tSigCompoundProperty.ClassType + ' ';
      if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
      begin
        Result := tSigCompoundProperty.Create( 'Item', iIndexText, self );
        exit;
      end;
      iText := tSigObjectList.ClassType + ' ';
      if SameText( Copy(pPropertyText,1, Length( iText )), iText  ) then
      begin
        Result := tSigObjectList.Create( 'Item', iIndexText, self, tSigCompoundProperty );
        exit;
      end;
      //else
      begin
        raise Exception.Create('Attempting to create unrecognised type of child');
      end;
    end
    else
    begin
      raise Exception.Create('Attempting to create untyped child');
    end;
  end
  else if SameText( pPropertyText, fArrayClass.ClassType + ' Item') then
  begin
    Result := fArrayClass.Create( 'Item', iIndexText, self );
    Result.Value := pValue;
  end
  else
  begin
    Result := inherited CreateChild( pPropertyText, iIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
  end;
end;

procedure tSigObjectArray.Delete(const pIndex: integer);
begin
  Delete( pIndex, undoDelete2 );
end;

procedure tSigObjectArray.Delete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  inherited;
  Reindex;
  fMax := Count - 1;
  if fActiveChild > fMax then
  begin
    ActiveChild := fMax;
  end;
  ExecuteOnChange( self, Undoing, AmRedoing );
  RefreshEditor;
end;

procedure tSigObjectArray.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing: boolean);
var
  i: Integer;
begin
  inherited;
  if assigned( StringListControlList ) then
  begin
    for i := 0 to Max do
    begin
      if Entry[ i ].ObjectAffectsStringListText( pChangedObject ) then
      begin
        StringListControlList.ChangeString( i, pChangedObject.StringListText );
        break;
      end;
    end;
  end;
end;

procedure tSigObjectArray.OnDestroy;
begin
  if assigned( fSpinEdit ) then
  begin
    fSpinEdit.OnChange := fOnEditorChange;
  end;
  fOnEditorChange := nil;
  if assigned( fCountSpinEdit ) then
  begin
    fCountSpinEdit.OnChange := fOnCountEditorChange;
  end;
  fOnCountEditorChange := nil;
  inherited;
end;

procedure tSigObjectArray.fOnCountEditChange(Sender: tObject);
begin
{$IFDEF FMX_SIGFILE}
  Max := Round(fCountSpinEdit.Value) - 1;
{$ELSE}
  if fCountSpinEdit is tSigSpinEdit then
  begin
    with fCountSpinEdit as tSigSpinEdit do
    begin
      if not IsValid then
      begin
        exit;
      end;
    end;
  end;
  Max := fCountSpinEdit.Value - 1;
{$ENDIF}
  if assigned( fOnCountEditorChange ) then
  begin
    fOnCountEditorChange( Sender );
  end;
end;

procedure tSigObjectArray.fOnEditChange(Sender: tObject);
begin
  if assigned( fSpinEdit ) then
  begin
    Max := Round(fSpinEdit.Value);
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( Sender );
    end;
  end;
end;

function tSigObjectArray.GetActiveChild: integer;
begin
  Result := inherited;
  if Result > Max then
  begin
    Result := -1;
  end;
end;

function tSigObjectArray.GetItem(const i: integer): tSigBaseProperty;
begin
  if (i < 0) or (i >= Children.Count ) then
  begin
    Result := nil;
  end
  else
  begin
    Result := Children[ i ] as tSigBaseProperty;
  end;
end;

function tSigObjectArray.IndexOf(pObject: tSigBaseProperty): integer;
begin
  for Result := 0 to Max do
  begin
    if Entry[ Result ] = pObject then
    begin
      exit;
    end;
  end;
  // else
  Result := -1;
end;

function tSigObjectArray.InsertNewChild(const AtLoc: integer): tSigBaseProperty;
begin
  Result := fArrayClass.Create( 'Item', IntToStr( AtLoc ), self );
  if assigned ( Result ) then
  begin
    fMax := Count - 1;
    ActiveChild := fMax;
    Reindex;
    if assigned( fOnAddChild ) then
    begin
      fOnAddChild( Result );
    end;
  end
  else
  begin
    raise  exception.Create( 'Unable to create child' );
  end;
end;

function tSigObjectArray.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  MaxFound : boolean;
  iActiveChild : integer;
  iActiveChildFound : boolean;
Label
  Loop;
begin
  MaxFound := FALSE;
  iActiveChild := -1;
  iActiveChildFound := FALSE;
Loop:
  // analyse the line...
  if pFile[ pLine ] = '' then
  begin
    inc( pLine );
    goto Loop;
  end;
  if SigNETParse ( pFile[ pLine ], SigProperty,
         SigIndex, SigValue, SigComment) then
  begin
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      if SaveMax and assigned( fArrayClass ) then
      begin
        // if we don't save it, we don't load it
        Max := StrToInt( SigValue );
      end;
      MaxFound := TRUE;
      goto Loop;
    end;
    if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      iActiveChildFound := TRUE;
      goto Loop;
    end;
  end;
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
  if (not MaxFound) and SaveMax then
  begin
    if assigned( pErrors ) then
    begin
      pErrors.Add( pLine, 0, 'Warning - array size not specified. Will be calculated' );
    end;
    Max := Count - 1;
  end;
  if iActiveChildFound then
  begin
    ActiveChild := iActiveChild;
  end;
end;

function tSigObjectArray.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
  MaxFound : boolean;
  iActiveChild : integer;
  iACtiveChildFound : boolean;
Label
  Loop;
begin
  MaxFound := FALSE;
  iActiveChild := -1;
  iActiveChildFound := FALSE;
Loop:
  // analyse the line...
  if SigNETParse ( pClipboard[ pLine ], SigProperty,
         SigIndex, SigValue, SigComment) then
  begin
    if SameText(SigProperty, 'Max') then
    begin
      inc( pLine );
      Max := StrToInt( SigValue );
      MaxFound := TRUE;
      goto Loop;
    end;
    if SameText(SigProperty, 'Active Child') then
    begin
      inc( pLine );
      iActiveChild := StrToInt( SigValue );
      iActiveChildFound := TRUE;
      goto Loop;
    end;
  end;
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );
  if not MaxFound then
  begin
    if assigned( pErrors ) then
    begin
      pErrors.Add( pLine, 0, 'Warning - array size not specified. Will be calculated' );
    end;
    Max := Count - 1;
  end;
  if iActiveChildFound then
  begin
    ActiveChild := iActiveChild;
  end;
end;

function tSigObjectArray.RecCellCount: integer;
var
  i : integer;
begin
  Result := 0;
  if assigned( fRecEditor ) then
  begin
    if fRecSelCol >= 0 then
    begin
      for i := fRecEditor.FixedRows to fRecEditor.RowCount + 1 do
      begin
        if fRecEditor.Cell[ fRecSelCol, i ] = '1' then
        begin
          inc( Result );
        end;
      end;
    end;
  end;
end;

procedure tSigObjectArray.RecSelCell(Sender: tObject; ACol, ARow: integer;
  var CanSelect: boolean);
var
  iActiveChild : integer;
begin
  if assigned( fRecEditor ) then
  begin
    if ARow > fRecEditor.FixedRows then
    begin
      if ACol = fRecSelCol then
      begin
        // toggle selection
        if fRecEditor.Cell[ ACol, ARow ] = '1' then
        begin
          fRecEditor.Cell[ ACol, ARow ] := '0';
        end
        else
        begin
          fRecEditor.Cell[ ACol, ARow ] := '1';
        end;
      end;
      // set active child, if required
      iActiveChild := ARow - fRecEditor.FixedRows;
      if iActiveChild < Max then
      begin
        ActiveChild := iActiveChild;
      end
      else if AllowRecCreate then
      begin
        Max := iActiveChild;
      end;
      // now other ops
      if assigned( fOnChildSelRecCell ) then
      begin
        fOnChildSelRecCell( Sender, ACol, ARow, CanSelect );
      end;
      if assigned( fOnRecSelCell ) then
      begin
        fOnRecSelCell( Sender, ACol, ARow, CanSelect );
      end;
    end;
  end;
end;

procedure tSigObjectArray.RedisplayStringControlList;
var
  i: Integer;
begin
  if assigned( StringListControlList ) then
  begin
    StringListControlList.ClearStrings;
    for i := 0 to Max do
    begin
      StringListControlList.AddString(  Entry[ i ].StringListText );
    end;
    StringListControlList.Index := ActiveChild;
  end;
end;

procedure tSigObjectArray.RedisplayStringControlList(const pItem: integer);
var
  i: Integer;
begin
  if assigned( StringListControlList ) then
  begin
    StringListControlList.Items[ pItem ].ClearStrings;
    for i := 0 to Max do
    begin
      StringListControlList.Items[ pItem ].AddString(  Entry[ i ].StringListText );
    end;
    StringListControlList.Items[ pItem ].Index := ActiveChild;
  end;

end;

procedure tSigObjectArray.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  case pUndoAction of
    undoValue:
    begin
      inherited;
    end;
    undoAdd,
    undoInsert2,
    undoUndelete2:
    begin
      i := StrToInt( pUndoString );  // debug
      if i >= 0 then
      begin
        UnDelete( i, pUndoAction );
      end
      else
      begin
        raise Exception.Create(Translate('Internal error on Redo action'));
      end;
    end;
    undoDelete2:
    begin
      i := StrToInt( pUndoString );
      Delete( i, pUndoAction );
    end;
    undoMove:
    begin
      Children.Move( pUndoString );
    end;
    undoSwap2:
    begin
      Children.Swap( pUndoString );
    end;
    undoChangeMax: ;
    undoSelPos : ;
    undoSelLen: ;
    undoChangeActiveChild:
    begin
      ActiveChild := StrToInt( pUndoString );
    end;
    undoPointer: ;
  end;
  //OnRedo( self, pUndoAction, pUndoString );
end;

procedure tSigObjectArray.RefreshEditor;
begin
  inherited;
  if assigned( fSpinEdit ) then
  begin
    if fSpinEdit.Value <> Count - 1 then
    begin
      fSpinEdit.Value := Count;
    end;
  end;
  if assigned( fCountSpinEdit ) then
  begin
    if fCountSpinEdit.Value <> Count then
    begin
      fCountSpinEdit.Value := Count;
    end;
  end;
end;

procedure tSigObjectArray.Reindex;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Entry[ i ].Index := IntToStr( i );
  end;
end;

procedure tSigObjectArray.Save(pSaveFile: tStrings; pShortFormat: boolean;
  pIndent: integer);
var
  iLine : string;
  i: Integer;
begin
  if SaveWithFile then
  begin
    // these have the form
    // object name [( index )] [= value ]
    // ...
    // end name
    if pShortFormat then
    begin
      iLine := StringOfChar( ' ', pIndent ) + PropertyName;
    end
    else
    begin
      iLine := StringOfChar( ' ', pIndent ) + ClassType + ' ' + PropertyName;
    end;
    if Indexed then
    begin
      iLine := iLine + '( ' + Index + ' )';
    end;
    if Value <> '' then
    begin
      iLine := iLine + ' = ' + Value;
    end;
    pSaveFile.Add( iLine );
    SaveOthers( pSaveFile, pIndent );
    for i := 0 to Max do
    begin
      Children[ i ].Save( pSaveFile, pShortFormat, pIndent + 2 );
    end;
    pSaveFile.Add( StringOfChar( ' ', pIndent) + TerminationString );
    IsDirty := FALSE;
  end;
end;

procedure tSigObjectArray.SaveOthers(pSaveFile: tStrings; pIndent: integer);
begin
  if SaveWithFile then
  begin
    inherited;
    // fMax
    if SaveMax then
    begin
      pSaveFile.Add( StringOfChar( ' ', pIndent + 2 ) + 'Max = ' + IntToStr( fMax ));
    end;
    // views, if any
  end;
end;

{$IFDEF FMX_SIGFILE}
procedure tSigObjectArray.SetCountSpinEdit(const Value: tSpinBox);
{$ELSE}
procedure tSigObjectArray.SetCountSpinEdit(const Value: tSpinEdit);
{$ENDIF}
begin
  if fCountSpinEdit <> Value then
  begin
    if assigned( fCountSpinEdit ) then
    begin
      // if we previously hijacked OnChange then return it
      fCountSpinEdit.OnChange := fOnCountEditorChange;
    end;
    fCountSpinEdit := Value;
    if assigned( fCountSpinEdit ) then
    begin
      fOnCountEditorChange := fCountSpinEdit.OnChange;
      fCountSpinEdit.OnChange := fOnCountEditChange;
      fCountSpinEdit.Value := Max + 1;
      SetEnabled( Enabled );
    end
    else
    begin
      fOnCountEditorChange := nil;
    end;
  end;
end;

procedure tSigObjectArray.SetActiveChild(const Value: integer);
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fStringListControl ) then
  begin
    if fStringListControl is TListBox then
    begin
      with fStringListControl as TListBox do
      begin
        ItemIndex := Value;
      end;
    end
    else if fStringListControl is TTabControl then
    begin
      with fStringListControl as TTabControl do
      begin
        TabIndex := Value;
      end;
    end
    else
    begin
      raise Exception.Create( fStringListControl.ClassName + ' not supported as String List control [2]' );
    end;
  end;
{$ENDIF}
end;

procedure tSigObjectArray.SetEnabled(const Value: boolean);
begin
  inherited;
  if assigned( fSpinEdit ) then
  begin
    MaxEditor.Enabled := Value;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    MaxEditor.EditorEnabled := Value;
    MaxEditor.Button.Visible := Value;
    if Value then
    begin
      MaxEditor.Color := clWindow;
    end
    else
    begin
      MaxEditor.ParentColor := TRUE;
    end;
{$ENDIF}
  end;
  if assigned( fCountSpinEdit ) then
  begin
    CountEditor.Enabled := Value;
{$IFDEF FMX_SIGFILE}
{$ELSE}
    CountEditor.EditorEnabled := Value;
    CountEditor.Button.Visible := Value;
    if Value then
    begin
      CountEditor.Color := clWindow;
    end
    else
    begin
      CountEditor.ParentColor := TRUE;
    end;
{$ENDIF}
  end;
end;

procedure tSigObjectArray.SetMax(const Value: integer);
var
  i: Integer;
begin
  if fMax <> Value then
  begin
    ChangingMax := TRUE;
    try
      ExecutePrepareUndoableAction( self, undoChangeMax, IntToStr( fMax ) );
      if fMax < ActiveChild then
      begin
        ActiveChild := -1;
      end;
      for i := fMax downto Value + 1 do
      begin
        // hiding = removing - in reverse order!
        Delete( i, undoDelete2 );
      end;

      if Value >= 0 then
      begin
        while Count <= Value do
        begin
          AddNewChild;
        end;
      end;
      IsDirty := TRUE;
      ExecuteCompleteUndoableAction( self, undoChangeMax, IntToStr( fMax ) );

    finally
      if ActiveChild > Max then
      begin
        ActiveChild := Max;
      end;
      ChangingMax := FALSE;
      if Assigned( fSpinEdit ) then
      begin
        if fSpinEdit.Value <> Count - 1 then
        begin
          fSpinEdit.Value := Count - 1;
        end;
      end;
      if Assigned( fCountSpinEdit ) then
      begin
        if fCountSpinEdit.Value <> Count then
        begin
          fCountSpinEdit.Value := Count;
        end;
      end;
      {
      if assigned( fOnMaxChange ) then
      begin
        try
          fOnMaxChange( self, fMax );
        except

        end;
      end;
      }
      if assigned( fOnCountChange ) then
      begin
        try
          fOnCountChange( self, Count );
        except

        end;
      end;
    end;
    if assigned( fRecEditor ) then
    begin
      RebuildRecEditor;
    end;
    RedisplayStringControlList;
  end;
end;

{$IFNDEF FMX_SIGFILE}

procedure tSigObjectArray.RebuildRecEditor;
var
  i, iRowCount : integer;
begin
  if assigned( fRecEditor ) then
  begin
    iRowCount := fRecEditor.FixedRows + Max + 1;
    if AllowRecCreate then
    begin
      inc( iRowCount );
    end;
    fRecEditor.RowCount := iRowCount;
    for i := fRecEditor.FixedRows to iRowCount - 1 do
    begin
      BuildRecLine( i, Entry[ i - fRecEditor.FixedRows ] );
    end;
  end;
end;

procedure tSigObjectArray.SetRecEditor(const Value: tSigGeneralGrid);
begin
  if Value <> fRecEditor then
  begin
    if assigned(fRecEditor) then
    begin
      // return hijacked values
      fRecEditor.OnSelectCell := fOnRecSelCell;
    end;
    fRecEditor := Value;
    if assigned( fRecEditor ) then
    begin
      fOnRecSelCell := fRecEditor.OnSelectCell;
      fRecEditor.OnSelectCell := RecSelCell;
      RebuildRecEditor;
    end;
  end;
end;
{$ENDIF}

{$IFDEF FMX_SIGFILE}
procedure tSigObjectArray.SetSpinEdit(const Value: tSpinBox);
{$ELSE}
procedure tSigObjectArray.SetSpinEdit(const Value: tSpinEdit);
{$ENDIF}
begin
  if fSpinEdit <> Value then
  begin
    if assigned( fSpinEdit ) then
    begin
      // if we previously hijacked OnChange then return it
      fSpinEdit.OnChange := fOnEditorChange;
    end;
    fSpinEdit := Value;
    if assigned( fSpinEdit ) then
    begin
      fOnEditorChange := fSpinEdit.OnChange;
{$IFDEF FMX_SIGFILE}
      fSpinEdit.Max := 0;
      fSpinEdit.Min := 0;
{$ELSE}
      fSpinEdit.MaxValue := 0;
      fSpinEdit.MinValue := 0;
{$ENDIF}
      fSpinEdit.OnChange := fOnEditChange;
      fSpinEdit.Value := Max;
      SetEnabled( Enabled );
    end
    else
    begin
      fOnEditorChange := nil;
    end;
  end;
end;

procedure tSigObjectArray.SetStringListControl(const Value: TWinControl);
begin
  if Value is TListBox then
  else if Value is TTabControl then
  else
  begin
    raise Exception.Create( Value.ClassName + ' not supported as String List control' );
  end;
  fStringListControl := Value;
end;

procedure tSigObjectArray.UnDelete(const pIndex: integer; const pUndoAction : tSigFileUndoAction);
begin
  inherited;
  Reindex;
  fMax := Count - 1;
  if pIndex <= fMax then
  begin
    ActiveChild := pIndex;
  end;
end;

procedure tSigObjectArray.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  AmUndoing := TRUE;
  try
    case pUndoAction of
      undoValue:
      begin
        inherited;
      end;
      undoAdd,
      undoInsert2,
      undoUndelete2:
      begin
        i := StrToInt( pUndoString );
        Delete( i, pUndoAction );
      end;
      undoDelete2:
      begin
        i := StrToInt( pUndoString );
        UnDelete( i, pUndoACtion );
      end;
      undoMove:
      begin
        Children.Move( pUndoString );
      end;
      undoSwap2:
      begin
        Children.Swap( pUndoString );
      end;
      undoChangeMax: ;
      undoSelPos: ;
      undoSelLen: ;
      undoChangeActiveChild:
      begin
        ActiveChild := StrToInt( pUndoString );
      end;
      undoPointer:;
    end;
    OnUndo( self, pUndoAction, pUndoString );
  finally
    AmUndoing := FALSE;
  end;
end;

{ tSigCfgFile }

constructor tSigCfgFile.Create;
begin
  inherited Create( 'Cfg', nil );
end;

function tSigCfgFile.Load(const pFileName: string; const pIndex : integer ): boolean;
var
  iFileName : string;
begin
  if pFileName = '' then
  begin
    //iFileName := ChangeFileExt( Application.ExeName, '.cfg');
    iFileName := ChangeFileExt( ParamStr(0), '.cfg');
    // load if it exists
    if FileExists( iFileName ) then
    begin
      Result := inherited Load( iFileName, pIndex );
    end
    else
    begin
      fFileName := iFileName;
      Result := TRUE;
    end;
  end
  else
  begin
    Result := inherited Load( pFileName, pIndex );
  end;
  IsDirty := FALSE;
end;

{ tSigTextProperty }

procedure tSigTextProperty.OnDestroy;
begin
  if assigned( fEdit ) then
  begin
    if fEdit is tEdit then
    begin
      with fEdit as tEdit do
      begin
        OnChange := fOnEditorChange;
        fOnEditorChange := nil;
      end;
    end
{$IFDEF FMX_SIGFILE}
{$ELSE}
    else if fEdit is tMaskEdit then
    begin
      with fEdit as tMaskEdit do
      begin
        OnChange := fOnEditorChange;
        fOnEditorChange := nil;
      end;
    end
{$ENDIF}
    else if fEdit is tMemo then
    begin
      with fEdit as tMemo do
      begin
        OnChange := fOnEditorChange;
        fOnEditorChange := nil;
      end;
    end
    else
    begin
      raise exception.Create( 'Editor type not recognised for ' + PropertyName );
    end;
  end;
  inherited;
end;

procedure tSigTextProperty.fOnEditChange(Sender: tObject);
begin
  if Value <> fEdit.Text then
  begin
    Value := fEdit.Text;
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( Sender );
    end;
  end;
end;

procedure tSigTextProperty.fOnEditExit(Sender: tObject);
begin
  if Value <> fEdit.Text then
  begin
    Value := fEdit.Text;
    if assigned( fOnEditorExit ) then
    begin
      fOnEditorExit( Sender );
    end;
  end;
end;

procedure tSigTextProperty.RefreshEditor;
begin
  inherited;
  if assigned( fEdit ) then
  begin
    fEdit.Text := self.Value;
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( self );
    end;
  end;
end;

procedure tSigTextProperty.SetEdit(const Value: tCustomEdit);
begin
  if fEdit <> Value then
  begin
    // if the OnChange event was previously hijacked, return it
    // Primarily this is to prevent fOnEditorChange pointing to fOnEditChange
    // which causes a stack overflow!
    if assigned( fEdit) then
    begin
      if fEdit is tEdit then
      begin
        with fEdit as tEdit do
        begin
          if UpdateOnEditorChange then
          begin
            OnChange := fOnEditorChange;
            fOnEditorChange := nil;
          end;
          if UpdateOnEditorExit then
          begin
            OnExit := fOnEditorExit;
            fOnEditorExit := nil;
          end;
        end;
      end
{$IFDEF FMX_SIGFILE}
{$ELSE}
      else if fEdit is tMaskEdit then
      begin
        with fEdit as tMaskEdit do
        begin
          if UpdateOnEditorChange then
          begin
            OnChange := fOnEditorChange;
            fOnEditorChange := nil;
          end;
          if UpdateOnEditorExit then
          begin
            OnExit := fOnEditorExit;
            fOnEditorExit := nil;
          end;
        end;
      end
{$ENDIF}
      else if fEdit is tMemo then
      begin
        with fEdit as tMemo do
        begin
          if UpdateOnEditorChange then
          begin
            OnChange := fOnEditorChange;
            fOnEditorChange := nil;
          end;
          if UpdateOnEditorExit then
          begin
            OnExit := fOnEditorExit;
            fOnEditorExit := nil;
          end;
        end;
      end
      else
      begin
        raise exception.Create( 'Editor type not recognised for ' + PropertyName );
      end;
    end;
    fEdit := Value;
    if assigned( fEdit ) then
    begin
      fEdit.Enabled := fEnabled;
      if fEdit is tEdit then
      begin
        with fEdit as tEdit do
        begin
          if UpdateOnEditorChange then
          begin
            fOnEditorChange := OnChange;
            OnChange := fOnEditChange;
          end;
          if UpdateOnEditorExit then
          begin
            fOnEditorExit := OnExit;
            OnExit := fOnEditExit;
          end;
          MaxLength := MaxLen;
{$IFDEF FMX_SIGFILE}
          Password := PasswordEdit;
{$ELSE}
          if PasswordEdit then
          begin
            PasswordChar := '*';
          end
          else
          begin
            PasswordChar := #0;
          end;
          NumbersOnly := NumericOnly;
{$ENDIF}
        end;
      end
{$IFDEF FMX_SIGFILE}
{$ELSE}
      else if fEdit is tMaskEdit then
      begin
        with fEdit as tMaskEdit do
        begin
          if UpdateOnEditorChange then
          begin
            fOnEditorChange := OnChange;
            OnChange := fOnEditChange;
          end;
          if UpdateOnEditorExit then
          begin
            fOnEditorExit := OnExit;
            OnExit := fOnEditExit;
          end;
        end;
      end
{$ENDIF}
      else if fEdit is tMemo then
      begin
        with fEdit as tMemo do
        begin
          if UpdateOnEditorChange then
          begin
            fOnEditorChange := OnChange;
            OnChange := fOnEditChange;
          end;
          if UpdateOnEditorExit then
          begin
            fOnEditorExit := OnExit;
            OnExit := fOnEditExit;
          end;
        end;
      end
      else
      begin
        raise exception.Create( 'Editor type not recognised for ' + PropertyName );
      end;
      fEdit.Text := TranslateValue( self.Value );
    end;
  end;
end;

procedure tSigTextProperty.SetEnabled(const Value: boolean);
begin
  inherited;
  if assigned( fEdit ) then
  begin
    fEdit.Enabled := Value;
  end;
end;

procedure tSigTextProperty.SetMaxLen(const Value: integer);
begin
  fMaxLen := Value;
  if assigned( Editor ) then
  begin
    if Editor is TEdit then
    begin
      with Editor as TEdit do
      begin
        MaxLength := MaxLen;
      end;
    end;
  end;
end;

procedure tSigTextProperty.SetNumericOnly(const Value: boolean);
begin
  fNumericOnly := Value;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( Editor ) then
  begin
    if Editor is tEdit then
    begin
      with Editor as TEdit do
      begin
        NumbersOnly := Value;
      end;
    end;
  end;
{$ENDIF}
end;

procedure tSigTextProperty.SetPasswordEdit(const Value: boolean);
begin
  fPasswordEdit := Value;
  if assigned( Editor ) then
  begin
    if Editor is tEdit then
    begin
      with Editor as TEdit do
      begin
{$IFDEF FMX_SIGFILE}
        Password := Value;
{$ELSE}
        if Value then
        begin
          PasswordChar := '*';
        end
        else
        begin
          PasswordChar := #0;
        end;
{$ENDIF}
      end;
    end;
  end;
end;

{ tSigEnumProperty }

procedure tSigEnumProperty.AssignItemList(const pList: tStrings);
var
  i : integer;
begin
  pList.Clear;
  for i := MinVal to MaxVal do
  begin
    if Visible[ i ] then
    begin
      pList.Add( ValueToText( i ) );
    end;
  end;
end;

procedure tSigEnumProperty.OnDestroy;
begin
  if assigned( fComboBox ) then
  begin
    // if OnChange event previously hi-jacked - return it
    fComboBox.OnChange := fOnEditorChange;
  end;
  fOnEditorChange := nil;
  inherited;
end;

procedure tSigEnumProperty.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing : boolean);
begin
  if pUndoing then
  begin
    AmUndoing := TRUE;
  end;
  if pRedoing then
  begin
    AmRedoing := TRUE;
  end;
  try
    inherited;
    if assigned( fComboBox ) then
    begin
      if fComboBox.ItemIndex <> (ValueAsInt - MinVal) then
      begin
        fComboBox.ItemIndex := ValueAsInt - MinVal;
      end;
    end;
  finally
    if pUndoing then
    begin
      AmUndoing := FALSE;
    end;
    if pRedoing then
    begin
      AmRedoing := FALSE;
    end;
  end;
end;

procedure tSigEnumProperty.fOnEditChange(Sender: tObject);
begin
  if assigned( fComboBox ) then
  begin
    ValueAsInt := MapItemToValue( fComboBox.ItemIndex );
    if assigned( fOnEditorChange ) then
    begin
      fOnEditorChange( Sender );
    end;
  end;
end;

procedure tSigEnumProperty.RefreshEditor;
begin
  if assigned( fComboBox ) then
  begin
    AssignItemList( fComboBox.Items );
    fComboBox.ItemIndex := MapValueToItem( ValueAsInt );
  end;
end;

procedure tSigEnumProperty.SetComboBox(const Value: tComboBox);
begin
  if assigned( fComboBox ) then
  begin
    // if OnChange event previously hi-jacked - return it
    fComboBox.OnChange := fOnEditorChange;
  end;
  fComboBox := Value;
  if assigned( fComboBox ) then
  begin
    fOnEditorChange := fComboBox.OnChange;
    fComboBox.OnChange := fOnEditChange;
  end;
  RefreshEditor;
end;

procedure tSigEnumProperty.SetEnabled(const Value: boolean);
begin
  inherited;
  if assigned( fComboBox ) then
  begin
    fComboBox.Enabled := Value;
  end;
end;

procedure tSigEnumProperty.SetMaxVal(const Value: integer);
begin
  inherited;
  RefreshEditor;
end;

procedure tSigEnumProperty.SetMinVal(const Value: integer);
begin
  inherited;
  RefreshEditor;
end;

{ tSigEnum<T> }

procedure tSigEnum<T>.AssignItemList(const pList: tStrings);
var
  i : integer;
begin
  plist.Clear;
  for i := MinVal to MaxVal do
  begin
    if Visible[ i ] then
    begin
      pList.Add( ValueToText( i ) );
    end;
  end;
end;

procedure tSigEnum<T>.Clear;
begin
  inherited;
  MinVal := fTypeData^.MinValue;
  MaxVal := fTypeData^.MaxValue;
end;

constructor tSigEnum<T>.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fTypeInfo := TypeInfo( T );
  fTypeData := GetTypeData( fTypeInfo );
{$IFDEF FMX_SIGFILE}
{$ELSE}
  fEdit := tSelectableEdit.Create;
  fEdit.OnChange := fOnEditChange;
{$ENDIF}
  MinVal := fTypeData^.MinValue;
  MaxVal := fTypeData^.MaxValue;
  ValueAsInt := MinVal;
end;

procedure tSigEnum<T>.OnDestroy;
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEdit ) then
  begin
    fEdit.OnChange := fOnEditorChange;
  end;
{$ENDIF}
  inherited;
end;

procedure tSigEnum<T>.fOnEditChange(Sender: tObject);
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  ValueAsInt := MapItemToValue( fEdit.ItemIndex );
{$ENDIF}
  if assigned( fOnEditorChange ) then
  begin
    fOnEditorChange( Sender );
  end;
end;

function tSigEnum<T>.GetComboBox: tComboBox;
begin
{$IFDEF FMX_SIGFILE}
  Result := nil;
{$ELSE}
  Result := fEdit.GUI as tComboBox;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigEnum<T>.GetRadioGroup: tRadioGroup;
begin
  Result := fEdit.GUI as tRadioGroup;
end;
{$ENDIF}

function tSigEnum<T>.GetValueAsInt: integer;
begin
  Result := GetEnumValue( fTypeInfo, Value );
end;

function tSigEnum<T>.IsConsistent: boolean;
var
  iVal : integer;
begin
  iVal := ValueAsInt;
  if iVal < MinVal then
  begin
    Result := FALSE;
  end
  else if iVal > MaxVal then
  begin
    Result := FALSE;
  end
  else if not Visible[ iVal ] then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := TRUE;
  end;
end;

procedure tSigEnum<T>.SetComboBox(const Value: tComboBox);
begin
  // return hijacked events
{$IFDEF FMX_SIGFILE}
{$ELSE}
  fEdit.OnChange :=  fOnEditorChange;
  fEdit.GUI := Value;
  if assigned( Value ) then
  begin
    fOnEditorChange := fEdit.OnChange;
    fEdit.OnChange := fOnEditChange;
    RefreshEditor;
  end
  else
  begin
    fOnEditorChange := nil;
  end;
{$ENDIF}
end;

procedure tSigEnum<T>.SetEnabled(const Value: boolean);
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  fEdit.Enabled := Value;
{$ENDIF}
end;

procedure tSigEnum<T>.SetMaxVal(const Value: integer);
begin
  inherited;
  RefreshEditor();
end;

procedure tSigEnum<T>.SetMinVal(const Value: integer);
begin
  inherited;
  RefreshEditor();
end;

procedure tSigEnum<T>.RefreshEditor;
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  try
    if assigned( fEdit ) then
    begin
      if assigned( fEdit.Items ) then
      begin
        AssignItemList( fEdit.Items );
        if fEdit.Items.Count = 0 then
        begin
          fEdit.Visible := FALSE;
          if assigned( GUILabel ) then
          begin
            GUILabel.Visible := FALSE;
          end;
        end
        else
        begin
          fEdit.Visible := TRUE;
          if assigned( GUILabel ) then
          begin
            GUILabel.Visible := TRUE;
          end;
          fEdit.ItemIndex := MapValueToItem( ValueAsInt );
        end;
      end;
    end;
  except
    // editor detroyed?
    fEdit := nil;
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigEnum<T>.SetRadioGroup(const Value: tRadioGroup);
begin
  fEdit.OnChange :=  fOnEditorChange;
  fEdit.GUI := Value;
  if assigned( Value ) then
  begin
    fOnEditorChange := fEdit.OnChange;
    fEdit.OnChange := fOnEditChange;
    RefreshEditor;
  end
  else
  begin
    fOnEditorChange := nil;
  end;

//  fEdit.GUI := Value;
//  RefreshEditor;
end;
{$ENDIF}

procedure tSigEnum<T>.SetValueAsInt(const pValue: integer);
var
  iVal : string;
begin
  if assigned( fTypeInfo ) then
  begin
    if (fMinVal <> fMaxVal) then
    begin
      if pValue in [fMinVal..fMaxVal] then
      begin
        iVal := GetEnumName( fTypeInfo, pValue );
        if iVal = '' then
        begin
          raise EConvertError.Create('Illegal value - ' + IntToStr( pValue ));
        end
        else
        begin
          Value := iVal;
        end;
      end
      else
      begin
        raise EConvertError.Create('Illegal value - ' + IntToStr( pValue ));
      end;
    end;
    // else creating - value will be set later
  end;
end;

function tSigEnum<T>.StrToInt(pName: string): integer;
begin
  Result := GetEnumValue( fTypeInfo, pName );
end;

function tSigEnum<T>.TextToValue(pValue: string): integer;
var
  i: Integer;
begin
  for i := fMinVal to fMaxVal do
  begin
    if SameText( ValueToText( i ), pValue ) then
    begin
      Result := i;
      exit;
    end;
  end;
  // else
  raise Exception.Create('Illegal Value');
end;

function tSigEnum<T>.ValueToText(pValue: integer): string;
var
  iVal : string;
  iPos : integer;
begin
  if pValue < 0 then    // definitely not a valid enum
  begin
    Result := inherited;
    exit;
  end;
  // else
  try
    iVal := GetEnumName( fTypeInfo, pValue );
    iPos := Pos( '_', iVal );
    iVal := Copy( iVal, iPos + 1, Length( iVal ));
    iPos := Pos( '_', iVal );
    while iPos > 0 do
    begin
      iVal[ iPos ] := ' ';
      iPos := Pos( '_', iVal );
    end;
    Result := TranslateValue( iVal );
  except
    Result := inherited;
  end;
end;

{ tSigEnumSet<T> }

procedure tSigEnumSet<T>.Clear;
begin
  inherited;
  MinVal := fTypeData^.MinValue;
  MaxVal := fTypeData^.MaxValue;
end;

constructor tSigEnumSet<T>.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fTypeInfo := TypeInfo( T );
  fTypeData := GetTypeData( fTypeInfo );

end;

procedure tSigEnumSet<T>.OnDestroy;
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEdit ) then
  begin
    fEdit.OnClickCheck := fOnEditorChange;
  end;
{$ENDIF}
  inherited;
end;

procedure tSigEnumSet<T>.fOnEditChange(Sender: tObject);
var
{$IFDEF FMX_SIGFILE}
{$ELSE}
  i : integer;
{$ENDIF}
  iVal : integer;
begin
  if assigned( fOnEditorChange ) then
  begin
    fOnEditorChange( Sender );
  end;
  iVal := 0;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  for i := 0 to fEdit.Items.Count - 1 do
  begin
    if fEdit.Checked[ i ] then
    begin
      if not Inverted[ i ] then
      begin
        inc( iVal, 1 shl MapItemToValue( i ) );
      end;
    end
    else
    begin
      if Inverted[ i ] then
      begin
        inc( iVal, 1 shl MapItemToValue( i ) );
      end;
    end;
  end;
{$ENDIF}
  ValueAsInt := iVal;
end;

function tSigEnumSet<T>.GetChecked(const index: integer): boolean;
var
  iVal : longword;
begin
  iVal := ValueAsInt;
  Result := Bit(iVal, index );
end;

function tSigEnumSet<T>.GetInverted(const Index: integer): boolean;
begin
  Result := Bit( fInverted, Index );
end;

procedure tSigEnumSet<T>.RefreshEditor;
var
  i, j: Integer;
  iItemCount : integer;
begin
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEdit ) then
  begin
    fEdit.Style := lbOwnerDrawFixed;
    iItemCount := 0;
    if assigned( fEdit.Items) then
    begin
      fEdit.Items.Clear;
      for i := MinVal to MaxVal do
      begin
        if Visible[ i ] then
        begin
          j := fEdit.Items.Add( ValueToText( i ) );
          if Inverted[ i ] then
          begin
            fEdit.Checked[ j ] := not Checked[ i ];
          end
          else
          begin
            fEdit.Checked[ j ] := Checked[ i ];
          end;
          inc( iItemCount );
        end;
      end;
      if iItemCount > 0 then
      begin
        fEdit.Visible := TRUE;
        fEdit.ItemHeight := fEdit.ClientHeight div iItemCount;
      end
      else
      begin
        fEdit.Visible := FALSE;
      end;
      fEdit.Enabled := Enabled;
    end;
  end;
{$ENDIF}
end;

procedure tSigEnumSet<T>.SetChecked(const index: integer; const Value: boolean);
var
  iVal : Word;
begin
  iVal := ValueAsInt;
  SetBit( iVal, index, Value);
  ValueAsInt := iVal;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEdit ) then
  begin
    RefreshEditor();
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigEnumSet<T>.SetEdit(const Value: tCheckListBox);
begin
  if assigned( fEdit ) then
  begin
    fEdit.OnClickCheck := fOnEditorChange;
  end;
  fEdit := Value;
  if assigned( fEdit ) then
  begin
    fOnEditorChange := fEdit.OnClick;
    fEdit.OnClickCheck := fOnEditChange;
  end
  else
  begin
    fOnEditorChange := nil;
  end;
  RefreshEditor();
end;
{$ENDIF}

procedure tSigEnumSet<T>.SetEnabled(const Value: boolean);
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEdit ) then
  begin
    fEdit.Enabled := Value;
  end;
{$ENDIF}
end;

procedure tSigEnumSet<T>.SetInverted(const Index: integer;
  const Value: boolean);
begin
  SetBit( fInverted, Index, Value );
  RefreshEditor();
end;

procedure tSigEnumSet<T>.SetMaxVal(const Value: integer);
begin
  inherited;
  RefreshEditor();
end;

procedure tSigEnumSet<T>.SetMinVal(const Value: integer);
begin
  inherited;
  RefreshEditor();
end;

function tSigEnumSet<T>.ValueToText(pValue: integer): string;
var
  iVal : string;
  iPos : integer;
begin
  iVal := GetEnumName( fTypeInfo, pValue );
  iPos := Pos( '_', iVal );
  iVal := Copy( iVal, iPos + 1, Length( iVal ));
  iPos := Pos( '_', iVal );
  while iPos > 0 do
  begin
    iVal[ iPos ] := ' ';
    iPos := Pos( '_', iVal );
  end;
  Result := TranslateValue( iVal );
end;

{ tSigBaseEnumProperty }

procedure tSigBaseEnumProperty.Clear;
begin
  inherited;
  // by default everything is visible
  fVisible := $FFFFFFFF;
  RefreshEditor();
end;

procedure tSigBaseEnumProperty.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty; const pUndoing, pRedoing : boolean);
begin
  if pUndoing then
  begin
    AmUndoing := TRUE;
  end;
  if pRedoing then
  begin
    AmRedoing := TRUE;
  end;
  try
    inherited;
    RefreshEditor();
  finally
    if pUndoing then
    begin
      AmUndoing := FALSE;
    end;
    if pRedoing then
    begin
      AmRedoing := FALSE;
    end;
  end;
end;

function tSigBaseEnumProperty.GetVisible(const Index: integer): boolean;
begin
  Result := Bit( fVisible, Index );
end;

function tSigBaseEnumProperty.MapItemToValue(Item: integer): integer;
var
  i: integer;
begin
  // the item index mapped to a value
  Result := MinVal - 1;
  for i := MinVal to MaxVal do
  begin
    inc( Result );
    if Visible[ i ] then
    begin
      dec( Item );
      if Item < 0 then
      begin
        exit;
      end;
    end;
  end;
  // if we get here the item was not valid.
  raise exception.Create( 'Index out of bounds for ' + PropertyName);
end;

function tSigBaseEnumProperty.MapValueToItem( pValue: integer): integer;
var
  i: Integer;
begin
  {
  if (pValue < MinVal) or (pValue > MaxVal) then
  begin
    raise exception.Create( 'Value (' + IntToStr( pValue ) + ') not valid for ' + PropertyName);
  end;
  }
  Result := -1;
  for i := MinVal to pValue do
  begin
    if Visible[ i ] then
    begin
      inc( Result );
    end;
  end;
end;

procedure tSigBaseEnumProperty.SetAllVisible(const Value: boolean);
begin
  if Value then
  begin
    fVisible := $FFFFFFFF;
  end
  else
  begin
    fVisible := $00000000;
  end;
  RefreshEditor();
end;

procedure tSigBaseEnumProperty.SetVisible(const Index: integer;
  const Value: boolean);
begin
  SetBit( fVisible, Index, Value );
  RefreshEditor();
end;

{ tSigStringArray }

function tSigStringArray.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine,
  pErrorPos: integer): tSigBaseProperty;
begin
  if SameText( pPropertyText, 'Item') then
  begin
    Result := tSigTextProperty.Create( pPropertyText, pIndexText, self );
    if pValue <> '' then
    begin
      Result.Value := pValue;
    end;
  end
  else
  begin
    Result := inherited CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
  end;
end;

function tSigStringArray.GetStringItem(const i: integer): string;
begin
    Result := Entry[ i ].Value;
end;

procedure tSigStringArray.RefreshEditor;
{$IFDEF FMX_SIGFILE}
{$ELSE}
var
  i : integer;
  iSelStart, iSelLen : integer;
{$ENDIF}
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEditor ) then
  begin
    iSelStart := fEditor.SelStart;
    iSelLen := fEditor.SelLength;
    fEditor.Clear;
    for i := 0 to Max do
    begin
      fEditor.Lines.Add( Item[ i ] );
    end;
    fEditor.SelStart := iSelStart;
    fEditor.SelLength := iSelLen;
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigStringArray.SetEditor(const Value: tMemo);
begin
  if fEditor <> Value then
  begin
    if assigned( fEditor ) then
    begin
      // if we previously hijacked OnChange then return it
      fEditor.OnChange := fOnEditorChange;
    end;
    fEditor := Value;
    if assigned( fEditor ) then
    begin
      fOnEditorChange := fEditor.OnChange;
      SetEnabled( Enabled );
      RefreshEditor;
    end
    else
    begin
      fOnEditorChange := nil;
    end;
  end;
end;
{$ENDIF}

procedure tSigStringArray.SetStringItem(const i: integer; const Value: string);
begin
  Entry[ i ].Value := Value;
end;

{ tSigEnumMap }

procedure tSigEnumMap.Clear;
begin
  inherited;
  fVisible.ValueAsBool := TRUE;
end;

constructor tSigEnumMap.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fEnum := tSigIntegerProperty.Create( 'Value', self );
  fEnumName := tSigTextProperty.Create( 'Name', self );
  fVisible := tSigBooleanProperty.Create( 'Visible', self );

end;

{ tSigEnumMapList }

procedure tSigEnumMapList.BuildVisibleStrings(const pStrings: tStrings);
var
  i : integer;
begin
  pStrings.Clear;
  for i := 0 to Max do
  begin
    if Map[ i ].Visible.ValueAsBool then
    begin
      pStrings.AddObject(  Map[ i ].EnumName.Value, Map[ i ] );
    end;
  end;
end;

function tSigEnumMapList.BuildVisibleStrings(const pStrings: tStrings;
  const MatchString: string): integer;
var
  i : integer;
  iIndex : integer;
  iAlternateIndex : integer;
  iString : string;
begin
  Result := -1;
  iAlternateIndex := -1;
  pStrings.Clear;
  for i := 0 to Max do
  begin
    if Map[ i ].Visible.ValueAsBool then
    begin
      iString := Map[ i ].EnumName.Value;
      iIndex := pStrings.Add( iString );
      if SameText( iString, MatchString ) then
      begin
        Result := iIndex;
      end;
      iString := Map[ i ].Enum.Value;
      if SameText( iString, MatchString ) then
      begin
        iAlternateIndex := iIndex;
      end;
    end;
  end;
  if (Result = -1) and (iAlternateIndex <> -1) then
  begin
    Result := iAlternateIndex;
  end;
end;

procedure tSigEnumMapList.Clear;
begin
  inherited;

  if assigned( fVisibleColHeader ) then
  begin
    fVisibleColHeader.Value := 'Visible';
  end;
  if assigned( fIDColHeader ) then
  begin
    fIDColHeader.Value := 'ID';
  end;
  if assigned( fNameColHeader ) then
  begin
    fNameColHeader.Value := 'Name';
  end;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEditor ) then
  begin
    RefreshEditor( TRUE );
    try
      fEditor.Col := 1;
    except

    end;
  end;
{$ENDIF}

end;

constructor tSigEnumMapList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pArrayClass: tSigBasePropertyClass);
begin
  inherited;

  fVisibleColHeader := tSigTextProperty.Create('Visible Column Header', self );
  fIDColHeader := tSigTextProperty.Create( 'ID Column Header', self );
  fNameColHeader := tSigTextProperty.Create( 'Name Column Header', self );

  ChildArray.OnMaxChange := fOnMaxChange;
  ChildArray.OnChange := fOnChildChange;

  ChildArray.ClearRemovesChildren := TRUE;

end;

constructor tSigEnumMapList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  Create( pPropertyName, pOwner, tSigEnumMap );

end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigEnumMapList.OnGetEditText(Sender: TObject;
  ACol, ARow: Integer; var Value: string);
begin
  try
    Value := fEditor.Cells[ ACol, ARow ];
  except
    Value := '';
  end;
end;
{$ENDIF}

function tSigEnumMapList.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
begin
  result := inherited;
  Sort;
end;

procedure tSigEnumMapList.RefreshEditor;
begin
  RefreshEditor( FALSE );
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigEnumMapList.DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if ACol = cVisibleCol then
  begin
    if assigned( fImageListCheckBox ) then
    begin
      if ARow = 0 then
      begin
        if fImageListCheckBox.Count > 2 then
        begin
          fImageListCheckBox.Draw( fEditor.Canvas, Rect.Left, Rect.Top, 2 );
        end;
      end
      else
      begin
        if ARow > ChildArray.Count then
        begin
          fEditor.Canvas.Brush.Color := clSilver;
          fEditor.Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right, Rect.Bottom );
        end
        else if Map[ ARow - 1].Visible.ValueAsBool then
        begin
          fImageListCheckBox.Draw( fEditor.Canvas, Rect.Left, Rect.Top, 1 );
        end
        else
        begin
          fImageListCheckBox.Draw( fEditor.Canvas, Rect.Left, Rect.Top, 0 );
        end;
      end;
    end
    else
    begin
    end;
  end;
  if assigned( fOnDrawCell ) then
  begin
    fOnDrawCell( Sender, ACol, ARow, Rect, State );
  end;
end;
{$ENDIF}

procedure tSigEnumMapList.fOnChildChange(
  const pChangedObject: tSigBaseProperty);
begin
  RefreshEditor( FALSE );
end;

procedure tSigEnumMapList.SelfOnMaxChange(const NewVal: integer);
begin
  if assigned(fOnMaxChange) then
  begin
    fOnMaxChange( self, NewVal );
  end;
  RefreshEditor(FALSE);
end;

function tSigEnumMapList.GetMap(const i: integer): tSigEnumMap;
begin
  Result := Entry[ i ] as tSigEnumMap;
end;

function tSigEnumMapList.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
begin
  result := inherited;
  Sort;
end;

function tSigEnumMapList.MapWithText(const pText: string): tSigEnumMap;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if SameText( Map[ i ].fEnumName.Value, pText ) then
    begin
      Result := Map[ i ];
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function tSigEnumMapList.MapWithValue(const pValue: integer): tSigEnumMap;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if Map[ i ].Enum.ValueAsInt = pValue then
    begin
      Result := Map[ i ];
      exit;
    end;
  end;
  // else
  Result := nil;
end;

procedure tSigEnumMapList.RefreshEditor( const ForceRedraw : boolean );
{$IFDEF FMX_SIGFILE}
{$ELSE}
var
  iSelection : tGridRect;
  i: Integer;
{$ENDIF}
begin
  inherited RefreshEditor;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( fEditor ) then
  begin
    with fEditor do
    begin
      if ForceRedraw or (RowCount <> (ChildArray.Count + 2)) then
      begin
        RowCount := ChildArray.Count + 2; // 1 extra for title row and one extra for blank row
        for i := 1 to ChildArray.Count do
        begin
          if assigned( Map[ i - 1 ] ) then
          begin
            if assigned( Map[ i - 1 ].Enum ) then
            begin
              Cells[ cIDCol, i ] := Map[ i - 1 ].Enum.Value;
            end;
            if assigned( Map[ i - 1 ].EnumName ) then
            begin
              Cells[ cNameCol, i ] := Map[ i - 1 ].EnumName.Value;
            end;
            if assigned( Map[ i - 1].Visible ) then
            begin
              if assigned( fImageListCheckBox ) then
              begin
                Cells[ cVisibleCol, i ] := '';
              end
              else
              begin
                Cells[ cVisibleCol, i ] := Map[ i - 1 ].Visible.Value;
              end;
            end;
          end;
        end;
      end;
      Cells[ cIDCol, RowCount - 1 ] := '';
      Cells[ cNameCol, RowCount - 1 ] := ''; // blank row to edit
      Cells[ cVisibleCol, RowCount - 1 ] := '';
      if ActiveChild < 0 then
      begin
        iSelection.Top := fEditor.RowCount - 1;
      end
      else
      begin
        iSelection.Top := ActiveChild + 1;
      end;
      iSelection.Left := 1;
      iSelection.Bottom := iSelection.Top;
      iSelection.Right := 1;
      fEditor.Selection := iSelection;
    end;
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigEnumMapList.SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  iMustInvalidate : boolean;
begin
  iMustInvalidate := FALSE;
  if ACol = 0 then
  begin
    CanSelect := FALSE;
    if (ARow > 0) and (ARow <= ChildArray.Count) then
    begin
      Map[ ARow - 1 ].Visible.ValueAsBool := not Map[ ARow - 1 ].Visible.ValueAsBool;
      iMustInvalidate := TRUE;
    end;
  end
  else if (ARow > 0) and (ARow <= ChildArray.Count) then
  begin
    if ActiveChild <> ARow - 1 then
    begin
      ActiveChild := ARow - 1;
    end;
  end;
  if ARow = 0 then
  begin
    CanSelect := FALSE;
  end;
  if assigned( fOnSelectCell ) then
  begin
    fOnSelectCell( Sender, ACol, ARow, CanSelect ); // let programmer have the last say!
  end;
  if iMustInvalidate then
  begin
    fEditor.Invalidate;
  end;
end;

procedure tSigEnumMapList.SetEditor(const Value: tStringGrid);
begin
  if assigned( fEditor ) then
  begin
    // revert any stolen procedures
    fEditor.OnDrawCell := fOnDrawCell;
    fEditor.OnSelectCell := fOnSelectCell;
    fEditor.OnSetEditText := fOnSetEditText;
    fEditor.OnGetEditText := fOnGetEditText;
  end;
  fEditor := Value;
  if assigned( fEditor ) then
  begin
    fOnDrawCell := fEditor.OnDrawCell;
    fEditor.OnDrawCell := DrawCell;
    fOnSelectCell := fEditor.OnSelectCell;
    fEditor.OnSelectCell := SelectCell;
    fOnSetEditText := fEditor.OnSetEditText;
    fEditor.OnSetEditText := SetEditText;
    fOnGetEditText := fEditor.OnGetEditText;
    fEditor.OnGetEditText := OnGetEditText;
    SetupEditor;
  end;
end;

procedure tSigEnumMapList.SetEditText(Sender: TObject; ACol, ARow: Integer;
  const pValue: string);
begin
  if ARow > 0 then
  begin
    if ACol <> cVisibleCol then
    begin
      if ARow > ChildArray.Count then
      begin
        if pValue <> '' then
        begin
          // new entry. Create and modify
          Max := Max + 1;
          fEditor.RowCount := ChildArray.Count + 2;
          fEditor.Invalidate;
        end;
      end;
      if ACol = cIDCol then
      begin
        try
          Map[ ARow - 1 ].Enum.ValueAsInt := StrToInt( pValue );
        except

        end;
      end
      else if ACol = cNameCol then
      begin
        Map[ ARow - 1 ].EnumName.Value := pValue;
      end;
    end;
  end;
  if assigned( fOnSetEditText ) then
  begin
    fOnSetEditText( Sender, ACol, ARow, pValue );
  end;
end;

procedure tSigEnumMapList.SetImageListCheckBox(const Value: tImageList);
begin
  if assigned( fImageListCheckBox ) then
  begin
    // return any stolen procedures
  end;
  fImageListCheckBox := Value;
  if assigned( fImageListCheckBox ) then
  begin
    // steal any procedures
    SetupEditor;
  end;
end;

procedure tSigEnumMapList.SetupEditor;
var
  iColWidth, iColWidth2 : integer;
  iSelection : tGridRect;
begin
  if assigned( fEditor ) then
  begin
    fEditor.Options := fEditor.Options + [ goEditing, goTabs ];
    fEditor.ColCount := 3;
    fEditor.FixedRows := 1;
    fEditor.ScrollBars := ssVertical;

    if assigned( fImageListCheckbox ) then
    begin
      fEditor.FixedCols := 0;
      fEditor.DefaultRowHeight := fImageListCheckbox.Height;
      fEditor.ColWidths[ cVisibleCol ] := fImageListCheckbox.Width;
      if fImageListCheckbox.Count > 2 then
      begin
        fEditor.Cells[ cVisibleCol, 0 ] := ''; // drawn if 3rd image present
      end
      else
      begin
        fEditor.Cells[ cVisibleCol, 0 ] := VisibleColHeader.Value;
      end;
    end
    else
    begin
      fEditor.FixedCols := 0;
      iColWidth := fEditor.Canvas.TextWidth( VisibleColHeader.Value );
      iColWidth2 := fEditor.Canvas.TextWidth( 'FALSE' );
      if iColWidth2 > iColWidth then
      begin
        iColWidth := iColWidth2;
      end;
      inc( iColWidth, fEditor.Canvas.TextWidth( 'XX' ));
      fEditor.ColWidths[ cVisibleCol ] := iColWidth;
      fEditor.Cells[ cVisibleCol, 0 ] := VisibleColHeader.Value;
    end;

    iColWidth := fEditor.Canvas.TextWidth( '65000' ); // enough for anyone!
    iColWidth2 := fEditor.Canvas.TextWidth( IDColHeader.Value );
    if iColWidth2 > iColWidth then
    begin
      iColWidth := iColWidth2;
    end;
    inc( iColWidth, fEditor.Canvas.TextWidth( 'XX' ));
    fEditor.ColWidths[ cIDCol ] := iColWidth;
    fEditor.Cells[ cIDCol, 0 ] := IDColHeader.Value;
    // give what is left to description
    fEditor.ColWidths[ cNameCol ] := fEditor.ClientWidth - ( 2* fEditor.GridLineWidth ) - fEditor.ColWidths[ cIDCol ] - fEditor.ColWidths[ cVisibleCol ] - 24 { for vertical scroll bar};
    fEditor.Cells[ cNameCol, 0 ] := NameColHeader.Value;

    RefreshEditor( TRUE );

    if ActiveChild < 0 then
    begin
      iSelection.Top := fEditor.RowCount - 1;
    end
    else
    begin
      iSelection.Top := ActiveChild + 1;
    end;
    iSelection.Left := 1;
    iSelection.Bottom := iSelection.Top;
    iSelection.Right := 1;
    fEditor.Selection := iSelection;
  end;
end;
{$ENDIF}

procedure tSigEnumMapList.Sort;
  function CompareIDs( a, b : pointer ) : integer;
  var
    ia, ib : tSigEnumMap;
  begin
    ia := tSigEnumMap( a );
    ib := tSigEnumMap( b );
    Result := ia.Enum.ValueAsInt - ib.Enum.ValueAsInt;
  end;
begin
  ChildArray.Children.Sort( @CompareIDs );
  RefreshEditor( TRUE );
end;

{ tSigMappedEnum }

procedure tSigMappedEnum.Clear;
begin
  inherited;
  // RefreshEditor; done in base class
end;

constructor tSigMappedEnum.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pMap: tSigEnumMapList);
begin
  inherited Create( pPropertyName, pOwner );
  fMap := pMap;
  if assigned( fMap ) then
  begin
    fChainedOnMapListChange := fMap.OnChange;
    fMap.OnChange := OnMapListChange;
  end;
end;

procedure tSigMappedEnum.EditorChange(Sender: TObject);
{$IFDEF FMX_SIGFILE}
begin
{$ELSE}
var
  iMap : tSigEnumMap;
begin
  if fEditor.ItemIndex >= 0 then
  begin
    iMap := fEditor.Items.Objects[ fEditor.ItemIndex ] as tSigEnumMap;
    ValueAsInt := iMap.Enum.ValueAsInt;
  end;
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigMappedEnum.GetEditor: TWinControl;
begin
  if assigned( fEditor ) then
  begin
    Result := fEditor.GUI;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSigMappedEnum.GetHiddenEditor: TWinControl;
begin
  Result := GetEditor;
end;
{$ENDIF}

function tSigMappedEnum.GetMaxVal: integer;
begin
  Result := fMap.Count - 1;
end;

function tSigMappedEnum.GetMinVal: integer;
begin
  Result := 0;
end;

function tSigMappedEnum.GetValueAsInt: integer;
var
  iMap : tSigEnumMap;
begin
  if assigned( fMap ) then
  begin
    iMap := fMap.MapWithText( self.Value );
    if assigned( iMap ) then
    begin
      Result := iMap.Enum.ValueAsInt;
    end
    else
    begin
      Result := inherited;
    end;
  end
  else
  begin
    Result := inherited;
  end;
end;

function tSigMappedEnum.GetVisibleMap: boolean;
var
  i : integer;
begin
  Result := FALSE;
  if assigned( fMap ) then
  begin
    for i := 0 to fMap.Max do
    begin
      if fMap.Map[ i ].Enum.ValueAsInt = ValueAsInt then
      begin
        Result := fMap.Map[ i ].Visible.ValueAsBool;
        exit;
      end;
    end;
  end;
end;

function tSigMappedEnum.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
begin
  Result := inherited;
  // RefreshEditor;
end;

function tSigMappedEnum.MapItemToValue(Item: integer): integer;
begin
  if assigned( fMap ) then
  begin
    Result := fMap.Map[ Item ].Enum.ValueAsInt;
  end
  else
  begin
    Result := -1;
  end;
end;

function tSigMappedEnum.MapValueToItem(pValue: integer): integer;
var
  i: Integer;
begin
  if assigned( fMap ) then
  begin
    with fMap do
    begin
      for i := 0 to Max do
      begin
        if Map[ i ].Enum.ValueAsInt = pValue then
        begin
          Result := i;
          exit;
        end;
      end;
    end;
  end;
  // else
  Result := -1;
end;

procedure tSigMappedEnum.OnMapListChange(
  const pChangedObject: tSigBaseProperty);
begin
  if assigned( fChainedOnMapListChange ) then
  begin
    fChainedOnMapListChange( pChangedObject );
  end;
  RefreshEditor;
end;

function tSigMappedEnum.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  RefreshEditor;
end;

{$IFDEF FMX_SIGFILE}
procedure tSigMappedEnum.RefreshEditor;
begin
  inherited;
end;
{$ELSE}
procedure tSigMappedEnum.RefreshEditor;
var
  i, j: Integer;
  iIndex : integer;
begin
  if assigned( fEditor ) then
  begin
    if assigned( fEditor.GUI) then
    begin
      fEditor.Items.Clear;
      iIndex := -1;
      if assigned( fMap ) then
      begin
        for i := 0 to fMap.Max do
        begin
          if fEditorShowsHidden or fMap.Map[ i ].Visible.ValueAsBool then
          begin
            j := fEditor.Items.AddObject( fMap.Map[ i ].EnumName.Value, fMap.Map[ i ] );
            if fMap.Map[ i ].Enum.ValueAsInt = ValueAsInt then
            begin
              iIndex := j;
            end;
          end;
        end;
      end;
      fEditor.ItemIndex := iIndex;
    end;
    fEditor.Enabled := Enabled;
  end;
end;

procedure tSigMappedEnum.SetEditor(const Value: TWinControl);
begin
  fEditorShowsHidden := FALSE;
  if not assigned( fEditor ) then
  begin
    fEditor := tSelectableEdit.Create;
  end;
  fEditor.GUI := Value;
  fEditor.OnChange := EditorChange;
  RefreshEditor;
end;
{$ENDIF}

procedure tSigMappedEnum.SetEnabled(const Value: boolean);
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( Editor ) then
  begin
    Editor.Enabled := Value;
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigMappedEnum.SetHiddenEditor(const Value: TWinControl);
begin
  SetEditor( Value );
  fEditorShowsHidden := TRUE;
end;
{$ENDIF}

function tSigMappedEnum.ValueToText(pValue: integer): string;
var
  i: Integer;
begin
  with fMap do
  begin
    for i := 0 to Max do
    begin
      if Map[ i ].Enum.ValueAsInt = pValue then
      begin
        Result := Map[ i ].EnumName.Value;
        exit;
      end;
    end;
  end;
  // else
  Result := inherited ValueToText( pValue );
end;

{ tSigPrice }

constructor tSigPrice.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fDecimalPlaces := 2; // by default
end;

procedure tSigPrice.SetDecimalPlaces(const Value: integer);
begin
  fDecimalPlaces := Value;
end;

{ tSigRelativeFileProperty }

procedure tSigRelativeFileProperty.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iFileOwner : tSigFileProperty;
  iValue : string;
begin
  iFileOwner := OwnerFile;
  iValue := Value;
  if assigned( iFileOwner ) and (Value <> '') then
  begin
    fValue := ExtractRelativePath( ExtractFilePath(iFileOwner.FileName), Value );  // avoid associated operations of setting a value
  end;
  inherited;
  fValue := iValue;
end;

function tSigRelativeFileProperty.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
var
  iFileOwner : tSigFileProperty;
begin
  Result := inherited Load( pFile, pLine, pAllowUndo, pIsDirty, pErrors );
  // this will be a relative value - make absolute
  iFileOwner := OwnerFile;
  if assigned( iFileOwner ) and (Value <> '') then
  begin
    if ExtractFileDrive( Value ) = '' then  // path is relative
    begin
      Value := ExpandFileName( ExtractFilePath( iFileOwner.FileName ) + Value );
    end;
  end;
  {
  if assigned( iFileOwner ) then
  begin
    Value := ExtractRelativePath( ExtractFilePath(iFileOwner.FileName), Value );
  end;
  }
end;

function tSigRelativeFileProperty.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  iFileOwner : tSigFileProperty;
begin
  Result := inherited PasteFromClipboard( pClipboard, pLine, pErrors );
  // this will be a relative value - make absolute
  iFileOwner := OwnerFile;
  if assigned( iFileOwner ) and (Value <> '') then
  begin
    Value := ExpandFileName( ExtractFilePath( iFileOwner.FileName ) + Value );
  end;
end;

procedure tSigRelativeFileProperty.Save(pSaveFile: tStrings;
  pShortFormat: boolean; pIndent: integer);
var
  iFileOwner : tSigFileProperty;
  iValue : string;
begin
  if SaveWithFile then
  begin
    iFileOwner := OwnerFile;
    iValue := Value;
    if assigned( iFileOwner ) and (Value <> '') then
    begin
      fValue := ExtractRelativePath( ExtractFilePath(iFileOwner.FileName), Value );  // avoid associated operations of setting a value
    end;
    {
    if assigned( iFileOwner ) then
    begin
      Value := ExpandFileName( ExtractFilePath( iFileOwner.FileName ) + Value );
    end;
    }
    inherited;
    fValue := iValue;
  end;
end;

{ tSigRelativeFilePropertyList }

constructor tSigRelativeFilePropertyList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigRelativeFileProperty );

end;

{ tSigArrayView }

{ tSigArrayViewList }

procedure tSigArrayViewList.AssignIndex(pObject: tSigBaseProperty;
  pIndex: integer);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    ArrayView[ i ].AssignIndex( pObject, pIndex );
  end;
end;

function tSigArrayViewList.GetArrayView(const i: integer): tSigArrayView;
begin
  Result := Entry[ i ] as tSigArrayView;
end;

procedure tSigArrayViewList.RemoveObjectReferences(pObject: tSigBaseProperty);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    ArrayView[ i ].RemoveObjectReferences( pObject );
  end;
end;

{ tSigArrayView }

procedure tSigArrayView.AssignIndex(pObject: tSigBaseProperty; pIndex: integer);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if ViewEntry[ i ].SigObject = pObject then
    begin
      ViewEntry[ i ].ValueAsInt := pIndex;
    end;
  end;
end;

constructor tSigArrayView.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigArrayViewEntry);

end;

function tSigArrayView.GetViewEntry(const i: integer): tSigArrayViewEntry;
begin
  Result := Entry[ i ] as tSigArrayViewEntry;
end;

procedure tSigArrayView.RemoveObjectReferences(pObject: tSigBaseProperty);
var
  i: Integer;
begin
  for i := Max downto 0 do
  begin
    if ViewEntry[ i ].SigObject = pObject then
    begin
      Delete( i, undoDelete2 );
    end;
  end;
end;

{ tSigObjectListWithViews }

constructor tSigObjectListWithViews.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pArrayClass: tSigBasePropertyClass);
begin
  inherited;

  fViews := tSigArrayViewList.Create( 'Views', self );

end;

{ tSigPointer }

procedure tSigPointer.AfterLoad;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
  SigComment : string;
begin
  if SigNETParse ( fValue, SigProperty,
           SigIndex, SigValue, SigComment) then
  begin
    if assigned( DestinationList ) then
    begin
      DestinationObject := DestinationList.FindChild( SigProperty, SigIndex );
    end;
  end
  else
  begin
    DestinationObject := nil;
  end;
end;

class function tSigPointer.ClassType: string;
begin
  Result := '';
end;

procedure tSigPointer.CopyToClipboard(pClipboard: tStrings;
  pShortFormat: boolean; pIndent: integer);
begin
  if assigned( fDestinationObject ) then
  begin
    if fDestinationObject.Indexed then
    begin
      Value := fDestinationObject.PropertyName + '( ' + fDestinationObject.Index + ' )';
    end
    else
    begin
      Value := fDestinationObject.PropertyName;
    end;

    if Indexed then
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value );
    end
    else
    begin
      pClipboard.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value );
    end;
  end;
  inherited;

end;

constructor tSigPointer.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pDestinationList: tSigPropertyList);
begin
  inherited Create( pPropertyName, pOwner );
  fDestinationList := pDestinationList;
end;

constructor tSigPointer.Create(pPropertyName, pIndex: string;
  pOwner: tSigCompoundProperty; pDestinationList: tSigPropertyList);
begin
  inherited Create( pPropertyName, pIndex, pOwner );
  fDestinationList := pDestinationList;
end;

function tSigPointer.IsCurrentlyValid: boolean;
begin
  Result := fDestinationObject <> nil;
  if assigned( fOnCheckPointerValid ) then
  begin
    fOnCheckPointerValid( self, Result );
  end;
end;

function tSigPointer.Load(pFile: tStrings; var pLine: integer; const pAllowUndo : boolean; const pIsDirty : boolean;
  pErrors: tErrorList): boolean;
begin
  Result := TRUE;
  IsDirty := pIsDirty;
  // find owner file and register
  OwnerFile.RegisterAfterLoadEntry( self );
  LoadLine( pLine, pFile.Count );
end;

function tSigPointer.OnInterestedPartyCanDestroy(
  const pParty: tSigBaseProperty): boolean;
begin
  Result := not IsCurrentlyValid;
  //Result := DestinationObject = nil; // generally it is not safe to delete if we point to something
                                     // Descendants may add to error lists.
end;

procedure tSigPointer.OnInterestedPartyDestroy(const pParty: tSigBaseProperty);
begin
  inherited;
  if pParty = fDestinationObject then
  begin
    DestinationObject := nil;
  end;
end;

function tSigPointer.PasteFromClipboard(pClipboard: tStrings;
  var pLine: integer; pErrors: tErrorList): boolean;
var
  iOwner : tSigCompoundProperty;
begin
  Result := TRUE;
  // find owner file and register
  iOwner := Owner;
  while assigned( iOwner ) do
  begin
    if iOwner is tSigFileProperty then
    begin
      break;
    end;
    iOwner := iOwner.Owner;
  end;
  if assigned( iOwner ) then
  begin
    (iOwner as tSigFileProperty).RegisterAfterLoadEntry( self );
  end;
end;

function tSigPointer.PrintStructureString: string;
begin
  Result := PropertyName;
end;

procedure tSigPointer.Redo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  case pUndoAction of
    undoPointer:
    begin
      i := StrToInt( pUndoString );
      if i = -1 then
      begin
        DestinationObject := nil;
      end
      else
      begin
        DestinationObject := fDestinationList.Item[ i ];
      end;
    end;
    else
    begin
      inherited;
    end;
  end;

end;

procedure tSigPointer.ReinstateInterest;
begin
  inherited;
  if assigned( DestinationObject ) then
  begin
    try
      DestinationObject.RegisterInterest( self );
    except
      // object might no longer exist
      DestinationObject := nil;
    end;
  end;
end;

procedure tSigPointer.RemoveInterest;
begin
  inherited;
  if assigned( DestinationObject ) then
  begin
    try
      DestinationObject.UnregisterInterest( self );
    except

    end;
  end;
end;

procedure tSigPointer.Save(pSaveFile: tStrings; pShortFormat: boolean;
  pIndent: integer);
begin
  if SaveWithFile then
  begin
    if assigned( fDestinationObject ) then
    begin
      if fDestinationObject.Indexed then
      begin
        Value := fDestinationObject.PropertyName + '( ' + fDestinationObject.Index + ' )';
      end
      else
      begin
        Value := fDestinationObject.PropertyName;
      end;

      if Indexed then
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + '( ' + index + ' ) = ' + Value );
      end
      else
      begin
        pSaveFile.Add( StringOfChar( ' ', pIndent ) + PropertyName + ' = ' + Value );
      end;
    end;
    inherited;
  end;
end;

procedure tSigPointer.SetDestinationObject(const Value: tSigBaseProperty);
var
  iOldIndex : integer;
begin
  if not fDestroying then
  begin
    if fDestinationObject <> Value then
    begin
      if assigned( fDestinationObject ) then
      begin
        iOldIndex := fDestinationList.IndexOf( fDestinationObject );
        fDestinationObject.UnregisterInterest( self );
      end
      else
      begin
        iOldIndex := -1;
      end;
      if AmUndoing then
      begin
        ExecuteRedoableAction( self, undoPointer, IntToStr( iOldIndex ) );
      end
      else
      begin
        ExecuteUndoableAction( self, undoPointer, IntToStr( iOldIndex ) );
      end;
      fDestinationObject := Value;
      if assigned( fDestinationObject ) then
      begin
        fDestinationObject.RegisterInterest( self );
      end;
      IsDirty := TRUE;
    end;
  end;
end;

class function tSigPointer.TerminationString: string;
begin
  Result := '';
end;

procedure tSigPointer.Undo(const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  i : integer;
begin
  AmUndoing := TRUE;
  try
    case pUndoAction of
      undoPointer:
      begin
        i := StrToInt( pUndoString );
        if i = -1 then
        begin
          DestinationObject := nil;
        end
        else
        begin
          DestinationObject := fDestinationList.Item[ i ];
        end;
      end;
      else
      begin
        inherited;
      end;
    end;
  finally
    AmUndoing := FALSE;
  end;
end;

{ tSigAdaptablePointer }

constructor tSigAdaptablePointer.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pDestinationList: tSigPropertyList);
begin
  inherited Create( pPropertyName, pOwner, pDestinationList );
end;

procedure tSigAdaptablePointer.AfterLoad;
begin
  if assigned( fOnAfterLoad ) then
  begin
    fOnAfterLoad( self );
  end;

  inherited;

end;

constructor tSigAdaptablePointer.Create(pPropertyName, pIndex: string;
  pOwner: tSigCompoundProperty; pDestinationList: tSigPropertyList);
begin
  inherited Create( pPropertyName, pIndex, pOwner, pDestinationList );
end;

function tSigAdaptablePointer.GetDestinationList: tSigPropertyList;
begin
  if assigned( fOnGetList ) then
  begin
    Result := fOnGetList( self );
  end
  else
  begin
    Result := fDestinationList;
  end;
end;

{ tSigMappedObject }

constructor tSigMappedObject.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty; pMap: tSigEnumMapList);
begin
  inherited Create( pPropertyName, pOwner );
  fMap := pMap;
  if assigned( fMap ) then
  begin
    fChainedOnMapListChange := fMap.OnChange;
    fMap.OnChange := OnMapListChange;
  end;
end;

procedure tSigMappedObject.EditorChange(Sender: TObject);
{$IFDEF FMX_SIGFILE}
begin
{$ELSE}
var
  iMap : tSigEnumMap;
begin
  if fEditor.ItemIndex >= 0 then
  begin
    iMap := fEditor.Items.Objects[ fEditor.ItemIndex ] as tSigEnumMap;
    ValueAsInt := iMap.Enum.ValueAsInt;
  end;
{$ENDIF}
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
function tSigMappedObject.GetEditor: TWinControl;
begin
  if assigned( fEditor ) then
  begin
    Result := fEditor.GUI;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSigMappedObject.GetHiddenEditor: TWinControl;
begin
  Result := GetEditor;
end;
{$ENDIF}

function tSigMappedObject.GetValueAsInt: integer;
begin
  if Value = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( Value );
  end;
end;

function tSigMappedObject.GetVisibleMap: boolean;
var
  i : integer;
begin
  Result := FALSE;
  if assigned( fMap ) then
  begin
    for i := 0 to fMap.Max do
    begin
      if fMap.Map[ i ].Enum.ValueAsInt = ValueAsInt then
      begin
        Result := fMap.Map[ i ].Visible.ValueAsBool;
        exit;
      end;
    end;
  end;
end;

function tSigMappedObject.MapItemToValue(Item: integer): integer;
begin
  if assigned( fMap ) then
  begin
    Result := fMap.Map[ Item ].Enum.ValueAsInt;
  end
  else
  begin
    Result := -1;
  end;
end;

function tSigMappedObject.MapValueToItem(pValue: integer): integer;
var
  i: Integer;
begin
  if assigned( fMap ) then
  begin
    with fMap do
    begin
      for i := 0 to Count - 1 do
      begin
        if Map[ i ].Enum.ValueAsInt = pValue then
        begin
          Result := i;
          exit;
        end;
      end;
    end;
  end;
  // else
  Result := -1;
end;

procedure tSigMappedObject.OnMapListChange(
  const pChangedObject: tSigBaseProperty);
begin
  if assigned( fChainedOnMapListChange ) then
  begin
    fChainedOnMapListChange( pChangedObject );
  end;
  RefreshEditor;
end;

procedure tSigMappedObject.RefreshEditor;
{$IFDEF FMX_SIGFILE}
begin
  inherited;
end;
{$ELSE}
var
  i, j: Integer;
  iIndex : integer;
begin
  inherited;
  if assigned( fEditor ) then
  begin
    if assigned( fEditor.GUI) then
    begin
      fEditor.Items.Clear;
      iIndex := -1;
      if assigned( fMap ) then
      begin
        for i := 0 to fMap.Max do
        begin
          if fEditorShowsHidden or fMap.Map[ i ].Visible.ValueAsBool then
          begin
            j := fEditor.Items.AddObject( fMap.Map[ i ].EnumName.Value, fMap.Map[ i ] );
            if fMap.Map[ i ].Enum.ValueAsInt = ValueAsInt then
            begin
              iIndex := j;
            end;
          end;
        end;
      end;
      fEditor.ItemIndex := iIndex;
    end;
    fEditor.Enabled := Enabled;
  end;
end;
{$ENDIF}

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigMappedObject.SetEditor(const Value: TWinControl);
begin
  fEditorShowsHidden := FALSE;
  if not assigned( fEditor ) then
  begin
    fEditor := tSelectableEdit.Create;
  end;
  fEditor.GUI := Value;
  fEditor.OnChange := EditorChange;
  RefreshEditor;
end;
{$ENDIF}

procedure tSigMappedObject.SetEnabled(const Value: boolean);
begin
  inherited;
{$IFDEF FMX_SIGFILE}
{$ELSE}
  if assigned( Editor ) then
  begin
    Editor.Enabled := Value;
  end;
{$ENDIF}
end;

{$IFDEF FMX_SIGFILE}
{$ELSE}
procedure tSigMappedObject.SetHiddenEditor(const Value: TWinControl);
begin
  SetEditor( Value );
  fEditorShowsHidden := TRUE;
end;
{$ENDIF}

procedure tSigMappedObject.SetValueAsInt(const pValue: integer);
begin
  Value := IntToStr( pValue );
end;

function tSigMappedObject.ValueToText(pValue: integer): string;
var
  i: Integer;
begin
  with fMap do
  begin
    for i := 0 to Max do
    begin
      if Map[ i ].Enum.ValueAsInt = pValue then
      begin
        Result := Map[ i ].EnumName.Value;
        exit;
      end;
    end;
  end;
  // else
  Result := IntToStr( pValue );
end;

{ tSigBasePropertyList }

function tSigBasePropertyList.GetItem(const pIndex: integer): tSigBaseProperty;
begin
  if pIndex < 0 then
  begin
    Result := nil;
  end
  else if pIndex < Count then
  begin
    Result := Items[ pIndex ] as tSigBaseProperty;
  end
  else
  begin
    Result := nil;
  end;
end;

{ tSortedChild }

procedure tSortedChild.Add(pObject: tObject);
begin
  fList.Add( pObject );
end;

procedure tSortedChild.Clear;
begin
  fList.Clear;
end;

constructor tSortedChild.Create;
begin
  inherited Create;
  fList := tObjectList.Create( FALSE );
end;

destructor tSortedChild.Destroy;
begin
  fList.Free;
  inherited;
end;

{ tSortedChildren }

constructor tSortedChildren.Create;
begin
  inherited Create( TRUE );
  fIndex := -1; // nothing to undo!
end;

function tSortedChildren.Next(pSorter: TListSortCompare): tSortedChild;
begin
  if fIndex < (Count - 1) then
  begin
    // we already have an object that we can reuse
    Result := Items[ fIndex ] as tSortedChild;
    Result.Clear;
  end
  else
  begin
    Result := tSortedChild.Create;
    fIndex := Add( Result );
  end;
  Result.Sorter := pSorter;
end;

function tSortedChildren.Redo: tSortedChild;
begin
  if fIndex >= (Count - 1) then
  begin
    // can't redo!
    Result := nil;
  end
  else
  begin
    inc( fIndex );
    Result := Items[ fIndex ] as tSortedChild;
  end;
end;

function tSortedChildren.Undo: tSortedChild;
begin
  if fIndex < 0 then
  begin
    Result := nil; // can't undo
  end
  else
  begin
    Result := Items[ fIndex ] as tSortedChild;
    dec( fIndex );
  end;
end;

{ tSigInt64 }

function tSigInt64.GetValueAsInt64: int64;
begin
  Result := StrToInt64( Value );
end;

procedure tSigInt64.SetValueAsInt64(const Value: int64);
begin
  self.Value := IntToStr( Value );
end;

{ tSigObjectArrayHidden }

procedure tSigObjectArrayHidden.BuildRecCell(const pCol, pRow: integer;
  const pRec: tSigBaseProperty);
begin
  inherited;
  (GetOwnerOfType( tSigObjectList ) as tSigObjectList).BuildRecCell( pCol, pRow, pRec );
end;

procedure tSigObjectArrayHidden.BuildRecLine(const pLine: integer;
  const pRec: tSigBaseProperty);
begin
  inherited;
  (GetOwnerOfType( tSigObjectList ) as tSigObjectList).BuildRecLine( pLine, pRec );
end;

procedure tSigObjectArrayHidden.SetActiveChild(const Value: integer);
begin
  inherited;
  Owner.ActiveChild := Value;
end;

{ tStringListControl }

function tStringListControl.AddString(const pString: string): integer;
begin
  Result := fStrings.Add( pString );
end;

procedure tStringListControl.ClearStrings;
begin
  if Index < 0 then
  begin
    fSavedText := '';
  end
  else if Index >= fStrings.Count then
  begin
    fSavedText := '';
  end
  else
  begin
    fSavedText := fStrings[ fIndex ];
  end;
  fStrings.Clear;
end;

constructor tStringListControl.Create(const pWinControl: tWinControl; const pChangesActiveChild : boolean );
begin
  inherited Create;
  fControl := pWinControl;
  fChangesActiveChild := pChangesActiveChild;
  if fControl is TListBox then
  begin
    with fControl as TListBox do
    begin
      fOriginalChangeEvent := OnClick;
      OnClick := OnListBoxChange;
    end;
  end
  else if fControl is TTabControl then
  begin
    with fControl as TTabControl do
    begin
      fOriginalChangeEvent := OnChange;
      OnChange := OnTabControlChange;
    end;
  end
  else if fControl is TComboBox then
  begin
    with fControl as TComboBox do
    begin
      fOriginalChangeEvent := OnSelect;
      OnSelect := OnComboBoxChange;
    end;
  end
  else
  begin
    raise Exception.Create( '"StringListControl" does not support type ' + fControl.ClassName );
  end;
  fIndex := -1;
  fStrings.Clear;
end;

function tStringListControl.fStrings: TStrings;
begin
  if fControl is TListBox then
  begin
    with fControl as TListBox do
    begin
      Result := Items;
    end;
  end
  else if fControl is TTabControl then
  begin
    with fControl as TTabControl do
    begin
      Result := Tabs;
    end;
  end
  else if fControl is TComboBox then
  begin
    with fControl as TComboBox do
    begin
      Result := Items;
    end;
  end
  else
  begin
    raise Exception.Create( '"StringListControl" does not support type ' + fControl.ClassName );
  end;
end;

function tStringListControl.GetCount: integer;
begin
  Result := fStrings.Count;
end;

function tStringListControl.GetIndex: integer;
begin
  if fControl is TListBox then
  begin
    with fControl as TListBox do
    begin
      Result := ItemIndex;
    end;
  end
  else if fControl is TTabControl then
  begin
    with fControl as TTabControl do
    begin
      Result := TabIndex;
    end;
  end
  else if fControl is TComboBox then
  begin
    with fControl as TComboBox do
    begin
      Result := ItemIndex;
    end;
  end
  else
  begin
    Result := fIndex;
  end;

end;

function tStringListControl.GetStrings(const i: integer): string;
begin
  if fStrings.Count > i then
  begin
    Result := fStrings[ i ];
  end
  else
  begin
    Result := '';
  end;
end;

procedure tStringListControl.OnComboBoxChange(Sender: TObject);
begin
  with fControl as TComboBox do
  begin
    fIndex := ItemIndex;
  end;
  if assigned( fOnIndexChange ) then
  begin
    fOnIndexChange( fIndex );
  end;
  if assigned( fOriginalChangeEvent ) then
  begin
    fOriginalChangeEvent( Sender );
  end;
end;

procedure tStringListControl.OnListBoxChange(Sender: TObject);
begin
  with fControl as TListBox do
  begin
    fIndex := ItemIndex;
  end;
  if assigned( fOnIndexChange ) then
  begin
    fOnIndexChange( fIndex );
  end;
  if assigned( fOriginalChangeEvent ) then
  begin
    fOriginalChangeEvent( Sender );
  end;
end;

procedure tStringListControl.OnTabControlChange(Sender: TObject);
begin
  with fControl as TTabControl do
  begin
    fIndex := TabIndex;
  end;
  if assigned( fOnIndexChange ) then
  begin
    fOnIndexChange( fIndex );
  end;
  if assigned( fOriginalChangeEvent ) then
  begin
    fOriginalChangeEvent( Sender );
  end;
end;

procedure tStringListControl.RestoreSelection;
var
  i: Integer;
begin
  if fSavedText = '' then
  begin
    Index := -1;
  end
  else
  begin
    for i := 0 to fStrings.Count - 1 do
    begin
      if fStrings[ i ] = fSavedText then
      begin
        Index := i;
        exit;
      end;
    end;
  end;
end;

procedure tStringListControl.SetIndex(const Value: integer);
begin
  if fIndex <> Value then
  begin
    fIndex := Value;
    if fControl is TListBox then
    begin
      with fControl as TListBox do
      begin
        ItemIndex := Value;
      end;
    end
    else if fControl is TTabControl then
    begin
      with fControl as TTabControl do
      begin
        TabIndex := Value;
      end;
    end
    else if fControl is TComboBox then
    begin
      with fControl as TComboBox do
      begin
        ItemIndex := Value;
      end;
    end
    else
    begin
      raise Exception.Create( '"SetIndex" not supported for type ' + fControl.ClassName );
    end;
  end;
end;

procedure tStringListControl.SetOnIndexChange(const Value: tOnIndexChange);
begin
  fOnIndexChange := Value;
end;

procedure tStringListControl.SetStrings(const i: integer; const Value: string);
var
  iCount : integer;
begin
  iCount := fStrings.Count;
  if iCount > i then
  begin
    fStrings.Strings[ i ] := Value;
  end;
end;

{ tStringListControlList }

procedure tStringListControlList.AddString(const pString: string);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Items[ i ].AddString( pString );
  end;
end;

procedure tStringListControlList.ChangeString(const pIndex: integer;
  const pString: string);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Items[ i ].Strings[ pIndex ] := pString;
  end;
end;

procedure tStringListControlList.ClearStrings;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Items[ i ].ClearStrings;
  end;
end;

constructor tStringListControlList.Create;
begin
  inherited Create;
end;

function tStringListControlList.GetControl(const i: integer): TWinControl;
begin
  Result := (Items[ i ] as tStringListControl).Control;
end;

function tStringListControlList.GetMax: integer;
begin
  Result := Count - 1;
end;

procedure tStringListControlList.OnIndexChange(const pNewIndex: integer);
begin
  fIndex := pNewIndex;
  if assigned( fCurrentOwner ) then
  begin
    if fCurrentOwner.ActiveChild <> pNewIndex then
    begin
      fCurrentOwner.ActiveChild := pNewIndex;
    end;
  end;
end;

function tStringListControlList.RegisterControl(const pControl: TWinControl; const pChangesActiveChild : boolean) : integer;
begin
  // avoid duplicates
  for Result := 0 to Count - 1 do
  begin
    if Control[ Result ] = pControl then
    begin
      exit;
    end;
  end;
  // check valid
  if pControl is TListBox then
  else if pControl is TTabControl then
  else if pControl is TComboBox then
  else
  begin
    raise Exception.Create( pControl.ClassName + ' not supported as String List Editor' );
  end;
  Result := Add( TStringListControl.Create( pControl, pChangesActiveChild ));
  if pChangesActiveChild then
  begin
    Items[ Result ].OnIndexChange :=  self.OnIndexChange;
  end;
end;

procedure tStringListControlList.SetCurrentOwner(
  const Value: tSigCompoundProperty);
begin
  if assigned( fCurrentOwner ) then
  begin
    fCurrentOwner.StringListControlList := nil;
  end;
  fCurrentOwner := Value;
  if assigned( fCurrentOwner ) then
  begin
    fCurrentOwner.StringListControlList := self;
  end;
end;

procedure tStringListControlList.SetIndex(const Value: integer);
var
  i: Integer;
begin
  //if fIndex <> Value then we cannot use this test because particularly for combo boxes, Index could have changed even if fIndex has not
  begin
    fIndex := Value;
    for i := 0 to Count - 1 do
    begin
      with Items[ i ] do
      begin
        if ChangesActiveChild then
        begin
          Index := Value;
        end
        else
        begin
          RestoreSelection;
        end;
      end;
    end;
  end;
end;

procedure tStringListControlList.UnregisterControl(const pControl: TWinControl);
var
  i: Integer;
begin
  if assigned( pControl ) then
  begin
    for i := 0 to Count - 1 do
    begin
      if Control[ i ] = pControl then
      begin
        Delete( i );
        exit;
      end;
    end;
    // else
    //raise Exception.Create( pControl.Name + ' is not a registered String List Editor' );
  end;
  // It is legal to unregister a nil control - it simplifies the process
end;

{ tSigObjectList<T> }

function tSigObjectList<T>.AddNewChild: T;
begin
  Result := (inherited AddNewChild) as T
end;

constructor tSigObjectList<T>.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigBasePropertyClass( T ) );

end;

function tSigObjectList<T>.GetTypedItem(const i: integer): T;
begin
  Result := Entry[ i ] as T;
end;

{ TSigPointer<T> }

function TSigPointer<T>.GetTarget: T;
begin
  Result := DestinationObject as T;
end;

procedure TSigPointer<T>.SetTarget(const Value: T);
begin
  DestinationObject := (Value as TSigBaseProperty);
end;

end.









