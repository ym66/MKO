program mko;

uses
  Vcl.Forms,
  FormMain in 'FormMain.pas' {MainForm},
  FormSearchResult in 'FormSearchResult.pas' {SearchResultForm},
  FormFileView in 'FormFileView.pas' {FileViewForm},
  FormRunProcess in 'FormRunProcess.pas' {RunProcessForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSearchResultForm, SearchResultForm);
  Application.CreateForm(TFileViewForm, FileViewForm);
  Application.CreateForm(TRunProcessForm, RunProcessForm);
  Application.Run;
end.
