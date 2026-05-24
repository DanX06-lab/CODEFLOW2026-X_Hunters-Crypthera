import re
import math

# Crypthera RAG Datasets
KNOWLEDGE_BASE = {
    "crypto_terms": [
        {
            "term": "EVM (Ethereum Virtual Machine)",
            "context": "The EVM is the global decentralized computer that executes smart contracts on Ethereum and EVM-compatible chains like Sepolia, Polygon, and BSC."
        },
        {
            "term": "Non-Custodial Wallet",
            "context": "A non-custodial wallet gives the user full control of private keys and funds. No third party (like an exchange or bank) can freeze, recovery, or access the account assets."
        },
        {
            "term": "ERC-20 Token Standard",
            "context": "ERC-20 is the official Ethereum standard for fungible tokens (like USDT, USDC, and LINK). It defines standard transfer, balance, and allowance contract interfaces."
        }
    ],
    "blockchain_security": [
        {
            "topic": "Private Key Backup",
            "context": "Private keys must be secured in offline environments (like hardware enclaves, paper, or metal backups). Never store keys in plaintext or share them with unauthorized parties."
        },
        {
            "topic": "Phishing Protection",
            "context": "Phishing scams impersonate legitimate wallets (like Metamask) to steal seed phrases. Verify all URL origins before signing smart contract interactions."
        },
        {
            "topic": "Non-Custodial Inheritance Claims",
            "context": "Crypthera ensures that inheritance claims are only validated when owner inactivity is mathematically verified on-chain, eliminating unauthorized premature recovery."
        }
    ],
    "gas_fee_knowledge": [
        {
            "topic": "Ethereum Gas Fees",
            "context": "Gas fees represent the transaction computational cost on Ethereum. Standard transfers require 21,000 gas, while complex smart contract interactions require significantly more gas."
        },
        {
            "topic": "Sepolia Testnet Gas",
            "context": "Sepolia transactions use Sepolia ETH (sETH), which has no real monetary value. sETH can be acquired for free from faucets to test contract interaction states."
        },
        {
            "topic": "Gas Spikes & Network Congestion",
            "context": "When network usage increases, gas prices spike. High gas price bids (measured in Gwei) expedite transaction confirmation times but increase the total ether cost."
        }
    ],
    "inheritance_vault_docs": [
        {
            "topic": "Inactivity Duration Rules",
            "context": "Crypthera's Vault smart contract initializes a standard inactivity clock (e.g., 90 days). The timer resets with every transaction or check-in completed by the owner."
        },
        {
            "topic": "Grace & Warning Periods",
            "context": "If the inactivity timer expires, the vault enters Warning Mode. The owner has a grace window to check in before beneficiaries become eligible to claim allocations."
        },
        {
            "topic": "On-chain Claim Execution",
            "context": "Beneficiary claims execute on-chain via the 'claimFunds' contract method, distributing locked assets directly to registered recipient wallets according to percentages."
        }
    ],
    "wallet_risk_patterns": [
        {
            "risk": "Low Wallet Balance Alert",
            "context": "Active wallets with less than 0.002 ETH risk failing future transactions. Maintain a gas buffer to execute emergency check-ins or reset inactivity protocols."
        },
        {
            "risk": "Address Reuse & Clean Transfers",
            "context": "Interacting frequently with newly observed or unverified external addresses increases exposure to malware or accidental destination typos."
        },
        {
            "risk": "High Fee Outliers",
            "context": "Transactions bidding gas fees 3x higher than the daily network average are flagged as fee outliers, indicating inefficient gas configuration."
        }
    ],
    "portfolio_guidance": [
        {
            "strategy": "Smart Swap Volatility Shield",
            "context": "Crypthera's Smart Swap shifts volatile ETH, SOL, or MATIC vault assets into stablecoins like USDC during market crashes to preserve inheritance estate valuations."
        },
        {
            "strategy": "Asset Allocation Splits",
            "context": "Distributing inheritance percentages across multiple beneficiaries reduces asset centralization risks and aligns distribution with family estate planning goals."
        }
    ],
    "smart_contract_basics": [
        {
            "topic": "Smart Contract Immutability",
            "context": "Once compiled and deployed to the Ethereum blockchain, smart contract bytecode is immutable. No party, including the developers, can alter its code or rules."
        },
        {
            "topic": "EVM State Variables",
            "context": "Smart contracts store state variables (like balances and check-in times) directly in blockchain storage slots. Read queries are free, but write operations consume gas."
        }
    ],
    "scam_detection_knowledge": [
        {
            "scam": "Dusting Attack Warning",
            "context": "Dusting attacks send tiny fractions of tokens (dust) to random wallets to trace transaction networks. Avoid interacting with, transferring, or selling unknown dust assets."
        },
        {
            "scam": "Approval Exploit Hazards",
            "context": "Scam websites solicit unlimited token approvals (allowance) to drain wallet balances later. Regularly inspect and revoke token allowances using approval audit tools."
        }
    ]
}

# Helpers for tokenizing text
def tokenize(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    return set(text.split())

# Retrieve dynamic RAG context matching user query
def retrieve_rag_context(query, limit=3):
    query_tokens = tokenize(query)
    if not query_tokens:
        return []

    scored_documents = []

    for category, docs in KNOWLEDGE_BASE.items():
        for doc in docs:
            # Combine all document content to analyze relevance
            doc_content = " ".join(doc.values())
            doc_tokens = tokenize(doc_content)
            
            # Simple Jaccard similarity score (token overlap)
            intersection = query_tokens.intersection(doc_tokens)
            union = query_tokens.union(doc_tokens)
            
            if intersection:
                score = len(intersection) / len(union)
                scored_documents.append((score, doc, category))

    # Sort documents descending by similarity score
    scored_documents.sort(key=lambda x: x[0], reverse=True)
    
    return [doc for _, doc, _ in scored_documents[:limit]]
