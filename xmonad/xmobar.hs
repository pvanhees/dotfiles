Config {
    font = "xft:inconsolata:size=10"
    , bgColor = "#222222"
    , fgColor = "#619FCF"
    , position = Static { xpos = 1, ypos = 1058, width = 1918, height = 20 }
    --, position = Static { xpos = 1, ypos = 1, width = 1918, height = 20 }
    , lowerOnStart = False
    , commands = [
        Run Battery ["-t", "<left>"] 100
        , Run MultiCpu ["-t","<total0> <total1> <total2> <total3>"] 30
        , Run Date "%_d %#B %Y  <fc=white>|</fc>  %H:%M" "date" 1
        , Run Com "/home/pieter/bin/alsavolume" [] "volume" 10
        , Run Network "wlp3s0" ["-t","Net <fc=#8AE234><rx>kb/s</fc> <fc=#ff8000><tx>kb/s</fc>"] 10
        , Run Memory ["-t", "Mem <fc=#D42807><usedratio></fc>"] 10
        , Run StdinReader
    ]
    , sepChar = "%"
    , alignSep = "}{"
    , template = " %StdinReader% }{cpu <fc=#D42807>%multicpu%</fc>   %memory%   %wlp3s0%   vol <fc=#D42807>%volume%</fc>   bat  <fc=#D42807>%battery%</fc>  <fc=white>|</fc>  <fc=#619FCF>%date% </fc> "
}
