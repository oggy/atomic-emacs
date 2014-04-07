{WorkspaceView} = require 'atom'
AtomicEmacs = require '../lib/atomic-emacs'
Mark = require '../lib/mark'
EditorState = require './editor-state'

describe "AtomicEmacs", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    @editor = atom.project.openSync()
    @event = targetView: => {editor: @editor}

  describe "atomic-emacs:transpose-words", ->
    it "transposes the current word with the one after it", ->
      EditorState.set(@editor, "aaa b[0]bb .\tccc ddd")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa ccc .\tbbb[0] ddd")

    it "transposes the previous and next words if at the end of a word", ->
      EditorState.set(@editor, "aaa bbb[0] .\tccc ddd")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa ccc .\tbbb[0] ddd")

    it "transposes the previous and next words if at the beginning of a word", ->
      EditorState.set(@editor, "aaa bbb .\t[0]ccc ddd")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa ccc .\tbbb[0] ddd")

    it "transposes the previous and next words if in between words", ->
      EditorState.set(@editor, "aaa bbb .[0]\tccc ddd")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa ccc .\tbbb[0] ddd")

    it "moves to the start of the last word if in the last word", ->
      # Emacs leaves point at the start of the word, but that seems unintuitive.
      EditorState.set(@editor, "aaa bbb .\tcc[0]c ")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa bbb .\tccc[0] ")

    it "transposes the last two words if at the start of the last word", ->
      EditorState.set(@editor, "aaa bbb .\t[0]ccc")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("aaa ccc .\tbbb[0]")

    it "transposes the first two words if at the start of the buffer", ->
      EditorState.set(@editor, "[0]aaa .\tbbb ccc")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual("bbb .\taaa[0] ccc")

    it "moves to the start of the word if it's the only word in the buffer", ->
      # Emacs leaves point at the start of the word, but that seems unintuitive.
      EditorState.set(@editor, " \taaa [0]\t")
      AtomicEmacs.transposeWords(@event)
      expect(EditorState.get(@editor)).toEqual(" \taaa[0] \t")

  describe "atomic-emacs:transpose-lines", ->
    it "transposes this line with the previous one, and moves to the next line", ->
      EditorState.set(@editor, "aaa\nb[0]bb\nccc\n")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("bbb\naaa\n[0]ccc\n")

    it "pretends it's on the second line if it's on the first", ->
      EditorState.set(@editor, "a[0]aa\nbbb\nccc\n")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("bbb\naaa\n[0]ccc\n")

    it "creates a newline at end of file if necessary", ->
      EditorState.set(@editor, "aaa\nb[0]bb")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("bbb\naaa\n[0]")

    it "still transposes if at the end of the buffer after a trailing newline", ->
      EditorState.set(@editor, "aaa\nbbb\n[0]")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("aaa\n\nbbb\n[0]")

    it "inserts a blank line at the top if there's only one line with a trailing newline", ->
      EditorState.set(@editor, "a[0]aa\n")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("\naaa\n[0]")

    it "inserts a blank line at the top if there's only one line with no trailing newline", ->
      EditorState.set(@editor, "a[0]aa")
      AtomicEmacs.transposeLines(@event)
      expect(EditorState.get(@editor)).toEqual("\naaa\n[0]")

  describe "atomic-emacs:delete-horizontal-space", ->
    it "deletes all horizontal space around each cursor", ->
      EditorState.set(@editor, "a [0]\tb c [1]\td")
      AtomicEmacs.deleteHorizontalSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]b c[1]d")

    it "deletes all horizontal space to the beginning of the buffer if in leading space", ->
      EditorState.set(@editor, " [0]\ta")
      AtomicEmacs.deleteHorizontalSpace(@event)
      expect(EditorState.get(@editor)).toEqual("[0]a")

    it "deletes all horizontal space to the end of the buffer if in trailing space", ->
      EditorState.set(@editor, "a [0]\t")
      AtomicEmacs.deleteHorizontalSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]")

    it "deletes all text if the buffer only contains horizontal spaces", ->
      EditorState.set(@editor, " [0]\t")
      AtomicEmacs.deleteHorizontalSpace(@event)
      expect(EditorState.get(@editor)).toEqual("[0]")

    it "does not modify the buffer if there is no horizontal space around the cursor", ->
      EditorState.set(@editor, "a[0]b")
      AtomicEmacs.deleteHorizontalSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]b")

  describe "atomic-emacs:kill-word", ->
    it "deletes from the cursor to the end of the word if inside a word", ->
      EditorState.set(@editor, "aaa b[0]bb ccc")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa b[0] ccc")

    it "deletes the word in front of the cursor if at the beginning of a word", ->
      EditorState.set(@editor, "aaa [0]bbb ccc")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0] ccc")

    it "deletes the next word if at the end of a word", ->
      EditorState.set(@editor, "aaa[0] bbb ccc")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa[0] ccc")

    it "deletes the next word if between words", ->
      EditorState.set(@editor, "aaa [0] bbb ccc")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0] ccc")

    it "does nothing if at the end of the buffer", ->
      EditorState.set(@editor, "aaa bbb ccc[0]")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa bbb ccc[0]")

    it "deletes the trailing space in front of the cursor if at the end of the buffer", ->
      EditorState.set(@editor, "aaa bbb ccc [0] ")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa bbb ccc [0]")

    it "deletes any selected text", ->
      EditorState.set(@editor, "aaa b(0)b[0]b ccc")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa b[0]b ccc")

    it "operates on multiple cursors", ->
      EditorState.set(@editor, "aaa b[0]bb c[1]cc ddd")
      AtomicEmacs.killWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa b[0] c[1] ddd")

  describe "atomic-emacs:backward-kill-word", ->
    it "deletes from the cursor to the beginning of the word if inside a word", ->
      EditorState.set(@editor, "aaa bb[0]b ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0]b ccc")

    it "deletes the word behind the cursor if at the end of a word", ->
      EditorState.set(@editor, "aaa bbb[0] ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0] ccc")

    it "deletes the previous word if at the beginning of a word", ->
      EditorState.set(@editor, "aaa bbb [0]ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0]ccc")

    it "deletes the previous word if between words", ->
      EditorState.set(@editor, "aaa bbb [0] ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0] ccc")

    it "does nothing if at the beginning of the buffer", ->
      EditorState.set(@editor, "[0]aaa bbb ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("[0]aaa bbb ccc")

    it "deletes the leading space behind the cursor if at the beginning of the buffer", ->
      EditorState.set(@editor, " [0] aaa bbb ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("[0] aaa bbb ccc")

    it "deletes any selected text", ->
      EditorState.set(@editor, "aaa b(0)b[0]b ccc")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa b[0]b ccc")

    it "operates on multiple cursors", ->
      EditorState.set(@editor, "aaa bb[0]b cc[1]c ddd")
      AtomicEmacs.backwardKillWord(@event)
      expect(EditorState.get(@editor)).toEqual("aaa [0]b [1]c ddd")

  describe "atomic-emacs:just-one-space", ->
    it "replaces all horizontal space around each cursor with one space", ->
      EditorState.set(@editor, "a [0]\tb c [1]\td")
      AtomicEmacs.justOneSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a [0]b c [1]d")

    it "replaces all horizontal space at the beginning of the buffer with one space if in leading space", ->
      EditorState.set(@editor, " [0]\ta")
      AtomicEmacs.justOneSpace(@event)
      expect(EditorState.get(@editor)).toEqual(" [0]a")

    it "replaces all horizontal space at the end of the buffer with one space if in trailing space", ->
      EditorState.set(@editor, "a [0]\t")
      AtomicEmacs.justOneSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a [0]")

    it "replaces all text with one space if the buffer only contains horizontal spaces", ->
      EditorState.set(@editor, " [0]\t")
      AtomicEmacs.justOneSpace(@event)
      expect(EditorState.get(@editor)).toEqual(" [0]")

    it "does not modify the buffer if there is already exactly one space at around the cursor", ->
      EditorState.set(@editor, "a[0]b")
      AtomicEmacs.justOneSpace(@event)
      expect(EditorState.get(@editor)).toEqual("a [0]b")

  describe "atomic_emacs:set-mark", ->
    it "sets and activates the mark of all cursors", ->
      EditorState.set(@editor, "[0].[1]")
      [cursor0, cursor1] = @editor.getCursors()
      AtomicEmacs.setMark(@event)

      expect(AtomicEmacs.Mark.for(cursor0).isActive()).toBe(true)
      point = AtomicEmacs.Mark.for(cursor0).getBufferPosition()
      expect([point.row, point.column]).toEqual([0, 0])

      expect(AtomicEmacs.Mark.for(cursor1).isActive()).toBe(true)
      point = AtomicEmacs.Mark.for(cursor1).getBufferPosition()
      expect([point.row, point.column]).toEqual([0, 1])

  describe "atomic-emacs:keyboard-quit", ->
    it "deactivates all marks", ->
      EditorState.set(@editor, "[0].[1]")
      [mark0, mark1] = (AtomicEmacs.Mark.for(c) for c in @editor.getCursors())
      m.activate() for m in [mark0, mark1]
      AtomicEmacs.keyboardQuit(@event)
      expect(mark0.isActive()).toBe(false)

  describe "atomic-emacs:backward-char", ->
    it "moves the cursor backward one character", ->
      EditorState.set(@editor, "x[0]")
      AtomicEmacs.backwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("[0]x")

    it "does nothing at the start of the buffer", ->
      EditorState.set(@editor, "[0]x")
      AtomicEmacs.backwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("[0]x")

    it "extends an active selection if the mark is set", ->
      EditorState.set(@editor, "ab[0]c")
      AtomicEmacs.setMark(@event)
      AtomicEmacs.backwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]b(0)c")
      AtomicEmacs.backwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("[0]ab(0)c")

  describe "atomic-emacs:forward-char", ->
    it "moves the cursor forward one character", ->
      EditorState.set(@editor, "[0]x")
      AtomicEmacs.forwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("x[0]")

    it "does nothing at the end of the buffer", ->
      EditorState.set(@editor, "x[0]")
      AtomicEmacs.forwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("x[0]")

    it "extends an active selection if the mark is set", ->
      EditorState.set(@editor, "a[0]bc")
      AtomicEmacs.setMark(@event)
      AtomicEmacs.forwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("a(0)b[0]c")
      AtomicEmacs.forwardChar(@event)
      expect(EditorState.get(@editor)).toEqual("a(0)bc[0]")

  describe "atomic-emacs:backward-word", ->
    it "moves all cursors to the beginning of the current word if in a word", ->
      EditorState.set(@editor, "aa b[0]b c[1]c")
      AtomicEmacs.backwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa [0]bb [1]cc")

    it "moves to the beginning of the previous word if between words", ->
      EditorState.set(@editor, "aa bb [0] cc")
      AtomicEmacs.backwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa [0]bb  cc")

    it "moves to the beginning of the previous word if at the start of a word", ->
      EditorState.set(@editor, "aa bb [0]cc")
      AtomicEmacs.backwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa [0]bb cc")

    it "moves to the beginning of the buffer if at the start of the first word", ->
      EditorState.set(@editor, " [0]aa bb")
      AtomicEmacs.backwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("[0] aa bb")

    it "moves to the beginning of the buffer if before the start of the first word", ->
      EditorState.set(@editor, " [0] aa bb")
      AtomicEmacs.backwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("[0]  aa bb")

  describe "atomic-emacs:forward-word", ->
    it "moves all cursors to the end of the current word if in a word", ->
      EditorState.set(@editor, "a[0]a b[1]b cc")
      AtomicEmacs.forwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa[0] bb[1] cc")

    it "moves to the end of the next word if between words", ->
      EditorState.set(@editor, "aa [0] bb cc")
      AtomicEmacs.forwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa  bb[0] cc")

    it "moves to the end of the next word if at the end of a word", ->
      EditorState.set(@editor, "aa[0] bb cc")
      AtomicEmacs.forwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa bb[0] cc")

    it "moves to the end of the buffer if at the end of the last word", ->
      EditorState.set(@editor, "aa bb[0] ")
      AtomicEmacs.forwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa bb [0]")

    it "moves to the end of the buffer if past the end of the last word", ->
      EditorState.set(@editor, "aa bb [0] ")
      AtomicEmacs.forwardWord(@event)
      expect(EditorState.get(@editor)).toEqual("aa bb  [0]")

  describe "atomic-emacs:previous-line", ->
    it "moves the cursor up one line", ->
      EditorState.set(@editor, "ab\na[0]b\n")
      AtomicEmacs.previousLine(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]b\nab\n")

    it "goes to the start of the line if already at the top of the buffer", ->
      EditorState.set(@editor, "x[0]")
      AtomicEmacs.previousLine(@event)
      expect(EditorState.get(@editor)).toEqual("[0]x")

    it "extends an active selection if the mark is set", ->
      EditorState.set(@editor, "ab\nab\na[0]b\n")
      AtomicEmacs.setMark(@event)
      AtomicEmacs.previousLine(@event)
      expect(EditorState.get(@editor)).toEqual("ab\na[0]b\na(0)b\n")
      AtomicEmacs.previousLine(@event)
      expect(EditorState.get(@editor)).toEqual("a[0]b\nab\na(0)b\n")

  describe "atomic-emacs:next-line", ->
    it "moves the cursor down one line", ->
      EditorState.set(@editor, "a[0]b\nab\n")
      AtomicEmacs.nextLine(@event)
      expect(EditorState.get(@editor)).toEqual("ab\na[0]b\n")

    it "goes to the end of the line if already at the bottom of the buffer", ->
      EditorState.set(@editor, "[0]x")
      AtomicEmacs.nextLine(@event)
      expect(EditorState.get(@editor)).toEqual("x[0]")

    it "extends an active selection if the mark is set", ->
      EditorState.set(@editor, "a[0]b\nab\nab\n")
      AtomicEmacs.setMark(@event)
      AtomicEmacs.nextLine(@event)
      expect(EditorState.get(@editor)).toEqual("a(0)b\na[0]b\nab\n")
      AtomicEmacs.nextLine(@event)
      expect(EditorState.get(@editor)).toEqual("a(0)b\nab\na[0]b\n")

  describe "atomic-emacs:backward-paragraph", ->
    it "moves the cursor backwards to an empty line", ->
      EditorState.set(@editor, "aaaaa\n\nbbbbbb")
      @editor.moveCursorToBottom()
      AtomicEmacs.backwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor backwards to a line that only contains spaces", ->
      EditorState.set(@editor, "aaaaa\n                    \nbbbbbb")
      @editor.moveCursorToBottom()
      AtomicEmacs.backwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor backwards to a line that only contains tabs", ->
      EditorState.set(@editor, "aaaaa\n\t\t\t\nbbbbbb")
      @editor.moveCursorToBottom()
      AtomicEmacs.backwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor backwards to a line that only contains whitespaces", ->
      EditorState.set(@editor, "aaaaa\n\t  \t\t    \nbbbbbb")
      @editor.moveCursorToBottom()
      AtomicEmacs.backwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "does nothing when the cursor is at the first line of the buffer", ->
      EditorState.set(@editor, "aaaaa\n\t  \t\t    \nbbbbbb")
      @editor.moveCursorToTop()
      AtomicEmacs.backwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(0)

  describe "atomic-emacs:forward-paragraph", ->
    it "moves the cursor forward to an empty line", ->
      EditorState.set(@editor, "aaaaa\n\nbbbbbb")
      @editor.moveCursorToTop()
      AtomicEmacs.forwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor forward to a line that only contains spaces", ->
      EditorState.set(@editor, "aaaaa\n                    \nbbbbbb")
      @editor.moveCursorToTop()
      AtomicEmacs.forwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor forward to a line that only contains tabs", ->
      EditorState.set(@editor, "aaaaa\n\t\t\t\nbbbbbb")
      @editor.moveCursorToTop()
      AtomicEmacs.forwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "moves the cursor forward to a line that only contains whitespaces", ->
      EditorState.set(@editor, "aaaaa\n\t  \t\t    \nbbbbbb")
      @editor.moveCursorToTop()
      AtomicEmacs.forwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(1)

    it "does nothing when the cursor is at the last line of the buffer", ->
      EditorState.set(@editor, "aaaaa\n\t  \t\t    \nbbbbbb")
      @editor.moveCursorToBottom()
      AtomicEmacs.forwardParagraph(@event)
      expect(@editor.getCursorBufferPosition().row).toEqual(2)

  describe "atomic-emacs:exchange-point-and-mark", ->
    it "exchanges all cursors with their marks", ->
      EditorState.set(@editor, "[0]..[1].")
      for cursor in @editor.getCursors()
        Mark.for(cursor)
        cursor.moveRight()
      AtomicEmacs.exchangePointAndMark(@event)
      expect(EditorState.get(@editor)).toEqual("[0].(0).[1].(1)")
