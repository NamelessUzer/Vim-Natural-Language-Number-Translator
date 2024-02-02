" 防止脚本被重复源代码加载
if exists("g:loaded_NaturalLanguageNumberTranslatorNum2Zh_plugin")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslatorNum2Zh_plugin = 1

function! s:TranslateNum2ZhOperator(type)
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
            let translatedText = substitute(selectedText, Num2Zh#getNumberPattern(), '\=Num2Zh#Translator(submatch(0))', 'g')
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
        let translatedText = substitute(selectedText, Num2Zh#getNumberPattern(), '\=Num2Zh#Translator(submatch(0))', 'g')

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
nnoremap <silent> <Plug>(TranslateNum2Zh) :set operatorfunc=<sid>TranslateNum2ZhOperator<CR>g@
vnoremap <silent> <Plug>(TranslateNum2Zh) :<C-u>call <sid>TranslateNum2ZhOperator(visualmode())<CR>

" 允许用户映射他们自己的快捷键到这个操作符
" 例如，将 `gz` 映射到这个操作符
" nmap gz <Plug>(TranslateNum2Zh)
" xmap gz <Plug>(TranslateNum2Zh)

function! s:TranslateNum2ZhNum(style) range
    let l:style = a:style == 'upper' ? 'upper' : 'lower'
    for lnum in range(a:firstline, a:lastline)
        let line = getline(lnum)
        let translatedText = substitute(line, Num2Zh#getNumberPattern(), '\=Num2Zh#Translator(submatch(0), l:style)', 'g')
        call setline(lnum, translatedText)
    endfor
endfunction

" 定义一个 Vim 命令，命名为 TranslateNum2Zh
" 这个命令接受一个参数：要转换的文本
" 这个示例默认使用 'lower' 模式进行转换
command! -nargs=? -range=% TranslateNum2ZhNum call s:TranslateNum2ZhNum(<q-args>)
" 对小写风格
nnoremap <silent> <Plug>(TranslateNum2ZhNumLower) :TranslateNum2ZhNum lower<CR>
" 对大写风格
nnoremap <silent> <Plug>(TranslateNum2ZhNumUpper) :TranslateNum2ZhNum upper<CR>

" 允许用户映射他们自己的快捷键到这个操作符
" 例如，将 `gzz` 映射到这个转为中文小写的命令，将 `gzZ` 映射到这个转为中文大写的命令
" nnoremap gzz <Plug>(TranslateNum2ZhNumLower)
" nnoremap gzZ <Plug>(TranslateNum2ZhNumUpper)
