{$B-}                                 { Enable partial boolean evaluation   }
{$T-}                                 { Untyped pointers                    }
{$X+}                                 { Enable extended syntax              }
{$H+}                                 { Use long strings                    }
{$J+}                                 { Allow typed constant to be modified }

unit OverbyteIcsLibeayEx;

interface

uses
    Windows, SysUtils, PsApi, OverbyteIcsSSLEAY, OverbyteIcsLibeay;

const
    NID_key_usage                     = 83;
    NID_basic_constraints             = 87;

    RSA_PKCS1_PADDING                 = 1;
    RSA_SSLV23_PADDING                = 2;
    RSA_NO_PADDING                    = 3;
    RSA_PKCS1_OAEP_PADDING            = 4;

    RSA_PKCS1_PADDING_SIZE            = 11;
    RSA_PKCS1_OAEP_PADDING_SIZE       = 41;

    EVP_MAX_MD_SIZE                   = 64; //* longest known is SHA512 */
    PKCS5_SALT_LEN                    =  8;

type
    TEVP_CIPHER_CTX_st = packed record
        Dummy : array [0..0] of Byte;
        (*
        cipher        : PEVP_CIPHER;
        encrypt       : Integer;
        buf_len       : Integer;
        oiv           : array [0..EVP_MAX_IV_LENGTH -1] of Char;
        iv            : array [0..EVP_MAX_IV_LENGTH -1] of Char;
        buf           : array [0..EVP_MAX_BLOCK_LENGTH -1] of Char;
        num           : Integer;
        app_data      : Pointer;
        key_len       : Integer;
        flags         : Cardinal;
        cipher_data   : Pointer;
        final_used    : Integer;
        block_mask    : Integer;
        final         : array [0..EVP_MAX_BLOCK_LENGTH -1] of Char;
        *)
    end;
    PEVP_CIPHER_CTX = ^TEVP_CIPHER_CTX_st;
    
    TEngine_st = packed record
        Dummy : array [0..0] of Byte;
    end;
    PEngine = ^TEngine_st;

    TASN1_BIT_STRING   = TASN1_STRING_st;
    PASN1_BIT_STRING   = ^TASN1_BIT_STRING;

    TASN1_ENCODING_st = packed record
        enc       : PChar;
        len       : LongWord;
        modified  : Integer;
    end;
    TASN1_ENCODING = TASN1_ENCODING_st;
    PASN1_ENCODING = ^TASN1_ENCODING_st;

    TLHASH_st = packed record
        Dummy : array [0..0] of Byte;
    end;
    PLHASH = ^TLHASH_st;

    TX509V3_CTX_st = packed record
        Dummy : array [0..0] of Byte;
    end;
    PX509V3_CTX = ^TX509V3_CTX_st;

    TX509_PUBKEY_st = packed record
        algor       : PX509_ALGOR;
        public_key  : PASN1_BIT_STRING;
        pkey        : PEVP_PKEY;
    end;
    PX509_PUBKEY = ^TX509_PUBKEY_st;

    TX509_REQ_INFO_st = packed record
        enc         : TASN1_ENCODING;
        version     : PASN1_INTEGER;
        subject     : PX509_NAME;
        pubkey      : PX509_PUBKEY;
        attributes  : PSTACK;
    end;
    PX509_REQ_INFO = ^TX509_REQ_INFO_st;

    TX509_REQ_st = packed record
        req_info    : PX509_REQ_INFO;
        sig_alg     : PX509_ALGOR;
        signature   : PASN1_STRING;
        references  : Integer;
    end;
    PX509_REQ = ^TX509_REQ_st;

const
f_RAND_screen             : procedure; cdecl = nil;
f_RAND_load_file          : function(const FileName: PChar; Max_Bytes: Longint): Integer; cdecl = nil;
f_RAND_write_file         : function(const FileName: PChar): Integer; cdecl = nil;
f_RAND_status             : function: Integer; cdecl = nil;
f_RAND_cleanup            : procedure; cdecl = nil;
f_RAND_poll               : function: Integer; cdecl = nil;
f_RAND_add                : procedure(buf: Pointer; num: Integer; entropy: Double); cdecl = nil;
f_RAND_bytes              : function(buf: PChar; num: Integer): Integer; cdecl = nil;
f_RAND_pseudo_bytes       : function(buf: PChar; num: Integer): Integer; cdecl = nil;

f_RSA_free                : procedure(RSA: PRSA); cdecl = nil;

f_X509V3_EXT_conf_nid     : function(Conf: PLHASH; Ctx: PX509V3_CTX; ext_nid: Integer; value: PChar): PX509_EXTENSION; cdecl = nil;
f_X509_add_ext            : function(Cert: PX509; Ex: PX509_EXTENSION; loc: Integer): Integer; cdecl = nil;
f_X509_EXTENSION_free     : procedure(Ext: PX509_EXTENSION); cdecl = nil;

