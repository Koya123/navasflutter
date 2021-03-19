import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AstronomyHomePage extends StatefulWidget {
  @override
  _AstronomyHomePageState createState() => _AstronomyHomePageState();
}

class _AstronomyHomePageState extends State<AstronomyHomePage> {

  String _formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  var _fetchedData;
  String _apdMedia='';
  String _imageUrl='';
  String _title='', _explanation='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getApodData();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      breakpoints: ScreenBreakpoints(desktop: 900, tablet: 650, watch: 250),
      mobile: OrientationLayoutBuilder(
        portrait: (context) => _apodScaffold('mobile'),
        // landscape: (context) => HomeMobileLandscape(),
      ),
      tablet: OrientationLayoutBuilder(
        portrait: (context) => _apodScaffold('tab'),
      ),

      desktop: _apodScaffold('desk'),
    );

  }

  _apodScaffold(String _mode){
    Size _pageSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Astronomy Picture of the Day',
                  style: GoogleFonts.ubuntu(color: Colors.white,
                      fontSize: _mode=='mobile' ? _pageSize.width*.05 : _mode=='tab' ? _pageSize.width*.025 : _pageSize.width*.015,
                      fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(icon: Icon(Icons.calendar_today, color: Colors.white70,), onPressed: _selectDate)
                ),
              ],
            ),
          ),
        ),
      ),
      body: _apodBody(_mode),
    );
  }


  _apodBody(_mode){
    Size _pageSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scrollbar(
        child: ListView(
          children: [

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_formattedDate, style: GoogleFonts.ubuntu(color: Colors.black87),),
              ),
            ),

            _apdMedia =='image' ?
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal:  _pageSize.width*.025 ),
                    constraints: BoxConstraints(
                      maxWidth: _mode=='desk' ? _pageSize.height*.75 : _pageSize.height*.5
                    ),
                    child: Image.network(_imageUrl,
                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: CircularProgressIndicator(
                          ),
                        );
                      },
                    ),
                  ),
                ):
                Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                )),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: _pageSize.width*.05, vertical: _pageSize.height*.025),
              child: Text(
                  _title, style: GoogleFonts.ubuntu(color: Colors.black,
                      fontSize: _mode=='mobile' ? _pageSize.width*.05 : _mode=='tab' ? _pageSize.width*.04 : _pageSize.width*.025, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: _pageSize.width*.05, vertical: _pageSize.height*.025),
              child: Text(
                _explanation, style: GoogleFonts.ubuntu(color: Colors.black, fontSize: _mode=='mobile' ? _pageSize.width*.042 : _mode=='tab' ? _pageSize.width*.03 : _pageSize.width*.018,), textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getApodData() async{

    Dio _dio = Dio();
    Response response = await _dio.get(
        'https://api.nasa.gov/planetary/apod?api_key=aWPhODExHc5j48m59viPzCysv1jkoaN7ID2dchPw&date=$_formattedDate',
    );
    setState(() {
      _fetchedData = response.data;
      _apdMedia = _fetchedData['media_type'];
      _imageUrl = _fetchedData['url'];
      _title = _fetchedData['title'];
      _explanation = _fetchedData['explanation'];
    });
    print(_fetchedData);
  }

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now() ,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015) ,
        lastDate: DateTime.now());
    if (picked != null){
      setState(() {
        _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });

      _getApodData();
    }

  }
}
