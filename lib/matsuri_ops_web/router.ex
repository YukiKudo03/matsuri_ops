defmodule MatsuriOpsWeb.Router do
  use MatsuriOpsWeb, :router

  import MatsuriOpsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MatsuriOpsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MatsuriOpsWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", MatsuriOpsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:matsuri_ops, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MatsuriOpsWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", MatsuriOpsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MatsuriOpsWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      # Festival routes
      live "/festivals", FestivalLive.Index, :index
      live "/festivals/new", FestivalLive.Index, :new
      live "/festivals/:id/edit", FestivalLive.Index, :edit
      live "/festivals/:id", FestivalLive.Show, :show
      live "/festivals/:id/show/edit", FestivalLive.Show, :edit

      # Task routes
      live "/festivals/:festival_id/tasks", TaskLive.Index, :index
      live "/festivals/:festival_id/tasks/new", TaskLive.Index, :new
      live "/festivals/:festival_id/tasks/:id/edit", TaskLive.Index, :edit
      live "/festivals/:festival_id/tasks/:id", TaskLive.Show, :show
      live "/festivals/:festival_id/tasks/:id/show/edit", TaskLive.Show, :edit

      # Budget routes
      live "/festivals/:festival_id/budgets", BudgetLive.Index, :index
      live "/festivals/:festival_id/budgets/expenses/new", BudgetLive.Index, :new_expense
      live "/festivals/:festival_id/budgets/expenses/:id/edit", BudgetLive.Index, :edit_expense
      live "/festivals/:festival_id/budgets/categories/new", BudgetLive.Index, :new_category
      live "/festivals/:festival_id/budgets/categories/:id/edit", BudgetLive.Index, :edit_category

      # Staff routes
      live "/festivals/:festival_id/staff", StaffLive.Index, :index
      live "/festivals/:festival_id/staff/new", StaffLive.Index, :new
      live "/festivals/:festival_id/staff/:id/edit", StaffLive.Index, :edit

      # Operations routes
      live "/festivals/:festival_id/operations", OperationsLive.Dashboard, :dashboard
      live "/festivals/:festival_id/operations/incidents/new", OperationsLive.Dashboard, :new_incident
      live "/festivals/:festival_id/operations/incidents/:id/edit", OperationsLive.Dashboard, :edit_incident
      live "/festivals/:festival_id/operations/areas/new", OperationsLive.Dashboard, :new_area
      live "/festivals/:festival_id/operations/areas/:id/edit", OperationsLive.Dashboard, :edit_area
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", MatsuriOpsWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{MatsuriOpsWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
