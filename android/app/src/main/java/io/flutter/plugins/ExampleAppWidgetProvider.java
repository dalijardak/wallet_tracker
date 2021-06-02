package com.wallet_tracket.wallet_tracket;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.Toast;
import android.os.Bundle;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;
import android.content.SharedPreferences;

public class ExampleAppWidgetProvider extends AppWidgetProvider {
  public static String REFRESH_ACTION = "AppWidgetManager.ACTION_APPWIDGET_UPDATE";
  
  // Called when pressed refresh Button
  @Override
  public void onReceive(Context context, Intent intent) {
    int [] array = {24};
    super.onReceive(context, intent);

    if (intent.getAction().equalsIgnoreCase(REFRESH_ACTION)) {
      Bundle extras = intent.getExtras();
      if (extras != null) {
          int[] appWidgetIds = extras.getIntArray(AppWidgetManager.EXTRA_APPWIDGET_IDS);
          if (appWidgetIds != null && appWidgetIds.length > 0) {
              this.onUpdate(context, AppWidgetManager.getInstance(context), appWidgetIds);
          }
      }

    }
  }

  @Override
  public void onEnabled(Context context) {
      super.onEnabled(context);
    
}


  // Detect button pressed action
  static private PendingIntent getPenIntent(Context context, int[] appWidgetIds) {
    Intent intent = new Intent(context, ExampleAppWidgetProvider.class);
    intent.setAction(REFRESH_ACTION);
    intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds);
    return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
  }

  @Override
  public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {

    
    SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", context.MODE_PRIVATE);
    String hash = prefs.getString("flutter.hash", "");
    String currencyUrl = prefs.getString("flutter.currency", "");

    ApiService apiService = new ApiService(hash, currencyUrl);

    // Date and Time 
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm");
    LocalDateTime now = LocalDateTime.now();
    // API CALL
    apiService.execute();

    Intent intent = new Intent(context, ExampleAppWidgetProvider.class);
    PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
    RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.example_widget);

    
    views.setOnClickPendingIntent(R.id.button_id, getPenIntent(context,appWidgetIds));

    views.setTextViewText(R.id.coins_id, apiService.getCoins() + " BTC");
    //views.setOnClickPendingIntent(R.id.coins_id, pendingIntent);

    views.setTextViewText(R.id.balance_id, apiService.getBalance() + apiService.getCurrency());
    //views.setOnClickPendingIntent(R.id.coins_id, pendingIntent);

    views.setTextViewText(R.id.profit_id, apiService.getProfit() + "%");
    //views.setOnClickPendingIntent(R.id.profit_id, pendingIntent);

    views.setTextViewText(R.id.dateTime_id, "Last updated " + dtf.format(now).toString());
    //views.setOnClickPendingIntent(R.id.profit_id, pendingIntent);
    
 
   

    for (int appWidgetId: appWidgetIds) {
      appWidgetManager.updateAppWidget(appWidgetId, views);

    }
  }
}