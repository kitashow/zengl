{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.inf.ua
 *
 * This file is part of ZenGL
 *
 * ZenGL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenGL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_text;

{$I zgl_config.cfg}

interface
uses
  zgl_types,
  zgl_font,
  zgl_math_2d;

const
  TEXT_HALIGN_LEFT    = $000001;
  TEXT_HALIGN_CENTER  = $000002;
  TEXT_HALIGN_RIGHT   = $000004;
  TEXT_HALIGN_JUSTIFY = $000008;
  TEXT_VALIGN_TOP     = $000010;
  TEXT_VALIGN_CENTER  = $000020;
  TEXT_VALIGN_BOTTOM  = $000040;
  TEXT_FX_VCA         = $000080;
  TEXT_FX_LENGTH      = $000100;

type
  zglTTextWord = record
    X, Y, W : Integer;
    str     : String;
end;

procedure text_Draw( const Font : zglPFont; X, Y : Single; const Text : String; const Flags : LongWord = 0 );
procedure text_DrawEx( const Font : zglPFont; X, Y, Scale, Step : Single; const Text : String; const Alpha : Byte = 255; const Color : LongWord = $FFFFFF; const Flags : LongWord = 0 );
procedure text_DrawInRect( const Font : zglPFont; const Rect : zglTRect; const Text : String; const Flags : LongWord = 0 );
procedure text_DrawInRectEx( const Font : zglPFont; const Rect : zglTRect; const Scale, Step : Single; const Text : String; const Alpha : Byte = 0; const Color : LongWord = $FFFFFF; const Flags : LongWord = 0 );
function  text_GetWidth( const Font : zglPFont; const Text : String; const Step : Single = 0.0 ) : Single;
procedure textFx_SetLength( const Length : Integer; const LastCoord : zglPPoint2D = nil; const LastCharDesc : zglPCharDesc = nil );

implementation
uses
  zgl_main,
  zgl_opengl,
  zgl_opengl_all,
  zgl_opengl_simple,
  zgl_render_2d,
  zgl_fx,
  zgl_utils;

var
  textRGBA      : array[ 0..3 ] of Byte = ( 255, 255, 255, 255 );
  textScale     : Single = 1.0;
  textStep      : Single = 0.0;
  textLength    : Integer;
  textLCoord    : zglPPoint2D;
  textLCharDesc : zglPCharDesc;
  textWords     : array of zglTTextWord;

procedure text_Draw;
  var
    i, c, s : Integer;
    CharDesc : zglPCharDesc;
    Quad     : array[ 0..3 ] of zglTPoint2D;
    sx : Single;
    lastPage : Integer;
begin
  if ( Text = '' ) or ( not Assigned( Font ) ) Then exit;

  glColor4ubv( @textRGBA[ 0 ] );

  Y := Y - Font.MaxShiftY * textScale;
  if Flags and TEXT_HALIGN_CENTER > 0 Then
    X := X - Round( text_GetWidth( Font, Text, textStep ) / 2 ) * textScale
  else
    if Flags and TEXT_HALIGN_RIGHT > 0 Then
      X := X - Round( text_GetWidth( Font, Text, textStep ) ) * textScale;
  sx := X;

  if Flags and TEXT_VALIGN_CENTER > 0 Then
    Y := Y - ( Font.MaxHeight div 2 ) * textScale
  else
    if Flags and TEXT_VALIGN_BOTTOM > 0 Then
      Y := Y - Font.MaxHeight * textScale;

  FillChar( Quad[ 0 ], SizeOf( Quad[ 0 ] ) * 3, 0 );
  CharDesc := nil;
  lastPage := -1;
  c := font_GetCID( Text, 1, @i );
  s := 1;
  i := 1;
  if not b2d_Started Then
    begin
      if Assigned( Font.CharDesc[ c ] ) Then
        begin
          lastPage := Font.CharDesc[ c ].Page;
          batch2d_Check( GL_TRIANGLES, FX_BLEND, Font.Pages[ Font.CharDesc[ c ].Page ] );

          glEnable( GL_BLEND );
          glEnable( GL_TEXTURE_2D );
          glBindTexture( GL_TEXTURE_2D, Font.Pages[ Font.CharDesc[ c ].Page ].ID );
          glBegin( GL_TRIANGLES );
        end else
          begin
            glEnable( GL_BLEND );
            glEnable( GL_TEXTURE_2D );
          end;
    end;
  while i <= length( Text ) do
    begin
      if Text[ i ] = #10 Then
        begin
          X := sx;
          Y := Y + Font.MaxHeight;
        end;
      c := font_GetCID( Text, i, @i );

      if ( Flags and TEXT_FX_LENGTH > 0 ) and ( s > textLength ) Then
        begin
          if s > 1 Then
            begin
              if Assigned( textLCoord ) Then
                begin
                  textLCoord.X := Quad[ 0 ].X + Font.Padding[ 0 ] * textScale;
                  textLCoord.Y := Quad[ 0 ].Y + Font.Padding[ 1 ] * textScale;
                end;
              if Assigned( textLCharDesc ) Then
                textLCharDesc^ := CharDesc^;
            end;
          break;
        end;
      INC( s );

      CharDesc := Font.CharDesc[ c ];
      if not Assigned( CharDesc ) Then continue;

      if lastPage <> CharDesc.Page Then
        begin
          lastPage := Font.CharDesc[ c ].Page;

          if ( not b2d_Started ) Then
            begin
              glEnd;

              glBindTexture( GL_TEXTURE_2D, Font.Pages[ CharDesc.Page ].ID );
              glBegin( GL_TRIANGLES );
            end else
              if batch2d_Check( GL_TRIANGLES, FX_BLEND, Font.Pages[ CharDesc.Page ] ) Then
                begin
                  glEnable( GL_BLEND );

                  glEnable( GL_TEXTURE_2D );
                  glBindTexture( GL_TEXTURE_2D, Font.Pages[ CharDesc.Page ].ID );
                  glBegin( GL_TRIANGLES );
                end;
        end;

      Quad[ 0 ].X := X + ( CharDesc.ShiftX - Font.Padding[ 0 ] ) * textScale;
      Quad[ 0 ].Y := Y + ( CharDesc.ShiftY + ( Font.MaxHeight - CharDesc.Height ) - Font.Padding[ 1 ] ) * textScale;
      Quad[ 1 ].X := X + ( CharDesc.ShiftX + Font.CharDesc[ c ].Width + Font.Padding[ 2 ] ) * textScale;
      Quad[ 1 ].Y := Y + ( CharDesc.ShiftY + ( Font.MaxHeight - CharDesc.Height ) - Font.Padding[ 1 ] ) * textScale;
      Quad[ 2 ].X := X + ( CharDesc.ShiftX + CharDesc.Width ) * textScale + Font.Padding[ 2 ];
      Quad[ 2 ].Y := Y + ( CharDesc.ShiftY + CharDesc.Height + ( Font.MaxHeight - CharDesc.Height ) + Font.Padding[ 3 ] ) * textScale;
      Quad[ 3 ].X := X + ( CharDesc.ShiftX - Font.Padding[ 0 ] ) * textScale;
      Quad[ 3 ].Y := Y + ( CharDesc.ShiftY + CharDesc.Height + ( Font.MaxHeight - CharDesc.Height ) + Font.Padding[ 3 ] ) * textScale;

      if Flags and TEXT_FX_VCA > 0 Then
        begin
          glColor4ubv( @FX2D_VCA1[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 0 ] );
          gl_Vertex2fv( @Quad[ 0 ] );

          glColor4ubv( @FX2D_VCA2[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 1 ] );
          gl_Vertex2fv( @Quad[ 1 ] );

          glColor4ubv( @FX2D_VCA3[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 2 ] );
          gl_Vertex2fv( @Quad[ 2 ] );

          glColor4ubv( @FX2D_VCA3[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 2 ] );
          gl_Vertex2fv( @Quad[ 2 ] );

          glColor4ubv( @FX2D_VCA4[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 3 ] );
          gl_Vertex2fv( @Quad[ 3 ] );

          glColor4ubv( @FX2D_VCA1[ 0 ] );
          glTexCoord2fv( @CharDesc.TexCoords[ 0 ] );
          gl_Vertex2fv( @Quad[ 0 ] );
        end else
          begin
            glTexCoord2fv( @CharDesc.TexCoords[ 0 ] );
            gl_Vertex2fv( @Quad[ 0 ] );

            glTexCoord2fv( @CharDesc.TexCoords[ 1 ] );
            gl_Vertex2fv( @Quad[ 1 ] );

            glTexCoord2fv( @CharDesc.TexCoords[ 2 ] );
            gl_Vertex2fv( @Quad[ 2 ] );

            glTexCoord2fv( @CharDesc.TexCoords[ 2 ] );
            gl_Vertex2fv( @Quad[ 2 ] );

            glTexCoord2fv( @CharDesc.TexCoords[ 3 ] );
            gl_Vertex2fv( @Quad[ 3 ] );

            glTexCoord2fv( @CharDesc.TexCoords[ 0 ] );
            gl_Vertex2fv( @Quad[ 0 ] );
          end;

      X := X + ( Font.CharDesc[ c ].ShiftP + textStep ) * textScale;
    end;

  if not b2d_Started Then
    begin
      glEnd;

      glDisable( GL_TEXTURE_2D );
      glDisable( GL_BLEND );
    end;
end;

procedure text_DrawEx;
begin
  textRGBA[ 0 ] :=   Color             shr 16;
  textRGBA[ 1 ] := ( Color and $FF00 ) shr 8;
  textRGBA[ 2 ] :=   Color and $FF;
  textRGBA[ 3 ] := Alpha;
  textScale     := Scale;
  textStep      := Step;
  text_Draw( Font, X, Y, Text, Flags );
  textRGBA[ 0 ] := 255;
  textRGBA[ 1 ] := 255;
  textRGBA[ 2 ] := 255;
  textRGBA[ 3 ] := 255;
  textScale     := 1;
  textStep      := 0;
end;

procedure text_DrawInRect;
  var
    X, Y, sX   : Integer;
    b, i, imax : Integer;
    c, lc      : LongWord;
    curWord, j : Integer;
    newLine    : Integer;
    lineWidth  : Integer;
    SpaceShift : Integer;
    WordsCount : Integer;
    LinesCount : Integer;
    NewFlags   : Integer;
    startWord  : Boolean;
    newWord    : Boolean;
    lineEnd    : Boolean;
    lineFeed   : Boolean;
begin
  if ( Text = '' ) or ( not Assigned( Font ) ) Then exit;

  i          := 1;
  b          := 1;
  c          := 32;
  curWord    := 0;
  newLine    := 0;
  lineWidth  := 0;
  WordsCount := 0;
  LinesCount := 0;
  startWord  := FALSE;
  newWord    := FALSE;
  lineEnd    := FALSE;
  lineFeed   := FALSE;
  X          := Round( Rect.X ) + 1;
  Y          := Round( Rect.Y ) + 1 - Round( Font.MaxHeight * textScale );
  SpaceShift := Round( ( text_GetWidth( Font, ' ' ) + textStep ) * textScale );
  while i <= length( Text ) do
    begin
      lc   := c;
      j    := i;
      c    := font_GetCID( Text, i, @i );
      imax := Integer( i > length( Text ) );

      if ( not startWord ) and ( ( c = 32 ) or ( c <> 10 ) ) Then
        begin
          b := j - 1 * Integer( curWord > 0 ) + Integer( lc = 10 );
          while lineEnd and ( Text[ b ] = ' ' ) do INC( b );
          startWord := TRUE;
          lineEnd   := FALSE;
          continue;
        end;

      if ( c = 32 ) and ( startWord ) and ( lc <> 10 ) and ( lc <> 32 ) Then
        begin
          newWord   := TRUE;
          startWord := FALSE;
        end;

      if ( ( c = 10 ) and ( lc <> 10 ) and ( lc <> 32 ) ) or ( imax > 0 ) Then
        begin
          newWord   := TRUE;
          startWord := FALSE;
          lineFeed  := TRUE;
        end else
          if c = 10 Then
            begin
              startWord := FALSE;
              lineFeed  := TRUE;
            end;

      if newWord Then
        begin
          textWords[ curWord ].str := Copy( Text, b, i - b - ( 1 - imax ) );
          textWords[ curWord ].W   := Round( text_GetWidth( Font, textWords[ curWord ].str, textStep ) * textScale );
          lineWidth                := lineWidth + textWords[ curWord ].W;

          newWord := FALSE;
          INC( curWord );
          INC( WordsCount );
          if ( lineWidth > Rect.W - 2 ) and ( curWord - newLine > 1 ) Then
            begin
              lineEnd := TRUE;
              i := b;
              while Text[ i ] = ' ' do INC( i );
              DEC( curWord );
              DEC( WordsCount );
            end;
          if WordsCount > High( textWords ) Then
            SetLength( textWords, length( textWords ) + 1024 );
        end;

      if lineFeed or lineEnd Then
        begin
          Y := Y + Round( Font.MaxHeight * textScale );
          textWords[ newLine ].X := X;
          textWords[ newLine ].Y := Y;
          for j := newLine + 1 to curWord - 1 do
            begin
              textWords[ j ].X := textWords[ j - 1 ].X + textWords[ j - 1 ].W;
              textWords[ j ].Y := textWords[ newLine ].Y;
            end;

          if ( Flags and TEXT_HALIGN_JUSTIFY > 0 ) and ( curWord - newLine > 1 ) and ( c <> 10 ) and ( imax = 0 ) Then
            begin
              sX := Round( Rect.X + Rect.W - 1 ) - ( textWords[ curWord - 1 ].X + textWords[ curWord - 1 ].W );
              while sX > ( curWord - 1 ) - newLine do
                begin
                  for j := newLine + 1 to curWord - 1 do
                    INC( textWords[ j ].X, 1 + ( j - ( newLine + 1 ) ) );
                  sX := Round( Rect.X + Rect.W - 1 ) - ( textWords[ curWord - 1 ].X + textWords[ curWord - 1 ].W );
                end;
              textWords[ curWord - 1 ].X := textWords[ curWord - 1 ].X + sX;
            end else
              if Flags and TEXT_HALIGN_CENTER > 0 Then
                begin
                  sX := ( Round( Rect.X + Rect.W - 1 ) - ( textWords[ curWord - 1 ].X + textWords[ curWord - 1 ].W ) ) div 2;
                  for j := newLine to curWord do
                    textWords[ j ].X := textWords[ j ].X + sX;
                end else
                  if Flags and TEXT_HALIGN_RIGHT > 0 Then
                    begin
                      sX := Round( Rect.X + Rect.W - 1 ) - ( textWords[ curWord - 1 ].X + textWords[ curWord - 1 ].W );
                      for j := newLine to curWord do
                        textWords[ j ].X := textWords[ j ].X + sX;
                    end;

          newLine   := curWord;
          lineWidth := 0;
          lineFeed  := FALSE;
          INC( LinesCount );
          if ( LinesCount + 1 ) * Font.MaxHeight > Rect.H Then break;
        end;
    end;

  if Flags and TEXT_VALIGN_CENTER > 0 Then
    begin
      Y := Round( ( Rect.Y + Rect.H - 1 ) - ( textWords[ WordsCount - 1 ].Y + Font.MaxHeight ) ) div 2;
      for i := 0 to WordsCount - 1 do
        textWords[ i ].Y := textWords[ i ].Y + Y;
    end else
      if Flags and TEXT_VALIGN_BOTTOM > 0 Then
        begin
          Y := Round( ( Rect.Y + Rect.H - 1 ) - ( textWords[ WordsCount - 1 ].Y + Font.MaxHeight ) );
          for i := 0 to WordsCount - 1 do
            textWords[ i ].Y := textWords[ i ].Y + Y;
        end;

  NewFlags := 0;
  if Flags and TEXT_FX_VCA > 0 Then
    NewFlags := NewFlags or TEXT_FX_VCA;
  if Flags and TEXT_FX_LENGTH > 0 Then
    NewFlags := NewFlags or TEXT_FX_LENGTH;

  j := 0;
  b := textLength;
  for i := 0 to WordsCount - 1 do
    begin
      if Flags and TEXT_FX_LENGTH > 0 Then
        begin
          textFx_SetLength( b - j, textLCoord, textLCharDesc );
          if j > b Then continue;
          j := j + u_Length( textWords[ i ].str );
        end;
      text_Draw( Font, textWords[ i ].X, textWords[ i ].Y, textWords[ i ].str, NewFlags );
    end;
end;

procedure text_DrawInRectEx;
begin
  textRGBA[ 0 ] :=   Color             shr 16;
  textRGBA[ 1 ] := ( Color and $FF00 ) shr 8;
  textRGBA[ 2 ] :=   Color and $FF;
  textRGBA[ 3 ] := Alpha;
  textScale     := Scale;
  textStep      := Step;
  text_DrawInRect( Font, Rect, Text, Flags );
  textRGBA[ 0 ] := 255;
  textRGBA[ 1 ] := 255;
  textRGBA[ 2 ] := 255;
  textRGBA[ 3 ] := 255;
  textScale     := 1;
  textStep      := 0;
end;

function text_GetWidth;
  var
    i : Integer;
    c : LongWord;
    lResult : Single;
begin
  lResult := 0;
  Result  := 0;
  if ( Text = '' ) or ( not Assigned( Font ) ) Then exit;
  i  := 1;
  while i <= length( Text ) do
    begin
      c := font_GetCID( Text, i, @i );
      if c = 10 Then
        begin
          lResult := Result;
          Result  := 0;
        end else
          if Assigned( Font.CharDesc[ c ] ) Then
            Result := Result + Font.CharDesc[ c ].ShiftP + Step;
    end;
  if lResult > Result Then
    Result := lResult;
end;

procedure textFx_SetLength;
begin
  textLength    := Length;
  textLCoord    := LastCoord;
  textLCharDesc := LastCharDesc;
end;

initialization
  SetLength( textWords, 1024 );

finalization
  SetLength( textWords, 0 );

end.
