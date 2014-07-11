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
  .controller('D3GraphCtrl', [
    '$attrs'
    '$element'
    '$parse'
    '$window'
    '$rootScope'
    '$scope'
    'CircularLayout'
    'GraphExplorer'
    'GraphStyle'
    'CypherGraphModel'
    ($attrs, $element, $parse, $window, $rootScope, $scope, CircularLayout, GraphExplorer, GraphStyle, CypherGraphModel) ->

      measureSize = ->
        width: $element.width()
        height: $element.height()

      itemMouseOver = (item) ->
        if $attrs.onItemMouseOver
          exp = $parse($attrs.onItemMouseOver)
          $scope.$apply(->exp($scope, {'$item': item }))

      itemMouseOut = (item) ->
        if $attrs.onItemMouseOut
          exp = $parse($attrs.onItemMouseOut)
          $scope.$apply(->exp($scope, {'$item': item }))

      @render = (initialGraph) ->
        graph = initialGraph
        return if graph.nodes().length is 0
        GraphExplorer.internalRelationships(graph.nodes())
        .then (result) =>
          graph.addRelationships(result.relationships.map(CypherGraphModel.convertRelationship(graph)))

          graphView = new neo.graphView($element[0], measureSize, graph, GraphStyle)

          $scope.style = GraphStyle.rules
          $scope.$watch 'style', (val) =>
            return unless val
            graphView.update()
          , true

          selectedItem = null

          selectItem = (item) ->
            if $attrs.onItemClick
              exp = $parse($attrs.onItemClick)
              $scope.$apply(->exp($scope, {'$item': item }))

          toggleSelection = (d) =>
            if d is selectedItem
              d.selected = no
              selectedItem = null
            else
              selectedItem?.selected = no
              d.selected = yes
              selectedItem = d

            graphView.update()
            selectItem(selectedItem)

          graphView
          .on('nodeClicked', (d) ->
              d.fixed = yes
              toggleSelection(d)
            )
          .on('nodeDblClicked', (d) ->
              return if d.expanded
              GraphExplorer.exploreNeighboursWithInternalRelationships(d, graph)
              .then(
                    # Success
                  () =>
                    linkDistance = 60
                    CircularLayout.layout(graph.nodes(), d, linkDistance)
                    d.expanded = yes
                    graphView.update()
                ,
                    # Error
                  (msg) ->
                    # Too many neighbours
                    alert(msg)
                )
              # New in Angular 1.1.5
              # https://github.com/angular/angular.js/issues/2371
              $rootScope.$apply() unless $rootScope.$$phase
            )
          .on('relationshipClicked', (d) ->
              toggleSelection(d)
            )
          .on('nodeMouseOver', itemMouseOver)
          .on('nodeMouseOut', itemMouseOut)

          graphView.resize()
          $rootScope.$on 'layout.changed', (-> graphView.resize())
          $rootScope.$broadcast 'graph:changed', graph

      return @
  ])
