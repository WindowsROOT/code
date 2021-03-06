//+------------------------------------------------------------------+
//|                                                          MTC.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "WindowsROOT."
#property link      "https://www.facebook.com/WindowsROOT"
#property version   "1.0"
#include <trade\Trade.mqh>       // class for trade functions.
#include <Trade\SymbolInfo.mqh>  // class for Display symbol properties.
#include <Math\Stat\Math.mqh>    // class for libraries calculations mathematics.
CTrade trade;                    // trade functions.


//aQKjc3KAc4odSxJktRBiIloF59GlDG3O9igoGp6zPWS

//+------------------------------------------------------------------+
//| External parameters                        |
//+------------------------------------------------------------------+

input string Step1 = "===== Currency pairs Setting =================";  // • Step 1     
                                                        
input string	Symbol_1	 = "EURUSD"; //1st Currency
input string	Symbol_2	 = "GBPUSD"; //2nd Currency
input string	Symbol_3	 = "USDCHF"; //3rd Currency
 

input string Step2 = "===== Lot Size Setting ======================";  // • Step 2          
                                                        
input double	lot_1		 = 0.01;	    //1st Lot Size 
input double	lot_2		 = 0.02;     //2nd Lot Size 
input double	lot_3		 = 0.03;	    //3rd Lot Size
	
input string Step3 = "===== StopLoss and TakeProfit Setting ========="; //• Step 3 
                                                         
input double   TP        = 300; // TP (Point)
input double   SL        = 100; // SL (Point)
input double   TP_Target = 15.0;  // TP_Target(USD)
input double   SL_Target = 10.0;  // SL_Target(USD)

input string Step4 = "===== Moving Average Setting ================";  //• Step 4  
                                                        
input int      ma_period =15;


input string Step5 = "===== Line Notify Setting ===================";  //• Step 5  
                                                        
input bool Use_LineNotify = false;//• Use LineNotify
string message = "",endl="\n";
string message_2 = "";
input string token="aQKjc3KAc4odSxJktRBiIloF59GlDG3O9igoGp6zPWS"; // Token
input string api_url="https://notify-api.line.me/api/notify";     // URL API




//--- CAL parameters 
int      shift     =1; 
double   buf1[],buf2[],buf3[];
double   cor1,cor2;
double   _cor1 = 0.5;        // Correlat Positive.
double   _cor2 = -0.5;       // Correlat Negative. 
double   Point();            // Returns the point size of the current symbol in the quote currency.

// status EA Send to LineNotify
string status_1 = "BUY";
string status_2 = "SELL";
string status_3 = "CLOSE";


//+------------------------------------------------------------------+
//| Expert initialization function ( Working First use only 1 time )                                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Call_LineNotify("456546786");
   LineNotify("Multi Currency Trading System Notify Ready!!!");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function  ( Working closing only 1 time )                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function   (Work every time after price is changed )                                          |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   correlat();   // Calculator correlation
   OpenOrder();  // Open Order
   CloseOrder(); // Close Order
     
  }
//+------------------------------------------------------------------+

  void correlat()
  {
   // The function initializes a numeric array by a preset value.
   ArrayInitialize(buf1,0);
   ArrayInitialize(buf2,0);
   ArrayInitialize(buf3,0);
   
   //gets into close_array to buffer
  CopyClose(Symbol_1,NULL,1,100,buf1);
  CopyClose(Symbol_2,NULL,1,100,buf2);
  CopyClose(Symbol_3,NULL,1,100,buf3);
   
   // Calculator correlation
   MathCorrelationPearson(buf1,buf2,cor1);
   MathCorrelationPearson(buf1,buf3,cor2);

  }
//+-------------

// funtion send symbo return SMA_Price
double Price(string _symbo)
{
   double MAArray[];
   int MAHandle=iMA(_symbo,PERIOD_CURRENT,ma_period,0,MODE_SMA,PRICE_CLOSE);
   ArraySetAsSeries(MAArray,true);
   CopyBuffer(MAHandle,0,0,20,MAArray);
   return MAArray[shift];

}

