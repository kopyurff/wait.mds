/* WaitMdsApiWrapper
' The console injector dynamic library for COM server component of wait.mds
' script library.
'
' Current library performs text reading of current console window & sending
' of text to caller, closes auxiliary window & unloads itself on completion.
' In the absence of an overlay, the exchange data is recorded via a file.
'
' * * * * * * * * * * * *                             * * * * * * * * * * * * *
'
' wait.mds script library, v2.00
'                                           Copyright (C) 2019-2024 Anton Kopiev
'                                                     GNU General Public License
'
' * * * * * * * * * * * * End User License Agreement: * * * * * * * * * * * * *
'
'    This program is free software: you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation, either version 3 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program.  If not, see <http://www.gnu.org/licenses/>.
'
' * * * * * * * * * * * *                             * * * * * * * * * * * * */
#include "stdafx.h"
#include <fstream>
#include <TCHAR.H>

struct READERDATA { 
 TCHAR sOverlay[501]; char sFile[255];
 HWND hCon, hOve; HMODULE hModule; BOOL isCo, noLB;
 DWORD osmv;
 HANDLE hThread;
} rd = {0};

BOOL __stdcall EnumFuncA(HWND Hdl, LPARAM param)
{
 TCHAR ClsCap[501] = {0};
 if (GetClassName(Hdl, ClsCap, 500) && lstrcmpi(ClsCap, TEXT("Button")) == 0 &&
  GetWindowText(Hdl, ClsCap, 500) && lstrcmpi(ClsCap, rd.sOverlay) == 0) {
  HWND *Handle;
  Handle = (HWND*)param; *Handle = Hdl; Handle = NULL; return false;
 }
 else return true;
}

BOOL __stdcall EnumFuncB(HWND Hdl, LPARAM param)
{
 DWORD Pid; GetWindowThreadProcessId(Hdl, &Pid);
 if (Pid == GetCurrentProcessId()) {
  HWND *Handle;
  Handle = (HWND*)param; *Handle = (HWND)Hdl; Handle = NULL; return false;
 }
 else return true;
}

