<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IW360Demo.aspx.cs" Inherits="WebApplication1.IW360Demo" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>General demo for Infraworks 360</title>
</head>
<body onload="listModels()">
    <script src="jquery-2.1.0.js"></script>
    <script src="iw360.js"></script>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
    <script>
        var prg = '<img src="progress.gif" alt="Loading..."/> ';
        function listModels() {
            if (isLogged() == true) {
                $('#models').html(prg +'Reading models from server...');
                getModels(function (data) {
                    if (data.d == null) { $('#models').html('Cannot read models. Do you have InfraWorks 360 models on your account?'); return; }
                    $('#models').html('');
                    $.each(data.d, function (i, model) {
                        content = '<div id="model_' + model.id + '" onclick="selectModel(' + model.id + ')" class="bottomBorder">' + model.name + '</div>';
                        $(content).appendTo("#models");
                    });
                });
            }
            else {
                $('#models').html('Please login first');
            }
        }

        function selectModel(modelId) {
            if (isLogged()) {
                $('#buildings').html(prg + 'Reading buildings of this model...');
                $('#foursquareVenues').html('');
                $('#theMap').html('');
                getModelBuildings(modelId, function (data) {
                    $('#buildings').html('');
                    if (data.d == null) {
                        $('#buildings').html('The model still openning on server, please try again later.');
                        return;
                    }
                    if (data.d.items.length == 0) {
                        $('#buildings').html('This model has no buildings');
                        return;
                    }
                    var content = '';
                    $.each(data.d.items, function (i, building) {
                        var divName = 'building_' + building.id;
                        content = '<div id="' + divName + '" onclick="selectBuilding(' + modelId + ',' + building.id + ')"  class="bottomBorder" onmouseover="getBuildingName(' + modelId + ',' + building.id + ')">' + building.id + ':</div>';
                        $(content).appendTo("#buildings");
                    });
                });
            }
        }

        function selectBuilding(modelId, buildingId) {
            $('#foursquareVenues').html(prg + 'Searching venues (via FourSquare) around this building...');
            $('#theMap').html('');
            if (isLogged()) {
                getVenuesNearBuildingInfo(modelId, buildingId, function (data) {
                    $('#foursquareVenues').html('');
                    $.each(data.d, function (i, venue) {
                        content = '<div id="venue_' + venue.id + '" class="bottomBorder" onclick="selectVenue(\'' + venue.name + '\',' + venue.foursqlat + ', ' + venue.foursqlng + ', ' + venue.iw360lat + ', ' + venue.iw360lng + ')">' + venue.name + ' (' + venue.distance + 'm)<br/>' + venue.address + '</div>';
                        $(content).appendTo("#foursquareVenues");
                    });
                });
            }
        }

        function getBuildingName(modelId, buildingId) {
            $('#building_' + buildingId).removeAttr('onmouseover'); // remove handle
            if (isScrolledIntoView('#building_' + buildingId)) {
                $('#building_' + buildingId).html(buildingId + ': [Loading name...]');
                getBuildingSummaryInfo(modelId, buildingId, function (data) {
                    $('#building_' + buildingId).html(buildingId + ': ' + data.d[0] + data.d[1]);
                });
            }
        }


        function selectVenue(name, foursqlat, foursqlng, iw360lat, iw360lng) {
            var foursqCoord = new google.maps.LatLng(foursqlat, foursqlng);
            var iw360Coord = new google.maps.LatLng(iw360lat, iw360lng);
            var mapOptions = {
                zoom: 15,
                center: foursqCoord
            };
            var map = new google.maps.Map(document.getElementById('theMap'), mapOptions);
            var marker = new google.maps.Marker({
                position: foursqCoord,
                map: map,
                title: name + ' (from FourSquare)'
            });
            var marker = new google.maps.Marker({
                position: iw360Coord,
                map: map,
                title: 'IW360 Coordinate'
            });
        }


        ////
        // from http://stackoverflow.com/questions/487073/check-if-element-is-visible-after-scrolling/488073#488073
        ////
        function isScrolledIntoView(elem) {
            var docViewTop = $(window).scrollTop();
            var docViewBottom = docViewTop + $(window).height();

            var elemTop = $(elem).offset().top;
            var elemBottom = elemTop + $(elem).height();

            return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
        }

        function panoramio() {
            $.get('http://www.panoramio.com/wapi/data/get_photos?v=1&key=dummykey&tag=test&offset=0&length=20&callback=processImages&minx=-30&miny=0&maxx=0&ma',//'https://www.panoramio.com/map/get_panoramas.php?order=popularity&set=full&from=0&to=10&minx=-3.59&miny=37.17&maxx=-3.79&maxy=37.37&size=medium',
                 function (data) {
                     var thePicsHTML;
                     $(data).each(function (i, item) {
                         thePhoto = $(this)[0].photos[i];
                         thePicsHTML += "<img src='" + thePhoto.photo_file_url + "'>";
                         thePicsHTML += "";
                         thePicsHTML += thePhoto.photo_title;
                         thePicsHTML += "";
                         thePicsHTML += "Photo from: " + thePhoto.owner_name;
                         thePicsHTML += "";
                         thePicsHTML += "<a href='" + thePhoto.photo_url + "' target=_blank>Check the photo at Panoramio</a>";
                         thePicsHTML += "<p>";
                     });
                     $("#thePics").html(thePicsHTML);
                 });
        }
    </script>
    <style type="text/css">
        #models {
            border: solid 1px #808080;
            float: left;
            width: 300px;
            height: 300px;
            overflow-y: auto;
            padding: 0px;
        }

        #buildings {
            border: solid 1px #808080;
            float: left;
            width: 300px;
            height: 300px;
            overflow-y: auto;
            padding: 0px;
        }

        #foursquareVenues {
            border: solid 1px #808080;
            float: left;
            width: 300px;
            height: 300px;
            overflow-y: auto;
            padding: 0px;
        }

        #theMap {
            border: solid 1px #808080;
            float: left;
            width: 300px;
            height: 300px;
            overflow: hidden;
            padding: 0px;
        }

        #thePics {
            border: solid 1px #808080;
            float: left;
            width: 300px;
            height: 300px;
            overflow: hidden;
            padding: 0px;
        }

        .bottomBorder {
            padding: 3px;
            border-bottom: solid 1px #bab8b8;
            background-color: #F5F5F5;
            cursor: pointer;
        }
    </style>
    <form id="form1" runat="server">
        <div>

            <asp:Button ID="btnLogin" runat="server" OnClick="btnLogin_Click" Text="Login with Autodesk account" />
            <asp:Label ID="lblError" runat="server"></asp:Label>

        </div>
        <div id="models">
        </div>
        <div id="buildings">
        </div>
        <div id="foursquareVenues">
        </div>
        <div id="theMap">
        </div>
    </form>
</body>
</html>