f_X509_Req_new            : function: PX509_REQ; cdecl = nil;
f_X509_REQ_set_pubkey     : function(Req: PX509_REQ; PKey: PEVP_PKEY): Integer; cdecl = nil;
f_X509_REQ_set_version    : function(Req: PX509_REQ; Version: LongInt): Integer; cdecl = nil;
f_X509_REQ_sign           : function(Req: PX509_REQ; PKey: PEVP_PKEY; const Md: PEVP_MD): Integer; cdecl = nil;
f_X509_REQ_add_extensions : function(Req: PX509_REQ; Exts: PSTACK): Integer; cdecl = nil;
f_X509_REQ_free           : procedure(Req: PX509_REQ); cdecl = nil;

f_EVP_PKEY_size           : function(Pkey: PEVP_PKEY): Integer; cdecl = nil;
f_RSA_public_encrypt      : function(flen: Integer; from: PChar; to_: PChar; rsa: PRSA; padding: Integer): Integer; cdecl = nil;
f_RSA_private_decrypt     : function(flen: Integer; from: PChar; to_: PChar; rsa: PRSA; padding: Integer): Integer; cdecl = nil;


// High level OpenSSL Crypto stuff, most require OSSL 0.9.7
// Blowfish algo/modes
f_EVP_bf_cbc              : function: PEVP_CIPHER; cdecl = nil;
f_EVP_bf_ecb              : function: PEVP_CIPHER; cdecl = nil;
f_EVP_bf_cfb64            : function: PEVP_CIPHER; cdecl = nil;
f_EVP_bf_ofb              : function: PEVP_CIPHER; cdecl = nil;

f_EVP_CIPHER_CTX_new      : function: PEVP_CIPHER_CTX; cdecl = nil;
f_EVP_CIPHER_CTX_free     : procedure(ctx: PEVP_CIPHER_CTX); cdecl = nil;
f_EVP_CIPHER_CTX_init     : procedure(ctx: PEVP_CIPHER_CTX); cdecl = nil;
f_EVP_CIPHER_CTX_set_key_length : function(ctx: PEVP_CIPHER_CTX; keyl: Integer): LongBool; cdecl = nil;
f_EVP_CipherInit_ex       : function(ctx: PEVP_CIPHER_CTX; const cipher: PEVP_CIPHER; impl: PEngine; key, iv: PChar; enc: Integer): LongBool; cdecl = nil;
f_EVP_CipherUpdate        : function(ctx: PEVP_CIPHER_CTX; out_: PChar; var outl: Integer; const in_: PChar; inl: Integer): LongBool; cdecl = nil;
f_EVP_CipherFinal_ex      : function(ctx: PEVP_CIPHER_CTX; out_: PChar; var outl: Integer): LongBool; cdecl = nil;
f_EVP_CIPHER_CTX_cleanup  : function(ctx: PEVP_CIPHER_CTX): Integer; cdecl = nil;
f_EVP_BytesToKey          : function(const type_: PEVP_CIPHER; const md: PEVP_MD; const salt: PChar; const data: PChar; datalen, count : Integer; key, iv: PChar): Integer; cdecl = nil;
f_EVP_md5                 : function: PEVP_MD; cdecl = nil;

var
  LibeayExLoaded: Boolean = FALSE;
  THE_GLIBEAY_DLL_Handle : THandle = 0;

procedure LoadLibeayEx;
function  IcsRandSeedFromFile(const FileName: String; MaxBytes: Integer = -1): Integer;
procedure IcsRandPoll;

{ C-macros }
function f_X509_REQ_get_subject_name(AReq: PX509_REQ): PX509_NAME;


implementation

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function IcsRandSeedFromFile(const FileName: String; MaxBytes: Integer = -1): Integer;
begin
    Result := 0;
    if FileExists(FileName) then
    begin
        if MaxBytes < -1 then MaxBytes := -1;
        Result := f_RAND_load_file(PChar(FileName), MaxBytes);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure IcsRandPoll;
var
    ProcIDs, P : PDWORD;
    cbNeeded, cb, hProc, PID : DWORD;
    I : Integer;
    hPsApi : THandle;
    ProcMemCnt : TProcessMemoryCounters;
