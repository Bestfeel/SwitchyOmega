angular.module('omega').controller 'IoCtrl', ($scope, $rootScope,
  $window, omegaTarget) ->

  $scope.exportOptions = ->
    $rootScope.applyOptionsConfirm().then ->
      plainOptions = angular.fromJson(angular.toJson($rootScope.options))
      content = JSON.stringify(plainOptions)
      blob = new Blob [content], {type: "text/plain;charset=utf-8"}
      saveAs(blob, "OmegaOptions.bak")

  $scope.importSuccess = ->
    $rootScope.showAlert(
      type: 'success'
      i18n: 'options_importSuccess'
      message: 'Options imported.'
    )

  $scope.restoreLocal = (content) ->
    $scope.restoringLocal = true
    $rootScope.resetOptions(content).then(( ->
      $scope.importSuccess()
    ), -> $scope.restoreLocalError()).finally ->
      $scope.restoringLocal = false
  $scope.restoreLocalError = ->
    $rootScope.showAlert(
      type: 'error'
      i18n: 'options_importFormatError'
      message: 'Invalid backup file!'
    )
  $scope.downloadError = ->
    $rootScope.showAlert(
      type: 'error'
      i18n: 'options_importDownloadError'
      message: 'Error downloading backup file!'
    )
  $scope.triggerFileInput = ->
    angular.element('#restore-local-file').click()
    return
  $scope.restoreOnline = ->
    $.ajax(
      url: $scope.restoreOnlineUrl,
      success: (content) -> $scope.$apply ->
        $scope.restoreLocal(content)
      error: $scope.downloadError,
      dataType: "text",
      cache: false,
      timeout: 10000
    )

  $scope.enableOptionsSync = (args) ->
    enable = ->
      omegaTarget.setOptionsSync(true, args).finally ->
        $window.location.reload()
    if args?.force
      enable()
    else
      $rootScope.applyOptionsConfirm().then enable

  $scope.disableOptionsSync = ->
    omegaTarget.setOptionsSync(false).then ->
      $rootScope.applyOptionsConfirm().then ->
        $window.location.reload()

  $scope.resetOptionsSync = ->
    omegaTarget.resetOptionsSync().then ->
      $rootScope.applyOptionsConfirm().then ->
        $window.location.reload()
