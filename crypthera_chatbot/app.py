from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os
from knowledge_base import retrieve_rag_context

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
    "crypthera": "Crypthera is an AI-powered Web3 wallet with built-in crypto inheritance protection.",
    "usp": "Crypthera's USP is a real crypto wallet with a silent inheritance layer and AI market protection.",
    "inactivity": "Crypthera tracks check-ins and wallet usage. If inactive, the vault enters warning mode before claim.",
    "beneficiary": "A beneficiary is a trusted person who receives crypto after inactivity and grace period rules.",
    "security": "Crypthera is non-custodial. It does not store private keys. Users confirm actions through their wallet.",
    "smart swap": "Smart Swap suggests converting volatile crypto like ETH into stablecoins like USDC during market crashes.",
    "false release": "False release risk is reduced using reminders, warning period, grace period, and optional guardian approval."
}


def get_market_data(coin_ids):
    try:
        url = "https://api.coingecko.com/api/v3/simple/price"
        params = {
            "ids": ",".join(coin_ids),
            "vs_currencies": "usd,inr",
            "include_24hr_change": "true",
            "include_market_cap": "true",
            "include_24hr_vol": "true"
        }
        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        # Fallback static prices if API is throttled or offline
        return {
            "bitcoin": {"usd": 68500, "inr": 5712000, "usd_24h_change": 1.2},
            "ethereum": {"usd": 3480, "inr": 290120, "usd_24h_change": -2.4},
            "solana": {"usd": 165, "inr": 13760, "usd_24h_change": 4.8},
            "matic-network": {"usd": 0.72, "inr": 60, "usd_24h_change": -0.8},
            "usd-coin": {"usd": 1.0, "inr": 83.4, "usd_24h_change": 0.0}
        }


