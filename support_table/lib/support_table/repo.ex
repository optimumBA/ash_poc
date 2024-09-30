defmodule SupportTable.Repo do
  use AshPostgres.Repo,
    otp_app: :support_table

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions"]
  end

  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
