import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class WeatherWidget extends StatefulWidget {
  final Size size;
  final String weather;
  final SunConfig sunConfig;
  final RainConfig rainConfig;
  final SnowConfig snowConfig;
  final CloudConfig cloudConfig;
  final ThunderConfig thunderConfig;

  WeatherWidget(
      {@required this.weather,
      @required this.size,
      this.sunConfig,
      this.rainConfig,
      this.snowConfig,
      this.cloudConfig,
      this.thunderConfig});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    switch (weather) {
      case 'Sunny':
        return SunWidgetState();
        break;
      case 'Cloudy':
        return CloudWidgetState();
        break;
      case 'Rainy':
        return RainWidgetState();
        break;
      case 'Snowy':
        return SnowWidgetState();
        break;
      case 'Thunder':
        return ThunderWidgetState();
        break;
    }
    return SunWidgetState();
  }
}

/*SunWidget*/

class SunConfig {
  final double sunWidth, sunBlurSigma;
  final Color sunOutColor, sunMidColor, sunInColor, bottomColor, topColor;
  final BlurStyle sunBlurStyle;
  int sunOutMill, sunMidMill;

  SunConfig({
    this.sunBlurStyle,
    this.sunBlurSigma,
    this.sunInColor,
    this.sunMidColor,
    this.sunOutColor,
    this.sunWidth,
    this.bottomColor,
    this.topColor,
    this.sunOutMill,
    this.sunMidMill,
  });
}

class SunWidgetState extends State<WeatherWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Stack(
        children: _buildPaints(),
      ),
    );
  }

  AnimationController outController, inController;
  Animation<double> outAnimation, inAnimation;
  double sunWidth;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  _initAnimation() {
    sunWidth =
        widget.sunConfig.sunWidth == null ? 360 : widget.sunConfig.sunWidth;
    outController = new AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.sunConfig.sunOutMill == null
                ? 1500
                : widget.sunConfig.sunOutMill));
    inController = new AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.sunConfig.sunMidMill == null
                ? 1500
                : widget.sunConfig.sunMidMill));
    outAnimation = Tween(begin: sunWidth * 2 / 9, end: sunWidth * 2.5 / 9)
        .animate(CurvedAnimation(
            parent: outController, curve: Curves.fastOutSlowIn));
    inAnimation = Tween(begin: sunWidth * 2 / 9, end: sunWidth * 1 / 3).animate(
        CurvedAnimation(parent: inController, curve: Curves.fastOutSlowIn));
    outController.repeat(reverse: true);
    inController.repeat(reverse: true);
  }

  _buildPaints() {
    List<Widget> paints = [];
    Color bottom = widget.sunConfig.bottomColor == null
        ? Colors.deepOrangeAccent[100]
        : widget.sunConfig.bottomColor;
    Color top = widget.sunConfig.topColor == null
        ? Colors.yellow
        : widget.sunConfig.topColor;
    paints.add(BackgroundWidget(colors: [bottom, top]));

    Color inside = widget.sunConfig.sunInColor == null
        ? Colors.orange
        : widget.sunConfig.sunInColor;
    Color middle = widget.sunConfig.sunMidColor == null
        ? Colors.yellow[400]
        : widget.sunConfig.sunMidColor;
    Color outside = widget.sunConfig.sunOutColor == null
        ? Colors.orange[400]
        : widget.sunConfig.sunOutColor;

    for (int i = 0; i < 3; i++) {
      Color color;
      double radius;

      switch (i) {
        case 0:
          color = inside;
          break;
        case 1:
          color = middle;
          break;
        case 2:
          color = outside;
          break;
      }

      if (i == 2) {
        radius = sunWidth * (1 / 2);
      } else {
        radius = sunWidth * ((2.7 - (-i + 1) * 1.5) / 7);
      }

      paints.add(Container(
        child: CustomPaint(
          painter: SunPainter(
              color: color,
              radius: radius,
              width: sunWidth * (2 / 9),
              repaintListener: i == 0
                  ? null
                  : i == 1
                      ? inController
                      : outController,
              animationWidth: i == 0
                  ? null
                  : i == 1
                      ? inAnimation
                      : outAnimation,
              blurStyle: widget.sunConfig.sunBlurStyle == null
                  ? BlurStyle.solid
                  : widget.sunConfig.sunBlurStyle,
              blurSigma: widget.sunConfig.sunBlurSigma == null
                  ? 13
                  : widget.sunConfig.sunBlurSigma,
              useCenter: i == 0 ? true : false),
          size: widget.size,
        ),
      ));
    }
    return paints;
  }

  @override
  void dispose() {
    outController.dispose();
    inController.dispose();
    super.dispose();
  }
}

