unit SigExpandableObjects;

interface

uses
  SigFile;

type
  tSigExpandableObject = class( tSigObjectList )
    {
      An expandable object is one that has two visual representations,
      expanded and contracted. This is in a Draw grid or descendant.
      When it is contracted, it occupies two cells (rows or columns),
      one to represent the objejct and one to represent an expansion
      bar.
      When expanded, it occupies just one, a bar to allow contraction.
      This is the same bar as the expansion bar.
    }
  private
  protected
  public
  end;

  tSigExpandableRow = class( tSigExpandableObject )
    {
      This represents the individual rows (or columns). Normally
      a row represents a collection of what is represented in
      the columns. If the parent swaps rows and columns the
      meaning will be similarly swapped
    }
  private
    fHeader: tSigExpandableObject;
  protected
  public
    property Header : tSigExpandableObject
             read fHeader;
  end;

  tSigExpandableRowList = class( tSigObjectList )

  end;

  tSigExpandableTable = class( tSigCompoundProperty )
  private
    fRowHeader: tSigExpandableObject;
    fColHeader: tSigExpandableObject;
    fRows: tSigExpandableRowList;
  protected
  public
    property ColHeader : tSigExpandableObject
             read fColHeader;
    property RowHeader : tSigExpandableObject
             read fRowHeader;
    property Rows : tSigExpandableRowList
             read fRows;

    // editor
  end;

implementation

end.
