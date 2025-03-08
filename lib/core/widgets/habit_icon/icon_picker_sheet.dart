import 'package:flutter/services.dart';
import 'package:habitrise/core/widgets/custom_emoji_picker.dart';

import '/core/core.dart';

class IconPickerSheet extends StatefulWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;

  const IconPickerSheet({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
  });

  @override
  IconPickerSheetState createState() => IconPickerSheetState();
}

class IconPickerSheetState extends State<IconPickerSheet> with SingleTickerProviderStateMixin {
  // Initial selected category index
  int selectedCategoryIndex = 0;
  int? selectedIconIndex;

  late final AnimationController controller;
  final ScrollController _gridScrollController = ScrollController();
  final Map<int, GlobalKey> _iconKeys = {};

  // Define categories with emojis
  late Map<String, List<String>> emojiCategories;

  void _initializeCategories() {
    emojiCategories = {
      LocaleKeys.iconCategories_dailylife.tr(): [
        // Sleep and Rest
        '🛏️', // bed
        '🛌', // sleeping person
        '😴', // sleep emoji
        '🌙', // night

        // Personal Care
        '🚿', // shower
        '🪥', // toothbrush
        '💧', // water drop
        '🧴', // lotion
        '💆🏻‍♂️', // face care
        '💆🏻‍♀️', // spa
        '💇🏻‍♂️', // haircut
        '💇🏻‍♀️', // hair care

        // Hydration and Nutrition
        '💦', // water splash
        '🥤', // cup with straw
        '🫗', // pouring liquid
        '🧊', // ice
        '🧃', // juice box
        '🍶', // sake bottle (water bottle)

        // Protein and Healthy Foods
        '🥚', // egg
        '🍗', // poultry leg
        '🥩', // cut of meat
        '🥜', // peanuts
        '🫘', // beans
        '🧆', // falafel
        '🍤', // fried shrimp
        '🥓', // bacon

        // Fruits and Vegetables
        '🥦', // broccoli
        '🥬', // leafy green
        '🥕', // carrot
        '🍅', // tomato
        '🥒', // cucumber
        '🍆', // eggplant
        '🥑', // avocado
        '🌽', // corn
        '🍎', // apple
        '🍌', // banana
        '🍓', // strawberry

        // Meals and Cooking
        '🍳', // cooking
        '🥄', // spoon
        '🍽️', // plate and cutlery
        '🥗', // salad
        '🥪', // sandwich
        '🍲', // pot of food
        '🍚', // cooked rice
        '🥘', // shallow pan of food
        '🍞', // bread
        '🥛', // milk

        // Exercise and Movement
        '🏃🏻', // running
        '🚶🏻', // walking
        '🧘🏻‍♂️', // meditation
        '🧘🏻‍♀️', // yoga
        '🏋🏻‍♂️', // weight lifting
        '🏋🏻‍♀️', // fitness
        '🚴', // cycling
        '🏊', // swimming
        '⛹️', // ball bouncing
        '🤸', // cartwheeling

        // Work and Productivity
        '💻', // computer
        '📱', // phone
        '📚', // book
        '✍🏻', // writing
        '📝', // note taking
        '⏰', // alarm clock
        '📅', // calendar

        // Household Activities
        '🧹', // sweeping
        '🧺', // laundry
        '🧼', // cleaning
        '🛒', // shopping cart
        '🧰', // toolbox
        '🪴', // potted plant (fixed)

        // Transportation
        '🚗', // car
        '🚌', // bus
        '🚲', // bicycle

        // Communication
        '📞', // phone
        '💬', // messaging
        '📧', // email

        // Entertainment
        '🎮', // gaming
        '🎵', // music
        '📺', // TV
        '🎧', // headphones
        '📱', // smartphone
        '🎬', // movie clapper
      ],
      LocaleKeys.iconCategories_sports.tr(): [
        // Walking and Running
        '🏃🏻‍♂️', // running (male)
        '🏃🏻‍♀️', // running (female)
        '🚶🏻‍♂️', // walking (male)
        '🚶🏻‍♀️', // walking (female)

        // Fitness and Strength Sports
        '🏋🏻‍♂️', // weight lifting (male)
        '🏋🏻‍♀️', // weight lifting (female)
        '🤸🏻‍♂️', // gymnastics
        '🤸🏻‍♀️', // gymnastics
        '🧘🏻‍♂️', // yoga (male)
        '🧘🏻‍♀️', // yoga (female)
        '🤾', // handball
        '🤼', // wrestling

        // Team Sports
        '⚽', // soccer
        '🏀', // basketball
        '🏈', // american football
        '⚾', // baseball
        '🏐', // volleyball
        '🏉', // rugby
        '🏑', // field hockey
        '🏒', // ice hockey

        // Racket Sports
        '🎾', // tennis
        '🏸', // badminton
        '🏓', // table tennis
        '🥍', // lacrosse

        // Water Sports
        '🏊🏻‍♂️', // swimming (male)
        '🏊🏻‍♀️', // swimming (female)
        '🚣🏻‍♂️', // rowing
        '🏄🏻‍♂️', // surfing (male)
        '🏄🏻‍♀️', // surfing (female)
        '🤽', // water polo
        '🛶', // canoe

        // Cycling
        '🚴🏻‍♂️', // cycling (male)
        '🚴🏻‍♀️', // cycling (female)
        '🚵', // mountain biking

        // Winter Sports
        '🏂🏻', // snowboarding
        '⛷️', // skiing
        '🎿', // ski equipment
        '🛷', // sled
        '⛸️', // ice skating

        // Martial Arts
        '🥋', // martial arts
        '🥊', // boxing
        '🤺', // fencing

        // Other Sports
        '🏇', // horse riding
        '⛳', // golf
        '🎯', // darts
        '🏹', // archery
        '🛹', // skateboarding
        '🛼', // roller skate

        // Sports Equipment
        '🥅', // goal net
        '🥎', // softball
        '🥏', // frisbee
        '⚾', // baseball
        '🏆', // trophy
        '🏅', // sports medal
      ],

      LocaleKeys.iconCategories_health.tr(): [
        // Heart and Health
        '❤️', // heart
        '🫀', // anatomical heart
        '💝', // healthy heart
        '🧠', // brain
        '🫁', // lungs

        // Medical Symbols
        '⚕️', // medical symbol
        '🏥', // hospital
        '💊', // medicine
        '💉', // syringe
        '🩺', // stethoscope

        // Healthcare Professionals
        '👨🏻‍⚕️', // doctor (male)
        '👩🏻‍⚕️', // doctor (female)
        '🧑🏻‍⚕️', // healthcare worker

        // Medical Equipment
        '🌡️', // thermometer
        '🩻', // x-ray
        '🔬', // microscope
        '🩹', // bandage
        '🩼', // crutch
        '🦮', // guide dog

        // Mental Health
        '🧘', // meditation
        '😌', // relieved face
        '🙏', // prayer hands
        '✨', // sparkles
        '🧿', // nazar amulet

        // Healthy Living
        '💪🏻', // strength
        '🥗', // healthy food
        '💧', // water
        '🍏', // green apple
        '🥦', // broccoli
        '🥝', // kiwi
        '🫐', // blueberries
        '🧘‍♀️', // yoga
        '🚶‍♀️', // walking
        '🧠', // mental health

        // Sleep and Rest
        '😴', // sleeping
        '🛌', // person in bed
        '🌙', // crescent moon
        '💤', // zzz
        '🧸', // teddy bear

        // Wellness
        '🧖‍♀️', // person in steam room
        '🧖‍♂️', // person in sauna
        '🌿', // herb
        '☕', // hot beverage
        '🍵', // tea (fixed)
      ],

      LocaleKeys.iconCategories_social.tr(): [
        // Communication
        '💬', // speech bubble
        '📱', // phone
        '📞', // telephone
        '📧', // email
        '📲', // mobile with arrow

        // Social Interaction
        '👥', // people
        '🤝', // handshake
        '🫂', // hugging
        '👋', // waving
        '🙌', // raised hands
        '👏', // clapping

        // Social Media
        '🌐', // world
        '📲', // messaging
        '💌', // message
        '🔔', // notification
        '📱', // smartphone
        '📷', // camera

        // Meetings and Collaboration
        '🗣️', // speaking
        '📢', // announcement
        '🤼', // meeting
        '🔗', // link
        '👨‍👩‍👧‍👦', // family
        '👯‍♀️', // people with bunny ears

        // Social Activities
        '🎉', // celebration
        '🎊', // party
        '🎭', // event
        '⭐', // star
        '🎁', // gift
        '🎂', // birthday cake
      ],

      LocaleKeys.iconCategories_nature.tr(): [
        // Weather
        '☀️', // sun
        '🌙', // moon
        '☁️', // cloud
        '🌧️', // rain
        '⛈️', // storm
        '❄️', // snow
        '🌪️', // tornado
        '🌈', // rainbow
        '⚡', // lightning

        // Plants
        '🌱', // seedling
        '🌿', // leaf
        '🌳', // tree
        '🌸', // flower
        '🌺', // hibiscus
        '🌻', // sunflower
        '🍀', // clover
        '🌵', // cactus
        '🌴', // palm tree

        // Seasons
        '🍁', // autumn
        '🌷', // spring
        '⛱️', // summer
        '☃️', // winter

        // Animals
        '🦁', // lion
        '🐘', // elephant
        '🦒', // giraffe
        '🦊', // fox
        '🦜', // parrot
        '🦋', // butterfly
        '🐝', // bee
        '🦔', // hedgehog
        '🐢', // turtle

        // Natural Formations
        '🏔️', // mountain
        '🌋', // volcano
        '🏖️', // beach
        '🌊', // wave
        '⛰️', // mountains
        '🏞️', // landscape
        '🏜️', // desert
        '🌄', // sunrise over mountains
      ],

      LocaleKeys.iconCategories_art.tr(): [
        // Art Supplies
        '🎨', // palette
        '🖌️', // brush
        '✏️', // pencil
        '🖍️', // crayon

        // Art Forms
        '🎭', // theater
        '🎨', // painting
        '🎼', // music
        '📷', // photography

        // Artists
        '👨🏻‍🎨', // artist (male)
        '👩🏻‍🎨', // artist (female)
        '🧑🏻‍🎨', // artist (neutral)

        // Crafts
        '🧶', // yarn
        '🧵', // thread
        '✂️', // scissors
        '🖼️', // frame

        // Performance
        '🎭', // mask
        '🎪', // circus
        '🎬', // film
        '🎤', // microphone
      ],

      LocaleKeys.iconCategories_business.tr(): [
        // Business Tools
        '💼', // briefcase
        '📱', // phone
        '💻', // laptop
        '📊', // chart

        // Office Supplies
        '📁', // folder
        '📝', // note
        '📎', // paperclip
        '✒️', // pen

        // Finance
        '💰', // money
        '💳', // credit card
        '📈', // growth chart
        '🏦', // bank

        // Planning
        '📅', // calendar
        '⏰', // clock
        '📋', // clipboard
        '✅', // check mark

        // Communication
        '👥', // meeting
        '📧', // email
        '📞', // phone
        '🤝', // agreement

        // Office
        '🏢', // building
        '💺', // seat
        '🗄️', // filing cabinet
        '🖨️', // printer
      ],

      LocaleKeys.iconCategories_studyandtask.tr(): [
        // Study Tools
        '📚', // books
        '📖', // open book
        '📓', // notebook
        '📔', // decorated notebook
        '📒', // ledger
        '📝', // note taking
        '✏️', // pencil
        '✒️', // fountain pen
        '🖊️', // pen
        '🖋️', // fountain pen
        '📏', // ruler
        '📐', // triangle ruler

        // Digital Tools
        '💻', // laptop
        '⌨️', // keyboard
        '🖥️', // desktop computer
        '📱', // mobile phone
        '🖱️', // computer mouse
        '🔋', // battery
        '💾', // floppy disk
        '📀', // DVD

        // Time Management
        '⏰', // alarm clock
        '⏱️', // stopwatch
        '⌚', // watch
        '⏳', // hourglass
        '⌛', // hourglass done
        '📅', // calendar
        '📆', // tear-off calendar
        '🗓️', // spiral calendar

        // Organization
        '📋', // clipboard
        '📊', // bar chart
        '📈', // increasing chart
        '📉', // decreasing chart
        '📑', // bookmark tabs
        '🗂️', // card index dividers
        '📁', // file folder
        '📂', // open file folder
        '🗄️', // file cabinet

        // Office Supplies
        '📌', // pushpin
        '📍', // round pushpin
        '📎', // paperclip
        '🔗', // link
        '✅', // check mark
        '☑️', // check box
        '✔️', // heavy check mark
        '📧', // e-mail
        '📨', // incoming envelope

        // Learning Environment
        '🎓', // graduation cap
        '🏫', // school
        '📕', // closed book
        '🔍', // magnifying glass
        '💡', // light bulb (idea)
        '🎯', // target
        '🏆', // trophy
        '🌟', // glowing star
        '⭐', // star

        // Education
        '👨🏻‍🏫', // teacher (male)
        '👩🏻‍🏫', // teacher (female)
        '🧑🏻‍🎓', // student
        '👨🏻‍💻', // technologist
        '👩🏻‍💻', // technologist
        '✍🏻', // writing hand

        // Study Subjects
        '🔢', // numbers
        '🔤', // abc
        '🔠', // input latin uppercase
        '📐', // geometry
        '🧮', // abacus
        '🗺️', // world map
        '🎨', // art
        '🧪', // science
        '🔬', // microscope
        '📜', // scroll
        '🧩', // puzzle piece
        '🔭', // telescope
      ],

      LocaleKeys.iconCategories_science.tr(): [
        // Laboratory
        '🧪', // test tube
        '🔬', // microscope
        '⚗️', // distillation
        '🧫', // petri dish
        '🧬', // DNA
        '🔭', // telescope

        // Scientists
        '👨🏻‍🔬', // scientist (male)
        '👩🏻‍🔬', // scientist (female)
        '🧑🏻‍🔬', // researcher
        '👨🏻‍💻', // technologist (male)
        '👩🏻‍💻', // technologist (female)

        // Medicine and Biology
        '🦠', // microbe
        '🫀', // heart
        '🧠', // brain
        '🦷', // tooth
        '🦴', // bone
        '🫁', // lungs
        '👁️', // eye

        // Space
        '🌌', // galaxy
        '🪐', // planet
        '🌍', // earth
        '🌠', // shooting star
        '🌟', // glowing star
        '🛰️', // satellite
        '🚀', // rocket

        // Measurement and Analysis
        '📊', // graph
        '📐', // triangle ruler
        '🌡️', // thermometer
        '⚖️', // scale
        '🧮', // abacus
        '🔍', // magnifying glass
        '📡', // satellite antenna
      ],

      LocaleKeys.iconCategories_gardenandyard.tr(): [
        // Plants
        '🌱', // seedling
        '🌳', // tree
        '🌺', // flower
        '🌸', // blooming
        '🌵', // cactus
        '🌴', // palm tree
        '🌲', // evergreen tree
        '🌿', // herb
        '☘️', // shamrock
        '🍀', // four leaf clover

        // Garden Tools
        '🪴', // potted plant
        '🌷', // tulip
        '💐', // bouquet
        '🪓', // axe
        '🧹', // broom
        '🪣', // bucket
        '🧤', // gloves
        '✂️', // scissors

        // Gardeners
        '👨🏻‍🌾', // gardener (male)
        '👩🏻‍🌾', // gardener (female)
        '🧑🏻‍🌾', // farmer

        // Garden Elements
        '⛲', // fountain
        '🏺', // vase
        '🪨', // rock
        '🌳', // landscaping
        '🪦', // tombstone
        '🏡', // house with garden
        '🌻', // sunflower
        '🍄', // mushroom
        '🐝', // bee
        '🦋', // butterfly
      ],

      LocaleKeys.iconCategories_pets.tr(): [
        // Dogs
        '🐕', // dog
        '🐶', // dog face
        '🦮', // guide dog
        '🐕‍🦺', // service dog
        '🦴', // bone

        // Cats
        '🐈', // cat
        '🐱', // cat face
        '🐈‍⬛', // black cat
        '🧶', // yarn ball

        // Small Pets
        '🐹', // hamster
        '🐰', // rabbit
        '🐢', // turtle
        '🦜', // parrot
        '🐇', // rabbit
        '🦔', // hedgehog
        '🦝', // raccoon
        '🦨', // skunk
        '🦡', // badger

        // Fish
        '🐠', // tropical fish
        '🐟', // fish
        '🐡', // blowfish
        '🦈', // shark
        '🐙', // octopus
        '🦑', // squid
        '🦐', // shrimp
        '🦞', // lobster

        // Pet Care
        '🐾', // paw prints
        '🪮', // mouse trap
        '🧹', // broom
        '🧼', // soap
        '✂️', // scissors
        '🛁', // bathtub
        '🧽', // sponge
      ],
      "Custom": [], // Custom emojis will be loaded from EmojiPicker
    };

    // Eğer seçili icon Custom kategorisindeyse listeye ekle
    if (widget.selectedIcon != null && !emojiCategories.values.any((list) => list.contains(widget.selectedIcon))) {
      emojiCategories["Custom"]!.add(widget.selectedIcon!);
    }
  }

