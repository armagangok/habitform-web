import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Utility class for handling icon conversions
class CategoryIconUtil {
  /// Convert string representation to FontAwesome IconData
  static IconData getIconFromString(String iconString) {
    // Convert string to IconData based on FontAwesome icons
    switch (iconString) {
      // Standard dash format icons (from service)
      case 'paintbrush':
        return FontAwesomeIcons.paintbrush;
      case 'palette':
        return FontAwesomeIcons.palette;
      case 'moneyBill':
        return FontAwesomeIcons.moneyBill;
      case 'dumbbell':
        return FontAwesomeIcons.dumbbell;
      case 'heartPulse':
        return FontAwesomeIcons.heartPulse;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'userGroup':
        return FontAwesomeIcons.userGroup;
      case 'book':
        return FontAwesomeIcons.book;
      case 'briefcase':
        return FontAwesomeIcons.briefcase;
      case 'sun':
        return FontAwesomeIcons.sun;
      case 'house':
        return FontAwesomeIcons.house;
      case 'houseUser':
        return FontAwesomeIcons.houseUser;
      case 'moon':
        return FontAwesomeIcons.moon;
      case 'star':
        return FontAwesomeIcons.star;
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      case 'music':
        return FontAwesomeIcons.music;
      case 'camera':
        return FontAwesomeIcons.camera;
      case 'pencil-alt':
        return FontAwesomeIcons.pencil;
      case 'tree':
        return FontAwesomeIcons.tree;
      case 'coffee':
        return FontAwesomeIcons.mugSaucer;
      case 'lightbulb':
        return FontAwesomeIcons.lightbulb;
      case 'clock':
        return FontAwesomeIcons.clock;
      case 'map':
        return FontAwesomeIcons.map;
      case 'futbol':
        return FontAwesomeIcons.futbol;
      case 'hiking':
        return FontAwesomeIcons.personHiking;
      case 'paint-roller':
        return FontAwesomeIcons.paintRoller;
      case 'wallet':
        return FontAwesomeIcons.wallet;
      case 'running':
        return FontAwesomeIcons.personRunning;
      case 'heartSolid':
        return FontAwesomeIcons.solidHeart;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'comments':
        return FontAwesomeIcons.comments;
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'tasks':
        return FontAwesomeIcons.listCheck;
      case 'bed':
        return FontAwesomeIcons.bed;
      case 'headphones':
        return FontAwesomeIcons.headphones;
      case 'video':
        return FontAwesomeIcons.video;
      case 'book-open':
        return FontAwesomeIcons.bookOpen;
      case 'soccer-ball':
        return FontAwesomeIcons.futbol;
      case 'paint-brush':
        return FontAwesomeIcons.paintbrush;
      case 'camera-retro':
        return FontAwesomeIcons.cameraRetro;
      case 'fish':
        return FontAwesomeIcons.fish;
      case 'mountain':
        return FontAwesomeIcons.mountain;
      case 'snowflake':
        return FontAwesomeIcons.snowflake;
      case 'fire':
        return FontAwesomeIcons.fire;
      case 'umbrella':
        return FontAwesomeIcons.umbrella;
      case 'bicycle':
        return FontAwesomeIcons.bicycle;
      case 'guitar':
        return FontAwesomeIcons.guitar;
      case 'pizza-slice':
        return FontAwesomeIcons.pizzaSlice;
      case 'martiniGlassCitrus':
        return FontAwesomeIcons.martiniGlassCitrus;
      case 'rocket':
        return FontAwesomeIcons.rocket;
      case 'bell':
        return FontAwesomeIcons.bell;
      case 'pen-to-square':
        return FontAwesomeIcons.pen;
      case 'personRunning':
        return FontAwesomeIcons.personRunning;
      case 'heartCircleCheck':
        return FontAwesomeIcons.heartCircleCheck;
      case 'desktop':
        return FontAwesomeIcons.desktop;
      case 'code':
        return FontAwesomeIcons.code;
      case 'penToSquare':
        return FontAwesomeIcons.penToSquare;
      default:
        return FontAwesomeIcons.tag;
    }
  }

