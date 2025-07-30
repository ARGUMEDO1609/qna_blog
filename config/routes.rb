# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root "questions#index"

  resources :questions do
    # Likes de la PREGUNTA -> helpers: like_question_path / unlike_question_path
    member do
      post   :like,   to: "likes#create",  defaults: { likable: "Question" }
      delete :unlike, to: "likes#destroy", defaults: { likable: "Question" }
    end

    # Respuestas anidadas (crear/editar/actualizar/eliminar).
    # Con shallow: true podrás usar edit_answer_path(@answer) y delete a secas sin question_id.
    resources :answers, shallow: true, only: [:create, :edit, :update, :destroy]
  end

  # Likes de la RESPUESTA -> helpers: like_answer_path / unlike_answer_path
  resources :answers, only: [] do
    member do
      post   :like,   to: "likes#create",  defaults: { likable: "Answer" }
      delete :unlike, to: "likes#destroy", defaults: { likable: "Answer" }
    end
  end
end
