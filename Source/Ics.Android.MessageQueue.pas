unit Ics.Android.MessageQueue;

interface

uses
{$IFDEF MSWINDOWS}
    Windows,
{$ENDIF}
    Classes,
    SysUtils,
{$IFDEF ANDROID}
    FMX.Platform.Android,
    Posix.UniStd, Posix.SysSocket, Posix.Errno, Posix.StrOpts,
    Androidapi.AppGlue,
    Androidapi.Looper,
{$ENDIF}
    Generics.Collections;

type

{$IFDEF MSWINDOWS}
    TPipeDescriptors = record
        ReadDes   : THandle;
        WriteDes  : THandle;
        DataCount : Integer;
    end;
    TALooper = record

    end;
    PALooper = ^TALooper;
{$ENDIF}

    ICS_WPARAM  = System.UIntPtr;
    ICS_LPARAM  = System.IntPtr;
    ICS_HWND    = type System.UIntPtr;
    ICS_LRESULT = System.IntPtr;
    ICS_BOOL    = LongBool;

{$IFDEF ANDROID}
    UINT  = System.UIntPtr;
    DWORD = System.UIntPtr;
    TPoint = record

    end;
    tagMSG = record
        hwnd    : ICS_HWND;
        message : UINT;
        wParam  : ICS_WPARAM;
        lParam  : ICS_LPARAM;
        time    : DWORD;
        pt      : TPoint;
    end;
    TMsg = tagMSG;
{$ENDIF}

    // Generic window message record
    PIcsMessage = ^TIcsMessage;
    TIcsMessage = record
        Msg: Cardinal;
        case Integer of
          0: (
            WParam: ICS_WPARAM;
            LParam: ICS_LPARAM;
            Result: ICS_LRESULT);
          1: (
            WParamLo: Word;
            WParamHi: Word;
            LParamLo: Word;
            LParamHi: Word;
            ResultLo: Word;
            ResultHi: Word);
    end;

    TIcsPipeMessage = packed record
       MsgSize : Byte;
       case MsgType : Byte of
       0: (MsgRec : TIcsMessage);
    end;
    PIcsPipeMessage = ^TIcsPipeMessage;

    TIcsWndMethod = procedure (var MsgRec: TIcsMessage) of object;

    TIcsWndRec = record
        PipeFD  : TPipeDescriptors;
        Wnd     : ICS_HWND;
        WndProc : TIcsWndMethod;
    end;
    PIcsWndRec = ^TIcsWndRec;

    TIcsMessageQueue = class
    protected
        FLooper  : PALooper;
        FWnds    : TDictionary<ICS_HWND, PIcsWndRec>;
        FLastWnd : ICS_HWND;
    public
        constructor Create(Looper: PALooper); virtual;
        destructor Destroy; override;
        function  AllocateHWnd : ICS_HWND;
        procedure DeallocateHWnd(Wnd: ICS_HWND);
        function  GetWndProc(Wnd: ICS_HWND) : TIcsWndMethod;
        function  SetWndProc(Wnd: ICS_HWND;
                             const AMethod: TIcsWndMethod) : Boolean;
        function  PostMessage(Wnd    : ICS_HWND;
                              Msg    : Integer;
                              wParam : ICS_WPARAM;
                              lParam : ICS_LPARAM) : ICS_BOOL;
        function GetMessage(var lpMsg     : TMsg;
                            Wnd           : ICS_HWND;
                            wMsgFilterMin : UINT;
                            wMsgFilterMax : UINT): ICS_BOOL;
    end;

    EIcsMessageQueueException = class(Exception)

    end;

{$IFDEF MSWINDOWS}
function Pipe(var PipeDes : TPipeDescriptors) : Integer;
function errno : Integer;
function ioctl(fd: THandle; request: Integer; Val : Pointer) : Integer;
function __write(fd: THandle; Buf: Pointer; Size: Integer) : Integer;
function __close(fd: THandle) : Integer;
{$ENDIF}

implementation

const
    FIONBIO = $5421;


{ TIcsMessageQueue }

constructor TIcsMessageQueue.Create(Looper: PALooper);
begin
    inherited Create;
    FLooper := Looper;
end;

destructor TIcsMessageQueue.Destroy;
var
    Item    : TPair<ICS_HWND, PIcsWndRec>;
begin
    if Assigned(FWnds) then begin
        // We need to free all items in the dictionary
        for Item in FWnds do
            Dispose(Item.Value);
        FreeAndNil(FWnds);
    end;
    inherited Destroy;
end;

function TIcsMessageQueue.AllocateHWnd: ICS_HWND;
var
    Status  : Integer;
    Val     : Integer;
var
    Item    : PIcsWndRec;
    PipeFD  : TPipeDescriptors;
    ErrCode : Integer;
