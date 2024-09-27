defmodule AshBlog.Posts do
  use Ash.Domain

  alias AshBlog.Posts.Post

  resources do
    resource Post
  end
end
