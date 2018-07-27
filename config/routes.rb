Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :common_mortgagees
    resources :target_dates, only: [:index]
    resources :reports, only: [:show, :index]
    resources :tasks, only: [:index]
    resources :fees, only: [:index]
    resources :users
    resources :notifications, only: [:index] do
      collection do
        post :approve_all
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :client_sessions, only: [:create]
      resources :declarations, only: [:show, :update]
      resources :payments, only: [:create]
      resources :submissions, only: [:create]
      resources :vessel_types, only: [:index]
      resources :vessels, only: [:index, :show]
    end
  end

  namespace :finance do
    resources :batches, only: [:index, :create, :update, :destroy] do
      member do
        post :close
        post :re_open
        post :lock
      end

      resources :payments

      collection do
        get :this_week
        get :this_month
        get :this_year
      end
    end
  end

  resources :finance_payments, only: [:show, :update] do
    collection do
      get :unattached_payments
      get :unattached_refunds
    end
    member do
      patch :update
      patch :link
    end
    resources :payments,
              controller: "finance_payments/payments",
              only: [:update]
    resources :submissions,
              controller: "finance_payments/submissions",
              only: [:new, :create]
  end

  resources :submissions, only: [:new, :create, :show, :edit, :update] do
    collection do
      get :open
      get :completed
    end

    resources :agent,
              controller: "submission/agents", only: [:update, :destroy]

    resources :applicant,
              controller: "submission/applicants", only: [:update]

    resource :approval,
             controller: "submission/approvals", only: [:show, :create]

    resources :beneficial_owners,
              controller: "submission/beneficial_owners",
              only: [:create, :update, :destroy]

    resource :carving_and_marking,
             controller: "submission/carving_and_marking",
             only: [:create] do
      member do
        post :update_state
      end
    end

    resource :csr,
             controller: "submission/csr",
             only: [:show, :update, :destroy]

    resources :directed_bys,
              controller: "submission/directed_bys",
              only: [:create, :update, :destroy]

    resources :managed_bys,
              controller: "submission/managed_bys",
              only: [:create, :update, :destroy]

    resource :correspondence,
             only: [:create, :destroy],
             controller: "submission/correspondences"

    resource :correspondent,
             only: [:update],
             controller: "submission/correspondents"

    resources :declaration_group_members,
              controller: "submission/declaration_group_members",
              only: [:create, :destroy]

    resources :declaration_groups,
              controller: "submission/declaration_groups",
              only: [:create, :update]

    resources :declarations,
              controller: "submission/declarations",
              only: [:create, :update, :destroy] do
      member do
        post :complete
      end
    end

    resources :charterers,
              controller: "submission/charterers",
              only: [:create, :update, :destroy] do
      resources :charter_parties,
                controller: "submission/charterers/charter_parties",
                only: [:create, :update, :destroy]
    end

    resources :documents,
              only: [:create, :update, :destroy],
              controller: "submission/documents"

    resources :engines,
              controller: "submission/engines",
              only: [:create, :update, :destroy]

    resources :managers,
              controller: "submission/managers",
              only: [:create, :update, :destroy]

    resources :mortgages,
              controller: "submission/mortgages",
              only: [:create, :update, :destroy]

    resource :official_no,
             controller: "submission/official_no",
             only: [:update]

    resource :managing_owner,
             only: [:update],
             controller: "submission/managing_owners"

    resource :name_approval,
             controller: "submission/name_approvals",
             only: [:show, :update]

    resources :notes,
              only: [:create, :update],
              controller: "submission/notes"

    resources :representatives,
              controller: "submission/representatives",
              only: [:update, :destroy]

    resource :shareholding,
             controller: "submission/shareholdings",
             only: [:show]

    resource :signature,
             controller: "submission/signatures",
             only: [:show, :update]

    resources :tasks,
              controller: "submission/tasks",
              only: [:index, :create, :destroy, :update, :show] do
      collection do
        post :confirm
      end

      member do
        post :claim
        post :unclaim
        post :claim_referral
      end

      resource :notification,
               controller: "submission/task/notifications",
               only: [:show] do
        member do
          post :cancel
          post :refer
        end
      end
    end
  end

  resources :print_jobs, only: [:show, :index, :update]

  namespace :reports do
    resources :work_logs, only: [:index]
  end

  resources :vessels, only: [:show, :index] do
    resource :closure,
             only: [:create],
             controller: "registered_vessel/closure"

    resource :forced_closure,
             only: [:create],
             controller: "registered_vessel/forced_closure"

    resources :csrs,
              only: [:show, :create, :update],
              controller: "registered_vessel/csrs"

    resource :cold_storage,
             only: [:create],
             controller: "registered_vessel/cold_storage"

    resource :current_transcript,
             only: [:show],
             controller: "registered_vessel/current_transcript"

    resource :correspondence,
             only: [:create, :destroy],
             controller: "registered_vessel/correspondences"

    resource :historic_transcript,
             only: [:show],
             controller: "registered_vessel/historic_transcript"

    resource :note,
             only: [:create],
             controller: "registered_vessel/notes"

    resource :official_no,
             controller: "registered_vessel/official_no",
             only: [:update]

    resource :registration_certificate,
             only: [:show],
             controller: "registered_vessel/registration_certificate"

    resource :section_notice,
             only: [:create],
             controller: "registered_vessel/section_notice"

    resource :termination,
             only: [:create],
             controller: "registered_vessel/termination"

    resource :manual_override,
             only: [:create],
             controller: "registered_vessel/manual_override"
  end

  %w(
    incomplete my-tasks team-tasks
    referred unclaimed cancelled next-task
  ).each do |action|
    get "/tasks/#{action}",
        controller: :tasks,
        action: action.tr("-", "_")
  end

  %w(
    carving_and_marking registration_certificate cover_letter
    current_transcript historic_transcript csr_form
    provisional_certificate termination_notice renewal_reminder_letter
    mortgagee_reminder_letter ihs section_notice forced_closure
  ).each do |template|
    get "/print_queue/#{template}",
        controller: :print_jobs,
        action: :index,
        template: template
  end

  get "/search", controller: :search, action: :index
  get "/search/submissions", controller: :search, action: :submissions
  get "/search/vessels", controller: :search, action: :vessels
  get "/search/global", controller: :search, action: :global

  root to: "dashboards#show"
end
