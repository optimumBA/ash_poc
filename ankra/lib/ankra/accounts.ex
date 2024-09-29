defmodule Ankra.Accounts do
  use Ash.Domain,
    otp_app: :ankra

  resources do
    resource Ankra.Accounts.Token

    resource Ankra.Accounts.User do
      define :make_admin, action: :make_admin
      define :list_users, action: :read
      define :get_user, action: :get_by_id, args: [:user_id]
    end
  end

  authorization do
    authorize :by_default
  end
end
