import 'package:elibraryapp/config/base_url.dart';

class ApiConfig {
  static String get baseUrl => '${BaseURL.base}/api';

  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String verifyAccount = '/verify/account';
  static const String signout = '/signout';
  static const String tokenRefresh = '/token/refresh';
  static const String items = '/items';
  static const String categories = '/categories';
  static const String searchBooks = '/search/books';
  static const String pdfProgress = '/pdf-progress';
  static const String pdfProgressList = '/pdf-progress/pdf-progress-list';
  static const String pdfCommentHighlights = '/pdf-comment-highlights';
  static const String chats = '/chats';
  static const String userProfile = '/users/profile';

  static String item(int id) => '/items/$id';
  static String favorite(int bookId) => '/books/$bookId/favorite';
  static String favoriteCheck(int bookId) => '/books/$bookId/favorite/check';
  static String chatMessages(int chatId) => '/chats/$chatId/messages';

  // Home page
  static const String homeRecommended = '/home/recommended';
  static const String homePopular = '/home/popular';
  static const String homeContinueReading = '/home/continue-reading';

  // Recommended overall books (from UserController)
  static const String recommendedOverall = '/users/recommended-overall-books';

  // Profile & Password
  static const String passwordChange = '/password/change';
  static const String passwordCreate = '/password/create';
  static const String updatePhoto = '/update/photo';
  static const String updateAbout = '/users/about';

  static const String userFavorites = '/users/favorites';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const String notificationReadAll = '/notifications/read-all';
  static const String notificationClearAll = '/notifications/clear-all';
}
