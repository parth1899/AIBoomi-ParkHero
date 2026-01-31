import qrcode
from io import BytesIO
from base64 import b64encode
from datetime import datetime
import math


def generate_qr_code(data):
    """
    Generate a QR code from the given data and return as base64 string.
    
    Args:
        data: String data to encode in QR code
        
    Returns:
        Base64 encoded PNG image string
    """
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    
    return b64encode(buffer.getvalue()).decode()


def calculate_distance(x1, y1, x2, y2):
    """
    Calculate Euclidean distance between two points.
    
    Args:
        x1, y1: Coordinates of first point
        x2, y2: Coordinates of second point
        
    Returns:
        Distance as float
    """
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)


def format_time_remaining(end_time):
    """
    Format time remaining until end_time in human-readable format.
    
    Args:
        end_time: datetime object
        
    Returns:
        String like "2 hours 30 minutes" or "Expired"
    """
    if not end_time:
        return "N/A"
    
    now = datetime.now(end_time.tzinfo) if end_time.tzinfo else datetime.now()
    delta = end_time - now
    
    if delta.total_seconds() <= 0:
        return "Expired"
    
    hours = int(delta.total_seconds() // 3600)
    minutes = int((delta.total_seconds() % 3600) // 60)
    
    if hours > 0:
        return f"{hours} hour{'s' if hours != 1 else ''} {minutes} minute{'s' if minutes != 1 else ''}"
    else:
        return f"{minutes} minute{'s' if minutes != 1 else ''}"
