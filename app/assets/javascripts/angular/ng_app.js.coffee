#= require ng-rails-csrf
#= require angular-devise
#= require angular-resource
#= require angular-google-maps
#= require angularjs-file-upload

# Initialisation
angular.module('iMap', ['Devise', 'ngResource', 'ng-rails-csrf', 'angularFileUpload', 'uiGmapgoogle-maps'])

# Configuration
angular.module('iMap').config (uiGmapGoogleMapApiProvider) ->

  uiGmapGoogleMapApiProvider.configure
    key: gon.global.gmaps_key,
    v: '3.17',
    libraries: 'weather, geometry, visualization'

#
# Application controller
#
angular.module('iMap').controller 'ApplicationController', ($scope, modalDialog, Auth, $timeout) ->
  app = @
  # Application menu
  app.menuActive = false
  app.toggleMenu = ->
    app.menuActive = if app.menuActive == false then true else false

  # Global features
  $scope.modalDialog = modalDialog
  $scope.Auth = Auth

  $timeout ->
    Auth._currentUser = $scope.preloadResource.user if $scope.preloadResource.user
  , 1

  return app

#
# Map controller
#
angular.module('iMap').controller 'MapController', ($scope, locationsService) ->
  $scope.selectedUploads = []
  $scope.locations       = []

  # Map center
  objectLatitude  = 55.0385767
  objectLongitude = 67.8679176

  # Default marker
  marker = {
    id: 1
  }
  # All markers
  markers = {}

  # Locations
  locationsService.getLocations().then (d) ->
    _.each d, (n, key) ->
      markers["somekey-#{key}"] =
        id: key
        coords:
          latitude: n.lat
          longitude: n.lng
        icon: '/assets/location/markers/icon.png'

    $scope.markers = markers


  $scope.map =
    center: { latitude: objectLatitude, longitude: objectLongitude }
    options:
      scrollwheel: false
      streetViewControl: false
      zoomControlOptions:
        style: 3
    zoom: 2,
    clickedMarker:
      id: 0
      options: {}
    events: click: (mapModel, eventName, originalEventArgs) ->

      # if $scope.selectedUploads.length == 0
      #   alert 'please, choose any photo to save it on map'
      #   return false

      # 'this' is the directive's scope
      #$log.info 'user defined event: ' + eventName, mapModel, originalEventArgs
      e = originalEventArgs[0]
      lat = e.latLng.lat()
      lon = e.latLng.lng()
      $scope.map.clickedMarker =
        id: 0
        options:
          labelContent: "Photo was saved into this location" # + 'lat: ' + lat + ' lon: ' + lon
          labelClass: 'marker-labels'
          labelAnchor: '50 0'
        latitude: lat
        longitude: lon

      # Save location values into database
      locationsService.saveLocation(lat, lon, $scope.selectedUploads)
      $scope.selectedUploads = []

      #scope apply required because this event handler is outside of the angular domain
      $scope.$apply()


#
# Uploads controller
#
angular.module('iMap').controller 'UploadsController', ($scope, FileUploader, $timeout, uploadsService) ->
  $scope.uploads = []

  uploader = $scope.uploader =
    new FileUploader
      url: Routes.uploads_path(),
      alias: 'upload[image]',
      autoUpload: true

  uploader.onAfterAddingFile = (fileItem) ->
    fileItem.formData.push { description: $scope.description }
    fileItem.description = $scope.description

  # Get already created uploads
  $timeout ->
    $scope.uploads = $scope.preloadResource.uploads
  , 1

  # Select
  $scope.select = (item) ->
    if _.findIndex($scope.selectedUploads, item) >= 0
      $scope.selectedUploads = _.without($scope.selectedUploads, item)
    else
      $scope.selectedUploads.push(item)

  $scope.isSelected = (item) ->
    _.findIndex($scope.selectedUploads, item) >= 0

  # Events
  $scope.$on 'devise:login', (event, currentUser) ->
    uploadsService.getUserUploads().then (d) ->
      $scope.uploads = d

  return $scope

