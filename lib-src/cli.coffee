# Licensed under the Apache License. See footer for details.

path = require "path"

_    = require "underscore"
nopt = require "nopt"

pkg    = require "../package.json"
weppls = require "./weppls"


cli = exports

#-------------------------------------------------------------------------------
cli.main = (args) ->
    help() if args.length is 0 
    help() if args[0] in ["?", "-?", "--?"]

    longOpts =
        output:  path
        verbose: Boolean
        help:    Boolean

    shortOpts = 
        o: "--output"
        v: "--verbose"
        h: "--help"

    parsed = nopt longOpts, shortOpts, args, 0

    help() if parsed.help

    args = parsed.argv.remain
    opts = _.pick parsed, _.keys longOpts

    help() if args.length is 0 
    
    weppls.run args[0], opts

    return

#-------------------------------------------------------------------------------
help = ->
    console.log "#{pkg.name} [options] directory"
    console.log ""
    console.log "directory is a directory of files to weppl-ize"
    console.log ""
    console.log "options:"
    console.log ""
    console.log "-o --output      output directory"
    console.log "-v --verbose     be verbose"
    console.log ""
    console.log "If you don't specify an output directory, an output directory"
    console.log "of <directory>-out willl be used."
    console.log ""
    console.log "version: #{pkg.version}; for more info: #{pkg.homepage}"

    process.exit 1

#-------------------------------------------------------------------------------
cli.main.call null, (process.argv.slice 2) if require.main is module


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
