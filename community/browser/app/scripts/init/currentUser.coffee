angular.module('neo4jApp')
.run [
  'Login'
  '$rootScope'
  (Login, $rootScope) ->
    $rootScope.$on 'user:authenticated', (evt, authenticated) ->
      if authenticated
        Login.ajax('/api/v1/me')
        .then(
          (data) ->
            $rootScope.currentUser = data
        ,
          ->
            $rootScope.currentUser = undefined
        )
      else
        $rootScope.currentUser = undefined

]
