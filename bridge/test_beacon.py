import firebase_admin
from firebase_admin import credentials, db
import time
import os

# --- 1. CONFIGURATION ---
# Ensure your JSON key path is correct for your PC setup
CERT_PATH = r"C:\Project-Rakshak\bridge\serviceAccountKey.json"
DB_URL = 'https://project-rakshak-7c370-default-rtdb.firebaseio.com/'

# --- 2. INITIALIZATION ---
def initialize_system():
    if not os.path.exists(CERT_PATH):
        print(f"❌ ERROR: Key not found at {CERT_PATH}")
        return False
    
    if not firebase_admin._apps:
        cred = credentials.Certificate(CERT_PATH)
        firebase_admin.initialize_app(cred, {'databaseURL': DB_URL})
    return True

# --- 3. THE SIMULATION LOGIC ---
def run_rakshak_simulation():
    print("🚀 Project Rakshak: Initializing Tactical Beacon Sync...")
    
    # Tactical sectors in Kerala for your demo
    beacons = [
        {"id": "beacon_Kochi", "lat": 9.9312, "lng": 76.2673, "name": "Kochi Sector"},
        {"id": "beacon_Thrissur", "lat": 10.5276, "lng": 76.2144, "name": "Thrissur Sector"},
        {"id": "beacon_Alappuzha", "lat": 9.4981, "lng": 76.3388, "name": "Alappuzha Sector"}
    ]
    
    for sector in beacons:
        print(f"\n📡 Pushing live emergency signal for {sector['name']}...")
        
        # THE FIX: Unique ID ensures the Flutter 'onValue' listener triggers the pop-up every time
        unique_id = int(time.time())
        emergency_status = f"VERIFIED (Manual Override) - EVENT_ID:{unique_id}"
        
        ref = db.reference(f"beacons/{sector['id']}")
        
        # Pushing data to the Cloud
        ref.set({
            "status": emergency_status,
            "location": {
                "lat": sector['lat'],
                "lng": sector['lng']
            },
            "last_updated": time.ctime(),
            "sensor_health": "OPTIMAL",
            "alert_level": "CRITICAL"
        })
        print(f"✅ Firebase Updated: {sector['id']} is now LIVE.")

# --- 4. EXECUTION ---
if __name__ == "__main__":
    if initialize_system():
        run_rakshak_simulation()
        print("\n🏆 All sectors synced. Your friends with the APK will see the alert now!")