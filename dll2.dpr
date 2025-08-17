library dll2;

uses
  Windows, SysUtils, Classes;

{$H+}

type
  TOutputCallback = procedure(const Line: PChar; UserData: Pointer); stdcall;
  TFinishedCallback = procedure(ExitCode: DWORD; UserData: Pointer); stdcall;

type
  PProcessTask = ^TProcessTask;
  TProcessTask = record
    Thread: TThread;
    ProcessHandle: THandle;
    OutputCB: TOutputCallback;
    FinishedCB: TFinishedCallback;
    UserData: Pointer;
  end;

type
  TProcessOutputThread = class(TThread)
  private
    FTask: PProcessTask;
    FCmdLine: string;
  protected
    procedure Execute; override;
    procedure SendOutput(const S: string);
  public
    constructor Create(Task: PProcessTask; const Cmd: string);
  end;

constructor TProcessOutputThread.Create(Task: PProcessTask; const Cmd: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FTask := Task;
  FCmdLine := Cmd;
end;

procedure TProcessOutputThread.SendOutput(const S: string);
begin
  if Assigned(FTask^.OutputCB) then
    FTask^.OutputCB(PChar(S), FTask^.UserData);
end;

procedure TProcessOutputThread.Execute;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  SecAttr: TSecurityAttributes;
  hRead, hWrite: THandle;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead: DWORD;
  ExitCode: DWORD;
  LineBuf: AnsiString;
  OneLine: AnsiString;
  p: Integer;
begin
  // пайп для stdout/stderr
  SecAttr.nLength := SizeOf(SecAttr);
  SecAttr.bInheritHandle := True;
  SecAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(hRead, hWrite, @SecAttr, 0) then
    Exit;

  try
    SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0);

    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    SI.wShowWindow := SW_HIDE;
    SI.hStdOutput := hWrite;
    SI.hStdError := hWrite;

    if CreateProcess(nil, PChar(FCmdLine), nil, nil, True,
                     CREATE_NO_WINDOW, nil, nil, SI, PI) then
    begin
      CloseHandle(hWrite);
      CloseHandle(PI.hThread);

      FTask^.ProcessHandle := PI.hProcess;

      LineBuf := '';
      while True do
      begin
        if not ReadFile(hRead, Buffer, SizeOf(Buffer)-1, BytesRead, nil) or (BytesRead = 0) then
          Break;

        Buffer[BytesRead] := #0;
        LineBuf := LineBuf + AnsiString(Buffer);

        // Разбиваем на строки
        while Pos(#10, LineBuf) > 0 do
        begin
          p := Pos(#10, LineBuf);
          OneLine := Trim(Copy(LineBuf, 1, p-1));
          Delete(LineBuf, 1, p);
          if OneLine <> '' then
            SendOutput(string(OneLine));
        end;
      end;

      // ждём завершения процесса
      WaitForSingleObject(PI.hProcess, INFINITE);
      if not GetExitCodeProcess(PI.hProcess, ExitCode) then
        ExitCode := DWORD(-1);

      CloseHandle(PI.hProcess);

      if Assigned(FTask^.FinishedCB) then
        FTask^.FinishedCB(ExitCode, FTask^.UserData);
    end
    else
    begin
      if Assigned(FTask^.FinishedCB) then
        FTask^.FinishedCB(DWORD(-1), FTask^.UserData);
    end;
  finally
    CloseHandle(hRead);
  end;
end;

// ------------------- API -------------------
function GetInfo: PWideChar; stdcall;
begin
   Result:= 'ArchivingFiles,Архивирование файлов/папки';
end;

function RunProcess(const CmdLine: PChar;
                    OutputCB: TOutputCallback;
                    FinishedCB: TFinishedCallback;
                    UserData: Pointer): Pointer; stdcall;
var
  Task: PProcessTask;
begin
  New(Task);
  FillChar(Task^, SizeOf(Task^), 0);
  Task^.OutputCB := OutputCB;
  Task^.FinishedCB := FinishedCB;
  Task^.UserData := UserData;

  Task^.Thread := TProcessOutputThread.Create(Task, CmdLine);

  Result := Task;
end;

function TerminateProcessTask(TaskPtr: Pointer): BOOL; stdcall;
var
  Task: PProcessTask absolute TaskPtr;
begin
  Result := False;
  if (Task <> nil) and (Task^.ProcessHandle <> 0) then
    Result := Windows.TerminateProcess(Task^.ProcessHandle, 1);
end;

procedure FreeProcessTask(TaskPtr: Pointer); stdcall;
var
  Task: PProcessTask absolute TaskPtr;
begin
  if Task <> nil then
    Dispose(Task);
end;


exports
  GetInfo,
  RunProcess,
  TerminateProcessTask,
  FreeProcessTask;

begin
end.

