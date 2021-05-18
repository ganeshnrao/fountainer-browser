import forOwn from 'lodash/forOwn'
import get from 'lodash/get'
import kebabCase from 'lodash/kebabCase'
import mapValues from 'lodash/mapValues'
import './style.css'
import fountainer from './fountainer'

function toPercent(numerator, denominator = 100) {
  return `${(numerator / denominator) * 100}%`
}

function toInches(value) {
  return `${value}in`
}

const fixed = {
  pageWidth: 8.5,
  left: 1.5,
  right: 1,
  transitionLeft: 5.5,
  transitionRight: 1,
  characterLeft: 3.5,
  characterRight: 1,
  parenLeft: 3,
  parenRight: 3.25,
  dialogueLeft: 2.5,
  dialogueRight: 2.5,
  notesLeft: 1,
  notesRight: 1,
  dualLeft: 2,
  dualRight: 1,
  dualGutter: 0.25,
  dualDialogueLeft: 2,
  dialDialogueRight: 1,
  dualCharacterLeft: 0.75,
  dualCharacterRight: 0.25,
  dualParenLeft: 0.25,
  dualParentRight: 0.25
}

const styles = {
  shared: {
    fontFamily: 'Courier Prime',
    fontSize: '12pt',
    lineHeight: '14pt',
    bgColor: '#FFFFFF',
    notesColor: '#AAAAA',
    color: '#333333'
  },
  fixed,
  responsive: mapValues(fixed, (value) => (value / fixed.pageWidth) * 100)
}

const defaults = {
  notes: false,
  responsive: false
}

function getApplyStyles(settings) {
  const responsive = get(settings, 'responsive', defaults.responsive)
  const notes = get(settings, 'notes', defaults.notes)
  const styleSettings = get(settings, 'styles', {})
  const defaultStyles = responsive ? styles.responsive : styles.fixed
  const format = responsive ? toPercent : toInches
  return function (el) {
    forOwn(defaultStyles, (defaultValue, property) => {
      const value = get(styleSettings, property, defaultValue)
      el.style.setProperty(`--${kebabCase(property)}`, format(value))
    })
    forOwn(styles.shared, (defaultValue, property) => {
      const value = get(styleSettings, property, defaultValue)
      el.style.setProperty(`--${kebabCase(property)}`, value)
    })
    if (notes) {
      el.style.setProperty('--display-notes', 'block')
    }
  }
}

export default function (element, settings) {
  if (!element) {
    throw new Error('Fountainer: element must be provided!')
  }
  const fountainString = get(
    settings,
    'fountainString',
    element.textContent.trim()
  )
  const html = fountainer(fountainString)
  const applyStyles = getApplyStyles(settings)
  element.innerHTML = html
  element.classList.add('fountainer')
  applyStyles(element)
  return element
}
