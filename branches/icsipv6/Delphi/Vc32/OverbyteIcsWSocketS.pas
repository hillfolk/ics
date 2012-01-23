{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Fran�ois PIETTE
Description:  A TWSocket that has server functions: it listen to connections
              an create other TWSocket to handle connection for each client.
Creation:     Aug 29, 1999
Version:      7.04
EMail:        francois.piette@overbyte.be     http://www.overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1999-2011 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium.
              <francois.piette@overbyte.be>
              SSL implementation includes code written by Arno Garrels,
              Berlin, Germany, contact: <arno.garrels@gmx.de>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Quick reference guide:
TWSocketServer will normally be used to listen on a given tcp port. When a
client connect, it will instanciate a new TWSocketClient component to handle
communication with client. Normally you will derive your own component from
TWSocketClient to add private data and methods to handle it. You tell
TWSocketServer which component it has to instanciate using ClientClass
property. You have to initialize instances from OnClientConnect event handler.
TWSocketServer maintain a list of connected clients. You can access it using
Client[] indexed property and ClientCount property.

History:
Sep 05, 1999 V1.01 Adpted for Delphi 1
Oct 09, 1999 V1.02 Added intermediate class TCustomWSocket
Nov 12, 1999 V1.03 Added OnClientCreate event just after client component has
                   been created.
Apr 02, 2000 V1.04 Added FSessionClosedFlag to avoid double SessionClosed
                   event triggering
Apr 13, 2002 V1.05 When sending banner to client, add LineEnd instead of CR/LF
                   as suggested by David Aguirre Grazio <djagra@xaire.com>
Sep 13, 2002 V1.06 Check if Assigned(Server) in TriggerSessionClosed.
                   Reported by Matthew Meadows <matthew.meadows@inquisite.com>
Sep 16, 2002 V1.07 Fixed a Delphi 1 issue in TriggerSessionClosed where
                   property was used in place of field variable.
Jan 04, 2003 V1.08 Renamed BannerToBusy to BannerTooBusy. This will cause
                   trouble in applications already using this property. You
                   have to rename the property in your app !
Jan 24, 2003 V5.00 Skipped to version 5 because of SSL code
Jan 26, 2004 V5.01 Introduced ICSDEFS.INC and reordered uses for FPC
                   compatibility.
May 01, 2004 V5.02 WMClientClosed was incorrectly referencing global Error
                   variable instead of the real winsock error code. Now pass
                   the errcode in WParam at the time of PostMessage.
                   Removed Forms and Graphics units from the uses clause.
May 23, 2005 V5.03 Added intermediate variable NewHSocket in procedure
                   TriggerSessionAvailable
Dec 30, 2005 V6.00b A.Garrels added IcsLogger
Jan 06, 2008 V6.01 Angus added Disconnect(Client) and DisconnectAll
May 01, 2008 V6.02 A. Garrels - Function names adjusted according to changes in
                   OverbyteIcsLibrary.pas.
May 14, 2008 V6.03 A. Garrels - Type change from String to AnsiString in
                   TWSocketClient (FPeerPort and FPeerAddr).
Aug 11, 2008 V6.04 A. Garrels - Type AnsiString rolled back String.
Nov 6,  2008 V7.00 Angus added CliId property used to ensure correct client freed
                    (did not call it ID to avoid conflicts with existing clients)
Aug 8,  2010 V7.01 FPiette enhanced TriggerSessionAvailable so catch exception
                   in client class constructor and ClientCreate, and close the
                   remote socket in that case.
Feb 4,  2011 V7.02 Angus added bandwidth throttling using TCustomThrottledWSocket.
                   Client sockets inherit server settings for BandwidthLimit and
                   BandwidthSampling, but these can be changed ideally in
                   OnClientCreate event, but also in OnClientConnect but note a
                   timer may have been started by then so better to default to
                   BandwidthLimit=0 and set it, than to disable it.
Apr 15, 2011 V7.03 Arno prepared for 64-bit.
May 13, 2011 V7.04 Anton S. found a small issue with CliId.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit OverbyteIcsWSocketS;

interface

{$B-}           { Enable partial boolean evaluation   }
{$T-}           { Untyped pointers                    }
{$X+}           { Enable extended syntax              }
{ You must define USE_SSL so that SSL code is included in the component.    }
{ Either in OverbyteIcsDefs.inc or in the project/package options.          }
{$I OverbyteIcsDefs.inc}
{$IFDEF COMPILER14_UP}
  {$IFDEF NO_EXTENDED_RTTI}
    {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
  {$ENDIF}
{$ENDIF}
{$IFDEF COMPILER12_UP}
    { These are usefull for debugging !}
    {$WARN IMPLICIT_STRING_CAST       OFF}
    {$WARN IMPLICIT_STRING_CAST_LOSS  OFF}
    {$WARN EXPLICIT_STRING_CAST       OFF}
    {$WARN EXPLICIT_STRING_CAST_LOSS  OFF}
{$ENDIF}
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}
{$IFNDEF VER80}   { Not for Delphi 1                    }
    {$H+}         { Use long strings                    }
    {$J+}         { Allow typed constant to be modified }
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}

uses
{$IFDEF MSWINDOWS}
    Messages,
    Windows,
    OverbyteIcsWinsock,
{$ENDIF}
{$IFDEF POSIX}
    Posix.Errno,
    Posix.NetinetIn,
    Posix.SysSocket,
    Ics.Posix.WinTypes,
    Ics.Posix.Messages,
{$ENDIF}
    Classes,
{$IFNDEF NO_DEBUG_LOG}
    OverbyteIcsLogger,
{$ENDIF}

    OverbyteIcsUtils, OverbyteIcsTypes, OverbyteIcsLibrary,
    OverbyteIcsWSocket;

const
    WSocketServerVersion     = 704;
    CopyRight : String       = ' TWSocketServer (c) 1999-2011 F. Piette V7.04 ';
    DefaultBanner            = 'Welcome to OverByte ICS TcpSrv';

