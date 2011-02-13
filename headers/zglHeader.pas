{-------------------------------}
{-----------= ZenGL =-----------}
{-------------------------------}
{                               }
{ version:  0.2 RC7             }
{ date:     2011.02.13          }
{ license:  GNU LGPL version 3  }
{ homepage: http://zengl.org    }
{                               }
{-------- developed by: --------}
{                               }
{     Kemka Andrey aka Andru    }
{                               }
{ mail: dr.andru@gmail.com      }
{ JID:  dr.andru@googlemail.com }
{ ICQ:  496929849               }
{ www:  http://andru-kun.inf.ua }
{                               }
{-------------------------------}
unit zglHeader;

{$IFDEF FPC}
  {$MODE DELPHI}
  {$MACRO ON}
  {$PACKRECORDS C}
  {$IFDEF LINUX}
    {$DEFINE LINUX_OR_DARWIN}
  {$ENDIF}
  {$IFDEF DARWIN}
    {$DEFINE LINUX_OR_DARWIN}
  {$ENDIF}
{$ENDIF}

{$IFDEF MSWINDOWS}
  {$DEFINE WINDOWS}
{$ENDIF}

interface
{$IFDEF DARWIN}
uses
  MacOSAll;
{$ENDIF}

type
  Ptr     = {$IFDEF CPU64}QWORD{$ELSE}LongWord{$ENDIF};
  PPtr    = ^Ptr;
  {$IFDEF WINDOWS}
  HANDLE  = LongWord;
  HDC     = LongWord;
  HGLRC   = LongWord;
  {$ENDIF}

type
  zglTStringList = record
    Count : Integer;
    Items : array of String;
end;

{$IFNDEF WINDOWS}
type zglTFile = LongInt;
{$ELSE}
type zglTFile = LongWord;
{$ENDIF}
type zglTFileList = zglTStringList;
type
  zglPMemory = ^zglTMemory;
  zglTMemory = record
    Memory   : Pointer;
    Size     : LongWord;
    Position : LongWord;
end;

const
{$IFDEF LINUX}
  libZenGL = 'libZenGL.so';
{$ENDIF}
{$IFDEF WINDOWS}
  libZenGL = 'ZenGL.dll';
{$ENDIF}
{$IFDEF DARWIN}
  libZenGL = 'libZenGL.dylib';
var
  mainPath : AnsiString;
{$ENDIF}

function zglLoad( LibraryName : AnsiString; Error : Boolean = TRUE ) : Boolean;
procedure zglFree;

var
  zgl_Init         : procedure( FSAA : Byte = 0; StencilBits : Byte = 0 );
  zgl_InitToHandle : procedure( Handle : Ptr; FSAA : Byte = 0; StencilBits : Byte = 0 );
  zgl_Exit         : procedure;

const
  SYS_APP_INIT           = $000001;
  SYS_APP_LOOP           = $000002;
  SYS_LOAD               = $000003;
  SYS_DRAW               = $000004;
  SYS_UPDATE             = $000005;
  SYS_EXIT               = $000006;
  SYS_ACTIVATE           = $000007;
  TEX_FORMAT_EXTENSION   = $000010;
  TEX_FORMAT_FILE_LOADER = $000011;
  TEX_FORMAT_MEM_LOADER  = $000012;
  TEX_CURRENT_EFFECT     = $000013;
  SND_FORMAT_EXTENSION   = $000020;
  SND_FORMAT_FILE_LOADER = $000021;
  SND_FORMAT_MEM_LOADER  = $000022;
  SND_FORMAT_DECODER     = $000023;

var
  zgl_Reg : procedure( What : LongWord; UserData : Pointer );

const
  ZENGL_VERSION           = 1; // Major shr 16, ( Minor and $FF00 ) shr 8, Revision and $FF
  ZENGL_VERSION_STRING    = 2; // PChar
  ZENGL_VERSION_DATE      = 3; // PChar

  DIRECTORY_APPLICATION   = 101; // PChar
  DIRECTORY_HOME          = 102; // PChar

  LOG_FILENAME            = 203; // PPAnsiChar

  DESKTOP_WIDTH           = 300;
  DESKTOP_HEIGHT          = 301;
  RESOLUTION_LIST         = 302; // zglPResolutionList

  WINDOW_HANDLE           = 400; // TWindow(GNU/Linux), HWND(Windows), WindowRef(MacOS X)
  WINDOW_X                = 401;
  WINDOW_Y                = 402;
  WINDOW_WIDTH            = 403;
  WINDOW_HEIGHT           = 404;

  GAPI_CONTEXT            = 500; // GLXContext(GNU/Linux), HGLRC(Windows), TAGLContext(MacOS X)
  GAPI_DEVICE             = 500; // For ZenGL with Direct3D render only
  GAPI_MAX_TEXTURE_SIZE   = 501;
  GAPI_MAX_TEXTURE_UNITS  = 502;
  GAPI_MAX_ANISOTROPY     = 503;
  GAPI_CAN_BLEND_SEPARATE = 504; // Boolean

  VIEWPORT_WIDTH          = 600;
  VIEWPORT_HEIGHT         = 601;
  VIEWPORT_OFFSET_X       = 602;
  VIEWPORT_OFFSET_Y       = 603;

  RENDER_FPS              = 700;
  RENDER_BATCHES_2D       = 701;

  MANAGER_TIMER           = 800; // zglPTimerManager
  MANAGER_TEXTURE         = 801; // zglPTextureManager
  MANAGER_ATLAS           = 802; // zglPAtlasManager
  MANAGER_FONT            = 803; // zglPFontManager
  MANAGER_RTARGET         = 804; // zglPRenderTargetManager
  MANAGER_SOUND           = 805; // zglPSoundManager
  MANAGER_EMITTER2D       = 806; // zglPEmitter2DManager

var
  zgl_Get         : function( What : LongWord ) : Ptr;
  zgl_GetMem      : procedure( var Mem : Pointer; Size : LongWord );
  zgl_FreeMem     : procedure( var Mem : Pointer );
  zgl_FreeStrList : procedure( var List : zglTStringList );

const
  COLOR_BUFFER_CLEAR    = $000001;
  DEPTH_BUFFER          = $000002;
  DEPTH_BUFFER_CLEAR    = $000004;
  DEPTH_MASK            = $000008;
  STENCIL_BUFFER_CLEAR  = $000010;
  CORRECT_RESOLUTION    = $000020;
  CORRECT_WIDTH         = $000040;
  CORRECT_HEIGHT        = $000080;
  APP_USE_AUTOPAUSE     = $000100;
  APP_USE_LOG           = $000200;
  APP_USE_ENGLISH_INPUT = $000400;
  APP_USE_UTF8          = $000800;
  WND_USE_AUTOCENTER    = $001000;
  SND_CAN_PLAY          = $002000;
  SND_CAN_PLAY_FILE     = $004000;
  CLIP_INVISIBLE        = $008000;

var
  zgl_Enable  : procedure( What : LongWord );
  zgl_Disable : procedure( What : LongWord );

// LOG
  log_Add : procedure( const Message : AnsiString; Timings : Boolean = TRUE );

// WINDOW
  wnd_SetCaption : procedure( const NewCaption : String );
  wnd_SetSize    : procedure( Width, Height : Integer );
  wnd_SetPos     : procedure( X, Y : Integer );
  wnd_ShowCursor : procedure( Show : Boolean );

// SCREEN
type
  zglPResolutionList = ^zglTResolutionList;
  zglTResolutionList = record
    Count  : Integer;
    Width  : array of Integer;
    Height : array of Integer;
end;

const
  REFRESH_MAXIMUM = 0;
  REFRESH_DEFAULT = 1;

var
  scr_Clear             : procedure;
  scr_Flush             : procedure;
  scr_SetVSync          : procedure( VSync : Boolean );
  // RU: ВНИМАНИЕ: Функция уничтожает контекст OpenGL, что потребует перезагрузку ресурсов
  // EN: WARNING: Function will destroy OpenGL context, so all resources must be reloaded
  scr_SetFSAA           : procedure( FSAA : Byte );
  scr_SetOptions        : procedure( Width, Height, Refresh : Word; FullScreen, VSync : Boolean );
  scr_CorrectResolution : procedure( Width, Height : Word );
  scr_ReadPixels        : procedure( var pData : Pointer; X, Y, Width, Height : Word );

// GL
const
  TARGET_SCREEN  = 1;
  TARGET_TEXTURE = 2;

var
  Set2DMode : procedure;
  Set3DMode : procedure( FOVY : Single = 45 );

// Z BUFFER
  zbuffer_SetDepth  : procedure( zNear, zFar : Single );
  zbuffer_Clear     : procedure;

// SCISSOR
  scissor_Begin : procedure( X, Y, Width, Height : Integer );
  scissor_End   : procedure;

// INI
  ini_LoadFromFile  : function( const FileName : String ) : Boolean;
  ini_SaveToFile    : procedure( const FileName : String );
  ini_Add           : procedure( const Section, Key : AnsiString );
  ini_Del           : procedure( const Section, Key : AnsiString );
  ini_Clear         : procedure( const Section : AnsiString );
  ini_IsSection     : function( const Section : AnsiString ) : Boolean;
  ini_IsKey         : function( const Section, Key : AnsiString ) : Boolean;
  _ini_ReadKeyStr   : function( const Section, Key : AnsiString ) : PAnsiChar;
  ini_ReadKeyInt    : function( const Section, Key : AnsiString ) : Integer;
  ini_ReadKeyFloat  : function( const Section, Key : AnsiString ) : Single;
  ini_ReadKeyBool   : function( const Section, Key : AnsiString ) : Boolean;
  ini_WriteKeyStr   : function( const Section, Key, Value : AnsiString ) : Boolean;
  ini_WriteKeyInt   : function( const Section, Key : AnsiString; Value : Integer ) : Boolean;
  ini_WriteKeyFloat : function( const Section, Key : AnsiString; Value : Single; Digits : Integer = 2 ) : Boolean;
  ini_WriteKeyBool  : function( const Section, Key : AnsiString; Value : Boolean ) : Boolean;

  function ini_ReadKeyStr( const Section, Key : AnsiString ) : AnsiString;

// TIMERS
type
  zglPTimer = ^zglTTimer;
  zglTTimer = record
    Active     : Boolean;
    Interval   : LongWord;
    LastTick   : Double;
    OnTimer    : procedure;

    Prev, Next : zglPTimer;
end;

type
  zglPTimerManager = ^zglTTimerManager;
  zglTTimerManager = record
    Count   : Integer;
    First   : zglTTimer;
end;

var
  timer_Add      : function( OnTimer : Pointer; Interval : LongWord ) : zglPTimer;
  timer_Del      : procedure( var Timer : zglPTimer );
  timer_GetTicks : function : Double;
  timer_Reset    : procedure;

// MOUSE
const
  M_BLEFT   = 0;
  M_BMIDDLE = 1;
  M_BRIGHT  = 2;
  M_WUP     = 0;
  M_WDOWN   = 1;

var
  mouse_X          : function : Integer;
  mouse_Y          : function : Integer;
  mouse_DX         : function : Integer;
  mouse_DY         : function : Integer;
  mouse_Down       : function( Button : Byte ) : Boolean;
  mouse_Up         : function( Button : Byte ) : Boolean;
  mouse_Click      : function( Button : Byte ) : Boolean;
  mouse_DblClick   : function( Button : Byte ) : Boolean;
  mouse_Wheel      : function( Axis : Byte ) : Boolean;
  mouse_ClearState : procedure;
  mouse_Lock       : procedure;

// KEYBOARD
const
  K_SYSRQ      = $B7;
  K_PAUSE      = $C5;
  K_ESCAPE     = $01;
  K_ENTER      = $1C;
  K_KP_ENTER   = $9C;

  K_UP         = $C8;
  K_DOWN       = $D0;
  K_LEFT       = $CB;
  K_RIGHT      = $CD;

  K_BACKSPACE  = $0E;
  K_SPACE      = $39;
  K_TAB        = $0F;
  K_TILDE      = $29;

  K_INSERT     = $D2;
  K_DELETE     = $D3;
  K_HOME       = $C7;
  K_END        = $CF;
  K_PAGEUP     = $C9;
  K_PAGEDOWN   = $D1;

  K_CTRL       = $FF - $01;
  K_CTRL_L     = $1D;
  K_CTRL_R     = $9D;
  K_ALT        = $FF - $02;
  K_ALT_L      = $38;
  K_ALT_R      = $B8;
  K_SHIFT      = $FF - $03;
  K_SHIFT_L    = $2A;
  K_SHIFT_R    = $36;
  K_SUPER      = $FF - $04;
  K_SUPER_L    = $DB;
  K_SUPER_R    = $DC;
  K_APP_MENU   = $DD;

  K_CAPSLOCK   = $3A;
  K_NUMLOCK    = $45;
  K_SCROLL     = $46;

  K_BRACKET_L  = $1A; // [ {
  K_BRACKET_R  = $1B; // ] }
  K_BACKSLASH  = $2B; // \
  K_SLASH      = $35; // /
  K_COMMA      = $33; // ,
  K_DECIMAL    = $34; // .
  K_SEMICOLON  = $27; // : ;
  K_APOSTROPHE = $28; // ' "

  K_0          = $0B;
  K_1          = $02;
  K_2          = $03;
  K_3          = $04;
  K_4          = $05;
  K_5          = $06;
  K_6          = $07;
  K_7          = $08;
  K_8          = $09;
  K_9          = $0A;

  K_MINUS      = $0C;
  K_EQUALS     = $0D;

  K_A          = $1E;
  K_B          = $30;
  K_C          = $2E;
  K_D          = $20;
  K_E          = $12;
  K_F          = $21;
  K_G          = $22;
  K_H          = $23;
  K_I          = $17;
  K_J          = $24;
  K_K          = $25;
  K_L          = $26;
  K_M          = $32;
  K_N          = $31;
  K_O          = $18;
  K_P          = $19;
  K_Q          = $10;
  K_R          = $13;
  K_S          = $1F;
  K_T          = $14;
  K_U          = $16;
  K_V          = $2F;
  K_W          = $11;
  K_X          = $2D;
  K_Y          = $15;
  K_Z          = $2C;

  K_KP_0       = $52;
  K_KP_1       = $4F;
  K_KP_2       = $50;
  K_KP_3       = $51;
  K_KP_4       = $4B;
  K_KP_5       = $4C;
  K_KP_6       = $4D;
  K_KP_7       = $47;
  K_KP_8       = $48;
  K_KP_9       = $49;

  K_KP_SUB     = $4A;
  K_KP_ADD     = $4E;
  K_KP_MUL     = $37;
  K_KP_DIV     = $B5;
  K_KP_DECIMAL = $53;

  K_F1         = $3B;
  K_F2         = $3C;
  K_F3         = $3D;
  K_F4         = $3E;
  K_F5         = $3F;
  K_F6         = $40;
  K_F7         = $41;
  K_F8         = $42;
  K_F9         = $43;
  K_F10        = $44;
  K_F11        = $57;
  K_F12        = $58;

  KA_DOWN     = 0;
  KA_UP       = 1;
var
  key_Down          : function( KeyCode : Byte ) : Boolean;
  key_Up            : function( KeyCode : Byte ) : Boolean;
  key_Press         : function( KeyCode : Byte ) : Boolean;
  key_Last          : function( KeyAction : Byte ) : Byte;
  key_BeginReadText : procedure( const Text : String; MaxSymbols : Integer = -1 );
  _key_GetText      : function : PChar;
  key_EndReadText   : procedure;
  key_ClearState    : procedure;

  function key_GetText : String;

// JOYSTICK
type
  zglPJoyInfo = ^zglTJoyInfo;
  zglTJoyInfo = record
    Name   : AnsiString;
    Count  : record
      Axes    : Integer;
      Buttons : Integer;
             end;
    Caps   : LongWord;
  end;

const
  JOY_HAS_Z   = $000001;
  JOY_HAS_R   = $000002;
  JOY_HAS_U   = $000004;
  JOY_HAS_V   = $000008;
  JOY_HAS_POV = $000010;

  JOY_AXIS_X = 0;
  JOY_AXIS_Y = 1;
  JOY_AXIS_Z = 2;
  JOY_AXIS_R = 3;
  JOY_AXIS_U = 4;
  JOY_AXIS_V = 5;
  JOY_POVX   = 6;
  JOY_POVY   = 7;

var
  joy_Init       : function : Byte;
  joy_GetInfo    : function( JoyID : Byte ) : zglPJoyInfo;
  joy_AxisPos    : function( JoyID, Axis : Byte ) : Single;
  joy_Down       : function( JoyID, Button : Byte ) : Boolean;
  joy_Up         : function( JoyID, Button : Byte ) : Boolean;
  joy_Press      : function( JoyID, Button : Byte ) : Boolean;
  joy_ClearState : procedure;

// 2D
type
  zglPPoint2D = ^zglTPoint2D;
  zglTPoint2D = record
    X, Y : Single;
end;

type
  zglPPoints2D = ^zglTPoints2D;
  zglTPoints2D = array[ 0..0 ] of zglTPoint2D;

type
  zglPLine = ^zglTLine;
  zglTLine = record
    x0, y0 : Single;
    x1, y1 : Single;
end;

type
  zglPRect = ^zglTRect;
  zglTRect = record
    X, Y, W, H : Single;
end;

type
  zglPCircle = ^zglTCircle;
  zglTCircle = record
    cX, cY : Single;
    Radius : Single;
end;

// TEXTURES
type
  zglPTextureCoord = ^zglTTextureCoord;
  zglTTextureCoord = array[ 0..3 ] of zglTPoint2D;

type
  zglPTexture = ^zglTTexture;
  zglTTexture = record
    ID            : LongWord;
    Width, Height : Word;
    U, V          : Single;
    FramesX       : Word;
    FramesY       : Word;
    FramesCoord   : array of zglTTextureCoord;
    Flags         : LongWord;

    prev, next    : zglPTexture;
end;

type
  zglPTextureFormat = ^zglTTextureFormat;
  zglTTextureFormat = record
    Extension  : String;
    FileLoader : procedure( const FileName : String; var pData : Pointer; var W, H : Word );
    MemLoader  : procedure( const Memory : zglTMemory; var pData : Pointer; var W, H : Word );
end;

type
  zglPTextureManager = ^zglTTextureManager;
  zglTTextureManager = record
    Count   : record
      Items   : Integer;
      Formats : Integer;
              end;
    First   : zglTTexture;
    Formats : array of zglTTextureFormat;
end;

const
  TEX_MIPMAP            = $000001;
  TEX_CLAMP             = $000002;
  TEX_REPEAT            = $000004;
  TEX_COMPRESS          = $000008;

  TEX_CONVERT_TO_POT    = $000010;
  TEX_CALCULATE_ALPHA   = $000020;

  TEX_GRAYSCALE         = $000040;
  TEX_INVERT            = $000080;
  TEX_CUSTOM_EFFECT     = $000100;

  TEX_FILTER_NEAREST    = $000200;
  TEX_FILTER_LINEAR     = $000400;
  TEX_FILTER_BILINEAR   = $000800;
  TEX_FILTER_TRILINEAR  = $001000;
  TEX_FILTER_ANISOTROPY = $002000;

  TEX_DEFAULT_2D        = TEX_CLAMP or TEX_FILTER_LINEAR or TEX_CONVERT_TO_POT or TEX_CALCULATE_ALPHA;

var
  tex_Add            : function : zglPTexture;
  tex_Del            : procedure( var Texture : zglPTexture );
  tex_Create         : procedure( var Texture : zglTTexture; var pData : Pointer );
  tex_CreateZero     : function( Width, Height : Word; Color : LongWord = $000000; Flags : LongWord = TEX_DEFAULT_2D ) : zglPTexture;
  tex_LoadFromFile   : function( const FileName : String; TransparentColor : LongWord = $FF000000; Flags : LongWord = TEX_DEFAULT_2D ) : zglPTexture;
  tex_LoadFromMemory : function( const Memory : zglTMemory; const Extension : String; TransparentColor : LongWord = $FF000000; Flags : LongWord = TEX_DEFAULT_2D ) : zglPTexture;
  tex_SetFrameSize   : procedure( var Texture : zglPTexture; FrameWidth, FrameHeight : Word );
  tex_SetMask        : function( var Texture : zglPTexture; Mask : zglPTexture ) : zglPTexture;
  tex_SetData        : procedure( Texture : zglPTexture; pData : Pointer; X, Y, Width, Height : Word; Stride : Integer = 0 );
  tex_GetData        : procedure( Texture : zglPTexture; var pData : Pointer );
  tex_Filter         : procedure( Texture : zglPTexture; Flags : LongWord );
  tex_SetAnisotropy  : procedure( Level : Byte );

// ATLASES
type
  zglPAtlasNode = ^zglTAtlasNode;
  zglTAtlasNode = record
    Leaf     : Boolean;
    Texture  : zglPTexture;
    TexCoord : zglTTextureCoord;
    FramesX  : Word;
    FramesY  : Word;
    Rect     : zglTRect;
    child    : array[ 0..1 ] of zglPAtlasNode;
  end;

type
  zglPAtlas = ^zglTAtlas;
  zglTAtlas = record
    root       : zglTAtlasNode;
    Texture    : zglPTexture;
    Full       : Boolean;
    prev, next : zglPAtlas;
  end;

type
  zglPAtlasManager = ^zglTAtlasManager;
  zglTAtlasManager = record
    Count : Integer;
    First : zglTAtlas;
end;

var
  atlas_Add               : function( Width, Height : Word; Flags : LongWord ) : zglPAtlas;
  atlas_Del               : procedure( var Atlas : zglPAtlas );
  atlas_GetFrameCoord     : procedure( Node : zglPAtlasNode; Frame : Word; var TexCoord : array of zglTPoint2D );
  atlas_InsertFromTexture : function( Atlas : zglPAtlas; Texture : zglPTexture ) : zglPAtlasNode;
  atlas_InsertFromFile    : function( Atlas : zglPAtlas; const FileName : String; TransparentColor, Flags : LongWord ) : zglPAtlasNode;
  atlas_InsertFromMemory  : function( Atlas : zglPAtlas; const Memory : zglTMemory; const Extension : String; TransparentColor, Flags : LongWord ) : zglPAtlasNode;

// RENDER TARGETS
type
  zglPRenderTarget = ^zglTRenderTarget;
  zglTRenderTarget = record
    _type      : Byte;
    Handle     : Pointer;
    Surface    : zglPTexture;
    Flags      : Byte;

    prev, next : zglPRenderTarget;
end;

type
  zglPRenderTargetManager = ^zglTRenderTargetManager;
  zglTRenderTargetManager = record
    Count : Integer;
    First : zglTRenderTarget;
end;

type
  zglTRenderCallback = procedure( Data : Pointer );

const
  RT_DEFAULT      = $00;
  RT_FULL_SCREEN  = $01;
  RT_USE_DEPTH    = $02;
  RT_CLEAR_COLOR  = $04;
  RT_CLEAR_DEPTH  = $08;
  RT_SAVE_CONTENT = $10; // Direct3D only!

var
  rtarget_Add    : function( Surface : zglPTexture; Flags : Byte ) : zglPRenderTarget;
  rtarget_Del    : procedure( var Target : zglPRenderTarget );
  rtarget_Set    : procedure( Target : zglPRenderTarget );
  rtarget_DrawIn : procedure( Target : zglPRenderTarget; RenderCallback : zglTRenderCallback; Data : Pointer );

// FX
const
  FX_BLEND_NORMAL = $00;
  FX_BLEND_ADD    = $01;
  FX_BLEND_MULT   = $02;
  FX_BLEND_BLACK  = $03;
  FX_BLEND_WHITE  = $04;
  FX_BLEND_MASK   = $05;

  FX_COLOR_MIX    = $00;
  FX_COLOR_SET    = $01;

  FX_BLEND        = $100000;
  FX_COLOR        = $200000;

var
  fx_SetBlendMode : procedure( Mode : Byte; SeparateAlpha : Boolean = TRUE );
  fx_SetColorMode : procedure( Mode : Byte );
  fx_SetColorMask : procedure( R, G, B, Alpha : Boolean );

// FX 2D
const
  FX2D_FLIPX    = $000001;
  FX2D_FLIPY    = $000002;
  FX2D_VCA      = $000004;
  FX2D_VCHANGE  = $000008;
  FX2D_SCALE    = $000010;

var
  fx2d_SetColor    : procedure( Color : LongWord );
  fx2d_SetVCA      : procedure( c1, c2, c3, c4 : LongWord; a1, a2, a3, a4 : Byte );
  fx2d_SetVertexes : procedure( x1, y1, x2, y2, x3, y3, x4, y4 : Single );
  fx2d_SetScale    : procedure( scaleX, scaleY : Single );

// Camera 2D
type
  zglPCamera2D = ^zglTCamera2D;
  zglTCamera2D = record
    X, Y  : Single;
    Angle : Single;
    Zoom  : zglTPoint2D;
end;

var
  cam2d_Set   : procedure( Camera : zglPCamera2D );
  cam2d_Get   : function : zglPCamera2D;

// Render 2D
  batch2d_Begin : procedure;
  batch2d_End   : procedure;
  batch2d_Flush : procedure;

// Primitives 2D
const
  PR2D_FILL   = $010000;
  PR2D_SMOOTH = $020000;

var
  pr2d_Pixel   : procedure( X, Y : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255 );
  pr2d_Line    : procedure( X1, Y1, X2, Y2 : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = 0 );
  pr2d_Rect    : procedure( X, Y, W, H : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = 0 );
  pr2d_Circle  : procedure( X, Y, Radius : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
  pr2d_Ellipse : procedure( X, Y, xRadius, yRadius : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
  pr2d_TriList : procedure( Texture : zglPTexture; TriList, TexCoords : zglPPoints2D; iLo, iHi : Integer; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = FX_BLEND );

// Sprites 2D
type
  zglPSprite2D = ^zglTSprite2D;
  zglPSEngine2D = ^zglTSEngine2D;

  zglTSEngine2D = record
    Count : Integer;
    List  : array of zglPSprite2D;
  end;

  zglTSprite2D = record
    ID      : Integer;
    Manager : zglPSEngine2D;
    Texture : zglPTexture;
    Destroy : Boolean;
    Layer   : LongWord;
    X, Y    : Single;
    W, H    : Single;
    Angle   : Single;
    Frame   : Single;
    Alpha   : Integer;
    FxFlags : LongWord;
    Data    : Pointer;

    OnInit  : procedure( Sprite : zglPSprite2D );
    OnDraw  : procedure( Sprite : zglPSprite2D );
    OnProc  : procedure( Sprite : zglPSprite2D );
    OnFree  : procedure( Sprite : zglPSprite2D );
  end;

type
  zglPTiles2D = ^zglTTiles2D;
  zglTTiles2D = record
    Count : record
      X, Y : Integer;
            end;
    Size  : record
      W, H : Single;
            end;
    Tiles : array of array of Integer;
  end;

type
  zglPGrid2D = ^zglTGrid2D;
  zglTGrid2D = record
    Cols : Integer;
    Rows : Integer;
    Grid : array of array of zglTPoint2D;
  end;

var
  sengine2d_AddSprite : function( Texture : zglPTexture; Layer : Integer; OnInit, OnDraw, OnProc, OnFree : Pointer ) : zglPSprite2D;
  sengine2d_DelSprite : procedure( ID : Integer );
  sengine2d_ClearAll  : procedure;
  sengine2d_Set       : procedure( SEngine : zglPSEngine2D );
  sengine2d_Draw      : procedure;
  sengine2d_Proc      : procedure;

  texture2d_Draw : procedure( Texture : zglPTexture; const TexCoord : array of zglTPoint2D; X, Y, W, H, Angle : Single; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  ssprite2d_Draw : procedure( Texture : zglPTexture; X, Y, W, H, Angle : Single; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  asprite2d_Draw : procedure( Texture : zglPTexture; X, Y, W, H, Angle : Single; Frame : Word; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  csprite2d_Draw : procedure( Texture : zglPTexture; X, Y, W, H, Angle : Single; const CutRect : zglTRect; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  tiles2d_Draw   : procedure( Texture : zglPTexture; X, Y : Single; Tiles : zglPTiles2D; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  sgrid2d_Draw   : procedure( Texture : zglPTexture; X, Y : Single; Grid : zglPGrid2D; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  agrid2d_Draw   : procedure( Texture : zglPTexture; X, Y : Single; Grid : zglPGrid2D; Frame : Integer; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  cgrid2d_Draw   : procedure( Texture : zglPTexture; X, Y : Single; Grid : zglPGrid2D; const CutRect : zglTRect; Alpha : Byte = 255; FX : LongWord = FX_BLEND );

// Particles
const
  EMITTER_MAX_PARTICLES = 1024;

  EMITTER_NONE      = 0;
  EMITTER_POINT     = 1;
  EMITTER_LINE      = 2;
  EMITTER_RECTANGLE = 3;
  EMITTER_CIRCLE    = 4;

type
  PDiagramByte         = ^TDiagramByte;
  PDiagramLW           = ^TDiagramLW;
  PDiagramSingle       = ^TDiagramSingle;
  zglPParticle2D       = ^zglTParticle2D;
  zglPEmitterPoint     = ^zglTEmitterPoint;
  zglPEmitterLine      = ^zglTEmitterLine;
  zglPEmitterRect      = ^zglTEmitterRect;
  zglPParticleParams   = ^zglTParticleParams;
  zglPEmitter2D        = ^zglTEmitter2D;
  zglPPEngine2D        = ^zglTPEngine2D;
  zglPEmitter2DManager = ^zglTEmitter2DManager;

  TDiagramByte = record
    Life  : Single;
    Value : Byte;
  end;

  TDiagramLW = record
    Life  : Single;
    Value : LongWord;
  end;

  TDiagramSingle = record
    Life  : Single;
    Value : Single;
  end;

  zglTParticle2D = record
    _lColorID     : Integer;
    _lAlphaID     : Integer;
    _lSizeXID     : Integer;
    _lSizeYID     : Integer;
    _lVelocityID  : Integer;
    _laVelocityID : Integer;
    _lSpinID      : Integer;
    ID            : Integer;

    Life          : Single;
    LifeTime      : Integer;
    Time          : Double;

    Frame         : Word;
    Color         : LongWord;
    Alpha         : Byte;

    Position      : zglTPoint2D;
    Size          : zglTPoint2D;
    SizeS         : zglTPoint2D;
    Angle         : Single;
    Direction     : Single;

    Velocity      : Single;
    VelocityS     : Single;
    aVelocity     : Single;
    aVelocityS    : Single;
    Spin          : Single;
  end;

  zglTEmitterPoint = record
    Direction : Single;
    Spread    : Single;
  end;

  zglTEmitterLine = record
    Direction : Single;
    Spread    : Single;
    Size      : Single;
    TwoSide   : Boolean;
  end;

  zglTEmitterRect = record
    Rect : zglTRect;
  end;

  zglPEmitterCircle = ^zglTEmitterCircle;
  zglTEmitterCircle = record
    cX, cY : Single;
    Radius : Single;
  end;

  zglTParticleParams = record
    Texture    : zglPTexture;
    BlendMode  : Byte;
    ColorMode  : Byte;

    LifeTimeS  : Integer;
    LifeTimeV  : Integer;
    Frame      : array[ 0..1 ] of Integer;
    Color      : array of TDiagramLW;
    Alpha      : array of TDiagramByte;
    SizeXYBind : Boolean;
    SizeXS     : Single;
    SizeYS     : Single;
    SizeXV     : Single;
    SizeYV     : Single;
    SizeXD     : array of TDiagramSingle;
    SizeYD     : array of TDiagramSingle;
    AngleS     : Single;
    AngleV     : Single;
    VelocityS  : Single;
    VelocityV  : Single;
    VelocityD  : array of TDiagramSingle;
    aVelocityS : Single;
    aVelocityV : Single;
    aVelocityD : array of TDiagramSingle;
    SpinS      : Single;
    SpinV      : Single;
    SpinD      : array of TDiagramSingle;
  end;

  zglTEmitter2D = record
    _type       : Byte;
    _pengine    : zglPPEngine2D;
    _particle   : array[ 0..EMITTER_MAX_PARTICLES - 1 ] of zglTParticle2D;
    _list       : array[ 0..EMITTER_MAX_PARTICLES - 1 ] of zglPParticle2D;
    _parCreated : Integer;
    _texFile    : String;
    _texHash    : LongWord;

    ID          : Integer;
    Params      : record
      Layer    : Integer;
      LifeTime : Integer;
      Loop     : Boolean;
      Emission : Integer;
      Position : zglTPoint2D;
                  end;
    ParParams   : zglTParticleParams;

    Life        : Single;
    Time        : Double;
    LastSecond  : Double;
    Particles   : Integer;
    BBox        : record
      MinX, MaxX : Single;
      MinY, MaxY : Single;
                  end;

    case Byte of
      EMITTER_POINT: ( AsPoint : zglTEmitterPoint );
      EMITTER_LINE: ( AsLine : zglTEmitterLine );
      EMITTER_RECTANGLE: ( AsRect : zglTEmitterRect );
      EMITTER_CIRCLE: ( AsCircle : zglTEmitterCircle );
  end;

  zglTPEngine2D = record
    Count : record
      Emitters  : Integer;
      Particles : Integer;
            end;
    List  : array of zglPEmitter2D;
  end;

  zglTEmitter2DManager = record
    Count : Integer;
    List  : array of zglPEmitter2D;
  end;

var
  pengine2d_Set            : procedure( PEngine : zglPPEngine2D );
  pengine2d_Get            : function : zglPPEngine2D;
  pengine2d_Draw           : procedure;
  pengine2d_Proc           : procedure( dt : Double );
  pengine2d_AddEmitter     : function( Emitter : zglPEmitter2D; X : Single = 0; Y : Single = 0 ) : zglPEmitter2D;
  pengine2d_DelEmitter     : procedure( ID : Integer );
  pengine2d_ClearAll       : procedure;
  emitter2d_Add            : function : zglPEmitter2D;
  emitter2d_Del            : procedure( var Emitter : zglPEmitter2D );
  emitter2d_LoadFromFile   : function( const FileName : String ) : zglPEmitter2D;
  emitter2d_LoadFromMemory : function( const Memory : zglTMemory ) : zglPEmitter2D;
  emitter2d_Init           : procedure( Emitter : zglPEmitter2D );
  emitter2d_Free           : procedure( var Emitter : zglPEmitter2D );
  emitter2d_Draw           : procedure( Emitter : zglPEmitter2D );
  emitter2d_Proc           : procedure( Emitter : zglPEmitter2D; dt : Double );

// Text
type
  zglPCharDesc = ^zglTCharDesc;
  zglTCharDesc = record
    Page      : Word;
    Width     : Byte;
    Height    : Byte;
    ShiftX    : Integer;
    ShiftY    : Integer;
    ShiftP    : Integer;
    TexCoords : array[ 0..3 ] of zglTPoint2D;
end;

type
  zglPFont = ^zglTFont;
  zglTFont = record
    Count      : record
      Pages : Word;
      Chars : Word;
                 end;

    Pages      : array of zglPTexture;
    CharDesc   : array[ 0..65535 ] of zglPCharDesc;
    MaxHeight  : Integer;
    MaxShiftY  : Integer;
    Padding    : array[ 0..3 ] of Byte;

    prev, next : zglPFont;
end;

type
  zglPFontManager = ^zglTFontManager;
  zglTFontManager = record
    Count : Integer;
    First : zglTFont;
end;

const
  TEXT_HALIGN_LEFT    = $000001;
  TEXT_HALIGN_CENTER  = $000002;
  TEXT_HALIGN_RIGHT   = $000004;
  TEXT_HALIGN_JUSTIFY = $000008;
  TEXT_VALIGN_TOP     = $000010;
  TEXT_VALIGN_CENTER  = $000020;
  TEXT_VALIGN_BOTTOM  = $000040;
  TEXT_FX_VCA         = $000080;

var
  font_Add            : function : zglPFont;
  font_Del            : procedure( var Font : zglPFont );
  font_LoadFromFile   : function( const FileName : String ) : zglPFont;
  font_LoadFromMemory : function( const Memory : zglTMemory ) : zglPFont;
  text_Draw           : procedure( Font : zglPFont; X, Y : Single; const Text : String; Flags : LongWord = 0 );
  text_DrawEx         : procedure( Font : zglPFont; X, Y, Scale, Step : Single; const Text : String; Alpha : Byte = 255; Color : LongWord = $FFFFFF; Flags : LongWord = 0 );
  text_DrawInRect     : procedure( Font : zglPFont; const Rect : zglTRect; const Text : String; Flags : LongWord = 0 );
  text_DrawInRectEx   : procedure( Font : zglPFont; const Rect : zglTRect; Scale, Step : Single; const Text : String; Alpha : Byte = 0; Color : LongWord = $FFFFFF; Flags : LongWord = 0 );
  text_GetWidth       : function( Font : zglPFont; const Text : String; Step : Single = 0.0 ) : Single;
  text_GetHeight      : function( Font : zglPFont; const Rect : zglTRect; const Text : String; Scale : Single = 1.0; Step : Single = 0.0 ) : Single;
  textFx_SetLength    : procedure( Length : Integer; LastCoord : zglPPoint2D = nil; LastCharDesc : zglPCharDesc = nil );

// Sound
const
  SND_ALL           = -2;
  SND_STREAM        = -3;

  SND_STATE_PLAYING = 1;
  SND_STATE_PERCENT = 2;
  SND_STATE_TIME    = 3;
  SND_INFO_LENGTH   = 4;

type
  zglPSound        = ^zglTSound;
  zglPSoundStream  = ^zglTSoundStream;
  zglPSoundDecoder = ^zglTSoundDecoder;
  zglPSoundFormat  = ^zglTSoundFormat;
  zglPSoundManager = ^zglTSoundManager;

  zglTSoundChannel = record
    Source     : LongWord;
    Speed      : Single;
    Volume     : Single;
    Position   : record
      X, Y, Z : Single;
                 end;
  end;

  zglTSound = record
    Buffer      : LongWord;
    SourceCount : LongWord;
    Channel     : array of zglTSoundChannel;

    Data        : Pointer;
    Size        : LongWord;
    Length      : Double;
    Frequency   : LongWord;

    prev, next  : zglPSound;
  end;

  zglTSoundStream = record
    _data      : Pointer;
    _file      : zglTFile;
    _decoder   : zglPSoundDecoder;
    _playing   : Boolean;
    _paused    : Boolean;
    _waiting   : Boolean;
    _complete  : Double;
    _lastTime  : Double;

    Buffer     : Pointer;
    BufferSize : LongWord;

    Frequency  : LongWord;
    Channels   : LongWord;
    Length     : Double;

    Loop       : Boolean;
  end;

  zglTSoundDecoder = record
    Ext   : String;
    Open  : function( var Stream : zglTSoundStream; const FileName : String ) : Boolean;
    Read  : function( var Stream : zglTSoundStream; Buffer : Pointer; Bytes : LongWord; var _End : Boolean ) : LongWord;
    Loop  : procedure( var Stream : zglTSoundStream );
    Close : procedure( var Stream : zglTSoundStream );
  end;

  zglTSoundFormat = record
    Extension  : String;
    Decoder    : zglPSoundDecoder;
    FileLoader : procedure( const FileName : String; var Data : Pointer; var Size, Format, Frequency : LongWord );
    MemLoader  : procedure( const Memory : zglTMemory; var Data : Pointer; var Size, Format, Frequency : LongWord );
  end;

  zglTSoundManager = record
    Count   : record
      Items   : Integer;
      Formats : Integer;
              end;
    First   : zglTSound;
    Formats : array of zglTSoundFormat;
  end;

var
  snd_Init              : function : Boolean;
  snd_Free              : procedure;
  snd_Add               : function( SourceCount : Integer ) : zglPSound;
  snd_Del               : procedure( var Sound : zglPSound );
  snd_LoadFromFile      : function( const FileName : String; SourceCount : Integer = 8 ) : zglPSound;
  snd_LoadFromMemory    : function( const Memory : zglTMemory; const Extension : String; SourceCount : Integer = 8 ) : zglPSound;
  snd_Play              : function( Sound : zglPSound; Loop : Boolean = FALSE; X : Single = 0; Y : Single = 0; Z : Single = 0 ) : Integer;
  snd_Stop              : procedure( Sound : zglPSound; ID : Integer );
  snd_SetPos            : procedure( Sound : zglPSound; ID : Integer; X, Y, Z : Single );
  snd_SetVolume         : procedure( Sound : zglPSound; ID : Integer; Volume : Single );
  snd_SetSpeed          : procedure( Sound : zglPSound; ID : Integer; Speed : Single );
  snd_Get               : function( Sound : zglPSound; ID, What : Integer ) : Integer;
  snd_PlayFile          : function( const FileName : String; Loop : Boolean = FALSE ) : Integer;
  snd_PauseFile         : procedure( ID : Integer );
  snd_StopFile          : procedure( ID : Integer );
  snd_ResumeFile        : procedure( ID : Integer );

// MATH
const
  pi      = 3.141592654;
  rad2deg = 57.29578049;
  deg2rad = 0.017453292;

  ORIENTATION_LEFT  = -1;
  ORIENTATION_RIGHT = 1;
  ORIENTATION_ZERO  = 0;

var
  m_Cos         : function( Angle : Integer ) : Single;
  m_Sin         : function( Angle : Integer ) : Single;
  m_Distance    : function( x1, y1, x2, y2 : Single ) : Single;
  m_FDistance   : function( x1, y1, x2, y2 : Single ) : Single;
  m_Angle       : function( x1, y1, x2, y2 : Single ) : Single;
  m_Orientation : function( x, y, x1, y1, x2, y2 : Single ) : Integer;

  tess_Triangulate : procedure( Contour : zglPPoints2D; iLo, iHi : Integer; AddHoles : Boolean = FALSE );
  tess_AddHole     : procedure( Contour : zglPPoints2D; iLo, iHi : Integer; LastHole : Boolean = TRUE );
  tess_GetData     : function( var TriPoints : zglPPoints2D ) : Integer;

// COLLISION 2D
  col2d_PointInRect     : function( X, Y : Single; const Rect : zglTRect ) : Boolean;
  col2d_PointInTriangle : function( X, Y : Single; const P1, P2, P3 : zglTPoint2D ) : Boolean;
  col2d_PointInCircle   : function( X, Y : Single; const Circle : zglTCircle ) : Boolean;
  // line 2d
  col2d_Line           : function( const A, B : zglTLine; ColPoint : zglPPoint2D ) : Boolean;
  col2d_LineVsRect     : function( const Line : zglTLine; const Rect : zglTRect; ColPoint : zglPPoint2D ) : Boolean;
  col2d_LineVsCircle   : function( const Line : zglTLine; const Circle : zglTCircle ) : Boolean;
  col2d_LineVsCircleXY : function( const Line : zglTLine; const Circle : zglTCircle; Precision : Byte; ColPoint : zglPPoint2D ) : Boolean;
  // rect
  col2d_Rect         : function( const Rect1, Rect2 : zglTRect ) : Boolean;
  col2d_ClipRect     : function( const Rect1, Rect2 : zglTRect ) : zglTRect;
  col2d_RectInRect   : function( const Rect1, Rect2 : zglTRect ) : Boolean;
  col2d_RectInCircle : function( const Rect : zglTRect; const Circle : zglTCircle ) : Boolean;
  col2d_RectVsCircle : function( const Rect : zglTRect; const Circle : zglTCircle ) : Boolean;
  // circle
  col2d_Circle         : function( const Circle1, Circle2 : zglTCircle ) : Boolean;
  col2d_CircleInCircle : function( const Circle1, Circle2 : zglTCircle ) : Boolean;
  col2d_CircleInRect   : function( const Circle : zglTCircle; const Rect : zglTRect ) : Boolean;

const
  FILE_ERROR = {$IFNDEF WINDOWS} 0 {$ELSE} LongWord( -1 ) {$ENDIF};

  // Open Mode
  FOM_CREATE = $01; // Create
  FOM_OPENR  = $02; // Read
  FOM_OPENRW = $03; // Read&Write

  // Seek Mode
  FSM_SET    = $01;
  FSM_CUR    = $02;
  FSM_END    = $03;

var
  file_Open          : function( var FileHandle : zglTFile; const FileName : String; Mode : Byte ) : Boolean;
  file_MakeDir       : function( const Directory : String ) : Boolean;
  file_Remove        : function( const Name : String ) : Boolean;
  file_Exists        : function( const Name : String ) : Boolean;
  file_Seek          : function( FileHandle : zglTFile; Offset, Mode : Integer ) : LongWord;
  file_GetPos        : function( FileHandle : zglTFile ) : LongWord;
  file_Read          : function( FileHandle : zglTFile; var Buffer; Bytes : LongWord ) : LongWord;
  file_Write         : function( FileHandle : zglTFile; const Buffer; Bytes : LongWord ) : LongWord;
  file_GetSize       : function( FileHandle : zglTFile ) : LongWord;
  file_Flush         : procedure( const FileHandle : zglTFile );
  file_Close         : procedure( var FileHandle : zglTFile );
  file_Find          : procedure( const Directory : String; var List : zglTFileList; FindDir : Boolean );
  _file_GetName      : function( const FileName : String ) : PChar;
  _file_GetExtension : function( const FileName : String ) : PChar;
  _file_GetDirectory : function( const FileName : String ) : PChar;
  file_SetPath       : procedure( const Path : String );

  function file_GetName( const FileName : String ) : String;
  function file_GetExtension( const FileName : String ) : String;
  function file_GetDirectory( const FileName : String ) : String;

var
  mem_LoadFromFile : procedure( var Memory : zglTMemory; const FileName : String );
  mem_SaveToFile   : procedure( var Memory : zglTMemory; const FileName : String );
  mem_Seek         : function( var Memory : zglTMemory; Offset, Mode : Integer ) : LongWord;
  mem_Read         : function( var Memory : zglTMemory; var Buffer; Bytes : LongWord ) : LongWord;
  mem_Write        : function( var Memory : zglTMemory; const Buffer; Bytes : LongWord ) : LongWord;
  mem_SetSize      : procedure( var Memory : zglTMemory; Size : LongWord );
  mem_Free         : procedure( var Memory : zglTMemory );

// Utils
function u_IntToStr( Value : Integer ) : String;
function u_StrToInt( const Value : String ) : Integer;
function u_FloatToStr( Value : Single; Digits : Integer = 2 ) : String;
function u_StrToFloat( const Value : String ) : Single;
function u_BoolToStr( Value : Boolean ) : String;
function u_StrToBool( const Value : String ) : Boolean;
// Только для английских символов попадающих в диапазон 0..127
function u_StrUp( const str : String ) : String;
function u_StrDown( const str : String ) : String;
function u_CopyAnsiStr( const Str : AnsiString ) : AnsiString;
function u_CopyStr( const Str : String ) : String;
var
  u_SortList : procedure( var List : zglTStringList; iLo, iHi : Integer );

{$IFDEF LINUX_OR_DARWIN}
function dlopen ( Name : PChar; Flags : longint) : Pointer; cdecl; external 'dl';
function dlclose( Lib : Pointer) : Longint; cdecl; external 'dl';
function dlsym  ( Lib : Pointer; Name : Pchar) : Pointer; cdecl; external 'dl';
{$ENDIF}

{$IFDEF WINDOWS}
function dlopen ( lpLibFileName : PAnsiChar) : HMODULE; stdcall; external 'kernel32.dll' name 'LoadLibraryA';
function dlclose( hLibModule : HMODULE ) : Boolean; stdcall; external 'kernel32.dll' name 'FreeLibrary';
function dlsym  ( hModule : HMODULE; lpProcName : PAnsiChar) : Pointer; stdcall; external 'kernel32.dll' name 'GetProcAddress';

function MessageBoxA( hWnd : LongWord; lpText, lpCaption : PAnsiChar; uType : LongWord) : Integer; stdcall; external 'user32.dll';
{$ENDIF}

implementation

var
  zglLib : {$IFDEF LINUX_OR_DARWIN} Pointer {$ENDIF} {$IFDEF WINDOWS} HMODULE {$ENDIF};
  {$IFDEF DARWIN}
  mainBundle   : CFBundleRef;
  tmpCFURLRef  : CFURLRef;
  tmpCFString  : CFStringRef;
  tmpPath      : array[ 0..8191 ] of Char;
  outItemHit   : SInt16;
  {$ENDIF}

function ini_ReadKeyStr( const Section, Key : AnsiString ) : AnsiString;
  var
    tmp : PAnsiChar;
begin
  tmp := _ini_ReadKeyStr( Section, Key );
  Result := u_CopyAnsiStr( tmp );
  zgl_FreeMem( Pointer( tmp ) );
end;

function key_GetText : String;
  var
    tmp : PChar;
begin
  tmp := _key_GetText();
  Result := u_CopyStr( tmp );
  zgl_FreeMem( Pointer( tmp ) );
end;

function file_GetName( const FileName : String ) : String;
  var
    tmp : PChar;
begin
  tmp := _file_GetName( FileName );
  Result := u_CopyStr( tmp );
  zgl_FreeMem( Pointer( tmp ) );
end;

function file_GetExtension( const FileName : String ) : String;
  var
    tmp : PChar;
begin
  tmp := _file_GetExtension( FileName );
  Result := u_CopyStr( tmp );
  zgl_FreeMem( Pointer( tmp ) );
end;

function file_GetDirectory( const FileName : String ) : String;
  var
    tmp : PChar;
begin
  tmp := _file_GetDirectory( FileName );
  Result := u_CopyStr( tmp );
  zgl_FreeMem( Pointer( tmp ) );
end;

function u_IntToStr( Value : Integer ) : String;
begin
  Str( Value, Result );
end;

function u_StrToInt( const Value : String ) : Integer;
  var
    E : Integer;
begin
  Val( String( Value ), Result, E );
end;

function u_FloatToStr( Value : Single; Digits : Integer = 2 ) : String;
begin
  Str( Value:0:Digits, Result );
end;

function u_StrToFloat( const Value : String ) : Single;
  var
    E : Integer;
begin
  Val( String( Value ), Result, E );
  if E <> 0 Then
    Result := 0;
end;

function u_BoolToStr( Value : Boolean ) : String;
begin
  if Value Then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

function u_StrToBool( const Value : String ) : Boolean;
begin
  if Value = '1' Then
    Result := TRUE
  else
    if u_StrUp( Value ) = 'TRUE' Then
      Result := TRUE
    else
      Result := FALSE;
end;

function u_CopyAnsiStr( const Str : AnsiString ) : AnsiString;
  var
    len : Integer;
begin
  len := length( Str );
  SetLength( Result, len );
  System.Move( Str[ 1 ], Result[ 1 ], len );
end;

function u_CopyStr( const Str : String ) : String;
  var
    len : Integer;
begin
  len := length( Str );
  SetLength( Result, len );
  System.Move( Str[ 1 ], Result[ 1 ], len * SizeOf( Char ) );
end;

function u_StrUp( const str : String ) : String;
  var
    i, l : Integer;
begin
  l := length( Str );
  SetLength( Result, l );
  for i := 1 to l do
    if ( Byte( Str[ i ] ) >= 97 ) and ( Byte( Str[ i ] ) <= 122 ) Then
      Result[ i ] := Char( Byte( Str[ i ] ) - 32 )
    else
      Result[ i ] := Str[ i ];
end;

function u_StrDown( const str : String ) : String;
  var
    i, l : Integer;
begin
  l := length( Str );
  SetLength( Result, l );
  for i := 1 to l do
    if ( Byte( Str[ i ] ) >= 65 ) and ( Byte( Str[ i ] ) <= 90 ) Then
      Result[ i ] := Char( Byte( Str[ i ] ) + 32 )
    else
      Result[ i ] := Str[ i ];
end;


function zglLoad( LibraryName : AnsiString; Error : Boolean = TRUE ) : Boolean;
begin
  Result := FALSE;
  {$IFDEF LINUX}
  zglLib := dlopen( PAnsiChar( './' + LibraryName ), $001 );
  if not Assigned( zglLib ) Then
  {$ENDIF}
  {$IFDEF DARWIN}
  mainBundle  := CFBundleGetMainBundle;
  tmpCFURLRef := CFBundleCopyBundleURL( mainBundle );
  tmpCFString := CFURLCopyFileSystemPath( tmpCFURLRef, kCFURLPOSIXPathStyle );
  CFStringGetFileSystemRepresentation( tmpCFString, @tmpPath[ 0 ], 8192 );
  mainPath    := tmpPath + '/Contents/';
  LibraryName := mainPath + 'Frameworks/' + LibraryName;
  {$ENDIF}
  zglLib := dlopen( PAnsiChar( LibraryName ) {$IFDEF LINUX_OR_DARWIN}, $001 {$ENDIF} );

  if zglLib <> {$IFDEF LINUX_OR_DARWIN} nil {$ENDIF} {$IFDEF WINDOWS} 0 {$ENDIF} Then
    begin
      Result := TRUE;
      zgl_Init := dlsym( zglLib, 'zgl_Init' );
      zgl_InitToHandle := dlsym( zglLib, 'zgl_InitToHandle' );
      zgl_Exit := dlsym( zglLib, 'zgl_Exit' );
      zgl_Reg := dlsym( zglLib, 'zgl_Reg' );
      zgl_Get := dlsym( zglLib, 'zgl_Get' );
      zgl_GetMem := dlsym( zglLib, 'zgl_GetMem' );
      zgl_FreeMem := dlsym( zglLib, 'zgl_FreeMem' );
      zgl_FreeStrList := dlsym( zglLib, 'zgl_FreeStrList' );
      zgl_Enable := dlsym( zglLib, 'zgl_Enable' );
      zgl_Disable := dlsym( zglLib, 'zgl_Disable' );

      log_Add := dlsym( zglLib, 'log_Add' );

      wnd_SetCaption := dlsym( zglLib, 'wnd_SetCaption' );
      wnd_SetSize := dlsym( zglLib, 'wnd_SetSize' );
      wnd_SetPos := dlsym( zglLib, 'wnd_SetPos' );
      wnd_ShowCursor := dlsym( zglLib, 'wnd_ShowCursor' );

      scr_Clear := dlsym( zglLib, 'scr_Clear' );
      scr_Flush := dlsym( zglLib, 'scr_Flush' );
      scr_SetVSync := dlsym( zglLib, 'scr_SetVSync' );
      scr_SetFSAA := dlsym( zglLib, 'scr_SetFSAA' );
      scr_SetOptions := dlsym( zglLib, 'scr_SetOptions' );
      scr_CorrectResolution := dlsym( zglLib, 'scr_CorrectResolution' );
      scr_ReadPixels := dlsym( zglLib, 'scr_ReadPixels' );

      ini_LoadFromFile := dlsym( zglLib, 'ini_LoadFromFile' );
      ini_SaveToFile := dlsym( zglLib, 'ini_SaveToFile' );
      ini_Add := dlsym( zglLib, 'ini_Add' );
      ini_Del := dlsym( zglLib, 'ini_Del' );
      ini_Clear := dlsym( zglLib, 'ini_Clear' );
      ini_IsSection := dlsym( zglLib, 'ini_IsSection' );
      ini_IsKey := dlsym( zglLib, 'ini_IsKey' );
      _ini_ReadKeyStr := dlsym( zglLib, 'ini_ReadKeyStr' );
      ini_ReadKeyInt := dlsym( zglLib, 'ini_ReadKeyInt' );
      ini_ReadKeyFloat := dlsym( zglLib, 'ini_ReadKeyFloat' );
      ini_ReadKeyBool := dlsym( zglLib, 'ini_ReadKeyBool' );
      ini_WriteKeyStr := dlsym( zglLib, 'ini_WriteKeyStr' );
      ini_WriteKeyInt := dlsym( zglLib, 'ini_WriteKeyInt' );
      ini_WriteKeyFloat := dlsym( zglLib, 'ini_WriteKeyFloat' );
      ini_WriteKeyBool := dlsym( zglLib, 'ini_WriteKeyBool' );

      timer_Add := dlsym( zglLib, 'timer_Add' );
      timer_Del := dlsym( zglLib, 'timer_Del' );
      timer_GetTicks := dlsym( zglLib, 'timer_GetTicks' );
      timer_Reset := dlsym( zglLib, 'timer_Reset' );

      mouse_X := dlsym( zglLib, 'mouse_X' );
      mouse_Y := dlsym( zglLib, 'mouse_Y' );
      mouse_DX := dlsym( zglLib, 'mouse_DX' );
      mouse_DY := dlsym( zglLib, 'mouse_DY' );
      mouse_Down := dlsym( zglLib, 'mouse_Down' );
      mouse_Up := dlsym( zglLib, 'mouse_Up' );
      mouse_Click := dlsym( zglLib, 'mouse_Click' );
      mouse_DblClick := dlsym( zglLib, 'mouse_DblClick' );
      mouse_Wheel := dlsym( zglLib, 'mouse_Wheel' );
      mouse_ClearState := dlsym( zglLib, 'mouse_ClearState' );
      mouse_Lock := dlsym( zglLib, 'mouse_Lock' );

      key_Down := dlsym( zglLib, 'key_Down' );
      key_Up := dlsym( zglLib, 'key_Up' );
      key_Press := dlsym( zglLib, 'key_Press' );
      key_Last := dlsym( zglLib, 'key_Last' );
      key_BeginReadText := dlsym( zglLib, 'key_BeginReadText' );
      _key_GetText := dlsym( zglLib, 'key_GetText' );
      key_EndReadText := dlsym( zglLib, 'key_EndReadText' );
      key_ClearState := dlsym( zglLib, 'key_ClearState' );

      joy_Init := dlsym( zglLib, 'joy_Init' );
      joy_GetInfo := dlsym( zglLib, 'joy_GetInfo' );
      joy_AxisPos := dlsym( zglLib, 'joy_AxisPos' );
      joy_Down := dlsym( zglLib, 'joy_Down' );
      joy_Up := dlsym( zglLib, 'joy_Up' );
      joy_Press := dlsym( zglLib, 'joy_Press' );
      joy_ClearState := dlsym( zglLib, 'joy_ClearState' );

      tex_Add := dlsym( zglLib, 'tex_Add' );
      tex_Del := dlsym( zglLib, 'tex_Del' );
      tex_Create := dlsym( zglLib, 'tex_Create' );
      tex_CreateZero := dlsym( zglLib, 'tex_CreateZero' );
      tex_LoadFromFile := dlsym( zglLib, 'tex_LoadFromFile' );
      tex_LoadFromMemory := dlsym( zglLib, 'tex_LoadFromMemory' );
      tex_SetFrameSize := dlsym( zglLib, 'tex_SetFrameSize' );
      tex_SetMask := dlsym( zglLib, 'tex_SetMask' );
      tex_SetData := dlsym( zglLib, 'tex_SetData' );
      tex_GetData := dlsym( zglLib, 'tex_GetData' );
      tex_Filter := dlsym( zglLib, 'tex_Filter' );
      tex_SetAnisotropy := dlsym( zglLib, 'tex_SetAnisotropy' );

      atlas_Add := dlsym( zglLib, 'atlas_Add' );
      atlas_Del := dlsym( zglLib, 'atlas_Del' );
      atlas_GetFrameCoord := dlsym( zglLib, 'atlas_GetFrameCoord' );
      atlas_InsertFromTexture := dlsym( zglLib, 'atlas_InsertFromTexture' );
      atlas_InsertFromFile := dlsym( zglLib, 'atlas_InsertFromFile' );
      atlas_InsertFromMemory := dlsym( zglLib, 'atlas_InsertFromMemory' );

      Set2DMode := dlsym( zglLib, 'Set2DMode' );
      Set3DMode := dlsym( zglLib, 'Set3DMode' );

      zbuffer_SetDepth := dlsym( zglLib, 'zbuffer_SetDepth' );
      zbuffer_Clear := dlsym( zglLib, 'zbuffer_Clear' );

      scissor_Begin := dlsym( zglLib, 'scissor_Begin' );
      scissor_End := dlsym( zglLib, 'scissor_End' );

      rtarget_Add := dlsym( zglLib, 'rtarget_Add' );
      rtarget_Del := dlsym( zglLib, 'rtarget_Del' );
      rtarget_Set := dlsym( zglLib, 'rtarget_Set' );
      rtarget_DrawIn := dlsym( zglLib, 'rtarget_Set' );

      fx_SetBlendMode := dlsym( zglLib, 'fx_SetBlendMode' );
      fx_SetColorMode := dlsym( zglLib, 'fx_SetColorMode' );
      fx_SetColorMask := dlsym( zglLib, 'fx_SetColorMask' );
      fx2d_SetColor := dlsym( zglLib, 'fx2d_SetColor' );
      fx2d_SetVCA := dlsym( zglLib, 'fx2d_SetVCA' );
      fx2d_SetVertexes := dlsym( zglLib, 'fx2d_SetVertexes' );
      fx2d_SetScale := dlsym( zglLib, 'fx2d_SetScale' );

      cam2d_Set := dlsym( zglLib, 'cam2d_Set' );
      cam2d_Get := dlsym( zglLib, 'cam2d_Get' );

      batch2d_Begin := dlsym( zglLib, 'batch2d_Begin' );
      batch2d_End := dlsym( zglLib, 'batch2d_End' );
      batch2d_Flush := dlsym( zglLib, 'batch2d_Flush' );

      pr2d_Pixel := dlsym( zglLib, 'pr2d_Pixel' );
      pr2d_Line := dlsym( zglLib, 'pr2d_Line' );
      pr2d_Rect := dlsym( zglLib, 'pr2d_Rect' );
      pr2d_Circle := dlsym( zglLib, 'pr2d_Circle' );
      pr2d_Ellipse := dlsym( zglLib, 'pr2d_Ellipse' );
      pr2d_TriList := dlsym( zglLib, 'pr2d_TriList' );

      sengine2d_AddSprite := dlsym( zglLib, 'sengine2d_AddSprite' );
      sengine2d_DelSprite := dlsym( zglLib, 'sengine2d_DelSprite' );
      sengine2d_ClearAll := dlsym( zglLib, 'sengine2d_ClearAll' );
      sengine2d_Set := dlsym( zglLib, 'sengine2d_Set' );
      sengine2d_Draw := dlsym( zglLib, 'sengine2d_Draw' );
      sengine2d_Proc := dlsym( zglLib, 'sengine2d_Proc' );

      texture2d_Draw := dlsym( zglLib, 'texture2d_Draw' );
      ssprite2d_Draw := dlsym( zglLib, 'ssprite2d_Draw' );
      asprite2d_Draw := dlsym( zglLib, 'asprite2d_Draw' );
      csprite2d_Draw := dlsym( zglLib, 'csprite2d_Draw' );
      tiles2d_Draw := dlsym( zglLib, 'tiles2d_Draw' );
      sgrid2d_Draw := dlsym( zglLib, 'sgrid2d_Draw' );
      agrid2d_Draw := dlsym( zglLib, 'agrid2d_Draw' );
      cgrid2d_Draw := dlsym( zglLib, 'cgrid2d_Draw' );

      pengine2d_Set := dlsym( zglLib, 'pengine2d_Set' );
      pengine2d_Get := dlsym( zglLib, 'pengine2d_Get' );
      pengine2d_Draw := dlsym( zglLib, 'pengine2d_Draw' );
      pengine2d_Proc := dlsym( zglLib, 'pengine2d_Proc' );
      pengine2d_AddEmitter := dlsym( zglLib, 'pengine2d_AddEmitter' );
      pengine2d_DelEmitter := dlsym( zglLib, 'pengine2d_DelEmitter' );
      pengine2d_ClearAll := dlsym( zglLib, 'pengine2d_ClearAll' );
      emitter2d_Add := dlsym( zglLib, 'emitter2d_Add' );
      emitter2d_Del := dlsym( zglLib, 'emitter2d_Del' );
      emitter2d_LoadFromFile := dlsym( zglLib, 'emitter2d_LoadFromFile' );
      emitter2d_LoadFromMemory := dlsym( zglLib, 'emitter2d_LoadFromMemory' );
      emitter2d_Init := dlsym( zglLib, 'emitter2d_Init' );
      emitter2d_Free := dlsym( zglLib, 'emitter2d_Free' );
      emitter2d_Draw := dlsym( zglLib, 'emitter2d_Draw' );
      emitter2d_Proc := dlsym( zglLib, 'emitter2d_Proc' );

      font_Add := dlsym( zglLib, 'font_Add' );
      font_Del := dlsym( zglLib, 'font_Del' );
      font_LoadFromFile := dlsym( zglLib, 'font_LoadFromFile' );
      font_LoadFromMemory := dlsym( zglLib, 'font_LoadFromMemory' );
      text_Draw := dlsym( zglLib, 'text_Draw' );
      text_DrawEx := dlsym( zglLib, 'text_DrawEx' );
      text_DrawInRect := dlsym( zglLib, 'text_DrawInRect' );
      text_DrawInRectEx := dlsym( zglLib, 'text_DrawInRectEx' );
      text_GetWidth := dlsym( zglLib, 'text_GetWidth' );
      text_GetHeight := dlsym( zglLib, 'text_GetHeight' );
      textFx_SetLength := dlsym( zglLib, 'textFx_SetLength' );

      snd_Init := dlsym( zglLib, 'snd_Init' );
      snd_Free := dlsym( zglLib, 'snd_Free' );
      snd_Add  := dlsym( zglLib, 'snd_Add' );
      snd_Del  := dlsym( zglLib, 'snd_Del' );
      snd_LoadFromFile := dlsym( zglLib, 'snd_LoadFromFile' );
      snd_LoadFromMemory := dlsym( zglLib, 'snd_LoadFromMemory' );
      snd_Play := dlsym( zglLib, 'snd_Play' );
      snd_Stop := dlsym( zglLib, 'snd_Stop' );
      snd_SetPos := dlsym( zglLib, 'snd_SetPos' );
      snd_SetVolume := dlsym( zglLib, 'snd_SetVolume' );
      snd_SetSpeed := dlsym( zglLib, 'snd_SetSpeed' );
      snd_Get := dlsym( zglLib, 'snd_Get' );
      snd_PlayFile := dlsym( zglLib, 'snd_PlayFile' );
      snd_PauseFile := dlsym( zglLib, 'snd_PauseFile' );
      snd_StopFile := dlsym( zglLib, 'snd_StopFile' );
      snd_ResumeFile := dlsym( zglLib, 'snd_ResumeFile' );

      m_Cos := dlsym( zglLib, 'm_Cos' );
      m_Sin := dlsym( zglLib, 'm_Sin' );
      m_Distance := dlsym( zglLib, 'm_Distance' );
      m_FDistance := dlsym( zglLib, 'm_FDistance' );
      m_Angle := dlsym( zglLib, 'm_Angle' );
      m_Orientation := dlsym( zglLib, 'm_Orientation' );

      tess_Triangulate := dlsym( zglLib, 'tess_Triangulate' );
      tess_AddHole := dlsym( zglLib, 'tess_AddHole' );
      tess_GetData := dlsym( zglLib, 'tess_GetData' );

      col2d_PointInRect := dlsym( zglLib, 'col2d_PointInRect' );
      col2d_PointInTriangle := dlsym( zglLib, 'col2d_PointInriangle' );
      col2d_PointInCircle := dlsym( zglLib, 'col2d_PointInCircle' );
      col2d_Line := dlsym( zglLib, 'col2d_Line' );
      col2d_LineVsRect := dlsym( zglLib, 'col2d_LineVsRect' );
      col2d_LineVsCircle := dlsym( zglLib, 'col2d_LineVsCircle' );
      col2d_LineVsCircleXY := dlsym( zglLib, 'col2d_LineVsCircleXY' );
      col2d_Rect := dlsym( zglLib, 'col2d_Rect' );
      col2d_ClipRect := dlsym( zglLib, 'col2d_ClipRect' );
      col2d_RectInRect := dlsym( zglLib, 'col2d_RectInRect' );
      col2d_RectInCircle := dlsym( zglLib, 'col2d_RectInCircle' );
      col2d_RectVsCircle := dlsym( zglLib, 'col2d_RectVsCircle' );
      col2d_Circle := dlsym( zglLib, 'col2d_Circle' );
      col2d_CircleInCircle := dlsym( zglLib, 'col2d_CircleInCircle' );
      col2d_CircleInRect := dlsym( zglLib, 'col2d_CircleInRect' );

      file_Open := dlsym( zglLib, 'file_Open' );
      file_MakeDir := dlsym( zglLib, 'file_MakeDir' );
      file_Remove := dlsym( zglLib, 'file_Remove' );
      file_Exists := dlsym( zglLib, 'file_Exists' );
      file_Seek := dlsym( zglLib, 'file_Seek' );
      file_GetPos := dlsym( zglLib, 'file_GetPos' );
      file_Read := dlsym( zglLib, 'file_Read' );
      file_Write := dlsym( zglLib, 'file_Write' );
      file_GetSize := dlsym( zglLib, 'file_GetSize' );
      file_Flush := dlsym( zglLib, 'file_Flush' );
      file_Close := dlsym( zglLib, 'file_Close' );
      file_Find := dlsym( zglLib, 'file_Find' );
      _file_GetName := dlsym( zglLib, 'file_GetName' );
      _file_GetExtension := dlsym( zglLib, 'file_GetExtension' );
      _file_GetDirectory := dlsym( zglLib, 'file_GetDirectory' );
      file_SetPath := dlsym( zglLib, 'file_SetPath' );

      mem_LoadFromFile := dlsym( zglLib, 'mem_LoadFromFile' );
      mem_SaveToFile := dlsym( zglLib, 'mem_SaveToFile' );
      mem_Seek := dlsym( zglLib, 'mem_Seek' );
      mem_Read := dlsym( zglLib, 'mem_Read' );
      mem_Write := dlsym( zglLib, 'mem_Write' );
      mem_SetSize := dlsym( zglLib, 'mem_SetSize' );
      mem_Free := dlsym( zglLib, 'mem_Free' );

      u_SortList := dlsym( zglLib, 'u_SortList' );
    end else
      if Error Then
        begin
          {$IFDEF LINUX}
          WriteLn( 'Error while loading ZenGL' );
          {$ENDIF}
          {$IFDEF WINDOWS}
          MessageBoxA( 0, 'Error while loading ZenGL', 'Error', $00000010 );
          {$ENDIF}
          {$IFDEF DARWIN}
          StandardAlert( kAlertNoteAlert, 'Error', 'Error while loading ZenGL', nil, outItemHit );
          {$ENDIF}
        end;
end;

procedure zglFree;
begin
  dlClose( zglLib );
end;

end.
