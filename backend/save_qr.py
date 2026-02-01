import qrcode

payload = "PARKHERO:KBT8LZ:5"

# Create a high-quality, larger QR code
qr = qrcode.QRCode(
    version=None,       # Auto-determine size
    error_correction=qrcode.constants.ERROR_CORRECT_H, # High error correction (30% recovery)
    box_size=20,        # Large pixels
    border=4,           # Standard border
)
qr.add_data(payload)
qr.make(fit=True)

# Save as PNG
img = qr.make_image(fill_color="black", back_color="white")
output_file = "qr_high_res.png"
img.save(output_file)

print(f"✅ Generated high-resolution QR: {output_file}")
print(f"Payload: {payload}")
print("Please scan this specific file.")
