## Tích hợp gửi thông báo Pipeline CI/CD đến Telegram

Tìm kiếm botfather trên Telegram

<div align="center">
  <img width="600" src="../images/telegram-bot-1.png" alt="Telegram bot">
</div>
<br>

Thực hiện các bước theo chỉ dẫn của `BotFather` để tạo bot mới, chọn `name` và `username` cho bot

- `name`: `Pipeline notification`
- `username`: `pipeline_check_bot`

Sau khi thành công sẽ có:

- Link để chuyển tới cuộc hội thoại của bot
- Token hãy lưu lại để sau sử dụng trong pipline CI/CD

<div align="center">
  <img width="600" src="../images/telegram-bot-2.png" alt="Telegram bot">
</div>
<br>

Chuyển đến con bot mới tạo ấn `Start` và chat 1 nội dung bất kì nào đó

<div align="center">
  <img width="600" src="../images/telegram-bot-3.png" alt="Telegram bot">
</div>
<br>

Truy cập vào link: `https://api.telegram.org/bot<Token>/getUpdates` và lưu lại Chat ID để sử dụng cho pipeline CI/CD

<div align="center">
  <img width="600" src="../images/telegram-bot-4.png" alt="Telegram bot">
</div>
<br>
