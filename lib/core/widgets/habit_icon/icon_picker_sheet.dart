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
        '🧴', // lotion
        '🪒', // shaving
        '💇🏻‍♂️', // haircut
        '💇🏻‍♀️', // hair care
        '💆🏻‍♂️', // face care
        '💆🏻‍♀️', // spa

        // Food and Drink
        '☕️', // coffee
        '🍳', // cooking
        '🥄', // spoon
        '🍽️', // plate and cutlery
        '🥤', // drink
        '🥛', // milk
        '🍞', // bread
        '🥚', // egg
        '🥗', // salad
        '🥪', // sandwich

        // Sports and Movement
        '🏃🏻', // running
        '🚶🏻', // walking
        '🧘🏻‍♂️', // meditation
        '🧘🏻‍♀️', // yoga
        '🏋🏻‍♂️', // weight lifting
        '🏋🏻‍♀️', // fitness

        // Work and Reading
        '💻', // computer
        '📱', // phone
        '📚', // book
        '✍🏻', // writing
        '📝', // note taking

        // Household Chores
        '🧹', // sweeping
        '🧺', // laundry
        '🧼', // cleaning
        '👕', // clothing
        '👖', // pants
        '🧦', // socks

        // Transportation
        '🚗', // car
        '🚌', // bus
        '🚶🏻‍♂️', // walking
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
      ],
      LocaleKeys.iconCategories_sports.tr(): [
        // Walking and Running
        '🏃🏻‍♂️', // running (male)
        '🏃🏻‍♀️', // running (female)
        '🚶🏻‍♂️', // walking (male)
        '🚶🏻‍♀️', // walking (female)
        '🏃🏻', // running (neutral)

        // Fitness and Strength Sports
        '🏋🏻‍♂️', // weight lifting (male)
        '🏋🏻‍♀️', // weight lifting (female)
        '🤸🏻‍♂️', // gymnastics
        '🤸🏻‍♀️', // gymnastics
        '🧘🏻‍♂️', // yoga (male)
        '🧘🏻‍♀️', // yoga (female)

        // Team Sports
        '⚽', // soccer
        '🏀', // basketball
        '🏈', // american football
        '⚾', // baseball
        '🏐', // volleyball
        '🏉', // rugby

        // Racket Sports
        '🎾', // tennis
        '🏸', // badminton
        '🏓', // table tennis

        // Water Sports
        '🏊🏻‍♂️', // swimming (male)
        '🏊🏻‍♀️', // swimming (female)
        '🚣🏻‍♂️', // rowing
        '🏄🏻‍♂️', // surfing (male)
        '🏄🏻‍♀️', // surfing (female)

        // Cycling
        '🚴🏻‍♂️', // cycling (male)
        '🚴🏻‍♀️', // cycling (female)
        '🚴🏻‍♂️', // mountain biking

        // Winter Sports
        '🏂🏻', // snowboarding
        '⛷️', // skiing
        '🎿', // ski equipment

        // Martial Arts
        '🥋', // martial arts
        '🥊', // boxing

        // Other Sports
        '🏇', // horse riding
        '⛳', // golf
        '🎯', // darts
        '🤺', // fencing
        '⛸️', // ice skating
        '🛹', // skateboarding

        // Sports Equipment
        '🥅', // goal net
        '🥎', // softball
        '🥏', // frisbee
        '⚾', // baseball
      ],

      LocaleKeys.iconCategories_health.tr(): [
        // Heart and Health
        '❤️', // heart
        '🫀', // anatomical heart
        '💝', // healthy heart

        // Medical Symbols
        '⚕️', // medical symbol
        '🏥', // hospital
        '💊', // medicine
        '💉', // syringe

        // Healthcare Professionals
        '👨🏻‍⚕️', // doctor (male)
        '👩🏻‍⚕️', // doctor (female)
        '🧑🏻‍⚕️', // healthcare worker

        // Medical Equipment
        '🩺', // stethoscope
        '🌡️', // thermometer
        '🩻', // x-ray
        '🔬', // microscope

        // First Aid
        '🚑', // ambulance
        '🩹', // bandage
        '⛑️', // first aid

        // Healthy Living
        '💪🏻', // strength
        '🧘🏻', // meditation
        '🥗', // healthy food
        '💧', // water
      ],

      LocaleKeys.iconCategories_social.tr(): [
        // Communication
        '💬', // speech bubble
        '📱', // phone
        '📞', // telephone
        '📧', // email

        // Social Interaction
        '👥', // people
        '🤝', // handshake
        '🫂', // hugging
        '👋', // waving

        // Social Media
        '🌐', // world
        '📲', // messaging
        '💌', // message
        '🔔', // notification

        // Meetings and Collaboration
        '🗣️', // speaking
        '📢', // announcement
        '🤼', // meeting
        '🔗', // link

        // Social Activities
        '🎉', // celebration
        '🎊', // party
        '🎭', // event
        '⭐', // star
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

        // Plants
        '🌱', // seedling
        '🌿', // leaf
        '🌳', // tree
        '🌸', // flower
        '🌺', // hibiscus
        '🌻', // sunflower
        '🍀', // clover

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

        // Natural Formations
        '🏔️', // mountain
        '🌋', // volcano
        '🏖️', // beach
        '🌊', // wave
        '⛰️', // mountains
        '🏞️', // landscape
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
        '💻', // laptop
        '⌨️', // keyboard
        '🖥️', // desktop computer
        '📱', // mobile phone

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
        '📌', // pushpin
        '📍', // round pushpin
        '📎', // paperclip
        '🔗', // link
        '✅', // check mark
        '☑️', // check box
        '✔️', // heavy check mark

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
      ],

      LocaleKeys.iconCategories_science.tr(): [
        // Laboratory
        '🧪', // test tube
        '🔬', // microscope
        '⚗️', // distillation
        '🧫', // petri dish

        // Scientists
        '👨🏻‍🔬', // scientist (male)
        '👩🏻‍🔬', // scientist (female)
        '🧑🏻‍🔬', // researcher

        // Medicine and Biology
        '🧬', // DNA
        '🦠', // microbe
        '🫀', // heart
        '🧠', // brain

        // Space
        '🔭', // telescope
        '🌌', // galaxy
        '🪐', // planet
        '🌍', // earth

        // Measurement and Analysis
        '📊', // graph
        '📐', // triangle ruler
        '🌡️', // thermometer
        '⚖️', // scale
      ],

      LocaleKeys.iconCategories_gardenandyard.tr(): [
        // Plants
        '🌱', // seedling
        '🌳', // tree
        '🌺', // flower
        '🌸', // blooming

        // Garden Tools
        '🪴', // potted plant
        '🌿', // herb
        '🪴', // plant in pot
        '💐', // bouquet

        // Gardeners
        '👨🏻‍🌾', // gardener (male)
        '👩🏻‍🌾', // gardener (female)
        '🧑🏻‍🌾', // farmer

        // Garden Elements
        '⛲', // fountain
        '🏺', // vase
        '🪨', // rock
        '🌳', // landscaping
      ],

      LocaleKeys.iconCategories_pets.tr(): [
        // Dogs
        '🐕', // dog
        '🐶', // dog face
        '🦮', // guide dog
        '🐕‍🦺', // service dog

        // Cats
        '🐈', // cat
        '🐱', // cat face
        '🐈‍⬛', // black cat

        // Small Pets
        '🐹', // hamster
        '🐰', // rabbit
        '🐢', // turtle
        '🦜', // parrot

        // Fish
        '🐠', // tropical fish
        '🐟', // fish
        '🐡', // blowfish

        // Pet Care
        '🦴', // bone
        '🐾', // paw prints
        '🪮', // food bowl
        '🧶', // play string
      ],
      "Custom": [], // Custom emojis will be loaded from EmojiPicker
    };

    // Eğer seçili icon Custom kategorisindeyse listeye ekle
    if (widget.selectedIcon != null && !emojiCategories.values.any((list) => list.contains(widget.selectedIcon))) {
      emojiCategories["Custom"]!.add(widget.selectedIcon!);
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
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the keys as category names
    List<String> categoryNames = emojiCategories.keys.toList();

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
                controller.forward(from: 0);
                selectedIconIndex = null;
                setState(() {
                  selectedCategoryIndex = selectedCategory;
                });
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: emojiCategories[categoryNames[selectedCategoryIndex]]!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final iconData = emojiCategories[categoryNames[selectedCategoryIndex]]![index];

                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        selectedIconIndex = index;
                      });

                      widget.onIconSelected(iconData);
                    },
                    child: Card(
                      elevation: .25,
                      color: index == selectedIconIndex ? context.primary.withAlpha(100) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              iconData,
                              textAlign: TextAlign.center,
                              style: context.titleLarge?.copyWith(fontSize: 40),
                            ),
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
