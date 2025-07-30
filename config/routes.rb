Rails.application.routes.draw do
  get "questions/index"
  get "questions/show"
  get "questions/new"
  get "questions/edit"
  get "questions/create"
  get "questions/update"
  get "questions/destroy"
  devise_for :users

  root "questions#index"

  resources :questions do
    resources :answers, only: [:create, :edit, :update, :destroy]
    # Likes para preguntas
    post   "like",   to: "likes#create",  defaults: { likable: "Question" }
    delete "unlike", to: "likes#destroy", defaults: { likable: "Question" }
  end

  # Likes para respuestas (shallow)
  resources :answers, only: [] do
    post   "like",   to: "likes#create",  defaults: { likable: "Answer" }
    delete "unlike", to: "likes#destroy", defaults: { likable: "Answer" }
  end
end