  void _scrollSelectedIconIntoView() {
    if (!mounted || selectedIconIndex == null || !_iconKeys.containsKey(selectedIconIndex)) return;

    final context = _iconKeys[selectedIconIndex]?.currentContext;
    if (context == null || !_gridScrollController.hasClients) return;

    // İkonun pozisyonunu ve boyutunu al
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final position = box.localToGlobal(Offset.zero);

    // GridView'ın pozisyonunu ve boyutunu al
    final RenderBox gridBox = _gridScrollController.position.context.storageContext.findRenderObject() as RenderBox;
    final gridPosition = gridBox.localToGlobal(Offset.zero);
    final gridWidth = gridBox.size.width;

    // İkonun GridView içindeki göreceli pozisyonunu hesapla
    final relativePosition = position.dx - gridPosition.dx;

    // İkonun GridView'ın görünür alanında olup olmadığını kontrol et
    final isFullyVisible = relativePosition >= 0 && relativePosition + size.width <= gridWidth;

    // İkon tamamen görünür değilse, kaydır
    if (!isFullyVisible) {
      // İkonun GridView içindeki hedef pozisyonunu hesapla (ortada olacak şekilde)
      final targetPosition = _gridScrollController.offset + relativePosition - (gridWidth / 2) + (size.width / 2);

      // Hedef pozisyonu sınırla (minimum 0, maksimum scrollExtent)
      final clampedPosition = targetPosition.clamp(0.0, _gridScrollController.position.maxScrollExtent);

      // Eğer mevcut pozisyondan çok farklı değilse, kaydırma yapma
      if ((clampedPosition - _gridScrollController.offset).abs() > 20) {
        _gridScrollController.animateTo(
          clampedPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    _initializeCategories();

    if (widget.selectedIcon != null) {
      // Tüm kategorilerde ara (Custom dahil)
      for (var i = 0; i < emojiCategories.length; i++) {
        final category = emojiCategories.values.elementAt(i);
        final iconIndex = category.indexOf(widget.selectedIcon!);
        if (iconIndex != -1) {
          selectedCategoryIndex = i;
          selectedIconIndex = iconIndex;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Biraz bekleyerek GridView'ın oluşmasını bekle
              Future.delayed(Duration(milliseconds: 200), () {
                if (mounted) {
                  _scrollSelectedIconIntoView();
                }
              });
            }
          });

          break;
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the keys as category names
    List<String> categoryNames = emojiCategories.keys.toList();

    // Seçili kategorideki ikonlar
    final currentCategoryIcons = emojiCategories[categoryNames[selectedCategoryIndex]] ?? [];

    // İkon tuşlarını güncelle - sadece gerektiğinde
    if (_iconKeys.length != currentCategoryIcons.length) {
      _iconKeys.clear();
    }

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            CategoryWidget(
              categories: categoryNames,
              initialSelectedIndex: selectedCategoryIndex,
              onCategorySelected: (int selectedCategory) {
                if (selectedCategory == selectedCategoryIndex) return;

                controller.forward(from: 0);
                setState(() {
                  selectedCategoryIndex = selectedCategory;
                  selectedIconIndex = null;
                });

                // Kategori değiştiğinde GridView'ı başa sar
                if (_gridScrollController.hasClients) {
                  _gridScrollController.jumpTo(0);
                }

                // Yeni kategori için tuşları güncelle
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _iconKeys.clear();
                    });
                  }
                });
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: GridView.builder(
                controller: _gridScrollController,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),

                cacheExtent: 1000, // Daha fazla öğeyi önbelleğe al
                itemCount: currentCategoryIcons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final iconData = currentCategoryIcons[index];
                  final isSelected = index == selectedIconIndex;

                  // Performans için key kullanımını optimize et
                  if (!_iconKeys.containsKey(index)) {
                    _iconKeys[index] = GlobalKey();
                  }

                  return CustomButton(
                    key: _iconKeys[index],
                    onPressed: () {
                      // Eğer zaten seçiliyse, tekrar işlem yapma
                      if (selectedIconIndex == index) return;

                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedIconIndex = index;
                      });

                      widget.onIconSelected(iconData);

                      // Seçilen ikonu görünür yap - ama sadece görünür değilse
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _scrollSelectedIconIntoView();
                        }
                      });
                    },
                    child: Card(
                      elevation: .25,
                      color: isSelected ? context.primary.withAlpha(100) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            iconData,
                            textAlign: TextAlign.center,
                            style: context.titleLarge?.copyWith(fontSize: 44),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).animate(controller: controller).fadeIn(duration: 500.ms),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  top: 5,
                ),
                child: CustomEmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    // Eğer emoji zaten seçiliyse, işlem yapma
                    if (widget.selectedIcon == emoji.emoji) {
                      navigator.pop();
                      return;
                    }

                    // Yeni emojiyi Custom kategorisine ekle
                    final customEmojis = emojiCategories["Custom"] ?? [];
                    if (!customEmojis.contains(emoji.emoji)) {
                      setState(() {
                        customEmojis.add(emoji.emoji);
                        emojiCategories["Custom"] = customEmojis;
                      });
                    }

                    widget.onIconSelected(emoji.emoji);

                    // Custom kategorisini seç
                    final customCategoryIndex = emojiCategories.keys.toList().indexOf("Custom");
                    setState(() {
                      selectedCategoryIndex = customCategoryIndex;
                      // Custom kategorisindeki yeni eklenen emojinin indeksini bul
                      selectedIconIndex = customEmojis.indexOf(emoji.emoji);
                    });

                    navigator.pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
