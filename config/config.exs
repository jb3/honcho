import Mix.Config

config :nosedrum,
  prefix: "honcho "

config :nostrum,
  token: System.get_env("BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages
  ],
  num_shards: 1