class SunPainter extends CustomPainter {
  bool useCenter = false;
  Color color;
  double radius;
  double width;
  Animation<double> animationWidth;
  BlurStyle blurStyle;
  double blurSigma;
  Paint _paint = Paint();

  SunPainter({
    this.useCenter,
    Listenable repaintListener,
    @required this.color,
    @required this.radius,
    @required this.width,
    this.animationWidth,
    @required this.blurStyle,
    @required this.blurSigma,
  }) : super(repaint: repaintListener);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    _paint.color = color;
    _paint.style = PaintingStyle.stroke;
    _paint.maskFilter = MaskFilter.blur(blurStyle, blurSigma);
    if (animationWidth != null) {
      _paint.strokeWidth = animationWidth.value;
    } else {
      _paint.strokeWidth = width;
    }
    canvas.drawArc(rect, 0, pi / 2, useCenter, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

/*CloudWidget*/

class CloudConfig {
  final Color bottomColor, topColor, cloudColor;
  final bool showCloud;

  CloudConfig({
    this.bottomColor,
    this.topColor,
    this.cloudColor,
    this.showCloud,
  });
}

class CloudWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.grey,
      child: Stack(
        children: _buildPaints(),
      ),
    );
  }

  _buildPaints() {
    List<Widget> _paints = [];
    Color bottom = widget.cloudConfig.bottomColor == null
        ? Colors.white30
        : widget.cloudConfig.bottomColor;
    Color top = widget.cloudConfig.topColor == null
        ? Colors.blue[800]
        : widget.cloudConfig.topColor;
    Color cloudColor = widget.cloudConfig.cloudColor == null
        ? Colors.white70
        : widget.cloudConfig.cloudColor;

    _paints.add(BackgroundWidget(colors: [bottom, top]));

    if (widget.cloudConfig.showCloud == null
        ? false
        : !widget.cloudConfig.showCloud) {
      return _paints;
    }

    _paints.add(CloudWidget(color: cloudColor));

    return _paints;
  }
}

class CloudWidget extends StatefulWidget {
  final Color color;

  CloudWidget({this.color});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleCloudState();
  }
}

class SingleCloudState extends State<CloudWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            child: SlideTransition(
              position: outSlideAnimation,
              child: ScaleTransition(
                scale: outAnimation,
                child: new Icon(
                  Icons.cloud,
                  color: widget.color == null ? Colors.white70 : widget.color,
                  size: 250,
                ),
              ),
            )),
        Container(
            margin: EdgeInsets.only(top: 150),
            transform: Matrix4.rotationX(0.6),
            child: SlideTransition(
              position: inSlideAnimation,
              child: ScaleTransition(
                scale: inAnimation,
                child: new Icon(
                  Icons.cloud,
                  color: widget.color == null ? Colors.white70 : widget.color,
                  size: 160,
                ),
              ),
            ))
      ],
    );
  }

  AnimationController outController, inController;
  Animation outAnimation, inAnimation, outSlideAnimation, inSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  _initAnimation() {
    outController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    inController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    outAnimation = Tween(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: outController, curve: Curves.fastOutSlowIn));
    inAnimation = Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: inController, curve: Curves.fastOutSlowIn));
    outSlideAnimation = Tween(begin: Offset.zero, end: Offset(0.05, 0)).animate(
        CurvedAnimation(parent: outController, curve: Curves.fastOutSlowIn));
    inSlideAnimation = Tween(begin: Offset(0.8, 0), end: Offset(0.9, 0))
        .animate(
            CurvedAnimation(parent: inController, curve: Curves.fastOutSlowIn));
    outController.repeat(reverse: true);
    inController.repeat(reverse: true);
  }

  @override
  void dispose() {
    outController.dispose();
    inController.dispose();
    super.dispose();
  }
}

/*RainWidget*/

class RainConfig {
  final int rainNum;
  final String rainSingleCloud;
  final Curve rainCurve;
  final Color rainColor, bottomColor, topColor;
  final double rainLength, rainWidth, rainRangeYEnd;
  final int durationRangeStartMill, durationRangeEndMill;