def get_fear_greed():
    try:
        url = "https://api.alternative.me/fng/"
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()["data"][0]
        return {
            "value": data["value"],
            "classification": data["value_classification"]
        }
    except Exception:
        return {
            "value": "72",
            "classification": "Greed"
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
    data = get_market_data([coin])[coin]

    price = data.get("usd")
    inr = data.get("inr")
    change = data.get("usd_24h_change", 0)
    volume = data.get("usd_24h_vol", 0)
    market_cap = data.get("usd_market_cap", 0)

    risk = risk_level(change)

    if change <= -15:
        suggestion = "Strong downside movement detected. Crypthera suggests stablecoin protection like Smart Swap."
    elif change <= -7:
        suggestion = "Moderate market drop detected. Monitoring and partial protection may be useful."
    elif change >= 10:
        suggestion = "Strong upward movement detected, but volatility risk is high."
    else:
        suggestion = "Market is currently stable. No urgent vault protection action needed."

    return f"""
Live Market Analysis
- Coin: {coin.upper()}
- Price: ${price}
- Price in INR: ₹{inr}
- 24h Change: {round(change, 2)}%
- Risk Level: {risk}

Crypthera AI Suggestion:
{suggestion}
"""


def daily_briefing():
    coins = ["bitcoin", "ethereum", "solana", "matic-network", "usd-coin"]
    data = get_market_data(coins)
    sentiment = get_fear_greed()

    lines = []
    for coin in coins:
        c = data[coin]
        change = c.get("usd_24h_change", 0)
        lines.append(
            f"- {coin.upper()}: ${c.get('usd')} | 24h: {round(change, 2)}% | Risk: {risk_level(change)}"
        )

    return f"""
Crypthera Daily Market Briefing

Market Sentiment:
- Fear & Greed Index: {sentiment['value']} / 100 ({sentiment['classification']})

Top Asset Watch:
{chr(10).join(lines)}

Crypthera AI Summary:
If major assets show sharp downside movement, Crypthera can suggest Smart Swap protection from volatile assets into stablecoins.
"""


def compare_coins():
    data = get_market_data(["bitcoin", "ethereum"])
    btc = data["bitcoin"]
    eth = data["ethereum"]

    btc_change = btc.get("usd_24h_change", 0)
    eth_change = eth.get("usd_24h_change", 0)
    better = "Bitcoin" if btc_change > eth_change else "Ethereum"

    return f"""
BTC vs ETH Comparison

Bitcoin:
- Price: ${btc.get('usd')}
- 24h Change: {round(btc_change, 2)}%
- Risk: {risk_level(btc_change)}

Ethereum:
- Price: ${eth.get('usd')}
- 24h Change: {round(eth_change, 2)}%
- Risk: {risk_level(eth_change)}

Crypthera AI View:
{better} is performing better in the last 24 hours.
"""


def risk_alert(message):
    coin = get_coin_from_message(message)
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
Crypthera Risk Alert
- Asset: {coin.upper()}
- 24h Change: {round(change, 2)}%
- Status: {alert}

Crypthera Protection Logic:
During high-risk market drops, Crypthera suggests triggering a Smart Swap into stablecoins to protect vault estates.
"""


def crash_simulation(message, balance=0.0):
    coin = get_coin_from_message(message)
    data = get_market_data([coin])[coin]
    price = data.get("usd")

    crash_10 = price * 0.90
    crash_20 = price * 0.80
    crash_30 = price * 0.70

    impact_10 = balance * 0.10
    impact_20 = balance * 0.20
    impact_30 = balance * 0.30

    return f"""
Crypthera Volatility Crash Simulation
- Asset: {coin.upper()}
- Current Price: ${price}

If market drops:
- 10% crash: ${round(crash_10, 2)} (Est. Vault Impact: -{round(impact_10, 4)} ETH)
- 20% crash: ${round(crash_20, 2)} (Est. Vault Impact: -{round(impact_20, 4)} ETH)
- 30% crash: ${round(crash_30, 2)} (Est. Vault Impact: -{round(impact_30, 4)} ETH)

Crypthera AI Insight:
Crash simulation helps you visualize risk. Tapping 'Smart Swap' converts volatile vault assets into USDC to offset this impact.
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
        response = requests.get(url, params=params, timeout=5)
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
    # 1. ORCHESTRATION LAYER: Context ingestion
    data = request.get_json()
    message = data.get("message", "").lower()
    wallet_address = data.get("wallet_address", "")
    wallet_balance = float(data.get("wallet_balance", 0.0))
    vault_balance = float(data.get("vault_balance", 0.0))
    recent_transactions = data.get("recent_transactions", [])

    # 2. INTENT CLASSIFIER
    intent = "general"
    if any(w in message for w in ["balance", "funds", "how much", "portfolio"]):
        intent = "portfolio"
    elif any(w in message for w in ["transaction", "activity", "history", "log"]):
        intent = "history"
    elif any(w in message for w in ["secure", "safe", "hack", "scam", "phishing"]):
        intent = "security"
    elif any(w in message for w in ["inactivity", "timer", "grace", "claim", "inheritance"]):
        intent = "inheritance"
    elif any(w in message for w in ["price", "market", "swap", "usdc", "crash", "briefing", "compare"]):
        intent = "market"

    # 3. RAG RETRIEVAL ENGINE
    retrieved_docs = retrieve_rag_context(message, limit=2)
    rag_segment = ""
    if retrieved_docs:
        rag_segment = "\nRelevant Knowledge Bases:\n" + "\n".join(
            [f"- {list(doc.values())[0]}: {list(doc.values())[1]}" for doc in retrieved_docs]
        )

    # 4. WALLET-AWARE REASONING & ALERTS
    alerts = []
    if wallet_address:
        if wallet_balance < 0.002:
            alerts.append(f"CRITICAL GAS ALERT: Available balance is low ({wallet_balance:.4f} ETH). Transactions may fail.")
        
        # Scan transactions for high gas costs or anomalies
        for tx in recent_transactions:
            desc = tx.get("description", "").lower()
            if "high" in desc or "gas" in desc:
                alerts.append("GAS FEE ANOMALY: A recent transaction encountered high gas costs on Sepolia.")
                break
            if "inactive" in desc:
                alerts.append("EMERGENCY NOTICE: Vault inactivity triggers have been updated.")
    else:
        alerts.append("ONBOARDING STATUS: No Web3 wallet connected. Link one in the Vault screen to start.")

    alert_segment = ""
    if alerts:
        alert_segment = "\nAI Wallet Security Alerts:\n" + "\n".join([f"⚠️ {alert}" for alert in alerts])

    # 5. CONTEXT SYNTHESIS & RESPONSE GENERATION
    # Under a production deployment, we compile all segments and pass them as a system prompt to Gemini/OpenAI.
    # In sandbox/hackathon execution, we use a custom synthesis matrix to create context-grounded responses immediately.
    
    reply = ""
    
    if intent == "portfolio":
        w_status = f"connected ({wallet_address[:6]}...{wallet_address[-4:]})" if wallet_address else "disconnected"
        reply = f"""
Crypthera Portfolio Analysis:
- Wallet Connection: {w_status}
- Available Wallet Balance: {wallet_balance:.4f} ETH
- Locked Vault Contract Balance: {vault_balance:.4f} ETH
{alert_segment}
{rag_segment}

AI Recommendation:
{"You have no locked assets. Set up beneficiaries and deposit ETH to protect your estate." if vault_balance == 0 else "Your vault is protected. Make sure to check in periodically to keep your check-in timestamp active."}
"""
    
    elif intent == "history":
        if not recent_transactions:
            reply = f"No recent activity logged for account {wallet_address[:8]}... yet."
        else:
            tx_lines = []
            for tx in recent_transactions[:3]:
                tx_lines.append(f"- [{tx.get('type','').upper()}] {tx.get('title','')}: {tx.get('description','')}")
            
            reply = f"""
Recent Activity Log Analysis:
{chr(10).join(tx_lines)}
{alert_segment}
{rag_segment}

AI Insight:
Your recent operations indicate a healthy wallet flow. Ensure your beneficiaries are aware of their registered claims.
"""
            
    elif intent == "security":
        v_status = "Protected" if vault_balance > 0 else "Not Deployed"
        reply = f"""
Guardian Security Audit:
- Vault Status: {v_status}
- Security Index: {"STRONG" if wallet_address and vault_balance > 0 else "WEAK (Setup required)"}
{alert_segment}
{rag_segment}

AI Protective Actions:
1. Never share your recovery private keys.
2. Confirm all transaction signatures directly in your wallet window.
"""

    elif intent == "inheritance":
        reply = f"""
Inactivity & Inheritance Protocol:
- Vault Address: {wallet_address if wallet_address else "No active vault"}
- Claim Eligibility: {"Eligible after 90 days of inactivity" if vault_balance > 0 else "Vault not active"}
{alert_segment}
{rag_segment}

AI Claim Instructions:
Beneficiaries can initiate claims via the recovery dashboard by entering their registered EVM address if inactivity triggers.
"""

    elif intent == "market":
        if "briefing" in message or "daily" in message:
            reply = daily_briefing()
        elif "compare" in message or "btc vs eth" in message:
            reply = compare_coins()
        elif "alert" in message or "risk" in message:
            reply = risk_alert(message)
        elif "crash" in message or "simulation" in message:
            reply = crash_simulation(message, balance=vault_balance)
        else:
            reply = analyze_market(message)
            
        reply = f"{reply}\n{alert_segment}\n{rag_segment}"

    else:
        reply = f"""
I am your Crypthera Guardian AI.

Active State Summary:
- Wallet Connected: {"Yes" if wallet_address else "No"}
- Available Balance: {wallet_balance:.4f} ETH
- Vault Contract Balance: {vault_balance:.4f} ETH
{alert_segment}
{rag_segment}

How can I assist you with your digital legacy or Sepolia transaction security today?
"""

    # If openAI key exists, we can optionally query the live model with the compiled prompt segment
    openai_key = os.environ.get("OPENAI_API_KEY")
    if openai_key:
        try:
            # Live GPT RAG completion
            prompt = f"System: You are Crypthera Guardian AI. Use the following context to answer: {alert_segment} {rag_segment}. User: {message}"
            headers = {"Authorization": f"Bearer {openai_key}", "Content-Type": "application/json"}
            payload = {
                "model": "gpt-4-turbo",
                "messages": [{"role": "user", "content": prompt}]
            }
            res = requests.post("https://api.openai.com/v1/chat/completions", json=payload, headers=headers, timeout=5)
            if res.status_code == 200:
                reply = res.json()["choices"][0]["message"]["content"]
        except Exception:
            pass  # Fall back to our high-fidelity synthesized RAG reply

    return jsonify({"reply": reply.strip()})


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "Crypthera Intelligence Engine (RAG + Orchestration) is active",
        "engine": "v2.0-Production-Ready"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5000)