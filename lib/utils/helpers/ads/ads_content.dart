// BannerAd? _bannerAd;
// if (_bannerAd != null)
// Align(
// alignment: Alignment.topCenter,
// child: Container(
// width: _bannerAd!.size.width.toDouble(),
// height: _bannerAd!.size.height.toDouble(),
// child: AdWidget(ad: _bannerAd!),
// ),
// ),
// BannerAd(
//   //adUnitId: AdsHelper.getBannerAdUnitId(),
//   adUnitId: 'ca-app-pub-3940256099942544/6300978111',
//   size: AdSize.banner,
//   request: AdRequest(),
//   listener: BannerAdListener(
//     onAdLoaded: (Ad ad) {
//       setState(() {
//         _bannerAd = ad as BannerAd;
//       });
//     },
//     onAdFailedToLoad: (Ad ad, LoadAdError error) {
//       print('Ad failed to load: $error');
//       ad.dispose();
//     },
//   ),
// )..load();