  RainConfig({
    this.rainNum,
    this.rainSingleCloud,
    this.rainCurve,
    this.rainColor,
    this.bottomColor,
    this.topColor,
    this.rainRangeYEnd,
    this.durationRangeStartMill,
    this.durationRangeEndMill,
    this.rainLength,
    this.rainWidth,
  });
}

class RainWidgetState extends State<WeatherWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[300],
      child: Stack(
        children: _buildPaints(),
      ),
    );
  }

  AnimationController outController, inController;
  Animation outSlideAnimation, inSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  _initAnimation() {
    outController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    inController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    outSlideAnimation = Tween(begin: Offset.zero, end: Offset(0.05, 0)).animate(
        CurvedAnimation(parent: outController, curve: Curves.fastOutSlowIn));
    inSlideAnimation = Tween(begin: Offset(0.8, 0), end: Offset(0.9, 0))
        .animate(
            CurvedAnimation(parent: inController, curve: Curves.fastOutSlowIn));
    outController.repeat(reverse: true);
    inController.repeat(reverse: true);
  }

  _buildPaints() {
    Color bottom = widget.rainConfig.bottomColor == null
        ? Colors.white30
        : widget.rainConfig.bottomColor;
    Color top = widget.rainConfig.topColor == null
        ? Colors.blueGrey[600]
        : widget.rainConfig.topColor;
    List<Widget> _paints = [];
    //addBackground
    _paints.add(BackgroundWidget(colors: [bottom, top]));

    //addCloud
    _paints.add(CloudWidget(color: Color(0xB3D6D6D6)));

    int rainNumControl =
        widget.rainConfig.rainNum == null ? 10 : widget.rainConfig.rainNum;
    int outNumControl, inNumControl;

    switch (widget.rainConfig.rainSingleCloud) {
      case 'out':
        outNumControl = rainNumControl;
        inNumControl = 0;
        break;
      case 'in':
        outNumControl = 0;
        inNumControl = rainNumControl;
        break;
      default:
        outNumControl = rainNumControl ~/ 2;
        inNumControl = rainNumControl ~/ 2;
        break;
    }

    //addRain
    for (int i = 0; i < outNumControl / 2; i++) {
      _paints.add(Container(
          child: SlideTransition(
        position: outSlideAnimation,
        child: RainWidget(
          rainRangeXStart: 55,
          rainRangeXEnd: 215,
          rainRangeYStart: 215,
          rainRangeYEnd: widget.rainConfig.rainRangeYEnd,
          durationRangeStartMill: widget.rainConfig.durationRangeStartMill,
          durationRangeEndMill: widget.rainConfig.durationRangeEndMill,
          rainCurve: widget.rainConfig.rainCurve,
          rainColor: widget.rainConfig.rainColor,
          rainLength: widget.rainConfig.rainLength,
          rainWidth: widget.rainConfig.rainWidth,
        ),
      )));
    }

    for (int i = 0; i < inNumControl / 2; i++) {
      _paints.add(Container(
          child: SlideTransition(
        position: outSlideAnimation,
        child: RainWidget(
          rainRangeXStart: 170,
          rainRangeXEnd: 275,
          rainRangeYStart: 240,
          rainRangeYEnd: widget.rainConfig.rainRangeYEnd,
          durationRangeStartMill: widget.rainConfig.durationRangeStartMill,
          durationRangeEndMill: widget.rainConfig.durationRangeEndMill,
          rainCurve: widget.rainConfig.rainCurve,
          rainColor: widget.rainConfig.rainColor,
          rainLength: widget.rainConfig.rainLength,
          rainWidth: widget.rainConfig.rainWidth,
        ),
      )));
    }

    return _paints;
  }

  @override
  void dispose() {
    inController.dispose();
    outController.dispose();
    super.dispose();
  }
}

class RainWidget extends StatefulWidget {
  final double rainLength, rainWidth, rainRangeYStart, rainRangeYEnd;
  final int durationRangeStartMill,
      durationRangeEndMill,
      rainRangeXStart,
      rainRangeXEnd;
  final Color rainColor;
  final Curve rainCurve;

  RainWidget(
      {@required this.rainRangeXStart,
      @required this.rainRangeXEnd,
      @required this.rainRangeYStart,
      @required this.rainRangeYEnd,
      @required this.durationRangeStartMill,
      @required this.durationRangeEndMill,
      this.rainLength,
      this.rainWidth,
      this.rainColor,
      this.rainCurve});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleRainState();
  }
}

