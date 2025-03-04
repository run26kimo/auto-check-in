# auto-check-in


## 專案簡介
由於每天都會忘記打卡，而希望藉由 github action 來實現 自動打卡

- 自動登入 Bipo 
- 每天 10:00, 19:00 在隨機加上 15 ~ 130 秒
- 完成後自動發送通知到 Line


## 需要設定的 ENV
- LINE_CHANNEL_ACCESS_TOKEN: 用於發送 Line 通知的存取權杖
- LINE_USER_ID: 接收 Line 通知的使用者 ID
- BIPOID: 用於登入 BIPO 的使用者 ID
- BIPOPASSWORD: 用於登入 BIPO 的密碼


## 流程圖

```mermaid
sequenceDiagram
    participant Cron as GitHub Actions (Cron Job)
    participant Runner as Mac Mini (GitHub Actions Runner)
    participant Script as Automation Script
    participant Bipo as Bipo App
    participant LineMsg as Line Message API

    Cron->>Runner: Trigger Runner (10:00 & 19:00)
    Runner->>Script: Execute Auto Clock In Script
    Script->>Bipo: Send Login Request
    Bipo-->>Script: Login Response (Success/Failure)
    
    alt Login Successful
        Script->>Bipo: Perform Clock In
        Bipo-->>Script: Clock In Confirmation
        Script->> LineMsg : Send Success message
    end
```