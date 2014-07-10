class neo.models.Graph
  constructor: () ->
    @nodeMap = {}
    @relationshipMap = {}

  nodes: ->
    value for own key, value of @nodeMap

  relationships: ->
    value for own key, value of @relationshipMap

  addNodes: (nodes) =>
    for node in nodes
      @nodeMap[node.id] ||= node
    @

  addRelationships: (relationships) =>
    for relationship in relationships
      @relationshipMap[relationship.id] = relationship
    @

  findNode: (id) => @nodeMap[id]

  findRelationship: (id) => @relationshipMap[id]