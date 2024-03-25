//
enum Type { text, image }

class MessageModel {
  String? toId;
  String? msg;
  String? read;
  String? send;
  String? fromId;
  Type? type;

  MessageModel(
      {this.toId, this.msg, this.read, this.send, this.fromId, this.type});

  MessageModel.fromJson(Map<String, dynamic> json) {
    toId = json['toId'];
    msg = json['msg'];
    read = json['read'];
    //Type.image.name?Type.image:Type.text is it true it's a image otherwise it's a text
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    send = json['send'];
    fromId = json['fromId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['toId'] = this.toId;
    data['msg'] = this.msg;
    data['read'] = this.read;
    data['type'] =
        this.type?.toString().split('.').last; // Convert enum to string
    data['send'] = this.send;
    data['fromId'] = this.fromId;
    return data;
  }
}
