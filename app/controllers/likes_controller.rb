class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_likable

  def create
    like = current_user.likes.find_or_initialize_by(likable: @likable)
    if like.persisted? || like.save
      redirect_back fallback_location: root_path, notice: "¡Te gustó!"
    else
      redirect_back fallback_location: root_path, alert: "No se pudo registrar el Me gusta."
    end
  end

  def destroy
    like = current_user.likes.find_by(likable: @likable)
    if like&.destroy
      redirect_back fallback_location: root_path, notice: "Quitaste tu Me gusta."
    else
      redirect_back fallback_location: root_path, alert: "No se pudo quitar el Me gusta."
    end
  end

  private

  # Recibe defaults desde routes.rb: { likable: "Question" } o { likable: "Answer" }
  def set_likable
    klass = params[:likable].presence || params[:likable_type]
    case klass
    when "Question"
      @likable = Question.find(params[:question_id] || params[:id])
    when "Answer"
      @likable = Answer.find(params[:answer_id] || params[:id])
    else
      head :bad_request
    end
  end
end

