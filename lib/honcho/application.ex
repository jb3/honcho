defmodule Honcho.Application do
  use Application

  def start(_type, _args) do
    children = [
      Nosedrum.Storage.ETS,
      Honcho.Consumer
    ]
    options = [strategy: :one_for_one, name: Honcho.Supervisor]
    Supervisor.start_link(children, options)
  end
end
