if exists("g:loaded_NaturalLanguageNumberTranslator")
  finish
endif
let g:loaded_NaturalLanguageNumberTranslator_plugin = 1

let s:ZhNumPattern = '\v[〇一二三四五六七八九零壹贰叁肆伍陆柒捌玖十拾百佰千仟万萬亿億两]+([点點][〇一二三四五六七八九零壹贰叁肆伍陆柒捌玖]+)?'

function! Zh2Num#getZhNumPattern()
  return s:ZhNumPattern
endfunction

" 定义全局变量
let s:CN_NUM_MAP = {
\ '〇': 0, '一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9,
\ '零': 0, '壹': 1, '贰': 2, '叁': 3, '肆': 4, '伍': 5, '陆': 6, '柒': 7, '捌': 8, '玖': 9,
\ '貮': 2, '两': 2, '点': '.', '點': '.'
\}
let s:CN_UNIT_MAP = {
\ '十': 10, '拾': 10, '百': 100, '佰': 100, '千': 1000, '仟': 1000, '万': 10000, '萬': 10000,
\ '亿': 100000000, '億': 100000000
\}

" 中文数字转阿拉伯数字
function! Zh2Num#Translator(ZhNum)
  let ZhNum = a:ZhNum
  if match(ZhNum, s:ZhNumPattern) == -1
    throw "Invalid Zh Number: " . ZhNum
  endif
  let ZhNum = substitute(ZhNum, '億', '亿', 'g')
  let ZhNum = substitute(ZhNum, '萬', '万', 'g')
  let ZhNum = substitute(ZhNum, '仟', '千', 'g')
  let ZhNum = substitute(ZhNum, '佰', '百', 'g')
  let ZhNum = substitute(ZhNum, '拾', '十', 'g')

  let parts = split(ZhNum, '[点點]')
  let integerPart = parts[0]
  let decimalPart = len(parts) > 1 ? parts[1] : ''
  let result = s:ZhInteger2Num(integerPart)

  if len(decimalPart) > 0
    let decimalString = ''
    for i in split(decimalPart, '\zs')
      if has_key(s:CN_NUM_MAP, i)
        let decimalString .= s:CN_NUM_MAP[i]
      endif
    endfor
    let result = result . '.' . decimalString
  endif

  return result
endfunction

" 转换中文整数部分为阿拉伯数字
function! s:ZhInteger2Num(ZhInteger)
  if match(a:ZhInteger, '[亿万]') >= 0
    for unit in ['亿', '万']
      let i = strridx(a:ZhInteger, unit)
      if i >= 0
        return s:ZhInteger2Num(strpart(a:ZhInteger, 0, i)) * s:CN_UNIT_MAP[unit] + s:ZhInteger2Num(strpart(a:ZhInteger, i+len(unit)))
      endif
    endfor
  else
    let intResult = 0
    let ZhInteger = a:ZhInteger
    while len(ZhInteger) > 0
      let ZhInteger = trim(ZhInteger, '〇零', 1)
      let matchInfo = matchlist(ZhInteger, '^\([一二三四五六七八九零壹贰叁肆伍陆柒捌玖貮两]\)\([千百十]\)\(.*\)')
      if len(matchInfo) > 0
        let intResult += s:CN_NUM_MAP[matchInfo[1]] * s:CN_UNIT_MAP[matchInfo[2]]
        let ZhInteger = matchInfo[3]
      elseif match(ZhInteger, '^十') >= 0
        let intResult += 10
        let ZhInteger = substitute(ZhInteger, '^十', '', '')
      elseif match(ZhInteger, '^[一二三四五六七八九壹贰叁肆伍陆柒捌玖貮两]$') >= 0
        let intResult += s:CN_NUM_MAP[ZhInteger]
        break
      else
        break
      endif
    endwhile
    return intResult
  endif
endfunction