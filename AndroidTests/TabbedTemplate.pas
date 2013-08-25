unit TabbedTemplate;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls,
  FMX.Layouts, FMX.Memo,
  Posix.UniStd, Posix.SysSocket, Posix.Errno, Posix.StrOpts,
  Androidapi.Looper,
  OverbyteIcsAnsiStrings,
  OverbyteIcsMD5;

type
  TTabbedForm = class(TForm)
    HeaderToolBar: TToolBar;
    ToolBarLabel: TLabel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    DontClickButton: TButton;
    Button2: TButton;
    TestLibButton: TButton;
    CreatePipeButton: TButton;
    ClosePipeButton: TButton;
    DisplayMemo: TMemo;
    WritePipeButton: TButton;
    ReadPipeButton: TButton;
    procedure DontClickButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TestLibButtonClick(Sender: TObject);
    procedure CreatePipeButtonClick(Sender: TObject);
    procedure ClosePipeButtonClick(Sender: TObject);
    procedure WritePipeButtonClick(Sender: TObject);
    procedure ReadPipeButtonClick(Sender: TObject);
  protected
    FPipeFD  : TPipeDescriptors;
    FData : Byte;
    procedure DisplayProc(const Msg : String);
    function CreatePipe : Integer;
    function ClosePipe : Integer;
    procedure Display(const Msg : String);
  public
    { Public declarations }
  end;

var
  TabbedForm: TTabbedForm;

implementation

{$R *.fmx}


procedure TTabbedForm.DontClickButtonClick(Sender: TObject);
begin
    ShowMessage('Please wait... Formating storage...');
end;


procedure TTabbedForm.Button2Click(Sender: TObject);
var
    sockfd, err: Integer;
begin
    sockfd := Posix.SysSocket.socket(AF_INET, SOCK_STREAM, 0);
    if sockfd >= 0 then begin
        Display('OK');
        __close(sockfd);
    end
    else begin
      err    := errno;
      if Err = 0 then
          Display('OK')
      else
          Display('Error #' + IntToStr(Err));
    end;
end;

procedure TTabbedForm.CreatePipeButtonClick(Sender: TObject);
begin
    if CreatePipe = 0 then
        Display('Pipe is now created');
end;

function TTabbedForm.ClosePipe: Integer;
var
   Status  : Integer;
begin
    Result := 0;
    if FPipeFD.ReadDes <> 0 then begin
        Status := __close(FPipeFD.ReadDes);
        if Status = -1 then begin
            Result := errno;
            Display('close(FPipeFD.ReadDes) failed. Error code is ' + IntToStr(Result));
        end
        else
            FPipeFD.ReadDes := 0;
    end;
    if FPipeFD.WriteDes <> 0 then begin
        Status := __close(FPipeFD.WriteDes);
        if Status = -1 then begin
            Result := errno;
            Display('close(FPipeFD.WriteDes) failed. Error code is ' + IntToStr(Result));
        end
        else
            FPipeFD.WriteDes := 0;
    end;
end;

procedure TTabbedForm.ClosePipeButtonClick(Sender: TObject);
begin
    if ClosePipe = 0 then
        Display('Pipe now closed');
end;

function TTabbedForm.CreatePipe: Integer;
var
    Status  : Integer;
    Val     : Integer;
const
    FIONBIO = $5421;
begin
    if (FPipeFD.ReadDes <> 0) or (FPipeFD.WriteDes <> 0) then begin
        Display('Pipe already created');
        Result := -1;
        Exit;
    end;
    Status := Pipe(FPipeFD);
    if Status = -1 then begin
        Result := errno;
        Display('Pipe() failed. Error code is ' + IntToStr(Result));
    end
    else begin
        Result := 0;
        Val := 1;
        if ioctl(FPipeFD.ReadDes, FIONBIO, @Val) = -1 then begin
            Result := errno;
            Display('ioctl(FIONBIO) failed. Error code is ' + IntToStr(Result));
            Exit;
        end;
        Display('Pipe created');
    end;
end;

procedure TTabbedForm.Display(const Msg: String);
begin
    Displaymemo.Lines.Add(Msg);
end;

procedure TTabbedForm.DisplayProc(const Msg: String);
begin
    Display(Msg);
end;

procedure TTabbedForm.TestLibButtonClick(Sender: TObject);
var
    ErrMsg : String;
begin
{$IFDEF ANSISTRINGS_SELF_TEST}
    if AnsiStringsUnitTest(ErrMsg) then
        Display(ErrMsg)
    else
        Display('AnsiStrings all tests  passed');
{$ENDIF}

{$IFDEF MD5_SELF_TEST}
    if not MD5UnitTest(DisplayProc) then
        Display('MD5 all tests passed');
{$ENDIF}
    Display('Done');
end;

procedure TTabbedForm.WritePipeButtonClick(Sender: TObject);
begin
    if FPipeFD.WriteDes = 0 then begin
        Display('Pipe is not open');
        Exit;
    end;
    Inc(FData);
    if __write(FPipeFD.WriteDes, @FData, 1) = -1 then begin
        Display('write() failed. ErrCode=' + IntToStr(errno));
        Exit;
    end;
    Display('Byte written (' + IntToStr(FData) + ')');
end;

procedure TTabbedForm.ReadPipeButtonClick(Sender: TObject);
var
    Len : Integer;
    Buf : Byte;
    ErrCode : Integer;
begin
    if FPipeFD.ReadDes = 0 then begin
        Display('Pipe is not open');
        Exit;
    end;
    Len := __read(FPipeFD.ReadDes, @Buf, 1);
    if Len < 0 then begin
        ErrCode := errno;
        if ErrCode = 11 then
            Display('Nothing to read')
        else
            Display('read() failed. ErrCode=' + IntToStr(errno));
        Exit;
    end;
    if Len = 0 then begin
        Display('Read returned 0 byte');
        Exit;
    end;
    Display('Read value ' + IntToStr(Buf));
end;


end.
