{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://zengl.org
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation, either version 3 of
 *  the License, or (at your option) any later version.
 *
 *  ZenGL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with ZenGL. If not, see http://www.gnu.org/licenses/
}
unit zgl_textures_tga;

{$I zgl_config.cfg}

interface

uses
  zgl_types,
  zgl_file,
  zgl_memory;

const
  TGA_EXTENSION : UTF8String = 'TGA';

procedure tga_LoadFromFile( const FileName : UTF8String; out Data : PByteArray; out W, H, Format : Word );
procedure tga_LoadFromMemory( const Memory : zglTMemory; out Data : PByteArray; out W, H, Format : Word );

implementation
uses
  zgl_main,
  zgl_log,
  zgl_textures;

type
  zglPTGAHeader = ^zglTTGAHeader;
  zglTTGAHeader = packed record
    IDLength  : Byte;
    CPalType  : Byte;
    ImageType : Byte;
    CPalSpec  : packed record
      FirstEntry : Word;
      Length     : Word;
      EntrySize  : Byte;
                end;
    ImgSpec   : packed record
      X      : Word;
      Y      : Word;
      Width  : Word;
      Height : Word;
      Depth  : Byte;
      Desc   : Byte;
                end;
end;

procedure tga_FlipVertically( Data : PByteArray; w, h : Integer );
  var
    i        : Integer;
    scanLine : PByteArray;
begin
  GetMem( scanLine, w * 4 );

  for i := 0 to h shr 1 - 1 do
    begin
      Move( Data[ i * w * 4 ], scanLine[ 0 ], w * 4 );
      Move( Data[ ( h - i - 1 ) * w * 4 ], Data[ i * w * 4 ], w * 4 );
      Move( scanLine[ 0 ], Data[ ( h - i - 1 ) * w * 4 ], w * 4 );
    end;

  FreeMem( scanLine );
end;

procedure tga_FlipHorizontally( Data : PByteArray; w, h : Integer );
  var
    i, x     : Integer;
    scanLine : PLongWordArray;
begin
  GetMem( scanLine, w * 4 );

  for i := 0 to h - 1 do
    begin
      Move( Data[ i * w * 4 ], scanLine[ 0 ], w * 4 );
      for x := 0 to w - 1 do
        PLongWordArray( Data )[ i * w + x ] := scanLine[ w - 1 - x ];
    end;

  FreeMem( scanLine );
end;

procedure tga_RLEDecode( var tgaMem : zglTMemory; var Header : zglTTGAHeader; out Data : PByteArray );
  var
    i, j      : Integer;
    pixelSize : Integer;
    size      : LongWord;
    packetHdr : Byte;
    packet    : array[ 0..3 ] of Byte;
    packetLen : Byte;
begin
  pixelSize := Header.ImgSpec.Depth shr 3;
  size      := Header.ImgSpec.Width * Header.ImgSpec.Height * pixelSize;
  GetMem( Data, size );

  for i := 0 to size - 1 do
    begin
      mem_Read( tgaMem, packetHdr, 1 );
      packetLen := ( packetHdr and $7F ) + 1;
      if ( packetHdr and $80 ) <> 0 Then
        begin
          mem_Read( tgaMem, packet[ 0 ], pixelSize );
          for j := 0 to ( packetLen * pixelSize ) - 1 do
            Data[ i ] := packet[ j mod pixelSize ];
        end else
          for j := 0 to ( packetLen * pixelSize ) - 1 do
            begin
              mem_Read( tgaMem, packet[ j mod pixelSize ], 1 );
              Data[ i ] := packet[ j mod pixelSize ];
            end;
    end;

  Header.ImageType := Header.ImageType - 8;
end;

function tga_PaletteDecode( var Header : zglTTGAHeader; var Data : PByteArray; Palette : PByteArray ) : Boolean;
  var
    i, base : Integer;
    size    : Integer;
    entry   : Byte;
