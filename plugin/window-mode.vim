" File: windows.vim
" Author: romgrk
" Exec: !::exe [source %]

" This calls interactive-window-mode
nmap gw        :call InteractiveWindow()<CR>
nmap <leader>w :call InteractiveWindow()<CR>

" Once there, you can: 
"
" resize            j/k, h/l
" max-size          f (height), F (width), 
" fullscreen        o (!closes all others)
" equalize          =
" width=text        |, <BAR> 
"
" [v]split          s/v
" close             x/c
"
" focus             
"    direction      Alt + [jkhl]
"    next/prev      n/p
"
" move window       H/J/K/L  
"                   m{h/j/k/l} or g{h/j/k/l}
" exchange w next   mx or gx
"
" cycle buffer      n/p, <S-TAB>/<TAB>
" exit              <ESC>, <CR>

nnoremap <F1> :ListWindows<CR>
command! ListWindows call <SID>listWindows()

let winmode = 'normal'
let winmap = {}
let winmap.normal = {
\
\ "h": "normal! \<C-w><" , "=": "normal! \<C-w>=" ,
\ "j": "normal! \<C-w>-" , "f": "normal! \<C-w>_" ,
\ "k": "normal! \<C-w>+" , "F": "normal! \<C-w>|" ,
\ "l": "normal! \<C-w>>" , "o": "normal! \<C-w>o" ,
\
\ "|": "normal! :\<C-r>=&tw\<CR>wincmd |\<CR>" ,
\ 
\ "\<A-h>": "normal! \<C-w>h" ,  "H": "normal! \<C-w>H" ,
\ "\<A-j>": "normal! \<C-w>j" ,  "J": "normal! \<C-w>J" ,
\ "\<A-k>": "normal! \<C-w>k" ,  "K": "normal! \<C-w>K" ,
\ "\<A-l>": "normal! \<C-w>l" ,  "L": "normal! \<C-w>L" ,
\
\ "x": "normal! \<C-w>c" , "n": "normal! :bn\<CR>" ,
\ "c": "normal! \<C-w>c" , "p": "normal! :bp\<CR>" ,
\ "s": "normal! \<C-w>s" , "\<TAB>": "normal! :bn\<CR>" ,
\ "v": "normal! \<C-w>v" , "\<S-TAB>": "normal! :bp\<CR>" ,
\ 
\ "w": "normal! \<C-w>w" ,
\ "W": "normal! \<C-w>w" ,
\ "P": "normal! \<C-w>P" ,
\ "q": "normal! :copen\<CR>" ,
\
\ "g": "let g:winmode='move'" ,
\ "m": "let g:winmode='move'" ,
\
\ "\<ESC>": "let exitwin=1" ,
\ "\<CR>": "let exitwin=1" ,
\}

let winmap.move = {
\ "h": "normal! \<C-w>H" ,
\ "j": "normal! \<C-w>J" ,
\ "k": "normal! \<C-w>K" ,
\ "l": "normal! \<C-w>L" ,
\ "x": "normal! \<C-w>x" ,
\ "\<ESC>": "\" NOP" ,
\ }

let winmap.escape = ["\<ESC>", "q"]

function! InteractiveWindow() " {{{
    let prompt = " (current:" . bufname(winbufnr(0)) . ")"
    let exitwin = 0
    let char    = ''

    call s:echo(prompt)
    while !exitwin
        let resetwinmode = 0
        let char = s:getChar()
        if !exists('g:winmap[g:winmode][l:char]')
            let g:winmode = 'normal'
            call s:echoerr('Unmapped char: ' . char)
            continue | en

        let mapping = g:winmap[g:winmode][char]
        let prompt = " " . char
        if g:winmode is 'move' 
            let resetwinmode = 1 | en

        call s:echo(' executing ')

        exe mapping
        if resetwinmode == 1 | let g:winmode = 'normal' | en

        call s:echo(' ')
    endwhile
endfunction " }}}

fu! s:getChar() " {{{
    let char = getchar()
    if char =~ '^\d\+$'
        return nr2char(char) | else
        return char          | end
endfun " }}}

hi WindowModeRed   ctermfg=red   guifg=#bb1111 
hi WindowModeGreen ctermfg=green guifg=#11bb11 

fu! s:e (m)
    let m = a:m
    if empty(m)
        let m = " (buffer: ".bufname(winbufnr(0)).")" | end
    redraw | echo "[" . g:winmode . "]> " . m 
    echohl None
endfu

function! s:echo (message) " {{{
    echohl WindowModeGreen 
    call s:e(a:message)
endfunction " }}}

function! s:echoerr (message) " {{{
    echohl WindowModeRed
    call s:e(a:message)
endfunction " }}}

function! s:listWindows () " {{{
    let windows = map(tabpagebuflist(), 'bufwinnr(v:val)')
    for window in windows
        let bufnr = winbufnr(window)
        let bufname = bufname(bufnr)
        let isListed = buflisted(bufnr)
        echo '[' . window . ': ' . bufname . ' ' . isListed . ']'  
    endfor
endfunction " }}}

"\  . " {" . strtrans(join(keys(g:winmap[g:winmode]), ', ')) . "}"
