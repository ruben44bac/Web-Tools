defmodule WebTool.WebsocketTest do
  use WebSockex

  @topic "socket_tools"

  alias Phoenix.PubSub

  # Start the WebSocket connection
  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{}, name: __MODULE__)
  end

  # Handle incoming messages
  def handle_frame({:text, msg}, state) do
    IO.puts("Received message: #{msg}")

    PubSub.broadcast(WebTool.PubSub, @topic, {:message, msg})

    {:ok, state}
  end

  def handle_info(msg, state) do
    {:ok, state}
  end

  # Send a message when connected
  def handle_connect(conn, state) do
    IO.puts("Connected to WebSocket")
    {:ok, state}
  end

  # Handle error
  def handle_disconnect(reason, state) do
    IO.puts("Disconnected: #{inspect(reason)}")
    {:ok, state}
  end

  # Join a channel
  def join_channel(conn, topic) do
    message = %{
      topic: topic,
      event: "phx_join",
      payload: %{},
      ref: 1
    }

    send_message(conn, message)
  end

  # Send a message
  def send_message(conn, message) do
    WebSockex.send_frame(conn, {:text, Jason.encode!(message)})
  end
end
