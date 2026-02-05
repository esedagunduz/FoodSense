# 📱 FoodSense – AI Destekli iOS Beslenme Takip Uygulaması

FoodSense, yapay zeka ile yemek fotoğraflarını analiz ederek besin değerlerini otomatik hesaplayan ve kullanıcıların kalori ile makro besin takibini kolaylaştıran bir iOS uygulamasıdır.

## 📸 AI Destekli Yemek Analizi
Kullanıcı, yemeğinin fotoğrafını kameradan çekerek veya galeriden seçerek analiz sürecini başlatır. Seçilen görüntü, Google Gemini 2.5 Flash ile analiz edilir ve:
- Kalori ve makro besin değerleri (protein, karbonhidrat, yağ) otomatik olarak hesaplanır
- Analiz edilen öğünler kaydedilerek günlük beslenme takibine dahil edilir

## 📊 Analytics & Beslenme Takibi
FoodSense, beslenme verilerini grafiklerle analiz ederek:
- Günlük, haftalık ve aylık kalori takibi
- Makro besin dağılımları (protein, karbonhidrat, yağ)
- Kalori hedeflerine uyum durumu (eksik / hedefte / fazla)
- Haftalık ve aylık trend grafikleri

## 🔹 Performans Odaklı Veri Yönetimi
- Aktif aya ait veriler SwiftData ile local olarak tutulur ve hızlı erişim sağlanır
- Tüm veriler Firebase ile senkronize edilir; eski aylara ait veriler gerektiğinde remote’dan okunur
- Ay değişiminde local cache otomatik olarak temizlenir

## ✅ Unit Testing
- XCTest ile unit testler yazıldı
- Mock-based & async/await testing
- State validation, error handling ve edge case’ler test edildi

## 🛠️ Kullanılan Teknolojiler & Yaklaşım
- Swift & SwiftUI – Modern, hızlı ve güvenli iOS UI geliştirme
- MVVM & State Management – View ve iş mantığının ayrımı
- Dependency Injection & Protocol-Oriented Programming – Test edilebilir ve esnek yapı
- Repository Pattern – Local ve remote veri katmanının ayrımı
- SwiftData – Local veri depolama ve hızlı erişim
- Firebase Firestore – Cloud depolama ve veri senkronizasyonu
- Google Gemini 2.5 Flash – AI destekli yemek fotoğrafı analizi
- XCTest – Unit test ile uygulama akışlarının güvence altına alınması

<p float="left">
  <img src="https://github.com/user-attachments/assets/6e2fb7fe-dc91-495f-840a-588fb01b00d6" width="200" />
  <img src="https://github.com/user-attachments/assets/7af18004-1364-423c-a52c-527ce5ffdebe" width="200" />
  <img src="https://github.com/user-attachments/assets/2458448e-dc81-47a7-8c3f-5e7517a672ae" width="200" />
</p>
<p float="left">
  <img src="https://github.com/user-attachments/assets/ced6899d-dd98-4916-8a8b-92cd00aab050" width="200" />
  <img src="https://github.com/user-attachments/assets/be18402a-37bc-4aa5-bab0-172d59893d19" width="200" />
  <img src="https://github.com/user-attachments/assets/f6fbb53b-ef3c-40a8-a2b0-cc670d717b38" width="200" />
</p>
<p float="left">
<img src="https://github.com/user-attachments/assets/87a49159-e4bd-4f4e-81d9-b24653ab5f3c" width="200" />
  <img src="https://github.com/user-attachments/assets/d6de773e-8598-4aef-9c3a-9224739a46b6" width="200" />
  <img src="https://github.com/user-attachments/assets/cecd72ed-51bc-40ec-beaf-0d8850836c08" width="200" />
 </p>
<p float="left">
 <img src="https://github.com/user-attachments/assets/ba00824f-ed1c-4263-88c9-0830de482354" width="200" />
  <img src="https://github.com/user-attachments/assets/d299f8c2-ff0f-4e02-9381-1f26c8bb60f1" width="200" />
</p>
