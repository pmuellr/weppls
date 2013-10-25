# Licensed under the Apache License. See footer for details.

path = require "path"

_      = require "underscore"
sh     = require "shelljs"
marked = require "marked"
coffee = require "coffee-script"

pkg = require "../package.json"

weppls = exports

iSubDirs = "views services filters directives".split " "

Program = pkg.name
Version = pkg.version

Verbose = false

#-------------------------------------------------------------------------------
weppls.run = (dir, options={}) ->
    weppls.error "no dir specified" if  !dir?

    if !options.output?
        options.output = "#{dir}-out"

    Verbose = !!options.verbose

    main dir, options

#-------------------------------------------------------------------------------
main = (iDir, options) ->
    oDir = options.output

    weppls.logv "iDir:    #{iDir}"
    weppls.logv "oDir:    #{oDir}"
    weppls.logv "options: #{JSON.stringify options, null, 4}"
    weppls.logv ""

    weppls.log "generating files in #{oDir}"
    sh.mkdir "-p", oDir
    if !sh.test "-d", oDir
        weppls.error "unable to create directory #{oDir}"

    # if !_.isEmpty sh.ls("-RA", oDir)
    sh.rm "-rf", "#{oDir}/*"

    sh.mkdir "-p", path.join(oDir, "m")

    createViews       iDir, oDir, options
    createIndexHtml   iDir, oDir, options
    createIndexScript iDir, oDir, options
    copyResources     iDir, oDir, options

#-------------------------------------------------------------------------------
createViews = (iDir, oDir, options) ->
    iDir = path.join iDir, "views"
    files = sh.ls iDir

    cFiles = {}
    hFiles = {}
    jFiles = {}
    mFiles = {}

    for file in files
        fullFile = path.join iDir, file

        match = file.match /^(.*)\.(.*)$/
        continue unless match

        base = match[1]
        ext  = match[2]

        switch ext
            when "coffee" then cFiles[base] = sh.cat fullFile
            when "html"   then hFiles[base] = sh.cat fullFile
            when "js"     then jFiles[base] = sh.cat fullFile
            when "md"     then mFiles[base] = sh.cat fullFile
            else                             
                weppls.log "ignoring unknown file type in views subdirectory: #{file}"

    marked.setOptions
        gfm:            true
        tables:         true
        breaks:         false
        pedantic:       false
        sanitize:       true
        smartLists:     true
        smartypants:    false

    # compile markdown
    for name, content of mFiles
        if hFiles[name]?
            weppls.log "ignoring view file #{name}.md as there is already an #{name}.html file"
            continue

        hFiles[name] = marked content

    # compile coffeescript 
    for name, content of cFiles
        if jFiles[name]?
            weppls.log "ignoring view file #{name}.coffee as there is already an #{name}.js file"
            continue

        options = 
            bare: true

        jFiles[name] = coffee.compile content, options

    # write the views module
    oFile = path.join oDir, "m", "views.js"

    hNames   = _.keys hFiles
    hNameLen = (_.max hNames, (hName) -> hName.length).length

    content = []
    for name, fileContent of hFiles
        pad = weppls.align.left "", hNameLen - name.length
        content.push "    #{JSON.stringify name}:#{pad} #{JSON.stringify fileContent}"

    content = """
        // generated on #{weppls.getDate()} by #{Program} #{Version}

        module.exports = {
        #{content.join ",\n"}
        };
        """
    content.to oFile

    # write the controllers
    viewsDir = path.join oDir, "m", "views"

    sh.mkdir "-p", viewsDir
    for name, content of jFiles
        oFile = path.join viewsDir, "#{name}.js"
        content.to oFile

    hFiles = _.keys hFiles
    jFiles = _.keys jFiles

    # write missing controllers
    jFilesMissing = _.difference hFiles, jFiles

    for jFile in jFilesMissing
        oFile = path.join viewsDir, "#{jFile}.js"
        content = """
            // generated on #{weppls.getDate()} by #{Program} #{Version}

            exports.controller = function($scope){
                /*no-op*/
            };
        """
        content.to oFile

    # write a missing body controller
    if "body" not in jFiles
        oFile = path.join viewsDir, "body.js"
        content = """
            // generated on #{weppls.getDate()} by #{Program} #{Version}

            exports.controller = function($scope){
                $scope.$on("$routeChangeSuccess", function(next, current) {
                    $(".navbar-collapse").collapse("hide");
                });
            };
        """
        content.to oFile

    # complain about extraneous controllers
    jFilesExtra = _.difference jFiles, hFiles

    for jFile in jFilesExtra
        weppls.log "extraneous module in views: #{jFile}"

    # write controller initializer
    cFiles = hFiles.slice()
    cFiles.unshift "body"

    cFileLen = (_.max cFiles, (cFile) -> cFile.length).length

    content = _.map cFiles, (cFile) ->
        pad = weppls.align.left "", cFileLen - cFile.length

        "    angularModule.controller('#{cFile}'#{pad}, require('./views/#{cFile}'#{pad}).controller);"

    content = """
        // generated on #{weppls.getDate()} by #{Program} #{Version}

        exports.configure = function(angularModule) {
        #{content.join '\n'}
        };
    """

    oFile = path.join oDir, "m", "controllers.js"
    content.to oFile

    # create a default routes module
    content = _.map hFiles, (hFile) ->
        url = "/#{hFile}"
        url = "/" if hFile is "home"

        padH = weppls.align.left "", cFileLen - hFile.length
        padU = weppls.align.left "", cFileLen - url.length + 1

        "        $routeProvider.when('#{url}', #{padU}{controller:'#{hFile}', #{padH}template: views['#{hFile}']});"

    content = """
        // generated on #{weppls.getDate()} by #{Program} #{Version}

        var views = require("./views");

        exports.configure = function(angularModule) {
            angularModule.config(function($routeProvider){
                $routeProvider.otherwise({redirectTo: "/"});

        #{content.join '\n'}
            })

        };
    """

    oFile = path.join oDir, "m", "routes.js"
    content.to oFile

    return

