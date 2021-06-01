package com.wallet_tracket.wallet_tracket;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.os.AsyncTask;


class ApiService extends AsyncTask<Void, Void, Void> {
   public static String coins = "";
   public static String balance = "";
   public static String profit = "";
   public static String currency = "";

   public void setCoins(String coins){
        this.coins=coins;
    }

    public String getCoins(){
        return coins;
    }
    public void setBalance(String balance){
        this.balance=balance;
    }

    public String getBalance(){
        return balance;
    }
    
    public String getCurrency(){
        return currency;
    }
    
    public void setCurrency(String currency){
        this.currency=currency;
    }
    
    public String getProfit(){
        return profit;
    }
    
    public void setProfit(float profit){
        if(profit>0)
            this.profit = "+"+Float.toString(profit);
        else
            this.profit = "-"+Float.toString(profit);

    }
    
  
    
    @Override
    protected Void doInBackground(Void... voids) {
        HttpURLConnection urlConnection = null;
        URL url = null;
        JSONObject object = null;
        JSONArray myArray = null;
        InputStream inStream = null;
    
        try {
            url = new URL("http://162.55.32.207/123456/EUR/light.json");
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("GET");
            
            urlConnection.setRequestProperty("accept", "application/json");
            inStream = urlConnection.getInputStream();
           BufferedReader bReader = new BufferedReader(new InputStreamReader(inStream));
            String temp, response = "";
            while ((temp = bReader.readLine()) != null) {
                response += temp;
            }
    
            object = (JSONObject) new JSONTokener(response).nextValue();
            //JSONObject obj = object.getJSONObject();
            String data1 = object.getString("coins");
            String data2 = object.getString("balance");
            String data3 = object.getString("currency");
            String data4 = object.getString("balance_24h");
            setCoins(data1);
            setBalance(data2);
            setCurrency(data3);
            System.out.println(data4);
            float v1 = Float.parseFloat(data2);
            float v2 = Float.parseFloat(data4);
            float v3 = (v1 - v2)*100/Math.abs(v1);
           
            setProfit(v3);

        } catch (Exception e) {
            System.out.println(e.toString());
        } finally {
            if (inStream != null) {
                try {
                    inStream.close();
                } catch (IOException ignored) {
    
                }
            }
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
        return null;
    }

    
    
}