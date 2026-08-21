unit LogicGrid;

{
  ************************************************************************
  *                                                                      *
  * Displays a collection of logic structures as a logic diagram         *
  *                                                                      *
  * The logic structures can be descended from for particular            *
  * applications.                                                        *
  *                                                                      *
  * editing is via a DropDown combo box or a drop Down List combo box    *
  *                                                                      *
  * To adapt for other uses descend from tCustomLogicGrid. To extend     *
  * new logic element, inherit element form tVisibleLogicElement. You    *
  * can use different visual images, but the elements must contain the   *
  * following:                                                           *
  * Image 0 = vertical extender (all symbols)                            *
  *     1-3 =
  *                                                                      *
  ************************************************************************
}

interface

uses
  SysUtils, Classes, Controls, Grids,
  Contnrs;

type
  tPopulateNamesList = procedure( pList : tStrings; var CanAdd : boolean ) of Object;

  TLogicGrid = class;

  {
    tLogicElement visually occupies 3 columns and an arbitrary number of rows
    depending on number of inputs - possibly fanned out
  }
  tLogicElement = class
  private
    fOwner: TLogicGrid;
    fOnPopulateNamesList: tPopulateNamesList;
  public
    constructor Create( AOwner : TLogicGrid );
    property Owner : TLogicGrid
             read fOwner;
    property OnPopulateNamesList : tPopulateNamesList
             read fOnPopulateNamesList
             write fOnPopulateNamesList;
  end;

  tLogicElementList = class( tObjectList )
  end;

  {
    tNULLLogicElement is simply an Output (really an input to another,
    non-null logic element
  }
  tNULLLogicElement = class( tLogicElement )
  private
    fOutputName: string;
    fObject: tObject;
  public
    property OutputName : string
             read fOutputName
             write fOutputName;
    property OutputObject : tObject
             read fObject
             write fObject;
  end;

  { Effectively a do nothing }
  tNormalInputLogicElement = class( tNULLLogicElement )
  end;

  tInvertedInputLogicElement = class( tNULLLogicElement )
  end;

  tNormalLogicOutput = class( tNULLLogicElement )
  end;

  tFannedOutLogicOutput = class( tNULLLogicElement )
  end;

  tInvertedOutputLogicElement = class( tNULLLogicElement )
  end;

  tInvertedFannedOutLogicElement = class( tNULLLogicElement )
  end;

  {
    tVisibleObjectElement stores links to an input logic element list
  }

  tVisibleLogicElement = class( tNULLLogicElement )
  private
  public
  end;

  TCustomLogicGrid = class(TStringGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

  TLogicGrid = class(TCustomLogicGrid)
  private
    fSymbolImageList: tImageList;
    fLogicElementList: tLogicElementList;
    fInverterFanoutImageList: tImageList;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    property LogicElementList : tLogicElementList
             read fLogicElementList;
  published
    { Published declarations }
    property SymbolImageList : tImageList
             read fSymbolImageList
             write fSymbolImageList;
    property InverterFanoutImageList : tImageList
             read fInverterFanoutImageList
             write fInverterFanoutImageList;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TLogicGrid]);
end;

{ tLogicElement }

constructor tLogicElement.Create(AOwner: TLogicGrid);
begin
  inherited Create;
  fOwner := AOwner;
end;

end.
