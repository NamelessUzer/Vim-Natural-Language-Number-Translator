" Global dictionaries
let s:numMapUpper = {
    \ '0'  : '零' , '1'  : '壹' , '2'  : '贰' , '3'  : '叁' , '4'  : '肆' , '5'  : '伍' , '6'  : '陆' , '7'  : '柒' , '8'  : '捌' , '9'  : '玖' ,
    \ '０' : '零' , '１' : '壹' , '２' : '贰' , '３' : '叁' , '４' : '肆' , '５' : '伍' , '６' : '陆' , '７' : '柒' , '８' : '捌' , '９' : '玖'
    \ }
let s:unitMap = {0: '', 1: '拾', 2: '佰', 3: '仟'}

let s:digit = '[0-9０１２３４５６７８９]'
let s:dot = '[．.]'
let s:NumberPattern = '\v' . s:digit . '+' . '(' . s:dot . s:digit . '+' . ')?'
let s:NumberFullMatchPattern = '^' . s:NumberPattern . '$'

function! Num2Zh#getNumberPattern()
  return s:NumberPattern
endfunction

" Updated main function to use the new structure
function! Num2Zh#Translator(number, style = 'lower')
  if a:number !~ s:NumberFullMatchPattern
    return a:number
  endif
  let integerStr = ""
  let decimalStr = ""
  if a:number =~ s:dot
    let [integerPart, decimalPart] = split(a:number, s:dot)
    let decimalList = split(decimalPart, '\zs')
    for i in range(len(decimalList))
      let decimalStr .= s:numMapUpper[decimalList[i]]
    endfor
  else
    let integerPart = a:number
  endif

  let integerList = split(integerPart, '\zs')
  let integerStr = s:TranslateIntegerList(integerList)
  while integerStr =~ '\(零[亿万仟佰拾]\)\+'
    let integerStr = substitute(integerStr, '\(零[仟佰拾]\?\)\+', '零', 'g')
    let integerStr = substitute(integerStr, '零\+\([亿万]\)', '\1零', 'g')
    let integerStr = substitute(integerStr, '亿\zs万', '', 'g')
  endwhile
  let integerStr = substitute(integerStr, '^零\+', '', 'g')
  let integerStr = substitute(integerStr, '零\+$', '', 'g')
  let integerStr = substitute(integerStr, '零\{2,}', '零', 'g')
  if integerStr == ''
    let integerStr = '零'
  endif

  if decimalStr == ""
    let result = integerStr
  else
    let result = integerStr . "点" . decimalStr
  endif

  " 处理小写转换
  if a:style == 'lower'
    let numMapLower = {'零': '〇', '壹': '一', '贰': '二', '叁': '三', '肆': '四', '伍': '五', '陆': '六', '柒': '七', '捌': '八', '玖': '九'}
    let unitMapLower = {'拾': '十', '佰': '百', '仟': '千'}
    let lowerResult = ''
    for ch in split(result, '\zs')
      if exists('numMapLower[ch]')
        let lowerResult .= numMapLower[ch]
      elseif exists('unitMapLower[ch]')
        let lowerResult .= unitMapLower[ch]
      else
        let lowerResult .= ch
      endif
    endfor
    let lowerResult = substitute(lowerResult, '^一\ze十', '', 'g')
    return lowerResult
  endif

  return result
endfunction

" Placeholder for TranslateInterList function
function! s:TranslateIntegerList(integerList)
  let result = ""
  let integerLength = len(a:integerList)
  if integerLength > 8
    let result = s:TranslateIntegerList(a:integerList[:-9]) . "亿" . s:TranslateIntegerList(a:integerList[-8:])
  elseif integerLength > 4
    let result = s:TranslateIntegerList(a:integerList[:-5]) . "万" . s:TranslateIntegerList(a:integerList[-4:])
  else
    " let paddedInteger = printf('%0*s', 4, a:integer)
    " 添加全角数字支持后，上述这一方便的方法不再可用
    let l:integerList = repeat(['0'], (4-len(a:integerList))) + a:integerList
    for i in range(4)
      let result .=  s:numMapUpper[l:integerList[i]] . s:unitMap[3-i]
    endfor
  endif
  return result
endfunction
