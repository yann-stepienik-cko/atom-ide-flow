{EditorControl} = require './editor-control'
utilFlowCommand = require('./util-flow-command')
createAutocompleteProvider = require('./flow-autocomplete-provider')

class PluginManager
  constructor: () ->
    @checkResults = []

    # Register an EditorControl for each editor view
    @controlSubscription = atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView(editor)
      editorView.flowController = new EditorControl(editor, this)

  deactivate: () ->
    for editor in atom.workspace.getTextEditors()
      editorView = atom.views.getView(editor)
      editorView.flowController?.deactivate()
      editorView.flowController = null
    @controlSubscription?.dispose()

  gotoDefinition: ->
    editor = atom.workspace.getActiveTextEditor()
    bufferPt = editor.getCursorBufferPosition()
    utilFlowCommand.getDef
      bufferPt: bufferPt
      fileName: editor.getPath()
      onResult: (result) ->
        if result.path? and result.path isnt ""
          promise = atom.workspace.open result.path
          promise.then (editor) ->
            editor.setCursorBufferPosition [result.line - 1, result.start - 1]
            editor.scrollToCursorPosition()
        else
          console.log("Could not go to definition")

  check: ->
    return;

  # Update every editor view with results
  updateAllEditorViewsWithResults: ->
    for editor in atom.workspace.getTextEditors()
      editorView = atom.views.getView(editor)
      editorView.flowController?.resultsUpdated()

  typeAtPos: ({bufferPt, fileName, text, onResult}) ->
    utilFlowCommand.typeAtPos
      fileName: fileName
      bufferPt: bufferPt
      onResult: onResult
      text: text


module.exports = { PluginManager }
