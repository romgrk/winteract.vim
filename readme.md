

# Winteract.vim

An interactive-window mode, where you can resize windows by
repeatedly pressing j/k and h/l, amongst other things.

Also:
split, close, move, change focus, fullscreen, cycle buffer,
fullwidth, fullheight, set width to textwidth, exhange position
with next window.

## Mappings

```viml
nmap gw        :call InteractiveWindow()<CR>
nmap <leader>w :call InteractiveWindow()<CR>
```

This calls interactive-window-mode
Once there, you can: 

```
  - resize            j/k, h/l
  - max-size          f (height), F (width), 
  - fullscreen        o (!closes all others)
  - equalize          =
  - width=text        |, <BAR> 
  
  - [v]split          s/v
  - close             x/c
  
  - focus             
    - direction       Alt + [jkhl]
    - next/prev       n/p
  
  - move window       H/J/K/L  
                      m{h/j/k/l} or g{h/j/k/l}
  - exchange w next   mx or gx
  
  - cycle buffer      n/p, <S-TAB>/<TAB>
  - exit mode         <ESC>, <CR>
```