  /// Convert IconData to string representation
  static String getIconString(IconData iconData) {
    // Convert IconData to string representation using dash format
    if (iconData == FontAwesomeIcons.palette) return 'palette';
    if (iconData == FontAwesomeIcons.moneyBill) return 'money-bill';
    if (iconData == FontAwesomeIcons.dumbbell) return 'dumbbell';
    if (iconData == FontAwesomeIcons.heartPulse) return 'heart-pulse';
    if (iconData == FontAwesomeIcons.apple) return 'apple';
    if (iconData == FontAwesomeIcons.users) return 'users';
    if (iconData == FontAwesomeIcons.book) return 'book';
    if (iconData == FontAwesomeIcons.briefcase) return 'briefcase';
    if (iconData == FontAwesomeIcons.sun) return 'sun';
    if (iconData == FontAwesomeIcons.houseUser) return 'house-user';
    if (iconData == FontAwesomeIcons.moon) return 'moon';
    if (iconData == FontAwesomeIcons.star) return 'star';
    if (iconData == FontAwesomeIcons.gamepad) return 'gamepad';
    if (iconData == FontAwesomeIcons.music) return 'music';
    if (iconData == FontAwesomeIcons.paintbrush) return 'palette';
    if (iconData == FontAwesomeIcons.heart) return 'heart';
    if (iconData == FontAwesomeIcons.house) return 'house-user';
    if (iconData == FontAwesomeIcons.camera) return 'camera';
    if (iconData == FontAwesomeIcons.pencil) return 'pencil-alt';
    if (iconData == FontAwesomeIcons.tree) return 'tree';
    if (iconData == FontAwesomeIcons.mugSaucer) return 'coffee';
    if (iconData == FontAwesomeIcons.lightbulb) return 'lightbulb';
    if (iconData == FontAwesomeIcons.clock) return 'clock';
    if (iconData == FontAwesomeIcons.map) return 'map';
    if (iconData == FontAwesomeIcons.futbol) return 'futbol';
    if (iconData == FontAwesomeIcons.personHiking) return 'hiking';
    if (iconData == FontAwesomeIcons.paintRoller) return 'paint-roller';
    if (iconData == FontAwesomeIcons.wallet) return 'wallet';
    if (iconData == FontAwesomeIcons.personRunning) return 'running';
    if (iconData == FontAwesomeIcons.heart) return 'heart';
    if (iconData == FontAwesomeIcons.utensils) return 'utensils';
    if (iconData == FontAwesomeIcons.comments) return 'comments';
    if (iconData == FontAwesomeIcons.laptop) return 'laptop';
    if (iconData == FontAwesomeIcons.listCheck) return 'tasks';
    if (iconData == FontAwesomeIcons.bed) return 'bed';
    if (iconData == FontAwesomeIcons.headphones) return 'headphones';
    if (iconData == FontAwesomeIcons.video) return 'video';
    if (iconData == FontAwesomeIcons.bookOpen) return 'book-open';
    if (iconData == FontAwesomeIcons.futbol) return 'soccer-ball';
    if (iconData == FontAwesomeIcons.paintbrush) return 'paint-brush';
    if (iconData == FontAwesomeIcons.cameraRetro) return 'camera-retro';
    if (iconData == FontAwesomeIcons.fish) return 'fish';
    if (iconData == FontAwesomeIcons.mountain) return 'mountain';
    if (iconData == FontAwesomeIcons.snowflake) return 'snowflake';
    if (iconData == FontAwesomeIcons.fire) return 'fire';
    if (iconData == FontAwesomeIcons.umbrella) return 'umbrella';
    if (iconData == FontAwesomeIcons.bicycle) return 'bicycle';
    if (iconData == FontAwesomeIcons.guitar) return 'guitar';
    if (iconData == FontAwesomeIcons.pizzaSlice) return 'pizza-slice';
    if (iconData == FontAwesomeIcons.martiniGlassCitrus) return 'cocktail';
    if (iconData == FontAwesomeIcons.rocket) return 'rocket';
    if (iconData == FontAwesomeIcons.bell) return 'bell';
    if (iconData == FontAwesomeIcons.moon) return 'moon';
    if (iconData == FontAwesomeIcons.sun) return 'sun';
    if (iconData == FontAwesomeIcons.pen) return 'pen';
    return 'tag';
  }

