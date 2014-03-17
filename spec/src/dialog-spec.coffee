describe "dialog", ->
  it "should see dialog if everything is ok", ->
    dialog = simple.dialog
      content: "hello world"

    expect($("body > .simple-dialog").length).toBe(1)


  it "should see throw error if no content", ->
    expect(simple.dialog).toThrow()


  it "should exsit only one dialog at same time", ->
    dialog1 = simple.dialog
      cls: "dialog-1"
      content: "hello"

    dialog2 = simple.dialog
      cls: "dialog-2"
      content: "hello"

    expect($(".dialog-1").length).toBe(0)
    expect($(".dialog-2").length).toBe(1)
    expect($(".simple-dialog").length).toBe(1)


  it "should remove when click remove button", ->
    dialog = simple.dialog
      content: "hello"

    dialog.el.find(".simple-dialog-remove").click()
    expect($(".simple-dialog").length).toBe(0)


  it "should remove when click modal", ->
    dialog = simple.dialog
      modal: true
      content: "hello"

    modal = $(".simple-dialog-modal")
    expect(modal.length).toBe(1)
    modal.click()
    expect($(".simple-dialog-modal").length).toBe(0)


  it "should remove when click the button created by config [close]", ->
    dialog = simple.dialog
      modal: true
      buttons: ["close"]
      content: "hello"

    dialog.el.find("button").click()
    expect($(".simple-dialog").length).toBe(0)


  it "should remove when call simple.dialog.removeAll", ->
    dialog = simple.dialog
      content: "hello"

    simple.dialog.removeAll()
    expect($(".simple-dialog").length).toBe(0)


  it "should change default class when set defaultButton", ->
    simple.dialog.setDefaultButton
      content: "tinyfive"
      cls: "tinyfive"

    dialog = simple.dialog
      content: "hello"
      buttons: [{
        test: 1
      }]

    button = dialog.buttonWrap.find('button')

    expect(button.html()).toEqual("tinyfive")
    expect(button.attr('class')).toEqual("tinyfive")


  it "should remove when ESC keydown", ->
    dialog = simple.dialog
      content: "hello"

    esc = $.Event "keydown.simple-dialog", which: 27
    $(document).trigger(esc)
    expect($(".simple-dialog").length).toBe(0)


  it "should change position and height when content change and refresh", ->
    dialog = simple.dialog
      content: "hello"

    oTop = dialog.el.css("marginTop")
    oHeight = dialog.el.outerHeight()

    content = "<p>1</p><p>1</p><p>1</p><p>1</p><p>1</p>"
    dialog.setContent(content)

    nTop = dialog.el.css("marginTop")
    nHeight = dialog.el.outerHeight()

    expect(oTop).not.toEqual(nTop)
    expect(oHeight).not.toEqual(nHeight)


describe "message", ->
  it "should see only one button called 知道了", ->
    message = simple.message
      content: "hello"
      buttons: [{
        content: "yes"
      }, {
        content: "no"
      }]

    button = message.el.find("button")
    expect(button.length).toBe(1)
    expect(button.html()).toEqual("知道了")