class SingleRainState extends State<RainWidget> with TickerProviderStateMixin {
  double randomRainX, yStart, yEnd;
  AnimationController rainController, fadeController;
  Animation rainAnimation, fadeAnimation;
  int randomRainDuration, xStart, xEnd, startMill, endMill;

  @override
  Widget build(BuildContext context) {
    double length = widget.rainLength == null ? 16 : widget.rainLength;
    double width = widget.rainWidth == null ? 5 : widget.rainWidth;
    // TODO: implement build
    return Container(
        child: FadeTransition(
      opacity: fadeAnimation,
      child: CustomPaint(
        painter: RainPainter(
          dx: randomRainX,
          dy: rainAnimation,
          color:
              widget.rainColor == null ? Color(0x9978909C) : widget.rainColor,
          rainLength: length,
          rainWidth: width,
        ),
        size: Size(width, length),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    xStart = widget.rainRangeXStart == null ? 55 : widget.rainRangeXStart;
    xEnd = widget.rainRangeXEnd == null ? 215 : widget.rainRangeXEnd;
    yStart = widget.rainRangeYStart == null ? 215 : widget.rainRangeYStart;
    yEnd = widget.rainRangeYEnd == null ? 620 : widget.rainRangeYEnd;
    startMill = widget.durationRangeStartMill == null
        ? 500
        : widget.durationRangeStartMill;
    endMill = widget.durationRangeEndMill == null
        ? 2500
        : widget.durationRangeEndMill;
    randomRainX = _randomRain(poolStart: xStart, poolEnd: xEnd).toDouble();
    randomRainDuration = _randomRain(poolStart: startMill, poolEnd: endMill);
    rainController = AnimationController(
        vsync: this, duration: Duration(milliseconds: randomRainDuration));
    fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: randomRainDuration));
    rainAnimation = Tween(begin: yStart, end: yEnd).animate(
        CurvedAnimation(parent: rainController, curve: Curves.easeInQuad));
    fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: rainController,
        curve:
            widget.rainCurve == null ? Curves.easeInExpo : widget.rainCurve));
    rainAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          randomRainX =
              _randomRain(poolStart: xStart, poolEnd: xEnd).toDouble();
        });
        randomRainDuration =
            _randomRain(poolStart: startMill, poolEnd: endMill);
        rainController.duration = Duration(milliseconds: randomRainDuration);
        fadeController.duration = Duration(milliseconds: randomRainDuration);
        rainAnimation = Tween(begin: yStart, end: yEnd).animate(
            CurvedAnimation(parent: rainController, curve: Curves.easeInQuad));
        rainController.reset();
        fadeController.reset();
        rainController.forward();
        fadeController.forward();
      }
    });
    rainController.forward();
  }

  int _randomRain({int poolStart, int poolEnd}) {
    Random random = Random();
    return random.nextInt(poolEnd - poolStart + 1) + poolStart;
  }

  @override
  void dispose() {
    rainController.dispose();
    fadeController.dispose();
    super.dispose();
  }
}

class RainPainter extends CustomPainter {
  Paint _paint = Paint();

  Animation<double> dy;
  double dx, rainLength;
  double rainWidth;
  Color color;

  RainPainter({
    @required this.dx,
    @required this.dy,
    @required this.rainLength,
    @required this.rainWidth,
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(dx, dy.value);
    path.lineTo(dx, dy.value + rainLength);

    _paint.color = color;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = rainWidth;
    canvas.drawPath(path, _paint);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

/*SnowWidget*/

class SnowConfig {
  final int snowNum,
      snowAreaXStart,
      snowAreaXEnd,
      snowWaveRangeMin,
      snowWaveRangeMax,
      snowFallSecMin,
      snowFallSecMax,
      snowWaveSecMin,
      snowWaveSecMax;
  final Color snowColor;
  final Curve waveCurve, fadeCurve;
  final double snowSize, snowAreaYStart, snowAreaYEnd;

  SnowConfig(
      {@required this.snowNum,
      this.snowSize,
      this.snowAreaXStart,
      this.snowAreaXEnd,
      this.snowWaveRangeMin,
      this.snowWaveRangeMax,
      this.snowFallSecMin,
      this.snowFallSecMax,
      this.snowWaveSecMin,
      this.snowWaveSecMax,
      this.snowAreaYStart,
      this.snowAreaYEnd,
      this.snowColor,
      this.fadeCurve,
      this.waveCurve});
}

class SnowWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.grey,
      child: Stack(
        children: _buildPaints(),
      ),
    );
  }