DWORD WINAPI TextReader(LPVOID lpParam)
{
__try {
   if (rd.hCon)
   {
    SetThreadPriority(rd.hThread, THREAD_PRIORITY_ABOVE_NORMAL);

    HANDLE SOH = GetStdHandle(STD_OUTPUT_HANDLE); CONSOLE_SCREEN_BUFFER_INFO coin = {0};

    int cnt = 0; do { cnt ++; Sleep(5); } while ( cnt < 10 && ( WaitForSingleObject(SOH, 5) || GetLastError() ) );

    char fnBak[255] = {0}; FILE *fOut = NULL;
    if(rd.hOve == 0) { wsprintfA(fnBak, "%s.bak", rd.sFile); fOut = fopen(fnBak, "wb"); fwide(fOut, 1); }
      
    _CHAR_INFO *pod = NULL, *pev = NULL; SHORT *rows = NULL;
  __try {
     if (rd.isCo) {
      if (rd.hOve) SendMessage(rd.hOve, WM_APP + 16, (LPARAM)rd.hOve, NULL);

      if (SOH != INVALID_HANDLE_VALUE) {
       BOOL isClr = TRUE;

       if (GetConsoleScreenBufferInfo(SOH, &coin))
       {
        wchar_t row[32768] = {0}; COORD s = {coin.dwSize.X, coin.dwSize.Y};
        
        int sizeA = 2 * s.X, last[2] = {s.X / 2, s.X / 2}, sizeC = sizeA * sizeof(_CHAR_INFO), shiftY = 0, endY = 0, cntLB = 1;

        pod = new _CHAR_INFO[sizeA + 1]; ZeroMemory(pod, sizeC); cnt = -10;
        pev = new _CHAR_INFO[sizeA + 1]; ZeroMemory(pev, sizeC); if (10 <= rd.osmv) if (s.X % 2) last[1] --; else last[0] --;

        if (rd.noLB) { rows = new SHORT[9001]; ZeroMemory(rows, 18002); }

        for (int i = rd.hOve ? 0 : 1; i < 2; i ++)
        {
         DWORD row_cnt = 0, num_rpod, num_rpev, len = 0, xnlb = 0; COORD cod = {0, shiftY}, cev = {1, shiftY}; isClr = TRUE;
         BOOL _break = TRUE;

         while (cev.Y <= s.Y && ReadConsoleOutputCharacter(SOH, (LPWSTR) pod, (DWORD) s.X, cod, (LPDWORD) &num_rpod)
                             && ReadConsoleOutputCharacter(SOH, (LPWSTR) pev, (DWORD) s.X, cev, (LPDWORD) &num_rpev))
         {
          if (num_rpod == s.X && num_rpev == s.X) {
           int loe[2] = {0};
           
           for (int j = sizeA, l = last[0], k = last[1]; 0 <= k || 0 <= l; j --)
           {
            if (j % 2 == 0) {
             if (0 <= l) {
              if (loe[0]) {
               if (pod[l].Char.UnicodeChar == 0) loe[0] = 0;
              } else
               if (pod[l].Char.UnicodeChar != 0 && pod[l].Char.UnicodeChar != 32) loe[0] = l + 1;
             }
             l --;
            } else {
             if (0 <= k) {
              if (loe[1]) {
               if (pev[k].Char.UnicodeChar == 0) loe[1] = 0;
              } else
               if (pev[k].Char.UnicodeChar != 0 && pev[k].Char.UnicodeChar != 32) loe[1] = k + 1;
              k --;
             }
            }
           }
           if (loe[0] == 0) loe[1] = 0; else if (loe[1] == 0) loe[0] = 0;
           if (loe[1] + 1 < loe[0]) loe[1] = loe[0] - 1; else if (loe[0] < loe[1]) loe[0] = loe[1];

           if (rd.noLB) {
            _break = s.X % 2 ? loe[0] <= last[0] : loe[1] <= last[1]; if (!_break) { loe[0] = last[0] + 1; loe[1] = last[1] + 1; }
           }
           len = loe[1] + loe[0];

           if (i) {
            if (isClr) {
             isClr = FALSE;
             if (rd.hOve) SendMessage(rd.hOve, WM_APP + 17, cntLB, NULL); else fwprintf(fOut, L"%d\r\n%d\r\n%d\r\n", s.Y + 1, 2, 0);
            }
            if (len) {
             for (int j = 0, k = 0, l = 0; k < loe[1] || l < loe[0]; j ++) {
              if (j % 2 == 0) {
               if (l < loe[0])
                if (rd.hOve) SendMessage(rd.hOve, WM_APP + 18, pod[l++].Char.UnicodeChar, NULL); else row[xnlb + j] = pod[l++].Char.UnicodeChar;
              } else {
               if (k < loe[1])
                if (rd.hOve) SendMessage(rd.hOve, WM_APP + 18, pev[k++].Char.UnicodeChar, NULL); else row[xnlb + j] = pev[k++].Char.UnicodeChar;
              }
             }
            }
            if (_break) {
             if (rd.hOve) {
              row_cnt ++; SendMessage(rd.hOve, WM_APP + 19, row_cnt, NULL);
             } else {
              len += xnlb; row[len] = '\r'; row[len + 1] = '\n'; fwrite(row, 2, len + 2, fOut);
             }
             xnlb = 0;
            } else
             xnlb += len;
           }
           else if (rd.noLB) {
            xnlb += len;
            if (_break) { rows[row_cnt] = cev.Y; if (xnlb) { isClr = FALSE; cnt = row_cnt; }; xnlb = 0; row_cnt ++; } else cntLB --;
           } else {
            cnt ++; if (len) { isClr = FALSE; shiftY = cnt; endY = cev.Y; }
           }
           cod.Y ++; cev.Y ++; ZeroMemory(pev, sizeC); ZeroMemory(pod, sizeC);
          }
          else break;
         }
         if (i) {
          if (xnlb) 
           if (rd.hOve) {
            row_cnt ++; SendMessage(rd.hOve, WM_APP + 19, row_cnt, NULL);
           } else {
            len += xnlb; row[len] = '\r'; row[len + 1] = '\n'; fwrite(row, 2, len + 2, fOut);
           }
         } else {
          if (rd.noLB) {
           if (cnt < 10) { shiftY = 0; s.Y = rows[9]; } else { shiftY = rows[cnt - 9]; s.Y = rows[cnt]; }
           delete rows; rows = NULL;
          } else {
           if (shiftY < 0) shiftY = 0; s.Y = shiftY + 9; if (endY < s.Y) s.Y = endY;
          }
          if (isClr) break; else cntLB = s.Y - shiftY + cntLB;
         }
        }

        if (!isClr) if (rd.hOve) SendMessage(rd.hOve, WM_APP + 20, 0, NULL);
       }

       if (isClr) if (rd.hOve) SendMessage(rd.hOve, WM_APP + 21, 5, NULL); else fwprintf(fOut, L"%d\r\n%d\r\n%d\r\n", 0, 1, 5);
      } else
       if (rd.hOve) SendMessage(rd.hOve, WM_APP + 21, 6, NULL); else fwprintf(fOut, L"%d\r\n%d\r\n%d\r\n", 0, 1, 6);
     } else 
      if (rd.hOve) SendMessage(rd.hOve, WM_APP + 21, 7, NULL); else fwprintf(fOut, L"%d\r\n%d\r\n%d\r\n", 0, 1, 7);

     if (rd.hOve == 0) { fflush(fOut); fclose(fOut); fOut = NULL; rename(fnBak, rd.sFile); }
    } __finally {
     if (pev) { delete pev; pev = NULL; }
     if (pod) { delete pod; pod = NULL; }; if (rows) { delete rows; rows = NULL; }

     if(rd.hOve) {
      SendMessage(rd.hOve, WM_CLOSE, 0, NULL); SendMessage(rd.hOve, WM_QUIT, 0, NULL);
     } else {
      if (fOut) { fflush(fOut); fclose(fOut); fOut = NULL; }

      if (GetFileAttributesA(fnBak) != INVALID_FILE_ATTRIBUTES) rename(fnBak, rd.sFile);
     }
    }
   }
  } __finally {

   CloseHandle(rd.hThread); rd.hThread = NULL;
   while (true)
   {
  __try
    {
     Sleep(25); FreeLibraryAndExitThread(rd.hModule, 0); Sleep(75);
    }
  __finally { /*.*/ }
   }
  }
  return 0;
}


BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
  if(ul_reason_for_call == DLL_PROCESS_ATTACH)
  {
 __try
   {
    ZeroMemory(&rd, sizeof(READERDATA));
    rd.hCon = GetConsoleWindow(); if (rd.hCon) rd.isCo = TRUE; else EnumWindows(&EnumFuncB, (LPARAM)&rd.hCon);

    if (rd.hCon)
    {
     rd.hModule = hModule; wsprintfA(rd.sFile, "%s\\console.text.reader.%lu.out", getenv("TEMP"), rd.hCon);
     if (rd.isCo)
     {
      _stprintf(rd.sOverlay, L"console.text.reader.%lu", rd.hCon); EnumChildWindows(GetDesktopWindow(), &EnumFuncA, (LPARAM)&rd.hOve);

      OSVERSIONINFOW ovi; ZeroMemory(&ovi, sizeof(OSVERSIONINFOW)); ovi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOW);
      GetVersionEx(&ovi); rd.osmv = ovi.dwMajorVersion;
      if (10 <= rd.osmv) {
       char fnNlb[255] = {0}; wsprintfA(fnNlb, "%s.nlb", rd.sFile); rd.noLB = GetFileAttributesA(fnNlb) != INVALID_FILE_ATTRIBUTES;
      }
     }

     DWORD tid; rd.hThread = CreateThread(NULL, 0, TextReader, NULL, 0, &tid);
    } else
     FreeLibraryAndExitThread(hModule, 0);
   }
 __finally { /*.*/ }
  }
  else if(ul_reason_for_call == DLL_PROCESS_DETACH)
  {
   Sleep(25);
  }
  return TRUE;
}