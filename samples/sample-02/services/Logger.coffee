exports.service = class Logger

    #---------------------------------------------------------------------------
    constructor: () ->
        @_verbose  = false
        @_messages = []

    #---------------------------------------------------------------------------
    getMessages: () ->
        return @_messages

    #---------------------------------------------------------------------------
    verbose: (value) ->
        return @_verbose if !value? 

        @_verbose = !!value
        return @_verbose

    #---------------------------------------------------------------------------
    log: (text) ->
        date = new Date
        @_messages.push {date, text}

        return

    #---------------------------------------------------------------------------
    vlog: (text) ->
        return unless @_verbose

        log text
        return

    #---------------------------------------------------------------------------
    clear: ->
        @_messages.splice 0, @_messages.length
