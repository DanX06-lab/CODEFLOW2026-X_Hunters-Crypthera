from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os

app = Flask(__name__)
CORS(app)

COINS = {
    "btc": "bitcoin",
    "bitcoin": "bitcoin",
    "eth": "ethereum",
    "ethereum": "ethereum",
    "matic": "matic-network",
    "polygon": "matic-network",
    "sol": "solana",
    "solana": "solana",
    "usdc": "usd-coin"
}

APP_KNOWLEDGE = {
    "vaultx": "VaultX is an AI-powered Web3 wallet with built-in crypto inheritance protection.",
    "usp": "VaultX's USP is a real crypto wallet with a silent inheritance layer and AI market protection.",
    "inactivity": "VaultX tracks check-ins and wallet usage. If inactive, the vault enters warning mode before claim.",
    "beneficiary": "A beneficiary is a trusted person who receives crypto after inactivity and grace period rules.",
    "security": "VaultX is non-custodial. It does not store private keys. Users confirm actions through their wallet.",
    "smart swap": "Smart Swap suggests converting volatile crypto like ETH into stablecoins like USDC during market crashes.",
    "false release": "False release risk is reduced using reminders, warning period, grace period, and optional guardian approval."
}


def get_market_data(coin_ids):
    url = "https://api.coingecko.com/api/v3/simple/price"
    params = {
        "ids": ",".join(coin_ids),
        "vs_currencies": "usd,inr",
        "include_24hr_change": "true",
        "include_market_cap": "true",
        "include_24hr_vol": "true"
    }

    response = requests.get(url, params=params, timeout=10)
    response.raise_for_status()
    return response.json()


def get_fear_greed():
    try:
        url = "https://api.alternative.me/fng/"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()["data"][0]

        return {
            "value": data["value"],
            "classification": data["value_classification"]
        }
    except Exception:
        return {
            "value": "N/A",
            "classification": "Unavailable"
        }


def risk_level(change):
    if change <= -15:
        return "High Risk"
    elif change <= -7:
        return "Medium Risk"
    elif change >= 10:
        return "High Volatility"
    return "Normal"


def get_coin_from_message(message):
    for key, coin_id in COINS.items():
        if key in message:
            return coin_id
    return "ethereum"


def analyze_market(message):
    coin = get_coin_from_message(message)

    try:
        data = get_market_data([coin])[coin]

        price = data.get("usd")
        inr = data.get("inr")
        change = data.get("usd_24h_change", 0)
        volume = data.get("usd_24h_vol")
        market_cap = data.get("usd_market_cap")

        risk = risk_level(change)

        if change <= -15:
            suggestion = "Strong downside movement detected. VaultX may suggest stablecoin protection like Smart Swap."
        elif change <= -7:
            suggestion = "Moderate market drop detected. Monitoring and partial protection may be useful."
        elif change >= 10:
            suggestion = "Strong upward movement detected, but volatility risk is high."
        else:
            suggestion = "Market is currently stable. No urgent vault protection action needed."

        return f"""
Live Market Analysis

Coin: {coin}
Price: ${price}
Price in INR: ₹{inr}
24h Change: {round(change, 2)}%
Market Cap: ${round(market_cap, 2) if market_cap else "N/A"}
24h Volume: ${round(volume, 2) if volume else "N/A"}
Risk Level: {risk}

VaultX AI Suggestion:
{suggestion}

Disclaimer: Market information only, not financial advice.
"""

    except Exception as e:
        return f"Market API error: {str(e)}"


def daily_briefing():
    try:
        coins = ["bitcoin", "ethereum", "solana", "matic-network", "usd-coin"]
        data = get_market_data(coins)
        sentiment = get_fear_greed()

        lines = []

        for coin in coins:
            c = data[coin]
            change = c.get("usd_24h_change", 0)

            lines.append(
                f"- {coin}: ${c.get('usd')} | 24h: {round(change, 2)}% | Risk: {risk_level(change)}"
            )

        return f"""
VaultX Daily Market Briefing

Market Sentiment:
Fear & Greed Index: {sentiment['value']} / 100
Classification: {sentiment['classification']}

Top Asset Watch:
{chr(10).join(lines)}

VaultX AI Summary:
If major assets show sharp downside movement, VaultX can suggest Smart Swap protection from volatile assets into stablecoins.

Disclaimer: This is market information, not financial advice.
"""

    except Exception as e:
        return f"Daily briefing error: {str(e)}"


def compare_coins():
    try:
        data = get_market_data(["bitcoin", "ethereum"])

        btc = data["bitcoin"]
        eth = data["ethereum"]

        btc_change = btc.get("usd_24h_change", 0)
        eth_change = eth.get("usd_24h_change", 0)

        better = "Bitcoin" if btc_change > eth_change else "Ethereum"

        return f"""
BTC vs ETH Comparison

Bitcoin:
Price: ${btc.get('usd')}
24h Change: {round(btc_change, 2)}%
Risk: {risk_level(btc_change)}

Ethereum:
Price: ${eth.get('usd')}
24h Change: {round(eth_change, 2)}%
Risk: {risk_level(eth_change)}

VaultX AI View:
{better} is performing better in the last 24 hours.
BTC is usually treated as the market leader, while ETH is more connected to DeFi and smart contract activity.

Disclaimer: This is comparison information, not financial advice.
"""

    except Exception as e:
        return f"Comparison error: {str(e)}"


