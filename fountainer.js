import { parse } from './grammar.pegjs'
import render from './render'

export default function fountainToHtml(fountainString) {
  return render(parse(fountainString))
}
