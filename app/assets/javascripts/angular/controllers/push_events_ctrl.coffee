app.controller "PushEventsCtrl", ($scope, $window, Pusher) ->

  # We must receive pushes even before you visit (=load) one of the subview
  # controllers (e.g. CommitsCtrl), so it can't be handled there.

  subscribe = (event, cb) ->
    Pusher.subscribe "the_channel", event, cb


  subscribe "commits_updated", (data) ->
    $scope.commits = limitRecords data.commits.concat($scope.commits)

  subscribe "comment_updated", (data) ->
    $scope.comments = limitRecords [ data.comment ].concat($scope.comments)

  subscribe "commit_reviewed", (data) ->
    withCommit data, (commit) ->
      commit.reviewed = true
      commit.reviewer_email = data.reviewer_email

  subscribe "commit_unreviewed", (data) ->
    withCommit data, (commit) ->
      commit.reviewed = false
      commit.reviewer_email = null

  subscribe "app_deployed", (data) ->
    deployed_version = data.version
    our_version = $scope.appVersion
    console.log "Deployed v#{deployed_version}; we've got v#{our_version}"
    if our_version != deployed_version
      $window.location.reload()


  limitRecords = (list) ->
    list.slice(0, $scope.maxRecords)

  withCommit = (data, cb) ->
    for commit in $scope.commits
      if commit.id == data.id
        cb(commit)
        break
