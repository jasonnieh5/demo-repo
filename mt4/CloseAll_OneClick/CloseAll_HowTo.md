# CLOSE ALL – One-Button EA / 一鍵全部平倉

**1. Open a new chart / 開新圖表**
File > New Chart > US100.cash (keep the SignalAlert chart separate – 1 EA per chart / 每個圖表只能掛一個 EA)

**2. Drag the EA / 拖曳 EA**
Navigator > Expert Advisors > **CloseAll_OneClick** → drag onto the new chart / 拖到新圖表

**3. Common tab / 「常用」分頁**
Tick ✅ **Allow live trading** → OK

**4. AutoTrading button = GREEN / 工具列「自動交易」按鈕要是綠色**

**5. Use it / 使用**
Click red **CLOSE ALL** → button turns **CONFIRM? click again** → click again within 5 s
按紅色 CLOSE ALL → 5 秒內再按一次確認。超過 5 秒自動取消。

**6. The Alert / 彈出視窗**
"X position(s) closed, Y pending deleted, Z failed" – if failed > 0, those tickets are still open: press again or close manually.
若 failed > 0，代表那幾張單還沒平，請再按一次或手動平倉。
"trading NOT allowed" → check steps 3 & 4. Nothing was closed. / 沒有平倉，請檢查第 3、4 步。

**7. Remove / 移除**
Right-click chart > Expert Advisors > Remove / 右鍵圖表 > 智能交易系統 > 移除

Label next to button = open positions + floating P/L. The EA never opens trades. / 按鈕旁顯示持倉數與浮動盈虧；此 EA 不會開新單。
