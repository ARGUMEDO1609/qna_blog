class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:create]
  before_action :set_answer, only: [:edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def create
    @answer = @question.answers.build(answer_params.merge(user: current_user))
    if @answer.save
      redirect_to @question, notice: "Respuesta publicada."
    else
      @answers = @question.answers.includes(:user, :likes).order(created_at: :asc)
      flash.now[:alert] = "No se pudo guardar la respuesta."
      render "questions/show", status: :unprocessable_entity
    end
  end

  def edit
    # Se edita en vista propia
  end

  def update
    if @answer.update(answer_params)
      redirect_to @answer.question, notice: "Respuesta actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    question = @answer.question
    @answer.destroy
    redirect_to question, notice: "Respuesta eliminada."
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def authorize_owner!
    redirect_back fallback_location: root_path, alert: "No autorizado." unless @answer.user == current_user
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
