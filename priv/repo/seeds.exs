# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HackerSona.Repo.insert!(%HackerSona.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# Create a user first
alias HackerSona.Accounts

{:ok, user} =
  user =
  Accounts.register_user(%{
    email: "medo@test.com",
    password: "password1234567890"
  })

# Create a post
post =
  HackerSona.Repo.insert!(%HackerSona.Content.Post{
    title: "Phoenix LiveView 1.0-rc is here!",
    body:
      "This 1.0 milestone comes almost six years after the first LiveView commit. \n
  Why LiveView
I started LiveView to scratch an itch. I wanted to create dynamic server-rendered applications without writing JavaScript. I was tired of the inevitable ballooning complexity that it brings.

Think realtime form validations, updating the quantity in a shopping cart, or real-time streaming updates. Why does it require moving mountains to solve in a traditional stack? We write the HTTP glue or GraphQL schemas and resolvers, then we figure out which validation logic needs shared or dup. It goes on and on from there – how do we get localization information to the client? What data serializers do we need? How do we wire up WebSockets and IPC back to our code? Is our js bundle getting too large? I guess it’s time to start turning the Webpack or Parcel knobs. Wait Vite is a thing now? Or I guess Bun configuration is what we want? We’ve all felt this pain.

The idea was, what if we removed these problems entirely? HTTP can go away, and the server can handle all the rendering and dynamic update concerns. It felt like a heavy approach, but I knew Elixir and Phoenix was perfectly suited for it.

Six years later this programming model still feels like cheating. Everything is super fast. Payloads are tiny. Latency is best-in-class. Not only do you write less code, theres simply less to think about when writing features.",
    user_id: user.id
  })

# Create a comment for the post
HackerSona.Repo.insert!(%HackerSona.Content.Post.Comment{
  body: "Comment body",
  post_id: post.id,
  user_id: user.id
})