// funtion send symbo return SMA_Price 
double getMA(string _symbo)
{
   double MAArray[];
   int MAHandle=iMA(_symbo,PERIOD_CURRENT,ma_period,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(MAArray,true);
   CopyBuffer(MAHandle,0,0,20,MAArray);
   return MAArray[shift];

}

// funtion condition to OpenOrder 
void OpenOrder(){
      if(   (Price(Symbol_1)<getMA(Symbol_1))&&
            (Price(Symbol_2)<getMA(Symbol_2))&&
            (Price(Symbol_3)<getMA(Symbol_3))&&
            (cor1>_cor1)&&(cor2>_cor2)&&
            (PositionsTotal()==0))
           {
             Comment("con1");
             BUY ();
           }
           
 else if(   (Price(Symbol_1)>getMA(Symbol_1))&&
            (Price(Symbol_2)<getMA(Symbol_2))&&
            (Price(Symbol_3)<getMA(Symbol_3))&&
            (cor1>_cor1)&&(cor2>_cor2)&&
            (PositionsTotal()==0))
           {
             Comment("con2");
             BUY ();
           }
 else if(   (Price(Symbol_1)>getMA(Symbol_1))&&
            (Price(Symbol_2)>getMA(Symbol_2))&&
            (Price(Symbol_3)>getMA(Symbol_3))&&
            (cor1>_cor1)&&(cor2>_cor2)&&
            (PositionsTotal()==0))
           {
             Comment("con3");
             SELL ();
           }
 else if(   (Price(Symbol_1)>getMA(Symbol_1))&&
            (Price(Symbol_2)>getMA(Symbol_2))&&
            (Price(Symbol_3)<getMA(Symbol_3))&&
            (cor1>_cor1)&&(cor2>_cor2)&&
            (PositionsTotal()==0))
           {
             Comment("con4");
             SELL ();
           }
else      {
            Comment("EUUSD/GBPUSD =",(cor1),"\n",
                    "EUUSD/USDCHF =",(cor2));
            
                
          }
}


// funtion  OpenOrder Position BUY 
void BUY (){

   trade.Buy( lot_1,
   			  Symbol_1,
   		     NULL,
   			  SymbolInfoDouble(Symbol_1,SYMBOL_ASK)-SL*_Point, 
   			  SymbolInfoDouble(Symbol_1,SYMBOL_ASK)+TP*_Point,
   			  NULL 		//comment
   			 );
   trade.Buy( lot_2,
   			  Symbol_2,
   		     NULL,
   			  SymbolInfoDouble(Symbol_2,SYMBOL_ASK)-SL*_Point, 
   			  SymbolInfoDouble(Symbol_2,SYMBOL_ASK)+TP*_Point,
   			  NULL 		//comment
   			 );
   trade.Buy( lot_3,
   			  Symbol_3,
   		     NULL,
   			  SymbolInfoDouble(Symbol_3,SYMBOL_ASK)-SL*_Point, 
   			  SymbolInfoDouble(Symbol_3,SYMBOL_ASK)+TP*_Point,
   			  NULL 		//comment
   			 );
   
   message_2 += "Buy :";
   message_2 += " Lot="+DoubleToString(lot_1,2);
   message_2 += " Symbol="+Symbol_1;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_1,SYMBOL_ASK)-SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_1,SYMBOL_ASK)+TP*_Point,5);
   message_2 += endl;
   
   message_2 += "Buy :";
   message_2 += " Lot="+DoubleToString(lot_2,2);
   message_2 += " Symbol="+Symbol_2;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_2,SYMBOL_ASK)-SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_2,SYMBOL_ASK)+TP*_Point,5);
   message_2 += endl;
   
   message_2 += "Buy :";
   message_2 += " Lot="+DoubleToString(lot_3,2);
   message_2 += " Symbol="+Symbol_3;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_3,SYMBOL_ASK)-SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_3,SYMBOL_ASK)+TP*_Point,5);
   message_2 += endl;
   
   
   Call_LineNotify(status_1);

}

