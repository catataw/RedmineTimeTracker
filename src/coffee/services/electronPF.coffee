angular.module('electron', []).provider 'Platform', () ->

  index = require('electron').remote.require('./scripts/index')
  shell = require('electron').shell
  storage = require('electron-json-storage')

  ###*
   Platform api wrapper for electron app.
   @class Platform
  ###
  class Platform

    # key on storage
    SELECTED_PROJECT: "SELECTED_PROJECT"

    ###*
     @constructor
     @param {Object} $q - Service for Promise.
     @param {Object} $log - Service for Log.
    ###
    constructor: (@$q, @$log) ->
      @_notification = null


    ###*
     Returns platform name.
     @return {string} platform name.
    ###
    getPlatform: () -> return 'electron'


    ###*
     @typedef LoadedObject
     @property {Object} Loaded object.
    ###

    ###*
     Load data from storage area.
     @param {String} key - Key of data.
     @returns {Promise.<LoadedObject>} A promise for result of loading .
    ###
    load: (key) =>
      deferred = @$q.defer()

      storage.get key, (err, local) =>
        if not err?
          @$log.info key + ' loaded.'
          @$log.debug local
          deferred.resolve(local)
        else
          @$log.debug err
          deferred.reject()

      return deferred.promise

    ###*
     Save data to storage area.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    save: (key, value) =>
      deferred = @$q.defer()

      storage.set key, value, (err) =>
        if err?
          @$log.info key + ' failed to save.'
          deferred.reject()
        else
          @$log.info key + ' saved to local.'
          @$log.debug value
          deferred.resolve()

      return deferred.promise

    ###*
     Save data to storage `local` area. Same as `save()`.
     @param {String} key - Key of data.
     @param {Object} value - Value which to be saved.
     @return {Promise.<undefined>} A promise for result of saving.
    ###
    saveLocal: (key, value) =>
      return @save(key, value)

    ###*
     Clear data from storage area.
     @return {Promise.<undefined>} A promise for result.
    ###
    clear: () =>
      deferred = @$q.defer()
      storage.clear (err) ->
        if err?
          deferred.reject()
        else
          deferred.resolve()
      return deferred.promise

    ###*
     Gets the system locale.
     @return {String} language
     {@link http://electron.atom.io/docs/api/locales/}
    ###
    getLanguage: () ->
      lang = require('electron').remote.app.getLocale()
      @$log.debug("Language: " + lang)
      return lang

    ###*
     Show the application window.
    ###
    showAppWindow: () =>
      win = require('electron').remote.getCurrentWindow()
      win.show()

    ###*
     Message which used on type = list.
     @typedef {object} listMessage
     @prop {string} title - list message title.
     @prop {string} message - list message body.
    ###

    ###*
     @typedef {object} NotificationOptions
     @prop {string} icon - Icon's url.
     @prop {string} iconUrl - Alias for icon.
     @prop {string} title - Notification title.
     @prop {listMessage[]} items - messages.
    ###

    ###*
     Creates and displays a notification.
     @param {NotificationOptions} options - Contents of the notification.
    ###
    createNotification: (options) =>
      # options.icon = options.icon or options.iconUrl
      # options.icon = __dirname + "/.." + options.icon
      options.body = ""
      for item in options.items
        options.body += "\n#{item.title}: #{item.message}"
      @_notification = new Notification(options.title, options)

    ###*
     Clears the notification.
    ###
    clearNotification: () =>
      if @_notification?
        @_notification.onclick = undefined
        @_notification.close()
        @_notification = null
      else
        @$log.log("Notification doesn't exist.")

    ###*
     @callback onClickedListener
    ###

    ###*
     Add on clicked lister to notification.
     @param {onClickedListener} listener - be called when the user clicked in a non-button area of the notification.
    ###
    addOnClickedListener: (listener) =>
      if @_notification?
        @_notification.onclick = listener
      else
        @$log.log("Notification doesn't exist.")


    ###*
     Get path.
     @param {string} path - Platform specified path.
    ###
    getPath: (path) ->
      return __dirname + "../../" + path


    ###*
     Open url to external browser application.
     @param {string} url - Url to be opened.
    ###
    openExternalLink: (url) ->
      return @$log.log("Invalid url.") if not url?
      shell.openExternal(url)

    ###*
     Set proxy login event lister.
     @param {function} func - Function which will be called when fired app's 'login' event.
    ###
    setLoginLister: (func) ->
      index.onLogin(func)


  return {
    getLanguage: () -> return require('electron').remote.app.getLocale()
    openDevTools: () -> index.openDevTools()
    $get: ($q, $log) -> return new Platform($q, $log)
  }
