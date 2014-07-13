neo.viz = (el, measureSize, graph, layout, style) ->
  viz =
    style: style
    size: measureSize()

  el = d3.select(el)
  geometry = new NeoD3Geometry(style)

  # To be overridden
  viz.trigger = (event, args...) ->

  onNodeClick = (node) => viz.trigger('nodeClicked', node)

  onNodeDblClick = (node) => viz.trigger('nodeDblClicked', node)

  onRelationshipClick = (relationship) =>
    viz.trigger('relationshipClicked', relationship)

  onNodeMouseOver = (node) -> viz.trigger('nodeMouseOver', node)
  onNodeMouseOut = (node) -> viz.trigger('nodeMouseOut', node)

  onRelMouseOver = (rel) -> viz.trigger('relMouseOver', rel)
  onRelMouseOut = (rel) -> viz.trigger('relMouseOut', rel)

  render = ->
    geometry.onTick(graph)

    nodeGroups = el.selectAll('g.node')
    .attr('transform', (d) ->
          "translate(#{ d.x },#{ d.y })")

    for renderer in neo.renderers.node
      nodeGroups.call(renderer.onTick, viz)

    relationshipGroups = el.selectAll('g.relationship')
    .attr('transform', (d) ->
          "translate(#{ d.source.x } #{ d.source.y }) rotate(#{ d.naturalAngle + 180 })")

    for renderer in neo.renderers.relationship
      relationshipGroups.call(renderer.onTick, viz)

  force = layout.init(render)

  viz.update = ->
    return unless graph

    layers = el.selectAll("g.layer").data(["relationships", "nodes"])

    # Background click event
    el.on('click', ->
      viz.trigger('canvasClicked', el)
    )

    layers.enter().append("g")
    .attr("class", (d) -> "layer " + d )

    nodes         = graph.nodes()
    relationships = graph.relationships()

    relationshipGroups = el.select("g.layer.relationships")
    .selectAll("g.relationship").data(relationships, (d) -> d.id)

    relationshipGroups.enter().append("g")
    .attr("class", "relationship")
    .on("click", onRelationshipClick)
    .on('mouseover', onRelMouseOver)
    .on('mouseout', onRelMouseOut)

    geometry.onGraphChange(graph)

    for renderer in neo.renderers.relationship
      relationshipGroups.call(renderer.onGraphChange, viz)

    relationshipGroups.exit().remove();

    nodeGroups = el.select("g.layer.nodes")
    .selectAll("g.node").data(nodes, (d) -> d.id)

    nodeGroups.enter().append("g")
    .attr("class", "node")
    .call(force.drag)
    .call(clickHandler)
    .on('mouseover', onNodeMouseOver)
    .on('mouseout', onNodeMouseOut)

    for renderer in neo.renderers.node
      nodeGroups.call(renderer.onGraphChange, viz);

    nodeGroups.exit().remove();

    force.update(graph, [viz.size.width, viz.size.height])

  viz.resize = ->
    newSize = measureSize()
    unless newSize.width == viz.size.width and newSize.height = viz.size.height
      viz.size = newSize
      force.update(graph, [viz.size.width, viz.size.height])

  clickHandler = neo.utils.clickHandler()
  clickHandler.on 'click', onNodeClick
  clickHandler.on 'dblclick', onNodeDblClick

  viz
