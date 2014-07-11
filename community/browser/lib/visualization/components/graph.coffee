class neo.models.Graph
  constructor: () ->
    @nodeMap = {}
    @_nodes = []
    @relationshipMap = {}
    @_relationships = []

  nodes: ->
    @_nodes

  relationships: ->
    @_relationships

  addNodes: (nodes) =>
    for node in nodes
      if (@_nodes.indexOf(node) < 0)
        @_nodes.push(node)
      @nodeMap[node.id] ||= node
    @

  addRelationships: (relationships) =>
    for relationship in relationships
      if (@_relationships.indexOf(relationship) < 0)
        @_relationships.push(relationship)
      @relationshipMap[relationship.id] = relationship
    @

  findNode: (id) => @nodeMap[id]

  findRelationship: (id) => @relationshipMap[id]
