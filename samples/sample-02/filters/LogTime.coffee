exports.filter = ->
    (date) -> 
        hh = right "#{date.getHours()}",   2, 0
        mm = right "#{date.getMinutes()}", 2, 0
        ss = right "#{date.getSeconds()}", 2, 0
        return "#{hh}:#{mm}:#{ss}"

#-------------------------------------------------------------------------------
right = (string, len, pad) ->
    while string.length < len
        string = "#{pad}#{string}"
    return string
