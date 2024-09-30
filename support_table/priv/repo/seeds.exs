# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SupportTable.Repo.insert!(%SupportTable.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SupportTable.Support

# Create more representatives
representatives = [
  "John Doe",
  "Jane Smith",
  "Alice Johnson",
  "Bob Williams",
  "Carol Brown",
  "David Lee",
  "Eva Garcia",
  "Frank Miller",
  "Grace Taylor",
  "Henry Wilson"
]

created_representatives =
  Enum.map(representatives, fn name ->
    Support.Representative
    |> Ash.Changeset.for_create(:create, %{name: name})
    |> Ash.create!()
  end)

# Create more tickets
ticket_subjects = [
  "Cannot login to the system",
  "App crashes on startup",
  "Need help with password reset",
  "Feature request: dark mode",
  "Billing issue",
  "Performance problems",
  "Integration with third-party service not working",
  "Data export functionality not working",
  "UI elements misaligned on mobile",
  "Need assistance with API documentation",
  "Error when submitting form",
  "Unable to update profile picture",
  "Forgot username",
  "Request for additional user licenses",
  "Sync issues between devices",
  "Notification settings not saving",
  "Questions about new feature rollout",
  "Report a security vulnerability",
  "Trouble connecting to database",
  "API rate limit exceeded"
]

# Generate 100 tickets
for _ <- 1..100 do
  subject = Enum.random(ticket_subjects)
  status = Enum.random([:open, :closed])
  representative = Enum.random([nil | created_representatives])

  Support.Ticket
  |> Ash.Changeset.for_create(:create, %{
    subject: subject,
    status: status,
    representative_id: (representative && representative.id) || nil
  })
  |> Ash.create!()
end
