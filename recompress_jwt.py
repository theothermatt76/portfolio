import zlib
import base64
import json

# recompress JSON into a encoded and flattened JWT. this doesn't do signing, if you need that look at the other script

def compress_to_token(data: dict) -> str:
    """
    Compress JSON data → zlib → base64url (no padding '=')
    Returns a string you can prefix with '.' if desired.
    """
    # Convert to compact JSON (no extra whitespace)
    json_str = json.dumps(data, separators=(',', ':'), sort_keys=True)
    
    # Compress with zlib (default level=6 is fine)
    compressed = zlib.compress(json_str.encode('utf-8'))
    
    # Base64url encode and remove padding
    b64 = base64.urlsafe_b64encode(compressed).decode('ascii').rstrip('=')
    
    return b64

# Example usage
payload = {
    "_permanent": "True",
    "company": "Guest Company",
    "email": "guest@router-resellers.com",
    "name": "Guest User",
    "role": "admin",
    "user_id": "USR_001"
}

token_payload = compress_to_token(payload)

# Many systems prefix with a dot when storing in cookie
full_token = f".{token_payload}"

print("Payload only:", token_payload)
print("Full (cookie-style):", full_token)
print("\nLength:", len(full_token))
