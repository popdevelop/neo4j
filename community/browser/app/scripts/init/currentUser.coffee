angular.module('neo4jApp')
.run [
  'Login'
  'localStorageService'
  '$rootScope'
  (Login, localStorageService, $rootScope) ->


    # Sync local storage to the cloud
    sync = ->
      keys = localStorageService.keys()
      d = {}
      d[k] = localStorageService.get(k) for k in keys

      Login.ajax({
        contentType: 'application/json'
        method: 'PUT'
        url: '/api/v1/store'
        data: JSON.stringify(d)
      }).then((d)->
        console.log d
      )

    $rootScope.$on 'user:authenticated', (evt, authenticated) ->
      if authenticated
        Login.ajax('/api/v1/me')
        .then(
          (data) ->
            $rootScope.currentUser = data
            sync()
        ,
          ->
            $rootScope.currentUser = undefined
        )
      else
        $rootScope.currentUser = undefined

]