#
# Modal controller
#
angular.module('iMap').controller 'ModalController', ($scope, $http, modalDialog, Auth) ->
  modal = @
  modal.defaultActionTitle = 'Sign in'
  modal.currentActionTitle = modal.defaultActionTitle
  modal.currentAction      = 'signIn'

  # Opens modal dialog
  modal.setAction = (action) ->
    modal.currentAction      = action
    modal.currentActionTitle = if modal.currentAction == 'signUp' then 'Sign up' else modal.defaultActionTitle

  modal.isSignInForm = ->
    modal.currentAction == 'signIn'

  modal.isSignUpForm = ->
    modal.currentAction == 'signUp'

  # Submit modal form
  modal.submit = ->
    # No errors!
    modal.formError = false

    # Request settings
    path =
      if modal.isSignUpForm() then Routes.user_registration_path(format: 'json')
      else Routes.user_session_path(format: 'json')

    credentials =
      email: modal.email
      password: modal.password

    config =
      headers:
        'X-HTTP-Method-Override': 'POST'

    # SignIn form processing
    if modal.isSignInForm()
      Auth.login(credentials, config).then (user) ->
        $scope.currentUser = user
        modalDialog.hide()
      , (error) ->
        # Authentication failed...
        modal.formError = true
        modal["#{modal.currentAction}Form"].$invalid = true

    # SignUp form processing
    if modal.isSignUpForm()
      # Add password_confirmation
      _.merge(credentials, { password_confirmation: modal.passwordConfirmation })

      Auth.register(credentials, config).then ((registeredUser) ->
        modalDialog.hide()
      ), (error) ->
        # Authentication failed...
        modal.formError = true
        modal["#{modal.currentAction}Form"].$invalid = true

    return false

  return modal


#
# Locations loader
#
angular.module('iMap').factory 'locationsService', ($http) ->

  @.getLocations = ->
    $http.get(Routes.locations_path()).then (response) ->
      return response.data

  # Save uploads into selected location
  @.saveLocation = (lat, lng, uploads = []) ->
    if uploads.length > 0
      uploads = _.pluck(uploads, 'id')

    params =
      location:
        lat: lat
        lng: lng
        uploads: uploads

    $http.post(Routes.locations_path(), params)
      .success (data, status, headers, config) ->
        console.log data
      .error (data, status, headers, config) ->
        # @TODO error action

  return @


#
# Uploads loader
#
angular.module('iMap').factory 'uploadsService', ($http) ->

  @.getUserUploads = ->
    $http.get(Routes.user_uploads_path()).then (response) ->
      return response.data

  return @


# Auth factory with modal initialisation
angular.module('iMap').factory 'modalDialog', ->
  element = angular.element('.ui.modal')

  @.show = ->
    element.modal('setting', 'transition', 'scale').
    modal('setting', 'closable', false).
    modal
      closable: false,
      onHide: ->
        return false
      ,
      onDeny: ->
        return false
      ,
      onApprove: ->
        return false
    .modal('show')

  @.hide = ->
    element.modal('hide')

  return @


# Preload resource
angular.module('iMap').directive 'preloadResource', ->
  {
    link: (scope, element, attrs) ->
      scope.preloadResource = JSON.parse(attrs.preloadResource)
      element.remove()
  }

# Canvas image as preview
angular.module('iMap').directive 'ngThumb', [
  '$window'
  ($window) ->
    helper =
      support: ! !($window.FileReader and $window.CanvasRenderingContext2D)
      isFile: (item) ->
        angular.isObject(item) and item instanceof $window.File
      isImage: (file) ->
        type = '|' + file.type.slice(file.type.lastIndexOf('/') + 1) + '|'
        '|jpg|png|jpeg|bmp|gif|'.indexOf(type) != -1
    {
      restrict: 'A'
      template: '<canvas/>'
      link: (scope, element, attributes) ->

        onLoadFile = (event) ->
          img = new Image
          img.onload = onLoadImage
          img.src = event.target.result
          return

        onLoadImage = ->
          width = params.width or @width / @height * params.height
          height = params.height or @height / @width * params.width
          canvas.attr
            width: width
            height: height
          canvas[0].getContext('2d').drawImage this, 0, 0, width, height
          return

        if !helper.support
          return
        params = scope.$eval(attributes.ngThumb)
        if !helper.isFile(params.file)
          return
        if !helper.isImage(params.file)
          return
        canvas = element.find('canvas')
        reader = new FileReader
        reader.onload = onLoadFile
        reader.readAsDataURL params.file
        return
    }
]
