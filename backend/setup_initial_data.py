"""
Initial database setup script for ParkHero ATLAS app.
Creates realistic parking data for Pune area including:
- Government parking lots (from Excel data)
- Independent small parking lots
- Homeowner parking spaces
- Commercial malls with floor plans and real-time availability
"""

import os
import sys
import django
import pandas as pd
from decimal import Decimal
import random

# Setup Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'parkhero.settings')
django.setup()

from apps.atlas.models import Facility, Floor, ParkingSpot, Device
from django.contrib.auth.models import User


def clear_existing_data():
    """Clear all existing data for fresh setup."""
    print("🗑️  Clearing existing data...")
    ParkingSpot.objects.all().delete()
    Floor.objects.all().delete()
    Facility.objects.all().delete()
    Device.objects.all().delete()
    # Keep demo user but remove other test users
    User.objects.filter(username__in=['homeowner_demo', 'lotowner_demo', 'mall_operator']).delete()
    print("✅ Existing data cleared\n")


def create_owner_users():
    """Create owner users for P2P marketplace."""
    print("👤 Creating owner users...")
    
    # P2P Homeowner
    homeowner, created = User.objects.get_or_create(
        username='homeowner_demo',
        defaults={
            'email': 'homeowner@parkhero.com',
            'first_name': 'Rajesh',
            'last_name': 'Sharma',
            'is_staff': False
        }
    )
    if created:
        homeowner.set_password('demo123')
        homeowner.save()
        print(f"  ✓ Created homeowner: {homeowner.username}")
    
    # Parking Lot Owner
    lot_owner, created = User.objects.get_or_create(
        username='lotowner_demo',
        defaults={
            'email': 'lotowner@parkhero.com',
            'first_name': 'Amit',
            'last_name': 'Patel',
            'is_staff': False
        }
    )
    if created:
        lot_owner.set_password('demo123')
        lot_owner.save()
        print(f"  ✓ Created lot owner: {lot_owner.username}")
    
    # Mall Operator
    mall_operator, created = User.objects.get_or_create(
        username='mall_operator',
        defaults={
            'email': 'malloperator@parkhero.com',
            'first_name': 'Phoenix',
            'last_name': 'Management',
            'is_staff': True
        }
    )
    if created:
        mall_operator.set_password('demo123')
        mall_operator.save()
        print(f"  ✓ Created mall operator: {mall_operator.username}")
    
    print("✅ Owner users created\n")
    return {
        'homeowner': homeowner,
        'lot_owner': lot_owner,
        'mall_operator': mall_operator
    }


def create_government_parking_lots():
    """Create government parking lots from Excel data."""
    print("🏛️  Creating government parking lots...")
    
    excel_path = '/home/parth1899/Projects/AIBoomi-ParkHero/D58_Parking_Lots_with_Coordinates.xlsx'
    df = pd.read_excel(excel_path)
    
    facilities = []
    for idx, row in df.iterrows():
        # Create facility
        facility = Facility.objects.create(
            name=row['Name of Parking'],
            type='lot',
            address=row['Parking Address'],
            onboarding_type='enterprise',
            confidence_score=85
        )
        
        # Create single ground floor
        floor = Floor.objects.create(
            facility=facility,
            label='Ground'
        )
        
        # Create parking spots
        two_wheeler_count = int(row['No. of 2 wheeler parking']) if pd.notna(row['No. of 2 wheeler parking']) else 0
        four_wheeler_count = int(row['No. of 4 wheeler parking']) if pd.notna(row['No. of 4 wheeler parking']) else 0
        
        # Create 2-wheeler spots
        for i in range(min(two_wheeler_count, 50)):  # Limit for demo
            ParkingSpot.objects.create(
                floor=floor,
                code=f"2W-{i+1:03d}",
                x=random.uniform(10, 90),
                y=random.uniform(10, 90),
                status=random.choice(['available', 'available', 'available', 'occupied']),
                verified=True,
                distance_from_entry=random.randint(5, 100)
            )
        
        # Create 4-wheeler spots
        for i in range(min(four_wheeler_count, 50)):  # Limit for demo
            ParkingSpot.objects.create(
                floor=floor,
                code=f"4W-{i+1:03d}",
                x=random.uniform(10, 90),
                y=random.uniform(10, 90),
                status=random.choice(['available', 'available', 'occupied']),
                verified=True,
                distance_from_entry=random.randint(5, 100)
            )
        
        facilities.append(facility)
        print(f"  ✓ {facility.name} - {two_wheeler_count} 2W + {four_wheeler_count} 4W spots")
    
    print(f"✅ Created {len(facilities)} government parking lots\n")
    return facilities


