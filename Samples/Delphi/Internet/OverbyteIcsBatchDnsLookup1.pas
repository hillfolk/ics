unit OverbyteIcsBatchDnsLookup1;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Contnrs,
  OverbyteIcsUtils,
  OverbyteIcsIniFiles,
  OverbyteIcsWndControl,
  OverbyteIcsWSocket;

type
  TBatchDnsLookupForm = class(TForm)
    StartButton: TButton;
    DnsNamesMemo: TMemo;
    ResultMemo: TMemo;
    MinEdit: TEdit;
    Label1: TLabel;
    MaxEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    InstancesEdit: TEdit;
    SocketFamilyComboBox: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    procedure StartButtonClick(Sender: TObject);
    procedure WSocket1DnsLookupDone(Sender: TObject; ErrCode: Word);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SocketFamilyComboBoxChange(Sender: TObject);
  private
    FDummyWSocket: TWSocket;
    FHostList: TStringList;
    FResultList: TStringList;
    FMin : Byte;
    FMax : Byte;
    FInstances : Byte;
    FIniFile : TIcsIniFile;
    FInitialized : Boolean;
    FWSocketList: TComponentList;
    procedure WmUser(var AMsg: TMessage); message WM_USER;
  public
    property IniFile: TIcsIniFile read FIniFile;
  end;

var
  BatchDnsLookupForm: TBatchDnsLookupForm;

implementation

{$R *.dfm}
uses
    Math;

const
    SectionWindow      = 'Window';   // Must be unique for each window
    KeyTop             = 'Top';
    KeyLeft            = 'Left';
    //KeyWidth           = 'Width';
    //KeyHeight          = 'Height';
    SectionSetup       = 'Setup';
    KeyMin             = 'MinLookupThreads';
    KeyMax             = 'MaxLookupThreads';
    KeyInstances       = 'NumberOfInstances';
    SectionDnsNames    = 'DnsNames';
    KeyDnsName         = 'Item';

procedure TBatchDnsLookupForm.FormCreate(Sender: TObject);
begin
{$IF RTLVersion >= 18}
    { Built-in memory leak detection and display since BDS2006 }
    { This is useful for debugging, however a bit slower.      }
    ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$IFEND}
    IcsNameThreadForDebugging('Main');
    FHostList := TStringList.Create;
    FResultList := TStringList.Create;
    FWSocketList := TComponentList.Create(TRUE);
    ResultMemo.Clear;
    DnsNamesMemo.WordWrap := FALSE;
    FIniFile := TIcsIniFile.Create(OverbyteIcsIniFiles.GetIcsIniFileName);
    ActiveControl := StartButton;
end;

procedure TBatchDnsLookupForm.FormDestroy(Sender: TObject);
begin
    FWSocketList.Free;
    FHostList.Free;
    FResultList.Free;
    FIniFile.Free;
end;

