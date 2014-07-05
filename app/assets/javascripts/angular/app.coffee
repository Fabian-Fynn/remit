window.Remit = {}

window.app = angular.module "Remit", [
  "Remit.PreloadedData"
  "ngRoute"
  "ngAnimate"
  "doowb.angular-pusher"
  "ui.gravatar"
  "ipCookie"
  "once"
]

app.run ($rootScope, $location, Settings, preloadedData) ->
  $rootScope.maxRecords = preloadedData.maxRecords
  $rootScope.commits  = Commit.decorate(preloadedData.commits)
  $rootScope.comments = Comment.decorate(preloadedData.comments)

  $rootScope.$on "$routeChangeSuccess", ->
    $rootScope.isOnSettingsPage = $location.path() == "/settings"

  $rootScope.settings = Settings.load
    include_my_comments: false
    include_comments_on_others: true
