import kebabCase from 'lodash/kebabCase'

const skipSet = new Set(['type', 'tokens', 'text', 'class', 'tag', 'inline'])

function props(data) {
  return Object.keys(data)
    .reduce((acc, key) => {
      const value = data[key]
      if (!skipSet.has(key) && value !== null && typeof value !== 'undefined') {
        acc.push(` data-${kebabCase(key)}="${value}"`)
      }
      return acc
    }, [])
    .join('')
}

function preserveLeadingSpaces(text) {
  return text.replace(/^[ \t]+/, (spaces) =>
    spaces
      .split('')
      .map((space) => (space === '\t' ? '&nbsp;&nbsp;&nbsp;&nbsp;' : '&nbsp'))
      .join('')
  )
}

const renderer = {
  notes(token, inner) {
    return `<div class="notes"${props(token)}>
      ${inner.trim().replace(/\n/gim, '<br>')}
    </div>`
  },
  empty(token) {
    return renderer.default(token, '&nbsp;')
  },
  bold: { tag: 'strong' },
  italic: { tag: 'em' },
  underline: { tag: 'u' },
  uppercase: { tag: 'span', class: 'uppercase' },
  text(token, inner) {
    return preserveLeadingSpaces(inner)
  },
  extension: { tag: 'span' },
  lane: { class: 'col' },
  synopsis: { class: 'notes' },
  default(token, inner) {
    const { type, tag = 'div', text } = token
    const cssClass = token.class || kebabCase(type)
    const innerHtml = text || inner
    return ` <${tag} class="${cssClass}"${props(token)}>${innerHtml}</${tag}>`
  }
}

function getRenderFn(token) {
  const render = renderer[token.type] || renderer.default
  if (typeof render === 'object') {
    return (token, inner, context) =>
      renderer.default({ ...token, ...render }, inner, context)
  }
  return render
}

function walk(tokens = [], context = []) {
  return tokens
    .map((token) => {
      const render = getRenderFn(token)
      const contextable = token.type !== 'text' && !token.inline
      if (contextable) {
        context.unshift(token.type)
      }
      const inner = token.text || walk(token.tokens, context)
      const html = render(token, inner, context)
      if (contextable) {
        context.shift()
      }
      return html
    })
    .join('')
}

export default function (tokens) {
  return `<div class="script">${walk(tokens, [])}</div>`
}
