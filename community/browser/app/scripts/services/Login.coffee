###!
Copyright (c) 2002-2014 "Neo Technology,"
Network Engine for Objects in Lund AB [http://neotechnology.com]

This file is part of Neo4j.

Neo4j is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

'use strict';

angular.module('neo4jApp.services')
.factory 'Login', [
  'Settings'
  (Settings) ->
    iframe = angular.element('<iframe>')
    .attr('name', 'neo4jLogin')
    .attr('allowtransparency', true)
    .attr('seamless', true)
    .css(
      'background-color': 'rgba(0, 0, 0, 0)'
      border: '0px none rgba(0, 0, 0, 0)'
      overflow: 'hidden'
      visibility: 'visible'
      margin: '0px'
      padding: '0px'
      '-webkit-tap-highlight-color': 'transparent'
      position: 'fixed'
      left: '0px'
      top: '0px'
      width: '100%'
      height: '100%'
      'z-index': '9999'
      display: 'none'
    )
    .insertAfter('body')

    # Recieve messages from the login frame
    #pm.bind 'ready', (data) ->
    #  console.log alert('ready')

    pm.bind 'close', ->
      iframe.removeAttr('src').hide()

    {
      open: ->
        iframe.attr('src', Settings.endpoint.login).show()
      close: ->
        iframe.removeAttr('src').hide()
    }
]