begin
  if ( Header.CPalType = 1 ) and ( Header.CPalSpec.EntrySize <> 24 ) Then
    begin
      log_Add( 'Unsupported color palette type in TGA-file!' );
      Result := FALSE;
      exit;
    end;

  size := Header.ImgSpec.Width * Header.ImgSpec.Height;
  base := Header.CPalSpec.FirstEntry;
  ReallocMem( Data, size * 3 );

  if Header.CPalType = 1 Then
    begin
      for i := size - 1 downto 0 do
        begin
          entry             := Data[ i ];
          Data[ i * 3 ]     := Palette[ entry * 3 - base ];
          Data[ i * 3 + 1 ] := Palette[ entry * 3 + 1 - base ];
          Data[ i * 3 + 2 ] := Palette[ entry * 3 + 2 - base ];
        end;
    end else
      for i := size - 1 downto 0 do
        begin
          entry             := Data[ i ];
          Data[ i * 3 ]     := entry;
          Data[ i * 3 + 1 ] := entry;
          Data[ i * 3 + 2 ] := entry;
        end;

  Header.ImageType     := 2;
  Header.ImgSpec.Depth := 24;
  Header.CPalType      := 0;
  FillChar( Header.CPalSpec, SizeOf( Header.CPalSpec ), 0 );

  Result := TRUE;
end;

procedure tga_LoadFromFile( const FileName : UTF8String; out Data : PByteArray; out W, H, Format : Word );
  var
    tgaMem : zglTMemory;
begin
  mem_LoadFromFile( tgaMem, FileName );
  tga_LoadFromMemory( tgaMem, Data, W, H, Format );
  mem_Free( tgaMem );
end;

procedure tga_LoadFromMemory( const Memory : zglTMemory; out Data : PByteArray; out W, H, Format : Word );
  label _exit;
  var
    i, size    : Integer;
    tgaMem     : zglTMemory;
    tgaHeader  : zglTTGAHeader;
    tgaData    : PByteArray;
    tgaPalette : PByteArray;
begin
  tgaMem := Memory;
  mem_Read( tgaMem, tgaHeader, SizeOf( zglTTGAHeader ) );

  if tgaHeader.CPalType = 1 then
    with tgaHeader.CPalSpec do
      begin
        GetMem( tgaPalette, Length * EntrySize shr 3 );
        mem_Read( tgaMem, tgaPalette[ 0 ], Length * EntrySize shr 3 );
      end;

  if tgaHeader.ImageType >= 9 Then
    tga_RLEDecode( tgaMem, tgaHeader, tgaData )
  else
    begin
      size := tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height * ( tgaHeader.ImgSpec.Depth shr 3 );
      GetMem( tgaData, size );
      mem_Read( tgaMem, tgaData[ 0 ], size );
    end;

  if tgaHeader.ImageType <> 2 Then
    if not tga_PaletteDecode( tgaHeader, tgaData, tgaPalette ) Then
      goto _exit;

  if tgaHeader.ImgSpec.Depth shr 3 = 3 Then
    begin
      GetMem( Data, tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height * 4 );
      for i := 0 to tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height - 1 do
        begin
          Data[ i * 4 + 2 ] := tgaData[ 0 ];
          Data[ i * 4 + 1 ] := tgaData[ 1 ];
          Data[ i * 4 ]     := tgaData[ 2 ];
          Data[ i * 4 + 3 ] := 255;
          INC( PByte( tgaData ), 3 );
        end;
      DEC( PByte( tgaData ), tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height * 3 );
    end else
      if tgaHeader.ImgSpec.Depth shr 3 = 4 Then
        begin
          GetMem( Data, tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height * 4 );
          for i := 0 to tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height - 1 do
            begin
              Data[ i * 4 + 2 ] := tgaData[ 0 ];
              Data[ i * 4 + 1 ] := tgaData[ 1 ];
              Data[ i * 4 ]     := tgaData[ 2 ];
              Data[ i * 4 + 3 ] := tgaData[ 3 ];
              INC( PByte( tgaData ), 4 );
            end;
          DEC( PByte( tgaData ), tgaHeader.ImgSpec.Width * tgaHeader.ImgSpec.Height * 4 );
        end;

  W      := tgaHeader.ImgSpec.Width;
  H      := tgaHeader.ImgSpec.Height;
  Format := TEX_FORMAT_RGBA;

  if ( tgaHeader.ImgSpec.Desc and ( 1 shl 4 ) ) <> 0 Then
    tga_FlipHorizontally( Data, W, H );
  if ( tgaHeader.ImgSpec.Desc and ( 1 shl 5 ) ) <> 0 Then
    tga_FlipVertically( Data, W, H );

_exit:
  begin
    FreeMem( tgaData );
    FreeMem( tgaPalette );
  end;
end;

{$IFDEF USE_TGA}
initialization
  zgl_Reg( TEX_FORMAT_EXTENSION,   @TGA_EXTENSION[ 1 ] );
  zgl_Reg( TEX_FORMAT_FILE_LOADER, @tga_LoadFromFile );
  zgl_Reg( TEX_FORMAT_MEM_LOADER,  @tga_LoadFromMemory );
{$ENDIF}

end.
