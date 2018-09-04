defmodule Sys2app.Manager do
  @moduledoc """
  Executes designated callback to setup Application environment
  for other dependant applications.
  """

  require(Logger)

  def child_spec(_opts) do
    %{id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      # transient means that it won't be restarted if exits normally
      restart: :transient,
      shutdown: 5000,
      type: :worker}
  end

  def start_link() do
    # Callback will be executed in the supervisor context to guarantie that
    # other dependencies won't be started before callback is finished.
    setup_environment()

    # Dummy process - required by supervisor
    {:ok, spawn_link(fn -> :ok end)}
  end

  def setup_environment do
    {m, f, a} = Application.get_env(:sys2app, :callback,
      {__MODULE__, :default_callback, []})

    Logger.info("Executing sys2app callback: #{inspect {m, f, a}}")
    apply(m, f, a)
  end

  def default_callback,
    do: Logger.error("#{__MODULE__}: Callback function not specified!")
end
