<%@ Page Title="Data Extract" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DataExtract.aspx.cs" Inherits="InvoiceManager.DataExtract" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        #wrapper { position:absolute; top:90px; bottom:0; left:0; right:0; padding:5px; }
        table { font-family:arial, sans-serif; border-collapse:collapse; width:100%; height:100%; }
        .overflow_auto { border:4px solid #dddddd; text-align:left; padding:0; width:100%; height:100%; overflow:auto; }
        .non_selectable { user-select:none; -moz-user-select:none; -webkit-user-drag:none; -webkit-user-select:none; -ms-user-select:none; }
        .round_button {width: 200px; height: 40px; float:left; margin:5px; border-radius:5px; font-size:20px; color:#fff; line-height:40px; text-align:center; background:darkseagreen; }
        .zoom_button { width:40px; height:40px; float:left; margin:5px; border-radius:50%; font-size:30px; color:#fff; line-height:40px; text-align:center; background:darkseagreen; }
        .zoom_button:hover, .round_button:hover { background:darkolivegreen; cursor:pointer; }
    </style>

    <script>
        var mouseX1 = 0, mouseY1 = 0, mouseX2 = 0, mouseY2 = 0;
        $(document).ready(function () {
            loadInvoiceDataInfoList();
            var mousePressed = false;
            mouseX1 = 0;
            mouseY1 = 0;
            mouseX2 = 0;
            mouseY2 = 0;

            $('.drawing_pad').mousedown(function (e) {
                mousePressed = true;
                var offset = $(this).offset();
                mouseX1 = getRealCoordinate(e.pageX - offset.left);
                mouseY1 = getRealCoordinate(e.pageY - offset.top);
                mouseX2 = mouseX1;
                mouseY2 = mouseY1;
                drawRectOnInvoiceImage();
            });

            $('.drawing_pad').mouseup(function (e) {
                mousePressed = false;
                var jsonData = { invoiceNo: $('#invoice_data_info_list').val(), X1: parseInt(mouseX1), Y1: parseInt(mouseY1), X2: parseInt(mouseX2), Y2: parseInt(mouseY2) };
                $.ajax({
                    type: 'POST',
                    url: 'DataExtract.aspx/GetInvoiceDataForRect',
                    data: JSON.stringify(jsonData),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (respondingMessage) {
                        $('#<%=ExtractResultTextBox.ClientID%>').val(respondingMessage.d);
                    },
                    error: function (e) {
                        console.log('Failed');
                    }
                });
            });

            $('.drawing_pad').mousemove(function (e) {
                if (mousePressed == false) return;
                var offset = $(this).offset();
                mouseX2 = getRealCoordinate(e.pageX - offset.left);
                mouseY2 = getRealCoordinate(e.pageY - offset.top);
                drawRectOnInvoiceImage();
            });

            $('#invoice_data_info_list').change(function (e) {
                var jsonData = { invoiceNo: $(this).val() };
                $.ajax({
                    type: 'POST',
                    url: 'DataExtract.aspx/GetInvoiceDataInfo',
                    data: JSON.stringify(jsonData),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (respondingMessage) {
                        var invoiceDataInfo = respondingMessage.d.split("|");
                        $('#invoice_image_width').val(invoiceDataInfo[1]);
                        $('#invoice_image_height').val(invoiceDataInfo[2]);
                        $('#zoom_scale').val(100);
                        changeInvoiceImage(invoiceDataInfo[0]);
                        resizeInvoiceImage(invoiceDataInfo[1], invoiceDataInfo[2]);
                        mouseX1 = 0;
                        mouseY1 = 0;
                        mouseX2 = 0;
                        mouseY2 = 0;
                        drawRectOnInvoiceImage();
                    },
                    error: function (e) {
                        console.log('Failed');
                    }
                });
            });

        });

        function loadInvoiceDataInfoList() {
            $.ajax({
                type: 'POST',
                url: 'DataExtract.aspx/GetInvoiceDataInfoList',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (respondingMessage) {
                    var invoiceDataInfoList = respondingMessage.d.split("|");
                    for (var i = 0; i < invoiceDataInfoList.length; i++) {
                        $('#invoice_data_info_list').append($('<option></option>').attr('value', i).text(invoiceDataInfoList[i]));
                    }
                    $('#invoice_data_info_list').val($('#invoice_data_info_list').val()).trigger('change');
                },
                error: function (e) {
                    console.log('Failed');
                }
            });
        }

        function changeInvoiceImage(invoiceImage) {
            $('#invoice_image').attr('xlink:href', invoiceImage);
        }

        function resizeInvoiceImage(width, height) {
            $('#svg').attr('width', width);
            $('#svg').attr('height', height);
            $('#invoice_image').attr('width', width);
            $('#invoice_image').attr('height', height);
        }

        function drawRectOnInvoiceImage() {
            $("#drawing_rect").attr("x", getImageCoordinate(Math.min(mouseX1, mouseX2)));
            $("#drawing_rect").attr("y", getImageCoordinate(Math.min(mouseY1, mouseY2)));
            $("#drawing_rect").attr("width", getImageCoordinate(Math.abs(mouseX1 - mouseX2)));
            $("#drawing_rect").attr("height", getImageCoordinate(Math.abs(mouseY1 - mouseY2)));
        }

        function getRealCoordinate(imageCoordinate) {
            var zoomScale = parseInt($('#zoom_scale').val());
            return imageCoordinate * 100 / zoomScale;
        }

        function getImageCoordinate(realCoordinate) {
            var zoomScale = parseInt($('#zoom_scale').val());
            return realCoordinate * zoomScale / 100;
        }

        function populateLineItems() {
            var jsonData = { invoiceNo: $('#invoice_data_info_list').val(), X1: parseInt(mouseX1), Y1: parseInt(mouseY1), X2: parseInt(mouseX2), Y2: parseInt(mouseY2) };
            $.ajax({
                type: 'POST',
                url: 'DataExtract.aspx/GetInvoiceLineItemDataForRect',
                data: JSON.stringify(jsonData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (respondingMessage) {
                    $('#<%=ExtractResultTextBox.ClientID%>').val(respondingMessage.d);
                },
                error: function (e) {
                    console.log('Failed');
                }
            });
        }

        function zoomIn() {
            zoomInvoiceImage(5);
        }

        function zoomOut() {
            zoomInvoiceImage(-5);
        }

        function zoomInvoiceImage(zoomScaleDelta) {
            var zoomScale = parseInt($('#zoom_scale').val()) + zoomScaleDelta;
            if (zoomScale < 50 || zoomScale > 200) return;
            $('#zoom_scale').val(zoomScale);
            var width = parseInt($('#invoice_image_width').val()) * zoomScale / 100;
            var height = parseInt($('#invoice_image_height').val()) * zoomScale / 100;
            resizeInvoiceImage(width, height);
            x1 = mouseX1 * zoomScale / 100;
            y1 = mouseY1 * zoomScale / 100;
            x2 = mouseX2 * zoomScale / 100;
            y2 = mouseY2 * zoomScale / 100;
            var w = x2 - x1;
            var h = y2 - y1;
            drawRectOnInvoiceImage(Math.min(x1, x2), Math.min(y1, y2), Math.abs(w), Math.abs(h));
        }

    </script>
    
    <input type="hidden" id="invoice_image_width" />
    <input type="hidden" id="invoice_image_height" />
    <input type="hidden" id="zoom_scale" />
    <div id='wrapper'>
        <table style="table-layout:fixed;">
            <tr>
                <td style="width:300px;">
                    <div class='overflow_auto'>
                        <table style="table-layout:fixed;">
                            <tr style="height:40px;">
                                <td>
                                    <div>
                                        <label>Please select file</label>
                                        <select id='invoice_data_info_list' style="width:100%;"></select>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div class='overflow_auto'>
                                        <asp:TextBox ID="ExtractResultTextBox" runat="server" Width="100%" Height="100%" BorderStyle="None" TextMode="MultiLine" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
                <td>
                    <div class='overflow_auto' style="background-color:darkgray;">
                        <svg id='svg' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='100%' height='100%'>
                            <image id='invoice_image' xlink:href="res/images/invoice-folder.jpg" x='0' y='0' width='0' height='0' />
                            <rect id='drawing_rect' x='0' y='0' width='0' height='0' style="stroke:red; stroke-width:2; fill-opacity:0.1"/>
                            <rect class='drawing_pad' x='0' y='0' width='100%' height='100%' style="cursor:crosshair; fill:red; fill-opacity:0"/>
                        </svg>
                    </div>
                </td>
            </tr>
        </table>
        <div style="position:absolute; left:350px; top:30px;">
            <div class="round_button non_selectable" onclick="populateLineItems()">PopulateLineItems</div>
            <div class="zoom_button non_selectable" onclick="zoomIn()">+</div>
            <div class="zoom_button non_selectable" onclick="zoomOut()">-</div>
        </div>
    </div>
    
</asp:Content>
