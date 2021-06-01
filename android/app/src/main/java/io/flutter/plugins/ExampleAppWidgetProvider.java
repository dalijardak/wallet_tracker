package com.wallet_tracket.wallet_tracket;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.Toast;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime;    

public class ExampleAppWidgetProvider extends AppWidgetProvider {

  ApiService apiService = new ApiService();

  

  private void updateAppWidget(Context context, AppWidgetManager appWidgetManager,
    int appWidgetId) {
    
    // Date and Time 

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm");  
    LocalDateTime now = LocalDateTime.now();  
        // API CALL
    apiService.execute();

    Intent intent = new Intent(context, MainActivity.class);
    PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
    RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.example_widget);

    
    
    views.setTextViewText(R.id.coins_id, apiService.getCoins() + " BTC");
    views.setOnClickPendingIntent(R.id.coins_id, pendingIntent);
  
    views.setTextViewText(R.id.balance_id, apiService.getBalance() + apiService.getCurrency());
    views.setOnClickPendingIntent(R.id.coins_id, pendingIntent);
  
    views.setTextViewText(R.id.profit_id, apiService.getProfit() + "%");
    views.setOnClickPendingIntent(R.id.profit_id, pendingIntent);
  
    views.setTextViewText(R.id.dateTime_id, "Last updated " +dtf.format(now).toString());
    views.setOnClickPendingIntent(R.id.profit_id, pendingIntent);

    appWidgetManager.updateAppWidget(appWidgetId, views);

  }

  @Override
  public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {

    for (int appWidgetId: appWidgetIds) {
        updateAppWidget(context, appWidgetManager, appWidgetId);
    }
  }
}