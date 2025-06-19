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
  static const String posts = '/posts';
  static const String warehouse = '/warehouse';
  static const String interests = '/interests';
  static const String ranking = '/ranking';
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

  // ========== FULL ROUTE PATHS (để kiểm tra navigation) ==========
  static const String fullPostDetail = '/posts/post-detail';
  static const String fullCreatePost = '/posts/create-post';
  static const String fullItemDetail = '/warehouse/item-detail';
  static const String fullInterestChat = '/interests/chat';
  static const String fullEditProfile = '/profile/edit';
  static const String fullChangePassword = '/profile/change-password';
  static const String fullMyPosts = '/profile/my-posts';

  // ========== ROUTE PARAMETERS ==========
  static const String slugParam = 'slug';
  static const String idParam = 'id';
  static const String interestIdParam = 'interestId';

  // ========== ROUTE BUILDERS ==========
  static String buildPostDetailRoute(String slug) => '$fullPostDetail/$slug';
  static String buildItemDetailRoute(String id) => '$fullItemDetail/$id';
  static String buildInterestChatRoute(String interestId) =>
      '$fullInterestChat/$interestId';

  // ========== ROUTE COLLECTIONS ==========
  static const Set<String> protectedRoutes = {
    fullEditProfile,
    fullChangePassword,
    fullMyPosts,
    fullInterestChat,
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
  };

  static const Map<String, int> navigationRoutes = {
    posts: 0,
    warehouse: 1,
    interests: 2,
    ranking: 3,
    profile: 4,
  };

  static const Map<String, int> subRouteMapping = {
    fullPostDetail: 0,
    fullCreatePost: 0,
    fullItemDetail: 1,
    fullInterestChat: 2,
    fullEditProfile: 4,
    fullChangePassword: 4,
    fullMyPosts: 4,
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
  static const String posts = 'posts';
  static const String warehouse = 'warehouse';
  static const String interests = 'interests';
  static const String ranking = 'ranking';
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
}
