using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication1
{
  public partial class buildingongmaps : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      btnLogin.Visible = !IW360OAuth.IsAuthorized;
      if (!IW360OAuth.IsAuthorized) return;


    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
      if (IW360OAuth.IsAuthorized) return; // redundant...

      IW360OAuth oAuth = new IW360OAuth();
      if (oAuth.CallLogin() != System.Net.HttpStatusCode.OK)
      {
        lblError.Text = "Oops! Something went wrong - couldn't request token Autodesk oxygen provider";
        return;
      }
      ClientScript.RegisterStartupScript(this.GetType(), "AutodeskOAuth", "<script>window.open('" + oAuth.LoginURL + "',this, 'dialogWidth:400px;dialogHeight:300px;resizable:no;');</script>");
    }
  }
}