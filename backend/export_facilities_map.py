"""
Export all facilities with coordinates to JSON for map visualization.
"""

import os
import sys
import django
import json

# Setup Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'parkhero.settings')
django.setup()

from apps.atlas.models import Facility
import pandas as pd


def export_facilities_to_json():
    """Export all facilities with coordinates to JSON."""
    
    # Load Excel data for coordinates
    excel_path = '/home/parth1899/Projects/AIBoomi-ParkHero/D58_Parking_Lots_with_Coordinates.xlsx'
    df = pd.read_excel(excel_path)
    
    # Create coordinate mapping from Excel
    coord_map = {}
    for _, row in df.iterrows():
        coord_map[row['Name of Parking']] = {
            'lat': float(row['Latitude']),
            'lon': float(row['Longitude'])
        }
    
    # Hardcoded coordinates for other facilities
    other_coords = {
        # Independent lots
        'Koregaon Park Quick Park': {'lat': 18.5362, 'lon': 73.8958},
        'FC Road Parking Zone': {'lat': 18.5314, 'lon': 73.8446},
        'Deccan Gymkhana Lot': {'lat': 18.5089, 'lon': 73.8343},
        'Viman Nagar Plaza Parking': {'lat': 18.5679, 'lon': 73.9143},
        'Kothrud Market Parking': {'lat': 18.5074, 'lon': 73.8077},
        
        # Homeowner spaces
        'Aundh Residential Parking - Sharma': {'lat': 18.5642, 'lon': 73.8077},
        'Koregaon Park Home Parking - Patel': {'lat': 18.5401, 'lon': 73.8921},
        'Baner Society Parking - Deshmukh': {'lat': 18.5590, 'lon': 73.7793},
        'Kalyani Nagar Private Parking - Joshi': {'lat': 18.5483, 'lon': 73.9067},
        'Wakad Home Parking - Kulkarni': {'lat': 18.5978, 'lon': 73.7644},
        'Hinjewadi Residential - Mehta': {'lat': 18.5912, 'lon': 73.7389},
        
        # Malls
        'Phoenix Market City': {'lat': 18.5679, 'lon': 73.9143},
        'Seasons Mall': {'lat': 18.5196, 'lon': 73.9284},
        'Amanora Town Centre': {'lat': 18.5089, 'lon': 73.9284},
        'Pavilion Mall': {'lat': 18.5304, 'lon': 73.8431},
        'Westend Mall': {'lat': 18.5642, 'lon': 73.8077},
    }
    
    coord_map.update(other_coords)
    
    # Get all facilities
    facilities = Facility.objects.all()
    
    facilities_data = []
    for facility in facilities:
        # Get coordinates
        coords = coord_map.get(facility.name)
        
        if coords:
            # Count spots
            total_spots = sum(floor.spots.count() for floor in facility.floors.all())
            available_spots = sum(
                floor.spots.filter(status='available').count() 
                for floor in facility.floors.all()
            )
            
            facilities_data.append({
                'id': facility.id,
                'name': facility.name,
                'type': facility.type,
                'address': facility.address,
                'lat': coords['lat'],
                'lon': coords['lon'],
                'confidence': facility.confidence_score,
                'onboarding_type': facility.onboarding_type,
                'total_spots': total_spots,
                'available_spots': available_spots,
                'floors_count': facility.floors.count()
            })
    
    # Save to JSON
    output_path = 'facilities_map_data.json'
    with open(output_path, 'w') as f:
        json.dump(facilities_data, f, indent=2)
    
    print(f"✅ Exported {len(facilities_data)} facilities to {output_path}")
    print(f"   - Malls: {len([f for f in facilities_data if f['type'] == 'mall'])}")
    print(f"   - Lots: {len([f for f in facilities_data if f['type'] == 'lot'])}")
    print(f"   - Total spots: {sum(f['total_spots'] for f in facilities_data)}")
    
    return facilities_data


if __name__ == '__main__':
    export_facilities_to_json()
