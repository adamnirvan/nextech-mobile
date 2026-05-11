require('dotenv').config(); 

const express = require('express'); 
const cors = require('cors'); 
const axios = require('axios'); 
const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json'); 

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();
// -----------------------------------

const app = express();
app.use(cors());
app.use(express.json());

const XENDIT_SECRET_KEY = process.env.XENDIT_SECRET_KEY;
const BITESHIP_API_KEY = process.env.BITESHIP_API_KEY;
const BITESHIP_BASE_URL = 'https://api.biteship.com/v1';

const PORT = process.env.PORT || 3000; 

app.post('/create-invoice', async (req, res) => {
    try {
        const { orderId, amount, customerName } = req.body;
        console.log(`\n📦 Ada pesanan masuk! ID: ${orderId} | Total: Rp ${amount} | Nama: ${customerName}`);

        const response = await axios.post('https://api.xendit.co/v2/invoices', {
            external_id: orderId,
            amount: amount,
            description: `Pesanan Nextech - ${customerName}`,
            invoice_duration: 86400,
            success_redirect_url: `nextech://payment-success?orderId=${orderId}&amount=${amount}`,
            customer: { given_names: customerName }
        }, {
            headers: {
                'Authorization': 'Basic ' + Buffer.from(XENDIT_SECRET_KEY + ':').toString('base64'),
                'Content-Type': 'application/json'
            }
        });

        console.log("✅ Tagihan sukses dibuat di Xendit!");
        
        res.json({ success: true, checkoutUrl: response.data.invoice_url });

    } catch (error) {
        console.error("❌ Gagal membuat tagihan:", error.response ? error.response.data : error.message);
        res.status(500).json({ success: false, message: 'Gagal membuat tagihan di Payment Gateway' });
    }
});

app.get('/get-payment-status/:orderId', async (req, res) => {
    try {
        const { orderId } = req.params;

        const response = await axios.get(`https://api.xendit.co/v2/invoices?external_id=${orderId}`, {
            headers: { 'Authorization': 'Basic ' + Buffer.from(XENDIT_SECRET_KEY + ':').toString('base64') }
        });

        const invoice = response.data[0];

        res.json({
            success: true,
            status: invoice.status,
            paymentMethod: invoice.payment_method,
            channel: invoice.payment_channel
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

app.post('/xendit-webhook', async (req, res) => {
    try {
        console.log("🔔 [WEBHOOK] Menerima panggilan dari Xendit...");
        
        const xenditEvent = req.body; 
        const orderId = xenditEvent.external_id; 
        const status = xenditEvent.status; 
        
        const orderRef = db.collection('orders').doc(orderId);
        const orderDoc = await orderRef.get();

        console.log(`💰 [WEBHOOK] Status pesanan ${orderId} adalah: ${status}`);

        // CEK: Jika statusnya PAID (LUNAS)
        if (status === 'PAID' || status === 'SETTLED') {
            console.log(`⏳ [WEBHOOK] Mengubah status ${orderId} menjadi processing di Firebase...`);

            // 1. Update status pesanan di Firestore
            await orderRef.update({
                status: 'processing',
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`✅ [WEBHOOK] Berhasil! Pesanan ${orderId} masuk tahap PROCESSING.`);

            // 2. KIRIM NOTIFIKASI (Hanya jika dokumen pesanan ada)
            if (orderDoc.exists) {
                const userId = orderDoc.data().userId;

                console.log(`✉️ [WEBHOOK] Membuat notifikasi untuk user: ${userId}`);

                await db.collection('notifications').add({
                    userId: userId,
                    title: "Pembayaran Berhasil! 🎉",
                    message: `Pembayaran pesanan ${orderId} telah berhasil diverifikasi. Pesananmu sedang disiapkan.`,
                    type: "order",
                    isRead: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp()
                });

                console.log(`🔔 Notifikasi berhasil dikirim ke database!`);
            }
        }

        // Balas Xendit agar dia tahu kita sudah menerima datanya
        res.status(200).json({ message: 'Webhook received' });

    } catch (error) {
        console.error("❌ [WEBHOOK] Gagal memproses data:", error);
        if (!res.headersSent) {
            res.status(500).json({ message: 'Internal Server Error' });
        }
    }
});


app.get('/api/search-area', async (req, res) => {
    try {
        const { keyword } = req.query; 

        const response = await axios.get(`${BITESHIP_BASE_URL}/maps/areas?countries=ID&input=${keyword}&type=single`, {
            headers: { 
                'Authorization': `Bearer ${BITESHIP_API_KEY}` 
            }
        });
        
        console.log("✅ Biteship Sukses! Area ditemukan:", response.data.areas.length);
        res.json({ success: true, data: response.data.areas });
    } catch (error) {
        console.error("❌ Gagal cari area:", error.response ? error.response.data : error.message);
        res.status(500).json({ success: false, message: error.message });
    }
});


app.post('/api/check-rates', async (req, res) => {
    try {
        const { destinationAreaId, items } = req.body;

        console.log("📦 Memproses ongkir...");
        console.log("📍 ID Alamat Tujuan (Dari Flutter):", destinationAreaId);

        if (!destinationAreaId || destinationAreaId.trim() === '') {
            return res.status(400).json({ 
                success: false, 
                message: "Area ID kosong! Tolong buat alamat baru di HP-mu menggunakan Autocomplete Biteship." 
            });
        }

        const formattedItems = items.map(item => ({
            name: item.name,
            value: item.price,
            quantity: item.qty,
            weight: item.weight || 1000 
        }));

        const response = await axios.post(`${BITESHIP_BASE_URL}/rates/couriers`, {
            origin_postal_code: 12240, 
            destination_area_id: destinationAreaId,
            couriers: "jne,sicepat,jnt", 
            items: formattedItems
        }, {
            headers: { 
                'Authorization': `Bearer ${BITESHIP_API_KEY}`,
                'Content-Type': 'application/json'
            }
        });

        console.log("✅ Berhasil menyedot ongkir dari Biteship!");
        res.json({ success: true, data: response.data.pricing });

    } catch (error) {
        console.error("❌ Gagal cek ongkir:", error.response ? error.response.data : error.message);
        res.status(500).json({ success: false, message: error.message });
    }
});



if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
}
module.exports = app;