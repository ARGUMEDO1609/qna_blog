class LikesController < ApplicationController
  include ActionView::RecordIdentifier  # 👈 habilita dom_id en el controlador

  before_action :authenticate_user!
  before_action :set_likable

  def create
    like = current_user.likes.find_or_initialize_by(likable: @likable)
    ok = like.persisted? || like.save

    respond_to do |format|
      format.turbo_stream do
        if ok
          render turbo_stream: turbo_stream.replace(
            dom_id(@likable, :likes),
            partial: "likes/likes",
            locals: { likable: @likable }
          )
        else
          head :unprocessable_entity
        end
      end

      format.html do
        if ok
          redirect_back fallback_location: root_path, notice: "¡Te gustó!"
        else
          redirect_back fallback_location: root_path, alert: "No se pudo registrar el Me gusta."
        end
      end
    end
  end

  def destroy
    like = current_user.likes.find_by(likable: @likable)
    ok = like&.destroy

    respond_to do |format|
      format.turbo_stream do
        if ok
          render turbo_stream: turbo_stream.replace(
            dom_id(@likable, :likes),
            partial: "likes/likes",
            locals: { likable: @likable }
          )
        else
          head :unprocessable_entity
        end
      end

      format.html do
        if ok
          redirect_back fallback_location: root_path, notice: "Quitaste tu Me gusta."
        else
          redirect_back fallback_location: root_path, alert: "No se pudo quitar el Me gusta."
        end
      end
    end
  end

  private

  def set_likable
    klass = params[:likable].presence || params[:likable_type]
    case klass
    when "Question" then @likable = Question.find(params[:question_id] || params[:id])
    when "Answer"   then @likable = Answer.find(params[:answer_id]   || params[:id])
    else head :bad_request
    end
  end
end
