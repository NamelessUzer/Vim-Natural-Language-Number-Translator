" Global dictionaries
let s:numMapUpper = {'0': '零', '1': '壹', '2': '贰', '3': '叁', '4': '肆', '5': '伍', '6': '陆', '7': '柒', '8': '捌', '9': '玖'}
let s:unitMap = {0: '', 1: '拾', 2: '佰', 3: '仟'}

let s:NumberPattern = '\v\d+(\.\d+)?'

function! Num2Zh#getNumberPattern()
  return s:NumberPattern
endfunction

" Updated main function to use the new structure
function! Num2Zh#Translator(number, style = 'lower')
  if a:number !~ '\v^\d+(\.\d+)?$'
    return a:number
  endif
  let integerStr = ""
  let decimalStr = ""
  if stridx(a:number, '.') >= 0
    let [integerPart, decimalPart] = split(a:number, '\.')
    for i in range(len(decimalPart))
      let decimalStr .= s:numMapUpper[decimalPart[i:i]]
    endfor
  else
    let integerPart = a:number
  endif

  let integerStr = s:TranslateIntegerStr(integerPart)
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

" Placeholder for TranslateInterStr function
function! s:TranslateIntegerStr(integer)
  let result = ""
  let integerLength = len(a:integer)
  if integerLength > 8
    let result = s:TranslateIntegerStr(a:integer[:-9]) . "亿" . s:TranslateIntegerStr(a:integer[-8:])
  elseif integerLength > 4
    let result = s:TranslateIntegerStr(a:integer[:-5]) . "万" . s:TranslateIntegerStr(a:integer[-4:])
  else
    let zerosNeeded = 4 - integerLength
    let zeros = repeat("0", zerosNeeded)
    let paddedInteger = zeros . a:integer
    for i in range(4)
      let result .=  s:numMapUpper[paddedInteger[i:i]] . s:unitMap[3-i]
    endfor
  endif
  return result
endfunction
