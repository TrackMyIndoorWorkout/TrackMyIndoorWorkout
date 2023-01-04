import '../utils/constants.dart';

const measurementSinkAddress = "Measurement Sink Server Name or IP Address";
const measurementSinkAddressTag = "measurement_sink_address";
const measurementSinkAddressDefault = "";
const measurementSinkAddressDescription =
    "Domain name or IP address of a special FTMS receiver server. "
    "The application will live stream the workout measurement data "
    "in format to that address (preceded by a description packet). "
    "The intention is that the receiver (sink) can act as a BLE peripheral "
    "and advertise the workout as a BLE FTMS. This can be especially useful "
    "if recording software (such as Kinomap) is incompatible with certain "
    "fitness equipment Track My Indoor Workout understands, such as "
    "Precor Spinner Chrono Power or CSC sensor based DIY trainer setup or "
    "the Old Danube ergometer";

const measurementSinkPort = "Measurement Sink Server Port Number";
const measurementSinkPortTag = "measurement_sink_port";
const measurementSinkPortDefault = 80;
const measurementSinkPortDescription = "The port number for the above described server.";
const portNumberMin = 1;
const portNumberMax = maxUint16 - 1;
const portNumberDivisions = portNumberMax - portNumberMin;
