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

angular.module('neo4jApp')
  .controller 'LegendCtrl', ['$scope', 'Frame', 'GraphStyle', ($scope, resultFrame, graphStyle) ->

    $scope.graph = null

    graphStats = (graph) ->
      resultLabels = {}
      resultRelTypes = {}
      stats = {
        labels: {}
        types: {}
      }
      for node in graph.nodes()
        if node.labels?.length is 0
          stats.labels[''] ?= { count: 0, style: graphStyle.forNode(node) }
          stats.labels[''].count++
          continue
        for label in node.labels
          stats.labels[label] ?= { count: 0, style: graphStyle.forNode(node) }
          stats.labels[label].count++
      for rel in graph.relationships()
        stats.types[rel.type] ?= { count: 0, style: graphStyle.forRelationship(rel) }
        stats.types[rel.type].count++

      stats

    update = (graph) ->
      stats = graphStats(graph)
      #for rule in graphStyle.rules
      #  if stats.labels.hasOwnProperty(rule.selector.klass)
      #    resultRules.push(rule)
      #$scope.rules = resultRules
      $scope.labels = stats.labels
      $scope.types = stats.types

    $scope.$watch 'frame.response', (frameResponse) ->
      return unless frameResponse
      if frameResponse.graph
        $scope.graph = frameResponse.graph
        update(frameResponse.graph)

    graphChanged = (event, graph) ->
      if graph is $scope.graph
        update(graph)

    $scope.$on 'graph:changed', graphChanged

    $scope.rules = []

    $scope.isNode = (rule) ->
      rule.selector.tag == 'node'

    $scope.remove = (rule) ->
      graphStyle.destroyRule(rule)

  ]