type
    TCustomWSocketServer       = class;
    TWSocketClient             = class;
    TWSocketClientClass        = class of TWSocketClient;
    TWSocketClientCreateEvent  = procedure (Sender : TObject;
                                            Client : TWSocketClient) of object;
    TWSocketClientConnectEvent = procedure (Sender : TObject;
                                            Client : TWSocketClient;
                                            Error  : Word) of object;

    TClientIdRec = record    { angus V7.00 }
        PClient : Pointer;
        CliId   : LongInt;
    end;
    PClientIdRec = ^TClientIdRec;

    { TWSocketClient is used to handle all client connections.           }
    { Altough you may use it directly, you'll probably wants to use your }
    { own derived component to add data and methods suited to your       }
    { application.                                                       }
    { If you use a derived component, then assign it's class to          }
    { TWSocketServer ClientClass property.                               }
    TWSocketClient = class(TWSocket)
    protected
        FBanner            : String;
        FServer            : TCustomWSocketServer;
        FPeerAddr          : String;
        FPeerPort          : String;
        FSessionClosedFlag : Boolean;
        {$IFDEF CLR}
        FHandleGc          : GCHandle;
        {$ENDIF}
        FCliId             : LongInt;          { angus V7.00 }

    public
        procedure   StartConnection; virtual;
        procedure   TriggerSessionClosed(ErrCode : Word); override;
        procedure   Dup(newHSocket : TSocket); override;
        function    GetPeerAddr: String; override;
        function    GetPeerPort: String; override;
        property    Server : TCustomWSocketServer read  FServer
                                                  write FServer;
        {$IFDEF CLR}
        property    HandleGc : GCHandle           read  FHandleGc
                                                  write FHandleGc;
        {$ENDIF}
        property    CliId : LongInt               read  FCliId              { angus V7.00 }
                                                  write FCliId;
    published
        property    Banner : String               read  FBanner
                                                  write FBanner;
    end;

    { TWSocketServer is made for listening for tcp client connections.      }
    { For each connection, it instanciate a new TWSocketClient (or derived) }
    { to handle connection. Use ClientClass to specify your derived.        }
    TCustomWSocketServer = class(TWSocket)
    protected
        FBanner                 : String;
        FBannerTooBusy          : String;
        FClientClass            : TWSocketClientClass;
        FClientList             : TList;
        FClientNum              : LongInt;
        FMaxClients             : LongInt;
        FMsg_WM_CLIENT_CLOSED   : UINT;
        FOnClientCreate         : TWSocketClientCreateEvent;
        FOnClientConnect        : TWSocketClientConnectEvent;
        FOnClientDisconnect     : TWSocketClientConnectEvent;
        procedure WndProc(var MsgRec: TMessage); override;
{$IFNDEF CLR}
        procedure Notification(AComponent: TComponent; operation: TOperation); override;
{$ENDIF}
        procedure TriggerSessionAvailable(Error : Word); override;
        procedure TriggerClientCreate(Client : TWSocketClient); virtual;
        procedure TriggerClientConnect(Client : TWSocketClient; Error : Word); virtual;
        procedure TriggerClientDisconnect(Client : TWSocketClient; Error : Word); virtual;
        function  GetClientCount : Integer; virtual;
        function  GetClient(nIndex : Integer) : TWSocketClient; virtual;
        procedure WMClientClosed(var msg: TMessage); virtual;
        function  MsgHandlersCount: Integer; override;
        procedure AllocateMsgHandlers; override;
        procedure FreeMsgHandlers; override;
    public
{$IFDEF CLR}
    constructor Create; override;
{$ELSE}
    constructor Create(AOwner: TComponent); override;
{$ENDIF}
        destructor  Destroy; override;
        { Check  if a given object is one of our clients }
        function  IsClient(SomeThing : TObject) : Boolean;
        procedure Disconnect(Client: TWSocketClient); virtual;        { angus V6.01 }
        procedure DisconnectAll; virtual;                             { angus V6.01 }
    protected
        { TWSocketClient derived class to instanciate for each client }
        property  ClientClass            : TWSocketClientClass
                                                      read  FClientClass
                                                      write FClientClass;
        { How many active clients we currently have }
        property  ClientCount   : Integer             read  GetClientCount;
        { Client[] give direct access to anyone of our clients }
        property  Client[nIndex : Integer] : TWSocketClient
                                                      read  GetClient;
    published
        { Banner sent to client as welcome message. Can be empty. }
        property  Banner                 : String     read  FBanner
                                                      write FBanner;
        property  BannerTooBusy          : String     read  FBannerTooBusy
                                                      write FBannerTooBusy;
        property  MaxClients             : LongInt    read  FMaxClients
                                                      write FMaxClients;
        { Triggered when a client disconnect }
        property  OnClientDisconnect     : TWSocketClientConnectEvent
                                                      read  FOnClientDisconnect
                                                      write FOnClientDisconnect;
        { Triggered when a new client is connecting }
        property  OnClientConnect        : TWSocketClientConnectEvent
                                                      read  FOnClientConnect
                                                      write FOnClientConnect;
        { Triggered when a new client component has been created }
        property  OnClientCreate         : TWSocketClientCreateEvent
                                                      read  FOnClientCreate
                                                      write FOnClientCreate;
    end;

    TWSocketServer = class;

    TCustomMultiListenWSocketServer = class;

    TWSocketMultiListenItem = class(TCollectionItem {$IFDEF POSIX}, IIcsEventSource{$ENDIF})
    private
      FAddr: string;
      FHSocket: TSocket;
      FListenBacklog: Integer;
      FPort: string;
      FSocketFamily: TSocketFamily;
      FOldSocketFamily: TSocketFamily;
      FState: TSocketState;
      FPortNum: Integer;
      FLastError: Integer;
      FCloseInvoked: Boolean;
      FPaused: Boolean;
      procedure SetAddr(const Value: string);
      procedure SetSocketFamily(const Value: TSocketFamily);
      function GetAddrResolved: string;
  {$IFDEF POSIX} { IIcsEventSource }
    strict private
      FPxEventMask        : LongWord;
      FPxFileDescriptor   : Integer;
      FPxEventState       : TIcsAsyncEventState;
      FPxEventMessageID   : UINT;
      FPxEventWindow      : HWND;
      FPxObjectID         : NativeInt;
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
      function  GetEventMask: LongWord;
      procedure SetEventMask(const AValue: LongWord);
      function  GetNotifyMessageID: UINT;
      procedure SetNotifyMessageID(const AValue: UINT);
      function  GetNotifyWindow: HWND;
      function  GetEventState: TIcsAsyncEventState;
      function  GetFileDescriptor: Integer;
      procedure SetFileDescriptor(const AValue: Integer);
      function  GetObject: TObject;
      procedure SetEventState(const AValue: TIcsAsyncEventState);
      procedure SetNotifyWindow(const AValue: HWND);
      function  GetObjectID: NativeInt;
  {$ENDIF POSIX IIcsEventSource}
    protected
      procedure AssignDefaults; virtual;
      procedure SetCloseInvoked(const AValue: Boolean);
      function  GetCloseInvoked: Boolean;
      property  CloseInvoked: Boolean read GetCloseInvoked write SetCloseInvoked;
    public
      Fsin: TSockAddrIn6;
      constructor Create(Collection: TCollection); override;
      destructor Destroy; override;
      procedure Close;
      procedure Listen;
      function  OwnerServer: TCustomMultiListenWSocketServer;
      function  Pause: Boolean;
      function  Resume: Boolean;
      property  AddrResolved: string read GetAddrResolved;
      property  HSocket: TSocket read FHSocket write FHSocket;
      property  LastError: Integer read FLastError write FLastError;
      property  Paused: Boolean read FPaused;
      property  PortNum: Integer read FPortNum write FPortNum;
      property  State: TSocketState read FState write FState;
    published
      property Addr: string read FAddr write SetAddr;
      property ListenBacklog: Integer           read  FListenBacklog
                                                write FListenBacklog default 5;
      property Port: string read FPort write FPort;
      property SocketFamily: TSocketFamily      read  FSocketFamily
                                                write SetSocketFamily
                                                default DefaultSocketFamily;
    end;

    TWSocketMultiListenItemClass = class of TWSocketMultiListenItem;

    TWSocketMultiListenCollection = class(TOwnedCollection)
    protected
      function GetItem(Index: Integer): TWSocketMultiListenItem;
        {$IFDEF USE_INLINE} inline; {$ENDIF}
      procedure SetItem(Index: Integer; Value: TWSocketMultiListenItem);
        {$IFDEF USE_INLINE} inline; {$ENDIF}
    public
      constructor Create(AOwner     : TPersistent;
                         AItemClass : TWSocketMultiListenItemClass);
      function Add: TWSocketMultiListenItem;
          {$IFDEF USE_INLINE} inline; {$ENDIF}
      function FindItemIndex(const AHSocket: TSocket): Integer;
          {$IFDEF USE_INLINE} inline; {$ENDIF}
      function FindItemHandle(const AHSocket: TSocket): TWSocketMultiListenItem;
      function FindItemID(ID: Integer): TWSocketMultiListenItem;
          {$IFDEF USE_INLINE} inline; {$ENDIF}
      function Insert(Index: Integer): TWSocketMultiListenItem;
          {$IFDEF USE_INLINE} inline; {$ENDIF}
      function Owner: TCustomMultiListenWSocketServer;
      property Items[Index: Integer]: TWSocketMultiListenItem
                                                        read  GetItem
                                                        write SetItem; default;
    end;

    TCustomMultiListenWSocketServer = class(TCustomWSocketServer)
    private
        FMultiListenSockets: TWSocketMultiListenCollection;
        FMultiListenIndex: Integer;
    protected
        procedure Ml_Do_FD_CLOSE(AItem: TWSocketMultiListenItem;
                                  AMsg: TMessage); virtual;
        procedure MlListen(AItem: TWSocketMultiListenItem); virtual;
        procedure MlClose(AItem: TWSocketMultiListenItem); virtual;
        procedure MlSocketError(AItem           : TWSocketMultiListenItem;
                                const ASockFunc : String;
                                ALastError      : Integer = 0); virtual;
        procedure MlPause(AItem: TWSocketMultiListenItem); virtual;
        procedure MlResume(AItem: TWSocketMultiListenItem); virtual;
        procedure MlSetAddr(var FldAddr              : string;
                            var FldSocketFamily      : TSocketfamily;
                            const FldOldSocketFamily : TSocketfamily;
                            const NewValue           : string); virtual;
        procedure MlSetSocketFamily(var FldSocketFamily    : TSocketfamily;
                                    var FldOldSocketFamily : TSocketfamily;
                                    const NewValue         : TSocketFamily);
        function  MultiListenItemClass: TWSocketMultiListenItemClass; virtual;
        procedure SetMultiListenIndex(const Value: Integer);
        procedure TriggerClientConnect(Client: TWSocketClient; Error: Word); override;
        procedure WMASyncSelect(var msg: TMessage); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        function  Accept: TSocket; override;
        procedure Close; override;
        procedure Listen; override;
        procedure MultiListen; virtual;
        procedure MultiClose; virtual;
        procedure ThreadAttach; override;
        procedure ThreadDetach; override;
        property  MultiListenIndex: Integer read  FMultiListenIndex;

        property  MultiListenSockets: TWSocketMultiListenCollection
                                                      read  FMultiListenSockets
                                                      write FMultiListenSockets;
    end;

    TWSocketServer = class(TCustomMultiListenWSocketServer)
    public
        property  ClientClass;
        property  ClientCount;
        property  Client;
    published
    {$IFNDEF NO_DEBUG_LOG}
        property  IcsLogger;                                 { V5.04 }
    {$ENDIF}
        property  Banner;
        property  BannerTooBusy;
        property  MaxClients;
        property  MultiListenSockets;
        property  OnClientDisconnect;
        property  OnClientConnect;
    end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ Either in OverbyteIcsDefs.inc or in the project/package options.          }
{$IFDEF USE_SSL}
{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Fran�ois PIETTE
Description:  A component adding SSL support to TWSocketServer.
              Requires OpenSSL (http://www.openssl.org).
              More details in ReadMeIcsSsl.txt and IcsSslHowTo.txt.
              SSL demo applications can be found in /Delphi/SslInternet.
              If you use Delphi 7 and later, you may want to disable warnings
              for unsage type, unsafe code and unsafe typecast in the project
              options. Those warning are intended for .NET programs. You may
              also want to turn off deprecated symbol and platform symbol
              warnings.

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
const
     SslWSocketServerVersion            = 100;
     SslWSocketServerDate               = 'Feb 02, 2003';
     SslWSocketServerCopyRight : String = ' TSslWSocket (c) 2003 Francois Piette V1.00.3 ';

type
    TSslWSocketMultiListenItem = class(TWSocketMultiListenItem)
    private
      FSslEnable : Boolean;
    public
      constructor Create(Collection: TCollection); override;
    published
      property SslEnable : Boolean read FSslEnable write FSslEnable;
    end;

    TSslWSocketClient = class(TWSocketClient)
    public
        constructor Create(AOwner : TComponent); override;
        procedure   StartConnection; override;
    end;

    TSslWSocketServer = class(TWSocketServer)
    protected
        procedure TriggerClientConnect(Client : TWSocketClient; Error : Word); override;
        function  MultiListenItemClass: TWSocketMultiListenItemClass; override;
    public
        constructor Create(AOwner : TComponent); override;
        property  ClientClass;
        property  ClientCount;
        property  Client;
        property  SslMode;
    published
        property  SslContext;
        property  Banner;
        property  BannerTooBusy;
        property  MaxClients;
        property  OnClientDisconnect;
        property  OnClientConnect;
        property  SslEnable;
        property  SslAcceptableHosts;
        property  OnSslVerifyPeer;
        property  OnSslSetSessionIDContext;
        property  OnSslSvrNewSession;
        property  OnSslSvrGetSession;
        property  OnSslHandshakeDone;
    end;
{$ENDIF} // USE_SSL

implementation


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TCustomWSocketServer.Create{$IFNDEF CLR}(AOwner: TComponent){$ENDIF};
begin
    inherited Create{$IFNDEF CLR}(AOwner){$ENDIF};
    FClientList      := TList.Create;
    FClientClass     := TWSocketClient;
    FBanner          := DefaultBanner;
    FBannerTooBusy   := 'Sorry, too many clients';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomWSocketServer.Destroy;
var
    I : Integer;
begin
    if Assigned(FClientList) then begin
        { We need to destroy all clients }
        for I := FClientList.Count - 1 downto 0 do begin
            try
                {$IFDEF CLR}
                TWSocketClient(FClientList.Items[I]).HandleGc.Free;
                {$ENDIF}
                TWSocketClient(FClientList.Items[I]).Free;
            except
                { Ignore any exception here }
            end;
        end;
        { Then we can destroy client list }
        FClientList.Free;
        FClientList := nil;
    end;
    { And finally destroy ourself }
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocketServer.MsgHandlersCount : Integer;
begin
    Result := 1 + inherited MsgHandlersCount;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.AllocateMsgHandlers;
begin
    inherited AllocateMsgHandlers;
    FMsg_WM_CLIENT_CLOSED := FWndHandler.AllocateMsgHandler(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.FreeMsgHandlers;
begin
    if Assigned(FWndHandler) then
        FWndHandler.UnregisterMessage(FMsg_WM_CLIENT_CLOSED);
    inherited FreeMsgHandlers;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Message handler                                                           }
procedure TCustomWSocketServer.WndProc(var MsgRec: TMessage);
begin
    with MsgRec do begin
        if Msg = FMsg_WM_CLIENT_CLOSED then begin
            { We *MUST* handle all exception to avoid application shutdown }
            try
                WMClientClosed(MsgRec)
            except
                on E:Exception do
                    HandleBackGroundException(E);
            end;
        end
        else
            inherited WndProc(MsgRec);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Called by destructor when child component (a clients) is create or        }
{ destroyed.                                                                }
{$IFNDEF CLR}
procedure TCustomWSocketServer.Notification(
    AComponent : TComponent;
    Operation  : TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Assigned(FClientList) and (AComponent is TWSocketClient) then begin
        if Operation = opInsert then
            { A new client has been created, add it to our list }
            FClientList.Add(AComponent)
        else if Operation = opRemove then
            { If one of our client has been destroyed, remove it from our list }
            FClientList.Remove(AComponent);
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Called when a session is available, that is when a client is connecting   }
procedure TCustomWSocketServer.TriggerSessionAvailable(Error : Word);
var
    Client     : TWSocketClient;
    TempHandle : TSocket;
begin
{$IFDEF DEBUG_OUTPUT}
    OutputDebugString('OnSessionAvailable');
{$ENDIF}
    { Call parent event handler }
    inherited TriggerSessionAvailable(Error);
    { In case of error, do nothing }
    if Error <> 0 then
        Exit;

    if Cardinal(FClientNum) >= Cardinal(MaxInt) then    { V7.04 }
        FClientNum := 0;                                { angus V7.00 }
    Inc(FClientNum);
    Client := nil;
    try                                                 { FPiette V7.01 }
        Client                 := FClientClass.Create(Self);
        Client.FCliId          := FClientNum;           { angus V7.00 }
{$IFDEF BUILTIN_THROTTLE}
        Client.BandwidthLimit    := Self.BandwidthLimit;     { angus V7.02 may be changed in event for different limit }
        Client.BandwidthSampling := Self.BandwidthSampling;  { angus V7.02 }
{$ENDIF}
        TriggerClientCreate(Client);
    except                                               { FPiette V7.01 }
        try                                              { FPiette V7.01 }
            TempHandle := Accept;                        { FPiette V7.01 }
            if TempHandle <> INVALID_SOCKET then         { FPiette V7.01 }
                WSocket_closesocket(TempHandle);         { FPiette V7.01 }
            if Assigned(Client) then                     { FPiette V7.01 }
                Client.Free;                             { FPiette V7.01 }
        except                                           { FPiette V7.01 }
            // safely ignore any exception here. Component user may already
            // have accepted and closed the connection.
        end;                                             { FPiette V7.01 }
        raise;                                           { FPiette V7.01 }
    end;                                                 { FPiette V7.01 }
    Client.Name            := Name + 'Client' + _IntToStr(FClientNum);
    Client.Banner          := FBanner;
    Client.Server          := Self;
{$IFNDEF NO_DEBUG_LOG}
    Client.IcsLogger       := IcsLogger;                           { V5.04 }
{$ENDIF}
{$IFDEF MSWINDOWS}
    Client.HSocket         := Accept;
{$ENDIF}
{$IFDEF POSIX}
    TempHandle := Accept;
    { Accept() doesn't raise a socket error for WSAEWOULDBLOCK in POSIX. }
    { IMO Accept() should never raise a socket error here but we should  }
    { call Dup() only if Accept() returned a valid socket handle,        }
    { otherwise pass the error code to TriggerClientConnect() and free   }
    { the client object afterwards, so this is just a workaround.  AG    }
    if (TempHandle = INVALID_SOCKET) and (LastError = WSAEWOULDBLOCK) then
        Error := LastError
    else
        Client.HSocket := TempHandle;
{$ENDIF}
    TriggerClientConnect(Client, Error);
    { The event handler may have destroyed the client ! }
    if FClientList.IndexOf(Client) < 0 then
        Exit;
{$IFDEF POSIX}
    if Error <> 0 then begin
        Client.Free;
        Exit;
    end;
{$ENDIF}
    { The event handler may have closed the connection }
    if Client.State <> wsConnected then
        Exit;
    { Ok, the client is still there, process with the connection }
    if (FMaxClients > 0) and (FMaxClients < ClientCount) then begin
        { Sorry, toomuch clients }
        Client.Banner := FBannerTooBusy;
        Client.StartConnection;
        Client.Close;
    end
    else
        Client.StartConnection;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.TriggerClientConnect(
    Client : TWSocketClient; Error : Word);
begin
    if Assigned(FOnClientConnect) then
        FOnClientConnect(Self, Client, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.TriggerClientCreate(Client : TWSocketClient);
begin
    if Assigned(FOnClientCreate) then
        FOnClientCreate(Self, Client);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.TriggerClientDisconnect(
    Client : TWSocketClient; Error : Word);
begin
    if Assigned(FOnClientDisconnect) then
        FOnClientDisconnect(Self, Client, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ get number of connect clients                                               }
function TCustomWSocketServer.GetClientCount : Integer;
begin
    if Assigned(FClientList) then
        Result := FClientList.Count
    else
        Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Acces method to return a client by index.                                   }
{ Return nil if index is out of range.                                        }
function TCustomWSocketServer.GetClient(nIndex : Integer) : TWSocketClient;
begin
    if not Assigned(FClientList) then begin
        Result := nil;
        Exit;
    end;
    if (nIndex < 0) or (nIndex >= FClientList.Count) then begin
        Result := nil;
        Exit;
    end;
    Result := TWSocketClient(FClientList.Items[nIndex]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Client has closed. Remove it from client list and destroy component.        }
procedure TCustomWSocketServer.WMClientClosed(var msg: TMessage);
var
    Client : TWSocketClient;
    PIdRec : PClientIdRec;
{$IFDEF CLR}
    GCH          : GCHandle;
{$ENDIF}
begin
    PIdRec := PClientIdRec(Msg.LParam);  { angus V7.00 }
    try
{$IFDEF CLR}
    GCH := GCHandle(IntPtr(PIdRec^.PClient);
    Client := TWSocketClient(GCH.Target);
{$ELSE}
    Client := TWSocketClient(PIdRec^.PClient);
{$ENDIF}
    { angus V7.00 ensure client not freed already }
    if IsClient(Client) and (Client.CliId = PIdRec^.CliId) then
    try
        TriggerClientDisconnect(Client, Msg.WParam);
    finally
        { Calling Free will automatically remove client from list because    }
        { we installed a notification handler.                               }
{$IFDEF CLR}
        FClientList.Remove(Client);
        Client.HandleGc.Free;
{$ENDIF}
        Client.Free;
    end;
    finally
        System.Dispose(PIdRec);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Check if a given object is one of our clients.                              }
function TCustomWSocketServer.IsClient(SomeThing : TObject) : Boolean;
begin
    if not Assigned(FClientList) then
        Result := FALSE
    else
        Result := (FClientList.IndexOf(SomeThing) >= 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.Disconnect(Client: TWSocketClient);        { angus V6.01 }
var
    Msg : TMessage;
    PIdRec : PClientIdRec;
begin
    FillChar(Msg, SizeOf(Msg), 0);
{ angus V7.00 pass CliId to WMClientClosed so correct client is closed  }
    New(PIdRec);
    PIdRec^.PClient := Client;
    PIdRec^.CliId   := Client.CliId;
    Msg.WParam      := WSAECONNABORTED;
    Msg.LParam      := LPARAM(PIdRec);
    WMClientClosed(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocketServer.DisconnectAll;                             { angus V6.01 }
begin
    while ClientCount > 0 do
        Disconnect(Client[0]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{*                                                                           *}
{*                   TCustomMultiListenWSocketServer                         *}
{*                                                                           *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function SizeOfAddr(const AAddr: TSockAddrIn6): Integer;
    {$IFDEF USE_INLINE} inline; {$ENDIF}
begin
    if AAddr.sin6_family = AF_INET6 then
        Result := SizeOf(TSockAddrIn6)
    else
        Result := SizeOf(TSockAddrIn);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomMultiListenWSocketServer.Accept: TSocket;
var
    Len     : Integer;
    AItem   : TWSocketMultiListenItem;
  {$IFDEF POSIX}
    LastErr : Integer;
  {$ENDIF}
begin
    if FMultiListenIndex = -1 then
    begin
        Result := inherited Accept;
    end
    else begin
      {$IFDEF POSIX}
        AItem := nil;
        try
      {$ENDIF}
            AItem := FMultiListenSockets[FMultiListenIndex];
            if AItem.State <> wsListening then begin
                WSocket_WSASetLastError(WSAEINVAL);
                MlSocketError(AItem, 'not a listening socket');
                Result := INVALID_SOCKET;
                Exit;
            end;
            Len := SizeOf(AItem.Fsin);
            FASocket := WSocket_Accept(AItem.HSocket, @AItem.Fsin, @Len);
            Result := FASocket;
            if FASocket = INVALID_SOCKET then begin
              {$IFDEF MSWINDOWS}
                MlSocketError(AItem, 'Accept');
              {$ENDIF}
              {$IFDEF POSIX}
                LastErr := WSocket_WSAGetLastError;
                if LastErr <> WSAEWOULDBLOCK then
                    MlSocketError(AItem, 'Accept', LastErr);
              {$ENDIF}
                Exit;
            end;
      {$IFDEF POSIX}
        finally
            if (AItem <> nil) and (AItem.State = wsListening) then
                WSocketSynchronizedEnableAcceptEvent(AItem);
        end;
      {$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.Close;
begin
    FMultiListenIndex := -1;
    inherited;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TCustomMultiListenWSocketServer.Create(AOwner: TComponent);
begin
    inherited;
    FMultiListenIndex := -1;
    FMultiListenSockets := TWSocketMultiListenCollection.Create(
                              Self, MultiListenItemClass);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomMultiListenWSocketServer.Destroy;
begin
  FMultiListenSockets.Free;
  inherited;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.Listen;
begin
    FMultiListenIndex := -1;
    inherited Listen;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlClose(
  AItem: TWSocketMultiListenItem);
var
    iStatus : Integer;
begin
    FMultiListenIndex := AItem.Index;
    if AItem.HSocket = INVALID_SOCKET then
    begin
        AItem.AssignDefaults;
        Exit;
    end;

    if AItem.State = wsClosed then
        Exit;

    if AItem.HSocket <> INVALID_SOCKET then begin
        repeat
            { Close the socket }
            iStatus := WSocket_closesocket(AItem.HSocket);
            if iStatus <> 0 then begin
                AItem.LastError := WSocket_WSAGetLastError;
                if AItem.LastError <> WSAEWOULDBLOCK then begin
                  {$IFDEF POSIX}
                    WSocketSynchronizedRemoveEvents(AItem, False);
                    IcsClearMessages(Handle, FMsg_WM_ASYNCSELECT, WPARAM(AItem.HSocket));
                  {$ENDIF}
                    AItem.HSocket := INVALID_SOCKET;
                  {$IFDEF MSWINDOWS}
                    { Ignore the error occuring when winsock DLL not      }
                    { initialized (occurs when using TWSocket from a DLL) }
                    if AItem.LastError = WSANOTINITIALISED then
                        Break;
                  {$ENDIF}
                    MlSocketError(AItem, 'Disconnect (closesocket)');
                    Exit;
                end;
                MessagePump;
            end;
        until iStatus = 0;
      {$IFDEF POSIX}
        WSocketSynchronizedRemoveEvents(AItem, True);
        IcsClearMessages(Handle, FMsg_WM_ASYNCSELECT, WPARAM(AItem.HSocket));
      {$ENDIF}
        AItem.HSocket := INVALID_SOCKET;
    end;
    AItem.State := wsClosed;
    if (not (csDestroying in ComponentState)) and
       (not AItem.CloseInvoked) {and Assigned(FOnSessionClosed)} then begin
        AItem.CloseInvoked := TRUE;
        TriggerSessionClosed(0);
    end;
    { 29/09/98 Protect AssignDefaultValue because SessionClosed event handler }
    { may have destroyed the component.                                       }
    try
        AItem.AssignDefaults;
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlSocketError(
    AItem: TWSocketMultiListenItem;
    const ASockFunc: String;
    ALastError: Integer = 0);
var
    ErrCode  : Integer;
    Line : String;
begin
    FMultiListenIndex := AItem.Index;
    try
        if ALastError = 0 then
            ErrCode := WSocket_WSAGetLastError
        else
            ErrCode := ALastError;
        Line  := 'Listening socket index #' + _IntToStr(FMultiListenIndex) + ' ' +
                  WSocketErrorDesc(ErrCode) + ' (#' + _IntToStr(ErrCode) +
                  ' in ' + ASockFunc + ')' ;

        if (ErrCode = WSAECONNRESET) or
           (ErrCode = WSAENOTCONN) then begin
            WSocket_closesocket(AItem.HSocket);
            AItem.HSocket := INVALID_SOCKET;
            if AItem.State <> wsClosed then
               TriggerSessionClosed(ErrCode);
            AItem.State := wsClosed;
        end;

        AItem.LastError := ErrCode;
        LastError := ErrCode;
        RaiseException(Line);
    finally
        FMultiListenIndex := -1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.Ml_Do_FD_CLOSE(
    AItem : TWSocketMultiListenItem;
    AMsg  : TMessage);
begin
    if (AItem.HSocket <> INVALID_SOCKET) then begin
        if not AItem.CloseInvoked then
        begin
            AItem.CloseInvoked := TRUE;
            TriggerSessionClosed(IcsHiWord(AMsg.LParam));
        end;
        if AItem.State <> wsClosed then
            MlClose(AItem);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlListen(
    AItem: TWSocketMultiListenItem);
var
    iStatus : Integer;
begin
    FMultiListenIndex := AItem.Index;
    try
        if (AItem.State <> wsClosed) then begin
            WSocket_WSASetLastError(WSAEINVAL);
            MlSocketError(AItem, 'listen: socket is already listening');
            Exit;
        end;

        if _LowerCase(FProtoStr) <> 'tcp' then begin
            WSocket_WSASetLastError(WSAEINVAL);
            MlSocketError(AItem, 'listen: protocol unsupported');
            Exit;
        end;

        if AItem.Port = '' then begin
            WSocket_WSASetLastError(WSAEINVAL);
            MlSocketError(AItem, 'listen: port not assigned');
            Exit;
        end;

        if AItem.Addr = '' then begin
            //WSocket_Synchronized_WSASetLastError(WSAEINVAL);
            WSocket_WSASetLastError(WSAEINVAL);
            MlSocketError(AItem, 'listen: address not assigned');
            Exit;
        end;

        try
            { The next line will trigger an exception in case of failure }
            AItem.PortNum := WSocketResolvePort(
                                  AnsiString(AItem.Port), AnsiString('tcp'));
            AItem.Fsin.sin6_port := WSocket_htons(AItem.PortNum);

            { The next line will trigger an exception in case of failure }
            if AItem.SocketFamily = sfIPv4 then
            begin
                AItem.Fsin.sin6_family := AF_INET;
                PSockAddrIn(@AItem.Fsin).sin_addr.s_addr :=
                    WSocketResolveHost(AnsiString(AItem.Addr)).s_addr;
            end
            else
                WSocketResolveHost(AItem.Addr, AItem.Fsin, AItem.SocketFamily);
        except
            on E: Exception do begin
                AItem.AssignDefaults;
                raise ESocketException.Create('listen: ' + E.Message);
            end;
        end;

        { Remove any data from the internal output buffer }
        { (should already be empty !)                     }
        DeleteBufferedData;

        AItem.HSocket :=
          WSocket_socket(AItem.Fsin.sin6_family, SOCK_STREAM, IPPROTO_TCP);
        if AItem.HSocket = INVALID_SOCKET then begin
            MlSocketError(AItem, 'listen: socket');
            Exit;
        end;

        iStatus := WSocket_bind(AItem.HSocket, PSockAddr(@AItem.Fsin)^,
                                           SizeOfAddr(AItem.Fsin));
        if iStatus = 0 then
            AItem.State := wsBound
        else begin
            MlSocketError(AItem, 'listen: Bind');
            MlClose(AItem);
            Exit;
        end;

        iStatus := WSocket_listen(AItem.HSocket, AItem.ListenBacklog);
        if iStatus = 0 then
            AItem.State := wsListening
        else begin
            MlSocketError(AItem, 'listen: Listen');
            Exit;
        end;

        iStatus := WSocket_WSAASyncSelect(
                                        {$IFDEF POSIX}
                                          AItem,
                                        {$ENDIF}
                                          AItem.HSocket,
                                          Handle,
                                          FMsg_WM_ASYNCSELECT,
                                          FD_ACCEPT or FD_CLOSE);
        if iStatus <> 0 then begin
            MlSocketError(AItem, 'listen: WSAASyncSelect');
            Exit;
        end;
    finally
        FMultiListenIndex := -1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlPause(
    AItem: TWSocketMultiListenItem);
begin
    if not AItem.Paused then
        AItem.FPaused := WSocket_WSAASyncSelect(
                                              {$IFDEF POSIX}
                                                AItem,
                                              {$ENDIF}
                                                AItem.HSocket,
                                                Handle, 0, 0) = 0;

end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MLResume(
    AItem: TWSocketMultiListenItem);
begin
    if AItem.Paused then
        AItem.FPaused := not (WSocket_WSAASyncSelect(
                                                {$IFDEF POSIX}
                                                  AItem,
                                                {$ENDIF}
                                                  AItem.HSocket,
                                                  Handle,
                                                  FMsg_WM_ASYNCSELECT,
                                                  FD_ACCEPT or FD_CLOSE) = 0);

end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlSetAddr(
  var FldAddr: string; var FldSocketFamily: TSocketfamily;
  const FldOldSocketFamily: TSocketfamily;
  const NewValue: string);
var
    LSocketFamily: TSocketFamily;
begin
    FldAddr := _Trim(NewValue);
    if FldAddr = '' then
        Exit;
    { If the address is either a valid IPv4 or IPv6 address }
    { change current SocketFamily.                          }
    if WSocketIsIP(FldAddr, LSocketFamily) then
    begin
        if (LSocketFamily = sfIPv4) or (IsIPv6APIAvailable) then
            FldSocketFamily := LSocketFamily
        else
            FldSocketFamily := FldOldSocketFamily;
    end
    else
        FldSocketFamily := FldOldSocketFamily;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MlSetSocketFamily(
  var FldSocketFamily: TSocketfamily;
  var FldOldSocketFamily: TSocketfamily;
  const NewValue: TSocketFamily);
begin
    if NewValue <> FldSocketFamily then begin
        if NewValue <> sfIPv4 then begin
            try
                if not IsIPv6APIAvailable then
                    raise ESocketException.Create(
                     'SetSocketFamily: New API requires winsock 2.2 ' +
                     'and Windows XP, property "SocketFamily" reset to "sfIPv4"');
            except
                FldSocketFamily := sfIPv4;
                FldOldSocketFamily := FldSocketFamily;
                Exit;
            end;
        end;
        FldSocketFamily := NewValue;
        FldOldSocketFamily :=FldSocketFamily;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MultiClose;
var
    I: Integer;
begin
    if State <> wsClosed then
        Close;
    if Assigned(FMultiListenSockets) then begin
        for I := 0 to FMultiListenSockets.Count - 1 do
            if FMultiListenSockets[I].State <> wsClosed then
                MlClose(FMultiListenSockets[I]);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.MultiListen;
var
    I: Integer;
begin
    if State <> wsListening then
        Listen;
    if Assigned(FMultiListenSockets) then
        for I := 0 to FMultiListenSockets.Count - 1 do
            if FMultiListenSockets[I].State <> wsListening then
            MlListen(FMultiListenSockets[I]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomMultiListenWSocketServer.MultiListenItemClass: TWSocketMultiListenItemClass;
begin
    Result := TWSocketMultiListenItem;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.SetMultiListenIndex(
  const Value: Integer);
begin
    FMultiListenIndex := Value;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.ThreadAttach;
var
    I : Integer;
    LItem : TWSocketMultiListenItem;
begin
    FMultiListenIndex := -1;
    inherited ThreadAttach;
    for I := 0 to FMultiListenSockets.Count -1 do begin
        LItem := FMultiListenSockets[I];
        if (LItem.HSocket <> INVALID_SOCKET) then
            WSocket_WSAASyncSelect(
                                  {$IFDEF POSIX}
                                    LItem,
                                  {$ENDIF}
                                    LItem.HSocket,
                                    Handle, FMsg_WM_ASYNCSELECT,
                                    FD_ACCEPT or FD_CLOSE);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.ThreadDetach;
var
    I : Integer;
    LItem : TWSocketMultiListenItem;
begin
    FMultiListenIndex := -1;
    inherited ThreadDetach;
    for I := 0 to FMultiListenSockets.Count -1 do begin
        LItem := FMultiListenSockets[I];
        if (LItem.HSocket <> INVALID_SOCKET) then
            WSocket_WSAASyncSelect(
                                  {$IFDEF POSIX}
                                    LItem,
                                  {$ENDIF}
                                    LItem.HSocket,
                                    Handle, 0, 0);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.TriggerClientConnect(
    Client : TWSocketClient; Error : Word);
begin
    inherited TriggerClientConnect(Client, Error);
    { Finally reset the MultiListenIndex just to avoid bad component use }
    FMultiListenIndex := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomMultiListenWSocketServer.WMASyncSelect(var msg: TMessage);
var
    Check   : Word;
    ParamLo : Word;
    AItem   : TWSocketMultiListenItem;
begin
    if msg.wParam = WPARAM(FHSocket) then begin
        FMultiListenIndex := -1;

        if FPaused then
          Exit;

        ParamLo := LoWord(msg.lParam);
        Check := ParamLo and FD_ACCEPT;
        if Check <> 0 then begin
            FSelectMessage := FD_ACCEPT;
            Do_FD_ACCEPT(msg);
        end;

        Check := ParamLo and FD_CLOSE;
        if Check <> 0 then begin
            FSelectMessage := FD_CLOSE;
            Do_FD_CLOSE(msg);
        end;
        FSelectMessage := 0;

    end
    else begin
        FMultiListenIndex := FMultiListenSockets.FindItemIndex(msg.wParam);
        if FMultiListenIndex = -1 then
            Exit;
        AItem := FMultiListenSockets[FMultiListenIndex];

        if AItem.Paused then
          Exit;

        ParamLo := LoWord(msg.lParam);

        Check := ParamLo and FD_ACCEPT;
        if Check <> 0 then
            Do_FD_ACCEPT(msg);

        Check := ParamLo and FD_CLOSE;
        if Check <> 0 then
            Ml_Do_FD_CLOSE(AItem, msg);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ TWSocketMultiListenItem }
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{$IFDEF POSIX}
{ Impl. IIcsEventSource }
function TWSocketMultiListenItem.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem._AddRef: Integer;
begin
  Result := -1;  // no ref count
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem._Release: Integer;
begin
  Result := -1; // no ref count
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetEventMask: LongWord;
begin
    Result := FPxEventMask;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetEventMask(const AValue: LongWord);
begin
    FPxEventMask := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetNotifyMessageID: UINT;
begin
    Result := FPxEventMessageID;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetNotifyMessageID(const AValue: UINT);
begin
    FPxEventMessageID := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetNotifyWindow: HWND;
begin
    Result := FPxEventWindow;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetNotifyWindow(const AValue: HWND);
begin
    FPxEventWindow := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetEventState: TIcsAsyncEventState;
begin
    Result := FPxEventState;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetEventState(const AValue: TIcsAsyncEventState);
begin
    FPxEventState := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetFileDescriptor: Integer;
begin
    Result := FPxFileDescriptor;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetFileDescriptor(const AValue: Integer);
begin
    FPxFileDescriptor := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetObject: TObject;
begin
    Result := Self;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetObjectID: NativeInt;
begin
    Result := FPxObjectID;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$ENDIF POSIX IIcsEventSource}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure TWSocketMultiListenItem.AssignDefaults;
begin
    FHSocket            := INVALID_SOCKET;
    FPortNum            := 0;
    FState              := wsClosed;
    FPaused             := FALSE;
    FCloseInvoked       := FALSE;
    FillChar(Fsin, SizeOf(Fsin), 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.Close;
begin
    OwnerServer.MlClose(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TWSocketMultiListenItem.Create(Collection: TCollection);
begin
    inherited Create(Collection);
    FListenBackLog := 5;
    FSocketFamily := DefaultSocketFamily;
    FOldSocketFamily := FSocketFamily;
    AssignDefaults;
{$IFDEF POSIX}
    FPxObjectID := WSocketGenerateObjectID;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TWSocketMultiListenItem.Destroy;
begin
    if (FState <> wsInvalidState) and (FState <> wsClosed) then
        OwnerServer.MlClose(Self);
    inherited;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetAddrResolved: string;
begin
    if Fsin.sin6_family = AF_INET6 then
        Result := WSocketIPv6ToStr(@Fsin)
    else
        Result := WSocketIPv4ToStr(PInteger(@PSockAddr(@Fsin)^.sin_addr)^);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.GetCloseInvoked: Boolean;
begin
    Result := FCloseInvoked;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.Listen;
begin
    OwnerServer.MlListen(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.OwnerServer: TCustomMultiListenWSocketServer;
begin
    Result := TWSocketMultiListenCollection(Collection).Owner;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.Pause: Boolean;
begin
    OwnerServer.MlPause(Self);
    Result := FPaused;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenItem.Resume: Boolean;
begin
    OwnerServer.MlResume(Self);
    Result := not FPaused;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetAddr(const Value: string);
begin
    OwnerServer.MlSetAddr(FAddr, FSocketFamily, FOldSocketFamily, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetCloseInvoked(const AValue: Boolean);
begin
    FCloseInvoked := AValue;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenItem.SetSocketFamily(const Value: TSocketFamily);
begin
    OwnerServer.MlSetSocketFamily(FSocketFamily, FOldSocketFamily, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ TWSocketMultiListenCollection }
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function TWSocketMultiListenCollection.Add: TWSocketMultiListenItem;
begin
    Result := TWSocketMultiListenItem(inherited Add);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TWSocketMultiListenCollection.Create(AOwner: TPersistent;
    AItemClass: TWSocketMultiListenItemClass);
begin
    inherited Create(AOwner, AItemClass);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.FindItemHandle(
    const AHSocket: TSocket): TWSocketMultiListenItem;
var
    I: Integer;
begin
    for I := 0 to Count -1 do
    begin
      Result := Items[I];
      if Result.FHSocket = AHSocket then
          Exit;
    end;
    Result := nil;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.FindItemIndex(
    const AHSocket: TSocket): Integer;
begin
    for Result := 0 to Count -1 do
    begin
      if Items[Result].FHSocket = AHSocket then
          Exit;
    end;
    Result := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.FindItemID(ID: Integer): TWSocketMultiListenItem;
begin
    Result := TWSocketMultiListenItem(inherited FindItemID(ID));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.GetItem(Index: Integer): TWSocketMultiListenItem;
begin
    Result := TWSocketMultiListenItem(inherited GetItem(Index));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.Insert(
  Index: Integer): TWSocketMultiListenItem;
begin
    Result := TWSocketMultiListenItem(inherited Insert(Index));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TWSocketMultiListenCollection.Owner: TCustomMultiListenWSocketServer;
begin
    Result := TCustomMultiListenWSocketServer(GetOwner);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketMultiListenCollection.SetItem(Index: Integer;
  Value: TWSocketMultiListenItem);
begin
    inherited SetItem(Index, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{*                                                                           *}
{*                            TWSocketClient                                 *}
{*                                                                           *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TWSocketClient.StartConnection;
begin
    if Length(FBanner) > 0 then
        SendStr(FBanner + FLineEnd);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Triggered when socket is closed. Need to inform server socket to update   }
{ client list and trigger client disconnect event.                          }
procedure TWSocketClient.TriggerSessionClosed(ErrCode : Word);
var
    PIdRec : PClientIdRec;
begin
    if not FSessionClosedFlag then begin
        FSessionClosedFlag := TRUE;
        if Assigned(FServer) then begin
            New(PIdRec);
            PIdRec^.PClient := Self;
            PIdRec^.CliId   := FCliId;
            if NOT PostMessage(Server.Handle, Server.FMsg_WM_CLIENT_CLOSED, ErrCode,
                        {$IFDEF CLR}
                        Integer(IntPtr(Self.HandleGc)));
                        {$ELSE}
                        LPARAM(PIdRec))
                        {$ENDIF}
            then
                System.Dispose(PIdRec);
        end;
        inherited TriggerSessionClosed(ErrCode);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This override base class GetPeerAddr. It return cached value.             }
function TWSocketClient.GetPeerAddr: String;
begin
    Result := FPeerAddr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This override base class GetPeerPort. It return cached value.             }
function TWSocketClient.GetPeerPort: String;
begin
    Result := FPeerPort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Override base class. Dup is called when a client is assigned to a         }
{ TWSocket. Assigning HSocket property will call Dup.                       }
procedure TWSocketClient.Dup(newHSocket : TSocket);
begin
    inherited Dup(newHSocket);
    { Cache PeerAddr value }
    FPeerAddr := inherited GetPeerAddr;
    FPeerPort := inherited GetPeerPort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF USE_SSL}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TSslWSocketServer.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
    // Server socket doesn't use SSL to listen for clients
    FSslEnable       := TRUE;
    Port             := '443';
    Proto            := 'tcp';
    Addr             := '0.0.0.0';
    SslMode          := sslModeServer;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TSslWSocketServer.MultiListenItemClass: TWSocketMultiListenItemClass;
begin
    Result := TSslWSocketMultiListenItem;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSslWSocketServer.TriggerClientConnect(
    Client : TWSocketClient; Error : Word);
begin
    inherited TriggerClientConnect(Client, Error);
    { The event handler may have closed the connection }
    { The event handler may also have started the SSL }
    if (Error <> 0) or (Client.State <> wsConnected) or
       (Client.SslState > sslNone) then
        Exit;
    if MultiListenIndex = -1 then
        Client.SslEnable := FSslEnable
    else begin
        Assert(MultiListenIndex < MultiListenSockets.Count);
        Client.SslEnable := TSslWSocketMultiListenItem(
          MultiListenSockets[MultiListenIndex]).SslEnable;
    end;
    if Client.SslEnable then begin
        Client.SslMode                  := FSslMode;
        Client.SslAcceptableHosts       := FSslAcceptableHosts;
        Client.SslContext               := FSslContext;
        Client.OnSslVerifyPeer          := OnSslVerifyPeer;
        Client.OnSslSetSessionIDContext := OnSslSetSessionIDContext;
        Client.OnSslSvrNewSession       := OnSslSvrNewSession;
        Client.OnSslSvrGetSession       := OnSslSvrGetSession;
        Client.OnSslHandshakeDone       := OnSslHandshakeDone;
        try
            if Client.SslMode = sslModeClient then
                Client.StartSslHandshake
            else
                Client.AcceptSslHandshake;
        except
            on E: Exception do begin                            // AG 12/18/05
                Client.SslEnable := False;
                Client.Abort;
                { Don't abort silently }
                Client.HandleBackGroundException(E);            // AG 12/18/05
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TSslWSocketClient.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSslWSocketClient.StartConnection;
begin
    inherited StartConnection;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ TSslWSocketMultiListenItem }
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TSslWSocketMultiListenItem.Create(Collection: TCollection);
begin
    inherited Create(Collection);
    FSslEnable := TRUE;
end;

{$ENDIF} // USE_SSL

end.

