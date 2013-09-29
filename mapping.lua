require ('scancode1')

-- had to put it in two tables
-- as luajit does something funny with predef tables
-- and ipairs don't work...

mapSrc = {
scancode.SC_CapsLock  -- who uses caps lock anyway?
,  scancode.SC_LCtrl
,  scancode.SC_RCtrl  -- my laptop has stupid keys, swap RCTRL with menu
,   scancode.SC_Menu

,      scancode.SC_K -- first steps from QWKRFY 
,      scancode.SC_E -- http://mkweb.bcgsc.ca/carpalx/?partial_optimization
,      scancode.SC_J
,      scancode.SC_O
,      scancode.SC_F
,      scancode.SC_T
}

mapDst = {
scancode.SC_LCtrl
, scancode.SC_CapsLock
,   scancode.SC_Menu
,  scancode.SC_RCtrl
,      scancode.SC_E
,      scancode.SC_K
,      scancode.SC_O
,      scancode.SC_J
,      scancode.SC_T
,      scancode.SC_F
}
