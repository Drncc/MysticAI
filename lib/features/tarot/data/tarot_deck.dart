import 'package:tekno_mistik/features/tarot/data/models/tarot_card_model.dart';

class TarotDeck {
  static List<TarotCard> majorArcana = [
    TarotCard(id: 0, codeName: 'fool', nameTr: 'Deli', meaning: "Başlangıçlar, masumiyet, spontanlık, özgür ruh.", variantCount: 4),
    TarotCard(id: 1, codeName: 'magician', nameTr: 'Büyücü', meaning: "Tezahür, beceriklilik, güç, ilham.", variantCount: 3),
    TarotCard(id: 2, codeName: 'highpriestess', nameTr: 'Azize', meaning: "Sezgi, bilinçaltı, iç ses, gizem.", variantCount: 4),
    TarotCard(id: 3, codeName: 'theempress', nameTr: 'İmparatoriçe', meaning: "Doğurganlık, dişilik, güzellik, doğa, bolluk.", variantCount: 3), // 'the' VAR
    TarotCard(id: 4, codeName: 'theemperor', nameTr: 'İmparator', meaning: "Otorite, yapı, kontrol, babalık.", variantCount: 3), // 'the' VAR
    TarotCard(id: 5, codeName: 'thehierophant', nameTr: 'Aziz', meaning: "Gelenek, inanç, maneviyat, rehberlik.", variantCount: 4), // 'the' VAR
    TarotCard(id: 6, codeName: 'lovers', nameTr: 'Aşıklar', meaning: "Aşk, uyum, ilişkiler, değerler.", variantCount: 3),
    TarotCard(id: 7, codeName: 'chariot', nameTr: 'Savaş Arabası', meaning: "Kontrol, irade, başarı, eylem.", variantCount: 4),
    TarotCard(id: 8, codeName: 'strenght', nameTr: 'Güç', meaning: "Güç, cesaret, sabır, kontrol.", variantCount: 3), // Yazım hatası korundu 'strenght'
    TarotCard(id: 9, codeName: 'hermit', nameTr: 'Ermiş', meaning: "İç gözlem, yalnızlık, rehberlik.", variantCount: 3),
    TarotCard(id: 10, codeName: 'wheeloffortune', nameTr: 'Kader Çarkı', meaning: "Şans, karma, yaşam döngüleri, kader.", variantCount: 4),
    TarotCard(id: 11, codeName: 'justice', nameTr: 'Adalet', meaning: "Adalet, denge, gerçek, hukuk.", variantCount: 4),
    TarotCard(id: 12, codeName: 'hanged', nameTr: 'Asılan Adam', meaning: "Teslimiyet, fedakarlık, yeni bakış açısı.", variantCount: 4),
    TarotCard(id: 13, codeName: 'death', nameTr: 'Ölüm', meaning: "Sonlar, değişim, dönüşüm, geçiş.", variantCount: 4),
    TarotCard(id: 14, codeName: 'temperance', nameTr: 'Denge', meaning: "Denge, ılımlılık, sabır, amaç.", variantCount: 3),
    TarotCard(id: 15, codeName: 'devil', nameTr: 'Şeytan', meaning: "Bağımlılık, maddiyat, cinsellik, gölge benlik.", variantCount: 4),
    TarotCard(id: 16, codeName: 'tower', nameTr: 'Yıkılan Kule', meaning: "Ani değişim, kaos, yıkım, uyanış.", variantCount: 4),
    TarotCard(id: 17, codeName: 'star', nameTr: 'Yıldız', meaning: "Umut, inanç, amaç, yenilenme.", variantCount: 3),
    TarotCard(id: 18, codeName: 'moon', nameTr: 'Ay', meaning: "Yanılsama, korku, kaygı, bilinçaltı.", variantCount: 4),
    TarotCard(id: 19, codeName: 'sun', nameTr: 'Güneş', meaning: "Pozitiflik, eğlence, sıcaklık, başarı.", variantCount: 4),
    TarotCard(id: 20, codeName: 'judgement', nameTr: 'Mahkeme', meaning: "Yargı, yeniden doğuş, iç çağrı.", variantCount: 4),
    TarotCard(id: 21, codeName: 'world', nameTr: 'Dünya', meaning: "Tamamlanma, entegrasyon, başarı, seyahat.", variantCount: 4),
  ];
}