begin
    Status := Pipe(PipeFD);
    if Status = -1 then begin
        ErrCode := errno;
        raise EIcsMessageQueueException.Create(
                  'Pipe() failed. Error code is ' +
                  IntToStr(ErrCode));
    end;

    Val := 1;
    if ioctl(PipeFD.ReadDes, FIONBIO, @Val) = -1 then begin
        ErrCode := errno;
        __close(PipeFD.WriteDes);
        __close(PipeFD.ReadDes);
        raise EIcsMessageQueueException.Create(
                  'ioctl(FIONBIO) failed. Error code is ' +
                  IntToStr(ErrCode));
    end;

    if not Assigned(FWnds) then
        FWnds := TDictionary<ICS_HWND, PIcsWndRec>.Create;
    Inc(FLastWnd);
    Result       := FLastWnd;
    New(Item);
    Item.PipeFD  := PipeFD;
    Item.Wnd     := Result;
    Item.WndProc := nil;
{$IFDEF MSWINDOWS}
    Item.PipeFD.DataCount := 0;
{$ENDIF}
    FWnds.Add(Result, Item);
end;

procedure TIcsMessageQueue.DeallocateHWnd(Wnd: ICS_HWND);
var
    Item : PIcsWndRec;
begin
    if not Assigned(FWnds) then
        raise EIcsMessageQueueException.Create(
                  'DeallocateHWnd failed. No HWND defined');
    if not FWnds.TryGetValue(Wnd, Item) then
        raise EIcsMessageQueueException.Create(
                  'DeallocateHWnd failed. Wnd not found');
    Dispose(Item);
    FWnds.Remove(Wnd);
    if FWnds.Count <= 0 then begin
{$IFDEF AUTOREFCOUNT}
        FWnds := nil;
{$ELSE}
        FreeAndNil(FWnds);
{$ENDIF}
    end;
end;

function TIcsMessageQueue.PostMessage(
    Wnd    : ICS_HWND;
    Msg    : Integer;
    wParam : ICS_WPARAM;
    lParam : ICS_LPARAM): ICS_BOOL;
var
    Item    : PIcsWndRec;
    MsgBuf  : TIcsPipeMessage;
    MsgSize : Byte;
    Written : Integer;
begin
    Result := FALSE;
    if not Assigned(FWnds) then
        Exit;
    if not FWnds.TryGetValue(Wnd, Item) then
        Exit;
    MsgSize := SizeOf(MsgBuf.MsgRec) +
               NativeInt(Addr(MsgBuf.MsgRec)) - NativeInt(Addr(MsgBuf));
    MsgBuf.MsgSize       := MsgSize;
    MsgBuf.MsgType       := 0;
    MsgBuf.MsgRec.Msg    := Msg;
    MsgBuf.MsgRec.WParam := WParam;
    MsgBuf.MsgRec.LParam := LParam;
    MsgBuf.MsgRec.Result := 0;
    Written := __write(Item.PipeFD.WriteDes, @MsgBuf, MsgSize);
    Result := Written = MsgSize;
{$IFDEF MSWINDOWS}
    if Written > 0 then
        InterlockedExchangeAdd(@Item.PipeFD.DataCount, Written);
{$ENDIF}
end;

function TIcsMessageQueue.GetMessage(
    var lpMsg     : TMsg;
    Wnd           : ICS_HWND;
    wMsgFilterMin : UINT;
    wMsgFilterMax : UINT): ICS_BOOL;
var
    Item : PIcsWndRec;
begin
    if Wnd = 0 then
        raise Exception.Create('GetMessage with HWND 0 not implemented yet');
    if Wnd = ICS_HWND(-1) then
        raise Exception.Create('GetMessage with HWND -1 not implemented yet');
    Result := ICS_BOOL(-1);  // Function failed
    if not Assigned(FWnds) then
        Exit;
    if not FWnds.TryGetValue(Wnd, Item) then
        Exit;

end;

function TIcsMessageQueue.GetWndProc(Wnd: ICS_HWND): TIcsWndMethod;
var
    Item : PIcsWndRec;
begin
    Result := nil;
    if not Assigned(FWnds) then
        Exit;
    if FWnds.TryGetValue(Wnd, Item) then
        Result := Item.WndProc;
end;

function TIcsMessageQueue.SetWndProc(
    Wnd           : ICS_HWND;
    const AMethod : TIcsWndMethod): Boolean;
var
    Item : PIcsWndRec;
begin
    Result := FALSE;
    if not Assigned(FWnds) then
        Exit;
    if FWnds.TryGetValue(Wnd, Item) then begin
        Result := TRUE;
        if @Item.WndProc <> @AMethod then
            Item.WndProc := AMethod;
    end;
end;

{$IFDEF MSWINDOWS}
function Pipe(var PipeDes : TPipeDescriptors) : Integer;
begin
    if CreatePipe(PipeDes.ReadDes, PipeDes.WriteDes, nil, 0) then
        Result := 0
    else
        Result := -1;
end;

function errno : Integer;
begin
    Result := GetLastError;
end;

function ioctl(fd: THandle; request: Integer; Val : Pointer) : Integer;
begin
    Result := -1;
    case Request of
    FIONBIO: begin
                 Result := 0;
             end;
    end;
end;

function __write(fd: THandle; Buf: Pointer; Size: Integer) : Integer;
var
    Written : Cardinal;
begin
    if not WriteFile(fd, Buf^, Size, Written, nil) then
        Result := -1
    else
        Result := Written;
end;

function __close(fd: THandle) : Integer;
begin
    if CloseHandle(fd) then
        Result := 0
    else
        Result := -1;
end;
{$ENDIF}


end.
