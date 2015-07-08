class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session
  protect_from_forgery :except => :receive_guest

  before_action :preload_app
  before_action :preload_uploads
  before_action :preload_pending_uploads
  before_action :current_or_guest_user, only: :show

  respond_to :json

  def show
  end

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  helper_method :current_or_guest_user

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user(with_retry = true)
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user if with_retry
  end

  private

    # called (once) when the user logs in, insert any code your application needs
    # to hand off from guest_user to current_user.
    def logging_in
      # For example:
      # guest_comments = guest_user.comments.all
      # guest_comments.each do |comment|
        # comment.user_id = current_user.id
        # comment.save!
      # end
    end

    def create_guest_user
      u = User.create(:name => "guest", :email => "guest_#{Time.now.to_i}#{rand(100)}@example.com")
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      u
    end

    def preload_app
      @app = {
        user: current_user
      }.to_json
    end

    def preload_uploads
      uploads =
        if current_user
          ActiveModel::ArraySerializer.new(current_user.uploads, each_serializer: UploadSerializer)
        else
          []
        end

      @uploads = {
        uploads: uploads
      }.to_json
    end

    def preload_pending_uploads
      pending_uploads =
        if user_signed_in? && current_user.admin?
          ActiveModel::ArraySerializer.new(Upload.pending, each_serializer: UploadSerializer)
        else
          []
        end

      @pending_uploads = {
        pending_uploads: pending_uploads
      }.to_json
    end


  protected

    def validate_rights
      unless current_user.present?
        render json: { unauthorised: true }, status: :unprocessable_entity
        return false
      end
    end

end
