import qrcode

qr = qrcode.QRCode(
    version=1,
    box_size=10,
    border=1
)

# Solicita o link ou texto para gerar o QR Code
data = input("link: ")

qr.add_data(data)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
img.save(input("nome do arquivo: ")+".png")