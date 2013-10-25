# Licensed under the Apache License. See footer for details.

path = require "path"

_      = require "underscore"
sh     = require "shelljs"
marked = require "marked"
coffee = require "coffee-script"

pkg = require "../package.json"

weppls = exports

iSubDirs = "views services filters directives".split " "

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

        jFiles[name] = coffee.compile content

    # write the views module
    oFile = path.join oDir, "m", "views.js"

    content = JSON.stringify hFiles, null, 4
    content = "module.exports = #{content}"
    content.to oFile

    # write the controllers
    viewsDir = path.join oDir, "m", "views"

    sh.mkdir "-p", viewsDir
    for name, content of jFiles
        oFile = path.join viewsDir, "#{name}.js"
        content.to oFile

    hFiles = _.keys hFiles
    jFiles = _.keys jFiles

    jFilesMissing = _.difference hFiles, jFiles

    for jFile in jFilesMissing
        oFile = path.join viewsDir, "#{jFile}.js"
        content = "exports.controller = function($scope){/*no-op*/}"
        content.to oFile

    jFilesExtra = _.difference jFiles, hFiles

    for jFile in jFilesExtra
        weppls.log "extraneous module in views: #{jFile}"

    return

#-------------------------------------------------------------------------------
copyResources = (iDir, oDir, options) ->
    subDirs = sh.ls iDir
    subDirs = _.filter subDirs, (subDir) -> sh.test "-d", path.join oDir, subDir
    subDirs = _.filter subDirs, (subDir) -> subDir not in iSubDirs

    for subDir in subDirs
        iSubDir = path.join iDir, subDir
        oSubDir = path.join oDir, subDir

        sh.mkdir "-p", oSubDir
        sh.cp "-R", iSubDir, oSubDir

    return

#-------------------------------------------------------------------------------
createIndexHtml = (iDir, oDir, options) ->

#-------------------------------------------------------------------------------
createIndexScript = (iDir, oDir, options) ->

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
