class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @questions = Question
      .includes(:user, :answers, :likes)
      .order(created_at: :desc)
  end

  def show
    @answer = Answer.new
    @answers = @question.answers.includes(:user, :likes).order(created_at: :asc)
  end

  def new
    @question = current_user.questions.build
  end

  def edit; end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      redirect_to @question, notice: "¡Pregunta creada!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      redirect_to @question, notice: "Pregunta actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: "Pregunta eliminada."
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def authorize_owner!
    redirect_to @question, alert: "No autorizado." unless @question.user == current_user
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
