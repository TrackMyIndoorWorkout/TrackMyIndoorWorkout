const measurementSinkAddress = "Measurement Sink Server Address";
const measurementSinkAddressTag = "measurement_sink_address";
const measurementSinkAddressDefault = "";

const measurementSinkAddressDescription =
    "Domain name or IP address with a comma separated port number. "
    "The port number is mandatory. "
    "The application will live stream the workout measurement data "
    "in a proprietary format to that address. The original intention "
    "is that the receiver can act as a BLE peripheral and advertise the "
    "workout as an FTMS. This can be especially useful if an FTMS compatible "
    "software is incompatible with an fitness equipment such as Kinomap "
    "doesn't support Precor Spinner Chrono Power or CSC sensor based DIY "
    "trainer setup or the Old Danube ergometer";