procedure TBatchDnsLookupForm.FormShow(Sender: TObject);
begin
    if not FInitialized then begin
        FInitialized := TRUE;
        //Width        := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        //Height       := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        Top          := IniFile.ReadInteger(SectionWindow, KeyTop,
                                               (Screen.Height - Height) div 2);
        Left         := IniFile.ReadInteger(SectionWindow, KeyLeft,
                                               (Screen.Width  - Width)  div 2);
        FMin         := IniFile.ReadInteger(SectionSetup, KeyMin,  1);
        FMax         := IniFile.ReadInteger(SectionSetup, KeyMax,  4);
        FInstances   := IniFile.ReadInteger(SectionSetup, KeyInstances, 4);
        if not IniFile.ReadStrings(SectionDnsNames, KeyDnsName, DnsNamesMemo.Lines) then
        begin
            DnsNamesMemo.Text :=
            'www.overbyte.be'#13#10 +
            'svn.overbyte.be'#13#10 +
            'wiki.overbyte.be'#13#10 +
            'www.embarcardero.com'#13#10 +
            'edn.embarcardero.com'#13#10 +
            'nonexisting'#13#10 +
            'www.microsoft.com'#13#10 +
            'ipv6.google.com'#13#10 +
            'www.goggle.com'#13#10 +
            'www.aol.com'#13#10 +
            'sourceforge.net'#13#10 +
            'www.borland.com'#13#10 +
            'msdn.microsoft.com'#13#10 +
            'localhost'#13#10 +
            '127.0.0.1'#13#10 +
            '::1'#13#10 +
            'www.sixxs.net';
        end;
        MinEdit.Text := IntToStr(FMin);
        MaxEdit.Text := IntToStr(FMax);
        InstancesEdit.Text := IntToStr(FInstances);

        { This instance is to keep a reference to a shared internal DnsLookup   }
        { object so that DNS lookup threads don't terminate when the last       }
        { TWSocket instance is destroyed.                                       }
        FDummyWSocket := TWSocket.Create(Self);
        { In order to get a reference we just set the minimum and maximum lookup}
        { threads shared by all TWsocket instances in this thread context.      }
        FDummyWSocket.SetMinMaxIcsAsyncDnsLookupThreads(FMin, FMax);
        { We can also call method AllocateIcsAsyncDnsLookup to get a reference. }
    end;
end;

procedure TBatchDnsLookupForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    try
        IniFile.WriteInteger(SectionWindow,   KeyTop,         Top);
        IniFile.WriteInteger(SectionWindow,   KeyLeft,        Left);
        //IniFile.WriteInteger(SectionWindow,   KeyWidth,       Width);
        //IniFile.WriteInteger(SectionWindow,   KeyHeight,      Height);

        FMin        := StrToIntDef(MinEdit.Text, 0);
        FMax        := StrToIntDef(MaxEdit.Text, 2);
        FInstances  := StrToIntDef(InstancesEdit.Text, 3);

        IniFile.WriteInteger(SectionSetup,    KeyMin,         FMin);
        IniFile.WriteInteger(SectionSetup,    KeyMax,         FMax);
        IniFile.WriteInteger(SectionSetup,    KeyInstances,   FInstances);
        IniFile.WriteStrings(SectionDnsNames, KeyDnsName,     DnsNamesMemo.Lines);
        IniFile.UpdateFile;
    except
        on E: Exception do
            MessageDlg(E.ClassName + ' ' + E.Message, mtError, [mbOK], 0);
    end;
end;

procedure TBatchDnsLookupForm.SocketFamilyComboBoxChange(Sender: TObject);
begin
    if TSocketFamily(SocketFamilyComboBox.ItemIndex) = sfIPv4 then
    begin
        MinEdit.Enabled := FALSE;
        MinEdit.Color   := clBtnFace;
        MaxEdit.Enabled := FALSE;
        MaxEdit.Color   := clBtnFace;
        Label1.Enabled  := FALSE;
        Label2.Enabled  := FALSE;
        Label3.Enabled  := FALSE;
        Label6.Enabled  := FALSE;
    end
    else begin
        MinEdit.Enabled := TRUE;
        MinEdit.Color   := clWindow;
        MaxEdit.Enabled := TRUE;
        MaxEdit.Color   := clWindow;
        Label1.Enabled  := TRUE;
        Label2.Enabled  := TRUE;
        Label3.Enabled  := TRUE;
        Label6.Enabled  := TRUE;
    end;
end;


procedure TBatchDnsLookupForm.WmUser(var AMsg: TMessage);
var
    WSocket : TWSocket;
begin
    WSocket := TWSocket(AMsg.WParam);
    if FHostList.Count > 0 then
    begin
        WSocket.Tag := FHostList.Count - 1;
        WSocket.DnsLookup(FHostList[WSocket.Tag]);
        FHostList.Delete(WSocket.Tag);
    end
    else
        WSocket.Free;
end;

procedure TBatchDnsLookupForm.WSocket1DnsLookupDone(
    Sender  : TObject;
    ErrCode : Word);
begin
    if ErrCode = 0 then
        FResultList[TWSocket(Sender).Tag] := TWSocket(Sender).DnsResult
    else
        FResultList[TWSocket(Sender).Tag] := WSocketErrorDesc(ErrCode);
    ResultMemo.Lines.Assign(FResultList);
    ResultMemo.Update;
    PostMessage(Handle, WM_USER, WPARAM(Sender), 0);
end;

procedure TBatchDnsLookupForm.StartButtonClick(Sender: TObject);
var
    I       : Integer;
    WSocket : TWSocket;
    LMin, LMax : Byte;
begin
    FWSocketList.Clear;
    ResultMemo.Clear;
    ResultMemo.Update;

    LMin := StrToIntDef(MinEdit.Text, 0);
    LMax := StrToIntDef(MaxEdit.Text, 1);
    if (LMin <> FMin) or
       (LMax <> FMax) then
    begin
        FMin := LMin;
        FMax := LMax;
        FDummyWSocket.SetMinMaxIcsAsyncDnsLookupThreads(FMin, FMax);
    end;
    if StrToIntDef(InstancesEdit.Text, 1) <> FInstances then
        FInstances := StrToIntDef(InstancesEdit.Text, 1);

    FHostList.Assign(DnsNamesMemo.Lines);
    FResultList.Clear;
    for I := 0 to FHostList.Count -1 do
        FResultList.Add('Resolving..');

    for I := Min(FInstances, FHostList.Count - 1) downto 1 do begin
        WSocket := TWSocket.Create(nil);
        FWSocketList.Add(WSocket);
        WSocket.Tag := FHostList.Count -1;
        { Note DnsLookup uses the old API if SocketFamily is sfIPv4 }
        WSocket.SocketFamily := TSocketFamily(SocketFamilyComboBox.ItemIndex);
        WSocket.OnDnsLookupDone := WSocket1DnsLookupDone;
        WSocket.DnsLookup(FHostList[WSocket.Tag]);
        FHostList.Delete(WSocket.Tag);
    end;
end;

end.