  _buildPaints() {
    List<Widget> _paints = [];
    //addBackground
    _paints.add(BackgroundWidget(colors: [Colors.white30, Colors.blue[800]]));
    //addOutCloud
    _paints.add(CloudWidget());

    for (int i = 0; i < widget.snowConfig.snowNum; i++) {
      _paints.add(SnowWidget(
        snowAreaXEnd: widget.snowConfig.snowAreaXEnd,
        snowAreaXStart: widget.snowConfig.snowAreaXStart,
        snowAreaYEnd: widget.snowConfig.snowAreaYEnd,
        snowAreaYStart: widget.snowConfig.snowAreaYStart,
        snowColor: widget.snowConfig.snowColor,
        snowSize: widget.snowConfig.snowSize,
        snowFallSecMax: widget.snowConfig.snowFallSecMax,
        snowFallSecMin: widget.snowConfig.snowFallSecMin,
        snowWaveRangeMax: widget.snowConfig.snowWaveRangeMax,
        snowWaveRangeMin: widget.snowConfig.snowWaveRangeMin,
        snowWaveSecMax: widget.snowConfig.snowWaveSecMax,
        snowWaveSecMin: widget.snowConfig.snowWaveSecMin,
        fadeCurve: widget.snowConfig.fadeCurve,
        waveCurve: widget.snowConfig.waveCurve,
      ));
    }

    return _paints;
  }
}

class SnowWidget extends StatefulWidget {
  final int snowAreaXStart,
      snowAreaXEnd,
      snowWaveRangeMin,
      snowWaveRangeMax,
      snowFallSecMin,
      snowFallSecMax,
      snowWaveSecMin,
      snowWaveSecMax;
  final Color snowColor;
  final Curve waveCurve, fadeCurve;
  final double snowSize, snowAreaYStart, snowAreaYEnd;

  SnowWidget(
      {this.snowAreaXStart,
      this.snowAreaXEnd,
      this.snowWaveRangeMin,
      this.snowWaveRangeMax,
      this.snowFallSecMin,
      this.snowFallSecMax,
      this.snowWaveSecMin,
      this.snowWaveSecMax,
      this.snowSize,
      this.snowColor,
      this.snowAreaYStart,
      this.snowAreaYEnd,
      this.waveCurve,
      this.fadeCurve});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleSnowState();
  }
}

