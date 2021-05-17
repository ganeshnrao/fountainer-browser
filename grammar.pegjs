{
  const forEach = require('lodash/forEach')
  const isArray = require('lodash/isArray')
  const isString = require('lodash/isString')
  const flattenDeep = require('lodash/flattenDeep')
  const camelCase = require('lodash/camelCase')

  function node(type, fields) {
    const line = location().start.line
    return { line, type, ...fields }
  }

  function flatten(tokens) {
    if (!isArray(tokens)) {
      return tokens
    }
    const flattenedTokens = []
    let text = []
    forEach(tokens, (token) => {
      if (isString(token)) {
        text.push(token)
      } else {
        if (text.length) {
          flattenedTokens.push(node('text', { text: text.join('') }))
          text = []
        }
        flattenedTokens.push(token)
      }
    })
    if (text.length) {
      flattenedTokens.push(node('text', { text: text.join('') }))
    }
    return flattenDeep(flattenedTokens)
  }

}

start = empty* title:titlePage? body:block* { return [title, ...body] }

block
  = boneyard
  / notes
  / empty
  / pageBreak
  / section
  / synopsis
  / transition
  / action

action
  = tokens:content end
    { return node('action', { tokens }) }

bold
  = '**' tokens:(!'**' token:inline { return token })+ '**'
    { return node('bold', { tokens: flatten(tokens) }) }

boneyard
  = '/*' tokens:(!'*/' (eol / .))+ '*/' end?
    { return node('boneyard', { tokens: flatten(tokens) }) }

content
  = tokens:inline+ { return flatten(tokens) }

empty
  = ws* eol
    { return node('empty') }

eof
  = !.

eol
  = '\n' / '\r\n'

end = eol / eof

escape
  = '\\' char:!ws { return `&#${char.charCodeAt(0)};` }

inline
  = escape
  / notes
  / boneyard
  / bold
  / italic
  / underline
  / plainChar

italic
  = '*' tokens:(!'*' token:inline { return token })+ '*'
    { return node('italic', { tokens: flatten(tokens) }) }

notes
  = '[[' ws* tokens:(!']]' (eol / .))+ ws* ']]' end?
    { return node('notes', { tokens: flatten(tokens) }) }

pageBreak
  = '===' '='* end
    { return node('page-break') }

plainChar
  = !eol char:.
    { return char }

section
  = ws* level:sectionLevel ws* tokens:content end
    { return node('section', { depth: level.length, tokens }) }

sectionLevel
  = '######' / '#####' / '####' / '###' / '##' / '#'

synopsis
  = ws* '=' ws* tokens:content end
    { return node('synopsis', { tokens }) }

titleKeyValue
  = ws* key:titleKey ws* firstLine:content* end moreLines:titleValueMultiline*
    { return node(key, { tokens: flattenDeep([firstLine, moreLines]) }) }

titleKey
  = key:('title'i / 'authors'i / 'author'i / 'copyright'i / 'credit'i / 'notes'i / 'source'i / 'draft_date'i / 'draft date'i / 'draft'i / 'date'i / 'contact'i) ':'
    { return camelCase(key) }

titleValueMultiline
  = ws* tokens:(!(titleKey / eol) content:content { return flatten(content) })+ end
    { return node('title-multiline', { tokens: flatten(tokens) }) }

titlePage
  = tokens:titleKeyValue+ { return node('title-page', { tokens }) }

transition
  = ws* '>' ws* tokens:content end { return node('transition-right', { tokens }) }
  // / ws* tokens:((!(eol / ':') content)+ ':') eol? { return { type: 'transition-right', tokens: flatten(tokens) } }

underline
  = '_' tokens:(!'_' token:inline { return token })+ '_'
    { return node('underline', { tokens: flatten(tokens) }) }

ws = ' ' / '\t'
