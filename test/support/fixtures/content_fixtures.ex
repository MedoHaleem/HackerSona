defmodule HackerSona.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HackerSona.Content` context.
  """

  @doc """
  Generate a unique post title.
  """
  def unique_post_title, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: unique_post_title()
      })
      |> HackerSona.Content.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> HackerSona.Content.create_comment()

    comment
  end
end
