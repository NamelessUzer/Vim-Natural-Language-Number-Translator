if exists("g:loaded_NaturalLanguageNumberTranslator")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslator_plugin = 1

" 基本数字 + 特殊字符数字
let s:numberOnly = '〇一二三四五六七八九零壹贰叁肆伍陆柒捌玖两⼀⼆⼋'
" 单位（包括十、百、千、万等），基本单位 + 特殊字符单位
let s:unitOnly = '十百千万亿拾佰仟萬億⼗'
" 数字及单位的组合
let s:numAndUnit = s:numberOnly . s:unitOnly
" 点
let s:dot = '点點'
" 完整的数字表达式（考虑整数部分和可能的小数部分）
let s:ZhNumPattern = '\v([' . s:numAndUnit . ']+|[' . s:numberOnly . ']+)([' . s:dot . '][' . s:numberOnly . ']+)?'

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

let s:cnNumVariant2StandardMap = {
    \ '⼀': '一',
    \ '⼆': '二',
    \ '⼋': '八',
    \ '⼗': '十'
    \ }

function! Zh2Num#Translator(zhNum)
    let l:zhNum = a:zhNum
    if match(l:zhNum, s:ZhNumPattern) == -1
      throw "Invalid Zh Number: " . l:ZhNum
    else
      " 将所有大写中文数字转换为小写
      for [l:upper, l:lower] in items(s:cnUpper2LowerMap)
          let l:zhNum = substitute(l:zhNum, l:upper, l:lower, 'g')
      endfor
      " 将所有表示数字的异体汉字转换为常见的汉字形式
      for [l:variant, l:standard] in items(s:cnNumVariant2StandardMap)
          let l:zhNum = substitute(l:zhNum, l:variant, l:standard, 'g')
      endfor
    endif

    " 分割整数部分和小数部分
    let l:parts = split(l:zhNum, '点')
    let l:intPart = l:parts[0]
    let l:decPart = len(l:parts) > 1 ? l:parts[1] : ''

    " 检查整数部分是否为纯数字模式
    if match(l:intPart, '\v^[〇一二三四五六七八九]+$') != -1
        " 直接转换纯数字部分
        let l:intDigits = join(map(split(l:intPart, '\zs'), 'get(s:cnNumMap, v:val, v:val)'), '')
    else
        " 处理包含单位的数字
        " let l:intPart = substitute(l:intPart, '\v(^|[亿万千百〇])十', '\1一十', 'g')
        let l:intPart = substitute(l:intPart, '\v(^|[亿万千百〇])\zs\ze十', '一', 'g')
        let l:intDigits = s:ZhInteger2Num(l:intPart)
    endif

    " 处理小数部分
    if l:decPart != ''
        let l:decDigits = join(map(split(l:decPart, '\zs'), 'get(s:cnNumMap, v:val, v:val)'), '')
        return l:intDigits . '.' . l:decDigits
    else
        return l:intDigits
    endif
endfunction

function! s:ZhInteger2Num(integerPart)
    if a:integerPart == ''
      return '0'
    endif
    let l:integerPart = a:integerPart
    " 处理包含'亿'或'万'的数字
    for l:unit in ['亿', '万']
        let l:pos = strridx(l:integerPart, l:unit)  " 查找最后一个单位字符的位置
        if l:pos != -1
            let l:leftPart = strpart(l:integerPart, 0, l:pos)
            let l:rightPart = strpart(l:integerPart, l:pos + len(l:unit))
            let l:leftNum = s:ZhInteger2Num(l:leftPart)
            let l:rightNum = s:ZhInteger2Num(l:rightPart)
            return printf('%s%0*s', l:leftNum, s:cnUnitMap[l:unit], l:rightNum)
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
    return l:resultStr
endfunction
