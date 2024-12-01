from flask import Flask, render_template, request
import yfinance as yf
import numpy as np
from sklearn.linear_model import LinearRegression
import boto3
from datetime import datetime
import os
import json

app = Flask(__name__)

# Example lists, replace with real data if necessary
etf_list = ['SPY', 'IVV', 'VTI', 'XLF', 'QQQ', 'XLB', 'XLY', 'VOO', 'XLB', 'XLC']
crypto_list = ['BTC-USD', 'ETH-USD', 'BNB-USD', 'SOL-USD', 'ADA-USD', 'XRP-USD', 'DOGE-USD', 'LTC-USD', 'DOT-USD', 'TRX-USD']
commodity_list = ['GC=F', 'SI=F']  # Gold and Silver futures

# AWS SNS Client
sns_client = boto3.client('sns', region_name='us-east-1')  # Update with your region
topic_arn = 'arn:aws:sns:us-east-1:your-account-id:your-topic'  # Replace with your SNS Topic ARN

@app.route('/', methods=['GET', 'POST'])
def index():
    predicted_value = None
    stock_ticker = None

    if request.method == 'POST':
        stock_ticker = request.form['stock']
        predicted_value = get_stock_data(stock_ticker)

    # Updated lists for different categories
    stock_list = ['INTC', 'AAPL', 'GOOGL', 'AMZN', 'MSFT', 'TSLA', 'FB', 'NFLX', 'NVDA', 'BABA']
    stock_predictions = {
        'stocks': {ticker: get_stock_data(ticker) for ticker in stock_list},
        'etfs': {etf: get_stock_data(etf) for etf in etf_list},
        'cryptos': {crypto: get_stock_data(crypto) for crypto in crypto_list},
        'commodities': {commodity: get_stock_data(commodity) for commodity in commodity_list}
    }

    return render_template('index.html', predicted_value=predicted_value, stock_ticker=stock_ticker,
                           stock_predictions=stock_predictions)

def get_stock_data(ticker):
    try:
        stock_data = yf.download(ticker, period='5d', interval='1d')
        if len(stock_data) < 2:
            return {
                "yesterday": "N/A",
                "today": "N/A",
                "predicted_tomorrow": {
                    "value": "N/A",
                    "sign": "",
                    "color": "black"
                }
            }

        prices = stock_data['Close'].values[-2:]
        X = np.array([1, 2]).reshape(-1, 1)
        y = prices
        model = LinearRegression()
        model.fit(X, y)
        next_day = np.array([[3]])
        predicted_price = model.predict(next_day)[0]

        sign = "+" if predicted_price > prices[1] else "-"
        color = "green" if predicted_price > prices[1] else "red"

        return {
            "yesterday": round(prices[0], 2),
            "today": round(prices[1], 2),
            "predicted_tomorrow": {
                "value": round(predicted_price, 2),
                "sign": sign,
                "color": color
            }
        }
    except Exception:
        return {
            "yesterday": "N/A",
            "today": "N/A",
            "predicted_tomorrow": {
                "value": "N/A",
                "sign": "",
                "color": "black"
            }
        }

def fetch_app_data():
    stock_predictions = [get_stock_data(ticker) for ticker in stock_list]
    most_valuable_stock = max(stock_predictions, key=lambda x: x['predicted_tomorrow'] if x['predicted_tomorrow'] != "N/A" else float('-inf'))
    return {
        "timestamp": str(datetime.now()),
        "stock_predictions": stock_predictions,
        "most_valuable_stock": most_valuable_stock
    }

def format_message(data):
    message = f"\nDaily Stock Report:\n"
    message += f"Timestamp: {data['timestamp']}\n\n"
    message += "Stock Predictions:\n"
    for stock in data['stock_predictions']:
        message += f"Ticker: {stock['ticker']}, Yesterday: {stock['yesterday']}, Today: {stock['today']}, Predicted Tomorrow: {stock['predicted_tomorrow']}\n"
    message += f"\nMost Valuable Stock to Buy: {data['most_valuable_stock']['ticker']} (Predicted Price: {data['most_valuable_stock']['predicted_tomorrow']})\n"
    return message

def send_email_via_sns(subject, message):
    try:
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject
        )
        print(f"Message sent. ID: {response['MessageId']}")
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        
#cronjob command : crontab -e
#cronjob edit: 0 14 * * * /usr/bin/python3 /home/ec2-user/cron_email_script.py >> /home/ec2-user/cron_log.txt 2>&1
#cronjob test : crontab -l

def main():
    app_data = fetch_app_data()
    email_subject = "Daily Stock Predictions Report"
    email_message = format_message(app_data)
    send_email_via_sns(email_subject, email_message)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8000)
