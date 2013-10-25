# Licensed under the Apache License. See footer for details.

views = require "./views"

weppls = exports

weppls._ = {}

#-------------------------------------------------------------------------------
weppls.main = ->
    weppls.module = angular.module "app", ["ngRoute"]

    weppls.module.configure ($routeProvider) ->

        $routeProvider.otherwise 
            redirectTo:  "/"

        for controller, [url, html] of routes
            $routeProvider.when url, 
                controller:  controller
                template:    views[html]


#-------------------------------------------------------------------------------
weppls.route = (args) ->
    weppls.error "no arguments" if !args? 

    if typeof args is "string"
        args =
            url: "/#{args}"
            menu: args
            view: args

        args.url = "/" if args.view is "home"

    {url, menu, view} = args

    weppls.error "no url argument"  if !url?
    weppls.error "no menu argument" if !menu?
    weppls.error "no view argument" if !view?

    if !weppls._routeAdded?
        weppls._routeAdded = true
        $routeProvider.otherwise redirectTo: "/"

    $routeProvider.when url,
        controller: view
        template:   views[view]    

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
