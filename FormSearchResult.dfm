object SearchResultForm: TSearchResultForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1087#1086#1080#1089#1082#1072
  ClientHeight = 474
  ClientWidth = 361
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlBottom: TPanel
    Left = 0
    Top = 416
    Width = 361
    Height = 58
    Align = alBottom
    TabOrder = 0
    object btnOk: TButton
      Left = 136
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 361
    Height = 416
    Align = alClient
    BorderWidth = 10
    TabOrder = 1
    ExplicitLeft = 160
    ExplicitTop = 216
    ExplicitWidth = 185
    ExplicitHeight = 41
    object ListBox: TListBox
      Left = 11
      Top = 11
      Width = 339
      Height = 394
      Align = alClient
      ItemHeight = 15
      TabOrder = 0
      OnData = ListBoxData
    end
  end
end
