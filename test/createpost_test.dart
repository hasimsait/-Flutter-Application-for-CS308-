import 'package:flutter_test/flutter_test.dart';
import 'package:teamone_social_media/create_post.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
class MockClient extends Mock implements http.Client {}


  void main() {
    testWidgets('CreatePost creates text posts', (WidgetTester tester) async {
      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(CreatePost());//->throws the error below bc. its part of an app therefore requires context, like every route. I was going to use mockito and drag etc but ITS 4AM
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      //The following assertion was thrown building CreatePost(state: _CreatePostState#9b020):
      // MediaQuery.of() called with a context that does not contain a MediaQuery.
      // No MediaQuery ancestor could be found starting from the context that was passed to MediaQuery.of().
      // This can happen because you do not have a WidgetsApp or MaterialApp widget (those widgets introduce
      // a MediaQuery), or it can happen if the context you use comes from a widget above those widgets.
      //EVERYTHING (ALMOST) IS A MATERIAL APP IN FLUTTER. THESE GUYS ARE ON CRACK IF THEY THINK THAT THIS SHIT IS USABLE



      // Enter 'hi' into the TextField.
      //await tester.enterText(find.byType(TextField), 'hi');

      //await tester.pump();
    });
  }
