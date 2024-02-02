if exists("g:loaded_NaturalLanguageNumberTranslatorZh2Num_plugin")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslatorZh2Num_plugin = 1

function! s:TranslateZh2NumOperator(type)
    " 保存原始光标位置
    let save_cursor = getpos('.')
    " 备份寄存器t
    let t_save = @t

    " 如果是block模式，则特别处理
    if a:type == "\<C-V>"
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        if column_end < column_start
            let [column_start, column_end] = [column_end, column_start]
        endif
        for line_num in range(line_start, line_end)
            let line = getline(line_num)
            " 将行文本转换为UTF-8编码
            let line_utf8 = iconv(line, &encoding, 'UTF-8')
            let selectedText = line_utf8[column_start - 1: column_end - 1]
            let translatedText = substitute(selectedText, Zh2Num#getZhNumPattern(), '\=Zh2Num#Translator(submatch(0))', 'g')
            let newLine = line[:column_start - 2] . translatedText . line[column_end:]
            call setline(line_num, newLine)
        endfor
    else
        " 对其他模式的处理
        if a:type == 'line'
            normal! '[V']
        elseif a:type == 'char'
            normal! `[v`]
        elseif a:type ==? 'v'
            normal! gv
        else
            normal! '[v']
        endif

        " 获取选择的文本，将其保存在寄存器t中
        normal! "ty
        let selectedText = iconv(@t, &encoding, 'UTF-8')

        " 转换文本
        let translatedText = substitute(selectedText, Zh2Num#getZhNumPattern(), '\=Zh2Num#Translator(submatch(0))', 'g')

        " 替换原文本
        call setreg('"', translatedText)
        normal! gv"0p
    endif

    " 恢复寄存器t
    call setreg('t', t_save)
    " 恢复光标位置
    call setpos('.', save_cursor)
endfunction

" 为我们的操作符定义一个映射
nnoremap <silent> <Plug>(TranslateZh2Num) :set operatorfunc=<sid>TranslateZh2NumOperator<CR>g@
vnoremap <silent> <Plug>(TranslateZh2Num) :<C-u>call <sid>TranslateZh2NumOperator(visualmode())<CR>

" 允许用户映射他们自己的快捷键到这个操作符
" 例如，将 `gn` 映射到这个操作符
" nmap gn <Plug>(TranslateZh2Num)
" xmap gn <Plug>(TranslateZh2Num)

function! s:TranslateZh2Num() range
    " 遍历指定范围内的每一行
    for lnum in range(a:firstline, a:lastline)
        let line = getline(lnum)
        " 对这一行的文本进行转换
        let translatedText = substitute(line, Zh2Num#getZhNumPattern(), '\=Zh2Num#Translator(submatch(0))', 'g')
        " 替换原有的行文本
        call setline(lnum, translatedText)
    endfor
endfunction

" 定义一个命令，该命令接受一个范围，这个范围默认为当前行
command! -range TranslateZhNum2Num :<line1>,<line2>call s:TranslateZh2Num()
nnoremap <silent> <Plug>(TranslateZhNum2Num) :TranslateZhNum2Num<cr>

" 允许用户映射他们自己的快捷键到这个操作符
" 例如，将 `gnn` 映射到这个操作符
" nnoremap gnn <Plug>(TranslateZhNum2Num)
