object FileViewForm: TFileViewForm
  Left = 0
  Top = 0
  Caption = 'FileViewForm'
  ClientHeight = 441
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnResize = FormResize
  TextHeight = 15
  object pnlButtons: TPanel
    Left = 0
    Top = 392
    Width = 399
    Height = 49
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 624
    object btnOk: TButton
      Left = 160
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 0
    Width = 399
    Height = 392
    Align = alClient
    BorderWidth = 5
    TabOrder = 1
    ExplicitWidth = 624
    object lblCharsResult: TLabel
      Left = 6
      Top = 6
      Width = 387
      Height = 15
      Align = alTop
      Caption = 'lblCharsResult'
      ExplicitWidth = 75
    end
    object ListBox: TListBox
      Left = 6
      Top = 21
      Width = 387
      Height = 365
      Align = alClient
      ItemHeight = 15
      TabOrder = 0
      ExplicitLeft = 208
      ExplicitTop = 144
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
end
