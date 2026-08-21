unit Constants;

interface

const
	{ Constants used in determining quantities }
	NumberApolloDeviceTypes = 15;
	NumberNittanDeviceTypes = 8;
	NumberSysSensorDeviceTypes = 8;

	MAX_POINTS_APOLLO = 126;
	MAX_POINTS_SYS_SENSOR = 198;
	HALF_MAX_POINTS_SYS_SENSOR = 99;
	MAX_POINTS_NITTAN = 126;

	MAX_LOOP = 2;
	MAX_DEVICE = 255;
	MAX_DEVICE_TYPE = 13;
	MAX_ZONE = 32;
	MAX_GROUP = 15;
	MAX_CCTS = 4;
	MAX_ZONE_SET = 15;
	MAX_REPEATER = 15;
	MAX_ZONAL_OUTPUT = 15;

	MAX_SUMMARY_HEIGHT = 9000;
	MAX_DATA_RETRIES = 10;
	MAX_TOOL_BUTTONS = 15;

	EMPTY_IMAGE = 0;
	EDIT_IMAGE = 1;
	RESET_IMAGE = 2;
	REMOVE_IMAGE = 3;

	ZONE_ZERO_NAME = 'No zone allocated';
	GROUP_ZERO_NAME = 'No group allocated';
	OUTPUT_SET_ZERO_NAME = 'No set allocated';

	MAINFORM_CAPTION = 'AFP Prog Tools 3.2 - ';

	{ Constants used in serial communication }
	NEW_PROTOCOL = 0;
	OLD_PROTOCOL = 1;
	OLD_PROTOCOL_PARITY_INVERTED = 2;

	SOH = #1;
	RxAck = #6;
	RxNak = #21;
	ReqUpload = #65;
	RetUpload = #65;
	ReqDownload = #66;
	RetDownload = #66;
	TxReqPointName = #67;
	RxRetPointName = #67;
	TxSetPointName = #68;
	RxSetPointName = RxAck;
	TxReqZoneName = #69;
	RxRetZoneName = #69;
	TxSetZoneName = #70;
	RxSetZoneName = RxAck;
	TxReqMaintName = #71;
	RxRetMaintName = #71;
	TxSetMaintName = #72;
	RxSetMaintName = RxAck;
	TxReqPData = #73;
	RxRetPData = #73;
	TxSetPData = #74;
	RxSetPData = RxAck;
	TxReqMaintDate = #75;
	RxRetMaintDate = #75;
	TxSetMaintDate = #76;
	RxSetMaintDate = RxAck;

	TxReqZGroup = #77;
	RxRetZGroup = #77;
	TxSetZGroup = #78;
	RxSetZGroup = RxAck;

	TxReqAL2Code = #79;
	RxRetAL2Code = #79;
	TxSetAL2Code = #80;
	RxSetAL2Code = RxAck;
	TxReqAL3Code = #81;
	RxRetAL3Code = #81;
	TxSetAL3Code = #82;
	RxSetAL3Code = RxAck;
	TxReqPhasedSettings = #83;
	RxRetPhasedSettings = #83;
	TxSetPhasedSettings = #84;
	RxSetPhasedSettings = RxAck;
	TxSetTimeDate = #85;
	RxSetTimeDate = RxAck;
	TxReqLoopType = #86;
	RxRetLoopType = #86;
	TxSetLoopType = #87;
	RxSetLoopType = RxAck;
	TxReqFaultLockoutTime = #88;
	RxRetFaultLockoutTime = #88;
	TxSetFaultLockoutTime = #89;
	RxSetFaultLockoutTime = RxAck;
	TxReqZoneTimers = #90;
	RxRetZoneTimers = #90;
	TxSetZoneTimers = #91;
	RxSetZoneTimers = RxAck;
	TxReqMainVersion = #92;
	RxRetMainVersion = #92;
	TxReqRepeaterName = #93;
	RxRetRepeaterName = #93;
	TxSetRepeaterName = #94;
	RxSetRepeaterName = RxAck;
	TxReqOutputName = #95;
	RxRetOutputName = #95;
	TxSetOutputName = #96;
	RxSetOutputName = RxAck;
	TxReqRepeaterFitted = #97;
	RxRetRepeaterFitted = #97;
	TxSetRepeaterFitted = #98;
	RxSetRepeaterFitted = RxAck;
	TxReqOutputFitted = #99;
	RxRetOutputFitted = #99;
	TxSetOutputFitted = #100;

	TxReqSegNo = #101;
	RxRetSegNo = #101;
	TxSetSegNo = #102;
	RxSetSegNo = RxAck;

	TxReqPanelName = #103;
	RxRetPanelName = #103;
	TxSetPanelName = #104;
	RxSetPanelName = RxAck;

	TxReqZoneSet = #105;
	RxRetZoneSet = #105;
	TxSetZoneSet = #106;
	RxSetZoneSet = RxAck;

	TxReqZoneNonFire = #107;
	RxRetZoneNonFire = #107;
	TxSetZoneNonFire = #108;
	RxSetZoneNonFire = RxAck;
	RxSetOutputFitted = RxAck;

	HandshakePacket = 'A' + #0 + 'A';

	Base_Year = 2000;
	VerifyError = 1;
	WriteError = 2;
	DataCommsTimeoutTime = 5000;         //in milliseconds
	RxTimeoutTime=700;                   //in milliseconds
	MAX_BUFFER_LENGTH = 60;

	{ These constants are used during to printing to represent true are false }
	TRUE_SYMBOL = 'O';
	FALSE_SYMBOL = ' ';
	PULSED_SYMBOL = '-';
	NON_FIRE_SYMBOL = 'x';

	INVALID_DEVICE = 0;

	NEW_VERSION = '08 00';
	
implementation

end.

