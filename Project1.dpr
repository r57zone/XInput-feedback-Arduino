library Project1;

uses
  Windows, SysUtils, CPDrv, IniFiles;

{$R *.res}

const
  // Constants for gamepad buttons
  XINPUT_GAMEPAD_DPAD_UP          = 1;
  XINPUT_GAMEPAD_DPAD_DOWN        = 2;
  XINPUT_GAMEPAD_DPAD_LEFT        = 4;
  XINPUT_GAMEPAD_DPAD_RIGHT       = 8;
  XINPUT_GAMEPAD_START            = 16;
  XINPUT_GAMEPAD_BACK             = 32;
  XINPUT_GAMEPAD_LEFT_THUMB       = 64;
  XINPUT_GAMEPAD_RIGHT_THUMB      = 128;
  XINPUT_GAMEPAD_LEFT_SHOULDER    = 256;
  XINPUT_GAMEPAD_RIGHT_SHOULDER   = 512;
  XINPUT_GAMEPAD_A                = 4096;
  XINPUT_GAMEPAD_B                = 8192;
  XINPUT_GAMEPAD_X                = 16384;
  XINPUT_GAMEPAD_Y                = 32768;

  //Flags for battery status level
  BATTERY_TYPE_DISCONNECTED       = $00;

  //User index definitions
  XUSER_MAX_COUNT                 = 4;
  XUSER_INDEX_ANY                 = $000000FF;

  //Other
  ERROR_DEVICE_NOT_CONNECTED = 1167;
  ERROR_SUCCESS = 0;

  //Types and headers taken from XInput.pas
  //https://casterprojects.googlecode.com/svn/Delphi/XE2/Projects/DX/DirectXHeaders/Compact/XInput.pas

  type
  //Structures used by XInput APIs
    PXInputGamepad = ^TXInputGamepad;
    _XINPUT_GAMEPAD = record
    wButtons: Word;
    bLeftTrigger: Byte;
    bRightTrigger: Byte;
    sThumbLX: Smallint;
    sThumbLY: Smallint;
    sThumbRX: Smallint;
    sThumbRY: Smallint;
  end;
  XINPUT_GAMEPAD = _XINPUT_GAMEPAD;
  TXInputGamepad = XINPUT_GAMEPAD;

  PXInputState = ^TXInputState;
  _XINPUT_STATE = record
    dwPacketNumber: DWORD;
    Gamepad: TXInputGamepad;
  end;
  XINPUT_STATE = _XINPUT_STATE;
  TXInputState = XINPUT_STATE;

  PXInputVibration = ^TXInputVibration;
  _XINPUT_VIBRATION = record
    wLeftMotorSpeed:  word;
    wRightMotorSpeed: word;
  end;
  XINPUT_VIBRATION = _XINPUT_VIBRATION;
  TXInputVibration = _XINPUT_VIBRATION;

  PXInputCapabilities = ^TXInputCapabilities;
  _XINPUT_CAPABILITIES = record
    _Type: Byte;
    SubType: Byte;
    Flags: Word;
    Gamepad: TXInputGamepad;
    Vibration: TXInputVibration;
  end;
  XINPUT_CAPABILITIES = _XINPUT_CAPABILITIES;
  TXInputCapabilities = _XINPUT_CAPABILITIES;

  PXInputBatteryInformation = ^TXInputBatteryInformation;
  _XINPUT_BATTERY_INFORMATION = record
    BatteryType: Byte;
    BatteryLevel: Byte;
  end;
  XINPUT_BATTERY_INFORMATION = _XINPUT_BATTERY_INFORMATION;
  TXInputBatteryInformation = _XINPUT_BATTERY_INFORMATION;

  PXInputKeystroke = ^TXInputKeystroke;
  _XINPUT_KEYSTROKE = record
    VirtualKey: Word;
    Unicode: WideChar;
    Flags: Word;
    UserIndex: Byte;
    HidCode: Byte;
  end;
  XINPUT_KEYSTROKE = _XINPUT_KEYSTROKE;
  TXInputKeystroke = _XINPUT_KEYSTROKE;

type
  TCommPort = class
  public
  constructor Create; reintroduce;
  destructor Destroy; override;
end;

var
CommPortDriver: TCommPortDriver;

