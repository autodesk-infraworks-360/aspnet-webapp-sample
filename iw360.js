function test() {
    alert("working");

    $.getJSON('https://api.foursquare.com/v2/venues/search?client_id=PX2N3Y2FQTQLSDVWQK52WKMQ1CESC5RIVFBOTQWRUU0JW0YN &client_secret=PAETRB354N534UOX5BVBNT3FWD5Q45UORVZWSYXXB5JC2ETZ &v=20130815 &ll=37.7936515,-122.3947876 &radius=100',
    function (data) {
        $.each(data.response.venues, function (i, venues) {
            content = '<p>' + venues.name + '</p>';
            $(content).appendTo("#names");
        });
    });
}

var logged;
function isLogged() {
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/IsLogged',
        dataType: 'json',
        async: false,
        success: function (data, status) {
            if (data.d == true) {
                logged = true;
                return;
            }
            logged = false;
            return;
        }
    });
    return logged;
}

function getModels(getModelsCallback) {
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModels',
        dataType: 'json',
        success: function (data) { getModelsCallback(data); }
    });
}

function getModel(id, getModelCallback) {
    //var idAsInt = parseInt(id);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModel',
        data: JSON.stringify({ modelId: id }),
        dataType: 'json',
        success: function (data) { getModelCallback(data); }
    });
}

function getModelRoads(id, getModelRoadsCallback) {
    //var idAsInt = parseInt(id);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModelRoads',
        data: JSON.stringify({ modelId: id }),
        dataType: 'json',
        success: function (data) { getModelRoadsCallback(data); }
    });
}

function getModelBuildings(id, getModelRoadsCallback) {
    //var idAsInt = parseInt(id);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModelBuildings',
        data: JSON.stringify({ modelId: id }),
        dataType: 'json',
        success: function (data) { getModelRoadsCallback(data); }
    });
}

function getBuildingSummaryInfo(modelId, buildingId, getBuildingSummaryCallback) {
    //var modelIdAsInt = parseInt(modeId);
    //var buildingIdAsInt = parseInt(buildingId);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModelBuildingSummary',
        data: JSON.stringify({ modelId: modelId, buildingId: buildingId }),
        dataType: 'json',
        success: function (data) { getBuildingSummaryCallback(data); }
    });
}

function getBuildingPolygon(modelId, buildingId, getBuildingPolygonCallback) {
    //var modelIdAsInt = parseInt(modeId);
    //var buildingIdAsInt = parseInt(buildingId);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetBuildingPolygon',
        data: JSON.stringify({ modelId: modelId, buildingId: buildingId }),
        dataType: 'json',
        success: function (data) { getBuildingPolygonCallback(data); }
    });
}

function getBuildingInfo(modeId, buildingId, getBuildingInfoCallback) {
    //var modelIdAsInt = parseInt(modeId);
    //var buildingIdAsInt = parseInt(buildingId);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetModelBuilding',
        data: JSON.stringify({ modelId: modelId, buildingId: buildingId }),
        dataType: 'json',
        success: function (data) { getBuildingInfoCallback(data); }
    });
}

function getVenuesNearBuildingInfo(modelId, buildingId, getVenuesNearBuildingInfoCallback) {
    //var modelIdAsInt = parseInt(modeId);
    //var buildingIdAsInt = parseInt(buildingId);
    $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: 'IW360Methods.asmx/GetVenuesNearBuilding',
        data: JSON.stringify({ modelId: modelId, buildingId: buildingId }),
        dataType: 'json',
        success: function (data) { getVenuesNearBuildingInfoCallback(data); }
    });
}