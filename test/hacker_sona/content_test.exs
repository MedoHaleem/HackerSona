defmodule HackerSona.ContentTest do
  use HackerSona.DataCase

  alias HackerSona.Content

  describe "posts" do
    alias HackerSona.Content.Post

    import HackerSona.ContentFixtures
    import HackerSona.AccountsFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Content.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Content.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{title: "some title", body: "some body"}

      assert {:ok, %Post{} = post} = Content.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.body == "some body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Post{} = post} = Content.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_post(post, @invalid_attrs)
      assert post == Content.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Content.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Content.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
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
      assert Content.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = build_comment_with_post_and_user()
      assert Content.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      post = post_fixture()
      user = user_fixture()
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
      assert comment == Content.get_comment!(comment.id)
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
      post = post_fixture()
      user = user_fixture()
      # Merge attrs
      attrs = Enum.into(attrs, %{post_id: post.id, user_id: user.id})
      comment_fixture(attrs)
    end
  end
end
