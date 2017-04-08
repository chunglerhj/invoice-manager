<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InvoiceManager._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="jumbotron">
        <h1>INVOICE MANAGER</h1>
        <p class="lead">This Web Application ...</p>
        <p><a class="btn btn-primary btn-lg" runat="server" href="~/About">Learn more &raquo;</a></p>
    </div>

    <div class="row">
        <div class="col-md-4">
            <h2>Getting started</h2>
            <p>
                This Web Applicaton ...
            </p>
            <p>
                <a class="btn btn-default" runat="server" href="~/DataExtract">Data Extract &raquo;</a>
            </p>
        </div>
    </div>

</asp:Content>