#-------------------------------------------------------------------------------
copyResources = (iDir, oDir, options) ->

    #copy user directories 
    subDirs = sh.ls iDir
    subDirs = _.filter subDirs, (subDir) -> sh.test "-d", path.join iDir, subDir
    subDirs = _.filter subDirs, (subDir) -> subDir not in iSubDirs

    for subDir in subDirs
        iSubDir = path.join iDir, subDir

        sh.cp "-R", iSubDir, oDir

    # copy vendor files
    oSubDir   = path.join oDir, "vendor"
    vendorDir = path.join __dirname, "..", "vendor"

    sh.cp "-R", vendorDir, oDir

    return

#-------------------------------------------------------------------------------
createIndexHtml = (iDir, oDir, options) ->
    iFile = path.join iDir, "index.html"
    bFile = path.join iDir, "body.html"
    mFile = path.join iDir, "menu.html"

    error "index.html file not found in #{iDir}" if !sh.test "-f", iFile
    error "body.html file not found in #{iDir}"  if !sh.test "-f", bFile
    error "menu.html file not found in #{iDir}"  if !sh.test "-f", mFile

    iFile = sh.cat iFile
    bFile = sh.cat bFile
    mFile = sh.cat mFile

    iFile = iFile.replace "{{body}}", bFile
    iFile = iFile.replace "{{menu}}", mFile

    content = """
        #{iFile}

        <!-- generated on #{weppls.getDate()} by #{Program} #{Version} -->
    """

    oFile = path.join oDir, "index.html"
    content.to oFile

#-------------------------------------------------------------------------------
createIndexScript = (iDir, oDir, options) ->
    baseDir = path.join __dirname, ".."

    # copy weppls-rt as main.js
    mainFile = path.join baseDir, "weppls-rt", "lib", "index.js"
    sh.cp mainFile, path.join(oDir, "m", "main.js")

    # run browserify, producing index.js
    mFile = path.join oDir, "m", "main.js"
    oFile = path.join oDir, "index.js"
    browserify = path.join baseDir, "node_modules", ".bin", "browserify"
    cmd = "#{browserify}  #{mFile} --outfile #{oFile} --debug"

    sh.exec cmd

    # run sourcemap splitter
    splitTool = path.join baseDir, "tools", "split-sourcemap-data-url.coffee"
    coffee    = path.join baseDir, "node_modules", ".bin", "coffee"
    cmd = "#{coffee} #{splitTool} #{oFile}"

    sh.exec cmd

#-------------------------------------------------------------------------------
weppls.log = (message) ->
    if !message? or message is ""
        message = ""
    else
        message = "#{pkg.name}: #{message}"

    console.log message
    return

#-------------------------------------------------------------------------------
weppls.logv = (message) ->
    return if !Verbose
    weppls.log message
    return

#-------------------------------------------------------------------------------
weppls.error = (message) ->
    weppls.log message
    process.exit 1
    return

#-------------------------------------------------------------------------------
weppls.getDate = () ->
    date = new Date()

    yr  = date.getFullYear()
    mon = date.getMonth() + 1
    day = date.getDate()
    hr  = date.getHours()
    min = date.getMinutes()
    sec = date.getSeconds()
    ms  = date.getMilliseconds()

    mon = weppls.align.right "#{mon}" , 2, 0
    day = weppls.align.right "#{day}" , 2, 0
    hr  = weppls.align.right "#{hr }" , 2, 0
    min = weppls.align.right "#{min}" , 2, 0
    sec = weppls.align.right "#{sec}" , 2, 0

    result = "#{yr}-#{mon}-#{day} #{hr}:#{min}:#{sec}"
    return result

#-------------------------------------------------------------------------------
weppls.align = (s, dir, len, pad=" ") ->
    switch dir[0]
        when "l" then add = (s) -> "#{s}#{pad}"
        when "r" then add = (s) -> "#{pad}#{s}"
        else throw Error "invalid dir argument to align: #{dir}"

    s   = "#{s}"
    pad = "#{pad}"
    while s.length < len
        s = add s

    return s

#-------------------------------------------------------------------------------
weppls.align.left  = (s, len, pad=" ") -> weppls.align s, "left",  len, pad
weppls.align.right = (s, len, pad=" ") -> weppls.align s, "right", len, pad

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
