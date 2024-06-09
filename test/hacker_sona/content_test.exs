defmodule HackerSona.ContentTest do
  use HackerSona.DataCase

  alias HackerSona.Content

  describe "posts" do
    alias HackerSona.Content.Post

    import HackerSona.ContentFixtures
    import HackerSona.AccountsFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert Content.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert Content.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()
      valid_attrs = %{title: "some title", body: "some body", user_id: user.id}

      assert {:ok, %Post{} = post} = Content.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.body == "some body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Post{} = post} = Content.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Content.update_post(post, @invalid_attrs)
      assert post == Content.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert {:ok, %Post{}} = Content.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Content.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Content.change_post(post)
    end
  end

  describe "comments" do
    alias HackerSona.Content.Post.Comment

    import HackerSona.ContentFixtures
    import HackerSona.AccountsFixtures

    @invalid_attrs %{body: nil}

    test "list_comments/0 returns all comments" do
      comment = build_comment_with_post_and_user()
      comment_from_db = Content.list_comments() |> hd()
      assert comment.id == comment_from_db.id
      assert comment.body == comment_from_db.body
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = build_comment_with_post_and_user()
      comment_from_db = Content.get_comment!(comment.id)
      assert comment.id == comment_from_db.id
      assert comment.body == comment_from_db.body
    end

    test "create_comment/1 with valid data creates a comment" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      valid_attrs = %{body: "some body", post_id: post.id, user_id: user.id}

      assert {:ok, %Comment{} = comment} = Content.create_comment(valid_attrs)
      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = build_comment_with_post_and_user(%{body: "some body"})
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Comment{} = comment} = Content.update_comment(comment, update_attrs)
      assert comment.body == "some updated body"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = build_comment_with_post_and_user()
      assert {:error, %Ecto.Changeset{}} = Content.update_comment(comment, @invalid_attrs)
      comment_to_be_updated = Content.get_comment!(comment.id)
      assert comment.id == comment_to_be_updated.id
      assert comment.body == comment_to_be_updated.body
    end

    test "delete_comment/1 deletes the comment" do
      comment = build_comment_with_post_and_user()
      assert {:ok, %Comment{}} = Content.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Content.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = build_comment_with_post_and_user()
      assert %Ecto.Changeset{} = Content.change_comment(comment)
    end

    defp build_comment_with_post_and_user(attrs \\ %{}) do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      # Merge attrs
      attrs = Enum.into(attrs, %{post_id: post.id, user_id: user.id})
      comment_fixture(attrs)
    end
  end
end
