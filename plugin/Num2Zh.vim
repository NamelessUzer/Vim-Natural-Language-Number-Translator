" 防止脚本被重复源代码加载
if exists("g:loaded_NaturalLanguageNumberTranslatorNum2Zh_plugin")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslatorNum2Zh_plugin = 1

function! GetUserChoice()
    let prompt = "Please enter 'l' or 'L' for lowercase, 'u' or 'U' for uppercase, press 'Esc' to exit,  press 'Enter' for default ('l'): "
    let warning = ""
    while 1
        " Prompt the user for input
        echo warning . prompt
        let char = getchar()
        let typedChar = nr2char(char)
        let result = ""
        " Check the user input
        if typedChar =~? 'l'
            let result = 'l'
            break
        elseif typedChar =~? 'u'
            let result = 'u'
            break
        elseif char == 27 " 27 is the ASCII code for the Esc key
            let result = v:null
            break
        elseif char == 13 " 13 is the ASCII code for Enter key
            let result = 'l' " Default to 'l' if Enter is pressed
            break
        else
            let warning = "Invalid input charactor: '" . typedChar . "'. "
        endif
    endwhile
    echo ""
    return result
endfunction

function! s:TranslateNum2ZhOperator(type)
    " 保存原始光标位置
    let save_cursor = getpos('.')
    " 备份寄存器t
    let t_save = @t

    " 使用 GetUserChoice 函数的返回值来决定接下来的行为
    let choice = GetUserChoice()
    let caseStyle = 'lower'
    if choice == 'l'
        " 在这里添加处理小写的代码
        let caseStyle = 'lower'
    elseif choice == 'u'
        " 在这里添加处理大写的代码
        let caseStyle = 'upper'
    else
        " 默认/错误处理
        return
    endif

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
            let translatedText = substitute(selectedText, Num2Zh#getNumberPattern(), '\=Num2Zh#Translator(submatch(0), caseStyle)', 'g')
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
        let translatedText = substitute(selectedText, Num2Zh#getNumberPattern(), '\=Num2Zh#Translator(submatch(0), caseStyle)', 'g')

        " 替换原文本
        call setreg('t', translatedText)
        normal! gv"tp
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
command! -nargs=? -range TranslateNum2ZhNum :<line1>,<line2>call s:TranslateNum2ZhNum(<q-args>)
" 对小写风格
nnoremap <silent> <Plug>(TranslateNum2ZhNumLower) :TranslateNum2ZhNum lower<CR>
" 对大写风格
nnoremap <silent> <Plug>(TranslateNum2ZhNumUpper) :TranslateNum2ZhNum upper<CR>

" 允许用户映射他们自己的快捷键到这个操作符
" 例如，将 `gzz` 映射到这个转为中文小写的命令，将 `gzZ` 映射到这个转为中文大写的命令
" nnoremap gzz <Plug>(TranslateNum2ZhNumLower)
" nnoremap gzZ <Plug>(TranslateNum2ZhNumUpper)
