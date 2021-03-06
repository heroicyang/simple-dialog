class Dialog extends SimpleModule
  @i18n:
    'zh-CN':
      cancel: '取消'
      close: '关闭'
      ok: '确定'
      known: '知道了'
    'en':
      cancel: 'cancel'
      close: 'close'
      ok: 'ok'
      known: 'ok'
  opts:
    content: null
    width: 600
    modal: false
    clickModalRemove: true
    cls: ""
    defaultCls: ""
    showRemoveButton: true
    buttons: ['close']
    focusButton: ".btn:first"
    titleSelector: 'h3:first'
    contentSelector: '.simple-dialog-content'

  @_count: 0

  @_mobile: do ->
    ua = navigator.userAgent
    /Android|webOS|iPhone|iPad|iPod|BlackBerry|Windows Phone/.test ua

  @_tpl:
    dialog: """
      <div class="simple-dialog">
        <div class="simple-dialog-wrapper">
          <div class="simple-dialog-content"></div>
          <div class="simple-dialog-buttons"></div>
        </div>
        <a class="simple-dialog-remove" href="javascript:;">
          <i class="icon-cross"><span>&#10005;</span></i>
        </a>
      <div>
    """

    modal: """
      <div class="simple-dialog-modal"></div>
    """

    button: """
      <button type="button"></button>
    """


  _init: ->
    if @opts.content is null
      throw new Error "[Dialog] - content shouldn't be empty"

    @id = ++ Dialog._count

    Dialog.removeAll()
    @_render()
    @_bind()
    @el.data("dialog", @)
    @refresh()

    if @opts.buttons && @opts.focusButton
      @buttonWrap.find(@opts.focusButton).focus()

  _render: ->
    @el = $(Dialog._tpl.dialog).addClass [@opts.cls, @opts.defaultCls].join(' ')
    @wrapper = @el.find(".simple-dialog-wrapper")
    @removeButton = @el.find(".simple-dialog-remove")
    @contentWrap = @el.find(".simple-dialog-content")
    @buttonWrap = @el.find(".simple-dialog-buttons")

    @el.toggleClass 'simple-dialog-mobile', Dialog._mobile

    @el.css
      width: @opts.width

    @contentWrap.append(@opts.content)

    unless @opts.showRemoveButton
      @removeButton.remove()

    unless @opts.buttons
      @buttonWrap.remove()
      @buttonWrap = null
    else
      for button in @opts.buttons
        if button is "close"
          button =
            callback: =>
              @remove()

        button = $.extend({}, Dialog.defaultButton, button)

        $(Dialog._tpl.button)
          .addClass 'btn'
          .addClass button.cls
          .html button.text
          .on "click", button.callback
          .appendTo @buttonWrap

    @el.appendTo("body")

    if @opts.modal
      @modal = $(Dialog._tpl.modal).appendTo("body")
      @modal.css("cursor", "default") unless @opts.clickModalRemove


  _bind: ->
    @removeButton.on "click.simple-dialog", (e) =>
      e.preventDefault()
      @remove()

    if @modal and @opts.clickModalRemove
      @modal.on "click.simple-dialog", (e) =>
        @remove()

    $(document).on "keydown.simple-dialog-#{@id}", (e) =>
      if e.which is 27
        @remove()

    $(window).on "resize.simple-dialog-#{@id}", (e) =>
      @maxContentHeight = null
      @refresh()


  _unbind: ->
    @removeButton.off(".simple-dialog")
    @modal.off(".simple-dialog") if @modal and @opts.clickModalRemove
    $(document).off(".simple-dialog-#{@id}")
    $(window).off(".simple-dialog-#{@id}")


  _initContentScroll: ->
    @_topShadow ||= do =>
      $('<div class="content-top-shadow" />')
        .appendTo @wrapper

    @_bottomShadow ||= do =>
      $('<div class="content-bottom-shadow" />')
        .appendTo @wrapper

    contentPosition = @contentEl.position()
    contentW = @contentEl.width()
    shadowH = @_bottomShadow.height()
    @_topShadow.css
      width: contentW
      top: contentPosition.top
      left: contentPosition.left
    @_bottomShadow.css
      width: contentW
      top: contentPosition.top + @contentEl.innerHeight() - shadowH
      left: contentPosition.left

    @contentEl.css 'overflow-y': 'auto'
      .css 'position', 'relative'

    scrollHeight = @contentEl[0].scrollHeight
    innerHeight =  @contentEl.innerHeight()
    @contentEl.off 'scroll.simple-dialog'
      .on 'scroll.simple-dialog', (e) =>
        scrollTop = @contentEl.scrollTop()
        topScrolling = scrollTop > 0
        bottomScrolling = scrollHeight - scrollTop - innerHeight > 1
        @wrapper.toggleClass 'top-scrolling', topScrolling
          .toggleClass 'bottom-scrolling', bottomScrolling
      .trigger 'scroll'

  setContent: (content) ->
    @contentWrap.html(content)

    @contentEl = null
    @titleEl = null
    @maxContentHeight = null
    @_topShadow = null
    @_bottomShadow = null

    @refresh()


  remove: ->
    @trigger 'destroy'
    @_unbind()
    @modal.remove() if @modal
    @el.remove()
    $('body').removeClass('simple-dialog-scrollable')


  refresh: ->
    @contentEl ||= @el.find("#{@opts.contentSelector}")
    @titleEl ||= @el.find("#{@opts.titleSelector}")
    @maxContentHeight ||= do =>
      winH = $(window).height()
      dialogMargin = 30 * 2
      dialogPadding = @wrapper.outerHeight() - @wrapper.height()
      titleH = @titleEl.outerHeight(true)
      buttonH = @buttonWrap?.outerHeight(true) || 0
      winH - dialogMargin - dialogPadding - titleH - buttonH

    contentH = @contentEl[0].scrollHeight

    if contentH > @maxContentHeight
      @contentEl.height @maxContentHeight
      $('body').addClass('simple-dialog-scrollable')
      @_initContentScroll()
    else
      @contentEl.height contentH
      $('body').removeClass('simple-dialog-scrollable')
      @wrapper.removeClass('top-scrolling bottom-scrolling')

    @el.css
      marginLeft: - @el.outerWidth() / 2
      marginTop: - @el.outerHeight() / 2


  @removeAll: ->
    $(".simple-dialog").each () ->
      dialog = $(@).data("dialog")
      dialog.remove()


  @defaultButton:
    text: @::_t 'close'
    callback: $.noop


dialog = (opts) ->
  return new Dialog opts

dialog.class = Dialog

dialog.message = (opts) ->
  opts = $.extend({width: 450}, opts, {
    defaultCls: 'simple-dialog-message'
    buttons: [{
      text: Dialog._t 'known'
      callback: (e) ->
        $(e.target).closest(".simple-dialog")
          .data("dialog").remove()
    }]
  })

  return new Dialog opts

dialog.confirm = (opts) ->
  opts = $.extend({
    callback: $.noop
    width: 450
    defaultCls: 'simple-dialog-confirm'
    buttons: [{
      text: Dialog._t 'ok'
      callback: (e) ->
        dialog = $(e.target).closest(".simple-dialog").data("dialog")
        dialog.opts.callback(e, true)
        dialog.remove()
    }, {
      text: Dialog._t 'cancel'
      cls: "btn-link"
      callback: (e) ->
        dialog = $(e.target).closest(".simple-dialog").data("dialog")
        dialog.opts.callback(e, false)
        dialog.remove()
    }]
  }, opts)
  return new Dialog opts

dialog.removeAll = Dialog.removeAll
dialog.setDefaultButton = (opts) ->
  Dialog.defaultButton = opts
