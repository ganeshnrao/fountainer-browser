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
  / scene
  / center
  / dualDialogue
  / dialogue
  / transition
  / action

action
  = tokens:content end
    { return node('action', { tokens }) }

bold
  = '**' tokens:(!'**' token:inline { return token })+ '**'
    { return node('bold', { inline: true, tokens: flatten(tokens) }) }

boneyard
  = '/*' tokens:(!'*/' (eol / .))+ '*/' eol*
    { return node('boneyard', { tokens: flatten(tokens) }) }

center
  = ws* '>' ws* tokens:(!(eol / '<') inline:inline { return inline })+ '<' ws* end
    { return node('center', { tokens: flatten(tokens) }) }

character
  = ws* '@' tokens:content end
    { return node('character', { tokens }) }
  / ws* tokens:(!eol ![a-z^] inline:inline { return inline })+ end
    { return node('character', { tokens: flatten(tokens) }) }

characterCaret
  = ws* '@' tokens:(!(eol / '^') inline:inline { return inline })+ '^' ws* end
    { return node('character', { tokens: flatten(tokens) }) }
  / ws* tokens:(!(eol / [a-z^]) inline:inline { return inline })+ '^' ws* end
    { return node('character', { tokens: flatten(tokens) }) }

content
  = tokens:inline+ { return flatten(tokens) }

dialogue
  = character:character lines:dialogueItem+
    { return node('dialogue', { tokens: flatten([character, ...lines]) }) }

dialogueCaret
  = character:characterCaret lines:dialogueItem+
    {
      const { dual } = character
      return node('dialogue', { dual, tokens: flatten([character, ...lines]) })
    }

dualDialogue
  = first:dialogue empty* second:dialogueCaret
    { return node('dual-dialogue', { tokens: [first, second] }) }

dialogueItem
  = dialogueParen / dialogueLine

dialogueLine
  = ws* tokens:(!eol inline:inline { return inline })+ end
    { return node('dialogue-line', { tokens: flatten(tokens) }) }

dialogueParen
  = ws* '(' tokens:(!(eol / ')') inline:inline { return inline })+ ')' ws* end
    { return node('dialogue-paren', { tokens: flatten(['(', ...tokens, ')']) }) }

empty
  = ws* eol
    { return node('empty') }

eof
  = !.

eol
  = '\n' / '\r\n'

end = eol / eof

escape
  = '\\' char:. { return `&#${char.charCodeAt(0)};` }

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
    { return node('italic', { inline: true, tokens: flatten(tokens) }) }

notes
  = '[[' ws* tokens:(!']]' (eol / .))+ ws* ']]' eol*
    { return node('notes', { tokens: flatten(tokens) }) }

pageBreak
  = '===' '='* end
    { return node('page-break') }

plainChar
  = !eol char:.
    { return char }

scene
  = ws* &scenePrefix tokens:content eol { return node('scene', { tokens: flatten(tokens) }) }
    / ws* '.' &(!'.') ws* tokens:content eol { return node('scene', { tokens }) }

scenePrefix
  = 'INT' / 'EXT' / 'EST' / 'INT./EXT' / 'INT/EXT' / 'I/E'

section
  = ws* level:sectionLevel ws* tokens:content eol*
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
  = ws* '>' ws* tokens:content end
    { return node('transition-right', { tokens }) }
  / ws* tokens:(!(eol / transitionSuffix) inline:inline { return inline })+ suffix:transitionSuffix end
    { return node('transition-right', { tokens: flatten([...tokens, ...suffix]) }) }

transitionSuffix
  = 'TO:' / 'IN:' / 'OUT:'

underline
  = '_' tokens:(!'_' token:inline { return token })+ '_'
    { return node('underline', { inline: true, tokens: flatten(tokens) }) }

ws = ' ' / '\t'
