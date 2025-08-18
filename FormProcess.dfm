object ProcessForm: TProcessForm
  Left = 300
  Top = 300
  Caption = 'Process Window'
  ClientHeight = 441
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  DesignSize = (
    534
    441)
  TextHeight = 15
  object LblCmd: TLabel
    Left = 8
    Top = 8
    Width = 51
    Height = 15
    Caption = #1050#1086#1084#1072#1085#1076#1072':'
  end
  object LblTime: TLabel
    Left = 8
    Top = 28
    Width = 83
    Height = 15
    Caption = #1042#1088#1077#1084#1103': 00:00:00'
  end
  object Memo: TMemo
    Left = 8
    Top = 52
    Width = 530
    Height = 340
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object BtnStop: TButton
    Left = 220
    Top = 400
    Width = 100
    Height = 30
    Anchors = [akBottom]
    Caption = #1057#1090#1086#1087
    TabOrder = 1
    OnClick = BtnStopClick
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 472
    Top = 8
  end
end
