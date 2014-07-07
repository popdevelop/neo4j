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

'use strict'

angular.module('neo4jApp.controllers')
  .service('InspectorService', [->
    item: null
    type: null
    visible: null
  ])
  .controller 'InspectorCtrl', [
    '$scope',
    'GraphStyle'
    'InspectorService'
    ($scope, graphStyle, Inspector) ->
      $scope.sizes = graphStyle.defaultSizes()
      $scope.arrowWidths = graphStyle.defaultArrayWidths()
      $scope.colors = graphStyle.defaultColors()

      $scope.Inspector = Inspector
      $scope.$watch 'Inspector.item', () ->
        {item, type} = Inspector
        return unless item and type
        $scope.item = item
        $scope.itemTmpl = "inspector/#{type}.html"

      $scope.close = -> Inspector.visible = no

      $scope.toggleInspector = ->
        Inspector.visible = !Inspector.visible

      $scope.selectArrowWidth = (selector, size) ->
        $scope.item.style = graphStyle.changeForSelector(selector, size )

      $scope.selectCaption = (selector, caption) ->
        $scope.item.style = graphStyle.changeForSelector(selector, { caption: '{' + caption + '}'})

      $scope.selectScheme = (selector, scheme) ->
        $scope.item.style = graphStyle.changeForSelector(selector, angular.copy(scheme))

      $scope.selectSize = (selector, size) ->
        $scope.item.style = graphStyle.changeForSelector(selector, size)

      arrowDisplayWidths = ("#{5 + 3*i}px" for i in [0..10])
      $scope.arrowDisplayWidth = (idx) ->
        width: arrowDisplayWidths[idx]

      nodeDisplaySizes = ("#{15 + 5*i}px" for i in [0..10])
      $scope.nodeDisplaySize = (idx) ->
        width: nodeDisplaySizes[idx]
        height: nodeDisplaySizes[idx]

  ]