begin
    f_RAND_Poll; // Uses Tool Help32 Functions beside other methods to seed the RNG
    // depending on the windows version.
    // if PSAPI.dll is available I think we should add some additional seed
    hPsApi := LoadLibrary('PSAPI.dll');
    if hPsApi < 32 then Exit;
    FreeLibrary(hPsApi);

    cb := 1024;
    GetMem(ProcIDs, cb);
    try
        while True do
        begin
            if not EnumProcesses(ProcIDs, cb, cbNeeded) then
                RaiseLastOSError;
            if cbNeeded < cb then
                Break;
            Inc(cb, 1024);
            FreeMem(ProcIDs);
            GetMem(ProcIDs, cb);
        end;
        P := ProcIDs;
        for I := 1 to cbNeeded div SizeOf(DWORD) do
        begin
            PID := P^;
            Inc(P);
            hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, PID);
            if hProc <> 0 then
            try
                if GetProcessMemoryInfo(hProc, @ProcMemCnt, SizeOf(ProcMemCnt)) then
                    f_RAND_seed(@ProcMemCnt.PageFaultCount, SizeOf(ProcMemCnt.PageFaultCount));
            finally
                CloseHandle(hProc);
            end;
        end;
    finally
        FreeMem(ProcIDs);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function f_X509_REQ_get_subject_name(AReq: PX509_REQ): PX509_NAME;
begin
    Result := AReq^.req_info^.subject;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure LoadLibeayEx;
const
    Msg = 'GetProcAddress failed ';
