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
    plug MatsuriOpsWeb.Plugs.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MatsuriOpsWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/locale/:locale", LocaleController, :switch
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

      # Help routes
      live "/help", HelpLive.Index, :index
      live "/help/quickstart", HelpLive.Quickstart, :index
      live "/help/admin", HelpLive.Admin, :index
      live "/help/staff", HelpLive.Staff, :index
      live "/help/external", HelpLive.External, :index

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

      # Report routes
      live "/festivals/:festival_id/reports", ReportLive.Index, :index
      live "/reports/compare", ReportLive.Compare, :compare

      # Chat routes
      live "/festivals/:festival_id/chat", ChatLive.Index, :index
      live "/festivals/:festival_id/chat/new", ChatLive.Index, :new
      live "/festivals/:festival_id/chat/:id", ChatLive.Room, :show
      live "/festivals/:festival_id/chat/:id/edit", ChatLive.Index, :edit

      # Location routes
      live "/festivals/:festival_id/locations", LocationLive.Index, :index

      # Document routes
      live "/festivals/:festival_id/documents", DocumentLive.Index, :index
      live "/festivals/:festival_id/documents/new", DocumentLive.Index, :new
      live "/festivals/:festival_id/documents/:id/edit", DocumentLive.Index, :edit
      live "/festivals/:festival_id/documents/:id", DocumentLive.Show, :show

      # Announcement routes
      live "/festivals/:festival_id/announcements", AnnouncementLive.Index, :index
      live "/festivals/:festival_id/announcements/new", AnnouncementLive.Index, :new
      live "/festivals/:festival_id/announcements/:id/edit", AnnouncementLive.Index, :edit

      # Shift routes
      live "/festivals/:festival_id/shifts", ShiftLive.Index, :index
      live "/festivals/:festival_id/shifts/new", ShiftLive.Index, :new
      live "/festivals/:festival_id/shifts/:id/edit", ShiftLive.Index, :edit

      # Gantt chart routes
      live "/festivals/:festival_id/gantt", GanttLive.Index, :index

      # QR Code routes
      live "/festivals/:festival_id/qr-codes", QRCodeLive.Index, :index
      live "/festivals/:festival_id/qr-codes/new", QRCodeLive.Index, :new
      live "/festivals/:festival_id/qr-codes/:id/edit", QRCodeLive.Index, :edit
      live "/festivals/:festival_id/qr-codes/:id", QRCodeLive.Show, :show

      # Ad Banner routes
      live "/festivals/:festival_id/ad-banners", AdBannerLive.Index, :index
      live "/festivals/:festival_id/ad-banners/new", AdBannerLive.Index, :new
      live "/festivals/:festival_id/ad-banners/:id/edit", AdBannerLive.Index, :edit
      live "/festivals/:festival_id/ad-banners/:id", AdBannerLive.Show, :show

      # Gallery routes
      live "/festivals/:festival_id/gallery", GalleryLive.Index, :index
      live "/festivals/:festival_id/gallery/new", GalleryLive.Index, :new
      live "/festivals/:festival_id/gallery/:id/edit", GalleryLive.Index, :edit
      live "/festivals/:festival_id/gallery/:id", GalleryLive.Show, :show
      live "/festivals/:festival_id/gallery/moderation", GalleryLive.Moderation, :moderation

      # Social Media routes
      live "/festivals/:festival_id/social", SocialMediaLive.Index, :index
      live "/festivals/:festival_id/social/new", SocialMediaLive.Index, :new
      live "/festivals/:festival_id/social/:id/edit", SocialMediaLive.Index, :edit
      live "/festivals/:festival_id/social/:id", SocialMediaLive.Show, :show
      live "/festivals/:festival_id/social/accounts", SocialMediaLive.Accounts, :accounts

      # Template routes
      live "/templates", TemplateLive.Index, :index
      live "/templates/new", TemplateLive.Index, :new
      live "/templates/:id/edit", TemplateLive.Index, :edit
      live "/templates/:id", TemplateLive.Show, :show
      live "/templates/:id/apply", TemplateLive.Apply, :apply
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
