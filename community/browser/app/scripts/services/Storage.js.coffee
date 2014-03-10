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
.service 'Storage', ['$q', 'localStorageService', ($q, localStorageService) ->

  # TODO: implement authentication service to determine if we are connected to NTN
  online = no

  lsAdapter =
    get: ->
      dfd = $q.defer()
      data = localStorageService.get.apply(null, arguments)
      dfd.resolve(data)
      dfd.promise
    add: ->
      dfd = $q.defer()
      localStorageService.add.apply(null, arguments)
      dfd.resolve()
      dfd.promise

  ntnAdapter =
    get: (key) ->
      dfd = $q.defer()
      dfd.resolve(data)
      dfd.promise

    add: (key, value) ->
      dfd = $q.defer()
      dfd.resolve()
      dfd.promise

  get: -> (if online then ntnAdapter else lsAdapter).get.apply null, arguments
  add: -> (if online then ntnAdapter else lsAdapter).add.apply null, arguments
]
