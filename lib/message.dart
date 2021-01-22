class Message{
  String messageFrom;
  String messageTo;
  String messageDate;
  String messageContent;
  Message({this.messageFrom,this.messageTo, this.messageDate,this.messageContent});
  @override
  String toString() {
    return 'messageFrom: '+this.messageFrom+'\nmessageTo: '+this.messageTo+'\nmessageDate: '+this.messageDate+'\nmessageContent: '+this.messageContent;
  }
}