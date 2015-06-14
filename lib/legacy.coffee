
typeMap =
  info: 'Trace'
  warning: 'Warning'
  error: 'Error'

transform = (filePath, textEditor, results) ->
  results.map(({message, level, range}) ->
    [ [startLine, startCol], [ endLine, endCol ] ] = (range.serialize?() ? range)

    msg =  {
      # If the type is non-standard just pass along whatever it was
      type: typeMap[level] ? level
      message: message
      file: filePath
      # These are all 0-indexed, but the `Position` needs a range where
      # everything is 1-indexed
      position: [
        [ startLine, startCol],
        [ endLine, endCol]
      ]
    }

    return msg
  )

module.exports = (ClassicLinter) ->

  editorMap = new WeakMap()

  return {
    scopes: ClassicLinter.syntax
    scope: 'file'
    lintOnFly: true

    lint: (textEditor, textBuffer) ->

      # Try to reuse the same instance if we can.
      linter = editorMap.get(textEditor)
      unless linter
        linter = new ClassicLinter(textEditor)
        editorMap.set(textEditor, linter)

      filePath = textEditor.getPath()

      return new Promise((resolve) ->
        linter.lintFile(filePath, (results) ->
          resolve(transform(filePath, textEditor, results))
        )
      )
  }
