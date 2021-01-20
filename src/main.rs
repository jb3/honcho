use serenity::client::{Client, Context, EventHandler};
use serenity::model::channel::Message;
use serenity::framework::standard::macros::{command, group};
use serenity::framework::standard::{StandardFramework, CommandResult};

#[command]
async fn about(ctx: &Context, msg: &Message) -> CommandResult {
    msg.channel_id.say(&ctx.http, "A simple test bot").await?;

    Ok(())
}

#[command]
async fn ping(ctx: &Context, msg: &Message) -> CommandResult {
    msg.channel_id.say(&ctx.http, "pong!").await?;

    Ok(())
}

#[group]
#[commands(about, ping)]
struct General;

struct Handler;

impl EventHandler for Handler {}

#[tokio::main]
async fn main() {
    let token = std::env::var("DISCORD_TOKEN").expect("Could not find DISCORD_TOKEN env var");

    let framework = StandardFramework::new()
        .configure(|c| c.prefix("~"))
        // The `#[group]` (and similarly, `#[command]`) macro generates static instances
        // containing any options you gave it. For instance, the group `name` and its `commands`.
        // Their identifiers, names you can use to refer to these instances in code, are an
        // all-uppercased version of the `name` with a `_GROUP` suffix appended at the end.
        .group(&GENERAL_GROUP);

    let mut client = Client::builder(&token).event_handler(Handler).framework(framework).await.expect("Could not build client");
}
