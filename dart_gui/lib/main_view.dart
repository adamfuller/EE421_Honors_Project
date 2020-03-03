part of app;

class MainView extends StatefulWidget {
  MainView();

  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> {
  MainViewModel vm;

  @override
  void initState() {
    vm = new MainViewModel(() {
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: vm.isLoading ? Loading() : _getBody(),
    );
  }

  Widget _getBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 4 / 5,
          // width: MediaQuery.of(context).size.width * 2 / 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _getPreviewWindow(),
              _getSideControls(),
            ],
          ),
        ),
        _getBottomControls(),
      ],
    );
  }

  Widget _getSideControls() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getFiltersList(),
        _getAddFilter(),
        _getOutputDropdown(),
      ],
    );
  }

  Widget _getPreviewWindow() {
    double Function(double) signalOne = (x) => (0.5 * sin(x * 0.1 * 3.14159265) + 0.1 * cos(x * 1 * 3.14159265));
    double Function(double) signalTwo = (x) => (0.5 * cos(x * 0.1 * 3.14159265) + 0.1 * sin(x * 1 * 3.14159265));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CustomWidget(
          size: Size(
            MediaQuery.of(context).size.width * 3 / 5,
            MediaQuery.of(context).size.height * 4 / 5,
          ),
          onPaint: (c, size, progress) {
            double w = size.width;
            double h = size.height;
            Paint p1 = Paint()..color = Colors.blue;
            Paint p2 = Paint()..color = Colors.red;
            Paint p3 = Paint()..color = Colors.yellow.withAlpha(75);
            p1.strokeWidth = 1.5;
            p2.strokeWidth = 1.5;
            p3.strokeWidth = 1.5;

            double stamp = DateTime.now().millisecondsSinceEpoch / 100.0;
            double Function(double) scale = (i) => (h + i * h) / 2.0;

            if (vm.signal1.length > MainViewModel.signalLength) {
              vm.signal1.removeAt(0);
              vm.signal2.removeAt(0);
            }

            vm.signal1.add(signalOne(stamp));
            vm.signal2.add(signalTwo(stamp));

            for (int i = 0; i < vm.signal1.length - 1; i++) {
              double x1 = (i / MainViewModel.signalLength) * w;
              double x2 = (i + 1) / MainViewModel.signalLength * w;
              c.drawLine(Offset(x1, scale(vm.signal1[i])), Offset(x2, scale(vm.signal1[i + 1])), p1);
            }
            for (int i = 0; i < vm.signal2.length - 1; i++) {
              double x1 = (i / MainViewModel.signalLength) * w;
              double x2 = (i + 1) / MainViewModel.signalLength * w;
              c.drawLine(Offset(x1, scale(vm.signal2[i])), Offset(x2, scale(vm.signal2[i + 1])), p2);
            }
            if (vm.operation != null){
              for (int i = 0; i<vm.signal1.length-1;i++){
                double x1 = (i / MainViewModel.signalLength) * w;
                double x2 = (i + 1) / MainViewModel.signalLength * w;
                double val1 = vm.operation(vm.signal1[i], vm.signal2[i]);
                double val2 = vm.operation(vm.signal1[i+1], vm.signal2[i+1]);
                c.drawLine(Offset(x1, scale(val1)), Offset(x2, scale(val2)), p3);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _getFiltersList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text("Filters"),
        Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width * 2 / 5 - 24,
          child: Card(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 0,
              ),
              itemCount: vm.filters.length,
              itemBuilder: (c, i) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 3),
                title: Text(vm.filters[i]),
                subtitle: Text("BW: ${vm.filterSettings[i]["bw"]}, Fc: ${vm.filterSettings[i]["fc"]}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete_forever),
                  color: Colors.red,
                  onPressed: () => vm.removeFilterPressed(i),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getAddFilter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("Customize Filter"),
            FlatButton(
              child: Text("Add"),
              onPressed: vm.canAddFilter ? vm.addFilter : null,
            ),
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width * 2 / 5 - 24,
          child: Card(
            child: ListView(
              children: [
                DropdownButton(
                  hint: Text("Filter Type"),
                  onChanged: vm.filterTypeChanged,
                  value: vm.currentFilterSettings["type"],
                  items: vm.filterTypes.map<DropdownMenuItem<String>>(
                    (option) {
                      return DropdownMenuItem(child: Text(option), value: option);
                    },
                  ).toList(),
                ),
                TextFormField(
                  controller: vm.bandwidthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Bandwidth",
                    labelText: "Bandwidth (Hz)",
                  ),
                  onChanged: vm.bandwidthChanged,
                ),
                TextFormField(
                  controller: vm.cuttoffFreqController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Cutoff Frequency",
                    labelText: "Cutoff Frequency (Hz)",
                  ),
                  onChanged: vm.cutoffFrequencyChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getOutputDropdown() {
    return Column(
      children: [
        Text("Output"),
        DropdownButton(
          onChanged: vm.outputChanged,
          value: vm.outputOptions[vm.chosenOutputIndex],
          items: vm.outputOptions.map<DropdownMenuItem<String>>(
            (option) {
              return DropdownMenuItem(child: Text(option), value: option);
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _getBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            child: const Text("FFT"),
            onPressed: () {},
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            child: const Text("Add"),
            onPressed: vm.setAdd,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            child: const Text("Multiply"),
            onPressed: vm.setMultiply,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            child: const Text("Reset"),
            onPressed: vm.resetOperation,
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: CircularProgressIndicator());
}
