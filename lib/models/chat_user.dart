class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.isOnline,
    required this.lastActive,
    required this.id,
    required this.createAt,
    required this.email,
    required this.pushToken,
  });
  late final String image;
  late final String name;
  late final String about;
  late final bool isOnline;
  late final String lastActive;
  late final String id;
  late final String createAt;
  late final String email;
  late final String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    about = json['about'];
    isOnline = json['is_online'];
    lastActive = json['last_active'];
    id = json['id'];
    createAt = json['create_at'];
    email = json['email'];
    pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['create_at'] = createAt;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
