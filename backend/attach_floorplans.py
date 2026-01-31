"""
Script to attach floorplan images to mall parking floors.
"""

import os
import sys
import django

# Setup Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'parkhero.settings')
django.setup()

from apps.atlas.models import Facility, Floor


def attach_floorplans():
    """Attach floorplan images to mall floors."""
    print("🖼️  Attaching floorplan images to mall floors...\n")
    
    # Get all mall facilities
    malls = Facility.objects.filter(type='mall')
    
    # Mapping of floor labels to floorplan images
    floorplan_map = {
        'B2': 'floorplans/mall_parking_b2_1769855455713.png',
        'B1': 'floorplans/mall_parking_b1_1769855472246.png',
        'Ground': 'floorplans/mall_parking_ground_1769855489335.png',
        'P1': 'floorplans/mall_parking_p1_1769855505158.png',
    }
    
    updated_count = 0
    for mall in malls:
        print(f"📍 {mall.name}")
        floors = mall.floors.all()
        
        for floor in floors:
            if floor.label in floorplan_map:
                floor.floorplan_image = floorplan_map[floor.label]
                floor.save()
                print(f"  ✓ Floor {floor.label}: {floorplan_map[floor.label]}")
                updated_count += 1
            else:
                print(f"  ⚠️  Floor {floor.label}: No matching floorplan")
        print()
    
    print(f"✅ Updated {updated_count} floors with floorplan images\n")
    
    # Print summary
    print("="*60)
    print("📊 FLOORPLAN SUMMARY")
    print("="*60)
    print(f"\nMalls with floorplans: {malls.count()}")
    print(f"Floors updated: {updated_count}")
    print("\nFloorplan images:")
    for label, path in floorplan_map.items():
        print(f"  - {label}: {path}")
    print("\n" + "="*60)
    print("✅ Floorplan setup complete!")
    print("="*60)
    print("\n🎯 Test the floorplans:")
    print("   1. View facilities: http://localhost:8000/api/mobile/facilities/")
    print("   2. Get mall details: http://localhost:8000/api/mobile/facilities/<mall_id>/")
    print("   3. View floor map: http://localhost:8000/api/mobile/floors/<floor_id>/map/")
    print("\n")


if __name__ == '__main__':
    attach_floorplans()
