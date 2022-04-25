" Vim color file

set background=light
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "merore"

let s:bg = [254, "#e4e4e4"]
let s:fg = [243, "#767676"]
let s:gray = [188, "#d7d7d7"]
let s:dark_gray = [145, "#afafaf"]

let s:default_white = [231, "#FFFFFF"]

let s:lavender = [183, "#dfafff"]
let s:light_purple = [225, "#ffdfff"]
let s:gray_purple = [103, "#8787af"]

let s:pink = [218, "#ffafdf"]
let s:light_blue = [159, "#afffff"]
let s:mint = [108, "#afffd7"]
let s:light_yellow = [229, "#ffffaf"]

let s:dark_pink = [197, "#ff005f"]
let s:dark_green = [29, "#00875f"]
let s:dark_blue = [31, "#0087af"]

let s:none = ["NONE", ""]

function! <SID>set_hi(name, fg, bg, style)
  execute "hi " . a:name . " ctermfg=" . a:fg[0] . " ctermbg=" . a:bg[0] " cterm=" . a:style
  if a:fg[1] != ""
    execute "hi " . a:name . " guifg=" . a:fg[1]
  endif
  if a:bg[1] != ""
    execute "hi " . a:name . " guibg=" . a:bg[1]
  endif
  execute "hi " . a:name . " gui=" . a:style
endfun

call <SID>set_hi("Normal", s:fg, s:bg, "NONE")
call <SID>set_hi("Cursor", s:none, s:gray, "NONE")
call <SID>set_hi("Visual", s:none, s:gray, "NONE")
call <SID>set_hi("CursorLine", s:none, s:gray, "NONE")
call <SID>set_hi("CursorColumn", s:none, s:none, "NONE")
call <SID>set_hi("ColorColumn", s:none, s:none, "NONE")
call <SID>set_hi("LineNr", s:dark_gray, s:none, "NONE")
call <SID>set_hi("VertSplit", s:gray, s:gray, "NONE")
call <SID>set_hi("MatchParen", s:none, s:none, "underline")
call <SID>set_hi("StatusLine", s:none, s:none, "bold")
call <SID>set_hi("StatusLineNC", s:none, s:none, "NONE")
call <SID>set_hi("Pmenu", s:none, s:none, "NONE")
call <SID>set_hi("PmenuSel", s:none, s:none, "NONE")
call <SID>set_hi("IncSearch", s:none, s:none, "NONE")
call <SID>set_hi("Search", s:none, s:none, "underline")
call <SID>set_hi("Directory", s:none, s:none, "NONE")
call <SID>set_hi("Folded", s:none, s:none, "NONE")
call <SID>set_hi("TabLine", s:bg, s:gray, "NONE")
call <SID>set_hi("TabLineSel", s:none, s:none, "NONE")
call <SID>set_hi("TabLineFill", s:none, s:none, "NONE")

call <SID>set_hi("Define", s:gray_purple, s:none, "NONE")
call <SID>set_hi("DiffAdd", s:default_white, s:dark_green, "bold")
call <SID>set_hi("DiffDelete", s:dark_pink, s:none, "NONE")
call <SID>set_hi("DiffChange", s:default_white, s:gray, "NONE")
call <SID>set_hi("DiffText", s:default_white, s:dark_blue, "bold")
call <SID>set_hi("ErrorMsg", s:default_white, s:dark_pink, "NONE")
call <SID>set_hi("WarningMsg", s:default_white, s:dark_pink, "NONE")

call <SID>set_hi("Boolean", s:none, s:none, "NONE")
call <SID>set_hi("Character", s:none, s:none, "NONE")
call <SID>set_hi("Comment", s:none, s:none, "NONE")
call <SID>set_hi("Conditional", s:mint, s:none, "NONE")
call <SID>set_hi("Constant", s:mint, s:none, "NONE")
call <SID>set_hi("Float", s:none, s:none, "NONE")
call <SID>set_hi("Function", s:none, s:none, "NONE")
call <SID>set_hi("Identifier", s:none, s:none, "NONE")
call <SID>set_hi("Keyword", s:mint, s:none, "NONE")
call <SID>set_hi("Label", s:none, s:none, "NONE")
call <SID>set_hi("NonText", s:none, s:bg, "NONE")
call <SID>set_hi("Number", s:none, s:none, "NONE")
call <SID>set_hi("Operator", s:none, s:none, "NONE")
call <SID>set_hi("PreProc", s:none, s:none, "NONE")
call <SID>set_hi("Special", s:mint, s:none, "NONE")
call <SID>set_hi("SpecialKey", s:mint, s:gray, "NONE")
call <SID>set_hi("Statement", s:mint, s:none, "NONE")
call <SID>set_hi("SpellBad", s:pink, s:none, "underline")
call <SID>set_hi("SpellCap", s:light_blue, s:none, "underline")
call <SID>set_hi("StorageClass", s:mint, s:none, "NONE")
call <SID>set_hi("String", s:none, s:none, "NONE")
call <SID>set_hi("Tag", s:none, s:none, "NONE")
call <SID>set_hi("Title", s:none, s:none, "bold")
call <SID>set_hi("Todo", s:none, s:none, "inverse")
call <SID>set_hi("Type", s:none, s:none, "NONE")
call <SID>set_hi("Underlined", s:none, s:none, "underline")

call <SID>set_hi("SyntasticError", s:gray, s:pink, "NONE")
call <SID>set_hi("SyntasticWarning", s:gray, s:light_blue, "NONE")

" https://github.com/kien/rainbow_parentheses.vim
if !exists("g:rbpt_colorpairs")
  let g:rbpt_colorpairs = [
        \ s:mint, s:light_blue, s:lavender, s:pink,
        \ s:mint, s:light_blue, s:lavender, s:pink,
        \ s:mint, s:light_blue, s:lavender, s:pink,
        \ s:mint, s:light_blue, s:lavender, s:pink,
        \ ]
endif