//funtion  OpenOrder Position SELL
void SELL (){
   trade.Sell( lot_1,
   			  Symbol_1,
   		     NULL,
   			  SymbolInfoDouble(Symbol_1,SYMBOL_BID)+SL*_Point, 
   			  SymbolInfoDouble(Symbol_1,SYMBOL_BID)-TP*_Point,
   			  NULL 		//comment
   			 );
   trade.Sell( lot_2,
   			  Symbol_2,
   		     NULL,
   			  SymbolInfoDouble(Symbol_2,SYMBOL_BID)+SL*_Point, 
   			  SymbolInfoDouble(Symbol_2,SYMBOL_BID)-TP*_Point,
   			  NULL 		//comment
   			 );
   trade.Sell( lot_3,
   			  Symbol_3,
   		     NULL,
   			  SymbolInfoDouble(Symbol_3,SYMBOL_BID)+SL*_Point, 
   			  SymbolInfoDouble(Symbol_3,SYMBOL_BID)-TP*_Point,
   			  NULL 		//comment
   			 );
   			 
   message_2 += "Sell :";
   message_2 += " Lot="+DoubleToString(lot_1,2);
   message_2 += " Symbol="+Symbol_1;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_1,SYMBOL_BID)+SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_1,SYMBOL_BID)-TP*_Point,5);
   message_2 += endl;
   
   message_2 += "Sell :";
   message_2 += " Lot="+DoubleToString(lot_2,2);
   message_2 += " Symbol="+Symbol_2;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_2,SYMBOL_BID)+SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_2,SYMBOL_BID)-TP*_Point,5);
   message_2 += endl;
   
   message_2 += "Sell :";
   message_2 += " Lot="+DoubleToString(lot_3,2);
   message_2 += " Symbol="+Symbol_3;
   message_2 += " SL="+DoubleToString(SymbolInfoDouble(Symbol_3,SYMBOL_BID)+SL*_Point,5);
   message_2 += " TP="+DoubleToString(SymbolInfoDouble(Symbol_3,SYMBOL_BID)-TP*_Point,5);
   message_2 += endl;			 
   			 
   Call_LineNotify(status_2);

}






//funtion  CloseOrder 
void CloseOrder(){
   if (AccountInfoDouble(ACCOUNT_PROFIT)>=MathAbs(TP_Target))
     {  
        for(int i=PositionsTotal()-1;i>=0;i--)
         {
           if(PositionSelectByTicket(PositionGetTicket(i)))
            {
             trade.PositionClose(PositionGetInteger(POSITION_TICKET));  
             message_2 += "Close TP Target by Ticket = "+IntegerToString(PositionGetTicket(i)) + endl;
            }
         }
         Call_LineNotify(status_3);
     }
   if (AccountInfoDouble(ACCOUNT_PROFIT)<=-MathAbs(SL_Target))
     {  
        for(int i=PositionsTotal()-1;i>=0;i--)
         {
           if(PositionSelectByTicket(PositionGetTicket(i)))
            {
             trade.PositionClose(PositionGetInteger(POSITION_TICKET));
             message_2 += "Close SL Target by Ticket = "+IntegerToString(PositionGetTicket(i)) + endl;  
            }
         }
         Call_LineNotify(status_3);
     }
         
}

//funtion LineNotify
void LineNotify(string Massage)
  {
   string headers;
   char post[],result[];

   headers="Authorization: Bearer "+token+"\r\n";
   headers+="Content-Type: application/x-www-form-urlencoded\r\n";

   ArrayResize(post,StringToCharArray("message="+Massage,post,0,WHOLE_ARRAY,CP_UTF8)-1);
   int res = WebRequest("POST", "https://notify-api.line.me/api/notify", headers, 10000, post, result, headers);
   Print("Status code: " , res, ", error: ", GetLastError());
   Print("Server response: ", CharArrayToString(result));
  }
  
 //funtion Call LineNotify
void Call_LineNotify(string _status)
{
   if(!Use_LineNotify) return; // หาวิธีแก้ double แจ้งเตือน
      
   message = "";// แก้ตรงนี้
   message += "สถานะ: "+_status+".";
   message += " \n แจ้งเตือนรายละเอียดดังนี้\n";
   message += "AccountNumber : "+AccountInfoString(ACCOUNT_NAME)+endl;
   message += "Balance : "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+endl;
   message += "Equity : "+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+endl;
   message += "Profit : "+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+endl;
   message += message_2 +endl;
   message_2 = "";//ส่งก่อนค่อยเคลียของเดิม
   LineNotify(message);
}