  /// Get a list of all available icons for category selection
  static List<IconData> getIconList() {
    return [
      FontAwesomeIcons.palette, // Art
      FontAwesomeIcons.moneyBill1, // Finances
      FontAwesomeIcons.dumbbell, // Fitness
      FontAwesomeIcons.heartPulse, // Health
      FontAwesomeIcons.apple, // Nutrition
      FontAwesomeIcons.users, // Social
      FontAwesomeIcons.book, // Study
      FontAwesomeIcons.briefcase, // Work
      FontAwesomeIcons.sun, // Morning
      FontAwesomeIcons.houseUser, // Daily Life

      FontAwesomeIcons.star,
      FontAwesomeIcons.gamepad,
      FontAwesomeIcons.music,
      FontAwesomeIcons.camera, // Photography
      FontAwesomeIcons.pencil, // Writing
      FontAwesomeIcons.tree, // Nature
      FontAwesomeIcons.mugSaucer, // Relaxation
      FontAwesomeIcons.lightbulb, // Ideas
      FontAwesomeIcons.clock, // Time Management
      FontAwesomeIcons.map, // Travel
      FontAwesomeIcons.futbol, // Sports
      FontAwesomeIcons.personHiking, // Adventure
      FontAwesomeIcons.paintRoller, // Art (Painting)
      FontAwesomeIcons.wallet, // Finances (Budgeting)
      FontAwesomeIcons.personRunning, // Fitness (Running)
      FontAwesomeIcons.heart, // Health (Wellness)
      FontAwesomeIcons.utensils, // Nutrition (Food)
      FontAwesomeIcons.comments, // Social (Communication)
      FontAwesomeIcons.laptop, // Study (Online Learning)
      FontAwesomeIcons.listCheck, // Work (To-Do)
      FontAwesomeIcons.bed, // Daily Life (Rest)
      FontAwesomeIcons.headphones, // Music (Listening)
      FontAwesomeIcons.video, // Gaming (Streaming)
      FontAwesomeIcons.bookOpen, // Study (Reading)
      FontAwesomeIcons.futbol, // Sports (Soccer)
      FontAwesomeIcons.paintbrush, // Art (Brush)
      FontAwesomeIcons.cameraRetro, // Photography (Retro)
      FontAwesomeIcons.fish, // Nature (Aquatic)
      FontAwesomeIcons.mountain, // Adventure (Mountains)
      FontAwesomeIcons.snowflake, // Weather (Snow)
      FontAwesomeIcons.fire, // Nature (Fire)
      FontAwesomeIcons.umbrella, // Weather (Rain)
      FontAwesomeIcons.bicycle, // Adventure (Cycling)
      FontAwesomeIcons.guitar, // Music (Guitar)
      FontAwesomeIcons.pizzaSlice, // Food (Pizza)
      FontAwesomeIcons.martiniGlassCitrus, // Food (Cocktail)
      FontAwesomeIcons.rocket, // Adventure (Space)
      FontAwesomeIcons.bell, // Notifications
      FontAwesomeIcons.solidHeart, // Health (Heart)
      FontAwesomeIcons.sun, // Morning (Sun)
      FontAwesomeIcons.pen, // Writing (Pen)
    ];
  }
}
