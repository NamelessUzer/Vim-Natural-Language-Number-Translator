if exists("g:loaded_NaturalLanguageNumberTranslator")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslator_plugin = 1

let s:ZhNumPattern = '\v[〇一二三四五六七八九零壹贰叁肆伍陆柒捌玖十拾百佰千仟万萬亿億两]+([点點][〇一二三四五六七八九零壹贰叁肆伍陆柒捌玖]+)?'

function! Zh2Num#getZhNumPattern()
  return s:ZhNumPattern
endfunction

" 中文数字到阿拉伯数字的映射
let s:cnNumMap = {
            \ '〇': '0', '一': '1', '二': '2', '三': '3', '四': '4',
            \ '五': '5', '六': '6', '七': '7', '八': '8', '九': '9'
            \ }

" 单位映射
let s:cnUnitMap = {
            \ '十': 1, '百': 2, '千': 3, '万': 4, '亿': 8
            \ }

" 大写中文数字到小写中文数字的映射
let s:cnUpper2LowerMap = {
            \ '零': '〇', '壹': '一', '贰': '二', '叁': '三', '肆': '四',
            \ '伍': '五', '陆': '六', '柒': '七', '捌': '八', '玖': '九',
            \ '拾': '十', '佰': '百', '仟': '千', '萬': '万', '億': '亿',
            \ '貮': '二', '两': '二', '點': '点'
            \ }

function! Zh2Num#Translator(zhNum)
    let l:zhNum = a:zhNum
    if match(l:zhNum, s:ZhNumPattern) == -1
      throw "Invalid Zh Number: " . ZhNum
    endif
    " 将大写中文数字转换为小写
    for [l:upper, l:lower] in items(s:cnUpper2LowerMap)
        let l:zhNum = substitute(l:zhNum, l:upper, l:lower, 'g')
    endfor

    " 处理小数点
    let l:parts = split(l:zhNum, '点')
    let l:integerPart = l:parts[0]
    let l:decimalPart = len(l:parts) > 1 ? l:parts[1] : ''

    " 转换整数部分
    let l:integerDigits = s:ZhInteger2Num(l:integerPart)

    " 转换小数部分
    if len(l:parts) > 1
        let l:decimalDigits = join(map(split(l:decimalPart, '\zs'), 'get(s:cnNumMap, v:val, v:val)'), '')
        return l:integerDigits . '.' . l:decimalDigits
    else
        return l:integerDigits
    endif
endfunction

function! s:ZhInteger2Num(integerPart)
    " 特殊处理"十"开头的情况
    let l:integerPart = substitute(a:integerPart, '\(\_^\|[亿万千百〇]\)\zs\ze十', '一', 'g')

    " 处理包含'亿'或'万'的数字
    for l:unit in ['亿', '万']
        let l:pos = strridx(l:integerPart, l:unit)  " 查找最后一个单位字符的位置
        if l:pos != -1
            let l:leftPart = strpart(l:integerPart, 0, l:pos)
            let l:rightPart = strpart(l:integerPart, l:pos + len(l:unit))
            let l:leftNum = s:ZhInteger2Num(l:leftPart)
            let l:rightNum = s:ZhInteger2Num(l:rightPart)
            let l:padding = repeat('0', s:cnUnitMap[l:unit] - len(l:rightNum))
            return l:leftNum . l:padding . l:rightNum
        endif
    endfor

    " 处理不包含'亿'或'万'的数字
    let l:result = ['0', '0', '0', '0']  " 使用列表代替字符串
    let l:unitLevel = 0
    for l:char in reverse(split(l:integerPart, '\zs'))
        if has_key(s:cnNumMap, l:char)
            if l:char != '〇'
                let l:result[3 - l:unitLevel] = s:cnNumMap[l:char]
            endif
        elseif has_key(s:cnUnitMap, l:char)
            let l:unitLevel = s:cnUnitMap[l:char]
        endif
    endfor

    " 移除前导0并处理特殊情况
    let l:resultStr = join(l:result, '')
    let l:resultStr = substitute(l:resultStr, '^0\+', '', '')
    return l:resultStr != '' ? l:resultStr : '0'
endfunction