begin
    {if not Load then Exit;
    LibeayExLoaded :=  LibeayExLoaded and (GLIBEAY_DLL_Handle = THE_GLIBEAY_DLL_Handle);
    if not LibeayExLoaded then
        THE_GLIBEAY_DLL_Handle := GLIBEAY_DLL_Handle
    else
        Exit;}

    if LibeayExLoaded and (GLIBEAY_DLL_Handle <> 0) then Exit;
    if GLIBEAY_DLL_Handle = 0 then
        Load;

    f_RAND_pseudo_bytes := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_pseudo_bytes');
    if not Assigned(f_RAND_pseudo_bytes) then
        raise Exception.Create(Msg + 'RAND_pseudo_bytes');
    f_RAND_bytes := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_bytes');
    if not Assigned(f_RAND_bytes) then
        raise Exception.Create(Msg + 'RAND_bytes');
    f_RAND_add  := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_add');
    if not Assigned(f_RAND_add) then
        raise Exception.Create(Msg + 'RAND_add');
    f_RAND_poll := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_poll');
    if not Assigned(f_RAND_poll) then
        raise Exception.Create(Msg + 'RAND_poll');
    f_RAND_load_file := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_load_file');
    if not Assigned(f_RAND_load_file) then
        raise Exception.Create(Msg + 'RAND_load_file');
    f_RAND_write_file := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_write_file');
    if not Assigned(f_RAND_write_file) then
        raise Exception.Create(Msg + 'RAND_write_file');
    f_RAND_screen := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_screen');
    if not Assigned(f_RAND_screen) then
        raise Exception.Create(Msg + 'RAND_screen');
    f_RAND_status := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_status');
    if not Assigned(f_RAND_status) then
        raise Exception.Create(Msg + 'RAND_status');
    f_RAND_cleanup := GetProcAddress(GLIBEAY_DLL_Handle, 'RAND_cleanup');
    if not Assigned(f_RAND_cleanup) then
        raise Exception.Create(Msg + 'RAND_cleanup');
    f_X509_add_ext := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_add_ext');
    if not Assigned(f_X509_add_ext) then
        raise Exception.Create(Msg + 'X509_add_ext');
    f_X509_EXTENSION_free := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_EXTENSION_free');
    if not Assigned(f_X509_EXTENSION_free) then
        raise Exception.Create(Msg + 'X509_EXTENSION_free');
    f_X509V3_EXT_conf_nid := GetProcAddress(GLIBEAY_DLL_Handle, 'X509V3_EXT_conf_nid');
    if not Assigned(f_X509V3_EXT_conf_nid) then
        raise Exception.Create(Msg + 'X509V3_EXT_conf_nid');
    f_RSA_free := GetProcAddress(GLIBEAY_DLL_Handle, 'RSA_free');
    if not Assigned(f_RSA_free) then
        raise Exception.Create(Msg + 'RSA_free');
    f_X509_Req_new := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_new');
    if not Assigned(f_X509_Req_new) then
        raise Exception.Create(Msg + 'X509_REQ_new');
    f_X509_REQ_set_pubkey := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_set_pubkey');
    if not Assigned(f_X509_REQ_set_pubkey) then
        raise Exception.Create(Msg + 'X509_REQ_set_pubkey');
    f_X509_REQ_sign := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_sign');
    if not Assigned(f_X509_REQ_sign) then
        raise Exception.Create(Msg + 'X509_REQ_sign');
    f_X509_REQ_free := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_free');
    if not Assigned(f_X509_REQ_free) then
        raise Exception.Create(Msg + 'X509_REQ_free');
    f_X509_REQ_set_version := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_set_version');
    if not Assigned(f_X509_REQ_set_version) then
        raise Exception.Create(Msg + 'X509_REQ_set_version');
    f_X509_REQ_add_extensions:=GetProcAddress(GLIBEAY_DLL_Handle, 'X509_REQ_add_extensions');
    if not Assigned(f_X509_REQ_add_extensions) then
        raise Exception.Create(Msg + 'X509_REQ_add_extensions');
    f_X509_PUBKEY_free := GetProcAddress(GLIBEAY_DLL_Handle, 'X509_PUBKEY_free');
    if not Assigned(f_X509_PUBKEY_free) then
        raise Exception.Create(Msg + 'X509_PUBKEY_free');
    f_EVP_PKEY_size := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_PKEY_size');
    if not Assigned(f_EVP_PKEY_size) then
        raise Exception.Create(Msg + 'EVP_PKEY_size');
    f_RSA_public_encrypt := GetProcAddress(GLIBEAY_DLL_Handle, 'RSA_public_encrypt');
    if not Assigned(f_RSA_public_encrypt) then
        raise Exception.Create(Msg + 'RSA_public_encrypt');
    f_RSA_private_decrypt := GetProcAddress(GLIBEAY_DLL_Handle, 'RSA_private_decrypt');
    if not Assigned(f_RSA_private_decrypt) then
        raise Exception.Create(Msg + 'RSA_private_decrypt');
    f_EVP_bf_cbc := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_bf_cbc');
    if not Assigned(f_EVP_bf_cbc) then
        raise Exception.Create(Msg + 'EVP_bf_cbc');
    f_EVP_bf_ecb := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_bf_ecb');
    if not Assigned(f_EVP_bf_ecb) then
        raise Exception.Create(Msg + 'EVP_bf_ecb');
    f_EVP_bf_cfb64 := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_bf_cfb64');
    if not Assigned(f_EVP_bf_cfb64) then
        raise Exception.Create(Msg + 'EVP_bf_cfb64');
    f_EVP_bf_ofb := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_bf_ofb');
    if not Assigned(f_EVP_bf_ofb) then
        raise Exception.Create(Msg + 'EVP_bf_ofb');
    f_EVP_CIPHER_CTX_new := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CIPHER_CTX_new');
    if not Assigned(f_EVP_CIPHER_CTX_new) then
        raise Exception.Create(Msg + 'EVP_CIPHER_CTX_new');
    f_EVP_CIPHER_CTX_free := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CIPHER_CTX_free');
    if not Assigned(f_EVP_CIPHER_CTX_free) then
        raise Exception.Create(Msg + 'EVP_CIPHER_CTX_free');
    f_EVP_CIPHER_CTX_init := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CIPHER_CTX_init');
    if not Assigned(f_EVP_CIPHER_CTX_init) then
        raise Exception.Create(Msg + 'EVP_CIPHER_CTX_init');
    f_EVP_CipherInit_ex := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CipherInit_ex');
    if not Assigned(f_EVP_CipherInit_ex) then
        raise Exception.Create(Msg + 'EVP_CipherInit_ex');
    f_EVP_CipherUpdate := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CipherUpdate');
    if not Assigned(f_EVP_CipherUpdate) then
        raise Exception.Create(Msg + 'EVP_CipherUpdate');
    f_EVP_CipherFinal_ex := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CipherFinal_ex');
    if not Assigned(f_EVP_CipherFinal_ex) then
        raise Exception.Create(Msg + 'EVP_CipherFinal_ex');
    f_EVP_CIPHER_CTX_cleanup := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CIPHER_CTX_cleanup');
    if not Assigned(f_EVP_CIPHER_CTX_cleanup) then
        raise Exception.Create(Msg + 'EVP_CIPHER_CTX_cleanup');
    f_EVP_CIPHER_CTX_set_key_length := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_CIPHER_CTX_set_key_length');
    if not Assigned(f_EVP_CIPHER_CTX_set_key_length) then
        raise Exception.Create(Msg + 'EVP_CIPHER_CTX_set_key_length');
    f_EVP_BytesToKey := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_BytesToKey');
    if not Assigned(f_EVP_BytesToKey) then
        raise Exception.Create(Msg + 'EVP_BytesToKey');
    f_EVP_md5 := GetProcAddress(GLIBEAY_DLL_Handle, 'EVP_md5');
    if not Assigned(f_EVP_md5) then
        raise Exception.Create(Msg + 'EVP_md5');

    LibeayExLoaded := TRUE;

end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}


end.