class SingleSnowState extends State<SnowWidget> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        margin: EdgeInsets.only(left: x, top: y),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: new Icon(
            Icons.ac_unit,
            color: widget.snowColor == null ? Colors.white70 : widget.snowColor,
            size: widget.snowSize == null ? 20 : widget.snowSize,
          ),
        ));
  }

  AnimationController fallController, waveController, fadeController;
  Animation fallAnimation, waveAnimation, fadeAnimation;
  double x = 50, y = 200;
  double randomSnowX, randomSnowWave, fallStart, fallEnd;
  int randomSnowFallDuration, randomSnowWaveDuration;
  Curve fadeCurve, waveCurve;

  @override
  void initState() {
    super.initState();
    _setRandomData();
    waveCurve =
        widget.waveCurve == null ? Curves.easeInOutSine : widget.waveCurve;
    fadeCurve = widget.fadeCurve == null ? Curves.easeInCirc : widget.fadeCurve;
    fallStart = widget.snowAreaYStart == null ? 200 : widget.snowAreaYStart;
    fallEnd = widget.snowAreaYEnd == null ? 620 : widget.snowAreaYEnd;
    fallController = AnimationController(
        vsync: this, duration: Duration(seconds: randomSnowFallDuration));
    waveController = AnimationController(
        vsync: this, duration: Duration(seconds: randomSnowWaveDuration));
    fadeController = AnimationController(
        vsync: this, duration: Duration(seconds: randomSnowFallDuration));
    fallAnimation = Tween(begin: fallStart, end: fallEnd)
        .animate(CurvedAnimation(parent: fallController, curve: Curves.linear));
    waveAnimation = Tween(
            begin: randomSnowWaveDuration.isEven
                ? randomSnowX
                : randomSnowX + randomSnowWave,
            end: randomSnowWaveDuration.isEven
                ? randomSnowX + randomSnowWave
                : randomSnowX)
        .animate(CurvedAnimation(parent: waveController, curve: waveCurve));
    fadeAnimation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: fadeController, curve: fadeCurve));
    fallAnimation.addListener(() {
      setState(() {
        y = fallAnimation.value;
      });
    });
    waveAnimation.addListener(() {
      setState(() {
        x = waveAnimation.value;
      });
    });
    fallAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _setRandomData();
        fallController.duration = Duration(seconds: randomSnowFallDuration);
        waveController.duration = Duration(seconds: randomSnowWaveDuration);
        fadeController.duration = Duration(seconds: randomSnowFallDuration);
        fallAnimation = Tween(begin: fallStart, end: fallEnd).animate(
            CurvedAnimation(parent: fallController, curve: Curves.linear));
        waveAnimation = Tween(
                begin: randomSnowWaveDuration.isEven
                    ? randomSnowX
                    : randomSnowX + randomSnowWave,
                end: randomSnowWaveDuration.isEven
                    ? randomSnowX + randomSnowWave
                    : randomSnowX)
            .animate(CurvedAnimation(parent: waveController, curve: waveCurve));
        waveController.reset();
        fallController.reset();
        fadeController.reset();
        fallController.forward();
        fadeController.forward();
        waveController.repeat(reverse: true);
      }
    });
    fallController.forward();
    fadeController.forward();
    waveController.repeat(reverse: true);
  }

  _setRandomData() {
    randomSnowX = _randomSnow(
            poolStart:
                widget.snowAreaXStart == null ? 30 : widget.snowAreaXStart,
            poolEnd: widget.snowAreaXEnd == null ? 220 : widget.snowAreaXEnd)
        .toDouble();
    randomSnowWave = _randomSnow(
            poolStart:
                widget.snowWaveRangeMin == null ? 20 : widget.snowWaveRangeMin,
            poolEnd:
                widget.snowWaveRangeMax == null ? 110 : widget.snowWaveRangeMax)
        .toDouble();
    randomSnowFallDuration = _randomSnow(
        poolStart: widget.snowFallSecMin == null ? 10 : widget.snowFallSecMin,
        poolEnd: widget.snowFallSecMax == null ? 60 : widget.snowFallSecMax);
    randomSnowWaveDuration = _randomSnow(
        poolStart: widget.snowWaveSecMin == null ? 5 : widget.snowWaveSecMin,
        poolEnd: widget.snowWaveSecMax == null ? 20 : widget.snowWaveSecMax);
  }

  int _randomSnow({int poolStart, int poolEnd}) {
    Random random = Random();
    return random.nextInt(poolEnd - poolStart + 1) + poolStart;
  }

  @override
  void dispose() {
    fallController.dispose();
    waveController.dispose();
    fadeController.dispose();
    super.dispose();
  }
}

/*thunderWidget*/

class ThunderConfig {
  final double thunderWidth;
  final Color thunderColor;

  ThunderConfig({this.thunderWidth, this.thunderColor});
}

class ThunderWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.blueGrey[300],
      child: Stack(
        children: _buildPaints(),
      ),
    );
  }

  _buildPaints() {
    List<Widget> _paints = [];
    _paints
        .add(BackgroundWidget(colors: [Colors.white30, Colors.blueGrey[800]]));

    _paints.add(CloudWidget(color: Color(0xB3D6D6D6)));

    _paints.add(ThunderWidget(
        width: widget.thunderConfig.thunderWidth == null
            ? 15
            : widget.thunderConfig.thunderWidth,
        color: widget.thunderConfig.thunderColor == null
            ? Color(0x99FFEE58)
            : widget.thunderConfig.thunderColor));

    _paints.add(ThunderWidget(points: [
      Offset(210, 235),
      Offset(228, 285),
      Offset(212, 295),
      Offset(225, 335)
    ]));

    return _paints;
  }
}

class ThunderWidget extends StatefulWidget {
  final int flashMillStart, flashMillEnd, pauseMillStart, pauseMillEnd;
  final List<Offset> points;
  final Color color;
  final BlurStyle blurStyle;
  final double width, blurSigma;

  ThunderWidget(
      {this.flashMillStart,
      this.flashMillEnd,
      this.pauseMillStart,
      this.pauseMillEnd,
      this.blurStyle,
      this.blurSigma,
      this.points,
      this.color,
      this.width});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleThunderState();
  }
}

