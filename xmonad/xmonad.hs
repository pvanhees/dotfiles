import XMonad
import Data.Monoid
import System.Exit
 
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.UpdatePointer
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CycleWS
 
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
 
import XMonad.Util.Run(spawnPipe)
import System.IO(hPutStrLn)
 
import qualified XMonad.StackSet as W
import qualified Data.Map as M
 
myTerminal :: String
myTerminal = "termite"
 
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
 
myModMask = mod4Mask
 
myWorkspaces = ["a","s","d","f", "z"]
myMainColor = "#00FF00"
myBgColor = "#222222"
myTextcolor = "#8AE234"
whiteColor = "#ffFFff"
progColor = "#ffbf00"
proglColor = "#E9B96E"
 
myBorderWidth = 0
myNormalBorderColor = myTextcolor
myFocusedBorderColor = myNormalBorderColor
 
-- Key bindings. Add, modify or remove key bindings here.
-------------------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
 
    -- close focused window
    , ((modm .|. shiftMask, xK_c), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm, xK_space ), sendMessage NextLayout)
 
    -- Move focus to the next window
    , ((modm, xK_j), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm, xK_k), windows W.focusUp  )
 
    -- Swap the focused window and the master window
    , ((modm, xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j), windows W.swapDown  )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm, xK_h), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm, xK_l), sendMessage Expand)
 
    -- Shrink a window
    , ((modm, xK_u), sendMessage MirrorShrink)
 
    -- Expand a window
    , ((modm, xK_i), sendMessage MirrorExpand)
 
    -- Push window back into tiling
    , ((modm, xK_t), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm .|. shiftMask, xK_h), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm .|. shiftMask, xK_l), sendMessage (IncMasterN (-1)))

    -- move focus between screens
    , ((modm, xK_n), prevScreen)
    , ((modm .|. shiftMask, xK_n), shiftNextScreen)
 
    -- Volume
    , ((modm .|. controlMask , xK_j), spawn "amixer -c 0 set Master 5%- unmute")
    , ((modm .|. controlMask , xK_k), spawn "amixer -c 0 set Master 5%+ unmute")
    , ((modm .|. controlMask , xK_m), spawn "amixer -c 0 set Master toggle")
    , ((modm .|. controlMask , xK_h), spawn "amixer -c 0 set Headphone toggle")
    , ((modm .|. controlMask , xK_s), spawn "amixer -c 0 set Speaker toggle")
    , ((modm .|. controlMask , xK_i), spawn "hdmi-switch")
    , ((modm .|. controlMask , xK_l), spawn "xscreensaver-command --lock")
 
    -- Cover the status bar gap
    , ((modm, xK_c), sendMessage ToggleStruts)
 
    -- Programs
    , ((modm, xK_p), spawn "xfce4-appfinder")
    , ((modm, xK_b), spawn "google-chrome-stable")
    , ((modm, xK_v), spawn "~/bin/toggle-trayer" >> refresh)
    , ((modm .|. shiftMask, xK_v), spawn "pkill trayer")
    , ((modm .|. shiftMask, xK_q), spawn "xfce4-session-logout")
    , ((modm, xK_y), spawn "dmenu_run")
 
    -- Restart xmonad
    , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++
 
    --
    -- mod-[asdf], Switch to workspace N
    -- mod-shift-[asdf], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_a, xK_s, xK_d, xK_f, xK_z]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
 
 
-- Mouse bindings: default actions bound to mouse events
-------------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
       >> windows W.shiftMaster))
    ]
 
-- Layouts
------------------------------------------------------------------------
myLayout = avoidStruts $ smartSpacing 2 $ tiled ||| Mirror tiled ||| Full
  where
    tiled = ResizableTall 1 (3/100) (3/5) []
 
-- Window rules:
-- > xprop | grep WM_CLASS
-------------------------------------------------------------------------------
myManageHook = manageDocks <+> composeAll
    [ isFullscreen --> doFullFloat
    , className =? "Xfce4-notifyd" --> doIgnore
    , className =? "Conky" --> doIgnore
    , className =? "Xfce4-appfinder" --> doFloat
    , title     =? "plasma-desktop" -->doIgnore
    ]
 
-- Event handling
-------------------------------------------------------------------------------
myEventHook = fullscreenEventHook
 
-- Status bars and logging
-------------------------------------------------------------------------------
addPad = wrap " " " "
 
myPP statusPipe = xmobarPP {
    ppOutput = hPutStrLn statusPipe
    , ppCurrent = xmobarColor whiteColor myBgColor . addPad
    , ppVisible = xmobarColor myBgColor myTextcolor . addPad
    , ppHiddenNoWindows = xmobarColor myTextcolor myBgColor . addPad
    , ppHidden = xmobarColor myTextcolor myBgColor . addPad
    , ppTitle = xmobarColor progColor myBgColor
    , ppSep = xmobarColor whiteColor myBgColor "  |  "
}
 
myLogHook pipe = dynamicLogWithPP (myPP pipe) >> updatePointer (0.9,0.9) (0,0)
 
-- Startup hook
-------------------------------------------------------------------------------
myStartupHook = setWMName "LG3D"
 
-- Configuration structure
-------------------------------------------------------------------------------
defaults statusPipe = ewmh defaultConfig {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
 
    -- bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,
 
    -- hooks, layouts
    layoutHook         = myLayout,
    manageHook         = myManageHook,
    handleEventHook    = myEventHook,
    logHook            = myLogHook statusPipe,
    startupHook        = myStartupHook
}
 
-- Run xmonad with the settings specified. No need to modify this.
-------------------------------------------------------------------------------
main = do
    statusPipe <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
    xmonad $ defaults statusPipe
