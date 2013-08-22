unit OverbyteIcsSysUtils;

interface

uses
{$IFDEF POSIX}
    Posix.SysTypes, Posix.Errno,
    Posix.Unistd, Posix.Stdio, Posix.SysStatvfs,
    Posix.PThread, Posix.Time,
    Ics.Posix.WinTypes,
  {$IFDEF MACOS}
    Macapi.CoreFoundation,
    MacApi.CoreServices,
  {$ENDIF}
{$ENDIF}
{$IFDEF MSWINDOWS}
    Windows,
{$ENDIF}
    Classes, SysUtils, RtlConsts, SysConst,
    OverbyteIcsAnsiStrings;

type
    TIcsCriticalSection = class
    protected
        FSection: {$IFDEF MSWINDOWS} TRTLCriticalSection;
                  {$ELSE}            pthread_mutex_t;      {$ENDIF}
    public
        constructor Create;
        destructor Destroy; override;
        procedure Enter; {$IFDEF USE_INLINE} inline; {$ENDIF}
        procedure Leave; {$IFDEF USE_INLINE} inline; {$ENDIF}
        function TryEnter: Boolean;
    end;

    procedure IcsCheckOSError(ALastError: Integer); {$IFDEF USE_INLINE} inline; {$ENDIF}
    procedure IcsNameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1));
    function  IcsGetTickCount: LongWord;
    function  IcsCalcTickDiff(const StartTick, EndTick: LongWord): LongWord; {$IFDEF USE_INLINE} inline; {$ENDIF}


implementation


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TIcsCriticalSection.Create;
{$IFDEF POSIX}
var
    LAttr: pthread_mutexattr_t;
{$ENDIF}
begin
    inherited;
  {$IFDEF MSWINDOWS}
    InitializeCriticalSection(FSection);
  {$ENDIF}
  {$IFDEF POSIX}
    IcsCheckOSError(pthread_mutexattr_init(LAttr));
    IcsCheckOSError(pthread_mutexattr_settype(LAttr, PTHREAD_MUTEX_RECURSIVE));
    IcsCheckOSError(pthread_mutex_init(FSection, LAttr));
    pthread_mutexattr_destroy(LAttr);
  {$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TIcsCriticalSection.Destroy;
begin
  {$IFDEF MSWINDOWS}
    DeleteCriticalSection(FSection);
  {$ENDIF}
  {$IFDEF POSIX}
    pthread_mutex_destroy(FSection);
  {$ENDIF}
    inherited;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsCriticalSection.Enter;
begin
  {$IFDEF MSWINDOWS}
    EnterCriticalSection(FSection);
  {$ENDIF}
  {$IFDEF POSIX}
    IcsCheckOSError(pthread_mutex_lock(FSection));
  {$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsCriticalSection.Leave;
begin
  {$IFDEF MSWINDOWS}
    LeaveCriticalSection(FSection);
  {$ENDIF}
  {$IFDEF POSIX}
    IcsCheckOSError(pthread_mutex_unlock(FSection));
  {$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TIcsCriticalSection.TryEnter: Boolean;
begin
  {$IFDEF MSWINDOWS}
    Result := TryEnterCriticalSection(FSection);
  {$ENDIF}
  {$IFDEF POSIX}
    Result := pthread_mutex_trylock(FSection) = 0;
  {$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Warning: Duplicated in OverbyteIcsWndCntrol
function IcsGetTickCount: LongWord;
{$IFDEF MSWINDOWS}
begin
    Result := Windows.GetTickCount;
end;
{$ENDIF}
{$IFDEF POSIX}
{$IFDEF ANDROID}
var
  Res: timespec;
begin
  clock_gettime(CLOCK_MONOTONIC, @Res);
  Result := (Int64(1000000000) * res.tv_sec + res.tv_nsec) div 1000000;
end;
{$ENDIF ANDROID}
{$IFDEF LINUX}
var
    t: tms;
begin
    Result := Cardinal(Int64(Cardinal(times(t)) * 1000) div sysconf(_SC_CLK_TCK));
end;
{$ENDIF LINUX}
{$IFDEF MACOS}
begin
    Result := AbsoluteToNanoseconds(UpTime) div 1000000;
end;
{$ENDIF MACOS}
{$ENDIF POSIX}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function IcsCalcTickDiff(const StartTick, EndTick : LongWord): LongWord;
begin
    if EndTick >= StartTick then
        Result := EndTick - StartTick
    else
        Result := High(LongWord) - StartTick + EndTick;
end;


{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
procedure IcsCheckOSError(ALastError: Integer);
var
    Error: EOSError;
begin
    if ALastError <> 0 then begin
        Error := EOSError.CreateResFmt(@SOSError, [ALastError,
                                       SysErrorMessage(ALastError)]);
        Error.ErrorCode := ALastError;
        raise Error;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure IcsNameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID);
{$IFDEF ANDROID}
begin
    // Not supported on Android
end;
{$ELSE}
{$IFNDEF COMPILER14_UP}
type
    TThreadNameInfo = record
        FType: LongWord;     // must be 0x1000
        FName: PAnsiChar;    // pointer to name (in user address space)
        FThreadID: LongWord; // thread ID (-1 indicates caller thread)
        FFlags: LongWord;    // reserved for future use, must be zero
    end;
var
    ThreadNameInfo: TThreadNameInfo;
begin
    if IsDebuggerPresent then
    begin
        ThreadNameInfo.FType := $1000;
        ThreadNameInfo.FName := PAnsiChar(AThreadName);
        ThreadNameInfo.FThreadID := AThreadID;
        ThreadNameInfo.FFlags := 0;
        try
            RaiseException($406D1388, 0,
                  SizeOf(ThreadNameInfo) div SizeOf(LongWord), @ThreadNameInfo);
        except
        end;
    end;
{$ELSE}
begin
    TThread.NameThreadForDebugging(AThreadName, AThreadID);
{$ENDIF}
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
