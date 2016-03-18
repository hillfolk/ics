object SslWebServForm: TSslWebServForm
  Left = 287
  Top = 154
  Caption = 'ICS SSL WebServer Demo - http://www.overbyte.be'
  ClientHeight = 480
  ClientWidth = 619
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolsPanel: TPanel
    Left = 0
    Top = 0
    Width = 619
    Height = 265
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 36
      Top = 8
      Width = 33
      Height = 13
      Caption = 'DocDir'
    end
    object Label2: TLabel
      Left = 16
      Top = 32
      Width = 54
      Height = 13
      Caption = 'DefaultDoc'
    end
    object Label3: TLabel
      Left = 367
      Top = 32
      Width = 64
      Height = 13
      Caption = 'Port (HTTPS)'
    end
    object ClientHttpsCountLabel: TLabel
      Left = 109
      Top = 243
      Width = 105
      Height = 13
      Caption = 'ClientHttpsCountLabel'
    end
    object Label5: TLabel
      Left = 14
      Top = 243
      Width = 79
      Height = 13
      Caption = ' Clients (HTTPS)'
    end
    object Label4: TLabel
      Left = 39
      Top = 55
      Width = 35
      Height = 13
      Caption = 'CertFile'
    end
    object Label6: TLabel
      Left = 23
      Top = 79
      Width = 51
      Height = 13
      Caption = 'PrivateKey'
    end
    object Label7: TLabel
      Left = 20
      Top = 103
      Width = 56
      Height = 13
      Caption = 'PassPhrase'
    end
    object Label8: TLabel
      Left = 24
      Top = 120
      Width = 54
      Height = 13
      Caption = 'Acceptable'
    end
    object Label9: TLabel
      Left = 52
      Top = 132
      Width = 25
      Height = 13
      Caption = 'hosts'
    end
    object Label10: TLabel
      Left = 256
      Top = 79
      Width = 39
      Height = 13
      Caption = 'CA Path'
    end
    object Label11: TLabel
      Left = 264
      Top = 55
      Width = 33
      Height = 13
      Caption = 'CA File'
    end
    object Label12: TLabel
      Left = 240
      Top = 32
      Width = 57
      Height = 13
      Caption = 'Port (HTTP)'
    end
    object Label15: TLabel
      Left = 240
      Top = 243
      Width = 72
      Height = 13
      Caption = ' Clients (HTTP)'
    end
    object ClientHttpCountLabel: TLabel
      Left = 326
      Top = 243
      Width = 105
      Height = 13
      Caption = 'ClientHttpsCountLabel'
    end
    object Label17: TLabel
      Left = 14
      Top = 156
      Width = 62
      Height = 13
      Caption = ' Reneg. after'
    end
    object Label16: TLabel
      Left = 18
      Top = 144
      Width = 40
      Height = 13
      Caption = 'Req. Ssl'
    end
    object Label18: TLabel
      Left = 156
      Top = 147
      Width = 52
      Height = 26
      Caption = '(msec. 0 = disabled)'
      WordWrap = True
    end
    object Label19: TLabel
      Left = 306
      Top = 153
      Width = 30
      Height = 13
      Caption = 'ECDH'
    end
    object Label13: TLabel
      Left = 261
      Top = 103
      Width = 35
      Height = 13
      Caption = 'DH File'
    end
    object Label20: TLabel
      Left = 16
      Top = 175
      Width = 58
      Height = 13
      Caption = 'SSL Version'
    end
    object Label21: TLabel
      Left = 14
      Top = 199
      Width = 60
      Height = 13
      Caption = 'New Ciphers'
    end
    object Label14: TLabel
      Left = 199
      Top = 175
      Width = 53
      Height = 13
      Caption = 'SSL Cipher'
    end
    object Label22: TLabel
      Left = 212
      Top = 8
      Width = 82
      Height = 13
      Caption = 'Listen IP Address'
    end
    object DocDirEdit: TEdit
      Left = 80
      Top = 4
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'DocDirEdit'
    end
    object DefaultDocEdit: TEdit
      Left = 80
      Top = 28
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'DefaultDocEdit'
    end
    object StartHttpsButton: TButton
      Left = 460
      Top = 52
      Width = 73
      Height = 21
      Caption = '&Start HTTPS'
      TabOrder = 21
      OnClick = StartHttpsButtonClick
    end
    object StopButton: TButton
      Left = 460
      Top = 76
      Width = 73
      Height = 21
      Caption = 'St&op'
      TabOrder = 22
      OnClick = StopButtonClick
    end
    object PortHttpsEdit: TEdit
      Left = 437
      Top = 28
      Width = 53
      Height = 21
      TabOrder = 14
      Text = 'PortHttpsEdit'
    end
    object ClearButton: TButton
      Left = 460
      Top = 100
      Width = 73
      Height = 21
      Caption = '&Clear'
      TabOrder = 23
      OnClick = ClearButtonClick
    end
    object DisplayHeaderCheckBox: TCheckBox
      Left = 136
      Top = 220
      Width = 97
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Display Header'
      TabOrder = 10
    end
    object WriteLogFileCheckBox: TCheckBox
      Left = 16
      Top = 220
      Width = 97
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Write to log file'
      TabOrder = 9
      OnClick = WriteLogFileCheckBoxClick
    end
    object CertFileEdit: TEdit
      Left = 80
      Top = 52
      Width = 153
      Height = 21
      TabOrder = 2
      Text = 'CertFileEdit'
    end
    object PrivKeyFileEdit: TEdit
      Left = 80
      Top = 76
      Width = 153
      Height = 21
      TabOrder = 3
      Text = 'PrivKeyFileEdit'
    end
    object PassPhraseEdit: TEdit
      Left = 80
      Top = 100
      Width = 153
      Height = 21
      TabOrder = 4
      Text = 'PassPhraseEdit'
    end
    object AcceptableHostsEdit: TEdit
      Left = 80
      Top = 124
      Width = 373
      Height = 21
      TabOrder = 5
      Text = 'AcceptableHostsEdit'
    end
    object CAPathEdit: TEdit
      Left = 300
      Top = 76
      Width = 153
      Height = 21
      TabOrder = 16
      Text = 'CAPathEdit'
    end
    object CAFileEdit: TEdit
      Left = 300
      Top = 52
      Width = 153
      Height = 21
      TabOrder = 15
      Text = 'CAFileEdit'
    end
    object VerifyPeerCheckBox: TCheckBox
      Left = 218
      Top = 149
      Width = 71
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Verify Peer'
      TabOrder = 18
    end
    object StartHttpButton: TButton
      Left = 460
      Top = 124
      Width = 73
      Height = 21
      Caption = 'Start HTTP'
      TabOrder = 24
      OnClick = StartHttpButtonClick
    end
    object PortHttpEdit: TEdit
      Left = 300
      Top = 28
      Width = 53
      Height = 21
      TabOrder = 13
      Text = 'PortHttpEdit'
    end
    object RenegotiationIntervalEdit: TEdit
      Left = 80
      Top = 148
      Width = 71
      Height = 21
      TabOrder = 6
      Text = '0'
      OnChange = RenegotiationIntervalEditChange
    end
    object ButtonOSSLVersion: TButton
      Left = 460
      Top = 148
      Width = 73
      Height = 21
      Caption = 'OpenSSL?'
      TabOrder = 25
      OnClick = ButtonOSSLVersionClick
    end
    object DisplaySslInfoCheckBox: TCheckBox
      Left = 256
      Top = 220
      Width = 97
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Display SSL Info'
      TabOrder = 11
    end
    object DhParamFileEdit: TEdit
      Left = 300
      Top = 100
      Width = 153
      Height = 21
      Hint = 'Enter DH Parameter File (can be empty).'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 17
      Text = 'DhParamFileEdit'
    end
    object ECDHList: TComboBox
      Left = 345
      Top = 148
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 19
      Items.Strings = (
        'None'
        'Automatic'
        'ECDH_P256'
        'ECDH_P384'
        'ECDH_P521')
    end
    object SslVersionList: TComboBox
      Left = 80
      Top = 172
      Width = 108
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 7
      Items.Strings = (
        'Best Version'
        'SSLv2'
        'SSLv3'
        'TLSv1'
        'TLSv1.1'
        'TLSv1.2')
    end
    object SslCipherEdit: TEdit
      Left = 80
      Top = 196
      Width = 453
      Height = 21
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Text = 'SslCipherEdit'
    end
    object SslCipherList: TComboBox
      Left = 264
      Top = 172
      Width = 190
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 20
      Text = 'sslCiphersServer'
      Items.Strings = (
        'sslCiphersServer'
        'sslCiphersMozillaSrvBack'
        'sslCiphersMozillaSrvInter'
        'sslCiphersMozillaSrvHigh'
        'sslCiphersMozillaSrvBack38'
        'sslCiphersMozillaSrvInter38'
        'sslCiphersMozillaSrvHigh38')
    end
    object ListenAddr: TComboBox
      Left = 300
      Top = 4
      Width = 128
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 12
      Text = 'localhost'
      Items.Strings = (
        'localhost')
    end
  end
  object DisplayMemo: TMemo
    Left = 0
    Top = 265
    Width = 619
    Height = 215
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'DisplayMemo')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object SslHttpServer1: TSslHttpServer
    IcsLogger = IcsLogger1
    ListenBacklog = 5
    MultiListenSockets = <>
    Port = '80'
    Addr = '0.0.0.0'
    SocketFamily = sfIPv4
    MaxClients = 0
    DocDir = 'c:\wwwroot'
    TemplateDir = 'c:\wwwroot\templates'
    DefaultDoc = 'index.html'
    LingerOnOff = wsLingerNoSet
    LingerTimeout = 0
    Options = []
    KeepAliveTimeSec = 10
    KeepAliveTimeXferSec = 300
    MaxRequestsKeepAlive = 100
    SizeCompressMin = 5000
    SizeCompressMax = 5000000
    MaxBlkSize = 8192
    BandwidthLimit = 0
    BandwidthSampling = 1000
    ServerHeader = 'Server: ICS-HttpServer-8.08'
    OnServerStarted = SslHttpServer1ServerStarted
    OnServerStopped = SslHttpServer1ServerStopped
    OnClientConnect = SslHttpServer1ClientConnect
    OnClientDisconnect = SslHttpServer1ClientDisconnect
    OnGetDocument = SslHttpServer1GetDocument
    OnHeadDocument = SslHttpServer1HeadDocument
    OnPostDocument = SslHttpServer1PostDocument
    OnPostedData = SslHttpServer1PostedData
    OnBeforeProcessRequest = SslHttpServer1BeforeProcessRequest
    AuthTypes = []
    AuthRealm = 'ics'
    SslEnable = True
    SslContext = SslContext1
    OnSslVerifyPeer = SslHttpServer1SslVerifyPeer
    OnSslSetSessionIDContext = SslHttpServer1SslSetSessionIDContext
    OnSslSvrNewSession = SslHttpServer1SslSvrNewSession
    OnSslSvrGetSession = SslHttpServer1SslSvrGetSession
    OnSslHandshakeDone = SslHttpServer1SslHandshakeDone
    OnSslServerName = SslHttpServer1SslServerName
    Left = 42
    Top = 306
  end
  object SslContext1: TSslContext
    IcsLogger = IcsLogger1
    SslVerifyPeer = False
    SslVerifyDepth = 9
    SslVerifyFlags = []
    SslOptions = [sslOpt_MICROSOFT_SESS_ID_BUG, sslOpt_NETSCAPE_CHALLENGE_BUG, sslOpt_NETSCAPE_REUSE_CIPHER_CHANGE_BUG, sslOpt_MICROSOFT_BIG_SSLV3_BUFFER, sslOpt_SSLEAY_080_CLIENT_DH_BUG, sslOpt_TLS_D5_BUG, sslOpt_TLS_BLOCK_PADDING_BUG, sslOpt_TLS_ROLLBACK_BUG, sslOpt_SINGLE_DH_USE, sslOpt_NO_SSLv2, sslOpt_NO_SSLv3, sslOpt_NETSCAPE_CA_DN_BUG, sslOpt_NO_SESSION_RESUMPTION_ON_RENEGOTIATION, sslOpt_NETSCAPE_DEMO_CIPHER_CHANGE_BUG]
    SslVerifyPeerModes = [SslVerifyMode_PEER]
    SslSessionCacheModes = [sslSESS_CACHE_SERVER, sslSESS_CACHE_NO_INTERNAL_LOOKUP, sslSESS_CACHE_NO_INTERNAL_STORE]
    SslCipherList = 'ALL:!ADH:RC4+RSA:+SSLv2:@STRENGTH'
    SslVersionMethod = sslV23_SERVER
    SslECDHMethod = sslECDHNone
    SslSessionTimeout = 300
    SslSessionCacheSize = 20480
    SslDefaultSessionIDContext = 'Webservertest'
    AutoEnableBuiltinEngines = False
    Left = 132
    Top = 311
  end
  object HttpServer2: THttpServer
    IcsLogger = IcsLogger1
    ListenBacklog = 5
    MultiListenSockets = <>
    Port = '80'
    Addr = '0.0.0.0'
    SocketFamily = sfIPv4
    MaxClients = 0
    DocDir = 'c:\wwwroot'
    TemplateDir = 'c:\wwwroot\templates'
    DefaultDoc = 'index.html'
    LingerOnOff = wsLingerNoSet
    LingerTimeout = 0
    Options = []
    KeepAliveTimeSec = 10
    KeepAliveTimeXferSec = 300
    MaxRequestsKeepAlive = 100
    SizeCompressMin = 5000
    SizeCompressMax = 5000000
    MaxBlkSize = 8192
    BandwidthLimit = 0
    BandwidthSampling = 1000
    ServerHeader = 'Server: ICS-HttpServer-8.08'
    OnServerStarted = HttpServer2ServerStarted
    OnServerStopped = HttpServer2ServerStopped
    OnClientConnect = HttpServer2ClientConnect
    OnClientDisconnect = HttpServer2ClientDisconnect
    OnGetDocument = SslHttpServer1GetDocument
    OnHeadDocument = SslHttpServer1HeadDocument
    OnPostDocument = SslHttpServer1PostDocument
    AuthTypes = []
    AuthRealm = 'ics'
    Left = 42
    Top = 357
  end
  object IcsLogger1: TIcsLogger
    TimeStampFormatString = 'hh:nn:ss:zzz'
    TimeStampSeparator = ' '
    LogFileOption = lfoOverwrite
    LogFileName = 'Debug_Out_SslWebServ.txt'
    LogOptions = []
    Left = 237
    Top = 312
  end
  object SslAvlSessionCache1: TSslAvlSessionCache
    IdleTimeout = 30
    FlushInterval = 10000
    MaxCacheSize = 1000
    Left = 131
    Top = 361
  end
end
