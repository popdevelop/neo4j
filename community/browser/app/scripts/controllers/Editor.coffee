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
# TODO: maybe skip this controller and provide global access somewhere?
angular.module('neo4jApp.controllers')
  .controller 'EditorCtrl', [
    '$scope'
    'Editor'
    'motdService'
    'Utils'
    'Settings'
    ($scope, Editor, motdService, Utils, Settings) ->
      $scope.editor = Editor
      $scope.motd = motdService
      $scope.settings = Settings
      $scope.editorHasContent = no

      # FIXME:
      # This is a remedy for the "flashing" buttons bug.
      # For some reason the editor content is reset for each keypress
      # before the new content is set by Codemirror
      $scope.$watch 'editor.content', Utils.debounce((val, val2) ->
        $scope.editorHasContent = !!val
      , 100)
      $scope.star = ->
        unless Editor.document
          $scope.toggleDrawer("scripts", true)
        Editor.saveDocument()
  ]
