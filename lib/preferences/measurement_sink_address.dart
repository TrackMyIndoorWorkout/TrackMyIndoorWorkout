const measurementSinkAddress = "Measurement Sink Server Name or IP Address";
const measurementSinkAddressTag = "measurement_sink_address";
const measurementSinkAddressDefault = "";
const measurementSinkAddressDescription =
    "Domain name or IP address of a special FTMS receiver server (with a "
    "mandatory port number). "
    "The application will live stream the workout measurement data "
    "in format to that address (preceded by a description packet). "
    "The intention is that the receiver (sink) can act as a BLE peripheral "
    "and advertise the workout as a BLE FTMS. This can be especially useful "
    "if recording software (such as Kinomap) is incompatible with certain "
    "fitness equipment Track My Indoor Workout understands, such as "
    "Precor Spinner Chrono Power or CSC sensor based DIY trainer setup or "
    "the Old Danube ergometer";
