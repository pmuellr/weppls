exports.controller = ($scope, Logger) ->
    Logger.log "created body controller"

    $scope.messages = Logger.getMessages()

    subTitle = ""

    $scope.getSubtitle = -> 
        return "" if subTitle is ""
        return ": #{subTitle}"

    $scope.setSubtitle = (s) -> 
        subTitle = s
