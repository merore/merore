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

let s:purple = [103, "#8787af"]

let s:mint = [108, "#87af87"]

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

" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
" syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1

call <SID>set_hi("Normal", s:fg, s:bg, "NONE")
call <SID>set_hi("Cursor", s:none, s:gray, "NONE")
call <SID>set_hi("Visual", s:none, s:gray, "NONE")
call <SID>set_hi("CursorLine", s:none, s:gray, "NONE")
call <SID>set_hi("CursorColumn", s:none, s:none, "NONE")
call <SID>set_hi("ColorColumn", s:none, s:none, "NONE")
call <SID>set_hi("LineNr", s:dark_gray, s:gray, "NONE")
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

call <SID>set_hi("Define", s:none, s:none, "NONE")
call <SID>set_hi("DiffAdd", s:none, s:none, "NONE")
call <SID>set_hi("DiffDelete", s:none, s:none, "NONE")
call <SID>set_hi("DiffChange", s:none, s:none, "NONE")
call <SID>set_hi("DiffText", s:none, s:none, "NONE")
call <SID>set_hi("ErrorMsg", s:none, s:none, "NONE")
call <SID>set_hi("WarningMsg", s:none, s:none, "NONE")

call <SID>set_hi("Boolean", s:none, s:none, "NONE")
call <SID>set_hi("Character", s:none, s:none, "NONE")
call <SID>set_hi("Comment", s:dark_gray, s:none, "NONE")
call <SID>set_hi("Conditional", s:none, s:none, "NONE")
call <SID>set_hi("Constant", s:none, s:none, "NONE")
call <SID>set_hi("Float", s:none, s:none, "NONE")
call <SID>set_hi("Function", s:none, s:none, "bold")
call <SID>set_hi("Identifier", s:none, s:none, "NONE")
call <SID>set_hi("Keyword", s:none, s:none, "NONE")
call <SID>set_hi("Label", s:none, s:none, "NONE")
call <SID>set_hi("NonText", s:none, s:bg, "NONE")
call <SID>set_hi("Number", s:none, s:none, "NONE")
call <SID>set_hi("Operator", s:none, s:none, "NONE")
call <SID>set_hi("PreProc", s:purple, s:none, "NONE")
call <SID>set_hi("Special", s:dark_gray, s:none, "NONE")
call <SID>set_hi("SpecialKey", s:none, s:none, "NONE")
call <SID>set_hi("Statement", s:none, s:none, "NONE")
call <SID>set_hi("SpellBad", s:none, s:none, "underline")
call <SID>set_hi("SpellCap", s:none, s:none, "underline")
call <SID>set_hi("StorageClass", s:none, s:none, "bold")
call <SID>set_hi("String", s:none, s:none, "NONE")
call <SID>set_hi("Tag", s:none, s:none, "NONE")
call <SID>set_hi("Title", s:none, s:none, "NONE")
call <SID>set_hi("Todo", s:none, s:none, "inverse")
call <SID>set_hi("Type", s:none, s:none, "bold")
call <SID>set_hi("Underlined", s:none, s:none, "underline")

call <SID>set_hi("cFunction", s:none, s:none, "bold")

call <SID>set_hi("SyntasticError", s:none, s:none, "NONE")
call <SID>set_hi("SyntasticWarning", s:none, s:none, "NONE")
