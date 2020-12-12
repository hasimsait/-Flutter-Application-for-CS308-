import 'helper/constants.dart';
import 'helper/requests.dart';

class Post {
  String text;
  String image;
  String topic;
  String videoURL;
  String placeName;
  String placeGeoID;
  //ABOVE ARE WHAT YOU SEND TO CREATE A POST

  //Below apply to posts received from feed etc.
  int postID; //dart integers == java longs
  String postOwnerName;
  DateTime postDate;
  int postLikes;
  int postDislikes;
  Map<String, String> postComments; //yorum ve yorum yapanin usernamei

  Post(
      {this.text,
      this.image,
      this.topic,
      this.videoURL,
      this.placeName,
      this.placeGeoID,
      this.postID,
      this.postOwnerName,
      this.postDate,
      this.postLikes,
      this.postDislikes,
      this.postComments});

  like(String currentUserName) {
    //currentUserName likes the post this.postID
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " likes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName);
      return true;
    } else {
      Requests().like(postID).then((value) {return value;});
    }
  }

  dislike(String currentUserName) {
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " dislikes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName);
      return true;
    } else {
      Requests().dislike(postID).then((value) {return value;});
    }
  }

  Post from(
      {String text,
      String image,
      String topic,
      String videoURL,
      String placeName,
      String placeGeoID,
      int postID,
      String postOwnerName,
      DateTime postDate,
      int postLikes,
      int postDislikes,
      Map<String, String> postComments}) {
    return Post(
        text: text ?? this.text,
        image: image ?? this.image,
        topic: topic ?? this.topic,
        videoURL: videoURL ?? this.videoURL,
        placeName: placeName ?? this.placeName,
        placeGeoID: placeGeoID ?? this.placeGeoID,
        postID: postID ?? this.postID,
        postOwnerName: postOwnerName ?? this.postOwnerName,
        postDate: postDate ?? this.postDate,
        postLikes: postLikes ?? this.postLikes,
        postDislikes: postDislikes ?? this.postDislikes,
        postComments: postComments ?? this.postComments);
  }
}
