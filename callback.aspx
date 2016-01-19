<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="callback.aspx.cs" Inherits="WebApplication1.callback" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body onload="closeThis();">
    <form id="form1" runat="server">
    <div>
        You are authenticated. Now you can close this page.<br/>
    </div>
        <input id="btnClose" type="button" value="Close" onclick="closeThis();" />
    </form>
    <script>
        function closeThis() {
            window.opener.location.reload(true);
            window.self.close();
        }
    </script>
</body>
</html>
