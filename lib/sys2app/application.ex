defmodule Sys2app.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Sys2app.Worker.start_link(arg1, arg2, arg3)
      # worker(Sys2app.Worker, [arg1, arg2, arg3]),
      Sys2app.Manager,
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sys2app.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
