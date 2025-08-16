object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1052#1050#1054' '#1090#1077#1089#1090#1086#1074#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072
  ClientHeight = 543
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 15
  object Label3: TLabel
    Left = 104
    Top = 216
    Width = 34
    Height = 15
    Caption = 'Label3'
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 486
    Width = 668
    Height = 57
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      668
      57)
    object btnClose: TButton
      Left = 572
      Top = 6
      Width = 75
      Height = 25
      Action = actClose
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 0
    end
    object StatusBar: TStatusBar
      Left = 1
      Top = 37
      Width = 666
      Height = 19
      Panels = <
        item
          Width = 50
        end>
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 0
    Width = 668
    Height = 486
    Align = alClient
    TabOrder = 1
    object InfoPanel: TPanel
      Left = 1
      Top = 366
      Width = 666
      Height = 119
      Align = alBottom
      BorderWidth = 5
      TabOrder = 0
      object Memo: TMemo
        Left = 6
        Top = 6
        Width = 654
        Height = 107
        Align = alClient
        TabOrder = 0
      end
    end
    object pnlMain: TPanel
      Left = 1
      Top = 1
      Width = 666
      Height = 365
      Align = alClient
      BorderWidth = 5
      TabOrder = 1
      object Label1: TLabel
        Left = 6
        Top = 6
        Width = 654
        Height = 15
        Align = alTop
        Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095
        ExplicitWidth = 74
      end
      object StringGrid: TStringGrid
        Left = 6
        Top = 21
        Width = 654
        Height = 124
        Align = alTop
        ColCount = 3
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect, goFixedRowDefAlign]
        TabOrder = 0
        OnClick = StringGridClick
        ColWidths = (
          73
          149
          425)
      end
      object pnlFileSearch: TPanel
        Left = 6
        Top = 145
        Width = 654
        Height = 214
        Align = alClient
        BorderWidth = 5
        TabOrder = 1
        object PageControl: TPageControl
          Left = 6
          Top = 6
          Width = 642
          Height = 202
          ActivePage = TabSheet2
          Align = alClient
          TabOrder = 0
          object TabSheet1: TTabSheet
            Caption = 'TabSheet1'
            object pnlMaskSearch: TPanel
              Left = 0
              Top = 0
              Width = 634
              Height = 172
              Align = alClient
              TabOrder = 0
              DesignSize = (
                634
                172)
              object lblSearchMask: TLabel
                Left = 16
                Top = 124
                Width = 260
                Height = 15
                Caption = #1042#1074#1077#1076#1080#1090#1077' '#1084#1072#1089#1082#1091' '#1092#1072#1081#1083#1072' '#1080#1083#1080' '#1084#1072#1089#1082#1080' '#1095#1077#1088#1077#1079' '#1079#1072#1087#1103#1090#1091#1102
              end
              object Label2: TLabel
                Left = 16
                Top = 20
                Width = 89
                Height = 15
                Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1087#1072#1087#1082#1091
              end
              object lblMask: TLabel
                Left = 226
                Top = 149
                Width = 50
                Height = 15
                Caption = #1042#1099#1073#1088#1072#1085#1086
              end
              object lblSelected: TLabel
                Left = 282
                Top = 149
                Width = 35
                Height = 15
                Caption = #1052#1072#1089#1082#1072
              end
              object edMask: TEdit
                Left = 282
                Top = 120
                Width = 169
                Height = 23
                TabOrder = 0
                Text = '*.pas'
              end
              object btnMaskSearch: TButton
                Left = 555
                Top = 137
                Width = 75
                Height = 25
                Action = actMaskSearch
                Anchors = [akRight, akBottom]
                TabOrder = 1
              end
              object DirectoryListBox: TDirectoryListBox
                Left = 282
                Top = 33
                Width = 223
                Height = 81
                TabOrder = 2
                OnChange = DirectoryListBoxChange
              end
              object DriveComboBox: TDriveComboBox
                Left = 282
                Top = 8
                Width = 223
                Height = 21
                DirList = DirectoryListBox
                TabOrder = 3
              end
            end
          end
          object TabSheet2: TTabSheet
            Caption = 'TabSheet2'
            ImageIndex = 1
            object pnlSubstring: TPanel
              Left = 0
              Top = 0
              Width = 634
              Height = 172
              Align = alClient
              TabOrder = 0
              ExplicitLeft = 208
              ExplicitTop = 72
              ExplicitWidth = 185
              ExplicitHeight = 41
              object lblSubsttring: TLabel
                Left = 224
                Top = 32
                Width = 59
                Height = 15
                Caption = #1055#1086#1076#1089#1090#1088#1086#1082#1072
              end
              object lblBytes: TLabel
                Left = 224
                Top = 85
                Width = 48
                Height = 15
                Caption = #1055#1088#1080#1084#1077#1088':'
              end
              object rgSearchSubstring: TRadioGroup
                Left = 17
                Top = 16
                Width = 185
                Height = 105
                Caption = #1048#1089#1082#1072#1090#1100
                TabOrder = 0
              end
              object RadioButton1: TRadioButton
                Left = 32
                Top = 40
                Width = 113
                Height = 17
                Caption = #1055#1086#1076#1089#1090#1088#1086#1082#1091
                TabOrder = 1
              end
              object RadioButton2: TRadioButton
                Left = 32
                Top = 80
                Width = 113
                Height = 17
                Caption = #1053#1072#1073#1086#1088' '#1073#1072#1081#1090
                TabOrder = 2
              end
              object edSubstring: TEdit
                Left = 224
                Top = 56
                Width = 177
                Height = 23
                TabOrder = 3
              end
              object btnSearchSubstring: TButton
                Left = 555
                Top = 136
                Width = 75
                Height = 25
                Caption = #1048#1089#1082#1072#1090#1100
                TabOrder = 4
              end
            end
          end
        end
      end
    end
  end
  object ActionList: TActionList
    Left = 552
    Top = 24
    object actClose: TAction
      Caption = 'actClose'
      OnExecute = actCloseExecute
    end
    object actMaskSearch: TAction
      Caption = #1048#1089#1082#1072#1090#1100
      OnExecute = actMaskSearchExecute
    end
    object actSearchSubstring: TAction
      Caption = #1048#1089#1082#1072#1090#1100
    end
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 593
    Top = 210
  end
end