function XInputGetState(
    dwUserIndex: DWORD;      //Index of the gamer associated with the device
    out pState: TXInputState //Receives the current state
 ): DWORD; stdcall;
begin
  pState.Gamepad.bRightTrigger:=0;
  pState.Gamepad.bLeftTrigger:=0;
  pState.Gamepad.sThumbLX:=0;
  pState.Gamepad.sThumbLY:=0;
  pState.Gamepad.sThumbRX:=0;
  pState.Gamepad.sThumbRY:=0;

  pState.dwPacketNumber:=GetTickCount;

  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputSetState(
    dwUserIndex: DWORD;
    const pVibration: TXInputVibration  //The vibration information to send to the controller
 ): DWORD; stdcall;
begin
  if (pVibration.wLeftMotorSpeed > 0) and (pVibration.wRightMotorSpeed > 0) then
    CommPortDriver.SendString('V');

  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputGetCapabilities(
    dwUserIndex: DWORD;
    dwFlags: DWORD;                         //Input flags that identify the device type
    out pCapabilities: TXInputCapabilities  //Receives the capabilities
 ): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

procedure XInputEnable(
    enable: BOOL     //Indicates whether xinput is enabled or disabled.
); stdcall;
begin

end;

function XInputGetDSoundAudioDeviceGuids(
    dwUserIndex: DWORD;
    out pDSoundRenderGuid: TGUID; //DSound device ID for render
    out pDSoundCaptureGuid: TGUID //DSound device ID for capture
 ): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputGetBatteryInformation(
    dwUserIndex: DWORD;
    devType: Byte;               //Which device on this user index
    out pBatteryInformation: TXInputBatteryInformation //Contains the level and types of batteries
 ): DWORD; stdcall;
begin
  Result:=BATTERY_TYPE_DISCONNECTED;
end;

function XInputGetKeystroke(
    dwUserIndex: DWORD;
    dwReserved: DWORD;                // Reserved for future use
    var pKeystroke: TXInputKeystroke  //Pointer to an XINPUT_KEYSTROKE structure that receives an input event.
 ): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputGetStateEx(
    dwUserIndex: DWORD;
    out pState: TXInputState
 ): DWORD; stdcall;
begin
  if dwUserIndex = 0 then result:=ERROR_SUCCESS
  else result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputWaitForGuideButton(
    dwUserIndex: DWORD;
    dwFlags: DWORD;
    const LPVOID
 ): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputCancelGuideButtonWait(
    dwUserIndex: DWORD               
): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function XInputPowerOffController(
    dwUserIndex: DWORD
): DWORD; stdcall;
begin
  if dwUserIndex = 0 then Result:=ERROR_SUCCESS
  else Result:=ERROR_DEVICE_NOT_CONNECTED;
end;

function DllMain(inst:LongWord; reason:DWORD; const reserved): boolean;
var
  Ini: TIniFile;
begin
  case reason of
    DLL_PROCESS_ATTACH:
      begin
        TCommPort.Create();
        Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Vibration.ini');
        CommPortDriver.PortName:='\\.\Com' + IntToStr(Ini.ReadInteger('Main', 'CommPort', 1));
        Ini.Free;
        CommPortDriver.Connect;
      end;
    DLL_PROCESS_DETACH: CommPortDriver.Free;
  end;
    
  Result:=true;
end;

exports
  //XInput 1.3
  DllMain index 1, XInputGetState index 2, XInputSetState index 3, XInputGetCapabilities index 4, XInputEnable index 5,
  XInputGetDSoundAudioDeviceGuids index 6, XInputGetBatteryInformation index 7, XInputGetKeystroke index 8,
  //XInput 1.3 undocumented
  XInputGetStateEx index 100, XInputWaitForGuideButton index 101, XInputCancelGuideButtonWait index 102, XInputPowerOffController index 103;

constructor TCommPort.Create;
begin
  CommPortDriver:=TCommPortDriver.Create(nil);
  CommPortDriver.BaudRateValue:=115200;
  CommPortDriver.DataBits:=db8BITS;
end;

destructor TCommPort.Destroy;
begin
  CommPortDriver.Disconnect;
  CommPortDriver.Free;
  inherited destroy;
end;

begin
  DllProc:=@DllMain;
  DllProc(DLL_PROCESS_ATTACH);
end.
