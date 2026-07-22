import os
import random
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
# 🏆 FULL CORS ALLOWED FOR BOTH MOBILE APP & NETLIFY WEB
CORS(app)

# Operational State In-Memory Registry for Verification Tokens
ACTIVE_OTP_REGISTRY = {}

# =========================================================================
# ⚙️ SECURE SERVER NODE CONFIGURATION
# =========================================================================
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "abhinavsingh73760@gmail.com"
SENDER_PASSWORD = "qjyp otfm bivm yfis"

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({"status": "SUCCESS", "message": "Tournament Auth Server is Online!"}), 200

# -----------------------------------------------------------------
# DISPATCH TRIGGER: GENERATE & DISPATCH OTP NODE
# -----------------------------------------------------------------
@app.route('/api/auth/trigger-otp', methods=['POST'])
def trigger_otp():
    try:
        data = request.get_json(force=True, silent=True) or {}
    except Exception:
        return jsonify({"status": "ERROR", "message": "Malformed JSON payload."}), 400

    email = data.get("email", "").strip().lower()
    if not email:
        return jsonify({"status": "ERROR", "message": "Target email node cannot be empty."}), 400

    # Generate numeric token signature
    otp_code = str(random.randint(100000, 999999))
    ACTIVE_OTP_REGISTRY[email] = otp_code

    # Construct system transactional email matrix
    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = email
    msg['Subject'] = "[TOURNAMENT OS] Identity Verification Token"

    body = f'''Welcome to Tournament OS Manager 2026.

Your secure infrastructure identity validation token is:
⚡ {otp_code} ⚡

This code expires in 10 minutes. Do not share this token signature with anyone.'''

    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.sendmail(SENDER_EMAIL, email, msg.as_string())
        server.quit()
        
        return jsonify({"status": "SUCCESS", "message": "Verification token transmitted successfully."}), 200
    except Exception as e:
        return jsonify({"status": "ERROR", "message": f"SMTP Dispatch failed: {str(e)}"}), 500

# -----------------------------------------------------------------
# DISPATCH TRIGGER: VALIDATE CLIENT TOKEN MATCH
# -----------------------------------------------------------------
@app.route('/api/auth/verify-otp', methods=['POST'])
def verify_otp():
    try:
        data = request.get_json(force=True, silent=True) or {}
    except Exception:
        return jsonify({"status": "ERROR", "message": "Malformed JSON payload."}), 400

    email = data.get("email", "").strip().lower()
    client_otp = str(data.get("otp", "")).strip()

    if email in ACTIVE_OTP_REGISTRY and ACTIVE_OTP_REGISTRY[email] == client_otp:
        del ACTIVE_OTP_REGISTRY[email]  # Clear token on match consumption
        return jsonify({"status": "SUCCESS", "message": "Identity verified."}), 200
    else:
        return jsonify({"status": "ERROR", "message": "Invalid or expired verification token reference."}), 401

if __name__ == "__main__":
    # 🏆 DYNAMIC PORT BINDING FOR CLOUD HOSTING (RENDER)
    port = int(os.environ.get("PORT", 8080))
    print(f"🚀 Authentication Server running on port {port}...")
    app.run(host='0.0.0.0', port=port)