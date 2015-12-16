class Users::FavoriteCoursesController < ApplicationController
  include CourseManager

  before_action :authenticate_user!
  before_action :redis_state, only: [:show, :export]

  def show
    @entries = Entry.where(code: current_user.favorite_courses).includes(:course)
  end

  def create
    raise ActiveRecord::RecordNotFound if Entry.where(code: params[:favorite_course]).empty?
    append_course(:favorite_courses, params[:favorite_course])
  end

  def destroy
    delete_course(:favorite_courses, params[:favorite_course])
  end

  def export
    if current_user.student? && !@state[:queued] && !params[:csys_password].blank?
      BookmarkingCoursesJob.perform_later(current_user, params[:csys_password])
    else
      if current_user.student?
        redis_state(message: '工作尚未結束或密碼空白')
      else
        redis_state(message: '非學生帳號，請洽管理員')
      end
    end
    redirect_to users_favorite_courses_path
  end

  private

  def redis_state(**args)
    @state = JSON.parse($job_redis.get(current_user.id) || '{}')
    @state.merge!(args)
    $job_redis.set(current_user.id, @state.to_json)
  end
end
