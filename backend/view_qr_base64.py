import base64
import os

# The base64 string provided by the user
qr_base64 = "iVBORw0KGgoAAAANSUhEUgAAASIAAAEiAQAAAAB1xeIbAAABd0lEQVR4nO2aTW6DMBCFvylIWcINchRzsypH6g3wUXIDWEYiel2YnzRdtJtgAjMLS9ifxJN5DOMRJv6O+PEPCJxyyimnnNo6ZWOUEM3Mmn6aabLqOgQVJEkdQDWglkKSpJ/U+roOQfWzxynSjqfXILeuPVPl07WB8avu3Kr6nVGhA2vWvONhqcn3lYAeRF8MBvww/1bV74KKZmZWL5a/pzInt65dU8n3i8cVa2x8DXLqOg5lVpPMD5X0MJdX174pUhkflqErlB5A0JBW1W5V/XtTLEcoqSvGHW/n5eB7/2JK6sDsPECsC4Gfa1ejrAHU9mWq7wm6GbHOrmvf1FznCMJkcwtfNdCXg3LpOg710MdMkb61N+9jrkA99DEBtdxtyvxZdR2CmvqYutRgTX+SfV69j/lS6rmPOUZ1S+0Ez/drUuFqqcTR5ez5fhWqktQC1lQDavuTrMHz/UupMefElGIKiDbuuOZhu+rfmzL/N8opp5xy6hDUN2tXmmKHrtWlAAAAAElFTkSuQmCC"

output_filename = "user_provided_qr.png"

try:
    #Decode base64 string
    img_data = base64.b64decode(qr_base64)
    
    # Write to file
    with open(output_filename, "wb") as f:
        f.write(img_data)
        
    print(f"✅ QR Code saved to: {os.path.abspath(output_filename)}")
    print("You can now open this image file to scan it.")

except Exception as e:
    print(f"❌ Error decoding QR code: {e}")
