program mko;

uses
  Vcl.Forms,
  FormMain in 'FormMain.pas' {MainForm},
  FormSearchResult in 'FormSearchResult.pas' {SearchResultForm},
  FormFileView in 'FormFileView.pas' {FileViewForm},
  FormProcess in 'FormProcess.pas' {ProcessForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSearchResultForm, SearchResultForm);
  Application.CreateForm(TFileViewForm, FileViewForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.Run;
end.
