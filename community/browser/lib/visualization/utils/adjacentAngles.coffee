class neo.utils.adjacentAngles

  findRuns: (angleList, minSeparation) ->

    p = 0
    minStart = 0
    start = 0
    end = 0
    runs = []

    scanForDensePair = ->
      start = p
      end = angleList.wrapIndex(p + 1)
      if end == minStart
        'done'
      else
        p = end
        if tooDense(start, end)
          extendEnd

        else
          scanForDensePair

    extendEnd = ->
      if p == minStart
        'done'

      else if tooDense(start, angleList.wrapIndex(p + 1))
        end = angleList.wrapIndex(p + 1)
        p = end
        extendEnd

      else
        p = start
        extendStart

    extendStart = ->
      candidateStart = angleList.wrapIndex(p - 1)
      if tooDense(candidateStart, end)
        start = candidateStart
        p = start
        minStart = start
        extendStart

      else
        runs.push
          start: start
          end: end
        p = end
        scanForDensePair

    tooDense = (start, end) ->
      run =
        start: start
        end: end
      angleList.angle(run) < angleList.length(run) * minSeparation

    step = scanForDensePair
    while step != 'done'
      step = step()

    runs