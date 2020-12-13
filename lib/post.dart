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
  String postDate;
  int postLikes;
  int postDislikes;
  Map<String, String> postComments; //yorum ve yorum yapanin usernamei
  bool userLikedIt;
  bool userDislikedIt;

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
      this.postComments,
      this.userLikedIt,
      this.userDislikedIt});

  Future<bool> like(String currentUserName) async {
    //currentUserName likes the post this.postID
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " likes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName);
      this.userDislikedIt = false;
      this.userLikedIt = true;
      return true;
    } else {
      bool value= await Requests().like(postID);
      return value;
    }
  }

  Future<bool> dislike(String currentUserName) async{
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " dislikes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName);
      this.userDislikedIt = false;
      this.userLikedIt = true;
      return true;
    } else {
      bool value= await Requests().dislike(postID);
      return value;
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
      String postDate,
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
