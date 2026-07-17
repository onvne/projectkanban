Rails.application.routes.draw do
  # 1. Вложенные роуты только для создания задач
  resources :projects, only: [ :new, :create, :edit, :update, :destroy ] do
    resources :tasks, only: [ :index, :new, :create, :edit, :update, :destroy ]
  end

  devise_for :users, controllers: {
    registrations: "registrations"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # 2. Плоские роуты для ВСЕХ остальных действий с задачами
  resources :tasks, only: [ :index, :edit, :update, :destroy ] do
    member do
      patch :move_forward
      patch :move_backward
    end
  end

  root "tasks#index"
end
