import base64
import zlib
import json

# decompresses zlib+base64 encoded JWT. hint: look for 'eJw..."
token = "eJw9y00LQEAUheG_ortGys5KWdiT9TRxkpoP3ZlZSP67q7A8T-c9Se1gqx1cpCZyQk6zt7t2BzXUJ4SYde_OCVZvRnx9vGWfIrhgBBgDDqWEcnLa4m-nABZjb_B1MpOo2haRaRxUVdV03f4iLpE"

# pad if needed
token += '=' * (-len(token) % 4)

compressed = base64.urlsafe_b64decode(token)
decompressed = zlib.decompress(compressed)
data = json.loads(decompressed)          # often it's JSON
print(data)