class SingleThunderState extends State<ThunderWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FadeTransition(
      opacity: fadeAnimation,
      child: CustomPaint(
        painter: ThunderPainter(
            points: widget.points,
            color: widget.color,
            blurStyle: widget.blurStyle,
            blurSigma: widget.blurSigma,
            width: widget.width),
      ),
    );
  }

  AnimationController fadeController, pauseController;
  Animation fadeAnimation, pauseAnimation;
  int randomFlashDuration, randomPause;

  @override
  void initState() {
    super.initState();
    var fStart, fEnd, pStart, pEnd;
    fStart = widget.flashMillStart == null ? 50 : widget.flashMillStart;
    fEnd = widget.flashMillEnd == null ? 300 : widget.flashMillEnd;
    pStart = widget.pauseMillStart == null ? 50 : widget.pauseMillStart;
    pEnd = widget.pauseMillEnd == null ? 6000 : widget.pauseMillEnd;
    randomFlashDuration = _randomThunder(poolStart: fStart, poolEnd: fEnd);
    randomPause = _randomThunder(poolStart: pStart, poolEnd: pEnd);
    fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: randomFlashDuration));
    fadeAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: fadeController, curve: Curves.linear));
    pauseController = AnimationController(
        vsync: this, duration: Duration(milliseconds: randomPause));
    pauseAnimation = Tween(begin: 0.0, end: 1.0).animate(pauseController);
    pauseAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        randomPause = _randomThunder(poolStart: pStart, poolEnd: pEnd);
        pauseController.duration = Duration(milliseconds: randomPause);
        fadeController.forward();
      }
    });
    fadeAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          fadeController.reverse();
          break;
        case AnimationStatus.dismissed:
          randomFlashDuration =
              _randomThunder(poolStart: fStart, poolEnd: fEnd);
          fadeController.duration = Duration(milliseconds: randomFlashDuration);
          pauseController.reset();
          fadeController.reset();
          pauseController.forward();
          break;
        default:
          break;
      }
    });
    fadeController.forward();
  }

  int _randomThunder({int poolStart, int poolEnd}) {
    Random random = Random();
    return random.nextInt(poolEnd - poolStart + 1) + poolStart;
  }

  @override
  void dispose() {
    fadeController.dispose();
    pauseController.dispose();
    super.dispose();
  }
}

class ThunderPainter extends CustomPainter {
  Paint _paint = Paint();
  List<Offset> points;
  final Color color;
  final BlurStyle blurStyle;
  final double width, blurSigma;

