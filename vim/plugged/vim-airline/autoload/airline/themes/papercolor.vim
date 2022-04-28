let g:airline#themes#papercolor#palette = {}

let s:N1 = [ '#585858' , '#e4e4e4' , 243 , 116 ] " Mode
let s:N2 = [ '#e4e4e4' , '#0087af' , 243 , 116  ] " Info
let s:N3 = [ '#eeeeee' , '#005f87' , 255 , 24  ] " StatusLine
let g:airline#themes#papercolor#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)


let g:airline#themes#papercolor#palette.accents = {
      \ 'red': [ '#ff0000' , '' , 160 , ''  ]
      \ }
let pal = g:airline#themes#papercolor#palette
for item in ['insert', 'replace', 'visual', 'inactive', 'ctrlp']
  " why doesn't this work?
  " get E713: cannot use empty key for dictionary
  "let pal.{item} = pal.normal
  exe "let pal.".item." = pal.normal"
  for suffix in ['_modified', '_paste']
    exe "let pal.".item.suffix. " = pal.normal"
  endfor
endfor
