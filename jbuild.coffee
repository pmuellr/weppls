# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

path          = require "path"
child_process = require "child_process"

bower_files   = require "./bower-files"

mkdir "-p", "tmp"
pidFile = "tmp/server.pid"

# base name of this file, for watch()
__basename    = path.basename __filename

exports.build =
    doc: "run a build against the source files"
    run: -> taskBuild()

exports.test =
    doc: "test the build"
    run: -> taskTest()

exports.watch =
    doc: "watch for source file changes, then rebuild"
    run: -> taskWatch()

exports.vendor =
    doc: "get vendor files"
    run: -> taskVendor()

exports.serve =
    doc: "run serve on this directory at port 3005"
    run: -> taskServe()

#-------------------------------------------------------------------------------
taskServe = ->
    server.kill pidFile, ->
        server.start pidFile, "node_modules/.bin/serve", "-p 3005".split(" ")

#-------------------------------------------------------------------------------
taskBuild = ->
    coffeec "lib-src",       "lib"
    coffeec "weppls-rt/src", "weppls-rt/lib"

#-------------------------------------------------------------------------------
taskTest = ->
    samples = [ "01" ]

    for sample in samples
        cmd = """
            node bin/weppls.js 
                --verbose 
                --output tmp/sample-#{sample} 
                samples/sample-#{sample}
        """.replace /\s+/g, " "

        log "running #{cmd}"
        exec cmd

#-------------------------------------------------------------------------------
taskWatch =  ->
    buildNtest()

    # watch for changes to sources, run a build
    watch
        files: ["lib-src/**/*", "weppls-rt/src/**/*", "samples/**/*"]
        run: -> 
            buildNtest()

    # watch for changes to this file, then exit
    watch
        files: __basename
        run: -> 
            log "file #{__basename} changed; exiting"
            process.exit 0

#-------------------------------------------------------------------------------
taskVendor =  ->
    bower = which "bower"
    unless bower
        bower = "./node_modules/.bin/bower"

        unless test "-f", bower
            log grunt, "installing bower locally since it's not installed globally"
            exec "npm install bower"
            log grunt, ""

    mkdir "-p", "vendor"
    rm "-rf",   "vendor/*"

    for pkgName, pkgSpec of bower_files
        exec "#{bower} install #{pkgName}##{pkgSpec.version}"

        for srcFile, dstDir of pkgSpec.files
            mkdir "-p", dstDir
            srcFile = path.join "bower_components", pkgName, srcFile
            cp srcFile, dstDir

#-------------------------------------------------------------------------------
buildNtest =  ->
    taskBuild()
    process.nextTick ->
        taskTest()
        taskServe()

#-------------------------------------------------------------------------------
coffeec = (src, out) -> 
    log "compiling #{src}/*.coffee to #{out}"

    mkdir "-p", "#{out}"
    rm          "#{out}/*"

    coffee "--compile --bare --output #{out} #{src}/*.coffee"

#-------------------------------------------------------------------------------
coffee = (cmd) -> 
    pexec "coffee #{cmd}"

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
