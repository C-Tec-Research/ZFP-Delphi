unit DataXchange;

interface

{
  stores a history of serial exchange of records to allow data capture etc.
  No intrinsic functionality
}

uses
  Common;

type
  tExchangeRecordType = (exTx, exRx );

type
  tExchangeRecord = class
  private
    fRecordType: tExchangeRecordType;
    fRecordData: string;
  public
    property RecordType : tExchangeRecordType
             read fRecordType
             write fRecordType;
    property RecordData : string
             read fRecordData
             write fRecordData;
  end;

implementation

end.
