#Autodesk InfraWorks 360 REST API sample with ASP.NET

##Description

This sample uses the InfraWorks 360 REST API to read user data hosted on the Autodesk Cloud. It reads the building information, such as Name (if available) and location (polygon). Then calculate the center point (average of the polygon coordinates) and connect to Four Square API to get the venues at that location. Finally show the 2 locations (InfraWorks 360 and FourSquare) on a Google Maps interface.

##Dependencies

This sample uses the [RestSharp](http://restsharp.org), [SharpSquare](https://github.com/TICLAB/SharpSquare). You can add it to your project using NuGet in Visual Studio. Also the [InfraWorks 360 REST API Library](https://github.com/ADN-DevTech/Infraworks_API_Samples). 

##Live sample

This sample is published live [here](http://infraworks360samples.azurewebsites.net/IW360Demo.aspx). You must have an Autodesk Account with at least one InfraWorks 360 project/proposal synched/published.

##Setup/Usage Instructions

Download the sample, add the required packages (RestSharp and SharpSquare), download and add reference to the InfraWorks 360 REST API library. Finally add your Autodesk Developer key & secret, also your FourSquare client ID and secret.

## License

This sample is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Please see the [LICENSE](LICENSE) file for full details.

##Written by 

Augusto Goncalves





    
