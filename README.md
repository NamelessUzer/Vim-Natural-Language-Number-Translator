# Vim Natural Language Number Translator

`Vim Natural Language Number Translator` is a versatile Vim script utility designed to seamlessly convert numbers between their textual representations and numeric forms. Initially focusing on Chinese numerals, the architecture of the plugin is built with extensibility in mind, aiming to support a wide array of languages and numeral systems in the future.

## Features

- **Chinese Numerals to Digits**: Convert Chinese numeral text to its corresponding Arabic digits within any Vim buffer.
- **Digits to Chinese Numerals**: Transform numeric digits into their Chinese numeral representation, with options for both traditional and simplified forms.
- **Extensible Architecture**: Designed from the ground up to be easily extendable to support additional languages and numeral systems.
- **Range Selection**: Operate on selected text, the current line, or the entire document, providing flexible conversion options to fit your workflow.
- **Customizable**: Offers configurations to set default behaviors, including numeral styles and target languages once more languages are supported.

## Installation

You can install `Vim Natural Language Number Translator` using your favorite Vim package manager.

Using [Vim-Plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'NamelessUzer/Vim-Natural-Language-Number-Translator'
```

## Usage

To convert numerals within a document, the plugin provides commands that can be executed in normal mode. Here are the initial commands for Chinese numeral conversion:

Convert Chinese Numerals to Digits:

```Vim
:TranslateZhNum2Num
```

Convert Digits to Chinese Numerals:

```
:TranslateNum2ZhNumLower
:TranslateNum2ZhNumUpper
```

## Key Bindings

Default key bindings are provided for convenience:

Convert numerals on the current line to digits: gnn
Convert digits on the current line to Chinese numerals (defaulting to lower case): gzz
Convert digits on the current line to Chinese numerals upper case: gzZ
Custom key bindings can be set in your .vimrc

```Vim
nnoremap <desired-key> <Plug>(TranslateZhNum2Num)
nnoremap <desired-key> <Plug>(TranslateNum2ZhNumLower)
nnoremap <desired-key> <Plug>(TranslateNum2ZhNumUpper)
```

## Configuration

Further configurations and options will be added as the plugin supports more languages. Keep an eye on the documentation for updates.

## Contributing

Contributions are welcome and greatly appreciated! If you have suggestions for additional languages, improvements, or have found a bug, feel free to open an issue or submit a pull request.
