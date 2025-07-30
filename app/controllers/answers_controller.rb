class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:create]
  before_action :set_answer, only: [:edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def create
    @answer = @question.answers.build(answer_params.merge(user: current_user))

    respond_to do |format|
      if @answer.save
        format.turbo_stream do
          render turbo_stream: [
            # Prepend la nueva respuesta a la lista
            turbo_stream.prepend(
              "answers",
              partial: "answers/answer",
              locals: { answer: @answer }
            ),
            # Reemplaza el formulario por uno limpio
            turbo_stream.replace(
              "new_answer",
              partial: "answers/form",
              locals: { question: @question, answer: Answer.new }
            )
          ]
        end

        format.html { redirect_to @question, notice: "Respuesta publicada." }
      else
        format.turbo_stream do
          # Re-renderiza el formulario con errores
          render turbo_stream: turbo_stream.replace(
            "new_answer",
            partial: "answers/form",
            locals: { question: @question, answer: @answer }
          ), status: :unprocessable_entity
        end

        format.html do
          @answers = @question.answers.includes(:user, :likes).order(created_at: :asc)
          flash.now[:alert] = "No se pudo guardar la respuesta."
          render "questions/show", status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    # Renderiza la vista con el form dentro del frame del propio answer
  end

  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@answer),
            partial: "answers/answer",
            locals: { answer: @answer }
          )
        end
        format.html { redirect_to @answer.question, notice: "Respuesta actualizada." }
      else
        format.turbo_stream do
          # Muestra el form con errores en el mismo frame del answer
          render turbo_stream: turbo_stream.replace(
            dom_id(@answer),
            partial: "answers/edit_form",
            locals: { answer: @answer }
          ), status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    question = @answer.question

    respond_to do |format|
      if @answer.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(dom_id(@answer))
        end
        format.html { redirect_to question, notice: "Respuesta eliminada." }
      else
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to question, alert: "No se pudo eliminar." }
      end
    end
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