def risk_alert(message):
    coin = get_coin_from_message(message)

    try:
        data = get_market_data([coin])[coin]
        change = data.get("usd_24h_change", 0)

        if change <= -15:
            alert = "CRITICAL ALERT: Heavy market drop detected."
        elif change <= -7:
            alert = "WARNING: Medium downside movement detected."
        elif change >= 10:
            alert = "VOLATILITY ALERT: Strong upward movement detected."
        else:
            alert = "NORMAL: No major risk alert right now."

        return f"""
VaultX Risk Alert

Asset: {coin}
24h Change: {round(change, 2)}%
Status: {alert}

VaultX Protection Logic:
During high-risk market drops, VaultX can suggest Smart Swap protection into USDC to reduce vault value loss.
"""

    except Exception as e:
        return f"Risk alert error: {str(e)}"


def crash_simulation(message):
    coin = get_coin_from_message(message)

    try:
        data = get_market_data([coin])[coin]
        price = data.get("usd")

        crash_10 = price * 0.90
        crash_20 = price * 0.80
        crash_30 = price * 0.70

        return f"""
VaultX Crash Simulation

Asset: {coin}
Current Price: ${price}

If market drops:
- 10% crash: ${round(crash_10, 2)}
- 20% crash: ${round(crash_20, 2)}
- 30% crash: ${round(crash_30, 2)}

VaultX AI View:
Crash simulation helps users understand how much vault value may be affected during extreme volatility.
Smart Swap can be used as a protection feature during heavy downside risk.

Disclaimer: This is simulation only, not financial advice.
"""

    except Exception as e:
        return f"Crash simulation error: {str(e)}"


def crypto_news_analysis():
    try:
        url = "https://min-api.cryptocompare.com/data/v2/news/"
        params = {
            "lang": "EN"
        }

        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()

        news_data = response.json().get("Data", [])[:5]

        if not news_data:
            return "No crypto news found right now."

        headlines = []

        negative_words = [
            "crash", "hack", "ban", "lawsuit", "fraud",
            "drop", "collapse", "liquidation", "bearish", "scam"
        ]

        positive_words = [
            "surge", "rise", "approval", "growth", "adoption",
            "bullish", "rally", "partnership", "launch"
        ]

        score = 0

        for item in news_data:
            title = item.get("title", "")
            source = item.get("source_info", {}).get("name", "Unknown Source")

            lower_title = title.lower()

            for word in positive_words:
                if word in lower_title:
                    score += 1

            for word in negative_words:
                if word in lower_title:
                    score -= 1

            headlines.append(f"- {title} ({source})")

        if score > 1:
            sentiment = "Bullish / Positive"
        elif score < -1:
            sentiment = "Bearish / Risky"
        else:
            sentiment = "Neutral / Mixed"

        return f"""
VaultX Crypto News Analysis

Latest Headlines:
{chr(10).join(headlines)}

News Sentiment:
{sentiment}

VaultX AI View:
News sentiment helps VaultX understand short-term market risk.
If negative news combines with heavy price drops, VaultX may suggest Smart Swap protection.

Disclaimer: This is automated news analysis, not financial advice.
"""

    except Exception as e:
        return f"News analysis error: {str(e)}"


def explain_app(message):
    for key, value in APP_KNOWLEDGE.items():
        if key in message:
            return value

    return """
I can help with:
- Live market analysis
- Daily market briefing
- BTC vs ETH comparison
- Fear & Greed sentiment
- Risk alerts
- Crash simulation
- Crypto news analysis
- VaultX, USP, inactivity, beneficiaries, security, Smart Swap, and false release risk
"""


@app.route("/chart/<coin>", methods=["GET"])
def chart_data(coin):
    coin_map = {
        "eth": "ethereum",
        "ethereum": "ethereum",
        "btc": "bitcoin",
        "bitcoin": "bitcoin",
        "sol": "solana",
        "solana": "solana",
        "matic": "matic-network",
        "polygon": "matic-network"
    }

    coin_id = coin_map.get(coin.lower(), "ethereum")

    try:
        url = f"https://api.coingecko.com/api/v3/coins/{coin_id}/market_chart"
        params = {
            "vs_currency": "usd",
            "days": "7"
        }

        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()

        labels = []
        values = []

        for item in data.get("prices", []):
            labels.append(item[0])
            values.append(round(item[1], 2))

        return jsonify({
            "coin": coin_id,
            "labels": labels,
            "prices": values
        })

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500


@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    message = data.get("message", "").lower()

    if "news" in message or "headline" in message:
        reply = crypto_news_analysis()
    elif "briefing" in message or "daily" in message:
        reply = daily_briefing()
    elif "compare" in message or "btc vs eth" in message:
        reply = compare_coins()
    elif "alert" in message or "risk" in message:
        reply = risk_alert(message)
    elif "crash" in message or "simulation" in message:
        reply = crash_simulation(message)
    elif any(word in message for word in ["price", "market", "analyze", "btc", "eth", "matic", "sol", "usdc"]):
        reply = analyze_market(message)
    else:
        reply = explain_app(message)

    return jsonify({"reply": reply})


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "VaultX Guardian AI backend is running",
        "features": [
            "Live market analysis",
            "Daily market briefing",
            "BTC vs ETH comparison",
            "Fear & Greed sentiment",
            "Risk alerts",
            "Crash simulation",
            "Crypto news analysis",
            "7-day chart API",
            "VaultX project explanation"
        ]
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5000)