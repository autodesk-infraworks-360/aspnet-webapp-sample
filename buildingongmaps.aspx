<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="buildingongmaps.aspx.cs" Inherits="WebApplication1.buildingongmaps" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body onload="listModels()">
    <script src="jquery-2.1.0.js"></script>
    <script src="iw360.js"></script>
     <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true"></script>
    <script>
        var prg = '<img src="progress.gif" alt="Loading..."/> ';
        function listModels() {
            if (isLogged() == true) {
                $('#models').html(prg +'Reading models from server...');
                getModels(function (data) {
                    if (data.d == null) return;
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

                    $.each(data.d.items, function (i, building) {
                        // modelId building.id
                        getBuildingPolygon(modelId, building.id, function (data) {
                            if (map == null) startMap(data.d[0][0], data.d[0][1]);
                            drawExcrudedShape(map, data.d, 0.0005, 100, 90, '#000000', 1, 1, '#FF0000', 0.6);
                        });
                    });
                });
            }
        }


        function drawExcrudedShape(map, coordinates, height, zIndexBase, heading, strokeColor, strokeOpacity, strokeWeight, fillColor, fillOpacity) {
            var pairs = [],
                polygons = [];

            // build line pairs
            for (var i = 0; i < coordinates.length; i++) {

                var point = coordinates[i],
                    otherIndex = (i == coordinates.length - 1) ? 0 : i + 1,
                    otherPoint = coordinates[otherIndex];

                pairs.push([point, otherPoint]);
            }

            // sort the pairs based on which one has the "lowest" point based on the heading
            pairs.sort(function (a, b) {
                var aLowest = 0,
                    bLowest = 0;

                switch (heading) {
                    case 0:
                        aLowest = Math.min(a[0][0], a[1][0]);
                        bLowest = Math.min(b[0][0], b[1][0]);


                        if (aLowest < bLowest) {
                            return 1;
                        } else if (aLowest > bLowest) {
                            return -1;
                        } else {
                            return 0;
                        }
                    case 90:
                        aLowest = Math.min(a[0][1], a[1][1]);
                        bLowest = Math.min(b[0][1], b[1][1]);

                        if (aLowest < bLowest) {
                            return 1;
                        } else if (aLowest > bLowest) {
                            return -1;
                        } else {
                            return 0;
                        }

                    case 180:
                        aLowest = Math.max(a[0][0], a[1][0]);
                        bLowest = Math.max(b[0][0], b[1][0]);


                        if (aLowest > bLowest) {
                            return 1;
                        } else if (aLowest < bLowest) {
                            return -1;
                        } else {
                            return 0;
                        }

                    case 270:
                        aLowest = Math.max(a[0][1], a[1][1]);
                        bLowest = Math.max(b[0][1], b[1][1]);

                        if (aLowest > bLowest) {
                            return 1;
                        } else if (aLowest < bLowest) {
                            return -1;
                        } else {
                            return 0;
                        }

                }
            });

            // draw excrusions
            for (var i = 0; i < pairs.length; i++) {

                var first = pairs[i][0],
                    second = pairs[i][1],
                    wallCoordinates = null;

                switch (heading) {
                    case 0:
                        wallCoordinates = [
                            new google.maps.LatLng(first[0], first[1]),
                            new google.maps.LatLng(first[0] + height, first[1]),
                            new google.maps.LatLng(second[0] + height, second[1]),
                            new google.maps.LatLng(second[0], second[1])
                        ];
                        break;

                    case 90:
                        wallCoordinates = [
                            new google.maps.LatLng(first[0], first[1]),
                            new google.maps.LatLng(first[0], first[1] + height),
                            new google.maps.LatLng(second[0], second[1] + height),
                            new google.maps.LatLng(second[0], second[1])
                        ];
                        break;

                    case 180:
                        wallCoordinates = [
                            new google.maps.LatLng(first[0], first[1]),
                            new google.maps.LatLng(first[0] - height, first[1]),
                            new google.maps.LatLng(second[0] - height, second[1]),
                            new google.maps.LatLng(second[0], second[1])
                        ];
                        break;

                    case 270:
                        wallCoordinates = [
                            new google.maps.LatLng(first[0], first[1]),
                            new google.maps.LatLng(first[0], first[1] - height),
                            new google.maps.LatLng(second[0], second[1] - height),
                            new google.maps.LatLng(second[0], second[1])
                        ];
                        break;
                }

                var polygon = new google.maps.Polygon({
                    paths: wallCoordinates,
                    strokeColor: strokeColor,
                    strokeOpacity: strokeOpacity,
                    strokeWeight: strokeWeight,
                    fillColor: fillColor,
                    fillOpacity: fillOpacity,
                    zIndex: zIndexBase + i
                });

                polygon.setMap(map);

                polygons.push(polygon);
            }

            return polygons;
        }

        var map = null;

        function startMap(la, lo) {
            // Create a simple map.
            map = new google.maps.Map(document.getElementById('theMap'), {
                center: { lat: la, lng: lo },
                zoom: 18,
                mapTypeId: google.maps.MapTypeId.SATELLITE,
                heading: 90,
                rotateControl: true,
                tilt: 45
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

        #theMap {
            border: solid 1px #808080;
            float: left;
            width: 1100px;
            height: 600px;
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
            <asp:Button ID="btnLogin" runat="server" OnClick="btnLogin_Click" Text="Login" />
            <asp:Label ID="lblError" runat="server"></asp:Label>
        </div>
        <div id="models">
        </div>
        <div id="theMap">
        </div>
    </form>
</body>
</html>
