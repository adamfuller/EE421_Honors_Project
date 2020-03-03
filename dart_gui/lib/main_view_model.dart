part of app;

class MainViewModel {
  static const int signalLength = 400;

  //
  // Private members
  //
  List<StreamSubscription> _listeners;

  //
  // Public Properties
  //
  Function onDataChanged;
  bool isLoading = true;

  double sliderVal = 0.1;

  List<double> signal1 = List.filled(signalLength, 0, growable: true);
  List<double> signal2 = List.filled(signalLength, 0, growable: true);
  List<double> filteredSignal = List.filled(signalLength, 0, growable: true);
  TextEditingController cuttoffFreqController = TextEditingController(text: "");
  TextEditingController bandwidthController = TextEditingController(text: "");

  List<String> filters = [];
  List<Map<String, dynamic>> filterSettings = [];
  Map<String, dynamic> currentFilterSettings = {};
  double Function(double,double) operation;

  int chosenOutputIndex = 0;
  List<String> outputOptions = [
    "None",
    "Input 1",
    "Input 2",
    "Add Inputs",
    "Multiply Inputs",
    "Filter Output",
  ];

  List<String> filterTypes = [
    "Low-pass",
    "High-pass",
    "Band-pass",
    "Band-stop",
  ];

  //
  // Getters
  //

  bool get canAddFilter => this.currentFilterSettings.containsKey("type") && bandwidthController.text.isNotEmpty && cuttoffFreqController.text.isNotEmpty;

  //
  // Constructor
  //
  MainViewModel(this.onDataChanged) {
    init();
  }

  //
  // Public functions
  //
  void init() async {
    if (_listeners == null) _attachListeners();

    //
    // Write any initializing code here
    //

    this.isLoading = false;
    onDataChanged();
  }

  void sliderValChanged(double value) {
    this.sliderVal = value;
    onDataChanged();
  }

  void outputChanged(String value) {
    chosenOutputIndex = outputOptions.indexOf(value);
    onDataChanged();
  }

  void removeFilterPressed(int index) {
    this.filters.removeAt(index);
    onDataChanged();
  }

  void addFilter() {
    print("\n\nImplement addFilter\n\n");
    this.filters.add(this.currentFilterSettings["type"]);
    this.filterSettings.add(this.currentFilterSettings);
    this.currentFilterSettings = {};
    this.bandwidthController.text = "";
    this.cuttoffFreqController.text = "";
    onDataChanged();
  }

  void filterTypeChanged(value) {
    this.currentFilterSettings["type"] = value;
    onDataChanged();
  }

  void cutoffFrequencyChanged(String value) {
    this.currentFilterSettings["fc"] = double.tryParse(value);
    onDataChanged();
  }

  void bandwidthChanged(String value) {
    this.currentFilterSettings["bw"] = double.tryParse(value);
    onDataChanged();
  }

  void setAdd(){
    operation = (x,y) => x+y;
    onDataChanged();
  }
  void setMultiply(){
    operation = (x,y) => x*y;
    onDataChanged();
  }

  void resetOperation() {
    operation = null;
    onDataChanged();
  }

  //
  // Private functions
  //
  void _attachListeners() {
    if (this._listeners == null) {
      this._listeners = [
        //
        // Put listeners here
        //
      ];
    }
  }

  //
  // Dispose
  //
  void dispose() {
    this._listeners?.forEach((_) => _.cancel());
  }
}
