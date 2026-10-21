//+------------------------------------------------------------------+
//| CloseAll_OneClick.mq4 - one button closes ALL open positions     |
//| Places NO new orders. Only closes market orders / deletes pending|
//+------------------------------------------------------------------+
#property strict
#property description "One-click CLOSE ALL button. Closes all market orders on all symbols and (optionally) deletes pending orders. Never opens trades."

input bool RequireConfirm = true;   // Require second click within 5 s
input bool DeletePending  = true;   // Also delete pending orders
input int  Slippage       = 30;     // Slippage (points)
input int  MaxRetries     = 5;      // Retries per order

string BTN = "CA_OneClick_Btn";
string LBL = "CA_OneClick_Lbl";
datetime armedAt = 0;
bool armed = false;

void MakeButton(string text, color bg)
{
   if(ObjectFind(0,BTN) < 0)
   {
      ObjectCreate(0,BTN,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,BTN,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,BTN,OBJPROP_XDISTANCE,20);
      ObjectSetInteger(0,BTN,OBJPROP_YDISTANCE,40);
      ObjectSetInteger(0,BTN,OBJPROP_XSIZE,220);
      ObjectSetInteger(0,BTN,OBJPROP_YSIZE,60);
      ObjectSetInteger(0,BTN,OBJPROP_FONTSIZE,16);
      ObjectSetString(0,BTN,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,BTN,OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,BTN,OBJPROP_BORDER_COLOR,clrBlack);
      ObjectSetInteger(0,BTN,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,BTN,OBJPROP_HIDDEN,true);
   }
   ObjectSetString(0,BTN,OBJPROP_TEXT,text);
   ObjectSetInteger(0,BTN,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,BTN,OBJPROP_STATE,false);
}

void UpdateLabel()
{
   int n=0; double pl=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType()<=OP_SELL)
      { n++; pl+=OrderProfit()+OrderSwap()+OrderCommission(); }
   if(ObjectFind(0,LBL) < 0)
   {
      ObjectCreate(0,LBL,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,LBL,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,LBL,OBJPROP_XDISTANCE,255);
      ObjectSetInteger(0,LBL,OBJPROP_YDISTANCE,58);
      ObjectSetInteger(0,LBL,OBJPROP_FONTSIZE,14);
      ObjectSetString(0,LBL,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,LBL,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,LBL,OBJPROP_HIDDEN,true);
   }
   ObjectSetString(0,LBL,OBJPROP_TEXT,StringFormat("Open: %d   P/L: %s%.2f",n,(pl>=0?"+":""),pl));
   ObjectSetInteger(0,LBL,OBJPROP_COLOR,(pl>=0?clrLime:clrOrangeRed));
}

int OnInit()
{
   MakeButton("CLOSE ALL",clrRed);
   UpdateLabel();
   EventSetTimer(1);
   ChartRedraw();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0,BTN);
   ObjectDelete(0,LBL);
   ChartRedraw();
}

void OnTick(){ UpdateLabel(); }

void OnTimer()
{
   if(armed && TimeLocal()-armedAt>=5)
   { armed=false; MakeButton("CLOSE ALL",clrRed); }
   UpdateLabel();
   ChartRedraw();
}

bool CloseOne(int ticket)
{
   for(int a=0;a<MaxRetries;a++)
   {
      RefreshRates();
      if(!OrderSelect(ticket,SELECT_BY_TICKET)) return false;
      if(OrderCloseTime()!=0) return true;
      int t=OrderType(); bool ok=false;
      if(t==OP_BUY || t==OP_SELL)
      {
         double price=(t==OP_BUY)?MarketInfo(OrderSymbol(),MODE_BID):MarketInfo(OrderSymbol(),MODE_ASK);
         ok=OrderClose(ticket,OrderLots(),price,Slippage,clrNONE);
      }
      else ok=OrderDelete(ticket);
      if(ok) return true;
      Print("CloseAll: ticket ",ticket," attempt ",a+1," failed, error ",GetLastError());
      Sleep(300);
   }
   return false;
}

void CloseAll()
{
   if(!IsTradeAllowed())
   {
      Alert("CLOSE ALL: trading NOT allowed. Turn on AutoTrading and tick 'Allow live trading'. Nothing closed.");
      return;
   }
   int tickets[]; int cnt=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()>OP_SELL && !DeletePending) continue;
      ArrayResize(tickets,cnt+1); tickets[cnt++]=OrderTicket();
   }
   int closed=0, deleted=0, failed=0; string fails="";
   for(int k=0;k<cnt;k++)
   {
      bool pend=false;
      if(OrderSelect(tickets[k],SELECT_BY_TICKET)) pend=(OrderType()>OP_SELL);
      if(CloseOne(tickets[k])) { if(pend) deleted++; else closed++; }
      else { failed++; fails+=" #"+IntegerToString(tickets[k]); }
   }
   string msg=StringFormat("CLOSE ALL done: %d position(s) closed, %d pending deleted, %d failed%s",
                           closed,deleted,failed,(failed>0?(":"+fails):""));
   Print(msg);
   Alert(msg);
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id!=CHARTEVENT_OBJECT_CLICK || sparam!=BTN) return;
   if(RequireConfirm && !armed)
   {
      armed=true; armedAt=TimeLocal();
      MakeButton("CONFIRM? click again",clrDarkOrange);
      ChartRedraw();
      return;
   }
   armed=false;
   MakeButton("CLOSING...",clrGray); ChartRedraw();
   CloseAll();
   MakeButton("CLOSE ALL",clrRed);
   UpdateLabel(); ChartRedraw();
}
