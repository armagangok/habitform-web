import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/core/core.dart';
import '../category_picker.dart';
import '../sheet_header.dart';
import '../trailing_button.dart';

class IconPickerSheet extends StatefulWidget {
  final Function(IconData) onIconSelected;

  const IconPickerSheet({super.key, required this.onIconSelected});

  @override
  IconPickerSheetState createState() => IconPickerSheetState();
}

class IconPickerSheetState extends State<IconPickerSheet> with SingleTickerProviderStateMixin {
  // Initial selected category index
  int selectedCategoryIndex = 0;

  int? selectedIconIndex;

  late final AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

  // Define categories with icons
  Map<String, List<IconData>> iconCategories = {
    "Sports": [
      Icons.sports_soccer, // Futbol
      Icons.sports_basketball, // Basketbol
      Icons.sports_baseball, // Beyzbol
      Icons.sports_baseball_outlined, // Beyzbol
      CupertinoIcons.sportscourt, // Genel spor alanı ikonu
      Icons.sports_tennis, // Tenis
      Icons.sports_volleyball, // Voleybol
      Icons.sports_football, // Amerikan futbolu
      Icons.sports_cricket, // Kriket
      Icons.sports_golf, // Golf
      Icons.sports_mma, // Dövüş sporları, MMA
      Icons.sports_motorsports, // Motor sporları
      Icons.sports_rugby, // Rugby
      Icons.sports_esports, // E-spor
      Icons.sports_kabaddi, // Kabaddi
      Icons.directions_bike, // Bisiklet
      Icons.fitness_center, // Fitness, ağırlık kaldırma
      Icons.pool, // Yüzme, havuz
      Icons.snowboarding, // Snowboard
      Icons.surfing, // Sörf
      Icons.rowing, // Kürek sporu
      Icons.ice_skating, // Buz pateni
      Icons.sailing, // Yelken sporu
      Icons.paragliding, // Yamaç paraşütü
      Icons.hiking, // Doğa yürüyüşü, trekking
      Icons.nordic_walking, // Yürüyüş sporu
      Icons.kayaking, // Kano, kayak
      Icons.run_circle, // Koşu
      Icons.skateboarding, // Kaykay
    ],
    "Health": [
      CupertinoIcons.heart, // Kalp, sağlık ve fitness teması
      CupertinoIcons.heart_fill, // Dolu kalp, fitness, sevilen sağlık aktivitesi
      CupertinoIcons.flame, // Kalori yakma, yoğun egzersiz
      CupertinoIcons.flame_fill, // Kalori yakma, yoğun egzersiz
      CupertinoIcons.person_crop_circle, // Kişi temsili, bireysel sağlık ve fitness
      CupertinoIcons.staroflife, // Sağlık simgesi, tıp teması
      CupertinoIcons.bandage, // İlk yardım veya sağlık bakımı
      CupertinoIcons.bandage_fill, // İlk yardım veya sağlık bakımı
      CupertinoIcons.thermometer, // Sağlık durumu takibi, sıcaklık ölçümü
      CupertinoIcons.thermometer_snowflake, // Sağlık durumu takibi, sıcaklık ölçümü
      CupertinoIcons.thermometer_sun, // Sağlık durumu takibi, sıcaklık ölçümü
      CupertinoIcons.waveform_path_ecg, // Kalp atışı, ECG, kalp sağlığı
      CupertinoIcons.waveform_path, // Kalp atışı, ECG, kalp sağlığı
      CupertinoIcons.waveform, // Kalp atışı, ECG, kalp sağlığı
      Icons.favorite, // Kalp, sağlık ve sevgi
      Icons.favorite_border, // Boş kalp, sağlık ilgisi
      Icons.local_hospital, // Hastane, tıbbi bakım
      Icons.healing, // Şifa, sağlık ve iyileşme
      Icons.medical_services, // Sağlık hizmetleri, klinik teması
      Icons.monitor_heart, // Kalp atışı monitörü
      Icons.health_and_safety, // Sağlık ve güvenlik
      Icons.fitness_center, // Fitness, ağırlık çalışması
      Icons.water_drop, // Su alımı, hidrasyon
      Icons.coronavirus, // Sağlık temalı maske simgesi
      Icons.bloodtype, // Kan bağışı veya kan grubu
      Icons.vaccines, // Aşı, sağlık koruması
      Icons.thermostat, // Vücut sıcaklığı ölçümü
    ],
    "Social": [
      CupertinoIcons.person_2, // Sosyal bağlantı veya arkadaşlar
      CupertinoIcons.person_2_fill, // Sosyal bağlantı veya arkadaşlar
      CupertinoIcons.person_3, // Grup, topluluk veya sosyal çevre
      CupertinoIcons.person_3_fill, // Grup, topluluk veya sosyal çevre
      CupertinoIcons.person_add, // Grup, topluluk veya sosyal çevre
      CupertinoIcons.person_add_solid, // Grup, topluluk veya sosyal çevre
      CupertinoIcons.group_solid,
      CupertinoIcons.group, // Topluluk veya sosyal grup
      CupertinoIcons.chat_bubble, // Sohbet, mesajlaşma
      CupertinoIcons.chat_bubble_fill, // Dolu sohbet balonu, aktif mesajlaşma
      CupertinoIcons.chat_bubble_text, // Sohbet, mesajlaşma
      CupertinoIcons.chat_bubble_text_fill, // Sohbet, mesajlaşma
      CupertinoIcons.envelope, // E-posta veya mesaj gönderme
      CupertinoIcons.mail, // E-posta, iletişim
      CupertinoIcons.phone, // Telefon, arama yapma
      CupertinoIcons.phone_fill, // Dolu telefon, arama durumu
      CupertinoIcons.share, // Paylaşma, içerik gönderme
      CupertinoIcons.link, // Bağlantı paylaşma
      CupertinoIcons.bell, // Bildirim, sosyal medya uyarıları
      CupertinoIcons.add, // Yeni kişi veya grup ekleme
      CupertinoIcons.hand_thumbsup, // Beğenme, sosyal destek
      CupertinoIcons.hand_thumbsup_fill, // Beğenme, sosyal destek
      CupertinoIcons.heart, // Sevgi veya beğeni
      CupertinoIcons.heart_fill, // Sevgi veya beğeni
      Icons.person, // Kişi, profil
      Icons.group, // Kişi, profil
      Icons.group_outlined, // Kişi, profil
      Icons.group, // Grup, topluluk
      Icons.people, // Sosyal çevre, arkadaş grubu
      Icons.chat, // Mesajlaşma, sohbet
      Icons.message, // Mesaj, iletişim
      Icons.mail, // E-posta, iletişim
      Icons.phone, // Telefon, arama
      Icons.share, // Paylaşma, sosyal medya
      Icons.link, // Bağlantı, URL paylaşımı
      Icons.notifications, // Bildirim, uyarılar
      Icons.add_circle, // Yeni bağlantı ekleme
      Icons.thumb_up, // Beğenme, sosyal medya
      Icons.favorite, // Beğeni, kalp
      Icons.send, // Mesaj veya e-posta gönderme
      Icons.public, // Genel paylaşım, sosyal erişim
      Icons.connect_without_contact, // Dijital iletişim veya uzaktan bağlantı
      Icons.follow_the_signs, // Sosyal destek veya rehberlik
    ],
    "Nature": [
      CupertinoIcons.cloud, // Bulut, hava durumu
      CupertinoIcons.cloud_fill, // Dolu bulut
      CupertinoIcons.sun_max, // Güneş, parlak hava
      CupertinoIcons.sun_max_fill, // Dolu güneş
      CupertinoIcons.moon, // Ay, gece
      CupertinoIcons.moon_fill, // Dolu ay
      CupertinoIcons.wind, // Rüzgar, hava durumu
      CupertinoIcons.snow, // Kar, soğuk hava
      CupertinoIcons.wind_snow, // Kar, soğuk hava
      CupertinoIcons.cloud_snow_fill, // Kar, soğuk hava
      CupertinoIcons.drop, // Su damlası, yağmur
      CupertinoIcons.drop_fill, // Dolu su damlası
      Icons.wb_sunny, // Güneş, açık hava
      Icons.wb_sunny_outlined, // Çizimli güneş ikonu
      Icons.cloud, // Bulut, hava durumu
      Icons.cloud_outlined, // Çizimli bulut
      Icons.brightness_5, // Güneş ışığı
      Icons.brightness_3, // Gece veya ay ışığı
      Icons.brightness_4, // Alacakaranlık, hava durumu
      Icons.filter_vintage, // Çiçek veya doğa teması
      Icons.nightlight_round, // Ay veya gece
      Icons.water, // Su, doğa veya çevre
      Icons.water_drop, // Su damlası
    ],
    "Business": [
      CupertinoIcons.briefcase, // Çanta, iş dünyası
      CupertinoIcons.briefcase_fill, // Çanta, iş dünyası
      CupertinoIcons.chart_bar, // Çubuk grafiği, analiz ve iş verileri
      CupertinoIcons.chart_bar_fill, // Çubuk grafiği, analiz ve iş verileri
      CupertinoIcons.chart_bar_alt_fill, // Dolu çubuk grafiği
      CupertinoIcons.chart_pie, // Pasta grafiği, analiz ve iş verileri
      CupertinoIcons.chart_pie_fill, // Pasta grafiği, analiz ve iş verileri
      CupertinoIcons.person_crop_circle, // Kişi simgesi, iş görüşmeleri
      CupertinoIcons.calendar, // Takvim, iş toplantıları
      CupertinoIcons.calendar_today, // Takvim, iş toplantıları
      CupertinoIcons.calendar_today, // Bugünkü tarih
      CupertinoIcons.money_dollar, // Dolar simgesi, finans
      CupertinoIcons.money_euro, // Dolar simgesi, finans
      CupertinoIcons.money_pound, // Dolar simgesi, finans
      CupertinoIcons.money_rubl, // Dolar simgesi, finans
      CupertinoIcons.money_yen, // Dolar simgesi, finans
      CupertinoIcons.creditcard, // Kredi kartı, iş finansmanı
      CupertinoIcons.folder, // Klasör, dosya düzeni
      CupertinoIcons.folder_fill, // Klasör, dosya düzeni
      CupertinoIcons.folder_fill_badge_person_crop, // Klasör, dosya düzeni
      CupertinoIcons.doc, // Doküman, iş belgeleri
      CupertinoIcons.doc_fill, // Doküman, iş belgeleri
      CupertinoIcons.doc_append, // Doküman, iş belgeleri
      CupertinoIcons.doc_chart, // Doküman, iş belgeleri
      CupertinoIcons.doc_chart_fill, // Doküman, iş belgeleri
      CupertinoIcons.phone, // Telefon, iş iletişimi
      CupertinoIcons.phone_solid, // Telefon, iş iletişimi
      CupertinoIcons.mail, // E-posta, iş iletişimi
      CupertinoIcons.mail_solid, // E-posta, iş iletişimi
      Icons.business, // İş binası, iş dünyası
      Icons.business_center, // İş merkezi, çalışma
      Icons.attach_money, // Para simgesi, finans
      Icons.money, // Para, iş finansmanı
      Icons.account_balance, // Banka, iş finansmanı
      Icons.pie_chart, // Pasta grafiği, analiz
      Icons.pie_chart_outline, // Çizimli pasta grafiği
      Icons.bar_chart, // Çubuk grafiği, iş analizi
      Icons.show_chart, // Çizgi grafiği, iş analizi
      Icons.insert_chart, // Grafik ekleme
      Icons.insert_chart_outlined, // Çizimli grafik
      Icons.people, // İnsanlar, ekip çalışması
      Icons.groups, // Gruplar, iş ekipleri
      Icons.work, // İş, kariyer
      Icons.folder, // Klasör, dosya yönetimi
      Icons.document_scanner, // Belge tarayıcı, belge yönetimi
      Icons.date_range, // Takvim, toplantı planlama
      Icons.schedule, // Program, iş planı
      Icons.email, // E-posta, iş iletişimi
      Icons.phone, // Telefon, iletişim
      Icons.phone_android_rounded, // Telefon, iletişim
      Icons.phone_iphone, // Telefon, iletişim
    ],
    "Task & Project": [
      CupertinoIcons.list_bullet,
      CupertinoIcons.list_bullet_indent,
      CupertinoIcons.square_list,
      CupertinoIcons.square_list_fill,
      CupertinoIcons.calendar,
      CupertinoIcons.calendar_badge_plus,
      CupertinoIcons.doc_text,
      CupertinoIcons.text_badge_checkmark,
      CupertinoIcons.paperclip,
      CupertinoIcons.folder_fill,
      CupertinoIcons.briefcase_fill,
      CupertinoIcons.arrow_up_right_circle,
      CupertinoIcons.arrow_up_right_circle_fill,
      CupertinoIcons.add_circled,
      CupertinoIcons.add_circled_solid,
      CupertinoIcons.check_mark, // Onay işareti, tamamlanan görevler
      CupertinoIcons.check_mark_circled_solid, // Onay işareti, tamamlanan görevler
      CupertinoIcons.circle, // Daire, görev durumu
      CupertinoIcons.circle_fill, // Dolu daire, seçili görev
      CupertinoIcons.list_bullet, // Liste, görev veya proje listesi
      CupertinoIcons.square_list, // Kare liste, görev veya proje planı
      CupertinoIcons.pencil, // Kalem, düzenleme veya güncelleme
      CupertinoIcons.flag, // Bayrak, önemli görev veya hedef
      CupertinoIcons.calendar, // Takvim, tarih ve zaman yönetimi
      CupertinoIcons.bell, // Zil, bildirim ve hatırlatıcı
      CupertinoIcons.timer, // Zamanlayıcı, süreli görevler
      CupertinoIcons.checkmark_circle_fill,
      CupertinoIcons.ellipsis,
      Icons.task, // Görev, yapılacak iş
      Icons.task_alt, // Alternatif görev simgesi, tamamlanmış görevler
      Icons.check_circle, // Onay işareti, tamamlanan görev
      Icons.check_circle_outline, // Çizimli onay işareti
      Icons.assignment, // Atama, görev veya proje
      Icons.assignment_turned_in, // Tamamlanmış atama, bitmiş görev
      Icons.event, // Etkinlik, görev planlama
      Icons.flag, // Bayrak, işaretlenmiş görev
      Icons.list, // Liste, görev veya yapılacaklar listesi
      Icons.schedule, // Program, görev takvimi
      Icons.date_range, // Tarih aralığı, proje süresi
      Icons.alarm, // Alarm, görev hatırlatıcı
      Icons.access_time, // Zaman, süreli görev
      Icons.timer, // Zamanlayıcı, süreli proje yönetimi
      Icons.pending_actions, // Bekleyen işlemler, yapılacak görevler
      Icons.note, // Not, görev ayrıntıları
      Icons.notes, // Notlar, projeye ait açıklamalar
    ],
    "Art": [
      CupertinoIcons.pencil, // Kalem, çizim veya taslak
      CupertinoIcons.pencil_outline, // Çizimli kalem
      CupertinoIcons.paintbrush, // Boyama veya çizim
      CupertinoIcons.paintbrush_fill, // Dolu boya fırçası
      CupertinoIcons.photo, // Fotoğraf, sanat eseri
      CupertinoIcons.photo_fill, // Dolu fotoğraf
      CupertinoIcons.camera, // Kamera, fotoğrafçılık
      CupertinoIcons.camera_fill, // Dolu kamera
      CupertinoIcons.doc_plaintext, // Taslak veya çizim notları
      Icons.brush, // Fırça, çizim veya boyama
      Icons.brush_outlined, // Çizimli fırça
      Icons.color_lens, // Renk paleti, sanat
      Icons.color_lens_outlined, // Çizimli renk paleti
      Icons.palette, // Renk paleti, sanat ve tasarım
      Icons.palette_outlined, // Çizimli renk paleti
      Icons.photo, // Fotoğraf, sanat eseri
      Icons.photo_outlined, // Çizimli fotoğraf
      Icons.photo_camera, // Kamera, fotoğrafçılık
      Icons.photo_camera_outlined, // Çizimli kamera
      Icons.image, // Görsel, sanat eseri
      Icons.image_outlined, // Çizimli görsel
      Icons.edit, // Düzenleme, çizim veya sanat eseri oluşturma
      Icons.mode_edit, // Çizim veya tasarım için düzenleme
      Icons.auto_fix_high, // Renk düzenleme veya iyileştirme
      Icons.camera_roll, // Kamera rulosu, fotoğrafçılık
      Icons.camera_roll_outlined, // Çizimli kamera rulosu
      Icons.design_services, // Tasarım ve yaratıcı hizmetler
      Icons.photo_album, // Fotoğraf albümü, sanat koleksiyonu
      Icons.photo_album_outlined, // Çizimli fotoğraf albümü
    ],
    "Study": [
      CupertinoIcons.book, // Kitap, ders çalışmak veya eğitim
      CupertinoIcons.book_fill, // Dolu kitap
      CupertinoIcons.pencil, // Kalem, not alma veya yazı yazma
      CupertinoIcons.pencil_outline, // Çizim veya taslak oluşturma
      CupertinoIcons.folder, // Dosya, ders notları veya kaynaklar
      CupertinoIcons.folder_fill, // Dolu dosya, materyal depolama
      CupertinoIcons.timer, // Zaman yönetimi, sınav süresi
      CupertinoIcons.timer_fill, // Dolu zamanlayıcı
      CupertinoIcons.calendar, // Takvim, sınav ve ders takibi
      CupertinoIcons.calendar_today, // Günlük takvim
      CupertinoIcons.lightbulb, // Fikir veya öğrenme
      CupertinoIcons.lightbulb_fill, // Dolu fikir ampulü
      CupertinoIcons.square_list, // Görev listesi, çalışma planı
      CupertinoIcons.square_list_fill, // Dolu görev listesi
      CupertinoIcons.doc_text, // Belge veya yazılı ödev
      CupertinoIcons.doc_text_fill, // Dolu belge
      CupertinoIcons.question_circle, // Soru, sınav soruları veya quiz
      CupertinoIcons.question_circle_fill, // Dolu soru ikonu
      Icons.book, // Kitap, öğrenme veya ders
      Icons.book_outlined, // Çizimli kitap ikonu
      Icons.bookmark, // Okuma listesi veya işaretleme
      Icons.bookmark_outline, // Çizimli işaret
      Icons.menu_book, // Ders kitabı, ders materyalleri
      Icons.menu_book_outlined, // Çizimli ders kitabı
      Icons.library_books, // Kütüphane, ders materyalleri
      Icons.library_books_outlined, // Çizimli kütüphane ikonu
      Icons.edit, // Düzenleme, yazı yazma veya not alma
      Icons.edit_outlined, // Çizimli düzenleme
      Icons.folder, // Dosya, ders materyali
      Icons.folder_open, // Açık dosya
      Icons.schedule, // Programlama veya zaman yönetimi
      Icons.schedule_outlined, // Çizimli programlama
      Icons.assignment, // Ödev veya sınav
      Icons.assignment_turned_in_outlined, // Çizimli tamamlanmış görev
      Icons.calendar_today, // Takvim, sınav ve ders programı
      Icons.calendar_month, // Aylık takvim
      Icons.calendar_today_outlined, // Çizimli günlük takvim
      Icons.checklist, // Çalışma listesi, görev planlama
      Icons.checklist_rtl, // Çalışma listesi, sağdan sola
      Icons.lightbulb, // Fikir veya öğrenme süreci
      Icons.lightbulb_outline, // Çizimli fikir ampulü
      Icons.question_answer, // Sorular veya cevaplar
      Icons.timer, // Zamanlayıcı, sınav süresi yönetimi
      Icons.timer_outlined, // Çizimli zamanlayıcı
    ],
    "Pets": [
      CupertinoIcons.paw,
      FontAwesomeIcons.paw,
      FontAwesomeIcons.cat,
      FontAwesomeIcons.dog,
      FontAwesomeIcons.bowlFood,
      FontAwesomeIcons.kiwiBird,
      FontAwesomeIcons.twitter,
      FontAwesomeIcons.frog, // Frogs or amphibians
      FontAwesomeIcons.spider, // Exotic pets like spiders
      FontAwesomeIcons.otter, // Small mammals like otters
      FontAwesomeIcons.dove, // Birds or freedom symbolism
    ],
    "Garden & Yard": [
      CupertinoIcons.leaf_arrow_circlepath, // Yaprak, bitki veya doğa
      CupertinoIcons.tree, // Ağaç, doğa ve orman
      FontAwesomeIcons.tree,
      FontAwesomeIcons.carrot,
      Icons.yard,
      Icons.yard_outlined,
      Icons.terrain, // Arazi, doğa manzarası
      Icons.grass, // Çimen, doğa veya açık alan
      Icons.nature, // Doğa veya doğa alanı
      Icons.nature_outlined, // Çizimli doğa ikonu
      Icons.park, // Park veya doğa alanı
      Icons.park_outlined, // Çizimli park
      Icons.eco, // Ekoloji, çevre dostu
      Icons.eco_outlined, // Çizimli çevre ikonu
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Extract the keys as category names
    List<String> categoryNames = iconCategories.keys.toList();

    return SizedBox(
      height: context.height(.5),
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        navigationBar: SheetHeader(
          title: "Icon",
          closeButtonPosition: CloseButtonPosition.left,
          trailing: TrailingActionButton(
            title: "Save",
            onPressed: navigator.pop,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryWidget(
                      categories: categoryNames,
                      onCategorySelected: (int selectedCategory) {
                        controller.forward(from: 0);
                        setState(() {
                          selectedCategoryIndex = selectedCategory;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CupertinoScrollbar(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: iconCategories[categoryNames[selectedCategoryIndex]]!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                        ),
                        itemBuilder: (context, index) {
                          final iconData = iconCategories[categoryNames[selectedCategoryIndex]]![index];

                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                selectedIconIndex = index;
                              });

                              widget.onIconSelected(iconData);
                            },
                            child: Card(
                              color: index == selectedIconIndex ? context.primary.withValues(alpha: .25) : Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  iconData,
                                  size: 44,
                                  color: context.theme.iconTheme.color?.withValues(alpha: .75),
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate(controller: controller).fadeIn(duration: 500.ms),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
