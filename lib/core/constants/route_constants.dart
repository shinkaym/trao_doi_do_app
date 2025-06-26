class RouteConstants {
  RouteConstants._();

  // ========== STANDALONE ROUTES ==========
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ========== MAIN NAVIGATION ROUTES ==========
  static const String home = '/home'; // Màn hình chính
  static const String posts = '/posts';
  static const String warehouse = '/warehouse';
  static const String interests = '/interests';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // ========== NESTED ROUTES (chỉ path segment, không có parent path) ==========
  static const String postDetail = 'post-detail';
  static const String createPost = 'create-post';
  static const String itemDetail = 'item-detail';
  static const String interestChat = 'chat';
  static const String editProfile = 'edit';
  static const String changePassword = 'change-password';
  static const String myPosts = 'my-posts';
  static const String ranking = 'ranking'; // Ranking là con của profile
  static const String appointments =
      'appointments'; // Appointments là con của profile

  // ========== FULL ROUTE PATHS (để kiểm tra navigation) ==========
  static const String fullPostDetail = '/posts/post-detail';
  static const String fullCreatePost = '/posts/create-post';
  static const String fullItemDetail = '/warehouse/item-detail';
  static const String fullInterestChat = '/interests/chat';
  static const String fullEditProfile = '/profile/edit';
  static const String fullChangePassword = '/profile/change-password';
  static const String fullMyPosts = '/profile/my-posts';
  static const String fullRanking = '/profile/ranking';
  static const String fullAppointments = '/profile/appointments';

  // ========== ROUTE PARAMETERS ==========
  static const String slugParam = 'slug';
  static const String idParam = 'id';
  static const String interestIdParam = 'interestId';
  static const String appointmentIdParam = 'appointmentId';

  // ========== ROUTE BUILDERS ==========
  static String buildPostDetailRoute(String slug) => '$fullPostDetail/$slug';
  static String buildItemDetailRoute(String id) => '$fullItemDetail/$id';
  static String buildInterestChatRoute(String interestId) =>
      '$fullInterestChat/$interestId';

  // ========== ROUTE COLLECTIONS ==========
  // Tất cả các màn hình chính đều yêu cầu đăng nhập
  static const Set<String> protectedRoutes = {
    home,
    posts,
    warehouse,
    interests,
    profile,
    notifications,
    fullPostDetail,
    fullCreatePost,
    fullItemDetail,
    fullInterestChat,
    fullEditProfile,
    fullChangePassword,
    fullMyPosts,
    fullRanking,
    fullAppointments,
  };

  static const Set<String> authRoutes = {
    login,
    register,
    forgotPassword,
    resetPassword,
    onboarding,
  };

  // Routes that should hide the bottom navigation bar
  static const Set<String> routesWithoutNavBar = {
    fullPostDetail,
    fullCreatePost,
    fullItemDetail,
    fullInterestChat,
    fullEditProfile,
    fullChangePassword,
    fullMyPosts,
    fullRanking,
    fullAppointments,
    notifications,
  };

  // Navigation routes với home làm mặc định
  static const Map<String, int> navigationRoutes = {
    home: 0, // Home là tab đầu tiên
    posts: 1,
    warehouse: 2,
    interests: 3,
    profile: 4,
  };

  static const Map<String, int> subRouteMapping = {
    fullPostDetail: 1,
    fullCreatePost: 1,
    fullItemDetail: 2,
    fullInterestChat: 3,
    fullEditProfile: 4,
    fullChangePassword: 4,
    fullMyPosts: 4,
    fullRanking: 4, // Ranking thuộc profile
    fullAppointments: 4, // Appointments thuộc profile
  };
}

// ========== ROUTE NAMES ==========
/// Route names for navigation
class RouteNames {
  RouteNames._();

  // Standalone routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';

  // Main navigation routes
  static const String home = 'home';
  static const String posts = 'posts';
  static const String warehouse = 'warehouse';
  static const String interests = 'interests';
  static const String profile = 'profile';
  static const String notifications = 'notifications';

  // Nested routes
  static const String postDetail = 'post-detail';
  static const String createPost = 'create-post';
  static const String itemDetail = 'item-detail';
  static const String interestChat = 'interest-chat';
  static const String editProfile = 'edit-profile';
  static const String changePassword = 'change-password';
  static const String myPosts = 'my-posts';
  static const String ranking = 'ranking';
  static const String appointments = 'appointments';
}
