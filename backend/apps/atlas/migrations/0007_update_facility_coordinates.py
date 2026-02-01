from decimal import Decimal

from django.db import migrations


def set_coordinates(apps, schema_editor):
    Facility = apps.get_model('atlas', 'Facility')

    coords = [
        ("Westend Mall", Decimal("18.559"), Decimal("73.777")),
        ("Pavilion Mall", Decimal("18.5313"), Decimal("73.8449")),
        ("Amanora Town Centre", Decimal("18.5089"), Decimal("73.9283")),
        ("Seasons Mall", Decimal("18.5314"), Decimal("73.8468")),
        ("Phoenix Market City", Decimal("18.5589"), Decimal("73.7713")),
        ("Hinjewadi Residential - Mehta", Decimal("18.5912"), Decimal("73.7389")),
        ("Wakad Home Parking - Kulkarni", Decimal("18.6028"), Decimal("73.7633")),
        ("Kalyani Nagar Private Parking - Joshi", Decimal("18.5483"), Decimal("73.9065")),
        ("Baner Society Parking - Deshmukh", Decimal("18.559"), Decimal("73.7853")),
        ("Koregaon Park Home Parking - Patel", Decimal("18.5362"), Decimal("73.8936")),
        ("Aundh Residential Parking - Sharma", Decimal("18.559"), Decimal("73.8074")),
        ("Kothrud Market Parking", Decimal("18.5074"), Decimal("73.8077")),
        ("Viman Nagar Plaza Parking", Decimal("18.5679"), Decimal("73.9143")),
        ("Deccan Gymkhana Lot", Decimal("18.5176"), Decimal("73.843")),
        ("FC Road Parking Zone", Decimal("18.5314"), Decimal("73.844")),
        ("Koregaon Park Quick Park", Decimal("18.542"), Decimal("73.8945")),
        ("Bhaumaharaj Bol", Decimal("18.5195"), Decimal("73.8567")),
        ("Iscon Temple", Decimal("18.559"), Decimal("73.7712")),
        ("Kharadi S.No. 72, Amenity Space", Decimal("18.5515"), Decimal("73.9389")),
        ("Punya nagari, Vadgaon Sheri", Decimal("18.5493"), Decimal("73.9298")),
        ("Sambhaji garden Mech. J.M. Road", Decimal("18.5278"), Decimal("73.8567")),
        ("S.Nagar, FP660, J.M. Road", Decimal("18.5304"), Decimal("73.8445")),
        ("S.Nagar, Millenium Plaza", Decimal("18.532"), Decimal("73.8455")),
        ("S.Nagar, F.C. Shirole Road", Decimal("18.5289"), Decimal("73.8421")),
        ("S.Nagar FP 576", Decimal("18.5298"), Decimal("73.8432")),
        ("Dhanakavdi, Truck Terminal", Decimal("18.4689"), Decimal("73.8634")),
        ("Katraj Milk Dairy, PMPML", Decimal("18.4523"), Decimal("73.8643")),
        ("Katraj PMT, Old Octroi Naka", Decimal("18.4534"), Decimal("73.8632")),
        ("Rajiv Gandi Udyan", Decimal("18.5045"), Decimal("73.8123")),
        ("Saibaba Temple", Decimal("18.5234"), Decimal("73.8512")),
        ("Decision Tower,S.No.692", Decimal("18.5456"), Decimal("73.8945")),
        ("P.L. Desh. Udyan", Decimal("18.5167"), Decimal("73.8456")),
        ("Bhavani Peth, Nagzari Nala", Decimal("18.5089"), Decimal("73.8612")),
        ("Shahu Udyan", Decimal("18.5167"), Decimal("73.8534")),
        ("Alpana Theatre, Ganesh Peth", Decimal("18.5234"), Decimal("73.8645")),
        ("M. Gandhi", Decimal("18.5198"), Decimal("73.8523")),
        ("Dudhbhatti, Rasta Peth, Daruwala Bridge", Decimal("18.5167"), Decimal("73.8612")),
        ("Shinde Tukaram ( 4 Wheeler )", Decimal("18.5134"), Decimal("73.8578")),
        ("Shinde Tukaram ( 2 Wheeler)", Decimal("18.5136"), Decimal("73.858")),
        ("Aryan, Babu Genu", Decimal("18.5212"), Decimal("73.8589")),
        ("Navloba Temple", Decimal("18.5189"), Decimal("73.8567")),
        ("Haribhau Sane", Decimal("18.5201"), Decimal("73.8534")),
        ("Peshve Park", Decimal("18.5223"), Decimal("73.8545")),
        ("Hamalwada", Decimal("18.5178"), Decimal("73.8589")),
        ("Laxmi Road 709/ 710", Decimal("18.5189"), Decimal("73.8556")),
        ("Minarva, Misal", Decimal("18.5267"), Decimal("73.8534")),
    ]

    for name, lat, lon in coords:
        Facility.objects.filter(name=name).update(latitute=lat, longitude=lon)


def unset_coordinates(apps, schema_editor):
    Facility = apps.get_model('atlas', 'Facility')

    names = [
        "Westend Mall",
        "Pavilion Mall",
        "Amanora Town Centre",
        "Seasons Mall",
        "Phoenix Market City",
        "Hinjewadi Residential - Mehta",
        "Wakad Home Parking - Kulkarni",
        "Kalyani Nagar Private Parking - Joshi",
        "Baner Society Parking - Deshmukh",
        "Koregaon Park Home Parking - Patel",
        "Aundh Residential Parking - Sharma",
        "Kothrud Market Parking",
        "Viman Nagar Plaza Parking",
        "Deccan Gymkhana Lot",
        "FC Road Parking Zone",
        "Koregaon Park Quick Park",
        "Bhaumaharaj Bol",
        "Iscon Temple",
        "Kharadi S.No. 72, Amenity Space",
        "Punya nagari, Vadgaon Sheri",
        "Sambhaji garden Mech. J.M. Road",
        "S.Nagar, FP660, J.M. Road",
        "S.Nagar, Millenium Plaza",
        "S.Nagar, F.C. Shirole Road",
        "S.Nagar FP 576",
        "Dhanakavdi, Truck Terminal",
        "Katraj Milk Dairy, PMPML",
        "Katraj PMT, Old Octroi Naka",
        "Rajiv Gandi Udyan",
        "Saibaba Temple",
        "Decision Tower,S.No.692",
        "P.L. Desh. Udyan",
        "Bhavani Peth, Nagzari Nala",
        "Shahu Udyan",
        "Alpana Theatre, Ganesh Peth",
        "M. Gandhi",
        "Dudhbhatti, Rasta Peth, Daruwala Bridge",
        "Shinde Tukaram ( 4 Wheeler )",
        "Shinde Tukaram ( 2 Wheeler)",
        "Aryan, Babu Genu",
        "Navloba Temple",
        "Haribhau Sane",
        "Peshve Park",
        "Hamalwada",
        "Laxmi Road 709/ 710",
        "Minarva, Misal",
    ]

    Facility.objects.filter(name__in=names).update(latitute=None, longitude=None)


class Migration(migrations.Migration):

    dependencies = [
        ('atlas', '0006_facility_latitute_facility_longitude'),
    ]

    operations = [
        migrations.RunPython(set_coordinates, reverse_code=unset_coordinates),
    ]