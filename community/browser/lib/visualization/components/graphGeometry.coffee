class NeoD3Geometry
  square = (distance) -> distance * distance

  constructor: (@style) ->

  addShortenedNextWord = (line, word, measure) ->
    until word.length <= 2
      word = word.substr(0, word.length - 2) + '\u2026'
      if measure(word) < line.remainingWidth
        line.text += " " + word
        break

  noEmptyLines = (lines) ->
    for line in lines
      if line.text.length is 0 then return false
    true

  fitCaptionIntoCircle = (node, style) ->
    template = style.forNode(node).get("caption")
    captionText = style.interpolate(template, node.id, node.propertyMap)
    fontFamily = 'sans-serif'
    fontSize = parseFloat(style.forNode(node).get('font-size'))
    lineHeight = fontSize
    measure = (text) ->
      neo.utils.measureText(text, fontFamily, fontSize)

    words = captionText.split(" ")

    emptyLine = (lineCount, iLine) ->
      baseline = (1 + iLine - lineCount / 2) * lineHeight
      constainingHeight = if iLine < lineCount / 2 then baseline - lineHeight else baseline
      lineWidth = Math.sqrt(square(node.radius) - square(constainingHeight)) * 2
      {
      node: node
      text: ''
      baseline: baseline
      remainingWidth: lineWidth
      }

    fitOnFixedNumberOfLines = (lineCount) ->
      lines = []
      iWord = 0;
      for iLine in [0..lineCount - 1]
        line = emptyLine(lineCount, iLine)
        while iWord < words.length and measure(" " + words[iWord]) < line.remainingWidth
          line.text += " " + words[iWord]
          line.remainingWidth -= measure(" " + words[iWord])
          iWord++
        lines.push line
      if iWord < words.length
        addShortenedNextWord(lines[lineCount - 1], words[iWord], measure)
      [lines, iWord]

    consumedWords = 0
    maxLines = node.radius * 2 / fontSize

    lines = [emptyLine(1, 0)]
    for lineCount in [1..maxLines]
      [candidateLines, candidateWords] = fitOnFixedNumberOfLines(lineCount)
      if noEmptyLines(candidateLines)
        [lines, consumedWords] = [candidateLines, candidateWords]
      if consumedWords >= words.length
        return lines
    lines

  formatNodeCaptions: (nodes) ->
      for node in nodes
        node.caption = fitCaptionIntoCircle(node, @style)

  measureRelationshipCaption: (relationship, caption) ->
    fontFamily = 'sans-serif'
    fontSize = parseFloat(@style.forRelationship(relationship).get('font-size'))
    padding = parseFloat(@style.forRelationship(relationship).get('padding'))
    neo.utils.measureText(caption, fontFamily, fontSize) + padding * 2

  captionFitsInsideArrowShaftWidth: (relationship) ->
    parseFloat(@style.forRelationship(relationship).get('shaft-width')) >
    parseFloat(@style.forRelationship(relationship).get('font-size'))

  measureRelationshipCaptions: (relationships) ->
    for relationship in relationships
      relationship.captionLength = @measureRelationshipCaption(relationship, relationship.type)
      relationship.captionLayout =
        if @captionFitsInsideArrowShaftWidth(relationship)
          "internal"
        else
          "external"

  shortenCaption: (relationship, caption, targetWidth) ->
    shortCaption = caption
    while true
      if shortCaption.length <= 2
        return ['', 0]
      shortCaption = shortCaption.substr(0, shortCaption.length - 2) + '\u2026'
      width = @measureRelationshipCaption(relationship, shortCaption)
      if width < targetWidth
        return [shortCaption, width]

  layoutRelationships: (graph) ->
    for relationship in graph.relationships()
      dx = relationship.target.x - relationship.source.x
      dy = relationship.target.y - relationship.source.y
      relationship.naturalAngle = ((Math.atan2(dy, dx) / Math.PI * 180) + 180) % 360
      delete relationship.arrow

    sortedNodes = graph.nodes().sort((a, b) ->
        b.relationshipCount(graph) - a.relationshipCount(graph))

    for node in sortedNodes
      relationships = graph.relationships().filter((relationship) ->
        relationship.source == node or relationship.target == node
      )
      arrowAngles = { floating: {}, fixed: {} }
      relationshipMap = {}
      for relationship in relationships
        relationshipMap[relationship.id] = relationship

        if node == relationship.source
          if relationship.hasOwnProperty('arrow')
            arrowAngles.fixed[relationship.id] = relationship.naturalAngle + relationship.arrow.deflection
          else
            arrowAngles.floating[relationship.id] = relationship.naturalAngle
        if node == relationship.target
          if relationship.hasOwnProperty('arrow')
            arrowAngles.fixed[relationship.id] = (relationship.naturalAngle - relationship.arrow.deflection + 180) % 360
          else
            arrowAngles.floating[relationship.id] = (relationship.naturalAngle + 180) % 360

      distributedAngles = {}
      for id, angle of arrowAngles.floating
        distributedAngles[id] = angle
      for id, angle of arrowAngles.fixed
        distributedAngles[id] = angle

      if (relationships.length > 1)
        distributedAngles = neo.utils.distributeCircular(arrowAngles, 30)

      for id, angle of distributedAngles
        relationship = relationshipMap[id]
        if not relationship.hasOwnProperty('arrow')
          deflection = if node == relationship.source
            angle - relationship.naturalAngle
          else
            (relationship.naturalAngle - angle + 180) % 360

          shaftRadius = (parseFloat(@style.forRelationship(relationship).get('shaft-width')) / 2) or 2
          headRadius = shaftRadius + 3
          headHeight = headRadius * 2

          dx = relationship.target.x - relationship.source.x
          dy = relationship.target.y - relationship.source.y

          square = (distance) -> distance * distance
          centreDistance = Math.sqrt(square(dx) + square(dy))

          if Math.abs(deflection) < Math.PI / 180
            relationship.arrow = new neo.utils.straightArrow(
                relationship.source.radius,
                relationship.target.radius,
                centreDistance,
                shaftRadius,
                headRadius,
                headHeight,
                relationship.captionLayout
            )
          else
            relationship.arrow = new neo.utils.arcArrow(
                relationship.source.radius,
                relationship.target.radius,
                centreDistance,
                deflection,
                shaftRadius * 2,
                headRadius * 2,
                headHeight,
                relationship.captionLayout
            )

          [relationship.shortCaption, relationship.arrow.shortCaptionLength] = if relationship.arrow.shaftLength > relationship.captionLength
            [relationship.type, relationship.captionLength]
          else
            @shortenCaption(relationship, relationship.type, relationship.arrow.shaftLength)

  setNodeRadii: (nodes) ->
    for node in nodes
      node.radius = parseFloat(@style.forNode(node).get("diameter")) / 2

  onGraphChange: (graph) ->
    @setNodeRadii(graph.nodes())
    @formatNodeCaptions(graph.nodes())
    @measureRelationshipCaptions(graph.relationships())

  onTick: (graph) ->
    @layoutRelationships(graph)