def create_independent_parking_lots(lot_owner):
    """Create independent small parking lots."""
    print("🅿️  Creating independent parking lots...")
    
    lots_data = [
        {
            'name': 'Koregaon Park Quick Park',
            'address': 'Lane 5, Koregaon Park, Pune',
            'lat': 18.5362,
            'lon': 73.8958,
            'spots': 25,
            'hourly_rate': 30,
            'daily_rate': 200
        },
        {
            'name': 'FC Road Parking Zone',
            'address': 'Near Goodluck Cafe, FC Road, Pune',
            'lat': 18.5314,
            'lon': 73.8446,
            'spots': 30,
            'hourly_rate': 40,
            'daily_rate': 250
        },
        {
            'name': 'Deccan Gymkhana Lot',
            'address': 'Opposite Fergusson College, Pune',
            'lat': 18.5089,
            'lon': 73.8343,
            'spots': 40,
            'hourly_rate': 35,
            'daily_rate': 220
        },
        {
            'name': 'Viman Nagar Plaza Parking',
            'address': 'Near Phoenix Market City, Viman Nagar',
            'lat': 18.5679,
            'lon': 73.9143,
            'spots': 35,
            'hourly_rate': 45,
            'daily_rate': 280
        },
        {
            'name': 'Kothrud Market Parking',
            'address': 'Kothrud Market, Pune',
            'lat': 18.5074,
            'lon': 73.8077,
            'spots': 28,
            'hourly_rate': 30,
            'daily_rate': 200
        },
    ]
    
    facilities = []
    for lot in lots_data:
        facility = Facility.objects.create(
            name=lot['name'],
            type='lot',
            address=lot['address'],
            onboarding_type='small',
            confidence_score=75,
            owner=lot_owner,
            hourly_rate=Decimal(str(lot['hourly_rate'])),
            daily_rate=Decimal(str(lot['daily_rate']))
        )
        
        # Create barrier device for access control
        Device.objects.create(
            device_code=f"BARRIER-{facility.id}-ENTRY",
            device_type='barrier',
            bound_facility=facility
        )
        
        floor = Floor.objects.create(
            facility=facility,
            label='Ground'
        )
        
        # Create spots
        for i in range(lot['spots']):
            ParkingSpot.objects.create(
                floor=floor,
                code=f"P-{i+1:02d}",
                x=random.uniform(10, 90),
                y=random.uniform(10, 90),
                status=random.choice(['available', 'available', 'available', 'occupied']),
                verified=random.choice([True, False]),
                distance_from_entry=random.randint(5, 50)
            )
        
        facilities.append(facility)
        print(f"  ✓ {facility.name} - {lot['spots']} spots")
    
    print(f"✅ Created {len(facilities)} independent parking lots\n")
    return facilities


def create_homeowner_parking(homeowner):
    """Create homeowner parking spaces."""
    print("🏠 Creating homeowner parking spaces...")
    
    homeowner_data = [
        {
            'name': 'Aundh Residential Parking - Sharma',
            'address': 'Bungalow No. 12, Aundh, Pune',
            'lat': 18.5642,
            'lon': 73.8077,
            'spots': 2,
            'hourly_rate': 50,
            'daily_rate': 300
        },
        {
            'name': 'Koregaon Park Home Parking - Patel',
            'address': 'Villa 45, North Main Road, Koregaon Park',
            'lat': 18.5401,
            'lon': 73.8921,
            'spots': 1,
            'hourly_rate': 60,
            'daily_rate': 350
        },
        {
            'name': 'Baner Society Parking - Deshmukh',
            'address': 'Flat B-304, Green Valley, Baner',
            'lat': 18.5590,
            'lon': 73.7793,
            'spots': 2,
            'hourly_rate': 45,
            'daily_rate': 280
        },
        {
            'name': 'Kalyani Nagar Private Parking - Joshi',
            'address': 'Row House 7, Kalyani Nagar, Pune',
            'lat': 18.5483,
            'lon': 73.9067,
            'spots': 3,
            'hourly_rate': 55,
            'daily_rate': 320
        },
        {
            'name': 'Wakad Home Parking - Kulkarni',
            'address': 'Plot 23, Sector A, Wakad',
            'lat': 18.5978,
            'lon': 73.7644,
            'spots': 1,
            'hourly_rate': 40,
            'daily_rate': 250
        },
        {
            'name': 'Hinjewadi Residential - Mehta',
            'address': 'Bungalow 89, Phase 1, Hinjewadi',
            'lat': 18.5912,
            'lon': 73.7389,
            'spots': 2,
            'hourly_rate': 50,
            'daily_rate': 300
        },
    ]
    
    facilities = []
    for home in homeowner_data:
        facility = Facility.objects.create(
            name=home['name'],
            type='lot',
            address=home['address'],
            onboarding_type='p2p',
            confidence_score=70,
            owner=homeowner,
            hourly_rate=Decimal(str(home['hourly_rate'])),
            daily_rate=Decimal(str(home['daily_rate']))
        )
        
        # Create barrier device for access control
        Device.objects.create(
            device_code=f"BARRIER-{facility.id}-ENTRY",
            device_type='barrier',
            bound_facility=facility
        )
        
        floor = Floor.objects.create(
            facility=facility,
            label='Driveway'
        )
        
        # Create spots
        for i in range(home['spots']):
            ParkingSpot.objects.create(
                floor=floor,
                code=f"H-{i+1}",
                x=random.uniform(20, 80),
                y=random.uniform(20, 80),
                status=random.choice(['available', 'available', 'occupied']),
                verified=True,
                distance_from_entry=random.randint(1, 10)
            )
        
        facilities.append(facility)
        print(f"  ✓ {facility.name} - {home['spots']} spot(s)")
    
    print(f"✅ Created {len(facilities)} homeowner parking spaces\n")
    return facilities


