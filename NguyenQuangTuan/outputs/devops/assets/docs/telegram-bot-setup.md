## Integrate sending CI/CD Pipeline notifications to Telegram

Search for botfather on Telegram

<div align="center">
  <img width="600" src="../images/telegram-bot-1.png" alt="Telegram bot">
</div>
<br>

Follow the steps guided by `BotFather` to create a new bot, choose a `name` and `username` for the bot

- `name`: `Pipeline notification`
- `username`: `pipeline_check_bot`

After successful creation, you will have:

- A link to the bot conversation
- A token, save it for later use in the CI/CD pipeline

<div align="center">
  <img width="600" src="../images/telegram-bot-2.png" alt="Telegram bot">
</div>
<br>

Go to the newly created bot, press `Start`, and send any message

<div align="center">
  <img width="600" src="../images/telegram-bot-3.png" alt="Telegram bot">
</div>
<br>

Access the link: `https://api.telegram.org/bot<Token>/getUpdates` and save the Chat ID for use in the CI/CD pipeline

<div align="center">
  <img width="600" src="../images/telegram-bot-4.png" alt="Telegram bot">
</div>
<br>