  ThunderPainter(
      {this.blurStyle, this.blurSigma, this.points, this.color, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    _paint.color = color == null ? Color(0x99FFEE58) : color;
    _paint.strokeWidth = width == null ? 15 : width;
    _paint.maskFilter = MaskFilter.blur(
        blurStyle == null ? BlurStyle.solid : blurStyle,
        blurSigma == null ? 10 : blurSigma);
    _paint.style = PaintingStyle.stroke;
    if (points == null) {
      points = new List();
      points.add(Offset(110, 210));
      points.add(Offset(120, 240));
      points.add(Offset(106, 260));
      points.add(Offset(133, 340));
      points.add(Offset(105, 348));
      points.add(Offset(120, 400));
    }

    canvas.drawPoints(PointMode.lines, points, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

/*windWidget*/

class WindWidget extends StatefulWidget {
  final int pauseMillStart, pauseMillEnd, windSlideMill;
  final Color windColor;
  final double windWidth,
      windSlideXStart,
      windSlideXEnd,
      windGap,
      blurSigma,
      windPositionY;
  final BlurStyle blurStyle;

  WindWidget(
      {this.pauseMillStart,
      this.pauseMillEnd,
      this.windPositionY,
      this.windSlideMill,
      this.windColor,
      this.windWidth,
      this.windSlideXEnd,
      this.windSlideXStart,
      this.windGap,
      this.blurStyle,
      this.blurSigma});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleWindWidget();
  }
}

class SingleWindWidget extends State<WindWidget> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FadeTransition(
      opacity: fadeAnimation,
      child: CustomPaint(
        painter: WindPainter(
            listenable: slideAnimation,
            point: slideAnimation,
            windColor: windColor,
            windGap: windGap,
            windSlideY: windSlideY,
            windWidth: windWidth,
            blurStyle: blurStyle,
            blurSigma: blurSigma),
      ),
    );
  }

  AnimationController slideController, fadeController, pauseController;
  Animation slideAnimation, fadeAnimation, pauseAnimation;
  int randomPause;
  double windGap, windSlideY, windWidth, blurSigma;
  Color windColor;
  BlurStyle blurStyle;

  @override
  void initState() {
    super.initState();
    int pStart, pEnd, sDuration;
    pStart = widget.pauseMillStart == null ? 50 : widget.pauseMillStart;
    pEnd = widget.pauseMillEnd == null ? 6000 : widget.pauseMillEnd;
    sDuration = widget.windSlideMill == null ? 1000 : widget.windSlideMill;
    double sStart, sEnd;
    sStart = widget.windSlideXStart == null ? 0.0 : widget.windSlideXStart;
    sEnd = widget.windSlideXEnd == null ? 500.0 : widget.windSlideXEnd;
    windGap = widget.windGap == null ? 15 : widget.windGap;
    windSlideY = widget.windPositionY == null ? 300 : widget.windPositionY;
    windWidth = widget.windWidth == null ? 8 : widget.windWidth;
    windColor = widget.windColor == null ? Colors.blueGrey : widget.windColor;
    blurSigma = widget.blurSigma == null ? 8 : widget.blurSigma;
    blurStyle = widget.blurStyle == null ? BlurStyle.solid : widget.blurStyle;
    randomPause = _randomWind(poolStart: pStart, poolEnd: pEnd);
    slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: sDuration));
    fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: sDuration ~/ 2));
    pauseController = AnimationController(
        vsync: this, duration: Duration(milliseconds: randomPause));
    pauseAnimation = Tween(begin: 0.0, end: 1.0).animate(pauseController);
    slideAnimation = Tween(begin: sStart, end: sEnd).animate(slideController);
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(fadeController);

    pauseAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        randomPause = _randomWind(poolStart: pStart, poolEnd: pEnd);
        pauseController.duration = Duration(milliseconds: randomPause);
        fadeController.reset();
        slideController.reset();
        fadeController.forward();
        slideController.forward();
      }
    });
    fadeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) fadeController.reverse();
    });
    slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pauseController.reset();
        pauseController.forward();
      }
    });
    slideController.forward();
    fadeController.forward();
  }

  int _randomWind({int poolStart, int poolEnd}) {
    Random random = Random();
    return random.nextInt(poolEnd - poolStart + 1) + poolStart;
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    pauseController.dispose();
    super.dispose();
  }
}

class WindPainter extends CustomPainter {
  Paint _paint = Paint();
  Animation<double> point;
  double windGap, windSlideY, windWidth, blurSigma;
  BlurStyle blurStyle;
  Color windColor;

  WindPainter(
      {Listenable listenable,
      this.point,
      this.windGap,
      this.windSlideY,
      this.windWidth,
      this.windColor,
      this.blurSigma,
      this.blurStyle})
      : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    _paint.color = windColor;
    _paint.strokeWidth = windWidth;
    _paint.maskFilter = MaskFilter.blur(blurStyle, blurSigma);
    _paint.style = PaintingStyle.stroke;
    List<Offset> points = new List();
    points.add(Offset(point.value + 10 + (point.value / 10), windSlideY));
    points.add(Offset(point.value + 120 - (point.value / 10), windSlideY));
    points.add(Offset(point.value - (point.value / 10), windSlideY + windGap));
    points.add(
        Offset(point.value + 133 + (point.value / 10), windSlideY + windGap));
    points.add(
        Offset(point.value + 2 + (point.value / 10), windSlideY + windGap * 2));
    points.add(Offset(
        point.value + 110 + (point.value / 10), windSlideY + windGap * 2));

    canvas.drawPoints(PointMode.lines, points, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

/*BackgroundPainter*/
class BackgroundWidget extends StatelessWidget {
  final List<Color> colors;
  final Size size;

  BackgroundWidget({this.colors, this.size});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomPaint(
      painter: BackgroundPainter(colors: colors),
      size: size == null ? Size.infinite : size,
    );
  }
}

class BackgroundPainter extends CustomPainter {
  Paint _paint = Paint();
  List<Color> colors = [];

  BackgroundPainter({this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var rect = Offset.zero & size;
    var gradient = LinearGradient(
        begin: Alignment.bottomLeft, end: Alignment.topRight, colors: colors);
    _paint.shader = gradient.createShader(rect);
    _paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
