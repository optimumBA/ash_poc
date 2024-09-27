# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AshBlog.Repo.insert!(%AshBlog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AshBlog.Posts.Post

# TODO: Ideally, you would want to use this code block, for performance reasons,
# but since I want the posts to be ordered on the UI, I used sequential inserts
# with the for-loop
#
# Task.async_stream(1..100, fn i ->
#   Ash.create!(Post, %{
#     title: "Post #{i}",
#     body: "This is the body of post #{i}."
#   })
# end)
# |> Stream.run()

for i <- 1..100 do
  Ash.create!(Post, %{
    title: "Post #{i}",
    body: "This is the body of post #{i}."
  })
end
