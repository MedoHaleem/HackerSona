defmodule HackerSonaWeb.PostLiveTest do
  use HackerSonaWeb.ConnCase

  import Phoenix.LiveViewTest
  import HackerSona.ContentFixtures
  import HackerSona.AccountsFixtures
  alias HackerSona.Content

  @create_attrs %{title: "some title", body: "some body"}
  @update_attrs %{title: "some updated title", body: "some updated body"}
  @invalid_attrs %{title: nil, body: nil}

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(%{user_id: user.id})
    %{post: post}
  end

  describe "Index" do
    setup [:create_post, :register_and_log_in_user]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, ~p"/posts")

      assert html =~ "Listing Posts"
      assert html =~ post.title
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, ~p"/posts/new")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#post-form", post: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Post created successfully"
      assert html =~ "some title"
    end
  end

  describe "Show" do
    alias HackerSonaWeb.Presence
    setup [:create_post, :register_and_log_in_user]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/posts/#{post}")

      assert html =~ "Show Post"
      assert html =~ post.title
    end

    test "updates post within modal if user is owner of the post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, ~p"/posts/new")

      assert index_live
             |> form("#post-form", post: @create_attrs)
             |> render_submit()

      post = Content.get_latest_post()

      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")

      assert show_live |> element("a", "Edit") |> render_click() =~ "Edit"

      assert_patch(show_live, ~p"/posts/#{post}/show/edit")

      assert show_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/posts/#{post}")

      html = render(show_live)
      assert html =~ "Post updated successfully"
      assert html =~ "some updated title"
    end

    test "Edit button isn't visible if user is not owner of the post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")
      html = render(show_live)
      assert html != "Edit"
    end

    test "Add new comment to the post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")

      assert show_live
             |> form("#comment-form", comment: %{body: "some comment"})
             |> render_submit()

      html = render(show_live)
      assert html =~ "some comment"
    end

    test "broadcasts new comment", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")

      HackerSona.Content.subscribe(post.id)

      show_live
      |> form("#comment-form", comment: %{body: "some comment"})
      |> render_submit()

      assert_receive {tag,  %{body: "some comment"}}

      assert tag == :comment_created
    end

    test "tracks user presence in a post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")

      presences = Presence.list("post:#{post.id}")

      # Current user should be present in the post
      assert presences != %{}

      # simulate user presence have left the post by closing the tab
      GenServer.stop(show_live.pid())

      # Current user should not be present in the post
      assert Presence.list("post:#{post.id}") == %{}
    end
  end
end
