require ('scancode1')


mapSrc = {
-- who uses caps lock anyway?
[scancode.SC_CapsLock] = scancode.SC_LCtrl
,  [scancode.SC_LCtrl] = scancode.SC_CapsLock
-- my laptop has stupid keys, swap RCTRL with menu
,  [scancode.SC_RCtrl] = scancode.SC_Menu
,   [scancode.SC_Menu] = scancode.SC_RCtrl
 -- first steps from QWKRFY 
 -- http://mkweb.bcgsc.ca/carpalx/?partial_optimization
,      [scancode.SC_K] = scancode.SC_E
,      [scancode.SC_E] = scancode.SC_K
,      [scancode.SC_J] = scancode.SC_O
,      [scancode.SC_O] = scancode.SC_J
,      [scancode.SC_F] = scancode.SC_T
,      [scancode.SC_T] = scancode.SC_F
,      [scancode.SC_D] = scancode.SC_A
,      [scancode.SC_A] = scancode.SC_D
,      [scancode.SC_G] = scancode.SC_N
,      [scancode.SC_N] = scancode.SC_G
}
