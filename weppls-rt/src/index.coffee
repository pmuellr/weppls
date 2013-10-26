# Licensed under the Apache License. See footer for details.

controllers = require "./controllers"
services    = require "./services"
filters     = require "./filters"
routes      = require "./routes"

weppls = exports

#-------------------------------------------------------------------------------
weppls.main = ->
    angularModule = angular.module "app", []

    controllers.configure angularModule
    services.configure    angularModule
    filters.configure     angularModule
    routes.configure      angularModule

    $ -> onLoad()

    # angularModule.config ($rootScope) ->
    #     $rootScope.$on "$routeChangeStart", (next, current) ->
    #         $(".navbar-collapse").collapse "hide"

#-------------------------------------------------------------------------------
onLoad = ->
    $(".nav.navbar-nav").click ->
        $(".navbar-collapse").collapse "hide"

#-------------------------------------------------------------------------------
weppls.log = (message) ->
    console.log "weppls: #{message}"

#-------------------------------------------------------------------------------
weppls.error = (message) ->
    weppls.log message
    throw Error message

#-------------------------------------------------------------------------------
weppls.main()

#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
