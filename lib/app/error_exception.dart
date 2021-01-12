class Errors {
  static String showError(String errorCode){
    switch(errorCode){
      case 'emaıl-already-ın-use' :
        return "Bu mail adresi zaten kullanımda lütfen farklı bir adres deneyin";
      case 'user-not-found' :
        return "Böyle bir kullanıcı bulunmamaktadır";
      case 'wrong-password'  :
        return "Parola Yanlış";
      default :
        return "Bir hata oluştu";
    }
  }
}