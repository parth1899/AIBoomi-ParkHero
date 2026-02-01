#!/bin/bash

# Quick script to view floorplan URLs for all malls

echo "🏬 Mall Floorplan URLs"
echo "====================="
echo ""

# Get Phoenix Market City details (ID 42)
echo "1. Phoenix Market City"
curl -s http://localhost:8000/api/mobile/facilities/42/ | python3 -c "
import sys, json
data = json.load(sys.stdin)
for floor in data['floors']:
    print(f\"   Floor {floor['label']}: http://localhost:8000/api/mobile/floors/{floor['id']}/map/\")
"
echo ""

# Get Seasons Mall details (ID 43)
echo "2. Seasons Mall"
curl -s http://localhost:8000/api/mobile/facilities/43/ | python3 -c "
import sys, json
data = json.load(sys.stdin)
for floor in data['floors']:
    print(f\"   Floor {floor['label']}: http://localhost:8000/api/mobile/floors/{floor['id']}/map/\")
"
echo ""

# Get Amanora Town Centre details (ID 44)
echo "3. Amanora Town Centre"
curl -s http://localhost:8000/api/mobile/facilities/44/ | python3 -c "
import sys, json
data = json.load(sys.stdin)
for floor in data['floors']:
    print(f\"   Floor {floor['label']}: http://localhost:8000/api/mobile/floors/{floor['id']}/map/\")
"
echo ""

echo "📍 To view a specific floorplan:"
echo "   curl http://localhost:8000/api/mobile/floors/<floor_id>/map/ | python3 -m json.tool"
echo ""
echo "🖼️  Floorplan images are in: backend/media/floorplans/"
echo ""
