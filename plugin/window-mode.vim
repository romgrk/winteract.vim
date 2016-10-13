" File: windows.vim
" Author: romgrk
" Exec: !::exe [source %]

" This calls interactive-window-mode
"nmap gw        :InteractiveWindow<CR>

command! InteractiveWindow call InteractiveWindow()

let winmode  = {}

let winmode.trigger = '<leader>w'
let winmode.options = {
\ 'start': '',
\ 'stop':  '',
\ 'after': '',
\ }

let winmode.keys    = ''
let winmode.count   = ''
let winmode.submode = 'normal'

let winmap   = {}
let winmap.normal = {
\ "h": "normal! \<C-w><" , "=": "normal! \<C-w>=" ,
\ "j": "normal! \<C-w>-" , "f": "normal! \<C-w>_" ,
\ "k": "normal! \<C-w>+" , "F": "normal! \<C-w>|" ,
\ "l": "normal! \<C-w>>" , "o": "normal! \<C-w>o" ,
\
\ "|": "exe g:winmode.count.'wincmd |'",
\ "\\": "exe g:winmode.count.'wincmd _'",
\ "&": "normal! :\<C-r>=&tw\<CR>wincmd |\<CR>" ,
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
\ "w": "normal! \<C-w>w" , "\<A-w>": "normal! \<C-w>p" ,
\ "W": "normal! \<C-w>W" ,
\ "q": "normal! :copen\<CR>" ,
\
\ "m": "let g:winmode.submode='move'" ,
\ ":": "let g:winmode.submode='set'" ,
\ "t": "let g:winmode.submode='tab'" ,
\
\ "d": "bdelete" ,
\ ";": "terminal" ,
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
\ "r": "normal! \<C-w>r" ,
\ "\<ESC>": "\" NOP" ,
\ }

let winmap.set = {
\ "w": "exe g:winmode.count.'wincmd |'",
\ "h": "exe g:winmode.count.'wincmd _'",
\ "W": "wincmd |",
\ "H": "wincmd _",
\ "\<ESC>": "let resetmode=1" ,
\ }

let winmap.tab = {
\ "o": "tab sview %" ,
\ "e": "tabnew" ,
\ "x": "tabclose" ,
\ "n": "tabnext" ,
\ "p": "tabprevious" ,
\
\ "w": "let g:winmode.submode='normal'" ,
\ "\<ESC>": "let exitwin=1" ,
\ }

let winmap.escape = ["\<ESC>", "q"]

function! InteractiveWindow() " {{{
    let exitwin  = 0

    call s:prompt("window-mode started")
    while !exitwin
        let resetmode = 0

        let mode = g:winmode.submode
        let char = s:getChar()
        let lhs = char

        if !exists('g:winmap[l:mode][l:lhs]')
            if char =~ '^\d$'
                let g:winmode.count .= char
                call s:prompt('')
                call s:echo(g:winmode.count, 'TextWarning')
            else
                let g:winmode.submode = 'normal'
                call s:prompt('')
                call s:echo(lhs, 'TextInfo')
            end
            continue
        end

        let rhs = g:winmap[mode][lhs]

        if g:winmode.submode is 'move'
            let resetmode = 1 | en

        let wincount = g:winmode.count

        call s:echo('executing', 'TextWarning') | exe rhs

        if exitwin   | break                            | end
        if resetmode | let g:winmode.submode = 'normal' | end

        let g:winmode.count = ''
        let g:winmode.keys  = ''
        call s:prompt('')
    endwhile

    redraw
    call s:echo("exited window-mode ", 'TextInfo')
    call s:echo(":)", 'TextWarning')
endfunction " }}}

fu! s:getChar() " {{{
    let char = getchar()
    if char =~ '^\d\+$'
        return nr2char(char) | else
        return char          | end
endfun " }}}

fu! s:prompt(m, ...) "{{{
    redraw | call s:echo("[".g:winmode.submode."]> ". a:m)
    if !empty(a:000)
        for msg in range(len(a:000))
            call call('run_hello', ['foo'] + a:000)
        endfor
    end
endfu "}}}

fu! s:echo (...) " {{{
    " (mess, hl, re)
    let len = len(a:000)
    if len==3 || (len==2 && type(a:2)==0)
        redraw
    end
    if len==3 || (len==2 && type(a:2)==1)
        exe 'echohl '.a:2
    else
        echohl TextSuccess | end
    echon a:1 | echohl None
endfu " }}}

function! s:listWindows (...) " {{{
    let buffers = tabpagebuflist()
    let list = []
    for winID in range(1, winnr('$'))
        let bufnr = winbufnr(winID)
        let isListed = buflisted(bufnr)
        if (isListed || a:0)
            call add(list, winID)
        end
    endfor
    return list
endfunction " }}}

"\  . " {" . strtrans(join(keys(g:winmap[g:winmode.submode]), ', ')) . "}"
