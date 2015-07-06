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
    libraries: 'weather,geometry,visualization'

#
# Application controller
#
angular.module('iMap').controller 'ApplicationController', ($scope, modalDialog, Auth, $timeout) ->
  app = @

  # Application menu
  app.menuActive = true
  app.toggleMenu = ->
    app.menuActive = if app.menuActive == false then true else false

  # Administration toolkit
  app.toolKitActive = false
  app.toggleToolkit = ->
    app.toolKitActive = if app.toolKitActive == false then true else false

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
angular.module('iMap').controller 'MapController', ($scope, $timeout, locationsService, uploadsService, uiGmapIsReady) ->
  $scope.selectedUploads = []
  markers                = []

   # Locations
  locationsService.getLocations().then (d) ->

    _.each d, (l, key) ->
      labelStyle =
        'width': '20px'
        'height': '20px'

      markers.push {
        id: l.id
        icon: 'marker.png'
        latitude: l.lat
        longitude: l.lng
        labelContent: "<div class='u-size'>#{l.uploads_size}</div>
          <div class='u-cover' style='background-image: url(#{l.last_upload_src});'> </div>"
        labelClass: 'marker-labels'
        labelStyle: labelStyle
        labelAnchor: '-15 60'
        labelInBackground: false
      }

    $scope.markers = markers

  # Map center
  objectLatitude  = 55.0385767
  objectLongitude = 67.8679176

  $scope.map =
    center: { latitude: objectLatitude, longitude: objectLongitude }
    control: {},
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
      if $scope.selectedUploads.length > 0

        e = originalEventArgs[0]
        lat = e.latLng.lat()
        lon = e.latLng.lng()

        $scope.map.clickedMarker =
          id: 0
          options:
            icon: 'marker-added.png'
            labelContent: "Photo was saved into this location" #+ 'lat: ' + lat + ' lon: ' + lon
            labelAnchor: '50 0'
          latitude: lat
          longitude: lon

        # scope apply required because this event handler is outside of the angular domain
        $scope.$apply()

        # Save location values into database
        locationsService.saveLocation(lat, lon, $scope.selectedUploads)

        # Empty selected uploads
        $scope.selectedUploads = []


  # Render current photos
  $scope.showLocation = (marker) ->
    locationId = marker.id

    uploadsService.getLocationUploads(locationId).then (d) ->

      $.magnificPopup.open
        items: d.uploads # array
        gallery:
          enabled: true
        type: 'image'

  return $scope


#
# Administration controller
#
angular.module('iMap').controller 'AdministrationController', ($scope, $timeout, uploadsService) ->
  $scope.pendingUploads = []

  $timeout ->
    $scope.pendingUploads = $scope.preloadResource.pending_uploads
  , 1

  # Set item status as approved
  $scope.approve = (item) ->
    uploadsService.approveUpload(item).then (response) ->
      if response.status == 200 # OK!
        $scope.pendingUploads = _.without($scope.pendingUploads, item)
      else
        alert('Error while photo approving')

  # Permanently delete item
  $scope.delete = (item) ->
    uploadsService.deleteUpload(item).then (response) ->
      if response.status == 200 # OK!
        $scope.pendingUploads = _.without($scope.pendingUploads, item)
      else
        alert('Error while photo deletion')

  # Get uploads for administrator
  $scope.$on 'devise:admin', ->
    uploadsService.getAdminUploads().then (d) ->
      $scope.pendingUploads = d

  return $scope


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

  # After upload is finished we need to update saved ID information
  uploader.onCompleteItem = (item, response, status, headers) ->
    if status == 201
      item['id'] = response.id
    else
      alert('Something happend when upload is finished')

  # Get list of already created uploads
  $timeout ->
    $scope.uploads = $scope.preloadResource.uploads
  , 1

  $scope.delete = (item) ->
    uploadsService.deleteUpload(item).then (response) ->
      if response.status == 200 # OK!
        $scope.uploads = _.without($scope.uploads, item)
      else
        alert('Error while photo deletion')

  # Select
  $scope.select = (item) ->
    unless _.includes($scope.selectedUploads, item)
      $scope.selectedUploads.push(item)

  $scope.isSelected = (item) ->
    _.findIndex($scope.selectedUploads, item) >= 0

  $scope.authoriseWith = (action) ->
    return action

  # Events
  $scope.$on 'devise:login', (event, currentUser) ->
    # If this is an admin we need to emit new event for admin
    $scope.$broadcast 'devise:admin' if currentUser.role_id == 2

    # Get current user uploads
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
      .error (data, status, headers, config) ->
        alert('It was an error while saving location')

  return @


#
# Uploads loader
#
angular.module('iMap').factory 'uploadsService', ($http) ->

  @.approveUpload = (upload) ->
    $http.put(Routes.upload_approve_path(upload)).then (response) ->
      return response

  @.deleteUpload = (upload) ->
    $http.delete(Routes.upload_path(upload)).then (response) ->
      return response

  @.getLocationUploads = (locationId) ->
    $http.get(Routes.location_uploads_path(locationId)).then (response) ->
      return response.data

  @.getUserUploads = ->
    $http.get(Routes.user_uploads_path()).then (response) ->
      return response.data

  @.getAdminUploads = ->
    $http.get(Routes.pending_uploads_path()).then (response) ->
      return response.data

  return @


# Auth factory with modal initialisation
angular.module('iMap').factory 'modalDialog', ->
  element = angular.element('.ui.modal')

  @.show = ->
    element.modal('setting', 'transition', 'scale').
    modal
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
