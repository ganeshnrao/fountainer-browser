# Fountainer (Browser)

Render Fountain script as HTML.

A CLI version of Fountainer is [available here](https://github.com/ganeshnrao/fountainer)

## Installation
You have the following two options:
### Option 1: Install via `npm`
You can either install the package as follows.
```bash
npm install fountainer-browser --save
```
then in you HTML, you can embed the file as:
```html
<script src="../node_modules/fountainer-browser/dist.js"></script>
```

### Option 2: Load file from CDN
You can directly load the bundle file from CDN as follows.
```html
<script src="//cdn.jsdelivr.net/npm/fountainer-browser@latest/dist/bundle.js"></script>
```

## Usage
Embed the fountainer bundle file in your HTML body using the script tag as shown above. Then you can place your fountain script directly withn an element. Then call the `fountainer` method and pass the reference to the element containing the fountain script.

### Simple Usage Example
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Hello World -- An Example</title>
</head>
<body>
  <div id="hello-world">
Title: Hello world!
Credit: Written By
Author: Foo Bar

# ACT ONE
= Setup characters and the inciting incident

INT. SERVER ROOM - NIGHT

Two robots are moving servers. One old and blocky, another shiny and sharp.
Suddenly the old robot's arm FALLS OFF!

OLD ROBOT
Uh oh!

NEW ROBOT
You should be deprecated.
  </div>
  <script src="//cdn.jsdelivr.net/npm/fountainer-browser@latest/dist/bundle.js"></script>
  <script>
    (function(){
      fountainer(
        document.getElementById('hello-world'),
        { responsive: true, notes: true }
      )
    })()
  </script>
</body>
</html>
```

### Advanced Usage Example
The example below uses [jQuery](https://api.jquery.com/jquery.get/) to fetch the fountain file via an HTTP request, however you can use any library to fetch the fountain file content.
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Hello World -- An Example</title>
</head>
<body>
  <div id="hello-world"></div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/fountainer-browser@latest/dist/bundle.js"></script>
  <script>
    $(document).ready(function() {
      $.get('/hello-world.fountain', function (data) {
        fountainer(
          $('#hello-world')[0],
          { 
            fountainString: data,
            responsive: true,
            notes: true,
            styles: {
              // these will be interpreted as percentages
              // as we have set `responsive: true` above
              left: 5,
              right: 5,
              transitionLeft: 80,
            }
          }
        )
      })
    })
  </script>
</body>
</html>
```

## API

The `fountainer` method takes two arguments shown below
```js
fountainer(el, settings)
```
`el` is a reference to the element containing the fountain script. All the textual content of the `el` element will be interpreted as fountain text.

`settings` is an object with the following properties
```js
{
  fountainString: '', // you can provide the fountain script text here
  // when provided, the contents of the element are ignored
  notes: false, // notes will be rendered when set to true
  responsive: false,
  // when responsive is set to true the script will be rendered
  // with percentage based widths and all values provided in the
  // `styles` object will be interpreted as percentages.
  // When responsive is set to false, script will be rendered in
  // inches and all values provided in the `styles` object will be
  // interpreted as inches.
  styles: {
    // object containing styling overrides, default values are shown below
    pageWidth: 8.5, // width of the fountainer element
    left: 1.5, // left margin for scenes and actions 
    right: 1, // right margin for scenes and actions
    transitionLeft: 5.5, // left margin for transitions
    transitionRight: 1, // right margin for transitions
    characterLeft: 3.5, // left margin for character
    characterRight: 1, // right margin for character
    parenLeft: 3, // left margin for parentheticals
    parenRight: 3.25, // right margin for parentheticals
    dialogueLeft: 2.5, // left margin for dialogues
    dialogueRight: 2.5, // right margin for dialogues
    notesLeft: 1, // left margin for sections and synopses
    notesRight: 1, // right margin for sections and synopses
    dualLeft: 2, // left margin for dual dialogues
    dualRight: 1, // right margin for dual dialogues
    dualGutter: 0.25, // column gutter for dual dialogues
    dualDialogueLeft: 2, // left margin for dual dialogueslines
    dialDialogueRight: 1, // right margin for dual dialogue lines
    dualCharacterLeft: 0.75, // left margin for dual dialogue character
    dualCharacterRight: 0.25, // right margin for dual dialogue character
    dualParenLeft: 0.25, // left margin for dual dialogue parentheticals
    dualParentRight: 0.25, // right margin for dual dialogue parentheticals
    fontFamily: 'Courier Prime', // font for the script
    fontSize: '12pt', // font size for the script
    lineHeight: '14pt', // line height for the script
    bgColor: '#FFFFFF', // background color of the script
    color: '#333333', // foreground color of the script
    notesColor: '#AAAAA' // color for the notes (only applicable when `notes` is true)
  }
}
```
