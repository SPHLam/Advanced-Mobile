import 'dart:io';

class AdHelper{
    static String get interstitialAdUnitId{
        if(Platform.isAndroid){
            return 'ca-app-pub-3940256099942544/1033173712';
        }else if(Platform.isIOS){
            return 'ca-app-pub-3940256099942544/2934735716';
        }else{
            throw new UnsupportedError('Unsupported platform');
        }
    }
}

