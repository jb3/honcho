defmodule Honcho.Cogs.Help do
  @moduledoc false

  # Adapted from https://github.com/jchristgit/bolt/blob/master/lib/bolt/cogs/help.ex

  @behaviour Nosedrum.Command

  alias Nosedrum.Storage.ETS, as: CommandStorage
  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  @spec prefix() :: String.t()
  defp prefix, do: Application.fetch_env!(:nosedrum, :prefix)

  @spec format_command_detail(String.t(), Module.t()) :: Embed.t()
  def format_command_detail(name, command_module) do
    %Embed{
      title: "❔ `#{name}`",
      description: """
      ```ini
      #{
        command_module.usage()
        |> Stream.map(&"#{prefix()}#{&1}")
        |> Enum.join("\n")
      }
      ```
      #{command_module.description()}
      """,
    }
  end

  @impl true
  def usage, do: ["help [command:str]"]

  @impl true
  def description,
    do: """
    Show information about the given command.
    With no arguments given, list all commands.
    """

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, []) do

    embed = %Embed{
      title: "All commands",
      description:
        CommandStorage.all_commands()
        |> Map.keys()
        |> Enum.sort()
        |> Stream.map(&"`#{prefix()}#{&1}`")
        |> (fn commands ->
              """
              #{Enum.join(commands, ", ")}
              """
            end).()
    }

    {:ok, _msg} = Api.create_message(msg.channel_id, embed: embed)
  end

  @impl true
  def command(msg, [command_name]) do
    case CommandStorage.lookup_command(command_name) do
      nil ->
        response = "🚫 unknown command, check `help` to view all"
        {:ok, _msg} = Api.create_message(msg.channel_id, response)

      command_module when not is_map(command_module) ->
        embed = format_command_detail(command_name, command_module)
        {:ok, _msg} = Api.create_message(msg.channel_id, embed: embed)

      subcommand_map ->
        embed =
          if Map.has_key?(subcommand_map, :default) do
            format_command_detail(command_name, subcommand_map.default)
          else
            subcommand_string =
              subcommand_map
              |> Map.keys()
              |> Stream.reject(&(&1 === :default))
              |> Stream.map(&"`#{&1}`")
              |> Enum.join(", ")

            %Embed{
              title: "`#{command_name}` - subcommands",
              description: subcommand_string,
              footer: %Embed.Footer{
                text: "View `help #{command_name} <subcommand>` for details"
              }
            }
          end

        {:ok, _msg} = Api.create_message(msg.channel_id, embed: embed)
    end
  end

  def command(msg, [command_group, subcommand_name]) do
    # credo:disable-for-next-line Credo.Check.Refactor.WithClauses
    with command_map when is_map(command_map) <- CommandStorage.lookup_command(command_group) do
      case Map.fetch(command_map, subcommand_name) do
        {:ok, command_module} ->
          embed = format_command_detail("#{command_group} #{subcommand_name}", command_module)
          {:ok, _msg} = Api.create_message(msg.channel_id, embed: embed)

        :error ->
          subcommand_string =
            command_map |> Map.keys() |> Stream.map(&"`#{&1}`") |> Enum.join(", ")

          response =
            "🚫 unknown subcommand, known commands: #{subcommand_string}"

          {:ok, _msg} = Api.create_message(msg.channel_id, response)
      end
    else
      [] ->
        response = "🚫 no command group named that found"
        {:ok, _msg} = Api.create_message(msg.channel_id, response)

      [{_name, _module}] ->
        response =
          "🚫 that command has no subcommands, use" <>
            " `help #{command_group}` for information on it"

        {:ok, _msg} = Api.create_message(msg.channel_id, response)
    end
  end

  def command(msg, _args) do
    response =
      "ℹ️ usage: `help [command_name:str]` or `help [command_group:str] [subcommand_name:str]`"

    {:ok, _msg} = Api.create_message(msg.channel_id, response)
  end
end
