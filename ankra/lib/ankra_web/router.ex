defmodule AnkraWeb.Router do
  use AnkraWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AnkraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AnkraWeb do
    pipe_through :browser

    auth_routes_for Ankra.Accounts.User, to: AuthController
    sign_out_route AuthController
    sign_in_route register_path: "/register", auth_routes_prefix: "/auth"

    ash_authentication_live_session :authentication_required,
      on_mount: {AnkraWeb.UserAuth, :live_user_required} do
        live "/", CustomerLive.Index, :index
        live "/customers/new", CustomerLive.Index, :new
        live "/customers/:id/edit", CustomerLive.Index, :edit

        live "/customers/:id", CustomerLive.Show, :show
        live "/customers/:id/show/edit", CustomerLive.Show, :edit
    end

    # Define routes for admin
  end

  # Other scopes may use custom stacks.
  # scope "/api", AnkraWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ankra, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AnkraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
