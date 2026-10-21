# CloseAll_OneClick

MetaTrader 4 Expert Advisor that places one chart button. Pressing it closes **every open market order on the account, on every symbol**. It can also delete pending orders. It never opens, modifies, or scales into a trade.

Files in this folder:

- `CloseAll_OneClick.mq4` — EA source
- `CloseAll_HowTo.md` — short bilingual click-path
- `CloseAll_HowTo.png` — screenshot of the button on a chart

## Inputs

| Input | Default | Meaning |
| --- | --- | --- |
| `RequireConfirm` | `true` | First click arms the button. A second click within 5 seconds runs the close. |
| `DeletePending` | `true` | Also delete pending orders (`OP_BUYLIMIT`, `OP_SELLLIMIT`, `OP_BUYSTOP`, `OP_SELLSTOP`). Set to `false` to close market orders only. |
| `Slippage` | `30` | Maximum slippage, in points, passed to `OrderClose`. |
| `MaxRetries` | `5` | Attempts per ticket. Each failed attempt waits 300 ms and refreshes prices. |

A label beside the button shows the count of open market orders and their floating profit (profit + swap + commission).

## Install

1. Copy `CloseAll_OneClick.mq4` into the terminal data folder: `MQL4/Experts/` (File → Open Data Folder in MetaTrader 4).
2. Open the file in MetaEditor and compile it (F7). `CloseAll_OneClick.ex4` should appear with no errors.
3. Attach **CloseAll_OneClick** to any chart (Navigator → Expert Advisors → drag onto the chart). One EA per chart; use a chart that does not already have another EA.
4. On the Common tab, enable **Allow live trading**.
5. Turn the toolbar **AutoTrading** button on (green).

If trading is not allowed, the EA alerts and closes nothing.

## Two-click confirm

With `RequireConfirm = true` (the default):

1. Click the red **CLOSE ALL** button. It turns orange and reads **CONFIRM? click again**. No orders are closed yet.
2. Click the same button again within 5 seconds. It shows **CLOSING...**, then closes market orders and, if `DeletePending` is on, deletes pending orders.
3. If 5 seconds pass with no second click, the button returns to **CLOSE ALL** and the request is dropped.

With `RequireConfirm = false`, a single click closes immediately.

When it finishes, an alert reports how many positions were closed, how many pending orders were deleted, and which tickets failed. Failed tickets are still open; click again or close them manually.

## Risk warning

**This EA closes ALL open market positions on the account, not only the chart symbol.** With `DeletePending` enabled it also deletes every pending order. There is no symbol filter, magic-number filter, or partial-close option. Run it on a demo account first, and only arm it when you intend to flatten the whole account. Slippage, a frozen market, or AutoTrading being off can leave some tickets open.

## 繁體中文

此 EA 在圖表上放一顆按鈕，按下後會平掉**帳戶內所有商品**的市價單，並可依設定刪除掛單。它不會開新單。

參數：`RequireConfirm`（預設開啟，5 秒內需再按一次才執行）、`DeletePending`（是否刪除掛單）、`Slippage`（滑點，點）、`MaxRetries`（每張單重試次數）。

安裝：把 `CloseAll_OneClick.mq4` 複製到 `MQL4/Experts/`，用 MetaEditor 編譯，掛到圖表，並開啟「允許即時交易」與工具列的自動交易。

兩次確認：第一次按下只會把按鈕改成確認狀態，5 秒內再按一次才平倉；逾時自動取消。

**風險：會平掉整個帳戶的全部持倉，不限目前圖表。請先在模擬帳戶測試。**
