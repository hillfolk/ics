object Cli7Form: TCli7Form
  Left = 429
  Top = 327
  Caption = 'Client 7'
  ClientHeight = 196
  ClientWidth = 307
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 307
    Height = 109
    Align = alTop
    TabOrder = 0
    object Label6: TLabel
      Left = 196
      Top = 12
      Width = 19
      Height = 13
      Caption = 'Port'
    end
    object Label1: TLabel
      Left = 11
      Top = 12
      Width = 50
      Height = 13
      Caption = 'HostName'
    end
    object Label2: TLabel
      Left = 12
      Top = 84
      Width = 23
      Height = 13
      Caption = 'Data'
    end
    object PortEdit: TEdit
      Left = 233
      Top = 8
      Width = 57
      Height = 21
      TabOrder = 0
      Text = 'PortEdit'
    end
    object HostNameEdit: TEdit
      Left = 68
      Top = 8
      Width = 121
      Height = 21
      Hint = 'Host where the file is located'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = 'HostNameEdit'
    end
    object ConnectButton: TButton
      Left = 12
      Top = 40
      Width = 75
      Height = 17
      Caption = '&Connect'
      TabOrder = 2
      OnClick = ConnectButtonClick
    end
    object LineOnButton: TButton
      Left = 92
      Top = 40
      Width = 75
      Height = 17
      Caption = 'Line &On'
      TabOrder = 3
      OnClick = LineOnButtonClick
    end
    object LineOffButton: TButton
      Left = 92
      Top = 60
      Width = 75
      Height = 17
      Caption = 'Line O&ff'
      TabOrder = 4
      OnClick = LineOffButtonClick
    end
    object DisconnectButton: TButton
      Left = 12
      Top = 60
      Width = 75
      Height = 17
      Caption = '&Disconnect'
      TabOrder = 5
      OnClick = DisconnectButtonClick
    end
    object SendButton: TButton
      Left = 173
      Top = 60
      Width = 75
      Height = 17
      Caption = '&Send'
      TabOrder = 6
      OnClick = SendButtonClick
    end
    object DataEdit: TEdit
      Left = 41
      Top = 80
      Width = 249
      Height = 21
      TabOrder = 7
      Text = 'DataEdit'
    end
  end
  object DisplayMemo: TMemo
    Left = 0
    Top = 109
    Width = 307
    Height = 87
    Align = alClient
    Lines.Strings = (
      'DisplayMemo')
    TabOrder = 1
  end
  object WSocket1: TWSocket
    LineMode = False
    LineLimit = 65536
    LineEnd = #13#10
    LineEcho = False
    LineEdit = False
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalPort = '0'
    MultiThreaded = False
    MultiCast = False
    MultiCastIpTTL = 1
    FlushTimeout = 60
    SendFlags = wsSendNormal
    LingerOnOff = wsLingerOn
    LingerTimeout = 0
    KeepAliveOnOff = wsKeepAliveOff
    KeepAliveTime = 0
    KeepAliveInterval = 0
    SocksLevel = '5'
    SocksAuthentication = socksNoAuthentication
    LastError = 0
    ReuseAddr = False
    ComponentOptions = []
    ListenBacklog = 5
    ReqVerLow = 2
    ReqVerHigh = 2
    OnDataAvailable = WSocket1DataAvailable
    OnSessionClosed = WSocket1SessionClosed
    OnSessionConnected = WSocket1SessionConnected
    Left = 112
    Top = 116
  end
end