def create_mall_parking():
    """Create commercial mall parking with multiple floors and real-time availability."""
    print("🏬 Creating commercial mall parking facilities...")
    
    malls_data = [
        {
            'name': 'Phoenix Market City',
            'address': 'Viman Nagar, Pune, Maharashtra 411014',
            'lat': 18.5679,
            'lon': 73.9143,
            'floors': ['B2', 'B1', 'Ground', 'P1'],
            'spots_per_floor': [120, 150, 80, 100]
        },
        {
            'name': 'Seasons Mall',
            'address': 'Magarpatta City, Hadapsar, Pune 411028',
            'lat': 18.5196,
            'lon': 73.9284,
            'floors': ['B1', 'Ground', 'P1'],
            'spots_per_floor': [100, 60, 80]
        },
        {
            'name': 'Amanora Town Centre',
            'address': 'Amanora Park Town, Hadapsar, Pune 411028',
            'lat': 18.5089,
            'lon': 73.9284,
            'floors': ['B2', 'B1', 'Ground'],
            'spots_per_floor': [130, 140, 70]
        },
        {
            'name': 'Pavilion Mall',
            'address': 'Senapati Bapat Road, Shivajinagar, Pune 411016',
            'lat': 18.5304,
            'lon': 73.8431,
            'floors': ['B1', 'Ground'],
            'spots_per_floor': [90, 50]
        },
        {
            'name': 'Westend Mall',
            'address': 'Aundh, Pune, Maharashtra 411007',
            'lat': 18.5642,
            'lon': 73.8077,
            'floors': ['B1', 'Ground', 'P1'],
            'spots_per_floor': [80, 60, 70]
        },
    ]
    
    facilities = []
    for mall in malls_data:
        facility = Facility.objects.create(
            name=mall['name'],
            type='mall',
            address=mall['address'],
            onboarding_type='enterprise',
            confidence_score=95
        )
        
        # Create floors
        for floor_idx, (floor_label, spot_count) in enumerate(zip(mall['floors'], mall['spots_per_floor'])):
            floor = Floor.objects.create(
                facility=facility,
                label=floor_label
            )
            
            # Create parking spots in a grid pattern
            spots_created = 0
            rows = int((spot_count / 10) ** 0.5) + 1
            cols = (spot_count // rows) + 1
            
            for row in range(rows):
                for col in range(cols):
                    if spots_created >= spot_count:
                        break
                    
                    # Calculate position in grid
                    x = 10 + (col * 80 / cols)
                    y = 10 + (row * 80 / rows)
                    
                    # Determine status - malls show real-time availability
                    # Simulate realistic occupancy (60-80% during peak hours)
                    status_weights = ['available'] * 30 + ['occupied'] * 60 + ['reserved'] * 10
                    
                    spot = ParkingSpot.objects.create(
                        floor=floor,
                        code=f"{floor_label}-{chr(65 + row)}{col+1:02d}",
                        x=x,
                        y=y,
                        status=random.choice(status_weights),
                        verified=True,
                        distance_from_entry=random.randint(10, 200)
                    )
                    
                    # Bind some devices to spots (simulating sensors)
                    if random.random() < 0.7:  # 70% of spots have sensors
                        Device.objects.create(
                            device_code=f"SENSOR-{facility.id}-{floor.id}-{spots_created:04d}",
                            device_type='sensor',
                            bound_spot=spot
                        )
                    
                    spots_created += 1
                
                if spots_created >= spot_count:
                    break
            
            print(f"  ✓ {facility.name} - Floor {floor_label}: {spots_created} spots")
        
        facilities.append(facility)
    
    print(f"✅ Created {len(facilities)} mall parking facilities\n")
    return facilities


def create_demo_user():
    """Create a demo user for testing."""
    print("👤 Creating demo user...")
    
    try:
        user = User.objects.get(username='demo')
        print("  ℹ️  Demo user already exists")
    except User.DoesNotExist:
        user = User.objects.create_user(
            username='demo',
            email='demo@parkhero.com',
            password='demo123',
            first_name='Demo',
            last_name='User'
        )
        print("  ✓ Demo user created (username: demo, password: demo123)")
    
    print("✅ Demo user ready\n")
    return user


def print_summary():
    """Print summary of created data."""
    print("\n" + "="*60)
    print("📊 DATABASE SETUP SUMMARY")
    print("="*60)
    
    total_facilities = Facility.objects.count()
    total_floors = Floor.objects.count()
    total_spots = ParkingSpot.objects.count()
    total_devices = Device.objects.count()
    
    print(f"\n🏢 Facilities: {total_facilities}")
    print(f"   - Malls: {Facility.objects.filter(type='mall').count()}")
    print(f"   - Offices: {Facility.objects.filter(type='office').count()}")
    print(f"   - Lots: {Facility.objects.filter(type='lot').count()}")
    
    print(f"\n📋 Onboarding Types:")
    print(f"   - Enterprise: {Facility.objects.filter(onboarding_type='enterprise').count()}")
    print(f"   - Small Business: {Facility.objects.filter(onboarding_type='small').count()}")
    print(f"   - P2P Homeowners: {Facility.objects.filter(onboarding_type='p2p').count()}")
    
    print(f"\n🏗️  Floors: {total_floors}")
    print(f"🅿️  Parking Spots: {total_spots}")
    print(f"   - Available: {ParkingSpot.objects.filter(status='available').count()}")
    print(f"   - Occupied: {ParkingSpot.objects.filter(status='occupied').count()}")
    print(f"   - Reserved: {ParkingSpot.objects.filter(status='reserved').count()}")
    print(f"   - Verified: {ParkingSpot.objects.filter(verified=True).count()}")
    
    print(f"\n📡 Devices: {total_devices}")
    print(f"   - Sensors (Malls): {Device.objects.filter(device_type='sensor').count()}")
    print(f"   - Barriers (Lots/Homes): {Device.objects.filter(device_type='barrier').count()}")
    
    print(f"\n👥 Users:")
    print(f"   - Total: {User.objects.count()}")
    print(f"   - Homeowners: {User.objects.filter(username='homeowner_demo').count()}")
    print(f"   - Lot Owners: {User.objects.filter(username='lotowner_demo').count()}")
    
    print("\n" + "="*60)
    print("✅ Database setup complete!")
    print("="*60)
    print("\n🚀 Next steps:")
    print("   1. Start the server: uv run python manage.py runserver")
    print("   2. Access admin: http://localhost:8000/admin/")
    print("   3. View facilities: http://localhost:8000/api/mobile/facilities/")
    print("   4. View P2P facilities: http://localhost:8000/api/mobile/facilities/?type=p2p")
    print("\n👤 Demo credentials:")
    print("   - Driver: username=demo, password=demo123")
    print("   - Homeowner: username=homeowner_demo, password=demo123")
    print("   - Lot Owner: username=lotowner_demo, password=demo123")
    print("\n")


def main():
    """Main setup function."""
    print("\n" + "="*60)
    print("🎯 PARKHERO DATABASE SETUP")
    print("="*60)
    print("\nSetting up realistic parking data for Pune area...\n")
    
    # Clear existing data
    clear_existing_data()
    
    # Create owner users first
    owners = create_owner_users()
    
    # Create all data
    govt_lots = create_government_parking_lots()
    independent_lots = create_independent_parking_lots(owners['lot_owner'])
    homeowner_spaces = create_homeowner_parking(owners['homeowner'])
    malls = create_mall_parking()
    
    # Create demo user
    demo_user = create_demo_user()
    
    # Print summary
    print_summary()


if __name__ == '__main__':
    main()
